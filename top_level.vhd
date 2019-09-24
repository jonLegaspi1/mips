library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_level is 
    generic(width : positive := 32);
    port (
        clk     : in std_logic;
        rst     : in std_logic;
        button0 : in std_logic;
        switch  : in std_logic_vector(9 downto 0);
        led0     : out std_logic_vector(6 downto 0);
        led0_dp  : out std_logic;
        led1     : out std_logic_vector(6 downto 0);
        led1_dp  : out std_logic;
        led2     : out std_logic_vector(6 downto 0);
        led2_dp  : out std_logic;
        led3     : out std_logic_vector(6 downto 0);
        led3_dp  : out std_logic;
        led4     : out std_logic_vector(6 downto 0);
        led4_dp  : out std_logic;
        led5     : out std_logic_vector(6 downto 0);
        led5_dp  : out std_logic);


end top_level;


architecture STR of top_level is

    signal outport : std_logic_vector(width-1 downto 0);
    component decoder7seg
        port (
            input  : in  std_logic_vector(3 downto 0);
            output : out std_logic_vector(6 downto 0));
    end component;
    constant C0         : std_logic_vector(3 downto 0) := (others => '0');

begin

    U_MIPS : entity work.mips 
        generic map(
            width => width)
        port map(
            clk => clk,
            rst => not(rst),
            switch => switch,
            button0 => button0,
            output => outport);
    U_LED5 : decoder7seg port map (
        input  => outport(23 downto 20),
        output => led5);

    U_LED4 : decoder7seg port map (
        input  => outport(19 downto 16),
        output => led4);
    
    U_LED3 : decoder7seg port map (
        input  => outport(15 downto 12),
        output => led3);

    U_LED2 : decoder7seg port map (
        input  => outport(11 downto 8),
        output => led2);
    
    U_LED1 : decoder7seg port map (
        input  => outport(7 downto 4),
        output => led1);

    U_LED0 : decoder7seg port map (
        input  => outport(3 downto 0),
        output => led0);

    led5_dp <= '1';
    led4_dp <= '1';
    led3_dp <= '1';
    led2_dp <= '1';
    led1_dp <= '1';
    led0_dp <= '1';

end STR;