###############################################################################
#
# Copyright (c) 2007 Xilinx, Inc. All Rights Reserved.
# You may copy and modify these files for your own internal use solely with
# Xilinx programmable logic devices and  Xilinx EDK system or create IP
# modules solely for Xilinx programmable logic devices and Xilinx EDK system.
# No rights are granted to distribute any files unless they are distributed in
# Xilinx programmable logic devices.
#
# MODIFICATION HISTORY:
#
# 11/29/07 rpm Define INTR ids for FIFO and DMA in xparameters.h even if they
#              are not used.  Helps RTOS systems that need them defined. Also
#              commented out some Info messages.
# 02/08/08 rpm Fix robustness for interrupt connected to two sinks or not
#              connected to interrupt controller
# 04/08/08 rpm Fix problem with multiply defined canonicals when two temac
#              devices exist (each with one or both channels enabled)
#
###############################################################################
#uses "xillib.tcl"

set periph_config_params 0
set periph_ninstances    0

proc init_periph_config_struct { deviceid } {
    global periph_config_params
    set periph_config_params($deviceid) [list]
}

proc add_field_to_periph_config_struct { deviceid fieldval } {
    global periph_config_params
    lappend periph_config_params($deviceid) $fieldval
}

proc get_periph_config_struct_fields { deviceid } {
    global periph_config_params
    return $periph_config_params($deviceid)
}

# ------------------------------------------------------------------
# Given an LL_TEMAC peripheral, generate all the stuff required in
# the system include file.
#
# This consists of two logical things,
# 1. Know that each LL_TEMAC has two possible channels and split the
#    params out into two separate sets, such that each looks like its
#    own device.
#
# 2. Given each TEMAC channel which is an initiator on a
#    local link interface, traverse the local link to the target side,
#    figure out the peripheral type that is connected and
#    put in appropriate defines. The peripheral on the other side
#    can be hard DMA, soft DMA or LL_FIFO.
#
# ------------------------------------------------------------------
proc xdefine_lltemac_include_file {drv_handle file_name drv_string} {
    global periph_ninstances

    # Open include file
    set file_handle [xopen_include_file $file_name]

    # Get all peripherals connected to this driver
    set periphs [xget_sw_iplist_for_driver $drv_handle]

    # ----------------------------------------------
    # PART 1 - LL_TEMAC related parameters
    # ----------------------------------------------

    # Handle NUM_INSTANCES
    set periph_ninstances 0
    puts $file_handle "/* Definitions for driver [string toupper [xget_sw_name $drv_handle]] */"
    foreach periph $periphs {
        set value [xget_param_value $periph "C_TEMAC1_ENABLED"]
        if { $value != 0 } {
            init_periph_config_struct $periph_ninstances
            incr periph_ninstances 1

            init_periph_config_struct $periph_ninstances
            incr periph_ninstances 1
        } else {
            init_periph_config_struct $periph_ninstances
            incr periph_ninstances 1
        }
    }
    puts $file_handle "\#define [xget_dname $drv_string NUM_INSTANCES] $periph_ninstances"


    # Now print all useful parameters for all peripherals
    set device_id 0
    foreach periph $periphs {
        puts $file_handle ""
        for {set chan 0} {$chan < 2} {incr chan} {

            set value [xget_param_value $periph [format "C_TEMAC%d_ENABLED" $chan]]
            if { $value != "" && $value == 0  } {
                break
            }

            # Create instance-specific definitions
            xdefine_temac_params_instance $file_handle $periph $device_id $chan

            # Create canonical definitions
            xdefine_temac_params_canonical $file_handle $periph $device_id $chan

            # Interrupt ID (canonical)
            xdefine_temac_interrupt $file_handle $periph $device_id $chan

            incr device_id
            puts $file_handle "\n"
        }
    }


    # ----------------------------------------------
    # PART 2 -- LL Connection related parameters
    # ----------------------------------------------
    xdefine_ll_target_params $periphs $file_handle

    puts $file_handle "\n/******************************************************************/\n"
    close $file_handle
}

