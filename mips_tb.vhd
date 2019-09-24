library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mips_tb is
end mips_tb;

architecture TB of mips_tb is

    component mips
    generic(WIDTH : positive := 32);
    port(
        clk    : in  std_logic;
        rst    : in  std_logic;
        switch : in std_logic_vector(9 downto 0);
        button0: in std_logic;
        output  : out std_logic_vector(WIDTH-1 downto 0)
    );
    end component;
    constant WIDTH          : positive                           := 32;
    signal clk    : std_logic := '0';
    signal rst    : std_logic := '0';
    signal switch : std_logic_vector(9 downto 0) := (others => '0');
    signal button0: std_logic := '0';
    signal output : std_logic_vector(WIDTH-1 downto 0);


begin
    UUT : mips
        generic map(WIDTH => WIDTH)
        port map(
            clk     => clk,
            rst     => rst,
            switch  => switch,
            button0 => button0,
            output  => output);

            clk <= not clk after 10 ns;
        process
        begin
            button0 <= '0';
            rst <= '1';
            wait for 10 ns;

            rst <= '0';
            switch(9) <= '0';
            switch(8 downto 0) <= "000000100";
            
            wait for 20 ns;

            --button0 <= '0';

            wait for 20 ns;


            switch(9) <= '1';
            switch(8 downto 0) <= "000000010";
            --button0 <= '1';
            wait for 20 ns;

            --button0 <= '0';
            wait for 100000 ns;

            assert(output=output);
            --report "simulation finished successfully" severity FAILURE;

            wait;
        end process;
end TB;