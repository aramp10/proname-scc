#!/bin/bash
set -euo pipefail
cd /projectnb/your_project/your_workdir
proname_filter \
  --datatype simplex \
  --filtminlen 3500 \
  --filtmaxlen 5000 \
  --filtminqual 15 \
  --threads "$NSLOTS" \
  --inputpath /projectnb/your_project/RawData
