#!/bin/bash
# Runs inside the container. Usage: bash import.sh /path/to/config.sh
set -euo pipefail
source "$1"
cd "$WORKDIR"
proname_import \
  --inputpath "$RAWDATA" \
  --threads "$NSLOTS" \
  --duplex yes \
  --trimadapters yes \
  --sequencingkit "$SEQUENCING_KIT" \
  --trimprimers yes \
  --fwdprimer "$FWD_PRIMER" \
  --revprimer "$REV_PRIMER"
