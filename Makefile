



all: pigadget.zip

pigadget.zip:
	zip -r $@ ./etc ./usr

clean:
	-rm -f *.zip
