#!/bin/bash
# Runs inside the container. Usage: bash filter.sh /path/to/config.sh
set -euo pipefail
source "$1"
cd "$WORKDIR"
proname_filter \
  --datatype "$DATATYPE" \
  --filtminlen "$FILT_MIN_LEN" \
  --filtmaxlen "$FILT_MAX_LEN" \
  --filtminqual "$FILT_MIN_QUAL" \
  --threads "$NSLOTS" \
  --inputpath "$RAWDATA"
