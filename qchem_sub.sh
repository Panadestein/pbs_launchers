#PBS -N name_of_calc
#PBS -S /bin/bash
#PBS -M ramon
#PBS -j oe
#PBS -m ea
#PBS -l pmem=25Gb
#PBS -l nodes=u-0-3:ppn=8
#PBS -q pmedium

export Project=projectname
export CurrDir=$PBS_O_WORKDIR
export QCSCRATCH=$TMPDIR

module load qchem

NCPUS=$(wc -l < "$PBS_NODEFILE")
export NCPUS

cd "$CurrDir" || exit

echo "#--- Job started at $(date)"
echo "#--- Running with $NCPUS processors"
echo "#--- on nodes: "
cat "$PBS_NODEFILE"

qchem -pbs -nt "$NCPUS" $Project.inp $Project.out


echo "#--- Job ended at $(date)"