# ------------------------------------------------------------------
# This procedure creates XPARs that are instance-specific for the
# hardware design parameters
# ------------------------------------------------------------------
proc xdefine_temac_params_instance {file_handle periph device_id chan} {

    puts $file_handle "/* Definitions for peripheral [string toupper [xget_hw_name $periph]] Channel $chan */"

    # Handle device ID
    set formatted_name  [format "CHAN_%d_DEVICE_ID" $chan]
    puts $file_handle "\#define [xget_name $periph $formatted_name] $device_id"

    # Handle BASEADDR specially
    set formatted_name  [format "CHAN_%d_BASEADDR" $chan]
    if { $chan == 0 }  {
        puts $file_handle "\#define [xget_name $periph $formatted_name] [xget_param_value $periph C_BASEADDR]"
    } else {
        puts $file_handle "\#define [xget_name $periph $formatted_name] 0x[format %X [expr [xget_param_value $periph C_BASEADDR] + [expr $chan * 0x40]]]"
    }

    set formatted_name  [format "CHAN_%d_TXCSUM"   $chan]
    set formatted_value [format "C_TEMAC%d_TXCSUM" $chan]
    puts $file_handle "\#define [xget_name $periph $formatted_name] [xget_param_value $periph $formatted_value]"

    set formatted_name  [format "CHAN_%d_RXCSUM"   $chan]
    set formatted_value [format "C_TEMAC%d_RXCSUM" $chan]
    puts $file_handle "\#define [xget_name $periph $formatted_name] [xget_param_value $periph $formatted_value]"

    set formatted_name  [format "CHAN_%d_PHY_TYPE"   $chan]
    puts $file_handle "\#define [xget_name $periph $formatted_name] [xget_param_value $periph C_PHY_TYPE]"
}

# ------------------------------------------------------------------
# This procedure creates XPARs that are canonical/normalized for the
# hardware design parameters.  It also adds these to the Config table.
# ------------------------------------------------------------------
proc xdefine_temac_params_canonical {file_handle periph device_id chan} {

    puts $file_handle "\n/* Canonical definitions for peripheral [string toupper [xget_hw_name $periph]] Channel $chan */"

    set canonical_tag [string toupper [format "XPAR_LLTEMAC_%d" $device_id]]

    # Handle device ID
    set canonical_name  [format "%s_DEVICE_ID" $canonical_tag]
    puts $file_handle "\#define $canonical_name $device_id"
    add_field_to_periph_config_struct $device_id $canonical_name

    # Handle BASEADDR specially
    set canonical_name  [format "%s_BASEADDR" $canonical_tag]
    if { $chan == 0 }  {
        puts $file_handle "\#define $canonical_name [xget_param_value $periph C_BASEADDR]"
    } else {
        puts $file_handle "\#define $canonical_name 0x[format %X [expr [xget_param_value $periph C_BASEADDR] + [expr $chan * 0x40]]]"
    }
    add_field_to_periph_config_struct $device_id $canonical_name

    set canonical_name  [format "%s_TXCSUM" $canonical_tag]
    set formatted_value [format "C_TEMAC%d_TXCSUM" $chan]
    puts $file_handle "\#define $canonical_name [xget_param_value $periph $formatted_value]"
    add_field_to_periph_config_struct $device_id $canonical_name

    set canonical_name  [format "%s_RXCSUM" $canonical_tag]
    set formatted_value [format "C_TEMAC%d_RXCSUM" $chan]
    puts $file_handle "\#define $canonical_name [xget_param_value $periph $formatted_value]"
    add_field_to_periph_config_struct $device_id $canonical_name

    set canonical_name  [format "%s_PHY_TYPE" $canonical_tag]
    puts $file_handle "\#define $canonical_name [xget_param_value $periph C_PHY_TYPE]"
    add_field_to_periph_config_struct $device_id $canonical_name
}

