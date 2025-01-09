
#-------------------------------------------------------------------------------------------------
#-
#- To run this script do:
#-      - When Vivado has created a place and routed design switch to the TCL console window.
#-      - change directory (cd) to the /SimScripts directory of the project.
#-          - Type in the TCL command ruler: cd ../SimScripts
#-            While typing this normally will pop up automatically.
#-      - Run (source) this script.
#-  When done some files should be generated in the /Simulation directory of the project.
#-      - A verilog file created from the implemnetd design.
#-      - A timing information file (SDF).
#-------------------------------------------------------------------------------------------------
set_property target_simulator Questa [current_project]
set_property simulator_language Mixed [current_project]
#- PROCESS CORNER: SLOW or FAST
write_sdf -mode timesim -process_corner fast -force -file "../Simulation/${FILE_NAME}_Time_Impl.sdf"
#-write_sdf -mode timesim -process_corner slow -force -file "../Simulation/${FILE_NAME}_Time_Impl.sdf"
#-
write_verilog -mode timesim -nolib -sdf_anno true -force -file "../Simulation/${FILE_NAME}_Time_Impl.v"
cd ../Vivado
#-
#-------------------------------------------------------------------------------------------------
