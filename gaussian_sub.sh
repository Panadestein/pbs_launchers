# PBS script for submitting a Gaussian job
#PBS -N name_of_calc
#PBS -S /bin/bash
#PBS -j oe
#PBS -l nodes=1:gaussian:ppn=8
#PBS -l walltime=72:00:00

###################################
#  Variables for Gaussian        #
###################################
ulimit -s unlimited

export Project=projectname
export CurrDir=$PBS_O_WORKDIR
export GAUSS_SCRDIR=$TMPDIR

############################
#
cd "$CurrDir" || exit

echo "#--- Job started at $(date)"
echo "#--- Running with $NCPUS processors"
echo "#--- on nodes: "
cat "$PBS_NODEFILE"

# copy all necessary files (input, source, programs etc.) to the execution
# host

pwd
cp "$Project".com "$TMPDIR"

if [ -f $Project.chk.gz ]; then
   cp "$Project".chk.gz "$TMPDIR"
   gzip -d "$TMPDIR"/"$Project".chk.gz
fi

cd "$TMPDIR" || exit

# Start calculation
echo "Gaussian calculation"
g16 < "$Project".com  > "$CurrDir"/"$Project".out 2>&1

# copy all output files from the execution host back to $CurrDir

if [ -f $Project.chk ]; then
   gzip $Project.chk
   mv -f "$Project".chk.gz "$CurrDir"
fi

if [ -f $Project.wfn ]; then
   mv -f "$Project".wfn "$CurrDir"
fi

if [ -f $Project.wfx ]; then
   mv -f "$Project".wfx "$CurrDir"
fi

# remove the temporary directory if $CurrDir is accessible
cd "$CurrDir" && rm -rf "$TMPDIR"  

echo "#--- Job ended at $(date)"

