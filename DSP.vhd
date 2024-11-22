----------------------------------------------------------------------------------
-- Author: Alan Salciccioli
-- 
-- Create Date: 11/01/2023 10:03:00 AM
-- Design Name: DSP
-- Module Name: DSP - Behavioral
-- Project Name: IPBlocks

-- Description: This file implements a DSP that is to be used in the file top.vhd
-- The device recives data from the memory blocks present in the top level design, multiply said data together,
-- then stores  half the product in each block. Reads data from top of memory, stores data to bottom of memory

----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity DSP is
Port 
( 
    clk: in std_logic;
    reset: in std_logic;
    doutb0: in std_logic_vector(15 downto 0);
    doutb1: in std_logic_vector(15 downto 0);
    start: in std_logic;
    enb0: out std_logic;
    web0: out std_logic_vector(0 downto 0);
    addrb0: out std_logic_vector(7 downto 0);
    dinb0: out std_logic_vector(15 downto 0);
    enb1: out std_logic;
    web1: out std_logic_vector(0 downto 0);
    addrb1: out std_logic_vector(7 downto 0);
    dinb1 : out std_logic_vector(15 downto 0) 

);
end DSP;

architecture Behavioral of DSP is

COMPONENT dsp_macro_0
  PORT (
    CLK : IN STD_LOGIC;
    CE: in std_logic;
    A : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    B : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    P : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) 
  );
END COMPONENT;

--State Machine Declaration=============================
type stateMachine is (
ReadMem0, Interm1,Interm2,  --Read Memory States
MACRO_Operation,Macro_Interm0, -- Macro States
WriteMem0,WriteMem1 -- Write to Memory States
 );
signal currentState,nextState : stateMachine;
--======================================================
--Address signals============================================================================
signal readAddress0,readAddress1,writeAddress0,writeAddress1: std_logic_vector(7 downto 0);
--============================================================================================
--Macro Signals =================================================================================
signal macro_CE, macro_CE_async : std_logic;
signal macro_A, macro_B, macro_A_async,macro_B_async: std_logic_vector(15 downto 0);
signal macro_P: std_logic_vector(31 downto 0);
--===============================================================================================
--Asyncronous Version of DSP Signals==============================================
signal enb0_async, enb1_async : std_logic;
signal web0_async,web1_async : std_logic_vector(0 downto 0);
signal addrb0_async, addrb1_async: std_logic_vector(7 downto 0);
signal dinb0_async, dinb1_async: std_logic_vector(15 downto 0);

--==========================================================================


begin
Macro: dsp_macro_0 port map
(
    clk=> clk,
    CE=> macro_CE ,
    A => macro_A,
    B => macro_B,
    P => macro_P



);

SyncProcess: process(clk) --Synchronous Logic
begin
    if(rising_edge(clk)) then --if_1
        if(reset = '1') then -- if_reset
          currentState <= ReadMem0;       
          else
          
          currentState <= nextState;
        
        end if; --if_reset
     
    end if; -- if_1

end process;


--Asynchronous logic for state machine-------------------------------------
AsyncProc: process(all)

begin
if(start ='1') then --if_start

--Asynchronize synchronous signals(Not needed)=======================================================
 --Macro Reset----------------------------------------------
--    macro_CE_async <= macro_CE;
--    macro_A_async <= macro_A;
--    macro_B_async <= macro_B;
  ------------------------------------------------------------
  
  --DSP Signals-----------------------------------------------
--  enb0_async <= enb0;
--  enb1_async <= enb1;
  
--  web0_async <=web0;
--  web1_async <=web1;
--  addrb0_async <= addrb0;
--  addrb1_async <=addrb1;
--  dinb0_async <= dinb0;
--  dinb1_async <= dinb1;
  
  --==========================================================================

case currentState is

when ReadMem0 =>

--Reads the data of both memory blocks at the specified addresses
nextState <= Interm1;
web0_async <= "0";
web1_async <= "0";

enb0_async <='1';
enb1_async <='1';

