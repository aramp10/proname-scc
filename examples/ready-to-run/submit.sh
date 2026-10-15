#!/bin/bash
# Submit the PRONAME pipeline as batch jobs that run one after another.
#   bash submit.sh            # all 4 steps: import -> filter -> refine -> taxonomy
#   bash submit.sh refine     # start from a later step (earlier steps must have finished)
set -euo pipefail

PIPELINE_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$PIPELINE_DIR/config.sh"

# step  cores  max run time
STEPS=(
  "import    16  12:00:00"
  "filter    16  12:00:00"
  "refine    28  120:00:00"
  "taxonomy  16  12:00:00"
)
START=${1:-import}

die() { echo "ERROR: $*" >&2; exit 1; }

# --- Check settings ---
[[ "$PROJECT" != your_project ]] || die "edit config.sh first (PROJECT is still 'your_project')"
[ -f "$SIF" ]     || die "container not found: SIF=$SIF"
[ -d "$RAWDATA" ] || die "RAWDATA must be a folder of .fastq files: RAWDATA=$RAWDATA"
ls "$RAWDATA"/*.fastq >/dev/null 2>&1 || die "no .fastq files in RAWDATA=$RAWDATA"
[ "$(realpath -m "$WORKDIR")" != "$(realpath "$RAWDATA")" ] || die "WORKDIR must be a different folder from RAWDATA"
printf '%s\n' "${STEPS[@]}" | awk '{print $1}' | grep -qx "$START" || die "unknown step '$START' (use import, filter, refine, or taxonomy)"
[ -z "$METADATA" ] || [ -f "$METADATA" ] || die "METADATA file not found: $METADATA"

mkdir -p "$WORKDIR"

# --- Sample metadata for step 4 ---
if [ -n "$METADATA" ]; then
  cp "$METADATA" "$WORKDIR/sample_metadata.tsv"
elif [ ! -f "$WORKDIR/sample_metadata.tsv" ]; then
  {
    printf 'sample-id\tcondition\n#q2:types\tcategorical\n'
    for f in "$RAWDATA"/*.fastq; do printf '%s\tNA\n' "$(basename "$f" .fastq)"; done
  } > "$WORKDIR/sample_metadata.tsv"
  echo "Created placeholder $WORKDIR/sample_metadata.tsv"
fi

# --- Submit jobs, each waiting for the one before ---
started=no; prev=""; hold=()
for s in "${STEPS[@]}"; do
  read -r step cores rt <<< "$s"
  [ "$step" = "$START" ] && started=yes
  if [ "$started" = no ]; then prev=$step; continue; fi
  rm -f "$WORKDIR/.done_$step"
  jid=$(qsub -terse -P "$PROJECT" -N "proname_$step" -pe omp "$cores" -l h_rt="$rt" \
        -wd "$WORKDIR" -v PIPELINE_DIR="$PIPELINE_DIR",STEP="$step",PREV_STEP="$prev" \
        "${hold[@]}" "$PIPELINE_DIR/step.qsub")
  echo "Submitted $step: job $jid"
  hold=(-hold_jid "$jid"); prev=$step
done

echo
echo "Results and logs (proname_<step>.o<jobID>) go to: $WORKDIR"
echo "Check job status with: qstat -u $USER"
