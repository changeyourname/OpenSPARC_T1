###############################################################
# Copyright (c) 2007 Xilinx, Inc. All Rights Reserved.
###############################################################

## @BEGIN_CHANGELOG EDK_Jm
##
##  - Added Interrupt support 
##
## @END_CHANGELOG

# -----------------------------------------------------------------
# Software Project Types (swproj):
#   0 : MemoryTest - Calls basic  memorytest routines from common driver dir
#   1 : PeripheralTest - Calls any existing polled_example and/or selftest
# -----------------------------------------------------------------

# -----------------------------------------------------------------
# TCL Procedures:
# -----------------------------------------------------------------

proc gen_include_files {swproj mhsinst} {
   if {$swproj == 0} {
      return ""
   }
   if {$swproj == 1} {
      set ifintr [get_intr $mhsinst]
      set dmaType [get_dma_type $mhsinst]

      if {$ifintr == 1} {
         set inc_file_lines {xlltemac.h xlltemac_example.h lltemac_header.h lltemac_intr_header.h}

         if {$dmaType == 1} {
            append inc_file_lines " xllfifo.h"
         }
         if {$dmaType == 3} {
            append inc_file_lines " xlldma.h"
         }
      } else {
         set inc_file_lines {xlltemac.h xlltemac_example.h lltemac_header.h}
      }

      return $inc_file_lines
   }

   return ""
}

proc gen_src_files {swproj mhsinst} {
  if {$swproj == 0} {
    return ""
  }
  if {$swproj == 1} {
        set ifintr [get_intr $mhsinst]
        set dmaType [get_dma_type $mhsinst]
                
      if {$ifintr == 1} {
          if {$dmaType == 1} {
              set inc_file_lines {examples/xlltemac_example.h examples/xlltemac_example_polled.c examples/xlltemac_example_util.c examples/xlltemac_example_intr_fifo.c data/lltemac_header.h data/lltemac_intr_header.h}
          } elseif {$dmaType == 3} {
              set inc_file_lines {examples/xlltemac_example.h examples/xlltemac_example_polled.c examples/xlltemac_example_util.c examples/xlltemac_example_intr_sgdma.c data/lltemac_header.h data/lltemac_intr_header.h}
          }
      } else {
          set inc_file_lines {examples/xlltemac_example.h examples/xlltemac_example_polled.c examples/xlltemac_example_util.c data/lltemac_header.h}            
      }
      return $inc_file_lines
  }
}

proc gen_testfunc_def {swproj mhsinst} {
  return ""
}

proc gen_init_code {swproj mhsinst} {
   if {$swproj == 0} {
      return ""
   }
   if {$swproj == 1} {
        
      set ipname [xget_value $mhsinst "NAME"] 
      set ifintr [get_intr $mhsinst]
        
      if {$ifintr == 1} {
         set dmaType [get_dma_type $mhsinst]
         set decl "   static XLlTemac ${ipname}_LlTemac;"

         # FIFO
         if {$dmaType == 1} {
            set mhsHandle   [xget_hw_parent_handle $mhsinst]
            set fifo_ipname [get_fifo_info $mhsHandle "name"]

            append decl "
   static XLlFifo  ${fifo_ipname}_LlFifo;

"
         }

         # DMA
         if {$dmaType == 3} {
            append decl "
   static XLlDma  ${ipname}_LlDma;

"
         }

         set inc_file_lines $decl
         return $inc_file_lines
      }
   }

   return ""
}


