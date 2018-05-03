forth:
	fpc -O3 -XsX forth.pas
	
	
install:
	cp forth /usr/bin/

clean:
	rm -f *.o forth
