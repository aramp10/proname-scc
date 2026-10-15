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

Run these in an SCC terminal (a login node such as `scc1` or an OnDemand desktop both work).

**1. Get the latest version of this repo**

```bash
cd /projectnb/vervmb/mfinn/proname-scc
git pull
cd examples/ready-to-run
```

**2. Edit `config.sh`**

The easiest way is with Geany, a text editor, in an SCC OnDemand interactive desktop:

```bash
geany config.sh
```

(In a plain terminal you can use `vim config.sh` instead.)

Fill in the four required lines with full paths:

| Setting | What to put |
|---|---|
| `PROJECT` | your SCC project name |
| `SIF` | full path to `proname.sif` |
| `RAWDATA` | full path to the **folder** of `.fastq` files (not a single file) |
| `WORKDIR` | a new folder for results, e.g. `/projectnb/<your_project>/<your_dir>/proname_run1` |

For example, with the files already set up in the `vervmb` project (tutorial data), the four lines are:

```bash
PROJECT=vervmb
SIF=/projectnb/vervmb/mfinn/proname.sif
RAWDATA=/projectnb/vervmb/mfinn/proname-scc/examples/RawData
WORKDIR=/projectnb/vervmb/mfinn/proname_run1
```

`WORKDIR` doesn't need to exist yet; `submit.sh` creates it.

The other settings (sequencing kit, primers, read length/quality filters) are set for PRONAME's tutorial
data. Change them to match your own data when you run it on real samples.

**3. Submit**

```bash
bash submit.sh
```

The script checks your settings first and stops with a message if something is wrong. If everything
is fine, it submits 4 jobs. Each job waits until the one before it finishes. If a step fails, the steps
after it stop without running.

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
- `sample_metadata.tsv`: if you didn't provide one (`METADATA` in `config.sh`), a placeholder is created
  with one row per sample

On PRONAME's 10-sample tutorial dataset, a full run took about 3.5–5.5 hours, plus time waiting in the
queue. Refine was the longest step, at 3–4¾ hours.

## Files in this folder

| File | Purpose |
|---|---|
| `config.sh` | your settings (the only file to edit) |
| `submit.sh` | checks settings and submits the jobs |
| `step.qsub` | batch job used for each step (called by `submit.sh`) |
| `steps/*.sh` | the `proname_*` command for each step (run inside the container) |
