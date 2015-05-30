
/*******************************************************************************
* Ethernet component and parameters
*******************************************************************************/

Folder FOLDER_xtag_csp_LLTEMAC {
  NAME       Tri-Mode Ethernet Core
  SYNOPSIS   Tri-Mode Ethernet Core
  _CHILDREN  FOLDER_xtag_csp_CSP
}

Component INCLUDE_XLLTEMAC {
  NAME       LLTEMAC
  SYNOPSIS   Xilinx Tri-Mode Ethernet driver
  REQUIRES   
  _CHILDREN  FOLDER_xtag_csp_LLTEMAC
}

