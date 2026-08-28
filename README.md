# PRONAME on the BU Shared Computing Cluster (SCC)

This repo documents validating [PRONAME](https://github.com/benn888/PRONAME) — a nanopore metabarcoding
pipeline — for use on BU's Shared Computing Cluster (SCC), ahead of running it against real project data.

## Summary

- PRONAME ships as a Docker image; the SCC supports Singularity, not Docker, so the image was pulled and
  run as a Singularity container (`proname.sif`) instead. This worked with no compatibility issues.
- The full 4-step PRONAME tutorial (`proname_import` → `proname_filter` → `proname_refine` →
  `proname_taxonomy`) was run end-to-end against PRONAME's own published test dataset
  ([NCBI BioProject PRJNA1299388](https://www.ncbi.nlm.nih.gov/bioproject/PRJNA1299388), 10 nanopore
  amplicon samples) to confirm the pipeline runs correctly on the SCC before using it on real data.
- All 4 steps completed successfully, producing final QIIME2 taxonomy/feature-table outputs and a
  taxa barplot.

## Recommended SCC resource requests

Steps 3 and 4 were each benchmarked at two core counts to find a sensible default resource request.
Core count matters differently for each step — more cores is not always better:

| Pipeline step | Recommended cores (`-pe omp N`) | Why |
|---|---|---|
| `proname_refine` (clustering + polishing) | **28** | Both 16 and 28 cores kept 84-86% of requested cores busy — the extra cores at 28 do real work, cutting wall-clock time by ~35% (~4h38m → ~3h02m on the test dataset) for a modest ~15% increase in total core-hours. |
| `proname_taxonomy` (taxonomic classification) | **16** | 16 and 28 cores finished in essentially the same wall-clock time and used the same memory; 28 cores only kept ~59% of its requested cores busy on average, vs. ~76% at 16 — the extra cores aren't doing useful work for this step. |

These are starting points based on a 10-sample test dataset — actual runtime and the ideal core count may
shift somewhat with a larger real dataset, so it's worth spot-checking once real data is running.

## Practical notes for running this pipeline on the SCC

- Run the container with `scc-singularity`, not plain `singularity` — it's the SCC's supported wrapper
  and automatically binds project storage (`/projectnb`, etc.).
- `scc-singularity exec` has a quoting quirk with multi-command `bash -c '...'` strings — write each
  pipeline step as its own script file and run that, rather than an inline multi-statement command.
- `proname_refine`'s clustering (`vsearch`) and polishing (`medaka`) steps have no built-in checkpoint —
  if a job is killed mid-run (e.g. it hits its time-limit ceiling), it must be restarted from scratch.
  Request a generous walltime up front rather than risk this.
- If using `proname_taxonomy --phyloseq yes`: this option expects `rep_seqs.fasta` and `rep_table.tsv` to
  be present as plain files in the current working directory, separately from the `--qseqs`/`--qtable`
  `.qza` inputs — make sure those two files are also available there (e.g. via symlink) or phyloseq
  object generation will fail even though the main taxonomy step succeeds.

## Example batch submission scripts

See [`examples/`](examples/) for `qsub` scripts and the wrapped `proname_*` commands used for each step,
based on the recommended core counts above.
