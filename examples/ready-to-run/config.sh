# PRONAME pipeline settings -- the only file you need to edit.
# Use full paths (starting with /projectnb/...).

# --- Required ---
PROJECT=your_project                              # your SCC project name
SIF=/projectnb/your_project/proname.sif           # the PRONAME container
RAWDATA=/projectnb/your_project/RawData           # FOLDER of raw .fastq files (not a single file)
WORKDIR=/projectnb/your_project/proname_run1      # where results go (created if missing; must not be RAWDATA)

# --- Optional ---
# Sample metadata .tsv for step 4. Leave empty to auto-create a placeholder
# (one row per .fastq file in RAWDATA, condition = NA).
METADATA=

# --- Step 1: import (values below match PRONAME's tutorial data) ---
SEQUENCING_KIT=SQK-LSK114
FWD_PRIMER=AGRGTTYGATYMTGGCTCAG
REV_PRIMER=CGACATCGAGGTGCCAAAC

# --- Step 2: filter ---
DATATYPE=simplex      # simplex or duplex -- must match your data (check step 1 output)
FILT_MIN_LEN=3500
FILT_MAX_LEN=5000
FILT_MIN_QUAL=15
