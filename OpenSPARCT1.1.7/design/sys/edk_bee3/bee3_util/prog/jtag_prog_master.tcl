
connect mb mdm -cable type xilinx_platformusb port USB21 frequency 12000000 \
               -debugdevice devicenr 3 cpunr 1

dow       ../../ccx-firmware/executable.elf
dow -data ../../../edk/os/proms/2c4t_obp_prom.bin 0x8ff00000
dow -data ../../../edk/os/OpenSolaris/proto/ramdisk.snv-b77-nd.no-boot-time-network.gz 0x8af00000

run
disconnect 0

connect mb mdm -cable type xilinx_platformusb port USB21 frequency 12000000 \
               -debugdevice devicenr 4 cpunr 1

dow       ../../ccx-firmware/executable.elf
dow -data ../../../edk/os/proms/2c4t_obp_prom.bin 0x8ff00000
dow -data ../../../edk/os/OpenSolaris/proto/ramdisk.snv-b77-nd.no-boot-time-network.gz 0x8af00000

run
disconnect 0

