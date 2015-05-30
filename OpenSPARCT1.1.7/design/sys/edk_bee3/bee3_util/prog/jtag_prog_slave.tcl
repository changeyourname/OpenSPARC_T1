
connect mb mdm -cable type xilinx_platformusb port USB21 frequency 12000000 \
               -debugdevice devicenr 2 cpunr 1

dow       ../../ccx-firmware-slave/executable.elf
dow -data ../../../edk/os/proms/2c4t_obp_prom.bin 0x8ff00000

run
disconnect 0

connect mb mdm -cable type xilinx_platformusb port USB21 frequency 12000000 \
               -debugdevice devicenr 5 cpunr 1

dow       ../../ccx-firmware-slave/executable.elf
dow -data ../../../edk/os/proms/2c4t_obp_prom.bin 0x8ff00000

run
disconnect 0

