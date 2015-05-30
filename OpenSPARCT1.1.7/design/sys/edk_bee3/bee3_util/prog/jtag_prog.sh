#!/bin/sh

impact -batch jtag_prog.scr

xmd -tcl jtag_prog_slave.tcl
xmd -tcl jtag_prog_master.tcl

