#!/bin/bash

# description: convert html to pdf
# author: Zhang Fangxian, zhangfx@genomics.cn
# created date: 20100504
# modified date: 20100510, 20100507
# latest modified: 20130326, mayubin@bgitechsolutions.com; 20130722, liangwenyin@bgitechsolutions.com
# 20140919,zhouyuwen@genomics.cn update [wkhtmltox] to version 0.12.1 
# 20141103,zhouyuwen@genomics.cn add [pdftk] version 2.02
# 20141204,zhouyuwen@genomics.cn change settings for wkhtmltopdf 
# 20141210,zhouyuwen@genomics.cn customize the table of contents, add language option

if [ $# -ne 4 ]
	then
	echo "usage: $0 cover htmlpage language(cn/en) pdf" >&2
	exit 1
fi

#################
# deploy location
deploy="SZ"
#################

program_path=""
fontpath="/ifs4/BC_PUB/biosoft/bin/arfhtml/src/pdf/fonts"
pdftk_path="/ifs4/BC_PUB/biosoft/bin/arfhtml/src/pdf/pdftk"

path=`dirname $0`


if [ "$deploy" = "WH" ];then
        program_path="/export/data1/newcdts/src/pdf/wkhtmltopdf"

elif [ "$deploy" = "SZ" ];then
        program_path="/ifs4/BC_PUB/biosoft/bin/arfhtml/src/pdf/wkhtmltopdf"

elif [ "$deploy" = "HK" ];then
        program_path="/export/newcdts/src/pdf/wkhtmltopdf"

fi

# install font
#if [ ! -f ~/.fonts/wqy-microhei.ttc ]; then
#	wqy=$fontpath/`ls -1 $fontpath | grep wqy-microhei | tail -n 1`
#	echo installing wqy font...
#	if [ ! -d ~/.fonts ]; then
#		mkdir ~/.fonts
#	fi
#	tar zxf $wqy
#	cp wqy-microhei/*.ttc  ~/.fonts
#	rm -rf wqy-microhei
#fi

# convert html to pdf
my_cover=$1
my_html=$2
language=$3
my_pdf=$4
my_pdf_ori1="$4_ori1.pdf"
my_pdf_ori2="$4_ori2.pdf"
$program_path $my_cover /ifs4/BC_PUB/biosoft/bin/arfhtml/src/pdf/cover_$language.pdf
$program_path --page-size A4 --quiet --disable-external-links --print-media-type -O Portrait -T 35mm -R 30mm -B 29mm -L 30mm --outline-depth 3   toc --xsl-style-sheet /ifs4/BC_PUB/biosoft/bin/arfhtml/src/pdf/toc_$language.xsl --print-media-type --footer-font-size 7 --footer-center '[page]/[toPage]' --header-spacing 5 $my_html  --page-offset 0 --footer-font-size 7 --footer-center '[page]/[toPage]' /ifs4/BC_PUB/biosoft/bin/arfhtml/src/pdf/pdf_temp.pdf
pdftk /ifs4/BC_PUB/biosoft/bin/arfhtml/src/pdf/pdf_temp.pdf background /ifs4/BC_PUB/biosoft/bin/arfhtml/src/pdf/bgf12.pdf output /ifs4/BC_PUB/biosoft/bin/arfhtml/src/pdf/pdf_temp1.pdf
pdftk /ifs4/BC_PUB/biosoft/bin/arfhtml/src/pdf/cover_$language.pdf /ifs4/BC_PUB/biosoft/bin/arfhtml/src/pdf/pdf_temp1.pdf /ifs4/BC_PUB/biosoft/bin/arfhtml/src/pdf/bottom.pdf cat output $my_pdf
#$pdftk_path $my_pdf_ori1 output $my_pdf_ori2
#$pdftk_path $my_pdf_ori2 background ./background-pdf.jpg output $my_pdf
#rm -f $my_pdf_ori1 $my_pdf_ori2


