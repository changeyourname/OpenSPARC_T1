#! /bin/sh
# ========== Copyright Header Begin ==========================================
# 
# OpenSPARC T1 Processor File: sjm_tstgen.pl
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
#
#  SCCS ID: @(#).perl_wrapper	1.1 02/03/99
#
#  Cloned from .common_tool_wrapper

loginfo () {
    echo "DATE:              "`date`
    echo "WRAPPER:           $TRE_PROJECT/tools/bin/perl_wrapper"
    echo "USER:              "$user
    echo "HOST:              "`uname -n`
    echo "SYS:               "`uname -s` `uname -r`
    echo "PWD:               "`pwd`
    echo "ARGV:              "$ARGV
    echo "TOOL:              "$tool
    echo "VERSION:           "$version
    echo "TRE_SEARCH:        "$TRE_SEARCH
    echo "TRE_ENTRY:         "$TRE_ENTRY
}

mailinfo () {
    echo To: $1
    echo Subject: TRE_LOG
    echo "#"
    loginfo
}

mailerr () {
    echo "To: $1"
    echo "Subject: TRE ERROR"
    echo "#"
    echo "ERROR:             $2"
    loginfo
}

log () {
    # Log to TRE_LOG if it is set properly.
    # It is STRONGLY recommended that TRE_LOG be an e-mail address
    # in order to avoid problems with several people simultanously 
    # writing to the same file.
    # TRE_LOG must be set, but it can be broken.
    # TRE_ULOG is optional, for users who want their own logging.
    if [ ! -z "$TRE_LOG_ENABLED" ] ; then
    if [ ! -z "$TRE_LOG" ] ; then
	# Check first if TRE_LOG is a file (this is cheap).
	if [ -f $TRE_LOG -a -w $TRE_LOG ] ; then
    	    echo "#" >> $TRE_LOG
	    loginfo >> $TRE_LOG
	elif /usr/lib/sendmail -bv $TRE_LOG 1>&- 2>&- ; then
	    mailinfo $TRE_LOG | /usr/lib/sendmail $TRE_LOG
	else
	    mailerr $user "Can't log to TRE_LOG=$TRE_LOG. Fix environment." | /usr/lib/sendmail $user
	fi
    else
	die "TRE_LOG environment variable is not set."
    fi
    fi
    # TRE_ULOG is optional user log.  EMAIL address is recommended.
    if [ ! -z "$TRE_ULOG" ] ; then
	# Check first if TRE_ULOG is a file (this is cheap).
	if [ -f $TRE_ULOG -a -w $TRE_ULOG ] ; then
    	    echo "#" >> $TRE_ULOG
	    loginfo >> $TRE_ULOG
	elif /usr/lib/sendmail -bv $TRE_ULOG 1>&- 2>&- ; then
	    mailinfo $TRE_ULOG | /usr/lib/sendmail $TRE_ULOG
	else
	    mailerr $user "Can't log to TRE_ULOG=$TRE_ULOG. Fix environment." | /usr/lib/sendmail $user
	fi
    fi
}

die () {
    message="$1"
    echo "$tool -> perl_wrapper: $message Exiting ..."
    if [ ! -z "$TRE_LOG" ] ; then
	if [ -f ${TRE_LOG} -a -w ${TRE_LOG} ] ; then
    	    echo "#" >> $TRE_LOG
    	    echo "ERROR:             $message" >> $TRE_LOG
	    loginfo >> $TRE_LOG
	elif /usr/lib/sendmail -bv $TRE_LOG 1>&- 2>&- ; then
	    mailerr $TRE_LOG "$message" | /usr/lib/sendmail $TRE_LOG
	else
    	    echo  "Can not log to TRE_LOG=${TRE_LOG}. Logging to '$user.'"
	    mailerr $user "$message" | /usr/lib/sendmail $user
	fi
    fi
    # TRE_ULOG is optional user log.  EMAIL address is recommended.
    if [ ! -z "$TRE_ULOG" ] ; then
	if [ -f ${TRE_ULOG} -a -w ${TRE_ULOG} ] ; then
    	    echo "#" >> $TRE_ULOG
    	    echo "ERROR:             $message" >> $TRE_ULOG
	    loginfo >> $TRE_ULOG
	elif /usr/lib/sendmail -bv $TRE_ULOG 1>&- 2>&- ; then
	    mailerr $TRE_ULOG "$message" | /usr/lib/sendmail $TRE_ULOG
	else
    	    echo  "Can not log to TRE_ULOG=${TRE_ULOG}. Logging to '$user.'"
	    mailerr $user "$message" | /usr/lib/sendmail $user
	fi
    fi
    exit 1 
}

############################ main ##############################

tool=`basename $0`
ARGV="$*"
TRE_PROJECT=$DV_ROOT

if [ -z "$TRE_PROJECT" ]; then
    die "TRE_PROJECT not defined"
fi

TRE_ROOT=$TRE_PROJECT/tools/perlmod

### Verify TRE_SEARCH and TRE_ENTRY are defined and non-null

if [ -z "$TRE_SEARCH" ]; then
    die "TRE_SEARCH not defined"
fi
if [ -z "$TRE_ENTRY" ]; then
    die "TRE_ENTRY not defined"
fi

### Get version, based on tool invoked, and $TRE_ENTRY

if [ $tool = "configsrch" ] ; then
    exe=$TRE_ROOT/$tool
    exec $exe "$@"
    exit
else

    version=`configsrch $tool $TRE_ENTRY 2>&1`
    stat=$?
    if [ $stat != 0 ] ; then
        die "configsrch returned error code $stat"
    fi

    ###  Verify configsrch delivered a non-null version

    if [ -z "$version" ]; then
        die "No version set by configsrch"
    fi
fi

###  Assemble do-file name. If it's there, execute and test status.

exe=$TRE_ROOT/$tool,$version.do
if [ -x $exe ]; then
    $exe
    dostat=$?
    if [ $? != 0 ] ; then
	die "Error return from do file"
    fi
fi

OS=`uname -s`
if [ $OS = "SunOS" ] ; then
    user=`/usr/ucb/whoami`
    CPU=`uname -p`
fi
if [ $OS = "Linux" ]; then
    user=`/usr/bin/whoami`
    CPU=`uname -m`
fi

if [ -z "$PERL_VER" ] ; then
  if [ -z "$PERL5OPT" ] ; then
    PERL5OPT="-I$PERL_MODULE_BASE -I$PERL_MODULE_BASE/$OS-$CPU"
  else
    PERL5OPT="-I$PERL_MODULE_BASE -I$PERL_MODULE_BASE/$OS-$CPU $PERL5OPT"
  fi
else
  if [ -z "$PERL5OPT" ] ; then
    PERL5OPT="-I$PERL_MODULE_BASE -I$PERL_MODULE_BASE/$OS-$CPU -I$PERL5_PATH/$PERL_VER -I$PERL5_PATH/$PERL_VER/sun4-solaris"
  else
    PERL5OPT="-I$PERL_MODULE_BASE -I$PERL_MODULE_BASE/$OS-$CPU -I$PERL5_PATH/$PERL_VER -I$PERL5_PATH/$PERL_VER/sun4-solaris $PERL5OPT"
  fi
fi
export PERL5OPT


exe=$TRE_ROOT/$tool,$version
if [ -x $exe ]; then
    exec $PERL_CMD $exe "$@"
else
    die "executable $exe not found!"
fi
