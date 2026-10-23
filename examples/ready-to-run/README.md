# Ready-to-run PRONAME pipeline

Runs all 4 PRONAME steps (import → filter → refine → taxonomy) as SCC batch jobs with one command.
You edit one settings file (`config.sh`), then run `bash submit.sh`.

You do **not** need to run `proname_import` (or any `proname_*` command) yourself. Those commands only
exist inside the container (`proname.sif`), and these scripts take care of running them there.

## What you need

- The PRONAME container, `proname.sif`, somewhere in your project space
- A **folder** containing your raw `.fastq` files, one per sample (e.g. `RawData/`)
- This repo on the SCC

## Steps

**1. Get the latest version of this repo**

```bash
cd /projectnb/vervmb/mfinn/proname-scc    # or wherever you cloned this repo
git pull
cd examples/ready-to-run
```

**2. Edit `config.sh`**

In an SCC OnDemand desktop, open the settings file by running:

```bash
geany config.sh
```

Then set these four lines (full paths). Example for the files already set up in the `vervmb` project
(tutorial data):

```bash
PROJECT=vervmb                                                # your SCC project name
SIF=/projectnb/vervmb/mfinn/proname.sif                       # the PRONAME container
RAWDATA=/projectnb/vervmb/mfinn/proname-scc/examples/RawData  # FOLDER of .fastq files, not a single file
WORKDIR=/projectnb/vervmb/mfinn/proname_run1                  # new folder for results (created for you)
```

The other settings (sequencing kit, primers, read length/quality filters) are set for PRONAME's tutorial
data. Change them to match your own data when you run it on real samples.

**3. Submit**

```bash
bash submit.sh
```

This checks your settings, then submits 4 jobs that run one after another.

**4. Check progress**

```bash
qstat -u $USER
```

In the `state` column, `qw` means waiting to start, `hqw` means waiting for the previous step, and `r`
means running. Once your jobs no longer appear, the pipeline is done.

## Results

Everything goes in your `WORKDIR`:

- `proname_<step>.o<jobID>`: the log for each step. Look here first if something fails.
- `taxa_barplot_assay1_blastn.qzv`: taxa barplot. Open it at [view.qiime2.org](https://view.qiime2.org).
- `taxonomy_assay1_blastn.tsv`: taxonomy table
- `phyloseq_object.rds`: for analysis in R (phyloseq)

On PRONAME's 10-sample tutorial dataset, a full run took about 3.5–5.5 hours, plus time waiting in the
queue. Refine was the longest step, at 3–4¾ hours.

These scripts were also tested end to end on a small subset (2 tutorial samples, first 20,000 reads of
each):

| Step | Cores | Run time |
|---|---|---|
| import | 16 | 54 s |
| filter | 16 | 28 s |
| refine | 28 | 6 min 13 s |
| taxonomy | 16 | 2 min 20 s |

## How it works

`ready-to-run/` is a one-command version of the per-step scripts in [`examples/`](../):

| File | What it does | Equivalent in `examples/` |
|---|---|---|
| `config.sh` | Your paths and settings, in one place | Values typed into each script |
| `submit.sh` | Checks `config.sh`, then submits the 4 steps as jobs that run one after another | Running `qsub` 4 times |
| `step.qsub` | The batch job used for every step: runs the step in the container, then checks it produced its output | `import.qsub`, `filter.qsub`, … |
| `steps/<step>.sh` | The PRONAME command for that step (runs inside the container) | `run_import.sh`, `run_filter.sh`, … |

To change a PRONAME option (e.g. `--deletefiles` for refine), edit `steps/<step>.sh`.
To change cores or run time, edit the `STEPS` table at the top of `submit.sh`.

Each step writes `.done_<step>` in `WORKDIR` when it finishes, and the next step only starts if that file
exists. This is needed because PRONAME reports success even when a step fails.
