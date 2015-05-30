
# User needs to define these new variables

export DV_ROOT=/home/johndoe/OpenSPARCT1
export MODEL_DIR=/home/johndoe/OpenSPARCT1_model

if [ `uname -s` = "SunOS" ]
then
  export CC_BIN="/usr/dist/pkgs/sunstudio_`uname -p`/SUNWspro/bin"
else
  export CC_BIN=/usr/bin
fi

# Please define VERA_HOME only if you have VERA, otherwise comment it out.

if [ `uname -s` = "SunOS" -a `uname -p` = "sparc" ]
then
  export VERA_HOME=/import/EDAtools/vera/vera,v6.2.10/5.x
else
  export VERA_HOME
fi

# Please define VCS_HOME only if you have VCS, otherwise comment it out.

export VCS_HOME=/import/EDAtools/vcs/vcs7.1.1R21

# Please define NCV_HOME only if you have NC-Verilog, otherwise comment it out.

export NCV_HOME=/import/EDAtools/ncverilog/ncverilog.v5.3.s2/5.x

# Please define NOVAS_HOME only if you have Debussy, otherwise comment it out.

if [ `uname -s` = "SunOS" -a `uname -p` = "sparc" ]
then
  export NOVAS_HOME=/import/EDAtools/debussy/debussy,v5.3v19/5.x
fi

# Please define SYN_HOME only if you are running synopsys

export SYN_HOME="/import/EDAtools/synopsys/synopsys.vX-2005.09"

# Please define SYNP_HOME only if you are running Synplicity

export SYNP_HOME="/import/EDAtools/synplicity/synplify.v8.6.1/fpga_861"

export LM_LICENSE_FILE="/import/EDAtools/licenses/synopsys_key:/import/EDAtools/licenses/ncverilog_key"

# New variables (fixed or based on $DV_ROOT)

export TRE_ENTRY=/
export TRE_LOG=nobody
export TRE_SEARCH="$DV_ROOT/tools/env/tools.iver"
export ENVDIR=$DV_ROOT/tools/env
export PERL_MODULE_BASE=$DV_ROOT/tools/perlmod

# Synopsys variables from $SYN_HOME

export SYN_LIB=$SYN_HOME/libraries/syn
export SYN_BIN=$SYN_HOME/sparcOS5/syn/bin

# Set Perl related variables

if [ `uname -s` = "SunOS" -a `uname -p` = "sparc" ]
then
  export PERL_VER=5.8.7
  export PERL_PATH=$DV_ROOT/tools/perl-$PERL_VER
  export PERL5_PATH=$DV_ROOT/tools/perl-$PERL_VER/lib/perl5
  export PERL_CMD="$PERL_PATH/bin/perl"
else
  export PERL_CMD="/usr/bin/perl"
fi

# Set path

export PATH=".:$DV_ROOT/tools/bin:$NCV_HOME/tools/bin:$VCS_HOME/bin:$VERA_HOME/bin:$SYN_BIN/:$CC_BIN/:$PATH"


