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

## Building the Singularity container

Following BU's [Building From Docker or Singularity Hub](https://www.bu.edu/tech/support/research/software-and-programming/containers/building/)
guide:

```bash
[user@scc-i01 ~]$ singularity pull proname.sif docker://benn888/proname:v2.3.0-amd64
```

Run from a dedicated build node (`scc-i01`/`scc-i02`), not a general compute node. Took about 15 minutes
to pull and build the ~9.4 GB image. Move the resulting `.sif` to project storage once done; it doesn't
need to stay in scratch space.

## Downloading PRONAME's tutorial test data

PRONAME's own tutorial needs basecalled FASTQ input, one file per sample, in a `RawData/` directory. We
used its published test dataset — [NCBI BioProject PRJNA1299388](https://www.ncbi.nlm.nih.gov/bioproject/PRJNA1299388),
10 nanopore amplicon runs (~9.8 GB in SRA format, ~23.7 GB once converted to FASTQ) — rather than real
project data, to validate the pipeline first. [`download_tutorial_data.sh`](examples/download_tutorial_data.sh)
downloads and converts all 10 runs with SRA Toolkit (`module load sratoolkit/3.3.0`), renaming each to the
`sample<N>.fastq` naming PRONAME's tutorial expects. Took about 6 minutes total on the SCC. Run once from
wherever you want `RawData/` created; no `qsub` needed, it's light enough to run directly.

## Running the 4-step tutorial

Each step runs as its own batch job — submit with `qsub <script>.qsub` (see [`examples/`](examples/) for
the full scripts). A brief description of each step and its key options:

*(Steps 1-2's commands were tested directly; their `qsub` wrapper is a standard batch-job template, not
itself run as a job. Steps 3-4's `qsub` scripts and commands were both run exactly as shown.)*

**1. Import — `qsub import.qsub`** (`proname_import`)
Trims adapters/primers and separates duplex/simplex reads. Key options: sequencing kit and primer
sequences used for the run.

**2. Filter — `qsub filter.qsub`** (`proname_filter`)
Filters reads by length and quality. Key options: `--datatype` (must match whether your data is simplex
or duplex — check step 1's output first) and length/quality thresholds for your target amplicon.

**3. Refine — `qsub refine.qsub`** (`proname_refine`)
Clusters and polishes reads — the long-running step. Key options: clustering similarity threshold,
polishing model (matched to your flow cell/basecaller), and a chimera reference database.

**4. Taxonomy — `qsub taxonomy.qsub`** (`proname_taxonomy`)
Assigns taxonomy to the clustered, polished sequences from step 3. Key options: a reference
database/taxonomy file, and `--phyloseq yes` to also produce an R-ready phyloseq object.

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
- Run all 4 steps in the same working directory (the example scripts do this) — each step reads the
  previous step's output from the current directory, since PRONAME writes its outputs to cwd rather than
  taking a fixed output-path option.
- `proname_refine`'s clustering (`vsearch`) and polishing (`medaka`) steps have no built-in checkpoint —
  if a job is killed mid-run (e.g. it hits its time-limit ceiling), it must be restarted from scratch.
  Request a generous walltime up front rather than risk this.
- If using `proname_taxonomy --phyloseq yes` and you run refine/taxonomy in *separate* directories
  (instead of one shared directory as above): this option expects `rep_seqs.fasta` and `rep_table.tsv` to
  be present as plain files in the current working directory, separately from the `--qseqs`/`--qtable`
  `.qza` inputs — make sure those two files are also available there (e.g. via symlink) or phyloseq
  object generation will fail even though the main taxonomy step succeeds.

## Example scripts

See [`examples/`](examples/): `qsub` scripts and wrapped `proname_*` commands for each pipeline step
(based on the recommended core counts above), plus `download_tutorial_data.sh` for fetching the test
dataset.
