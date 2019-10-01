#!/bin/bash

# Small and easily extendible script to run in a cluster one or several 
# Quantum Chemistry calculations using software like Gaussian, Molcas, Molpro etc.
# The script requires the PBS scripts to be stored in a fix directory (~/bin for example) 

set -e

# Variable definitions and usage function

binDir=$HOME/bin
pbs_sub=$0
NP='1'
TIME='20'

function usage {
    echo "Usage: $pbs_sub -[g,ma,mo,h,c] -[all,infile] -[p] <n> -[t] <h>"
    echo "  -p <n>   run the job using n processors (dafaults to n=1)"
    echo "  -t <h>   run the job during h hours (dafaults to h=20)"
    echo "  -g	     run a gaussian calculation"
    echo "  -f	     run a generic Python calculation"
    echo "  -ma	     run a molcas calculation"
    echo "  -mo	     run a molpro calculation"
    echo "  -qc	     run a qchem calculation"
    echo "  -all     run calculation of a given type for all files in the directory"
    echo "  infile   run calculation only for infile"
    echo "  -h	     display this help"
    echo "  -c	     clean up out files"
}

if [[ $# -lt 1 ]]; then 
    usage
    exit 1
fi 

# Find out the number of processors and walltime

while getopts ':p:t:' flag; do
	case "${flag}" in
		p) NP="${OPTARG}" ;;
		t) TIME="${OPTARG}" ;;
		\?)
                echo "Invalid option: -$OPTARG" >/dev/null ;;
	esac
done

# Creates the scrip needed for the selected calculation 

function selector(){
    case $1 in
	"-g")
	    sed -e "s/projectname/$2/g" "$3"/gaussian_sub.sh  > ./run.sh
	    ;;
	"-f")
	    sed -e "s/procs/$NP/g" -e "s/horas/$TIME/g" "$3"/generic_sub.sh > ./run.sh
	    ;;
	"-ma")
	    sed -e "s/projectname/$2/g" "$3"/molcas_sub.sh  > ./run.sh
	    ;;
	"-mo")
	    sed -e "s/projectname/$2/g" "$3"/molpro_sub.sh  > ./run.sh
	    ;;
	"-qc")
	    sed -e "s/projectname/$2/g" "$3"/qchem_sub.sh  > ./run.sh
	    ;;
	"-h")
	    usage
	    exit 1
	    ;;
	"*")
	    echo -e "Not a valid option: ""$1"
	    exit 1
	    ;;	
    esac
}

# Run the calculation(s)
if [[ $1 = "-h" ]]; then
   selector "$1"
elif [[ $1 = "-f" ]]; then
    name=''
    selector "$1" "$name" "$binDir"
    qsub run.sh
elif [[ $2 = "-all" ]]; then
    if [[ $1 = "-g" || $1 = "-mo" ]]; then
	list=(./*.com)
    elif [[ $1 = "-ma" ]]; then		
	list=(./*.inp)
    else
	echo "Error in command line"
    fi
    
    for input in "${list[@]}"; do
	input=$(basename "$input")
	name=${input:0:${#input}-4}
	selector "$1" "$name" "$binDir"
	qsub run.sh
    done
    
elif [[ -f $2 ]]; then
    name=${2:0:${#2}-4}
    selector "$1" "$name" "$binDir"
    qsub run.sh
fi

# Clean up and watch the process running

rm -f run.sh

if [[ $1 = "-c" ]]; then
    read -r -p "This will erease all output files. Are you sure? [y/N] " response
    response=${response,,}    
    if [[ "$response" =~ ^(yes|y)$ ]]; then
	rm -f -- *.out* *.xml* *chk* *test* *.log* *.o* *.molden* *.err* *.status* *Orb* *mpd.hosts*
    fi
    exit 1
fi

watch -n 5 qstat -u "$USER"
