# Building the PRONAME Singularity container

Full command sequence used to build `proname.sif` on the SCC, following BU's
[Building From Docker or Singularity Hub](https://www.bu.edu/tech/support/research/software-and-programming/containers/building/)
guide. Replace `/projectnb/<your_project>/<your_dir>` with your own project directory.

```bash
# Log in to a build node (scc-i01 or scc-i02)
ssh scc-i01

# Make a temporary build directory in scratch space
mkdir $TMPDIR/$USER
SING_DIR=$TMPDIR/$USER

# PRONAME publishes amd64 and arm64 images (https://github.com/benn888/PRONAME).
# Check the architecture: x86_64 means use the amd64 image
uname -m

# Pull the Docker image and convert it to a .sif file
# (took about 15 minutes; produces a ~9.4 GB file)
singularity pull $SING_DIR/proname.sif docker://benn888/proname:v2.3.0-amd64

# Confirm the .sif file was created
ls -alht $SING_DIR

# Move the .sif to project storage and remove the temporary directory
mv $SING_DIR/proname.sif /projectnb/<your_project>/<your_dir>
rm -rf $SING_DIR

# Exit the build node
exit
```