addrb0_async <= readAddress0;
addrb1_async <= readAddress1;
---------------------------------------------------------------
--Itermidiate states to allow memory time to be read------------------
when Interm1 =>
nextState <= Interm2;
when Interm2 =>
nextState <= MACRO_Operation;
------------------------------------------------------------------------

when MACRO_Operation =>
--Activates DSP macro to perform operations on previously read values-----
nextState <= Macro_Interm0;
macro_A_async <= doutb0;
macro_B_async <= doutb1;
enb0_async <= '0';
enb1_async <='0';
macro_CE_async <='1';
----------------------------------------------------------------------

when Macro_Interm0 =>
--Deactivates DSP macro as well as memory blocks------------------------
macro_CE_async <= '0';
nextState <= WriteMem0;

enb0_async <= '0';
enb1_async <='0';

web0_async <="0";
web1_async <="0";

addrb0_async <= (others=>'0');
addrb1_async <= (others=>'0');
------------------------------------------------------------------------
when WriteMem0 =>
--Writes the product produced by macro into the specified addresses-----------
nextState <= WriteMem1;
enb0_async <= '1';
enb1_async <='1';

web0_async <="1";
web1_async <="1";
addrb0_async <= writeAddress0;
addrb1_async <= writeAddress1;
dinb0_async <= macro_P(31 downto 16);
dinb1_async <= macro_P(15 downto 0);
--------------------------------------------------------------------
when WriteMem1 =>
--Returns state machine to default state as well as resets memory block inputs----
nextState <= ReadMem0;
enb0_async <= '0';
enb1_async <='0';

web0_async <="0";
web1_async <="0";
-------------------------------------------------------------------------------
end case;

--=======================================================================================


end if; -- if_start
end process;

--Updates addresses synchronously and synchronizes signals -------------------
AddressUpdate: process(clk)
begin

if(rising_edge(clk)) then -- if_1
    if(reset = '1') then --if_reset
    --Reset all Synchronous signals===========================
   --Macro Reset----------------------------------------------
    macro_CE <= '0';
    macro_A <= (others => '0');
    macro_B <= (others=> '0');
  ------------------------------------------------------------
  
  --DSP Signals-----------------------------------------------
  enb0 <= '0';
  enb1 <= '0';
  
  web0 <="0";
  web1 <="0";
  addrb0 <= (others => '0');
  addrb1 <=(others => '0');
  dinb0 <= (others=> '0');
  dinb1 <= (others => '0');
  -----------------------------------------------------------
  --Reset Read and write addresses
  readAddress0 <= (others=>'0');
  readAddress1 <= (others=>'0');
  writeAddress0 <= (others=>'1');
  writeAddress1 <= (others=>'1');
  --==========================================================
 
  else
  
  --Synchronize Asynchronous signals=============================
     --Macro Reset----------------------------------------------
    macro_CE <= macro_CE_async;
    macro_A <= macro_A_async;
    macro_B <= macro_B_async;
  ------------------------------------------------------------
  
  --DSP Signals-----------------------------------------------
  enb0 <= enb0_async;
  enb1 <= enb1_async;
  
  web0 <=web0_async;
  web1 <=web1_async;
  addrb0 <= addrb0_async;
  addrb1 <=addrb1_async;
  dinb0 <= dinb0_async;
  dinb1 <= dinb1_async;
  
  --==========================================================================
  if (currentState = MACRO_Operation) then
         --Increments the Addresses to be Read-----------------------------
          readAddress0 <= std_logic_vector(to_unsigned(to_integer(unsigned(readAddress0)) + 1, 8));
           readAddress1 <= std_logic_vector(to_unsigned(to_integer(unsigned(readAddress1)) + 1, 8));
        end if;
        -------------------------------------------------------------------
   if (currentState = WriteMem1) then
         --Decrements the Addresses to be written to--------------------------
          writeAddress0 <= std_logic_vector(to_unsigned(to_integer(unsigned(writeAddress0)) - 1, 8));
           writeAddress1 <= std_logic_vector(to_unsigned(to_integer(unsigned(writeAddress1)) - 1, 8));
        end if;
  -----------------------------------------------------------------------------
  end if; -- if_reset
    
  end if;--if_1  
end process;


end Behavioral;
