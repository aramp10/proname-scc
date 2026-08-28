#!/bin/bash
set -euo pipefail
cd /projectnb/your_project/your_workdir
proname_refine \
  --clusterid 0.90 \
  --clusterthreads "$NSLOTS" \
  --inputpath /projectnb/your_project/RawData \
  --polisher medaka \
  --polisherthreads "$NSLOTS" \
  --polishermodel r1041_e82_400bps_sup_v5.2.0 \
  --chimeradb /opt/db/rEGEN-B/rEGEN-B_sequences.fasta \
  --qiime2import yes \
  --deletefiles yes
# --deletefiles yes clears large intermediate files (e.g. the filter-stage
# HQ/ input) as they're consumed -- tested and confirmed working (freed an
# 11GB working directory down to 78MB). Leave this off only if you're
# deliberately comparing multiple runs side by side and need to keep each
# run's intermediate files intact for inspection.
