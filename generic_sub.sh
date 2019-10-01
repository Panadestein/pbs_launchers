#!/bin/sh
#PBS -N name_of_calc
#PBS -S /bin/bash
#PBS -j oe
#PBS -l nodes=1:ppn=procs
#PBS -l walltime=horas:00:00

# Environment variable setup

export I_MPI_FABRICS="shm:tcp"
export MKL_NUM_THREADS=1
export OMP_NUM_THREADS=1
export CurrDir=$PBS_O_WORKDIR

LANG=C
LC_ALL=C
export LANG LC_ALL

NPROCS=$(wc -l < "$PBS_NODEFILE")
NHOSTS=$(uniq "$PBS_NODEFILE" | wc -l)
export NPROCS
export NHOSTS

uniq "$PBS_NODEFILE" > "$CurrDir"/mpd.hosts
echo "#--- Calculation running with $NPROCS CPUs:"
cat "$PBS_NODEFILE"

# Here the real job starts

echo "#--- Job started at $(date)"

# create the temporary directory and make sure the input directory is accessible

cd "$CurrDir" || exit 

# copy all necessary files (input, source, programs etc.) to the execution host

rsync -avP -- * "$TMPDIR"/

# Run calculation (on a hypotetical script "my_script")

cd "$TMPDIR" || exit
echo "Python calculation"
python my_script.py

# copy all output files from the execution host back to $CurrDir

echo "Backing up"
rsync -avP -- * "$CurrDir"/

# remove the temporary directory if $CurrDir is accessible

cd "$CurrDir" && rm -rf "$TMPDIR"
echo "#--- Job ended at $(date)"

