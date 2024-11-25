---------------------------------------------------------------------------------------------
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
---------------------------------------------------------------------------------------------
library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.std_logic_UNSIGNED.all;
library UNISIM;
    use UNISIM.vcomponents.all;
-- The comments blow are there as guidance,
-- when using the file REMOVE THE COMMENTS.
--
--  Drop here all libraries used on this level of the design.
--  This is necessary because component instantiation following the
--  entity instantiation method. This saves a lot of typing and reduces
--  the length of the VHDL file considerably.
--  Example:
--  library Common_Lib;       -- This is a directory in /Libraries
--      use Common_Lib.all;   -- This means use everything in the given library.
--  WARNING:
--      When using "xil_defaultlib" as library here, be warned that QuestaSim simulation
--      might error out. If that is the case, check the modelsim.ini file in the directory
--      used for the compiled Xilinx libraries.
--      - Open the modelsim.ini with an editor.
--      - Search for "xil_defaultlib".
--      - This will turn up a sentence "xil_defaultlib = questa_lib/msim/xil_defaultlib".
--      - Comment the line and save the file.
--      - Use in the .do files used in simulation the standard library command.
---------------------------------------------------------------------------------------------
-- Entity pin description
---------------------------------------------------------------------------------------------
-- Provide here as short description of the generics and ports of the design.
-- There is then no need to add comments after generics and ports in the entity code part.
-- Generics
--  Put a description of used generics here.
-- Ports
--  Put a description of used generics here.
---------------------------------------------------------------------------------------------
entity ${FILE_NAME} is
    generic (

    );
    port (

    );
end ${FILE_NAME};
---------------------------------------------------------------------------------------------
-- Architecture section
---------------------------------------------------------------------------------------------
architecture ${FILE_NAME}_arch of ${FILE_NAME} is
---------------------------------------------------------------------------------------------
-- Component Instantiation
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
-- Constants, Signals and Attributes Declarations
---------------------------------------------------------------------------------------------
-- Functions
-- Constants
constant Low      : std_logic	:= '0';
constant LowVec   : std_logic_vector(255 downto 0) := (others => '0');
constant High     : std_logic	:= '1';
constant HighVec  : std_logic_vector(255 downto 0) := (others => '1');
-- Signals

-- Attributes
attribute KEEP_HIERARCHY : string;
    attribute KEEP_HIERARCHY of ${FILE_NAME}_arch : architecture is "YES";
--attribute LOC : string;
---------------------------------------------------------------------------------------------
begin
--

---------------------------------------------------------------------------------------------
end ${FILE_NAME}_arch;
--
