
--------------------------------------------------------------------------------------------------
-- Naming Conventions:
--  Generics start with:                                    "C_*"
--  Ports
--      All words in the label of a port name start with a upper case, AnInputPort.
--      Active low ports end in                             "*_n"
--      Active high ports of a differential pair end in:    "*_p"
--      Ports being device pins end in _pin                 "*_pin"
--      Reset ports end in:                                 "*Rst"
--      Enable ports end in:                                "*Ena", "*En"
--      Clock ports end in:                                 "*Clk", "ClkDiv", "*Clk#"
--  Signals and constants
--      Constants start with                                "Cnst_"
--      Signals and constant labels start with              "Int*"
--      Registered signals end in                           "_d#"
--      User defined types:                                 "*_TYPE"
--      State machine next state:                           "*_Ns"
--      State machine current state:                        "*_Cs"
--      Counter signals end in:                             "*Cnt", "*Cnt_n"
--   Processes:                                 "<Entity_><Function>_PROCESS"
--   Component instantiations:                  "<Entity>_I_<Component>_<Function>"
--------------------------------------------------------------------------------------------------
library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.std_logic_UNSIGNED.all;
    use STD.textio.all;
library UNISIM;
    use UNISIM.vcomponents.all;
--------------------------------------------------------------------------------------------------
entity ${FILE_NAME}_Testbench is
-- Declarations
end ${FILE_NAME}_Testbench;
--------------------------------------------------------------------------------------------------
architecture ${FILE_NAME}_Testbench_struct of ${FILE_NAME}_Testbench is
--------------------------------------------------------------------------------------------------
-- Component Instantiation
--------------------------------------------------------------------------------------------------
component ${FILE_NAME}
    generic (
    -- Drop here the generic names of the top level entity.
    );
    port (
    -- Drop here the port names of the top level entity.
    -- When using Atom.io, use the package "VHDL Entity Converter" to
    -- translate the entity to component and then insert it here.
    );
end component ${FILE_NAME};
--
component ${FILE_NAME}_Tester
    generic (
        --C_TstrClkPeriod   : time;
        --C_TstrPhaseShift  : integer;
        --C_WriteDataFile   : string;
        --C_ReadDataFile    : string;
    --Insert here generics used in the stimulus file.
    );
    port (
    -- Insert here ports used in the stimulus file.
    );
end component ${FILE_NAME}_Tester;

--------------------------------------------------------------------------------------------------
-- Signal Declarations
--------------------------------------------------------------------------------------------------
-- Constants
-- Mandatory constant, because used in the _Tester.
--constant Sim_C_TstrClkPeriod    : time := 8.0 ns; -- 125 MHz
--constant Sim_C_TstrPhaseShift   : integer := 512; -- C_TstrClkPeriod/C_TstrPhaseShift is start phase shift.
--
-- Simulation run reading and writing text files.
-- Create a constant Sim_C_WriteDataFile pointing to a WriteDataFile.txt (meaningful name).
--constant Sim_C_WriteDataFile : string   := "../SimScripts/WriteDataFile.txt";
-- Create a constant Sim_C_WriteDataFile pointing to a WriteDataFile.txt (meaningful name).
--constant Sim_C_ReadDataFile  : string   := "../SimScripts/ReadDataFile.txt";
-- Connect these constants to generics used in the ${FILE_NAME}_Tester.
--
-- Example of possible constants
--constant Sim_C_Part         : string  := "XCVU095";
--constant Sim_C_IoBank       : integer := 68;
--constant Sim_C_UsedPll      : string  := "Pll0"; -- "Pll0", "Pll1"
--constant Sim_C_UseOddr      : string  := "Oddr";
-- signals

-- The ports of the ${FILE_NAME} component above should be copied here
-- and then translated to signals as shown in the example.
-- Add "signal Sim_" in front of the port name.
-- Remove the port direction (in, out) directive.
--
--signal Sim_MySignal    : std_logic;
--
--------------------------------------------------------------------------------------------------
begin
--
UUT : ${FILE_NAME}
    generic map (

    )
    port map (
    -- insert the ${FILE_NAME} component here and connect it up using the
    -- declared signals
    );
--
DTU : ${FILE_NAME}_Tester
    generic map (
        --C_TstrClkPeriod   => Sim_C_TstrClkPeriod,
        --C_TstrPhaseShift  => Sim_C_TstrPhaseShift,
        --C_WriteDataFile   => Sim_C_WriteDataFile,
        --C_ReadDataFile    => Sim_C_ReadDataFile,
    )
    port map (
    -- insert the ${FILE_NAME} component here and connect it up using the
    -- declared signals.
    );
-------------------------------------------------------------------------------------------
end ${FILE_NAME}_Testbench_struct;
--
