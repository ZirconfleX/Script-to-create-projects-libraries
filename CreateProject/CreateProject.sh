#!/bin/bash
#
# This script creates all files and folders for a Xilinx-Vivado project, using VHDL
# as the programming language. The created project contains all files and folders to let
# one develop all necessary files for the project, simulate it, synthesize it and implement
# it using Vivado, Petalinux, Pynq and/or Vitis.
#
#=========================================================================================
#
#=========================================================================================
# Variable definitions of variable used in the script.
#=========================================================================================
UsersHome=~
ScrptUser="${USER^}"
ScrptSrc="${BASH_SOURCE[0]}"
CrrntDrctry=$(cd `dirname %0` && pwd)
PrjMngrInstlPath=~/.config/Code/User/globalStorage/alefragnani.project-manager
PrjMngrJsonFile=~/.config/Code/User/globalStorage/alefragnani.project-manager/projects.json
#
#=========================================================================================
# Ask to exit the script.
#=========================================================================================
ExitOrStay() {
    read -e -p " Are you sure you want to exit the script? : (y/n) : " ExitStay
    if [ "${ExitStay,,}" == "y" ]; then
        echo " Exiting ..........."
        sleep 1
        exit
    else
        return 1
    fi
}
#=========================================================================================
# Determine the location of the script.
#=========================================================================================
GetScriptDir() {
    # While $ScrptSrc is a symlink, resolve it
    while [ -h "$ScrptSrc" ]; do
        ScrptDrctry="$( cd -P "$( dirname "$ScrptSrc" )" && pwd )"
        ScrptSrc="$( readlink "$ScrptSrc" )"
            # If $ScrptSrc was a relative symlink (so no "/" as prefix,
            # need to resolve it relative to the symlink base directory
        [[ $ScrptSrc != /* ]] && ScrptSrc="$ScrptDrctry/$ScrptSrc"
    done
    ScrptDrctry="$( cd -P "$( dirname "$ScrptSrc" )" && pwd )"
}
#
#=========================================================================================
# Store in variables : Day, Month and Year
#=========================================================================================
SetDate() {
    CurrDay=$(date +'%d')
    CurrMonth=$(date +'%b')
    CurrYear=$(date +"%Y")
}
#
#=========================================================================================
# Find out what needs to be created, a new project or a new library.
#=========================================================================================
GenProjOrLib() {
    echo       " For the good order:                                                          "
    echo       " Single character answers are case insensitive (y/n can also be Y/N).         "
    echo       " All other answers are case sensitive (Author, Project , ...).                "
    echo       "=============================================================================="
    echo       " This script needs GIT! Most likely GIT is already installed, but to be sure  "
    echo       " it is, type \"git --version\" in a command terminal window. If something     "
    echo       " like \"git version 2.46.0\" is reported, GIT is installed                    "
    echo       " If nothing is reported, GIT needs to be installed                            "
    echo       "    On Ubuntu or Linux Mint, type \"sudo apt install git\"                    "
    echo       "    On Arch Linux or Manjaro, type \"sudo pacman -S git\"                     "
    echo       " Configure GIT                                                                "
    echo       "    git config --global user.name \"Your Name\"                               "
    echo       "    git config --global user.email \"youremail@example.com\"                  "
    echo       "=============================================================================="
    echo       " REMARK:                                                                      "
    echo       "    At any moment the script can be left by hitting [CTRL]-[C].               "
    echo       "=============================================================================="
    echo       " What needs to be created?                                                    "
    read -e -p "  a project(p) or a library(l)   .  .  .  .  .  .  .  .  .  .  .  .  .  .   : " ProjLib
    #
    if [ "${ProjLib,,}" == "p" ]; then
        ProjOrLib=Proj
        return
    elif [ "${ProjLib,,}" == "l" ]; then
        ProjOrLib=Lib
        return
    else
        echo " Probably wrong answer given! "
        GenProjOrLib
    fi
}
# End of GenProjOrLib
#
#=========================================================================================
# Ask were the project or library needs to be created.
# ProjectRootPath   : Path where the new project will be created as sub-directory
#=========================================================================================
AskProjPathInfo() {
    echo       "=============================================================================="
    read -e -p " Is $CrrntDrctry, the path to create the new project (y/n)? : " YesNo
    echo       "=============================================================================="
    if [ "${YesNo,,}" == "y" ]; then
        ProjectRootPath=$CrrntDrctry
        return
    elif [ "${YesNo,,}" == "n" ]; then
        echo " Provide the path to the directory where the new project needs to be created. "
        echo " The new project is created as a sub-directory in the given path              "
        echo " Use the \"tab\" for auto-complete commands, files, or directories.           "
        echo " DO NOT USE '-' or SPACES in directory names or file names!                   "
        echo " DO NOT END THE PATH WITH A \" / \"!                                          "
        echo " Use absolute paths                                                           "
        read -e -p " : " ProjectRootPath
        # Check if the directory already exist.
        # If it exist ask again, else set the variable.
            if [ -d $ProjectRootPath ]; then
                echo    "                                                                              "
                echo    " Directory, $ProjectRootPath, already exists!                                 "
                read -e -p " Use(u) the given path or change(c) the path name (u/c)?  .  .  .  .  .  : " UsChng
                if [ "${UsChng,,}" == "u" ]; then
                    echo " New project will be created as directory in:  $ProjectRootPath              "
                    return
                elif [ "${UsChng,,}" == "c" ]; then
                    AskProjPathInfo
                fi
            else
                echo       "                                                                              "
                read -e -p " Given path does not exist. Sure about the name (y/n)?  .  .  .  .  .  .  . : " PrjPathOk
                if [ "${PrjPathOk,,}" == "y" ]; then
                    echo " Creating the directory $ProjectRootPath now!                                       "
                    mkdir $ProjectRootPath
                
                    return
                else 
                    AskProjPathInfo
                fi
            fi
    else
        echo " Please answer with y/n "
        AskProjPathInfo
    fi
}
# end of AskProjPathInfo
#
AskLibPathInfo() {
    echo       "=============================================================================="
    echo       " Libraries reside in the project's 'libraries' directory and can be simple    "
    echo       " set of sub-directories for HDL and simulation or can take the format of a    "
    echo       " complete project                                                             "  
    echo       " Provide the path to the root directory of a project and indicate the type of "
    echo       " library required:                                                            "
    echo       "    project (p) : Library is setup as if it's a project                       "
    echo       "    simple (s)  : Library contains only a basic set of directories.           "
    echo       "                                                                              "
    echo       " Use the \"tab\" for auto-complete commands, files, or directories.           "
    echo       " DO NOT USE '-' or SPACES in directory names or file names!                   "
    echo       " DO NOT END THE PATH WITH A \" / \"!                                          "
    echo       " Use the absolute path to the project directory for the new library.          "
    echo       "=============================================================================="
    read -e -p " Path to project were library needs created  .  .  .  .  .  .  .  .: " ProjectPath
    read -e -p " Library type: (p/s)?  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .    : " LibType
    if [ -d $ProjectPath ]; then
        if [ -d $ProjectPath/Libraries ]; then
            echo   "                                                                              "
            echo   " A \"Libraries\" directory is available in given project path.                "
            LibraryRootPath=$ProjectPath/Libraries
            echo   " A library can be created in: $LibraryRootPath                                "
            return
        else
            echo "                                                                               "
            echo " Directory 'Libraries' is not available in '$ProjectPath'!                     "
            echo " A 'Libraries' directory is created now                                        "
            mkdir $ProjectPath/Libraries
            LibraryRootPath=$ProjectPath/Libraries
            return
        fi
    else 
        echo "                                                                              "
        echo " The provided '$ProjectPath' path does not exist!                             "
        echo " Provide the path to an existing project!                                     "
        AskLibPathInfo
    fi
}
# End of AskLibPathInfo
#
#=========================================================================================
# Ask the project or library name
# ProjectName   : Project directory under the ProjectRootPath
#               : A new library is created in the Libraries directory of a project.
#               : For a new library ProjectRootPath and ProjectName exist, this new Library
#               : can easily be created in the existing Libraries folder.
# LibraryName   : Name of the new library to create in the Libraries directory.
#               : "_Lib" will be add to the given library name.                        
#=========================================================================================
AskPrjName() {
    echo       "=============================================================================="
    read -e -p " Provide the name of the new project to create!  .  .  : " ProjectName
    echo       "=============================================================================="
    FullProjectPath=$ProjectRootPath/$ProjectName
    echo " Checking if the project already exist in the provided path.   "
    if [ -d $FullProjectPath ]; then
        echo    " Project already exist in the provided path.                                     "
        echo    " Enter a new project name to create as directory under the given path            "
        echo    " or create a whole new project path.                                             "
        read -e -p " Enter a New Project Name (npn) or enter a New Project Path (npp)  .  .  .  .  : " NewP
        if [ "${NewP,,}" == "npn" ]; then
            AskPrjName
        elif [ "${NewP,,}" == "npp" ]; then
            AskProjPathInfo
        else
            echo " Wrong answer, restarting. "
            AskPrjName
        fi
    else
        echo " The project does not exist in the provided path.                                "
        echo " The project:                                                                    "
        echo "         "$ProjectName"                                                          "
        echo " is going to be created as directory in:                                         "
        echo "         "$ProjectRootPath"                                                      "
        mkdir $ProjectRootPath/$ProjectName
        return
    fi
}
# End of AskProjName
#
AskLibName() {
    echo       "=============================================================================="
    echo       " What is the name of the library that needs to be created?                    "
    echo       " REMARK: The entered name will automatically be extended with '_Lib'          "
    echo       "=============================================================================="
    read -e -p " : " BareLibraryName
    LibraryName=$BareLibraryName"_Lib"
    echo       " A library, $LibraryName, will be created in $LibraryRootPath                 "
    FulLibraryPath=$LibraryRootPath/$LibraryName
    echo       " Checking if the library already exist in the given project/Libraries path.   "
    if [ -d FulLibraryPath ]; then
        echo       " Library already exist!                                                       "
        echo       " Change the library name or set a new library path.                           "
        echo       " Enter \"nln\" to go back and enter a new Library Name                        "
        read -e -p " or enter \"nlp\" to go back and enter a new library path  .  .  .  .  .  . : " newl
        if [ "${NewL,,}" == "nln" ]; then
            AskLibName
        elif [ "${NewP,,}" == "nlp" ]; then
            AskLibPathInfo
        else
            echo " Wrong answer, restarting from start. "
            GenProjOrLib
        fi
    else
        echo " A new library, $LibraryName, will created in $LibraryRootPath "
        # Make a directory
        #   ProjectPath     ==> LibraryRootPath=ProjectPath/Libraries
        #   BareLibraryName ==> LibraryName=BareLibraryName_Lib
        #   FullLibraryName=LibraryRootPath/LibraryName
        mkdir $FulLibraryPath
        return
    fi
}
# End of AskLibName
#
#=========================================================================================
# Information to replace keywords in template files.
# When arriving here we already have following information:
# global:
#   ScrptDrctry
#   CrrntDrctry
# For a Project:
#   ProjectRootPath
#   ProjectName
# For a Library:
#   ProjectPath
#   LibraryPath
#   LibraryName
# Below are the variables from the script and their replacement keywords in project and/or library file headers.
# File headers have variables that can be used by text editors and other text related tools. WHen the file 
# header is add to the file the text variables are replaced by the script variables.
#  Script      :   text
# FpgaFamily   : ${FAMILY}          Used FPGA family or families for this project.
# TopLevelName : ${FILE_NAME}       Name of the VHDL top level file.
# SimulVer     : $[SIM_TOOL]        Simulator and version.
# Author       : ${AUTHOR}          The one who does the work.
# Vendor       : ${VENDOR}          The company the author works for.
# Date         : ${DATE}            of creating and first use, taken from PC date.
# Year         : ${YEAR}            for file legal headers, taken from PC date.
# Vivado       : ${VivadoVer}       Vivado and version.
# These are script variables.
# Petalinux    : When Petalinux is going to be used, create a Petalinux directory.
# Pynq         : When PYNQ isd going to be used, create a Pynq directory.
# Vitis        : When Vitis is going to be used, create a Vitis directory.
# Editor       ; Is the VS-Code editor used? 
#=========================================================================================
AskProjInfo() {
    echo       "================================================================================="
    echo       " Gathering Required Project Information                                          "
    echo       "                                                                                 "
    echo       " Remark:                                                                         "
    echo       "    The user of the script is responsible for the correct installation and       "
    echo       "    environment setting of all AMD/Xilinx tools (Vivado, Vitis, Petalinx, ...)!  "
    echo       "                                                                                 " 
    read -e -p " Name (without extension) of the top level design file (VHDL/verilog)?  .  .   : " TopLevelName
    read -e -p " Name of company/vendor creating this Project/Library?  .  .  .  .  .  .  .  . : " Vendor
    echo       " What is the target FPGA family for this project?                                "
    echo       " Use , to separate different FPGA families used in the project                   "
    read -e -p " Example: Zynq 7000, Ultrascale, Ultrascale+, Zynq-Ultrasacle+  .  .  .  .  .  : " FpgaFamily
    read -e -p " Vivado version going to be used for the project  .  .  .  .  .  .  .  .  .  . : " VivadoVer
    read -e -p " Used Simulator and its version (ex: QuestaSim_10.7)  .  .  .  .  .  .  .  .   : " SimulVer
    return
}
#
# Ask if PetaLinux is going to be used
#=========================================================================================
AskPetaLinux() {
    read -e -p " Is PetaLinux going to be used?  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .   : " PetaLnxUsed
    if [ "${PetaLnxUsed,,}" == "y" ] || [ "${PetaLnxUsed,,}" == "n" ]; then
        return
    else # Answer is not yes nor no.  
        echo " Please answer 'y' or 'n' "
        AskPetaLinux
    fi
}
# End of AskPetaLinux
#
# Ask if Pynq is going to be used
#=========================================================================================
AskPynq() {
    echo    " Is Pynq going to be used?                                                       "
    echo    "     Answering yes (y) will automatically clone the latest version               "
    echo    "     of PYNQ from the Xilinx Pynq GitHub page.                                   "
    echo    "     Find the official PYNQ webpage here http://www.pynq.io/                     "
    read -e -p "     Find the PYNQ documentation here http://pynq.readthedocs.io/  .  .  .  .  : " PynqUsed
    if [ "${PynqUsed,,}" == "y" ] || [ "${PynqUsed,,}" == "n" ]; then
        return
    else # Answer is not yes nor no.  
        echo " Please answer 'y' or 'n' "
        AskPynq
    fi
}
# End of AskPynq
#
# Ask if Vitis is going to be used
#=========================================================================================
AskVitis() {
    read -e -p " Is Vitis going to be used?  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  . .  : " VitisUsed
    if [ "${VitisUsed,,}" == "y" ] || [ "${VitisUsed,,}" == "n" ]; then
        return
    else # Answer is not yes nor no.  
        echo " Please answer 'y' or 'n' "
        AskVitis
    fi
}
# End of AskVitis
#
# Ask the the authors name to be able to complete the legal file headers.
# If the person completing this script is also going to be the author of the development,
# (answer = "y") set the known name as author reference. If the person completing this 
# script is doing it for somebody else (answer = "n") another name need to be used.
#=========================================================================================
AskScriptUser () {
    read -e -p " Is the project structure created for the person running this script? (y/n)  . : " YesNoUsr
    #
    if [ "${YesNoUsr,,}" == "y" ]; then
        read -e -p " Use $ScrptUser, as author reference in all file headers? (y/n)  .  .  .   : " UsrRef
        if [ "${UsrRef,,}" == y ]; then
            Author=$ScrptUser
            return
        elif [ "${UsrRef,,}" == n ]; then
            read -e -p " Provide the author reference for all file headers?  .  .  .  .  .  .  .  .  . : " Author
            return
        else # Answer is not yes nor no.  
            echo " Please answer 'y' or 'n' "
            AskScriptUser
        fi       
    elif [ "${YesNoUsr,,}" == "n" ]; then
        read -e -p " Provide the author reference for all file headers?  .  .  .  .  .  .  .  .  . : " Author
        return
    else # Answer is not yes nor no.  
        echo " Please answer 'y' or 'n' "
        AskScriptUser
    fi
}
# End of AskScriptUser
#
# Info gathering about the use of VS Code editor/IDE.
# Ask if VS-Code editor/IDE is used as development tool for coding.
# and ask if the project needs to be add to an existing project workspace?
#=========================================================================================
AskCodeWrkspce () {
    echo    "                                                                                 "
    read -e -p " Is the VS-Code editor used as development tool for the project? (y/n)  .  .   : " Editor
    read -e -p " Append or add the project to a editor workspace and/or project? (y/n)  .  .   : " Wrkspce
    #
    if [ "${Editor,,}" == "y" ]; then
        if [ "${Wrkspce,,}" == "y" ]; then
            echo          " To append the project to an existing code workspace file answer yes(y)          "
            read -e -p    " To create a local project code workspace file answer no(n)  .  .  .  .  .  .  : " AppAdd
            if [ "${AppAdd,,}" == "y" ]; then
                echo       " Provide the path to an existing code workspace file!                         "
                echo       " Use the \"tab\" for auto-complete commands, files, or directories.           "
                echo       " DO NOT USE '-' or SPACES in directory or file names!                         "
                echo       " DO NOT END THE PATH WITH A \" / \"!                                          "
                echo       " DO NOT USE ~ to indicate the users home directory. Use the real path instead "
                echo       " Example: /home/<user>/path/to/project                                        "
                read -e -p " : " WrkspcePath
                echo       " '$WrkspcePath' "
                # Check is the given path does exist
                if [ -d $WrkspcePath ]; then 
                    echo       " Directory exist!                                                              "
                    read -e -p " Provide the name of the code workspace file without extension  .  .  .  .   : " WrkspceFileName
                    if [ -f $WrkspcePath/$WrkspceFileName".code-workspace" ]; then
                        echo " A .code-workspace file is present in the provided directory.                    "
                        return
                    else
                        echo " NO .code-workspace file present in given path                                   "
                        AskCodeWrkspce
                    fi
                else
                    echo " The provided directory does not exist!                                           "
                    AskCodeWrkspce
                fi
            elif [ "${AppAdd,,}" == "n" ]; then    
                echo    "                                                                                 "
                echo    " A code workspace file will be created in project root directory of the project  "
                echo    " NOTE THAT:                                                                      "
                echo    "     The project root directory is the directory above the project directory.    "
                WrkspcePath=$ProjectRootPath
                WrkspceFileName=$ProjectName
                return
            else # Answer is something else than y or n
                echo " Please answer 'y' or 'n' "
                AskCodeWrkspce
            fi
        elif [ "${Wrkspce,,}" == "n" ]; then
            echo " User doesn't care about workspaces or projects!                                 "
            return
        else # Answer is something else than y or n
            echo " Please answer 'y' or 'n' "
            AskCodeWrkspce
        fi       
    elif [ "${Editor,,}" == "n" ]; then
        echo "                                                                              "
        echo " VS-Code editor is not used.                                                  "
        return
    else # Answer is something else than y or n
        echo " Please answer 'y' or 'n' "
        AskCodeWrkspce
    fi
}
# end of AskCodeWrkspce
#
#=========================================================================================
# Ask if the project needs to be add to the projects list of the Project Manager
# If a projects.json file is present set a variable to yes, else set the variable to no.
#=========================================================================================
AskCodeProjMngr () {
    echo       "                                                                                 "
    read -e -p    " Append the new project to the Project Manager project list? (y/n)  .  .  .  . : " ProjMngr
    echo          "================================================================================="
    if [ "${ProjMngr,,}" == "y" ]; then
        # Check if the project manager extension is installed in Vs-Code
        if [ -d $PrjMngrInstlPath ]; then 
            echo " The Project Manager extension for VS-Code is installed.                         "
            echo " Checking if there is already a projects.json file                               "
            echo " if file doesn't exist, one is automatically created.                            "
            if [ -f $PrjMngrJsonFile ]; then
                PrjMngrJsonFilePrsnt=y
                echo " There is already a projects.json file present                                      "
                return
            else
                PrjMngrJsonFilePrsnt=n
                echo " There is no projects.json file in:                                                 "
                echo " Creating one now.                                                                  "
                touch $PrjMngrInstlPath/projects.json
                return
            fi
        elif [ ! -d $PrjMngrInstlPath ]; then 
            echo " Project Manager is not installed!                                               "
            echo " Install the Project Manager before using this selection                         "
            return
        fi
    elif [ "${ProjMngr,,}" == "n" ]; then
        echo " Project is not to be add to the Project Manager list of projects.                    "
        return
    else # Answer is something else than y or n
        echo " Please answer 'y' or 'n' "
        AskCodeProjMngr
    fi
}
# End of AskCodeProjMngr
#
#=========================================================================================
# Summarize the provided project data before creating the project
#=========================================================================================
SumProjData () {
    echo "                                                                                     "
    echo "====================================================================================="
    echo " Summary of gathered project information before creating the project:                "
    echo "                                                                                     "
    echo " This script is stored in:                                           $ScrptDrctry    "
    echo " The script is run from:                                             $CrrntDrctry    "
    if [ $ProjOrLib == Proj ]; then
        echo "     Creating a new project in:                                      $ProjectRootPath"
        echo "     The new project is called:                                      $ProjectName    "
        echo "     The full project path is then:                                  $FullProjectPath"    
    elif [ $ProjOrLib == Lib ]; then
        echo "     Creating a new libray in:                                       $LibraryPath    "
        echo "     The new library is going to be called                           $LibrayName     "
        echo "     The complete pathe to the library is:                           $FulLibraryPath "
    fi
    echo " The FPGA(s) used in this project are:                               $FpgaFamily     "
    echo " The top level VHDL file is:                                         $TopLevelName   "
    echo " The Vivado version used is:                                         $VivadoVer      "
    echo " The Simulator and version used is:                                  $SimulVer       "
    echo " If Petalinux is going to be used, a directory for the OS is created $PetaLnxUsed    "
    echo " If Pynq is going to be used, a directory for the tool is created    $PynqUsed       "
    echo " If Vitis is going to be used, a directory for the tool is created   $VitisUsed      "
    echo " The project or design author is:                                    $Author         "
    echo " The company/vendor creating the project or Library is:              $Vendor         "
    echo " Today is:                                                           $CurrDay $CurrMonth $CurrYear "
    echo " VS-Code editor used?                                                $Editor         "
    echo "     Workspace file is put in:                                       $WrkspcePath    "
    echo "     Workspace file name:                                            $WrkspceFileName".code-workspace" "
    echo "     Add to Project Manager                                          $ProjMngr       "
    echo "     A projects.json file is available or created                                    "
    echo "====================================================================================="
    read -e -p " Is the displayed information correct? (y/n) : " CorrInfo
    if [ "${CorrInfo,,}" == "y" ]; then
        return
    elif [ "${CorrInfo,,}" == "n" ]; then
        AskProjInfo
    else # Answer is not yes nor no.
        echo " Please answer 'y' or 'n' "
        SumProjData
    fi
}
# end of SumProjData
#
#=========================================================================================
# Create the project.
# Use the gathered information.
# When a project is created the gathered data will be stored in a hidden file in the
# root of the project. Data in that file can afterwards be used to create new libraries.
# the file gets the name of the project with extension .mdf
#=========================================================================================
CreateProj() {
    echo "================================================================================="
    echo " Create the project.                                                             "
    sleep 1
    cp -r $ScrptDrctry/Project_Name/* $ProjectRootPath/$ProjectName

    if [ "${PetaLnxUsed,,}" == "y" ]; then
        mkdir $ProjectRootPath/$ProjectName/Petalinux
    else # Answer is no
        echo " Petalinux is not going to be used. "
    fi
    if [ "${PynqUsed,,}" == "y" ]; then
        mkdir $ProjectRootPath/$ProjectName/Pynq
        cd $ProjectRootPath/$ProjectName/Pynq
        git clone --recursive https://github.com/Xilinx/PYNQ.git
        cd $CrrntDrctry
    else # Answer is no
        echo " Pynq is not going to be used. "
    fi
    if [ "${VitisUsed,,}" == "y" ]; then
        mkdir $ProjectRootPath/$ProjectName/Vitis
    else # Answer is no
        echo " Vitis is not going to be used. "
    fi

    echo " Add file headers to the basic template files. "
    sleep 1
    # XDC files
    find $FullProjectPath/* -type f -name '*.xdc' \
      -exec cp $ScrptDrctry/FileHeaders/XdcFileHeader.txt $FullProjectPath/file.txt \; \
      -exec cat {} >> $FullProjectPath/file.txt \; \
      -exec cp $FullProjectPath/file.txt {} \;
    rm $FullProjectPath/file.txt
    #
    # Simulation command files
    find $FullProjectPath/* -type f -name '*.prj' \
      -exec cp $ScrptDrctry/FileHeaders/SimCmndFileHeader.txt $FullProjectPath/file.txt \; \
      -exec cat {} >> $FullProjectPath/file.txt \; \
      -exec cp $FullProjectPath/file.txt {} \;
    rm $FullProjectPath/file.txt
    #
    find $FullProjectPath/* -type f -name '*.sh' \
      -exec cp $ScrptDrctry/FileHeaders/SimCmndFileHeader.txt $FullProjectPath/file.txt \; \
      -exec cat {} >> $FullProjectPath/file.txt \; \
      -exec cp $FullProjectPath/file.txt {} \;
    rm $FullProjectPath/file.txt
    #
    find $FullProjectPath/* -type f -name '*.tcl' \
      -exec cp $ScrptDrctry/FileHeaders/SimCmndFileHeader.txt $FullProjectPath/file.txt \; \
      -exec cat {} >> $FullProjectPath/file.txt \; \
      -exec cp $FullProjectPath/file.txt {} ';'
    rm $FullProjectPath/file.txt
    #
    # VHDL files
    find $FullProjectPath/* -type f -name '*.vhd' \
      -exec cp $ScrptDrctry/FileHeaders/VhdlFileHeader.txt $FullProjectPath/file.txt \; \
      -exec cat {} >> $FullProjectPath/file.txt \; \
      -exec cp $FullProjectPath/file.txt {} \;
    rm $FullProjectPath/file.txt
    #
    echo " Name the files. "
    sleep 1
    # Replace 'FileName-'by the name of the top level "TopLevelName_                "
    for file in $(find $ProjectRootPath/$ProjectName -type f -name 'FileName-*.*')
    do
       mv $file $(echo "$file" | sed -r "s|FileName-|$TopLevelName"_"|g")
    done
    #
    for file in $(find $ProjectRootPath/$ProjectName -type f -name 'FileName*.*')
    do
        mv $file $(echo "$file" | sed -r "s|FileName|$TopLevelName|g")
    done
    #
    for file in $(find $ProjectRootPath/$ProjectName -type f -name 'LibName-*.*')
    do
        mv $file $(echo "$file" | sed -r "s|LibName-|$TopLevelName"_"|g")
    done
    #
    for file in $(find $ProjectRootPath/$ProjectName -type f -name 'LibName*.*')
    do
        mv $file $(echo "$file" | sed -r "s|LibName|$TopLevelName|g")
    done
    #
    echo " Replace the keywords in all files of the created project.                "
    sleep 1
    grep -rl '${YEAR}' $ProjectRootPath/$ProjectName | xargs sed -i "s/\${YEAR}/$CurrYear/g"
    grep -rl '${FAMILY}' $ProjectRootPath/$ProjectName | xargs sed -i "s/\${FAMILY}/$FpgaFamily/g"
    grep -rl '${AUTHOR}' $ProjectRootPath/$ProjectName | xargs sed -i "s/\${AUTHOR}/$Author/g"
    grep -rl '${VENDOR}' $ProjectRootPath/$ProjectName | xargs sed -i "s/\${VENDOR}/$Vendor/g"
    grep -rl '${FILE_NAME}' $ProjectRootPath/$ProjectName | xargs sed -i "s/\${FILE_NAME}/$TopLevelName/g"
    grep -rl '${SIM_TOOL}' $ProjectRootPath/$ProjectName | xargs sed -i "s/\${SIM_TOOL}/$SimulVer/g"
    grep -rl '${VIVADO_TOOL}' $ProjectRootPath/$ProjectName | xargs sed -i "s/\${VIVADO_TOOL}/$VivadoVer/g"
    grep -rl '${DATE}' $ProjectRootPath/$ProjectName | xargs sed -i "s/\${DATE}/$CurrDay $CurrMonth $CurrYear/g"
    #
}
# End of CreateProj
#
#=========================================================================================
# When the VS-Code editor is used append the project to a existing workspace file
# Or create a local workspace file in the project root directory (directory above the
# project directory).
#=========================================================================================
ManipCodeWrkspce () {
    # Append the new workspace to an existing workspace file
    if [ "${AppAdd,,}" == "y" ]; then
        echo " Append the project to an existing .code-workspace file                          "
        # Path for the workspace file is : WrkspcePath
        # Workspace file name is: WrkspceFileName
        sed -i 's/}/},/g' $WrkspcePath/$WrkspceFileName".code-workspace"
        sed -i 's/},,/},/g' $WrkspcePath/$WrkspceFileName".code-workspace"
        sed -i 's/{},/{}/g' $WrkspcePath/$WrkspceFileName".code-workspace"
         # The lines above make sure the the last } in the existing file get a ,
        # so that a new project can be append to it.
        # Remove the last lines
        sed -i '/],/d' $WrkspcePath/$WrkspceFileName".code-workspace"
        sed -i '/"settings": {}/d' $WrkspcePath/$WrkspceFileName".code-workspace"
        sed -i '$d' $WrkspcePath/$WrkspceFileName".code-workspace"
#-----------------------------------------------------------------------------------------
# Text for the generated file must start at the begin of the line.
        cat >> $WrkspcePath/$WrkspceFileName".code-workspace" << EOL
		{
			"path": "$ProjectName"
		}
    ],
    "settings": {}
}
EOL
# Creation of the workspace file and contents is done here.
#-----------------------------------------------------------------------------------------
#
    # Create a local workspace file
    elif [ "${AppAdd,,}" == "n" ]; then
        echo " Create a new .code-workspace file in the root of the project directory       "
#-----------------------------------------------------------------------------------------
# Text for the generated file must start at the begin of the line.
        cat >> $WrkspcePath/$ProjectName".code-workspace" << EOL
{
    "folders": [
		{
			"path": "$ProjectName"
		}
    ],
    "settings": {}
}
EOL
# Creation of the workspace file and contents is done here.
#-----------------------------------------------------------------------------------------
    fi
    return
}
# End of ManipCodeWrkspce
#
#=========================================================================================
# When the project is add to a .code-workspace file append, or not, the project
# into the projects.json file of the installed Project Manager VS-code extension.
# Checking of the Project Manager extension is installed is already done and a 
# projects.json file, if it did not already exist, is created.
#
# ProjectName = Name of the project, wil be the main name of the .code-workspace file
# ProjectRootPath = Path to the directory above the ProjectName directory 
#=========================================================================================
ManipCodePrjMngr () {
# If a projects.json was present it is still there, if there was no projects.json file 
# one was created in an earlier function.
# There is thus always a projects.json file present when arriving here.
# It can be empty (new created) or it can be an existing file containing projects.
#
    if [ "${PrjMngrJsonFilePrsnt,,}" == "y" ]; then
        echo " Add project to a existing projects.json file "
        sed -i 's/}/},/' $PrjMngrJsonFile
        sed -i 's/},,/},/' $PrjMngrJsonFile
        sed -i '/]/d' $PrjMngrJsonFile
        # The first line replaces all (first occurence on a line) } characters. It is possible 
        # that there are already }, character and after the first replacement these become },,
        # The second line replaces the },, back into }, 
        # The last command deletes the ] line.
        # After these replacements the new project can safely be appended.
#-----------------------------------------------------------------------------------------
# Text for the generated file must start at the begin of the line.
        cat >> $PrjMngrJsonFile << EOL
	{
		"name": "$ProjectName",
		"rootPath": "$WrkspcePath/$ProjectName.code-workspace",
		"paths": [],
		"tags": [],
		"enabled": true
	}
]
EOL
# Creation of the workspace file and contents is done here.
#-----------------------------------------------------------------------------------------
    elif [ "${PrjMngrJsonFilePrsnt,,}" == "n" ]; then
        echo " Add project to a new projects.json file "
#-----------------------------------------------------------------------------------------
# Text for the generated file must start at the begin of the line.
        cat >> $PrjMngrJsonFile << EOL
[
	{
		"name": "$ProjectName",
		"rootPath": "$WrkspcePath/$ProjectName.code-workspace",
		"paths": [],
		"tags": [],
		"enabled": true
	}
]
EOL
# Creation of the workspace file and contents is done here.
#-----------------------------------------------------------------------------------------
    fi
}
# End of ManipCodePrjMngr
#
#=========================================================================================
# Writing a text file requires that the text lines to write start from the border
# of the document. Indenting the lines makes indenting the lines in the written
# text files and EOL MUST BE at character position 0.
#=========================================================================================
CreateProjFile () {
    echo " Create .mdf project file. "
    sleep 1
    cat > $ProjectRootPath/$ProjectName/.$ProjectName".mdf" << EOL
#=====================================================================
# This file is auto-generated by the CreateProject .bat/script file.
# Please do not delete or alter this file!
#=====================================================================
${ScrptDrctry}
${CrrntDrctry}
${ProjectRootPath}
${FpgaFamily}
${TopLevelName}
${VivadoVer}
${SimulVer}
${PetaLnxUsed}
${PynqUsed}
${VitisUsed}
${Author}
${Vendor}
${CurrDay} ${CurrMonth} ${CurrYear}
${Editor}
${WrkspcePath}
${ProjMngr}
EOL
}
# End of CreateProjFile
#
#=========================================================================================
# Check if there is a $Projectname.mdf file, generated when a project was created.
# if there is no such file in the project, ask all questions/gather data and write the file.
# At this point this is known for a Library:
#   ProjectPath
#   LibraryPath
#   LibraryName
# A check has already been done to see if there is 'Libraries' directory.
# If there wasn't the directory has been created.
#=========================================================================================
CheckProjFile() {
    # Check if .mdf file exists and load the contents.
    if [ -f $ProjectPath/.*.mdf ]; then
        MdfFile=$(find $ProjectPath -type f -name '*.mdf')
        echo "================================================================================="
        echo " There is a .mdf available.                                                      "
        echo "================================================================================="
        mapfile -t Lines < $MdfFile
        ScrptDrctry="${Lines[4]}"
        CrrntDrctry="${Lines[5]}"
        ProjectPath="${Lines[6]}"
        FpgaFamily="${Lines[7]}"
        TopLevelName="${Lines[8]}"
        VivadoVer="${Lines[9]}"
        SimulVer="${Lines[10]}"
        PetaLnxUsed="${Lines[11]}"
        PynqUsed="${Lines[12]}"
        VitisUsed="${Lines[13]}"
        Author="${Lines[14]}"
        Vendor="${Lines[15]}"
        CurrDate="${Lines[16]}"
        Editor="${Lines[17]}"
        WrkspcePath="${Lines[18]}"
        ProjMngr="${Lines[19]}"
    else
        # File does not exist.
        # Ask all necessary questions to make a library and change the keywords in the files.
        echo "================================================================================="
        echo " There is no .mdf file available in $ProjectPath.                                "
        echo " One will be created after asking all necessary questions about the project.     " 
        echo "================================================================================="
        AskProjInfo
        #
# Writing a text file requires that the text lines to write start from the border
# of the document. Indenting the lines makes indenting the lines in the written
# text files and EOL MUST BE at position 0.
    cat > $ProjectPath/.$ProjectName".mdf" << EOL
#=====================================================================
# This file is auto-generated by the CreateProject .bat/script file.
# Please do not delete or alter this file!
#=====================================================================
${ScrptDrctry}
${CrrntDrctry}
${ProjectRootPath}
${FpgaFamily}
${TopLevelName}
${VivadoVer}
${SimulVer}
${PetaLnxUsed}
${PynqUsed}
${VitisUsed}
${Author}
${Vendor}
${CurrDay} ${CurrMonth} ${CurrYear}
${Editor}
${WrkspcePath}
${ProjMngr}
EOL
#
    fi
}
# End of CheckProjFile
#
#=========================================================================================
# Create the library.
# This information is available:
#   LibraryPath => This is the path into the /Libraies directory
#   LibraryName => This is the name of the library to create in the Libraries directory
#   ProjectName => name of the project
#   ProjectRootPath => path where the project is created.
# all information to change the keywords in the files.
#=========================================================================================
CreateLib() {
    if [ $LibType == p ]; then
        echo "================================================================================="
        echo " Create the library as a project:                                                "
        sleep 1
        ProjectRootPath=$LibraryRootPath
        ProjectName=$LibraryName
        FullProjectPath=$FulLibraryPath
        AskPetaLinux
        AskPynq
        AskVitis
        CreateProj
    elif [ $LibType == s ]; then 
        echo "================================================================================="
        echo " Create the library as a set of directories:                                     "
        sleep 1
        cp -r $ScrptDrctry/Library_Name/* $FulLibraryPath

        echo " Add file headers to the basic template files.  "
        sleep 1
        ## Simulation command files
        find $FulLibraryPath/* -type f -name '*.prj' \
          -exec cp $ScrptDrctry/FileHeaders/SimCmndFileHeader.txt $FulLibraryPath/file.txt \; \
          -exec cat {} >> $FulLibraryPath/file.txt \; \
          -exec cp $FulLibraryPath/file.txt {} \;
        rm $FulLibraryPath/file.txt
        ##
        find $FulLibraryPath/* -type f -name '*.sh' \
          -exec cp $ScrptDrctry/FileHeaders/SimCmndFileHeader.txt $FulLibraryPath/file.txt \; \
          -exec cat {} >> $FulLibraryPath/file.txt \; \
          -exec cp $FulLibraryPath/file.txt {} \;
        rm $FulLibraryPath/file.txt
        ##
        find $FulLibraryPath/* -type f -name '*.tcl' \
          -exec cp $ScrptDrctry/FileHeaders/SimCmndFileHeader.txt $FulLibraryPath/file.txt \; \
          -exec cat {} >> $FulLibraryPath/file.txt \; \
          -exec cp $FulLibraryPath/file.txt {} ';'
        rm $FulLibraryPath/file.txt
        #
        # VHDL files
        find $FulLibraryPath/* -type f -name '*.vhd' \
          -exec cp $ScrptDrctry/FileHeaders/VhdlFileHeader.txt $FulLibraryPath/file.txt \; \
          -exec cat {} >> $FulLibraryPath/file.txt \; \
          -exec cp $FulLibraryPath/file.txt {} \;
        rm $FulLibraryPath/file.txt
        #
        echo " Name the files.  "
        sleep 1
        # Replace 'LibName-' by the name of the top level (BareLibraryName_) and
        for file in $(find $FulLibraryPath -type f -name 'LibName-*.*')
            do
                mv $file $(echo "$file" | sed -r "s|LibName-|$BareLibraryName"_"|g")
            done
        #
        for file in $(find $FulLibraryPath -type f -name 'LibName*.*')
            do
                mv $file $(echo "$file" | sed -r "s|LibName|$BareLibraryName|g")
            done
        for file in $(find $FulLibraryPath -type f -name '*_LibName.*')
            do
                mv $file $(echo "$file" | sed -r "s|LibName|$BareLibraryName|g")
            done
        #
        echo " Replace the keywords in all files of the created project. "
        sleep 1
        grep -rl '${YEAR}' $FulLibraryPath | xargs sed -i "s/\${YEAR}/$CurrYear/g"
        grep -rl '${FAMILY}' $FulLibraryPath | xargs sed -i "s/\${FAMILY}/$FpgaFamily/g"
        grep -rl '${AUTHOR}' $FulLibraryPath | xargs sed -i "s/\${AUTHOR}/$Author/g"
        grep -rl '${VENDOR}' $FulLibraryPath | xargs sed -i "s/\${VENDOR}/$Vendor/g"
        grep -rl '${FILE_NAME}' $FulLibraryPath | xargs sed -i "s/\${FILE_NAME}/$BareLibraryName/g"
        grep -rl '${SIM_TOOL}' $FulLibraryPath | xargs sed -i "s/\${SIM_TOOL}/$SimulVer/g"
        grep -rl '${VIVADO_TOOL}' $FulLibraryPath | xargs sed -i "s/\${VIVADO_TOOL}/$VivadoVer/g"
        grep -rl '${DATE}' $FulLibraryPath | xargs sed -i "s/\${DATE}/$CurrDay $CurrMonth $CurrYear/g"
        return
    fi 
}
# End of CreateLib
#
#=========================================================================================
# Ask the necessary questions to create a project.
# Then create the project.
#   Creating a project is copying directory "Project_Name", sub-directories and files
#   to the given location and then change all names to the given new project name.
# Replace the keywords in all files in the newly created project.
#=========================================================================================
CreateProject() {
    AskProjPathInfo
    AskPrjName
    AskProjInfo
    AskPetaLinux
    AskPynq
    AskVitis
    AskScriptUser
    AskCodeWrkspce
    AskCodeProjMngr
    SumProjData 
    CreateProj
    ManipCodeWrkspce
    ManipCodePrjMngr
    CreateProjFile
    echo "================================================================================="
    echo " Project $ProjectName is created in $ProjectRootPath                             "
    echo "================================================================================="
    sleep 2
    read -e -p "Press enter to continue"
    exit
}
# End of CreateProject
#
#=========================================================================================
# Provide information and ask questions in order to be able to create a new library.
# Create the library and give files and directories the required name..
# Change the keywords in the library files.
#=========================================================================================
CreateLibrary() {
    AskLibPathInfo
    AskLibName
    CheckProjFile
    CreateLib
    echo "================================================================================="
    echo " Library $LibraryName is created in $LibraryRootPath                                 "
    echo "================================================================================="
    sleep 2
    read -e -p "Press enter to continue"
    exit
}
# End of CreateLibrary
#
#=========================================================================================
# Start/run the script to create a new project or library
#=========================================================================================
#
echo "================================================================================="
echo " This script creates a new project or new library in an existing project for     "
echo " AMD FPGA designs. The script generates a directory structure and coding and/or  "
echo " simulation template files to be used with Vivado, Petalinux, PynQ and/or Vitis  "
echo " Things:                                                                         "
echo "       - The scripyt assumes the use of VS-Code editor                           "
echo "       - The script and directory setup assumes the use of the Vivado simulator  "
echo "         run in standalone mode.                                                 "
echo "       - The Vivado tool is solely used for synthesis and inplementation         "
echo "       - PetaLinux, when used, is used in command line (terminal) mode           "
echo "       - Pynq, when used, is like PetaLinux used from the command line           "
echo "                                                                                 "
echo " Each of the created directories in a project or library has a PDF document      "
echo " with instructions and guidelines about how to use the directory, tools and      "
echo " files.                                                                          "
echo "================================================================================="
sleep 8
GetScriptDir
SetDate
GenProjOrLib
#
if [ "$ProjOrLib" = "Proj" ]; then
    CreateProject
elif [ "$ProjOrLib" = "Lib" ]; then
    CreateLibrary
fi
#
# The end
#=========================================================================================
