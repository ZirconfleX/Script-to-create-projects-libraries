#--------------------------------------------------------------------------------------------
#- Find below examples of constraints for a design.
#- Each design needs or has it's own set of specific constraints depending the
#- given and/or required targets.
#--------------------------------------------------------------------------------------------
#- Timing constraints
#-------------------------------------------------------------------------------------------
#- Clock inputs
#-
#create_clock -period 8.000 -name SysClk -waveform {0.000 4.000} [get_ports SysClk_p_pin]
#set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks SysClk]
#-
#-------------------------------------------------------------------------------------------
#- FPGA pin settings
#- Use the constraints that fit with the type of IOSTANDARD for the used pins.
#-------------------------------------------------------------------------------------------
#- N-side
#set_property PACKAGE_PIN        AY7         [get_ports ClkOut0_n_pin]
#set_property IOSTANDARD         LVDS        [get_ports ClkOut0_n_pin]
#set_property LVDS_PRE_EMPHASIS  FALSE       [get_ports ClkOut0_n_pin]
#set_property PACKAGE_PIN        AY8         [get_ports ClkOut0_p_pin]
#set_property IOSTANDARD         LVDS        [get_ports ClkOut0_p_pin]
#set_property LVDS_PRE_EMPHASIS  FALSE       [get_ports ClkOut0_p_pin]
#- P-side
#set_property PACKAGE_PIN        AV8         [get_ports ClkOut1_n_pin]
#set_property IOSTANDARD         LVDS        [get_ports ClkOut1_n_pin]
#set_property LVDS_PRE_EMPHASIS  FALSE       [get_ports ClkOut1_n_pin]
#set_property PACKAGE_PIN        AV9         [get_ports ClkOut1_p_pin]
#set_property IOSTANDARD         LVDS        [get_ports ClkOut1_p_pin]
#set_property LVDS_PRE_EMPHASIS  FALSE       [get_ports ClkOut1_p_pin]
#-
#-------------------------------------------------------------------------------------------
#- The end
