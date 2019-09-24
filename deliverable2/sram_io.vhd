library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity sram_io is
  generic (
    width : positive := 32);
  port (
    clk            : in std_logic;
    switch         : in  std_logic_vector(9 downto 0);
    button0        : in  std_logic;
    wr_data        : in std_logic_vector(width-1 downto 0);
    mem_Read       : in std_logic;
    mem_Write      : in std_logic;
    address        : in std_logic_vector(width-1 downto 0);
    outport        : out std_logic_vector(width-1 downto 0);
    rd_data        : out std_logic_vector(width-1 downto 0);
    from_inport    : out std_logic);
end sram_io;


architecture BVH of sram_io is
signal reg1_en : std_logic;
signal reg2_en : std_logic;
signal reg1_out : std_logic_vector(width-1 downto 0);
signal inport0_in : std_logic_vector(width-1 downto 0);
signal inport1_in : std_logic_vector(width-1 downto 0);
signal reg2_out : std_logic_vector(width-1 downto 0);
signal data_out : std_logic_vector(width-1 downto 0);
signal mux_sel  : std_logic_vector(1 downto 0);
signal outport_en : std_logic;
signal inport0_en : std_logic;
signal inport1_en : std_logic;

signal reg1_out_temp : std_logic_vector(width-1 downto 0);
signal reg2_out_temp : std_logic_vector(width-1 downto 0);
begin
    process(button0, switch)
    begin
        if ((button0 = '1') and (switch(9) = '0')) then
            inport0_en <= '1';
        elsif((button0 = '1') and (switch(9) = '1')) then
            inport1_en <= '1';
        else 
            inport0_en <= '0';
            inport1_en <= '0';
        end if;
    end process;

U_RAM: entity work.ram_test  
port map (
    address => address(9 downto 2),
    clock => clk,
    data => wr_data,
    wren => mem_Write,
    q => data_out
);

U_MEM_CTRL: entity work.mem_control
port map (
    memRead => mem_Read,
    memWrite => mem_Write, 
    address => address, 
    sel => mux_sel,
    outport_en => outport_en,
    from_inport => from_inport
);
inport0_in <= "00000000000000010000000"& switch(8 downto 0);

U_REG1: entity work.reg 
generic map(width => 32)
port map(
    clk => clk,
    rst => '0',
    load => inport0_en,
    input => inport0_in,
    output => reg1_out_temp);

inport1_in <= "00000000000000000000000"& switch(8 downto 0);

U_REG1_DELAY : entity work.reg
generic map(width => 32)
port map(
    clk => clk,
    rst => '0',
    load => '1',
    input => reg1_out_temp,
    output => reg1_out
);

U_REG2: entity work.reg 
generic map(width => 32)
port map(
    clk => clk,
    rst => '0',
    load => inport1_en,
    input => inport1_in,
    output => reg2_out_temp);

U_REG2_DELAY: entity work.reg 
generic map(width => 32)
port map(
    clk => clk,
    rst => '0',
    load => '1',
    input => reg2_out_temp,
    output => reg2_out);


U_REG_OUT: entity work.reg
generic map(width => 32)
port map(
    clk => clk,
    rst => '0',
    load => outport_en,
    input => wr_data,
    output => outport);

U_MUX: entity work.mux3x1
generic map(width => 32)
port map(
    in1 => reg1_out,
    in2 => reg2_out, 
    in3 => data_out,
    sel => mux_sel,
    output => rd_data
);

end BVH;