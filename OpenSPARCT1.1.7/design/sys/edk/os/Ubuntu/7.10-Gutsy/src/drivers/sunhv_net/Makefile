
obj-m := sunhv_net_module.o
sunhv_net_module-objs := sunhv_net.o sunhv_net_hcall.o

KDIR := /lib/modules/$(shell uname -r)/build

PWD  := $(shell pwd)

default:
	$(MAKE) -C $(KDIR) M=$(PWD) modules

clean:
	$(RM) -f Module.symvers sunhv_net_module.ko  sunhv_net_module.o sunhv_net_module.mod.c  sunhv_net_module.mod.o  sunhv_net.o sunhv_net_hcall.o
