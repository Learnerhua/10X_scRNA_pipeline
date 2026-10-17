#!/bin/bash
rm pdf2.pdf
rm PDF.pdf
rm report.pdf
./wkhtmltopdf --page-size A4 -B 29mm -R 30mm -T 35mm -L 30mm toc --xsl-style-sheet toc_cn.xsl --print-media-type --footer-font-size 7  --footer-center '[page]/[toPage]' --header-spacing 5 /home/P_bc_rd/BGI-RD-DEMO-PROJECT-22/report/src/page/PDF_cn.html --page-offset 0 --footer-font-size 7  --footer-center '[page]/[toPage]' PDF.pdf
pdftk PDF.pdf background ./bgf12.pdf output pdf2.pdf
pdftk cover.pdf pdf2.pdf bottom.pdf cat output report.pdf


