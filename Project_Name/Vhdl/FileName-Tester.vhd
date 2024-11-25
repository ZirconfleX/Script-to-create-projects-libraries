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
    use IEEE.std_logic_textio.all;
    use std.textio.all;
    use IEEE.std_logic_arith.all;
---------------------------------------------------------------------------------------------
entity ${FILE_NAME}_Tester is
    generic (
--        C_TstrClkPeriod   : time;
--        C_TstrPhaseShift  : integer;
--        C_WriteDataFile   : string;
--        C_ReadDataFile    : string;
    -- Insert here the generics as they are declared in the ${FILE_NAME}_Testbench.vhd file.
    );
    port (
    -- Insert here the ports as they are declared in the ${FILE_NAME}_Testbench.vhd file.
    );
end ${FILE_NAME}_Tester;
---------------------------------------------------------------------------------------------
-- Architecture Declarations
---------------------------------------------------------------------------------------------
architecture ${FILE_NAME}_Tester_flow of ${FILE_NAME}_Tester is
---------------------------------------------------------------------------------------------
-- Functions
--
-- Convert a std_logic_vector to a string.
function stdlvec_to_str(inp: std_logic_vector) return string is
	variable temp : string(inp'left+1 downto 1) := (others => 'X');
begin
	for i in inp'reverse_range loop
		if (inp(i) = '1') then
			temp(i+1) := '1';
		elsif (inp(i) = '0') then
			temp(i+1) := '0';
		end if;
	end loop;
return temp;
end function stdlvec_to_str;
--
-- Constants
constant Low        : std_logic := '0';
constant LowVec     : std_logic_vector(255 downto 0) := (others => '0');
constant High       : std_logic := '1';
--
--  When using the text files in the simulation for read and write operations
--  Change throughout the file "Write" in Sim_C_WriteDataFile and WriteDataFile.txt by a
--  meaningful name. Change throughout the file"Read" in Sim_C_ReadDataFile and
--  ReadDataFile.txt by a meaningful name.
--constant WriteDataFile    : string := C_WriteDataFile;
--constant ReadDataFile     : string := C_ReadDataFile;
--
-- Signals
--  The ports of the ${FILE_NAME} component above should be copied here
--  and then translated to signals as shown in the example.
--  Add "signal Sim_"in front of the port name.
--  Remove the port direction (in, out) directive.
--Example: signal Int<MySignal>      : std_logic; -- in
--
---------------------------------------------------------------------------------------------
begin
--
--  Connect here the internal signals to teh input and output Ports
-- Example:
--   <MyOutPort>_pin    <= Int<MyOutPort>;
--
---------------------------------------------------------------------------------------------
-- Processes
---------------------------------------------------------------------------------------------
MainProc : process
    begin
        -- Put some text on screen
        assert false
        report CR &
        "  " & CR &
        "  " & CR &
        "  " & CR
        severity note;
    --
    --Drop here the designs main control ports and force a value, like:
    --Int_Reset <= '1';
    --wait for C_TstrClkPeriod*53;
    --Int_Reset <= '0';
    --wait for C_TstrClkPeriod*200;
    --
    assert false
    report "That's All Folks !"
    severity warning;
    wait;
--
end process MainProc;
---------------------------------------------------------------------------------------------
-- Architecture Concurrent Statements
---------------------------------------------------------------------------------------------
--SomeProcess : process
--    file WriteFile : text open WRITE_MODE is WriteDataFile;
--    file ReadFile  : text open READ_MODE is ReadDataFile;
--    variable WriteLineLength  : line;
--    variable ReadLineLength   : line;
--    variable LenghtOfDataToRead : std_logic_vector(n downto 0);
--begin
--    -- enter a process description here.
--    -- During the process a file can be read or written.
--    -- Write a file as following:
--            write (WriteLineLength, <Something to be written>, left, 36);
--            write (WriteLineLength, stdlvec_to_str(Value), right, 8);
--            writeline (WriteFile, WriteLineLength);
--    -- A file can be read as following:
--            ReadLoop : while not endfile (TextFile) loop
--            -- some commands
--            readline (ReadFile, LineLength);        -- Read a line.
--            read (LineLength, LenghtOfDataToRead);  -- Put the line in a workable variable.
--            wait until (IntClk'event and IntClk = '1');
--            -- Use the "LenghtOfDataToRead" variable.
--end process;
---------------------------------------------------------------------------------------------
-- Generate one or multiple clocks.
--
--      The C_TstrClkPeriod is a generic of the ${FILE_NAME}_Tester.
--      It is defined and a value is given to it (Via constant) in the
--      ${FILE_NAME}_Testbench.vhd file.
--      When the frequency of the simulation must be changed, change the
--      C_TstrClkPeriod in the ${FILE_NAME}_Testbench.vhd file
--      When more clocks are required in a design/simulation create then as is done for
--      the C_TstrClkPeriod and it's clock.
--
--TheClock : process
--    variable TempOne : std_logic := '0';
--begin
--    if (TempOne = '0') then
--        wait for C_TstrClkPeriod/C_TstrPhaseShift;
--        TempOne := '1';
--    else
--        Int_Clock_p <= '0';
--        Int_Clock_n <= '1';
--        wait for C_TstrClkPeriod/2;
--        Int_Clock_p <= '1';
--        Int_Clock_n <= '0';
--        wait for C_TstrClkPeriod/2;
--    end if;
--end process;
--
--TheInternalClock : process
--    variable TempOne : std_logic := '0';
--begin
--    if (TempOne = '0') then
--        wait for C_TstrClkPeriod/C_PhaseShift;
--        TempOne := '1';
--    else
--        IntClk <= '0';
--        wait for C_TstrClkPeriod/2;
--        IntClk <= '1';
--        wait for C_TstrClkPeriod/2;
--    end if;
--end process;
-------------------------------------------------------------------------------------------
end ${FILE_NAME}_Tester_flow;
