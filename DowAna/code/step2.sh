#!/bin/bash

set -euxo pipefail

while getopts "O:F:" opt
do
	case $opt in
		O)
			outdir=$OPTARG
		;;
		F)
			sampleFile=$OPTARG
		;;
		*)
			echo "Check input"
			exit 1
		;;
	esac
done

mapfile -t list < <(cat ${sampleFile} | perl -alne 'if ($.>1){print $F[0]}')

for sample in ${list[@]};do
	if [ ! -f ${outdir}/code/Singlesample_${sample}.sh.sign ];then
		bash ${outdir}/code/Pipeline_plot_${sample}.sh && bash ${outdir}/code/Decontamination_${sample}.sh && bash ${outdir}/code/Singlesample_${sample}.sh &
		sleep 1
	fi
done

while true;do
	for sample in ${list[@]};do
		for script in GOKEGG SingleR Monocle CellChat;do
			if [ -f ${outdir}/code/Singlesample_${sample}.sh.sign ] && [ ! -f ${outdir}/code/${script}_${sample}.sh.sign ];then
				bash ${outdir}/code/${script}_${sample}.sh &
				sleep 1
			fi
		done
	done

	sampleNum=${#list[@]}
	echo $sampleNum
	signNum=`find ${outdir}/code -name "*sign" | wc -l`
	if [ $signNum -eq $((sampleNum*7)) ];then
		break
	else
		sleep 600
	fi
done

