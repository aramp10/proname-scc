#!/bin/bash
# Runs inside the container. Usage: bash refine.sh /path/to/config.sh
set -euo pipefail
source "$1"
cd "$WORKDIR"
proname_refine \
  --clusterid 0.90 \
  --clusterthreads "$NSLOTS" \
  --inputpath "$RAWDATA" \
  --polisher medaka \
  --polisherthreads "$NSLOTS" \
  --polishermodel r1041_e82_400bps_sup_v5.2.0 \
  --chimeradb /opt/db/rEGEN-B/rEGEN-B_sequences.fasta \
  --qiime2import yes \
  --deletefiles yes
