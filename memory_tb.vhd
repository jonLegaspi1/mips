library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;


entity memory_tb is
end memory_tb;

architecture TB of memory_tb is

    component sram_io

        generic (
            WIDTH : positive := 32
            );
            port (
                clk            : in std_logic;
                switch         : in  std_logic_vector(9 downto 0);
                button0        : in  std_logic;
                wr_data        : in std_logic_vector(width-1 downto 0);
                mem_Read       : in std_logic;
                mem_Write      : in std_logic;
                address        : in std_logic_vector(width-1 downto 0);
                outport        : out std_logic_vector(width-1 downto 0);
                rd_data        : out std_logic_vector(width-1 downto 0));

    end component;

    constant WIDTH  : positive                           := 32;
            signal    clk            : std_logic := '0';
            signal    switch         : std_logic_vector(9 downto 0);
            signal    button0        : std_logic;
            signal    wr_data        : std_logic_vector(width-1 downto 0);
            signal    mem_Read       : std_logic;
            signal    mem_Write      : std_logic;
            signal    address        : std_logic_vector(width-1 downto 0);
            signal    outport        : std_logic_vector(width-1 downto 0);
            signal    rd_data        : std_logic_vector(width-1 downto 0);

begin  -- TB

    UUT : sram_io
        generic map (WIDTH => WIDTH)
        port map (
        clk => clk,
        switch => switch,
        button0 => button0,
        wr_data => wr_data,
        mem_Read => mem_Read,
        mem_Write => mem_Write,
        address => address,
        outport => outport,
        rd_data => rd_data );

        clk <= not clk after 10 ns;
    process
    begin

    switch <= "0000000000";
    button0 <= '1';
    wr_data <= x"00000000";
    address <= x"00000000";
    mem_Read <= '1';
    mem_Write <= '1';
    
    wait for 5 ns;
    
    --Write 0x0A0A0A0A to byte address 0x00000000/Read
    address <= x"00000000";
    wr_data <= x"0A0A0A0A";
    mem_Read <= '0'; 
    mem_Write <= '1';
    wait for 20 ns;

    --Write 0xF0F0F0F0 to byte address 0x00000004
    address <= x"00000004";
    wr_data <= x"F0F0F0F0";
    mem_Read <= '0'; 
    mem_Write <= '1';
    wait for 20 ns;

    --Read from byte address 0x00000000 (should show 0x0A0A0A0A on read data output)
    mem_Write <= '0';
    mem_Read <= '1'; 
    address <= x"00000000";
    wait for 20 ns;

    --Read from byte address 0x00000001 (should show 0x0A0A0A0A on read data output)
    mem_Write <= '0';
    mem_Read <= '1'; 
    address <= x"00000001";
    wait for 20 ns;

    --Read from byte address 0x00000004 (should show 0xF0F0F0F0 on read data output)
    mem_Write <= '0';
    mem_Read <= '1'; 
    address <= x"00000004";
    wait for 20 ns;

    --Read from byte address 0x00000005 (should show 0xF0F0F0F0 on read data output)
    mem_Write <= '0';
    mem_Read <= '1'; 
    address <= x"00000005";
    wait for 20 ns;
    
    --Write 0x00001111 to the outport (should see value appear on outport)
    address <= x"0000FFFC";
    wr_data <= x"00001111";
    mem_Write <= '1';
    mem_Read <= '0';
    wait for 20 ns;

    --Load 0x00000001 into inport 1 and Read from inport 1
    address <= x"0000FFFC";
    button0 <= '1';
    switch(9) <= '1';
    switch(8 downto 0) <= "000000001";
    mem_Write <= '0';
    mem_Read <= '1';
    wait for 20 ns;

    --Load 0x00000001 into inport 0 and Read from inport 0
    address <= x"0000FFF8";
    button0 <= '1';
    switch(9) <= '0';
    switch(8 downto 0) <= "000000000";
    mem_Write <= '0';
    mem_Read <= '1';
    wait for 20 ns;

    report "simulation finished successfully" severity FAILURE;

    wait;

    end process;
end TB;