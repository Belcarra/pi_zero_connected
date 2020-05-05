



all: pigadget.zip

pigadget.zip:
	cd pigadget; zip -r ../$@ ./etc ./usr

clean:
	-rm -f *.zip