# ------------------------------------------------------------------
# This procedure re-forms the TEMAC interrupt ID XPAR constant and adds it to
# the driver config table. This Tcl needs to be carefile of the order of the
# config table entries
# ------------------------------------------------------------------
proc xdefine_temac_interrupt {file_handle periph device_id chan} {

    set mhs_handle [xget_hw_parent_handle $periph]
    set periph_name [string toupper [xget_hw_name $periph]]

    # set up the canonical constant name
    set canonical_name [format "XPAR_LLTEMAC_%d_INTR" $device_id]

    #
    # In order to reform the XPAR for the interrupt ID, we need to hunt
    # for the interrupt ID based on the interrupt signal name of the TEMAC
    #

    # First get the interrupt ports on this peripheral
    set interrupt_port [xget_port_by_subtype $periph "SIGIS" "INTERRUPT" "DIR" "O"]

    # For each interrupt port, find out the ordinal of the interrupt line
    # as connected to an interrupt controller
    set addentry 0
    foreach intr_port $interrupt_port {
        set interrupt_signal_name [xget_hw_name $intr_port]
        set interrupt_signal [xget_hw_value $intr_port]
        set intc_prt [xget_hw_connected_ports_handle $mhs_handle $interrupt_signal "sink"]

        # Make sure the interrupt signal was connected in this design. We assume
        # at least one is. (could be a bug if user just wants polled mode)
        if { $intc_prt != "" } {

            set found_intc ""
            foreach intr_sink $intc_prt {

                set phandle [xget_hw_parent_handle $intr_sink]
                set pname [string toupper [xget_hw_name $phandle]]

                set special [xget_hw_option_value $phandle "SPECIAL"]
                if {[string compare -nocase $special "interrupt_controller"] == 0} {

                    # if connected to an interrupt controller, break and use this handle
                    # TODO: could be a bug if connected to more than one intc (?)
                    set found_intc $intr_sink
                    break
                }
            }

            if {$found_intc == ""} {
                # not connected to an interrupt controller, so punt
                # puts "Info: TEMAC interrupt not connected to intc\n"
                break
            }

            set intc_periph [xget_hw_parent_handle $found_intc]
            set intc_name [string toupper [xget_hw_name $intc_periph]]
        } else {
            # puts "Info: $periph_name interrupt signal $interrupt_signal_name not connected"
            continue
        }

        # A bit of ugliness here. The only way to figure the ordinal is to
        # iterate over the interrupt lines again and see if a particular signal
        # matches the original interrupt signal we were tracking.

        set intc_src_ports [xget_interrupt_sources $intc_periph]

        set i 0
        foreach intc_src_port $intc_src_ports {

            if {[llength $intc_src_port] == 0} {
                incr i
                continue
            }

            set intc_src_port_value [xget_hw_value $intc_src_port]
            if { $intc_src_port_value == $interrupt_signal } {

                # Verify that these are the ports we are interested in
                if { $interrupt_signal_name == [format "TemacIntc0_Irpt"] } {

                    # verify that we are working with channel 0
                    if { $chan == 0 } {
                        # Recreate the XPAR name and add it to the config file
#                        set formatted_name [format "XPAR_%s_%s_%s_INTR" $intc_name $periph_name $interrupt_signal_name ]
#                        add_field_to_periph_config_struct $device_id [string toupper $formatted_name]
                        puts $file_handle "\#define $canonical_name $i"
                        add_field_to_periph_config_struct $device_id $canonical_name
                        set addentry 1
                    }
                }
                if { $interrupt_signal_name == [format "TemacIntc1_Irpt"] } {

                    # verify that we are working with channel 1
                    if { $chan == 1 } {
                        # Recreate the XPAR name and add it to the config file
#                        set formatted_name [format "XPAR_%s_%s_%s_INTR" $intc_name $periph_name $interrupt_signal_name ]
#                        add_field_to_periph_config_struct $device_id [string toupper $formatted_name]
                        puts $file_handle "\#define $canonical_name $i"
                        add_field_to_periph_config_struct $device_id $canonical_name
                        set addentry 1
                    }
                }
            }
            incr i
        }
    }

    if { $addentry == 0 } {
        # No interrupts were connected, so add dummy entry to the config structure
        puts $file_handle [format "#define $canonical_name 0xFF"]
        add_field_to_periph_config_struct $device_id 0xFF
    }
}


