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
  --qiime2import yes
# --deletefiles yes: not exercised in our test runs (we kept intermediate
# files to compare independent 16-/28-core runs side by side), but worth
# adding here once you're past comparison runs, since it clears large
# intermediate files as they're consumed.
