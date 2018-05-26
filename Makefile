forth: forth.pas
	fpc -O3 -XsX -Sh forth.pas

install: forth
	cp forth /usr/bin/

clean:
	rm -f *.o forth