# ------------------------------------------------------------------
# Given each LL peripheral (such as TEMAC, PCI, USB, etc.)
# which is an initiator on a local link interface, traverse the local
# link to the target side, figure out the peripheral type that
# is connected and put in appropriate defines.
# The peripheral on the other side can be hard DMA,
# soft DMA or LL_FIFO.
#
# NOTE: This procedure assumes that each LL link on each peripheral
#       corresponds to a unique device id in the system and populates
#       the global device config params structure accordingly.
#       That is so ugly! The alternative is to make this an
#       LL temac specific procedure, which is a shame, since most of
#       the code is generic and applies to similiar LL peripherals
#       such as PCI/USB etc.
# ------------------------------------------------------------------
proc xdefine_ll_target_params {periphs file_handle} {

    global periph_config_params
    global periph_ninstances

    #
    # First dump some enumerations on LL_TYPE
    #
    puts $file_handle "/* LocalLink TYPE Enumerations */"
    puts $file_handle "#define XPAR_LL_FIFO    1"
    puts $file_handle "#define XPAR_LL_DMA     2"
    puts $file_handle ""

    set deviceid 0

    # Get unique list of p2p peripherals
    foreach periph $periphs {
        set p2p_periphs [list]
        set mhs_handle [xget_hw_parent_handle $periph]
        set periph_name [string toupper [xget_hw_name $periph]]
        # Get all point2point buses for periph
        # TODO: Filter on bus_std == XIL_LL_DMA as well, otherwise we might be picking up
        #       p2p interfaces used for other purposes
        set p2p_busifs_i [xget_hw_busifs_by_subproperty $periph "BUS_TYPE" "INITIATOR"]

        puts $file_handle ""
        puts $file_handle "/* Canonical LocalLink parameters for $periph_name */"

        # Add p2p periphs
        foreach p2p_busif $p2p_busifs_i {

            set busif_name [string toupper [xget_hw_name $p2p_busif]]
            set bus_name [string toupper [xget_hw_value $p2p_busif]]
            set conn_busif_handle [xget_hw_connected_busifs_handle $mhs_handle $bus_name "TARGET"]
            if { [string compare -nocase $conn_busif_handle ""] == 0} {
                set dualchan [xget_param_value $periph "C_TEMAC1_ENABLED"]
                if { $dualchan != 0 } {
                    # If second channel is enabled, increment device ID even though LocalLink is not connected.
                    # This allows canonical params to align between temac defines and locallink defines.
                    puts "WARNING: locallink unconnected for a channel in $periph_name"
                    incr deviceid
                }
                continue
            }
            set conn_busif_name [xget_hw_name $conn_busif_handle]

            set target_periph [xget_hw_parent_handle $conn_busif_handle]

            # If this is not already in the list of periphs connected to
            # this peripheral, process the peripheral. Else, skip
            set posn [lsearch -exact $p2p_periphs $target_periph]
            if {$posn != -1} {
                continue
            }

            # Process the connected peripheral
            # This section of code relies on a lot of assumptions. For instance, the peripheral names, the types of parameters they have and their nature.
            # TODO: See if this can be abstracted into the MPD of each peripheral with tags.
            #
            # Now outputs canonical names for the XPAR constants, in addition to instance-specific names
            #
            set target_periph_type [xget_hw_value $target_periph]
            set target_periph_name [string toupper [xget_hw_name $target_periph]]
            set canonical_tag [string toupper [format "LLTEMAC_%d_LLINK" $deviceid ]]

            switch -glob $target_periph_type {

                "xps_ll_fifo" {

                    set ll_fifo_baseaddr [xget_value $target_periph "PARAMETER" "C_BASEADDR"]

                    #
                    # Handle the connection type (FIFO in this case)
                    #
#                   set formatted_name [format "XPAR_%s_%s_CONNECTED_TYPE" $periph_name $busif_name]
                    set canonical_name [format "XPAR_%s_CONNECTED_TYPE" $canonical_tag]
                    puts $file_handle "#define $canonical_name XPAR_LL_FIFO"
                    add_field_to_periph_config_struct $deviceid $canonical_name

                    #
                    # Handle the base address of the connected type
                    #
#                   set formatted_name [format "XPAR_%s_%s_CONNECTED_BASEADDR" $periph_name $busif_name]
                    set canonical_name [format "XPAR_%s_CONNECTED_BASEADDR" $canonical_tag]
                    puts $file_handle [format "#define $canonical_name %s" $ll_fifo_baseaddr]
                    add_field_to_periph_config_struct $deviceid $canonical_name

                    #
                    # Handle INTR signals for the LL channel
                    #
                    set canonical_name [format "XPAR_%s_CONNECTED_FIFO_INTR" $canonical_tag]

                    # First get the interrupt ports on this LL peripheral
                    set interrupt_port [xget_port_by_subtype $target_periph "SIGIS" "INTERRUPT" "DIR" "O"]


                    # For each interrupt port, find out the ordinal of the interrupt line
                    # as connected to an interrupt controller
                    set addentry 0
                    foreach intr_port $interrupt_port {
                        set interrupt_signal [xget_hw_value $intr_port]
                        set interrupt_signal_name [xget_hw_name $intr_port]
                        set intc_port [xget_hw_connected_ports_handle $mhs_handle $interrupt_signal "sink"]

                        # Make sure the interrupt signal was connected in this design. We assume
                        # at least one is. (could be a bug if user just wants polled mode)
                        if { $intc_port != "" } {
                            set found_intc ""
                            foreach intr_sink $intc_port {

                                set phandle [xget_hw_parent_handle $intr_sink]
                                set pname [string toupper [xget_hw_name $phandle]]

                                set special [xget_hw_option_value $phandle "SPECIAL"]
                                if {[string compare -nocase $special "interrupt_controller"] == 0} {

                                    # if connected to an interrupt controller, break and use this handle
                                    # TODO: could be a bug if connected to more than one intc (?)
                                    set found_intc $intr_sink
                                    break
                                }
                            }

                            if {$found_intc == ""} {
                                # not connected to an interrupt controller, so punt
                                # puts "Info: FIFO interrupt not connected to intc\n"
                                break
                            }

                            set intc_periph [xget_hw_parent_handle $found_intc]
                            set intc_name [string toupper [xget_hw_name $intc_periph]]
                        } else {
                            # puts "Info: $target_periph_name interrupt signal $interrupt_signal_name not connected"
                            continue
                        }


                        # A bit of ugliness here. The only way to figure the ordinal is to
                        # iterate over the interrupt lines again and see if a particular signal
                        # matches the original interrupt signal we were tracking.
                        # If it does, put out the XPAR
                        set intc_src_ports [xget_interrupt_sources $intc_periph]
                        set i 0
                        foreach intc_src_port $intc_src_ports {

                            if {[llength $intc_src_port] == 0} {
                                incr i
                                continue
                            }

                            set intc_src_port_value [xget_hw_value $intc_src_port]
                            if { $intc_src_port_value == $interrupt_signal } {


                                puts $file_handle [format "#define $canonical_name %d" $i]
                                add_field_to_periph_config_struct $deviceid $canonical_name

                                set addentry 1
                            }
                            incr i
                        }
                    }

                    if { $addentry == 0 } {
                        # Could not find a FIFO interrupt ID, so add a dummy one to the config
                        # and an empty constant to the xparameter file
                        puts $file_handle [format "#define $canonical_name 0xFF"]
                        add_field_to_periph_config_struct $deviceid 0xFF
                    }

                    # LL_FIFO has only one INTR line per channel. So we fill in dummy DMA interrupts
                    puts $file_handle [format "#define XPAR_%s_CONNECTED_DMARX_INTR 0xFF" $canonical_tag]
                    puts $file_handle [format "#define XPAR_%s_CONNECTED_DMATX_INTR 0xFF" $canonical_tag]
                    add_field_to_periph_config_struct $deviceid 0xFF
                    add_field_to_periph_config_struct $deviceid 0xFF
                }

                "*mpmc*" {

                    # Figure out which DMA engine, or port into MPMC, is being used
                    scan $conn_busif_name "SDMA_LL%d" mpmc_port_num

                    #
                    # DMA engines may have their own base addresses or share one
                    #
                    set shared_addr [xget_param_value $target_periph "C_ALL_PIMS_SHARE_ADDRESSES"]

                    if { $shared_addr == 0 } {
                        # DMA engines have their own base addresses
                        set mpmc_baseaddr [xget_value $target_periph "PARAMETER" [format "C_SDMA_CTRL%d_BASEADDR" $mpmc_port_num]]
                    } else {
                        # DMA engines share a base address, offset by the port number
                        set mpmc_baseaddr [xget_param_value $target_periph "C_SDMA_CTRL_BASEADDR"]
                        set mpmc_baseaddr 0x[format %x [expr $mpmc_baseaddr + [expr $mpmc_port_num * 0x80]]]
                    }


                    # Handle base address and connection type
#                    set formatted_name [format "XPAR_%s_%s_CONNECTED_TYPE" $periph_name $busif_name]

                    set canonical_name [format "XPAR_%s_CONNECTED_TYPE" $canonical_tag]
                    puts $file_handle "#define $canonical_name XPAR_LL_DMA"
                    add_field_to_periph_config_struct $deviceid $canonical_name

#                    set formatted_name [format "XPAR_%s_%s_CONNECTED_BASEADDR" $periph_name $busif_name]

                    set canonical_name [format "XPAR_%s_CONNECTED_BASEADDR" $canonical_tag]
                    puts $file_handle [format "#define $canonical_name %s" $mpmc_baseaddr]
                    add_field_to_periph_config_struct $deviceid $canonical_name

                    #
                    # Handle INTR signals for the LL channel
                    #

                    # In DMA mode, first put out a dummy entry for FIFO interrupt
                    puts $file_handle [format "#define XPAR_%s_CONNECTED_FIFO_INTR 0xFF" $canonical_tag]
                    add_field_to_periph_config_struct $deviceid 0xFF

                    set dmarx_signal [format "SDMA%d_Rx_IntOut" $mpmc_port_num]
                    set dmatx_signal [format "SDMA%d_Tx_IntOut" $mpmc_port_num]
                    xdefine_dma_interrupts $file_handle $mhs_handle $target_periph $deviceid $canonical_tag $dmarx_signal $dmatx_signal

                }

                "sdma*" {
                    #
                    # This case is for a standalone SDMA entry in the MHS file, which was often the
                    # case in pre-MPMC3 systems
                    #
                    scan $conn_busif_name "LLINK"

                    set mpmc_baseaddr [xget_value $target_periph "PARAMETER" [format "C_SDMA_BASEADDR"]]

                    # Handle base address and connection type
#                    set formatted_name [format "XPAR_%s_%s_CONNECTED_TYPE" $periph_name $busif_name]

                    set canonical_name [format "XPAR_%s_CONNECTED_TYPE" $canonical_tag]
                    puts $file_handle "#define $canonical_name XPAR_LL_DMA"
                    add_field_to_periph_config_struct $deviceid $canonical_name

#                    set formatted_name [format "XPAR_%s_%s_CONNECTED_BASEADDR" $periph_name $busif_name]

                    set canonical_name [format "XPAR_%s_CONNECTED_BASEADDR" $canonical_tag]
                    puts $file_handle [format "#define $canonical_name %s" $mpmc_baseaddr]
                    add_field_to_periph_config_struct $deviceid $canonical_name

                    #
                    # Handle INTR signals for the LL channel
                    #

                    # In DMA mode, first put out a dummy entry for FIFO interrupt
                    puts $file_handle [format "#define XPAR_%s_CONNECTED_FIFO_INTR 0xFF" $canonical_tag]
                    add_field_to_periph_config_struct $deviceid 0xFF

                    set dmarx_signal [format "SDMA_Rx_IntOut"]
                    set dmatx_signal [format "SDMA_Tx_IntOut"]
                    xdefine_dma_interrupts $file_handle $mhs_handle $target_periph $deviceid $canonical_tag $dmarx_signal $dmatx_signal

                }

                "ppc440*" {

                    scan $conn_busif_name "LLDMA%d" dma_port_num
                    # We assume the DCR DMA registers start at 0x80
                    set dma_baseaddr [format %x [expr $dma_port_num * 0x18 + 0x80]]

                    # Handle base address and connection type
#                    set formatted_name [format "XPAR_%s_%s_CONNECTED_TYPE" $periph_name $busif_name]

                    set canonical_name [format "XPAR_%s_CONNECTED_TYPE" $canonical_tag]
                    puts $file_handle "#define $canonical_name XPAR_LL_DMA"
                    add_field_to_periph_config_struct $deviceid $canonical_name

#                    set formatted_name [format "XPAR_%s_%s_CONNECTED_BASEADDR" $periph_name $busif_name]

                    set canonical_name [format "XPAR_%s_CONNECTED_BASEADDR" $canonical_tag]
                    puts $file_handle [format "#define $canonical_name 0x%s" $dma_baseaddr]
                    add_field_to_periph_config_struct $deviceid $canonical_name

                    #
                    # Handle INTR signals for the LL channel
                    #

                    # In DMA mode, first put out a dummy entry for FIFO interrupt
                    puts $file_handle [format "#define XPAR_%s_CONNECTED_FIFO_INTR 0xFF" $canonical_tag]
                    add_field_to_periph_config_struct $deviceid 0xFF

                    set dmarx_signal [format "DMA%dRXIRQ" $dma_port_num]
                    set dmatx_signal [format "DMA%dTXIRQ" $dma_port_num]
                    xdefine_dma_interrupts $file_handle $mhs_handle $target_periph $deviceid $canonical_tag $dmarx_signal $dmatx_signal

                }

                "default" {
                    error "Unable to handle LL connections for target type $target_periph_type" "" "mdt_error"
                }
            }

            puts $file_handle ""
            incr deviceid
        }
    }
}

