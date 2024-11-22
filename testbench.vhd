----------------------------------------------------------------------------------
-- Author: Alan Salciccioli
-- 
-- Create Date: 11/02/2023 02:00:32 PM
-- Design Name: TestBench 
-- Module Name: testbench - Behavioral
-- Project Name: IPBlocks

-- Description: This file tests the device implemented in the file top.vhd 
-- 
-- Dependencies: top.vhd, test_pkg.vhd

----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.env.finish;
use work.test_pkg.all;
entity testbench is
--  Port ( );
end testbench;

architecture Behavioral of testbench is

component top is
Port (
      clk_in: in std_logic;
      reset_in: in  std_logic;
      ena0 : in std_logic;
      wea0: in std_logic_vector(0 downto 0);
      addra0: in std_logic_vector(7 downto 0);
      dina0: in std_logic_vector(15 downto 0);
      ena1: in std_logic;
      wea1: in std_logic_vector(0 downto 0);
      addra1: in std_logic_vector(7 downto 0);
      dina1: in std_logic_vector(15 downto 0);
      start: in std_logic;
      locked: out std_logic;
      douta0: out std_logic_vector(15 downto 0);
      douta1 : out std_logic_vector(15 downto 0)

     );
end component;

--TestBench Signals inputs===================================================
signal clk_in_tb, reset_in_tb,ena0_tb,ena1_tb, start_tb :std_logic;
signal wea0_tb,wea1_tb :std_logic_vector(0 downto 0);
signal addra0_tb, addra1_tb: std_logic_vector(7 downto 0);
signal dina0_tb,dina1_tb, CurrentData_tb: std_logic_vector(15 downto 0);
--===========================================================================
--TestBench Output Signals=====================================================
signal locked_tb: std_logic;
signal douta0_tb,douta1_tb :std_logic_vector(15 downto 0);
--===============================================================================
constant period : time := 8ns;

begin

DUT: top port map
(
clk_in => clk_in_tb,
reset_in=> reset_in_tb,
ena0 => ena0_tb,
wea0 => wea0_tb,
addra0 => addra0_tb,
dina0 => dina0_tb,
ena1 => ena1_tb,
wea1 => wea1_tb,
addra1 => addra1_tb,
dina1 => dina1_tb,
start => start_tb,
locked => locked_tb,
douta0 => douta0_tb,
douta1 => douta1_tb
);

FreeRunningClock: process
begin
clk_in_tb <= '0';
wait for period/2;
clk_in_tb <= '1';
wait for period/2;

end process;


Timeout: process
begin
wait for 600us;
finish;
end process;


Test: process
begin

--Assures the Device has been properly reset as well as waits until clock is stable
reset_in_tb <= '1';
start_tb<='0';
wait until rising_edge(clk_in_tb);
wait for 5ns;
reset_in_tb <= '0';
wait until rising_edge(clk_in_tb);
wait until rising_edge(locked_tb);
wait for 1us;
wait until rising_edge(clk_in_tb);
--====================================================================================

--==============================================================================
--Test 1 Methodology: This test assures that the device is able to read from 
--memory by checking preloaded data defined in each memory block's coe file. 
--==============================================================================

--Memory 0 Tests Start-----------------------------------------------------------------
ReadMemoryBRAM(clk_in_tb, ena0_tb,wea0_tb,addra0_tb,"00000000",douta0_tb,CurrentData_tb);
wait until rising_edge(clk_in_tb);
if(douta0_tb /= x"000A") then
report "Test Fail Read Memory 0 at location 0";
finish;
end if;

ReadMemoryBRAM(clk_in_tb, ena0_tb,wea0_tb,addra0_tb,"00000001",douta0_tb,CurrentData_tb);
wait until rising_edge(clk_in_tb);
wait until rising_edge(clk_in_tb);
if(douta0_tb /= x"00F1") then
report "Test Fail Read Memory 0 at location 1";
finish;
end if;


ReadMemoryBRAM(clk_in_tb, ena0_tb,wea0_tb,addra0_tb,"00000010",douta0_tb,CurrentData_tb);
wait until rising_edge(clk_in_tb);
if(douta0_tb /= x"001F") then
report "Test Fail Read Memory 0 at location 2";
finish;
end if;


ReadMemoryBRAM(clk_in_tb, ena0_tb,wea0_tb,addra0_tb,"00000011",douta0_tb,CurrentData_tb);
wait until rising_edge(clk_in_tb);
if(douta0_tb /= x"0F0F") then
report "Test Fail Read Memory 0 at location 3";
finish;
end if;

