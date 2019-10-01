# PBS script for submitting a MOLPRO job
#PBS -N name_of_calc
#PBS -S /bin/bash
#PBS -j oe
#PBS -m ea
#PBS -l nodes=1:ppn=8
#PBS -l walltime=72:00:00
#PBS -q pmedium

###################################
#  Variables for MOLPRO           #
###################################
module load molpro

export Project=projectname
export CurrDir=$PBS_O_WORKDIR

export OMP_NUM_THREADS=1
export MKL_NUM_THREADS=1
NCPUS=$(wc -l < "$PBS_NODEFILE")
export NCPUS

cd "$CurrDir" || exit

echo "#--- Job started at $(date)"
echo "#--- Running in parallel with $NCPUS processors"
echo "#--- on nodes: "
cat "$PBS_NODEFILE"

molpro -n "$NCPUS" $Project.com

rm -rf "$TMPDIR"
echo "#--- Job ended at $(date)"

