
ECHO	:= @echo -e
help:
	$(ECHO) "-- For linux and pboot projects"
	$(ECHO) " configure - Configure everything"
	$(ECHO) " all       - Build everything"
	$(ECHO) " kernel    - Build the kernel"

configure: linux.configure pboot.configure

all: linux.all pboot.all

kernel: linux.kernel pboot.kernel

linux.%:
	@make $* -C linux

pboot.%:
	@make $* -C pboot

.PHONY: linux.* pboot.* all
