# ========== Copyright Header Begin ==========================================
# 
# OpenSPARC T1 Processor File: OpenSPARCT1.sdc
# Copyright (c) 2006 Sun Microsystems, Inc.  All Rights Reserved.
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES.
# 
# The above named program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public
# License version 2 as published by the Free Software Foundation.
# 
# The above named program is distributed in the hope that it will be 
# useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
# 
# You should have received a copy of the GNU General Public
# License along with this work; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
# 
# ========== Copyright Header End ============================================
define_scope_collection           RAMS {find -hier -inst * -filter @view==ram1 || @view==nram || @view==RAM*}
define_scope_collection           RAMS_exp {expand -hier -from $RAMS}
define_scope_collection           RAM_OREG {find -hier -inst * -in $RAMS_exp -filter @view==dff* || @view==sdff* || @view==FD*}
define_attribute          {$RAM_OREG} syn_allow_retiming {0}
define_global_attribute syn_noclockbuf {1}