--Memory 0 Tests finish-----------------------------------------------------------------


--Memory 1 Tests Start-----------------------------------------------------------------
ReadMemoryBRAM(clk_in_tb, ena1_tb,wea1_tb,addra1_tb,"00000000",douta1_tb,CurrentData_tb);
wait until rising_edge(clk_in_tb);
if(douta1_tb /= x"000A") then
report "Test Fail Read Memory 1 at location 0";
finish;
end if;

ReadMemoryBRAM(clk_in_tb, ena1_tb,wea1_tb,addra1_tb,"00000001",douta1_tb,CurrentData_tb);
wait until rising_edge(clk_in_tb);
if(douta1_tb /= x"00F1") then
report "Test Fail Read Memory 1 at location 1";
finish;
end if;



ReadMemoryBRAM(clk_in_tb, ena1_tb,wea1_tb,addra1_tb,"00000010",douta1_tb,CurrentData_tb);
wait until rising_edge(clk_in_tb);

if(douta1_tb /= x"001F") then
report "Test Fail Read Memory 1 at location 2";
finish;
end if;


ReadMemoryBRAM(clk_in_tb, ena1_tb,wea1_tb,addra1_tb,"00000011",douta1_tb,CurrentData_tb);
wait until rising_edge(clk_in_tb);

if(douta1_tb /= x"0F0F") then
report "Test Fail Read Memory 1 at location 3";
finish;
end if;
--Memory 1 Tests finish-----------------------------------------------------------------
--========================================================================================
--Test 2 Methodology: Assure devices can write Data to the device by passing in data to several addresses
--========================================================================================

--Memory 0 Test Start------------------------------------------------------------------------------------------

WriteMemoryBRAM(clk_in_tb,ena0_tb,wea0_tb,addra0_tb,"00000100",x"EE0E",dina0_tb);
wait until rising_edge(clk_in_tb);

ReadMemoryBRAM(clk_in_tb, ena0_tb,wea0_tb,addra0_tb,"00000100",douta0_tb,CurrentData_tb);
wait until rising_edge(clk_in_tb);
if(douta0_tb /= x"EE0E") then
report "Test Fail Write Memory 0 at location 4";
finish;
end if;

WriteMemoryBRAM(clk_in_tb,ena0_tb,wea0_tb,addra0_tb,"00000101",x"0FFF",dina0_tb);
wait until rising_edge(clk_in_tb);

ReadMemoryBRAM(clk_in_tb, ena0_tb,wea0_tb,addra0_tb,"00000101",douta0_tb,CurrentData_tb);
wait until rising_edge(clk_in_tb);
if(douta0_tb /= x"0FFF") then
report "Test Fail Write Memory 0 at location 5";
finish;
end if;


--Memory 0 Test Finish------------------------------------------------------------------------------------------

--Memory 1 Test Start------------------------------------------------------------------------------------------
WriteMemoryBRAM(clk_in_tb,ena1_tb,wea1_tb,addra1_tb,"00000100",x"1111",dina1_tb);
wait until rising_edge(clk_in_tb);

ReadMemoryBRAM(clk_in_tb, ena1_tb,wea1_tb,addra1_tb,"00000100",douta1_tb,CurrentData_tb);
wait until rising_edge(clk_in_tb);

if(douta1_tb /= x"1111") then
report "Test Fail Write Memory 1 at location 4";
finish;
end if;


WriteMemoryBRAM(clk_in_tb,ena1_tb,wea1_tb,addra1_tb,"00000101",x"0212",dina1_tb);
wait until rising_edge(clk_in_tb);

ReadMemoryBRAM(clk_in_tb, ena1_tb,wea1_tb,addra1_tb,"00000101",douta1_tb,CurrentData_tb);
wait until rising_edge(clk_in_tb);

if(douta1_tb /= x"0212") then
report "Test Fail Write Memory 1 at location 5";
finish;
end if;

--Memory 1 Test Finish------------------------------------------------------------------------------------------

--Starts State machine and waits for DSP to process data-----------------------------------------------------------
start_tb<='1';
wait for 2000ns;
start_tb<='0';
-------------------------------------------------------------------------------------------------------------------
--=================================================================================================================
--Test 3 methodology: Assures that the DSP is working correctly by checking the results that are stored in the 
-- in the highest addresses. 
--==================================================================================================================