proc gen_testfunc_call {swproj mhsinst} {

  if {$swproj == 0} {
    return ""
  }

  set mhsHandle [xget_hw_parent_handle $mhsinst]
  set ipname [xget_value $mhsinst "NAME"] 
  set deviceid [xget_name $mhsinst "CHAN_0_DEVICE_ID"]
  #set deviceid "XPAR_${ipname}_CHAN_0_DEVICE_ID"
  set hasStdout [xhas_stdout $mhsinst]
  set dma [get_dma_type $mhsinst]
  set ifintr [get_intr $mhsinst]  

  set fifo_deviceid [get_fifo_info $mhsHandle "id"]
  set fifo_ipname   [get_fifo_info $mhsHandle "name"]

  if {$ifintr == 1} {
      set retMhsInst [xget_intc $mhsHandle] 
      set intcname [xget_value $retMhsInst "NAME"]
      set intcvar [xget_intc_drv_var]
      set intrport [xget_value $retMhsInst "PORT" "Irq"]
      #PPC is 1, MB is 0
      set ppc [string match "EICC405EXTINPUTIRQ" $intrport]
      
  } else {
      set ppc [has_ppchandle $mhsHandle]
  }


  if { $dma == 1 } {
      set type "Fifo"
  }
  if { $dma == 3 } {
      set type "SgDma"
  }
  
  set testfunc_call ""

   # BEGIN: FIFO
   if { $dma == 1 } {
      append testfunc_call "
      
   {
      XStatus status;
"
      
      if {${hasStdout} == 1} {
         append testfunc_call "
      print(\"\\r\\n Runnning TemacPolledExample() for ${ipname}...\\r\\n\");
"
      }
      
      append testfunc_call "
      status = TemacPolledExample( ${deviceid},
                                   ${fifo_deviceid} );
"

      if {${hasStdout} == 1} {
         append testfunc_call "
      if (status == 0) {
         print(\"TemacPolledExample PASSED\\r\\n\");
      }
      else {
         print(\"TemacPolledExample FAILED\\r\\n\");
      }
"
      }

      append testfunc_call "
   }
"
   }
   # END: FIFO

   # BEGIN: DMA
   if { $dma == 3 } {
      append testfunc_call "
   /* TemacPolledExample does not support SGDMA      
   {
      XStatus status;
"
            
      if {${hasStdout} == 1} {
         append testfunc_call "
      print(\"\\r\\n Runnning TemacPolledExample() for ${ipname}...\\r\\n\");
"
      }
      
      append testfunc_call "
      status = TemacPolledExample( ${deviceid},
                                   ${fifo_deviceid});
"
      
      if {${hasStdout} == 1} {
         append testfunc_call "
      if (status == 0) {
         print(\"TemacPolledExample PASSED\\r\\n\");
      }
      else {
         print(\"TemacPolledExample FAILED\\r\\n\");
      }
"
      }

      append testfunc_call "
   }
   */
"
   }
   # END: DMA

   # BEGIN: INTERRUPT
   if { ${ifintr} == 1 } {
            
      # LLTEMAC
      set intr_id   "XPAR_${intcname}_${ipname}_TEMACINTC0_IRPT_INTR"
      set intr_mask "XPAR_${ipname}_TEMACINTC0_IRPT_MASK"
      set intr_id   [string toupper $intr_id]
      set intr_mask [string toupper $intr_mask]

      if {$ppc == 1} {
         append testfunc_call "

#ifdef CACHE_H
       XCache_DisableDCache();
       XCache_DisableICache();
#endif
"
      }

      # BEGIN: FIFO & INTERRUPT 
      if {$dma == 1} {
         # LLFIFO
         set fifo_intr_id "XPAR_${intcname}_${fifo_ipname}_IP2INTC_IRPT_INTR"
         set fifo_intr_mask "XPAR_${fifo_ipname}_IP2INTC_IRPT_MASK"
         set fifo_intr_id   [string toupper $fifo_intr_id]
         set fifo_intr_mask [string toupper $fifo_intr_mask]

         append testfunc_call "
   {
      XStatus Status;
"

         if {${hasStdout} == 1} {
            append testfunc_call "
      print(\"\\r\\nRunning Temac${type}IntrExample() for ${ipname}...\\r\\n\");
"
         }

         append testfunc_call "
      Status = Temac${type}IntrExample(&${intcvar}, &${ipname}_LlTemac,
                  &${fifo_ipname}_LlFifo,
                  ${deviceid},
                  ${fifo_deviceid},
                  ${intr_id},
                  ${fifo_intr_id});
"

         if {${hasStdout} == 1} {
            append testfunc_call "
      if(Status == 0) {
         print(\"Temac Interrupt Test PASSED.\\r\\n\");
      } 
      else {
         print(\"Temac Interrupt Test FAILED.\\r\\n\");
      }
"
         }

         append testfunc_call "
   }
"
      }
      # END: FIFO & INTERRUPT

      # BEGIN: DMA & INTERRUPT
      if {$dma == 3} {
         # DMA
         set dmaDriverInst "${ipname}_LlDma"
         set dmaRxIntrId "XPAR_LLTEMAC_0_LLINK_CONNECTED_DMARX_INTR"
         set dmaTxIntrId "XPAR_LLTEMAC_0_LLINK_CONNECTED_DMATX_INTR"

         append testfunc_call "
   {
      XStatus Status;
"

         if {${hasStdout} == 1} {
            append testfunc_call "
      print(\"\\r\\nRunning Temac${type}IntrExample() for ${ipname}...\\r\\n\");
"
         }

         append testfunc_call "
      Status = Temac${type}IntrExample(&${intcvar}, &${ipname}_LlTemac,
                     &${dmaDriverInst},
                     ${deviceid},
                     ${intr_id},
                     ${dmaRxIntrId},
                     ${dmaTxIntrId});
"

         if {${hasStdout} == 1} {
            append testfunc_call "
      if (Status == 0) {
         print(\"Temac Interrupt Test PASSED.\\r\\n\");
      } 
      else {
         print(\"Temac Interrupt Test FAILED.\\r\\n\");
      }
"
         }

         append testfunc_call "
   }"
      }
      # END: DMA & INTERRUPT
   }
   # END: INTERRUPT

   return $testfunc_call
}


proc get_intr {mhsinst} {
    set ipname [xget_value $mhsinst "NAME"] 
    set portname_intr "TemacIntc0_Irpt"
    set port_intr [xget_value $mhsinst "PORT" $portname_intr]
    set temac_intr [string match "${ipname}_${portname_intr}" $port_intr]

    # Try Intc1
    if {$temac_intr == 0} {
       set portname_intr "TemacIntc1_Irpt"
       set port_intr [xget_value $mhsinst "PORT" $portname_intr]
       set temac_intr [string match "${ipname}_${portname_intr}" $port_intr]
    }

    if {$temac_intr == 1} {
        set mhsHandle [xget_hw_parent_handle $mhsinst]
        set sinkHandle [xget_hw_connected_ports_handle $mhsHandle "${ipname}_${portname_intr}" "sink"]
        if {$sinkHandle != ""} {
            set intcHandle [xget_hw_parent_handle $sinkHandle]
            set irqValue [xget_hw_port_value $intcHandle "Irq"] 
            if {$irqValue != ""} {
                set procSinkHandle [xget_hw_connected_ports_handle $mhsHandle $irqValue "sink"]
                if {$procSinkHandle != ""} {
                    set procSinkName [xget_hw_name $procSinkHandle]
                    set procVisiblePPC440 [string match $procSinkName "EICC440EXTIRQ"]
                    set procVisiblePPC [string match $procSinkName "EICC405EXTINPUTIRQ"]
                    set procVisibleMB [string match $procSinkName "INTERRUPT"]                        
                    set procVisible [expr $procVisiblePPC || $procVisibleMB || $procVisiblePPC440 ]
                    if {$procVisible == 1} {
                        set temac_intr 1
                        return $temac_intr
                    }
                }
            }
        }
    }
    set temac_intr 0
    return $temac_intr
}

###############################################################################
# Get FIFO info.
# type = 
#    "id"   - get DEVICE_ID string of FIFO
#    "name" - instance name of FIFO
#
proc get_fifo_info {mhsHandle type} {

   set ipinst_list [xget_hw_ipinst_handle $mhsHandle "*"]

   foreach ipinst $ipinst_list {
      set coreName [xget_hw_value $ipinst]
      set instName [xget_hw_name  $ipinst]

      if {[string compare -nocase $coreName "xps_ll_fifo"] == 0} {

         if {[string compare -nocase $type "id"] == 0} {
            set deviceid [xget_name $ipinst "DEVICE_ID"]
            return $deviceid
         }
         if {[string compare -nocase $type "name"] == 0} {
            return $instName
         }
      }
   }

   return ""
}

proc get_dma_type {mhsinst} {

  set mhsHandle [xget_hw_parent_handle $mhsinst]
  set dma [xget_value $mhsinst "PARAMETER" "C_DMA_TYPE"]
  set fifo_deviceid [get_fifo_info $mhsHandle "id"]

  # New xps_ll_temac doesn't have DMA parameter; Instead for DMA=1, FIFO
  # is added to system.
  if { $dma == "" } {
     if { $fifo_deviceid != "" } {
        set dma 1
     } else {
        set dma 3
     }
  }

  return $dma
}

###############################################################################
# Determine if system has ppc
#
proc has_ppchandle {mhsHandle } {

   set ipinst_list [xget_hw_ipinst_handle $mhsHandle "*"]

   foreach ipinst $ipinst_list {
      set coreName [xget_hw_value $ipinst]
      set instName [xget_hw_name  $ipinst]

      if {[string compare -nocase $coreName "ppc405"] == 0} {
         return 1
      } elseif {[string compare -nocase $coreName "ppc405_virtex4"] == 0} {
         return 1
      }
   }

   return 0
}

