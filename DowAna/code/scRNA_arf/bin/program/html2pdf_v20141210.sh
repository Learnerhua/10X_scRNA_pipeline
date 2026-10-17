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

path=`dirname $0`

html2pdf_path="$path/html/wkhtmltox-0.12.1/"
fontpath="$path/html/fonts"
pdftk_path="$path/html/pdftk"


# install font
if [ ! -f ~/.fonts/wqy-microhei.ttc ]; then
	wqy=$fontpath/`ls -1 $fontpath | grep wqy-microhei | tail -n 1`
	echo installing wqy font...
	if [ ! -d ~/.fonts ]; then
		mkdir ~/.fonts
	fi
	# cp wqy-microhei/*.ttc  ~/.fonts
	# rm -rf wqy-microhei
	cp fonts/*.ttc  ~/.fonts
fi

# convert html to pdf
my_cover=$1
my_html=$2
language=$3
my_pdf=$4
my_pdf_ori1="$4_ori1.pdf"
my_pdf_ori2="$4_ori2.pdf"

$html2pdf_path/wkhtmltopdf --page-size A4 --quiet --disable-external-links --print-media-type -O Portrait -T 20mm -R 10mm -B 30mm -L 10mm --outline-depth 3 cover $my_cover toc --xsl-style-sheet $path/html/toc_$language.xsl --footer-center '[page]/[toPage]' --header-spacing 5 $my_html --page-offset -1 --footer-center '[page]/[toPage]' $my_pdf_ori1
$pdftk_path $my_pdf_ori1 output $my_pdf_ori2
$pdftk_path $my_pdf_ori2 background $path/html/background.pdf output $my_pdf
rm -f $my_pdf_ori1 $my_pdf_ori2

