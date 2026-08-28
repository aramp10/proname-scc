#!/bin/bash
set -euo pipefail
cd /projectnb/your_project/your_workdir
proname_import \
  --inputpath /projectnb/your_project/RawData \
  --threads "$NSLOTS" \
  --duplex yes \
  --trimadapters yes \
  --sequencingkit SQK-LSK114 \
  --trimprimers yes \
  --fwdprimer AGRGTTYGATYMTGGCTCAG \
  --revprimer CGACATCGAGGTGCCAAAC
