
obj-m := sunhv_disk_module.o
sunhv_disk_module-objs := sunhv_disk.o sunhv_disk_hcall.o

KDIR := /lib/modules/$(shell uname -r)/build

PWD  := $(shell pwd)

default:
	$(MAKE) -C $(KDIR) M=$(PWD) modules

clean:
	$(RM) -f Module.symvers sunhv_disk_module.ko  sunhv_disk_module.o sunhv_disk_module.mod.c  sunhv_disk_module.mod.o  sunhv_disk.o sunhv_disk_hcall.o
