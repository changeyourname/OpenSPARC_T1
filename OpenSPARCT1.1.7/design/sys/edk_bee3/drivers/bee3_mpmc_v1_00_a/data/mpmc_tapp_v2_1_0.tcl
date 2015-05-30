###############################################################
# Copyright (c) 2004-2007 Xilinx, Inc. All Rights Reserved.
###############################################################

## @BEGIN_CHANGELOG EDK_I_SP1
##
##  - Added MPMC Register Test
##
## @END_CHANGELOG

## @BEGIN_CHANGELOG EDK_I
##
##  - Add a new argument to gen_include_files.
##
## @END_CHANGELOG

## @BEGIN_CHANGELOG EDK_H
##
##  - Added support for generation of multiple applications.
##    All TCL procedures are now required to have a software
##    project type as its first argument
##    
## @END_CHANGELOG

# Uses $XILINX_EDK/bin/lib/xillib_sw.tcl

# -----------------------------------------------------------------
# Software Project Types (swproj):
#   0 : MemoryTest - Calls basic  memorytest routines from common driver dir
#   1 : PeripheralTest - Calls any existing polled_example and/or selftest
# -----------------------------------------------------------------

# -----------------------------------------------------------------
# TCL Procedures:
# -----------------------------------------------------------------

proc gen_include_files {swproj mhsinst} {
  if {$swproj == 1} {
    return ""
  }

  set ecc_support [xget_hw_parameter_value $mhsinst "C_INCLUDE_ECC_SUPPORT"]
  if {$swproj == 0} {
    if {$ecc_support == 1} {
       set inc_file_lines {xutil.h mpmc_header.h}
    } else {
       set inc_file_lines {xutil.h}
    }

    return $inc_file_lines
  }
}

proc gen_src_files {swproj mhsinst} {
  set ecc_support [xget_hw_parameter_value $mhsinst "C_INCLUDE_ECC_SUPPORT"]
  if {$swproj == 1} {
    return ""
  }
  if {$swproj == 0} {
    if {${ecc_support} == 1} {
       set inc_file_lines {examples/mpmc_selftest_example.c data/mpmc_header.h}
	 } else {
       set inc_file_lines {}
	 }
    return $inc_file_lines
  }

}

proc gen_testfunc_def {swproj mhsinst} {
  return ""
}

proc gen_init_code {swproj mhsinst} {
  return ""
}

proc gen_testfunc_call {swproj mhsinst} {

  if {$swproj == 1} {
    return ""
  }
  
  set ipname [xget_value $mhsinst "NAME"]
  set hasStdout [xhas_stdout $mhsinst]

  set testfunc_call ""



  set prog_memranges [xget_program_mem_ranges $mhsinst]
  if {[string compare ${prog_memranges} ""] != 0} {
    foreach progmem $prog_memranges {
      set baseaddrval [xget_value $mhsinst "PARAMETER" ${progmem}]
      append testfunc_call "
   /* 
    * MemoryTest routine will not be run for the memory at 
    * ${baseaddrval} (${ipname})
    * because it is being used to hold a part of this application program
    */
"
    }
  }

  set romemranges [xget_readonly_mem_ranges $mhsinst]
  if {[string compare ${romemranges} ""] != 0} {
    foreach romem $romemranges {
      set baseaddrval [xget_value $mhsinst "PARAMETER" ${romem}]
      append testfunc_call "
   /* 
    * MemoryTest routine will not be run for the memory at 
    * ${baseaddrval} (${ipname})
    * because it is a read-only memory
    */
"
    }
  }

  set baseaddrs [xget_writeable_mem_ranges $mhsinst]
  if {[string compare ${baseaddrs} ""] == 0} {
     return $testfunc_call
  }

  append testfunc_call "
   /* Testing MPMC Memory (${ipname})*/
   \{"

  if {${hasStdout} == 1} {
    append testfunc_call "
      XStatus status;"
  }

  # Get XPAR_ macro for each baseaddr param
  foreach baseaddr $baseaddrs {
    lappend baseaddr_macros [xget_name $mhsinst $baseaddr]
  }

  foreach baseaddr $baseaddr_macros {
    if {${hasStdout} == 0} {

      append testfunc_call "

      XUtil_MemoryTest32((Xuint32*)${baseaddr}, 1024, 0xAAAA5555, XUT_ALLMEMTESTS);
      XUtil_MemoryTest16((Xuint16*)${baseaddr}, 2048, 0xAA55, XUT_ALLMEMTESTS);
      XUtil_MemoryTest8((Xuint8*)${baseaddr}, 4096, 0xA5, XUT_ALLMEMTESTS);"
    } else {

      append testfunc_call "

      print(\"Starting MemoryTest for ${ipname}:\\r\\n\");
      print(\"  Running 32-bit test...\");
      status = XUtil_MemoryTest32((Xuint32*)${baseaddr}, 1024, 0xAAAA5555, XUT_ALLMEMTESTS);
      if (status == XST_SUCCESS) {
         print(\"PASSED!\\r\\n\");
      }
      else {
         print(\"FAILED!\\r\\n\");
      }
      print(\"  Running 16-bit test...\");
      status = XUtil_MemoryTest16((Xuint16*)${baseaddr}, 2048, 0xAA55, XUT_ALLMEMTESTS);
      if (status == XST_SUCCESS) {
         print(\"PASSED!\\r\\n\");
      }
      else {
         print(\"FAILED!\\r\\n\");
      }
      print(\"  Running 8-bit test...\");
      status = XUtil_MemoryTest8((Xuint8*)${baseaddr}, 4096, 0xA5, XUT_ALLMEMTESTS);
      if (status == XST_SUCCESS) {
         print(\"PASSED!\\r\\n\");
      }
      else {
         print(\"FAILED!\\r\\n\");
      }"

    }
  }

  append testfunc_call "
   \}"

  ##
  ## ---------------------   start TestApp_Memory  --------------------
  ##

  set deviceid [xget_name $mhsinst "DEVICE_ID"]
  set ecc_support [xget_hw_parameter_value $mhsinst "C_INCLUDE_ECC_SUPPORT"]
  
  if {${ecc_support} == 1} {
     if {${hasStdout} == 0} {
   
         append testfunc_call "
   
   {
      XStatus status;
                           
      status = MpmcSelfTestExample(${deviceid});
   
   }"
     } else {
   
         append testfunc_call "
   
   {
      XStatus status;
               
      print(\"\\r\\n Runnning Mpmc Register Test for ${ipname}...\\r\\n\");
         
      status = MpmcSelfTestExample(${deviceid});
         
      if (status == 0) {
         print(\"MPMC Register Test PASSED\\r\\n\");
      }
      else {
         print(\"MPMC Register Test FAILED\\r\\n\");
      }
   }"
     }
  } else {
     append testfunc_call "

   /**
    * MpmcSelfTestExample() will not be run for the memory 
    * (${ipname}) because ECC is not supported.
    */
"
  }

  ## ---------------------   end TestApp_Memory  --------------------


  return $testfunc_call
}
