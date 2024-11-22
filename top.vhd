----------------------------------------------------------------------------------
-- Author: Alan Salciccioli
-- 
-- Create Date: 11/01/2023 09:09:33 AM
-- Design Name: Top level Device
-- Module Name: top - Behavioral
-- Project Name: IPBlocks

-- Description: This file implements the top level design shown in figure 3 on the assignment document.
-- The device itself will recive and store data within one of two memory blocks. Once the signal start has 
-- become high, the device will take the data from its memory blocks and multiply the SIGNED values together, storing half the result in each blocks highest addresses.
-- Memory block 0 will store the higher weighted bits, while block 1 will store the lower weighted bits
-- 
-- Dependencies: DSP.vhd, system_controller.vhd

-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top is
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
end top;


architecture Behavioral of top is
component system_controller is
  generic (RESET_COUNT : integer := 32);
  port(
    clk_in    : in  std_logic;
    reset_in  : in  std_logic;
    clk_out   : out std_logic;
    locked    : out std_logic;
    reset_out : out std_logic
    );
end component;
component blk_mem_gen_0
  port (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    clkb : IN STD_LOGIC;
    enb : IN STD_LOGIC;
    web : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addrb : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    dinb : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) 
  );
end component;


component DSP is
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
end component;

--System Controller Outputs=======
signal Con_clk_out, Con_reset_out, Con_locked: std_logic;
--==================================
--Memory0 Outputs=======
signal Mem0_doutaA, Mem0_doutb: std_logic_vector(15 downto 0);
--==================================
--Memory1 Outputs=======
signal Mem1_doutaA, Mem1_doutb: std_logic_vector(15 downto 0);
--==================================
--DSP Outputs=================================================
signal DSP_addrb0, DSP_addrb1 : std_logic_vector(7 downto 0);
signal DSP_din0,DSP_din1 : std_logic_vector(15 downto 0);
signal DSP_web0,DSP_web1: std_logic_vector(0 downto 0);
signal DSP_enb0,DSP_enb1: std_logic;
--==================================



begin

DSP_0: DSP port map
(
    clk => Con_clk_out,
    reset => Con_reset_out,
    start => start,
    doutb0 =>Mem0_doutb,
    doutb1 => Mem1_doutb,
    addrb0 => DSP_addrb0,
    addrb1 => DSP_addrb1,
    dinb0 => DSP_din0,
    dinb1 => DSP_din1,
    enb0 => DSP_enb0,
    enb1 => DSP_enb1,
    web0 => DSP_web0,
    web1 => DSP_web1

);


Sys_Controller:system_controller port map
(
clk_in => clk_in,
reset_in => reset_in,
clk_out => Con_clk_out,
locked => locked,
reset_out => Con_reset_out

);

memory0: blk_mem_gen_0 port map
(
addra => addra0,
addrb => DSP_addrb0,
clka => Con_clk_out,
clkb => Con_clk_out,
dina => dina0,
dinb => DSP_din0,
ena => ena0,
enb => DSP_enb0,
wea => wea0,
web => DSP_web0,
douta => douta0,
doutb => Mem0_doutb
);

memory1: blk_mem_gen_0 port map
(
addra => addra1,
addrb => DSP_addrb1,
clka => Con_clk_out,
clkb => Con_clk_out,
dina => dina1,
dinb => DSP_din1,
ena => ena1,
enb => DSP_enb1,
wea => wea1,
web => DSP_web1,
douta => douta1,
doutb => Mem1_doutb



);


end Behavioral;
