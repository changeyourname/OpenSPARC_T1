
# User needs to define these new variables

setenv DV_ROOT /home/johndoe/OpenSPARCT1
setenv MODEL_DIR /home/johndoe/OpenSPARCT1_model

if (`uname -s` == "SunOS") then
  setenv CC_BIN "/usr/dist/pkgs/sunstudio_`uname -p`/SUNWspro/bin"
else
  setenv CC_BIN /usr/bin
endif

# Please define VERA_HOME only if you have VERA, otherwise comment it out.

if ((`uname -s` == "SunOS") && (`uname -p` == "sparc")) then
  setenv VERA_HOME /import/EDAtools/vera/vera,v6.2.10/5.x
else
  setenv VERA_HOME
endif

# Please define VCS_HOME only if you have VCS, otherwise comment it out.

setenv VCS_HOME /import/EDAtools/vcs/vcs7.1.1R21

# Please define NCV_HOME only if you have NC-Verilog, otherwise comment it out.

setenv NCV_HOME /import/EDAtools/ncverilog/ncverilog.v5.3.s2/5.x

# Please define NOVAS_HOME only if you have Debussy, otherwise comment it out.

if ((`uname -s` == "SunOS") && (`uname -p` == "sparc")) then
  setenv NOVAS_HOME /import/EDAtools/debussy/debussy,v5.3v19/5.x
endif

# Please define SYN_HOME only if you are running synopsys

setenv SYN_HOME "/import/EDAtools/synopsys/synopsys.vX-2005.09"

# Please define SYNP_HOME only if you are running Synplicity

setenv SYNP_HOME "/import/EDAtools/synplicity/synplify.v8.6.1/fpga_861"

setenv LM_LICENSE_FILE "/import/EDAtools/licenses/synopsys_key:/import/EDAtools/licenses/ncverilog_key"

# New variables (fixed or based on $DV_ROOT)

setenv TRE_ENTRY /
setenv TRE_LOG nobody
setenv TRE_SEARCH "$DV_ROOT/tools/env/tools.iver"
setenv ENVDIR $DV_ROOT/tools/env
setenv PERL_MODULE_BASE $DV_ROOT/tools/perlmod

# Synopsys variables from $SYN_HOME

setenv SYN_LIB $SYN_HOME/libraries/syn
setenv SYN_BIN $SYN_HOME/sparcOS5/syn/bin

# Set Perl related variables

if ((`uname -s` == "SunOS") && (`uname -p` == "sparc")) then
  setenv PERL_VER 5.8.7
  setenv PERL_PATH $DV_ROOT/tools/perl-$PERL_VER
  setenv PERL5_PATH $DV_ROOT/tools/perl-$PERL_VER/lib/perl5
  setenv PERL_CMD "$PERL_PATH/bin/perl"
  setenv PERL5LIB $PERL5_PATH
else
  setenv PERL_CMD "/usr/bin/perl"
endif

# Set path

setenv PATH ".:$DV_ROOT/tools/bin:$NCV_HOME/tools/bin:$VCS_HOME/bin:$VERA_HOME/bin:$SYN_BIN/:$CC_BIN/:$PATH"

set path = (. $DV_ROOT/tools/bin $NCV_HOME/tools/bin $VCS_HOME/bin $VERA_HOME/bin $SYN_BIN $CC_BIN $path)

