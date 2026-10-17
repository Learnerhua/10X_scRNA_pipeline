## wkhtmltopdf需要依赖中文字体，否则生成的pdf文件中无法正常显示中文。
# fontpath=`pwd`/fonts
fontpath=/oldhome/ouyjh/Workspace/scRNA_cellranger_pipeline/DowAna/code/scRNA_arf/bin/fonts
# install font
if [ ! -f ~/.fonts/wqy-microhei.ttc ]; then
    wqy=$fontpath/`ls -1 $fontpath | grep wqy-microhei | tail -n 1`
    echo installing wqy font...
    if [ ! -d ~/.fonts ]; then
        mkdir ~/.fonts
    fi
    cp $fontpath/*.ttc  ~/.fonts
fi 

/oldhome/ouyjh/Workspace/scRNA_cellranger_pipeline/DowAna/code/scRNA_arf/bin/program/wkhtmltopdf --page-size A4 --quiet --disable-external-links --print-media-type -O Portrait -T 20mm -R 10mm -B 10mm -L 10mm --outline-depth 3 cover ./cover_cn.html toc --xsl-style-sheet /oldhome/ouyjh/Workspace/scRNA_cellranger_pipeline/DowAna/code/scRNA_arf/bin/program/toc_cn.xsl --footer-center [page]/[toPage] --header-spacing 5 ./report/src/page/PDF_cn.html --page-offset -1 --footer-center [page]/[toPage] report_cn.pdf.tmp1
/oldhome/ouyjh/Workspace/scRNA_cellranger_pipeline/DowAna/code/scRNA_arf/bin/program/wkhtmltopdf --page-size A4 --quiet --disable-external-links --print-media-type -O Portrait -T 20mm -R 10mm -B 10mm -L 10mm --outline-depth 3 cover ./cover_en.html toc --xsl-style-sheet /oldhome/ouyjh/Workspace/scRNA_cellranger_pipeline/DowAna/code/scRNA_arf/bin/program/toc_en.xsl --footer-center [page]/[toPage] --header-spacing 5 ./report/src/page/PDF.html  --page-offset -1 --footer-center [page]/[toPage] report_en.pdf.tmp1
/oldhome/ouyjh/Workspace/scRNA_cellranger_pipeline/DowAna/code/scRNA_arf/bin/program/pdftk report_cn.pdf.tmp1 output report_cn.pdf.tmp2
/oldhome/ouyjh/Workspace/scRNA_cellranger_pipeline/DowAna/code/scRNA_arf/bin/program/pdftk report_en.pdf.tmp1 output report_en.pdf.tmp2
/oldhome/ouyjh/Workspace/scRNA_cellranger_pipeline/DowAna/code/scRNA_arf/bin/program/pdftk report_cn.pdf.tmp2 background /oldhome/ouyjh/Workspace/scRNA_cellranger_pipeline/DowAna/code/scRNA_arf/pdf/background_BGI_Research.pdf output ./report/report_cn.pdf
/oldhome/ouyjh/Workspace/scRNA_cellranger_pipeline/DowAna/code/scRNA_arf/bin/program/pdftk report_en.pdf.tmp2  background /oldhome/ouyjh/Workspace/scRNA_cellranger_pipeline/DowAna/code/scRNA_arf/pdf/background_BGI_Research.pdf output ./report/report_en.pdf
rm -f ./*tmp1 ./*tmp2


