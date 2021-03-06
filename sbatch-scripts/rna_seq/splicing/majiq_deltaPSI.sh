#!/bin/bash
display_usage(){
 printf "Script to automatically run majia deltaPSI and voila tsv for a set of files representing two different groups.\n
 Usage:
    -1nd argument must the majiq files that describes the input data for grp 1 (usually the controls)
    -2th argument must the majiq files that describes the input data for grp 2 
    -3rd argument must be the output directory 
    -4th argument must be the labels for the two experiments, split by ','.
    -5th argument must be the path of the splicegraph sql file to use by voila.
    -6th argument is optional. Refers to the min number of experiments per group (fraction or absolute number) passing the individual filters so that a LSV can be considered. Default: 0.5. Use '-' to skip argument and use default.
    -7th argument is optional. Refers to the filtering of LSVs based on a list of gene names and/or ids (one per line). Default: false. Values: [true|false|-].
    -8th argument is optional. Refers to use a default prior instead of computing using empirical data. Default:false. Values: [true|false|-].\n"
}

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ] || [ -z "$5" ]; then
    printf "Error. Please set the required parameters\n"
    display_usage
    exit 1
fi

#Data for each group
grp1=""
grp2=""
while read line; do
    grp1="$grp1 $line"
done < $1
while read line; do
    grp2="$grp2 $line"
done < $2

if [[ ! -d $(readlink -f "$3") ]]; then
    mkdir $(readlink -f "$3")
fi

#Outdir
OUT=$(readlink -f "$3")

#Groups names
IFS=','
read -r -a array <<< "$4"
label1=${array[0]}
label2=${array[1]}

#Splicegraph for voila
if [[ ! -f $(readlink -f "$5") ]]; then
    printf "Please set a valid splicegraph file in the 5th argument.\n"
    display_usage
    exit 1
else
    splicegraph=$(readlink -f "$5")
fi

CMD_DELTAPSI="majiq deltapsi --logger deltapsi_${label1}_${label2}.log --nproc \$SLURM_CPUS_PER_TASK --mem-profile -n $label1 $label2 -grp1 $grp1 -grp2 $grp2"
CMD_VOILA="voila tsv --logger voila_${label1}_${label2}.log --show-all --file-name voila_${label1}_${label2}.tsv"

#Min experiments
if [[ -z "$6" || "$6" == "-" ]]; then
    CMD_DELTAPSI+=" --min-experiments 0.5"
else
    CMD_DELTAPSI+=" --min-experiments $6"
fi

#LSV filter by geneID/name
if [[ -n "$7" && -f $(readlink -f "$7" ) ]]; then
    ids=$(readlink -f "$7")
    first_line=$(head -1 "$ids")
    if [[ "$first_line" =~ ^ENS* ]]; then
        CMD_VOILA="$CMD_VOILA --gene-ids-file $ids"
    else
        CMD_VOILA="$CMD_VOILA --gene-names-file $ids"
    fi
fi

#Use default prior
if [[ "$8" == "true" ]]; then
    CMD_DELTAPSI+="$CMD_DELTAPSI --default-prior"
fi

cat > deltapsi_majiq.sbatch <<EOL
#!/bin/bash
#SBATCH --job-name=majiq_deltapsi
#SBATCH --time=72:00:00
#SBATCH --mem=120G
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --output=%j_majiq_deltapsi.log
#SBATCH --image=mcfonsecalab/majiq:latest

scratch_out=/home/pedro.barbosa/scratch/rna_seq/majiq/\$SLURM_JOB_ID
mkdir \$scratch_out
cd \$scratch_out

printf "##DELTA PSI CMD##\n$CMD_DELTAPSI\n"
srun shifter $CMD_DELTAPSI -o \$PWD
cp $splicegraph . 

printf "##VOILA TSV CMD##\n$CMD_VOILA\n"
srun shifter $CMD_VOILA \$PWD
rm \$(basename $splicegraph)
mv * $OUT
cd ../ && rm -rf \$SLURM_JOB_ID
echo "Statistics for job \$SLURM_JOB_ID:"
sacct --format="JOBID,Start,End,Elapsed,CPUTime,AveDiskRead,AveDiskWrite,MaxRSS,MaxVMSize,exitcode,derivedexitcode" -j \$SLURM_JOB_ID
EOL

sbatch deltapsi_majiq.sbatch
