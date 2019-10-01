# PBS script for submitting a MOLCAS job
#PBS -N name_of_calc
#PBS -S /bin/bash
#PBS -j oe
#PBS -m ea
#PBS -l pmem=1024M
#PBS -l nodes=1:intel:ppn=4
#PBS -l walltime=4:00:00
#PBS -q short

###################################
#  Variables for MOLCAS           #
###################################
export NPROCS=$PBS_NP
export MKL_NUM_THREADS=$PBS_NUM_PPN
export OMP_NUM_THREADS=$PBS_NUM_PPN
export MOLCAS_MEM=1024
export MOLCAS_DISK=2048
export MOLCAS_WORKDIR=$TMPDIR
export MOLCAS_MOLDEN=ON

export HomeDir=$PBS_O_WORKDIR
export CurrDir=$HomeDir
export Project=projectname

module load intel
module load molcas

cd "$CurrDir" || exit

echo "#--- Job started at $(date) in SMP with $MKL_NUM_THREADS CPUs:"
echo "#--- on nodes: "
cat "$PBS_NODEFILE"

molcas $Project.inp -f

rm -rf "$TMPDIR"
echo "#--- Job ended at $(date)"
