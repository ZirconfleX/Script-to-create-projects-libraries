# This "!/bin/bash" Is add in the header that is add to this file when
# creating a project or library.
#-
ScriptName=`basename $0`
#=================================================================================================
# This is normally automatically set when the Create Project or Library script is run.
# In case it needs to be changed, added or other manually, see below
# Provide here the name, without extention or name adition, of the single or top level VHDL
# file that needs to be simulated.
# Example:
#   Need to simulate a VHDL file: ${FILE_NAME}.vhd
#   Having made a testbench ${FILE_NAME}_Testbench.vhd
#   and a tester/stimulus file: ${FILE_NAME}_Tester.vhd
#   Above files are present in the ../Vhdl directory.
#   The ../Simscripts directory contains all scripting files ancluding this one.
#   Set the SIMFILE environment to the base name of the single or top level VHDL file.
#   In case of the example it is: ${FILE_NAME}
#
SIMFILE=${FILE_NAME}
#=================================================================================================
# Used Libraries
# Beside the main and primitive libraries, six extra libraries can be add here.
#       When more than six extra libraries are used modify this script.
# Most of the time only one or two will be used.
MainLib=work
SecureIpLib=secureip
ExtrLib_1=
#ExtrLib_2=
#ExtrLib_3=
#ExtrLib_4=
#ExtrLib_5=
#ExtrLib_6=
#=================================================================================================
# Command line options
xv_boost_lib_path=$XILINX_VIVADO/tps/boost_1_64_0
#-------------------------------------------------------------------------------------------------
#- Main steps
run()
{
  check_args $1
  #
  if [ -f ../Simulation/xsim.log ]; then
    reset_run
  fi
  #-
  echo "                                                                    "
  echo " Checking if there is a project file that goes with this simulation."
  ProjFileName=${ScriptName//.sh}
  #
  if [ -f ${ProjFileName}.prj ]; then
    echo " Project file exist. "
  else
    echo "                                                 "
    echo " A project file does not exist in this directory."
    echo " Simulation cannot run! "
    echo " Please, create a valid project file in this directory. "
    echo " Get/read guidelines in the \"ReadMe_Simulation.pdf\" file."
    echo " Exiting this script now ... "
    sleep 1
    exit
  fi
  echo "                                   "
  if [ -f "../Simulation/"$SIMFILE"_FuncSim.wcfg" ]; then
    echo " A "$SIMFILE"_FuncSim.wcfg file is present in the ../Simulation directory."
  else
    cp "$SIMFILE"_FuncSim.wcfg ../Simulation/"$SIMFILE"_FuncSim.wcfg
    echo " Base empty "$SIMFILE"_FuncSim.wcfg file copied into ../Simulation."
  fi
  #-
  if [ -f "../Simulation/xsim.ini" ]; then
      echo " A xsim.ini file is present in the ../Simulation directory."
  else
    cp xsim.ini ../Simulation/xsim.ini
    echo " xsim.ini file copied from /SimScripts into ../Simulation."
  fi
  #-
  setup $1
}
#=================================================================================================
#- STEP: setup
setup()
{
  case $1 in
    "--help" )
      usage
    ;;
    "--compile" )
      echo "                                                                                  "
      echo " When instantiated components from other libraries than the 'work' and Xilinx     "
      echo " primitive libraries are used in the \"$SIMFILE\" simulation, these libraries     "
      echo " must be listed in the \"$ScriptName\" simulation script under the header \"Used Libraries\"."
      echo " Following libraries are now listed to be used:  "
      UsedLibs="--lib ${MainLib} --lib ${SecureIpLib}"
      echo " Library: $MainLib "
      echo " Library: $SecureIpLib "
      for n in {1..6}; do
        lbnm="ExtrLib_${n}"
        if [ -n "${!lbnm}" ]; then
          echo " library: ${!lbnm}"
          UsedLibs="${UsedLibs} --lib ${!lbnm}"
        else
          echo " No other used. "
        fi
      done
      #
      echo "                 "
      echo " These extra libraries must also be add into the simulation project file \"${ProjFileName}.prj\"."
      echo " Get/read guidelines in the \"ReadMe_Simulation.pdf\" file."
      #read -p " Exit to correct the ${ProjFileName}.prj project file? y/n: " YesNo
      #if [ "${YesNo,,}" == "y" ]; then
      #  echo " Exiting.... "
      #  sleep 1
      #  exit
      #elif [ "${YesNo,,}" == "n" ]; then
      #  echo " Continuing.... "
      #else
      #  echo " Please answer with y/n! "
      #  run
      #fi
      sleep 2
      echo " "
      #-
      echo "Compiling design files."
      echo "Compiler log file is called xvhdl.log and is available in the ../Simulation directory."
      compile
      exit 0
    ;;
    "--elaborate" )
      UsedLibs="--lib ${MainLib} --lib ${SecureIpLib}"
      for n in {1..6}; do
        lbnm="ExtrLib_${n}"
        if [ -n "${!lbnm}" ]; then
          UsedLibs="${UsedLibs} --lib ${!lbnm}"
        fi
      done
      echo " Elaborating design files."
      echo " Elaborate log file is written as xelab.log in the ../Simulation directory."
      elaborate
      exit 0
    ;;
    "--simulate" )
      echo " Simulating design files."
      echo " Simulation log file is written as xsim.log in the ../Simulation directory."
      simulate
      exit 0
    ;;
    "--all" )
      echo " Compile, elaborate and simulate design files."
      echo " For each of the tree steps a log file is written into the ../Simulation directory."
      compile
      elaborate
      simulate
      exit 0
    ;;
    "--xcrg_report" )
      echo " Create a functional coverage report."
      echo " The report is created in the ../Simulation/XcrgReport directory as an HTM file."
      xcrg_report
      exit 0
    ;;
    "--reset_run" )
      reset_run
      echo " INFO: Simulation run files in the ../Simulation directory are all, except the wcfg "
      echo " and wdb files, deleted."
      exit 0
    ;;
    * )
  esac
}
#=================================================================================================
#- RUN_STEP: <compile>
#-  xvhdl [options] file...
#-    -file [-f]            : Read additional options from the specified file
#-    -help [-help]         : Print this help message
#-    --version             : Print the compiler version
#-    --initfile            : Use user defined simulator init file to add to or override the
#-                          :  settings provided by the default xsim.ini file
#-    --lib [-L]            : Specify search libraries for the instantiated design units in a
#-                          :  Verilog or Mixed language design. Use -L|--lib for each search
#-                          :  library. The format of the argument is <name>[=<dir>] where
#-                          :  <name> is the logical name of the library and <dir> is an
#-                          :  optional physical
#-                          : directory of the library
#-    --nolog               : Suppress log file generation
#-    --log                 : Specify the log file name. Default is <application name>.log
#-    --prj                 : Specify Vivado Simulator project file containing one or more
#-                          :  entries of 'vhdl|verilog <work lib> <HDL file name>'
#-    --relax               : Relax strict HDL language checking rules
#-    --verbose [-v]        : Specify verbosity level for printing messages. Allowed values
#-                          :  are: 0, 1, 2 (Default:0)
#-    --incr                : Enable incremental parsing and compilation check point
#-    --nosignalhandlers    : Run with no XSim specific signal handlers. Necessary when 3rd
#-                          :  party software such as antivirus, firewall is generating signals
#-                          :  as part of its normal usage, causing XSim Compiler and Kernel
#-                          :  executables to trap these signals and report a crash.
#-    --93_mode             : Force usage of VHDL-93 mode for STD and IEEE libraries. Default
#-                          :  is mixed 93 and 2008. If used, should be used for all VHDL files
#-                          :  for the specific project.
#-    --work arg            : Specify the work library. The format of the argument is
#-                          :   <name>[=<dir>] where <name> is the logical name of the library
#-                          :  and <dir> is an optional physical directory of the library.
#-    --encryptdumps        : Encrypt parse dump of design units
#-    --2008                : Specify input files to be VHDL-2008 files
#-
compile()
{
  cd ../Simulation
  echo " Reading project information from ../SimScripts/"$SIMFILE"_FuncSim.prj file."
  xvhdl --relax --prj ../SimScripts/"$SIMFILE"_FuncSim.prj 2>&1
  cd ../SimScripts
}
#-------------------------------------------------------------------------------------------------
#- RUN_STEP: <elaborate>
#-  xelab [options] [libname.]unitname...
#-  Common options:
#-    --standalone [-a]     : Generates a standalone non-interactive simulation executable that
#-                          :  performs run-all.
#-    --define [-d]         : Define Verilog macros. Use -d|--define for each Verilog macro. The
#                           :  format of the macro is <name>[=<val>] where <name> is name of the
#                           :  macro and <value> is an optional value of the macro
#-    --debug               : Compile with specified HDL debugging ability turned on. Choices are:
#-                          :  line    : HDL breakpoint
#-                          :  wave    : waveform generation, conditional execution, force value
#-                          :  drivers : signal driver value probing
#-                          :  readers : signal reader (load) probing
#-                          :  xlibs   : visibility into libraries precompiled by xilinx
#-                          :  all     : all the above
#-                          :  typical : line, wave and drivers
#-                          :  subprogram: subprogram variable value probing
#-                          :  off     : turn off all debugging abilities
#-                          :  (Default  : off)
#-    --file [-f]           : Read additional options from the specified file
#-    --help [-h]           : Print this help message
#-    --incr                : Enable incremental parsing and compilation check point
#-    --include [-i]        : Specify directories to be searched for files included using Verilog
#-                          :  `include. Use -i|--include for each specified search directory
#-    --initfile            : Use user defined simulator init file to add to or override the
#-                          :  settings provided by the default xsim.ini file
#-    --log                 : Specify the log file name. Default is <application name>.log
#-    --lib [-L]            : Specify search libraries for the instantiated design units in
#-                          :  a Verilog or Mixed language design. Use -L|--lib for each search
#-                          :  library. The format of the argument is <name>[=<dir>] where <name>
#-                          :  is the logical name of the library and <dir> is an optional physical
#-                          :  directory of the library
#-    --nolog               : Suppress log file generation
#-    --override_timeunit   : Override timeunit for all Verilog modules, with the specified time
#-                          :  unit in -timescale option
#-    --prj                 : Specify Vivado Simulator  project file containing one or more entries
#-                          :  of 'vhdl|verilog <work lib> <HDL file name>'
#-    --rrun [-r]           : Run the generated executable
#-    --relax               : Relax strict HDL language checking rules
#-    --runall [-R]         : Run the generated executable till end of simulation (xsim -runall)
#-    --snapshot [-s]       : Specify the name of design snapshot
#-    --timescale           : Specify default timescale for Verilog modules( Default: 1ns/1ps )
#-    --version             : Print the compiler version
#-    --verbose [-v]        : Specify verbosity level for printing messages.
#-                          :  Allowed values are: 0, 1, 2 (Default:0)
#-    --uvm_version         : Specify the uvm version(default: 1.2)
#-
#-  Advanced Options:
#-    --93_mode                       : Force usage of VHDL-93 mode for STD and IEEE libraries.
#-                                    :  Default is mixed 93 and 2008. If used, should be used for
#-                                    :  all VHDL files for the specific project
#-    --driver_display_limit          : Set the maximum number of elements a signal may contain for
#-                                    : driver information to be recorded for the signal (Default:
#-                                    :  arg = 65536 elements)
#-    --generic_top                   : Override generic or parameter of a top level design unit
#-                                    :  with specified value( Example: -generic_top "P1=10"
#-    --ignore_assertions             : Ignore System Verilog Concurrent Assertions
#-    --report_assertion_pass         : Report System Verilog Concurrent Assertions Pass, even if
#-                                    :  there is no pass action block
#-    --ignore_coverage               : Ignore System Verilog Functional Coverage
#-    --maxarraysize                  : Set the maximum VHDL array size, beyond which an array
#-                                    :  declaration will generate an error, to be 2**arg elements
#-                                    :  (Default: arg = 28, which is 2**28 elements)
#-    --mt                            : Specifies the number of sub-compilation jobs which can be
#-                                    :  run in parallel. Choices are:
#-                                    :    auto: automatic
#-                                    :    n: where n is an integer greater than 1
#-                                    :    off: turn off multi-threading
#-                                    :  (Default:auto)
#-    --maxdesigndepth                : Override maximum design hierarchy depth allowed by the
#-                                    :  elaborator (Default: 5000)
#-    --noname_unnamed_generate       : Generate name for an unnamed generate block
#-    --nosignalhandlers              : Run with no XSim specific signal handlers. Necessary when
#-                                    :  3rd party software such as antivirus, firewall is generating
#-                                    :  signals as part of its normal usage, causing XSim Compiler
#-                                    :  and Kernel executables to trap these signals and report a crash.
#-    --override_timeprecision        : Override time precision for all Verilog modules, with the
#-                                    :  specified time precision in -timescale option
#-    --rangecheck                    : Enable runtime value range check for VHDL
#-    --sourcelibdir                  : Directory for Verilog source files of uncompiled modules.
#-                                    :  Use -sourcelibdir|--sourcelibdir <dirname> for each source directory.
#-    --sourcelibext                  : File extension for Verilog source files of uncompiled modules.
#-                                    :  Use -sourcelibext|--sourcelibext <file extension> for source
#-                                    :  file extension.
#-    --sourcelibfile                 : Filename of a Verilog source file which has uncompiled modules.
#-                                    :  Use -sourcelibfile|--sourcelibfile <filename>.
#-    --stats                         : Print tool CPU and memory usages, and design statistics
#-    --timeprecision_vhdl            : Specify time precision for vhdl designs(Default: 1ps)
#-    --transform_timing_checkers     : Transform timing checkers to Verilog processes
#-    --enable_unconstrained_element  : Enable unconstrained element in array and record for VHDL-2008
#-
#-  Timing Simulation:
#-      --maxdelay                     : Compile Verilog design units with maximum delays
#-      --mindelay                     : Compile Verilog design units with minimum delays
#-      --nosdfinterconnectdelays      : Ignore SDF port and interconnect delay constructs in SDF
#-      --nospecify                    : Ignore Verilog path delays and timing checks
#-      --notimingchecks               : Ignore timing check constructs in Verilog specify block(s)
#-      --pulse_int_e                  : Interconnect pulse error limit as percentage of delay.
#-                                     :  Allowed values are 0 to 100 (Default: 100)
#-      --pulse_int_r                  : Interconnect pulse reject limit as percentage of delay.
#-                                     :  Allowed values are 0 to 100 (Default: 100)
#-      --pulse_e                      : Path pulse error limit as percentage of path delay.
#-                                     :  Allowed values are 0 to 100 (Default: 100)
#-      --pulse_r                      : Path pulse reject limit as percentage of path delay.
#-                                     :  Allowed values are 0 to 100 (Default: 100)
#-      --pulse_e_style                : Specify when error about pulse being shorter than module
#-                                     :  path delay should be handled.
#-                                     :  Choices are:
#-                                     :    ondetect: report error right when violation is detected
#-                                     :    onevent:  report error after the module path delay
#-                                     :  (Default: onevent)
#-      --sdfmax                       : <root=file> Sdf annotate <file> at <root> with maximum delay
#-      --sdfmin                       : <root=file> Sdf annotate <file> at <root> with minimum delay
#-      --sdfnoerror                   : Treat errors found in sdf file as warning
#-      --sdfnowarn                    : Do not emit sdf warnings
#-      --sdfroot                      : <root_path> Default design hierarchy at which sdf annotation
#-                                     :  is applied
#-      --sdftyp                       : <root=file> Sdf annotate <file> at <root> with typical delay
#-      --transport_int_delays         : Use transport model for interconnect delays
#-      --typdelay                     : Compile Verilog design units with typical delays (Default)
#-
#-  Optimization:
#-      --O0                : Disable all optimizations
#-      --O1                : Enable basic optimizations
#-      --O2                : Enable most commonly desired optimizations (Default)
#-      --O3                : Enable advance optimizations
#-
#-  Mixed Language:
#-      --dup_entity_as_module : Enable support for hierarchical references inside the Verilog
#-                             :  hierarchy in mixed language designs. Warning: this may cause
#-                             :  significant slow down of compilation
#-:
#-  SystemC/DPI options:
#-      --dpi_absolute         : Use absolute paths instead of LD_LIBRARY_PATH on Linux for DPI
#-                             :  libraries that are formatted as lib<libname>.so
#-      --dpiheader            : Header filename for the exported and imported functions.
#-      --dpi_stacksize        : User-defined stack size for DPI tasks
#-      --sc_lib               : Shared library name for SystemC functions; (.dll/.so) without
#-                             :  the file extension
#-      --sv_lib               : Shared library name for DPI imported functions; (.dll/.so) without
#-                             :  the file extension
#-      --sv_liblist           : Bootstrap file pointing to DPI shared libraries.
#-      --sc_root              : Root directory off which SystemC libraries are to be found.
#-                             :  Default: <current_directory>/xsim.dir/work/xsc
#-      --sv_root              : Root directory off which DPI libraries are to be found.
#-                             :  Default: <current_directory>/xsim.dir/work/xsc
#-
#-  Coverage options:
#-      --cov_db_dir           : Functional Coverage database dump directory. The coverage data will
#-                             :  be present under <arg>/xsim.covdb/<cov_db_name> directory. Default is ./
#-      --cov_db_name          : Functional Coverage database name. The coverage data will be present
#-                             :  under <cov_db_dir>/xsim.covdb/<arg> directory. Default is snapshot name.
#-
elaborate()
{
  cd ../Simulation
  xelab --incr --relax --debug typical --lib UsedLibs --snapshot "$SIMFILE"_FuncSim --mt auto work."$SIMFILE"_Testbench
  cd ../SimScripts
}
#-------------------------------------------------------------------------------------------------
#- RUN_STEP: <simulate>
#   xsim [options] snapshot
#   --R                   : Run simulation till end i.e. do 'run all;quit'
#   --cov_db_dir          : Functional Coverage database dump directory. The coverage data
#                         :  will be present under <arg>/xsim.covdb/<cov_db_name> directory.
#                         :  Default is ./ or inherits value set in xelab.
#   --cov_db_name         : Functional Coverage database name. The coverage data will be present
#                         :  under <cov_db_dir>/xsim.covdb/<arg> directory. Default is snapshot
#                         :  name or inherits value set in xelab.
#   --downgrade_error2info    : Downgrade severity level of HDL messages from Error to Info.
#   --downgrade_error2warning : Downgrade severity level of HDL messages from Error to Warning.
#   --downgrade_fatal2info    : Downgrade severity level of HDL messages from Fatal to Info.
#   --downgrade_fatal2warning : Downgrade severity level of HDL messages from Fatal to Warning.
#   --downgrade_severity  : Downgrade severity level of HDL messages. Choices are:
#                         :  error2warning|error2info|fatal2warning|fatal2info
#   --file [--f]          : Take command line options from a file
#   --gui [--g]           : Run with interactive GUI
#   --help [--h]          : Print help message and exit
#   --ieeewarnings        : Enable warnings from VHDL IEEE functions
#   --ignore_assertions   : Ignore System Verilog Concurrent Assertions.
#   --ignore_coverage     : Ignore System Verilog Functional Coverage.
#   --ignore_feature      : Ignore effect of specific HDL feature or construct. Choices are:
#                         :  assertion
#   --log                 : Specify the log file name
#   --maxdeltaid          : Specify the maximum delta number. Will report error if it exceeds
#                         :  maximum simulation loops at the same time
#   --maxlogsize          : Set the maximum size a log file can reach in MB. The default
#                         :  setting is unlimited
#   --nolog               : Suppress log file generation
#   --nosignalhandlers    : Run with no signal handlers to avoid conflict with security software.
#   --onerror             : Specify behavior upon simulation run-time error: quit|stop
#   --onfinish            : Specify behavior at end of simulation: quit|stop
#   --protoinst           : Specify a .protoinst file for protocol analysis
#   --runall              : Run simulation till end i.e. do 'run all;quit'
#   --stats               : Display memory and cpu stats upon exiting
#   --sv_seed             : seed for sv constraint random
#   --tclbatch [-t]       : Specify the TCL file for batch mode execution
#   --tempDir             : Specify the temporary directory name
#   --testplusarg         : Specify plus args to be used by $test$plusargs and $value$plusargs
#                         :  system functions
#   --tl                  : Enable printing of file name and line number of statements being
#                         :  executed.
#   --tp                  : Enable printing of hierarchical names of process being executed.
#   --version             : Print the simulator version and quit.
#   --view                : Open a wave configuration file. This switch should be used together
#                         :  with -gui switch
#   --wdb                 : Specify the waveform database output file.
#
simulate()
{
  cd ../Simulation
  xsim "$SIMFILE"_FuncSim -gui --tclbatch ../SimScripts/"$SIMFILE"_FuncSim.tcl -view "$SIMFILE"_FuncSim.wcfg -log xsim.log &
  cd ../SimScripts
}
#-------------------------------------------------------------------------------------------------
#- RUN STEP: <xcgr_report>
#- Create a functional coverage report
#-  xcrg [options]
#-  --db_name arg         : Name of the database inside xsim.covdb. If unspecified all databases
#-                        :  present in the dir will be used
#-  --dir arg             : Path where the xsim.covdb database directory . Default is ./xsim.covdb
#-  --file arg            : Specify file with location[s] of Coverage Databases to be restored.
#-  --h                   : Print help message and exit
#-  --help                : Print help message and exit
#-  --log arg             : Specify name of file where log will be saved. Default is xcrg.log
#-  --merge_db_name arg   : Name of the merged database. Default is xcrg_mdb
#-  --merge_dir arg       : Directory where the merged database will be saved. Default is ./xsim.covdb
#-  --nolog               : Supress log File generation
#-  --report_dir arg      : Directory where the coverage database & report has to be saved.
#-                        :  Default is ./xcrg_report
#-  --report_format arg   : Specify desired format of Coverage report html|text|all. Default is html
#
xcrg_report()
{
  cd ../Simulation
  xcrg -report_format html -report_dir ./XcrgReport -file
  cd ../SimScripts
}
#-------------------------------------------------------------------------------------------------
#- RUN_STEP: <reset_run>
#- Delete generated data from the previous run
reset_run()
{
  if ls ../Simulation/*.log 1> /dev/null 2>&1; then
    rm -rf ../Simulation/*.log
  fi
  #
  if ls ../Simulation/*.jou 1> /dev/null 2>&1; then
    rm -rf ../Simulation/*.jou
  fi
  #
    if ls ../Simulation/*.pb 1> /dev/null 2>&1; then
    rm -rf ../Simulation/*.pb
  fi
  #
    if ls ../Simulation/*.wdb 1> /dev/null 2>&1; then
    rm -rf ../Simulation/*.wdb
  fi
  #
    if ls ../Simulation/*.str 1> /dev/null 2>&1; then
    rm -rf ../Simulation/*.str
  fi
  #
  if [ -d "../Simulation/xsim.dir" ]; then
    rm -rf ../Simulation/xsim.dir
  fi
}
#=================================================================================================
#- Check command line arguments.
#- Arrive here from the above 'run' command, when done, return.
check_args()
{
  if [[ ( $1 != "--compile"   &&
          $1 != "--elaborate" &&
          $1 != "--simulate"  &&
          $1 != "--all"       &&
          $1 != "--xcrg_report" &&
          $1 != "--reset_run" &&
          $1 != "--help"
          ) ]]; then
    echo -e "ERROR: Unknown option specified for "$SIMFILE"_FuncSim.sh"
    echo -e " Run "$SIMFILE"_FuncSim.sh --help for all possible options\n"
    exit 1
  fi
}
#=================================================================================================
#- Script Help. Display in the terminal some on-screen help information.
usage()
{
  echo -e " \n"
  echo -e " Usage: "$SIMFILE"_FuncSim.sh [--help] "
  echo -e "       -- Display help information for this script in the terminal. "
  echo -e " Usage: "$SIMFILE"_FuncSim.sh [--compile] "
  echo -e "       -- Compile only of the design files to simulate."
  echo -e " Usage: "$SIMFILE"_FuncSim.sh [--elaborate] "
  echo -e "       -- Elaborate only the result of the compile step."
  echo -e " Usage: "$SIMFILE"_FuncSim.sh [--simulate] "
  echo -e "       -- Simulate the with eleaborate created snapshot of the design."
  echo -e " Usage: "$SIMFILE"_FuncSim.sh [--all] "
  echo -e "       -- run compile, elaborate and simulate."
  echo -e " Usage: "$SIMFILE"_FuncSim.sh [--xcrg_report] "
  echo -e "       -- create a functional coverage report."
  echo -e " Usage: "$SIMFILE"_FuncSim.sh [--reset_run] "
  echo -e "       -- Remove generated files from the previous run and set everything up for a clean new run. \n"
  exit 1
}
#=================================================================================================
#- Launch script
#- when terminal command "" is entered the script starts here and then invokes the 'run' command above.
run $1
#-------------------------------------------------------------------------------------------------
#-
