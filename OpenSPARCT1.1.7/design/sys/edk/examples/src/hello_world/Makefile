
include ../Makefile.common


OBJS = hello_world.o

TARGET     = hello_world.mem.image
ELF_TARGET = hello_world

all: $(TARGET)

$(TARGET): $(ELF_TARGET)
	$(ROOT)/utils/elf_to_mem_image $(ELF_TARGET)

$(ELF_TARGET): $(OBJS)
	$(LD) -64 -e _start -dn -M $(ROOT)/mapfile -o $@ -z allextract -L $(LIBOS_PATH) -los $(OBJS) -L $(LIBC_PATH) -lc

clean:
	$(RM) $(OBJS)

clobber: clean
	$(RM) $(TARGET) $(ELF_TARGET)


install: $(TARGET)
	$(CP) $(TARGET) $(INSTALL_DIR)