# ------------------------------------------------------------------
# Create configuration C file as required by Xilinx drivers
# Use the config field list technique
# ------------------------------------------------------------------
proc xdefine_lltemac_config_file {file_name drv_string} {

    global periph_ninstances

    set filename [file join "src" $file_name]
    file delete $filename
    set config_file [open $filename w]
    xprint_generated_header $config_file "Driver configuration"
    puts $config_file "\#include \"xparameters.h\""
    puts $config_file "\#include \"[string tolower $drv_string].h\""
    puts $config_file "\n/*"
    puts $config_file "* The configuration table for devices"
    puts $config_file "*/\n"
    puts $config_file [format "%s_Config %s_ConfigTable\[\] =" $drv_string $drv_string]
    puts $config_file "\{"

    set start_comma ""
    for {set i 0} {$i < $periph_ninstances} {incr i} {

        puts $config_file [format "%s\t\{" $start_comma]
        set comma ""
        foreach field [get_periph_config_struct_fields $i] {
            puts -nonewline $config_file [format "%s\t\t%s" $comma $field]
            set comma ",\n"
        }

        puts -nonewline $config_file "\n\t\}"
        set start_comma ",\n"
    }
    puts $config_file "\n\};\n"
    close $config_file
}

# ------------------------------------------------------------------
# Main generate function - called by the tools
# ------------------------------------------------------------------
proc generate {drv_handle} {

    xdefine_lltemac_include_file $drv_handle "xparameters.h" "XLlTemac"
    xdefine_lltemac_config_file  "xlltemac_g.c" "XLlTemac"

}

