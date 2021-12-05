html: src/*.xml html.xsl Makefile
	xsltproc --xinclude --stringparam html.stylesheet "../css/bootstrap.min.css ../css/bootstrap-responsive.min.css ../css/styled.min.css ../css/highlight.css" --path "src css" --output build/ html.xsl prc.xml
#	xsltproc --xinclude --stringparam html.stylesheet "../css/one.min.css" --path "src css" --output build/ html.xsl c.xml
	perl -pi -e "s/\.pdf\"/\.png\"/g;" src/*.xml
#	find . -name "*.html" | xargs perl -pi -e "s/<html>/<!DOCTYPE html>/g;"
#	find . -name "*.html" | xargs perl -pi -e "s/<meta/<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\"><meta/g;"
	cp -r images build/
	./domp.py
	cp -r build/* /var/www/time-travel/


pdf: src/*.xml dblatex.xsl Makefile 
	#rm -rf pdf
	cp -r src pdf	
	dblatex -bxetex -T db2latex -p dblatex.xsl -P preface.tocdepth="1" -t tex src/prc.xml -o pdf/prc.tex
	perl -pi -e "s/\.png/\.pdf/g;" pdf/prc.tex
	./lstlisting_to_minted.sh
	cd pdf && xelatex -shell-escape prc.tex #&& xelatex -shell-escape c.tex
	cd pdf && makeindex c.tex
	cd pdf && xelatex -shell-escape prc.tex #&& xelatex -shell-escape c.tex

latex:
	dblatex -bxetex -T db2latex -p dblatex.xsl -P preface.tocdepth="1" -t tex src/prc.xml
	cd src && perl -pi -e "s/\.png/\.pdf/g;" prc.tex

fop:
#	cd src && xmllint --xinclude c.xml>resolvedc.xml
	xsltproc --xinclude --output src/prc.fo fop.xsl src/prc.xml
#	perl -pi -e "s/png/pdf/g;" src/c.fo
#	./fop.py
#	perl -pi -e "s/<html><body>//g;" src/c.fo
#	perl -pi -e "s/<\/body><\/html>//g;" src/c.fo
	cd src && fop prc.fo prc.pdf && fop prc.fo prc.pdf

epub: src/*.xml epub.xsl Makefile
	xsltproc --xinclude --stringparam html.stylesheet "../css/one.min.css" --path "src css" epub.xsl prc.xml
	cp -r images/*.png OEBPS
	./epub.py
	zip -r c.epub mimetype css META-INF/ OEBPS/
