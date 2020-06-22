# vim: noexpandtab shiftwidth=8 tabstop=8

JSON = $(wildcard *json)
SH = $(subst .json,.sh,${JSON})



.PHONY: test all

%.sh : %.json
	gadgetconfig --sh $< > $@

all: ${SH}

test:
	@echo JSON: ${JSON}
	@echo SH: ${SH}

