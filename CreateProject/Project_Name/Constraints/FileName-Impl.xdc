#-------------------------------------------------------------------------------------------------
#-
#- Constraint to allow a clock from a different IO-Bank than the one using the PLL.
#- DO NOT USE : ANY_CMT_ROUTE because the clock buffer is placed anywhere in the FPGA logic.
#- This case used ANY_CMT_ROUTE and the clock buffer was placed in a left top IO-Bank while
#- the inputs and used logic are placed middle-bottom right.
#-
#- Enable this constraint when the clock is supplied by another IO-Bank than the IO-Bank
#- containing the MMCM and/or PLL.
#set_property CLOCK_DEDICATED_ROUTE SAME_CMT_COLUMN [get_nets DrpClk_p_pin]
#-
#- Enable this constraint when the input clock for a PLL is supplied though a MMCM.
#set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets  ]
#-
#-------------------------------------------------------------------------------------------------
#- Timing Constraints (Put design timing constraints below the line)
#-------------------------------------------------------------------------------------------------
#-

#-------------------------------------------------------------------------------------------------
#-
#- The End
