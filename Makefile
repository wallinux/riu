

configure: linux.configure pboot.configure

all: linux.all pboot.all

kernel: linux.kernel pboot.kernel

linux.%:
	@make $* -C linux

pboot.%:
	@make $* -C pboot

.PHONY: linux.* pboot.* all