--Memory 0 Tests Start-----------------------------------------------------------------------------------------------
ReadMemoryBRAM(clk_in_tb, ena0_tb,wea0_tb,addra0_tb,x"FF",douta0_tb,CurrentData_tb);
wait until rising_edge(clk_in_tb);

if(douta0_tb /= x"0000") then
report "Test Fail DSP Write Memory 0 at location FF";
finish;
end if;

ReadMemoryBRAM(clk_in_tb, ena0_tb,wea0_tb,addra0_tb,x"FE",douta0_tb,CurrentData_tb);
wait until rising_edge(clk_in_tb);

if(douta0_tb /= x"0000") then
report "Test Fail DSP Write Memory 0 at location FE";
finish;
end if;

ReadMemoryBRAM(clk_in_tb, ena0_tb,wea0_tb,addra0_tb,x"FD",douta0_tb,CurrentData_tb);
wait until rising_edge(clk_in_tb);

if(douta0_tb /= x"0000") then
report "Test Fail DSP Write Memory 0 at location FD";
finish;
end if;

ReadMemoryBRAM(clk_in_tb, ena0_tb,wea0_tb,addra0_tb,x"FC",douta0_tb,CurrentData_tb);
wait until rising_edge(clk_in_tb);

if(douta0_tb /= x"00e2") then
report "Test Fail DSP Write Memory 0 at location FC";
finish;
end if;

ReadMemoryBRAM(clk_in_tb, ena0_tb,wea0_tb,addra0_tb,x"FB",douta0_tb,CurrentData_tb);
wait until rising_edge(clk_in_tb);

if(douta0_tb /= x"fecd") then
report "Test Fail DSP Write Memory 0 at location FB";
finish;
end if;

ReadMemoryBRAM(clk_in_tb, ena0_tb,wea0_tb,addra0_tb,x"FA",douta0_tb,CurrentData_tb);
wait until rising_edge(clk_in_tb);

if(douta0_tb /= x"0021") then
report "Test Fail DSP Write Memory 0 at location FA";
finish;
end if;




--Memory 0 Tests finish-----------------------------------------------------------------------------------------------

--Memory 1 Tests Start-----------------------------------------------------------------------------------------------

ReadMemoryBRAM(clk_in_tb, ena1_tb,wea1_tb,addra1_tb,x"FF",douta1_tb,CurrentData_tb);
wait until rising_edge(clk_in_tb);
if(douta1_tb /= x"0064") then
report "Test Fail DSP Write Memory 1 at location FF";
finish;
end if;

ReadMemoryBRAM(clk_in_tb, ena1_tb,wea1_tb,addra1_tb,x"FE",douta1_tb,CurrentData_tb);
wait until rising_edge(clk_in_tb);
if(douta1_tb /= x"E2E1") then
report "Test Fail DSP Write Memory 1 at location FE";
finish;
end if;

ReadMemoryBRAM(clk_in_tb, ena1_tb,wea1_tb,addra1_tb,x"FD",douta1_tb,CurrentData_tb);
wait until rising_edge(clk_in_tb);
if(douta1_tb /= x"03c1") then
report "Test Fail DSP Write Memory 1 at location FD";


finish;
end if;


ReadMemoryBRAM(clk_in_tb, ena1_tb,wea1_tb,addra1_tb,x"FC",douta1_tb,CurrentData_tb);
wait until rising_edge(clk_in_tb);
if(douta1_tb /= x"c2e1") then
report "Test Fail DSP Write Memory 1 at location FC";
finish;
end if;

ReadMemoryBRAM(clk_in_tb, ena1_tb,wea1_tb,addra1_tb,x"FB",douta1_tb,CurrentData_tb);
wait until rising_edge(clk_in_tb);
if(douta1_tb /= x"bcee") then
report "Test Fail DSP Write Memory 1 at location FB";
finish;
end if;

ReadMemoryBRAM(clk_in_tb, ena1_tb,wea1_tb,addra1_tb,x"FA",douta1_tb,CurrentData_tb);
wait until rising_edge(clk_in_tb);
if(douta1_tb /= x"1dee") then
report "Test Fail DSP Write Memory 1 at location FA";
finish;
end if;
--Memory 1 Tests finish-----------------------------------------------------------------------------------------------

wait until rising_edge(clk_in_tb);
wait until rising_edge(clk_in_tb);

report "Test Passed";
finish;

wait;


end process;



end Behavioral;
