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
fontpath="./pdf/fonts"
pdftk_path="./pdf/pdftk"

path=`dirname $0`


if [ "$deploy" = "WH" ];then
        program_path="/export/data1/newcdts/src/pdf/wkhtmltopdf"

elif [ "$deploy" = "SZ" ];then
        program_path="/data/newcdts/src/pdf/wkhtmltopdf"

elif [ "$deploy" = "HK" ];then
        program_path="/export/newcdts/src/pdf/wkhtmltopdf"

fi

# install font
if [ ! -f ~/.fonts/wqy-microhei.ttc ]; then
	wqy=$fontpath/`ls -1 $fontpath | grep wqy-microhei | tail -n 1`
	echo installing wqy font...
	if [ ! -d ~/.fonts ]; then
		mkdir ~/.fonts
	fi
	tar zxf $wqy
	cp wqy-microhei/*.ttc  ~/.fonts
	rm -rf wqy-microhei
fi

# convert html to pdf
my_cover=$1
my_html=$2
language=$3
my_pdf=$4
my_pdf_ori1="$4_ori1.pdf"
my_pdf_ori2="$4_ori2.pdf"
backpage="background.pdf"
./pdf/wkhtmltopdf --page-size A4 -B 25mm -R 30mm -T 10mm  cover $my_cover toc --dump-default-toc-xsl  --javascript-delay 20000 --no-stop-slow-scripts  --print-media-type --footer-center '[page]/[toPage]' --header-spacing 5 $my_html --page-offset -1 --footer-center '[page]/[toPage]' $my_pdf_ori1 
$pdftk_path $my_pdf_ori1 output $my_pdf_ori2
$pdftk_path $my_pdf_ori2 background ./pdf/background.pdf output $my_pdf
rm -f $my_pdf_ori1 $my_pdf_ori2