# ------------------------------------------------------------------
# Find the two LocalLink DMA interrupts (RX and TX), and define
# the canonical constants in xparameters.h and the config table
# ------------------------------------------------------------------
proc xdefine_dma_interrupts { file_handle mhs_handle target_periph deviceid canonical_tag dmarx_signal dmatx_signal } {

    set target_periph_name [string toupper [xget_hw_name $target_periph]]

    # First get the interrupt ports on this LL peripheral
    set interrupt_port [xget_port_by_subtype $target_periph "SIGIS" "INTERRUPT" "DIR" "O"]


    # For each interrupt port, find out the ordinal of the interrupt line
    # as connected to an interrupt controller
    set addentry 0
    set dmarx "null"
    set dmatx "null"
    foreach intr_port $interrupt_port {
        set interrupt_signal_name [xget_hw_name $intr_port]
        set interrupt_signal [xget_hw_value $intr_port]
        set intc_port [xget_hw_connected_ports_handle $mhs_handle $interrupt_signal "sink"]

        # Make sure the interrupt signal was connected in this design. We assume
        # at least one is. (could be a bug if user just wants polled mode)
        if { $intc_port != "" } {
            set found_intc ""
            foreach intr_sink $intc_port {

                set phandle [xget_hw_parent_handle $intr_sink]
                set pname [string toupper [xget_hw_name $phandle]]

                set special [xget_hw_option_value $phandle "SPECIAL"]
                if {[string compare -nocase $special "interrupt_controller"] == 0} {

                    # if connected to an interrupt controller, break and use this handle
                    # TODO: could be a bug if connected to more than one intc (?)
                    set found_intc $intr_sink
                    break
                }
            }

            if {$found_intc == ""} {
                # not connected to an interrupt controller, so punt
                # puts "Info: DMA interrupt not connected to intc\n"
                break
            }

            set intc_periph [xget_hw_parent_handle $found_intc]
            set intc_name [string toupper [xget_hw_name $intc_periph]]
        } else {
            # puts "Info: $target_periph_name interrupt signal $interrupt_signal_name not connected"
            continue
        }

        # A bit of ugliness here. The only way to figure the ordinal is to
        # iterate over the interrupt lines again and see if a particular signal
        # matches the original interrupt signal we were tracking.
        # If it does, put out the XPAR
        set intc_src_ports [xget_interrupt_sources $intc_periph]
        set i 0
        foreach intc_src_port $intc_src_ports {

            if {[llength $intc_src_port] == 0} {
                incr i
                continue
            }

            set intc_src_port_value [xget_hw_value $intc_src_port]
            if { $intc_src_port_value == $interrupt_signal } {

                # Verify that these are the DMA ports we are interested in

                if { $interrupt_signal_name == $dmarx_signal } {

                    set canonical_name [format "XPAR_%s_CONNECTED_DMARX_INTR" $canonical_tag]
                    puts $file_handle [format "#define $canonical_name %d" $i]
                    set dmarx $canonical_name

                } elseif { $interrupt_signal_name == $dmatx_signal } {

                    set canonical_name [format "XPAR_%s_CONNECTED_DMATX_INTR" $canonical_tag]
                    puts $file_handle [format "#define $canonical_name %d" $i]
                    set dmatx $canonical_name
                }
                incr addentry
            }
            incr i
        }
    }

    # Now add to the config table in the proper order (RX first, then TX

    if { $dmarx == "null" } {
        puts $file_handle [format "#define XPAR_%s_CONNECTED_DMARX_INTR 0xFF" $canonical_tag]
        add_field_to_periph_config_struct $deviceid 0xFF
    } else {
        add_field_to_periph_config_struct $deviceid $dmarx
    }

    if { $dmatx == "null" } {
        puts $file_handle [format "#define XPAR_%s_CONNECTED_DMATX_INTR 0xFF" $canonical_tag]
        add_field_to_periph_config_struct $deviceid 0xFF
    } else {
        add_field_to_periph_config_struct $deviceid $dmatx
    }

    if { $addentry == 1} {
        # for some reason, only one DMA interrupt was connected (probably a bug),
        # but fill in a dummy entry for the other (may be the wrong direction!)
        puts "WARNING: only one SDMA interrupt line connected for $target_periph_name"
    }
}
