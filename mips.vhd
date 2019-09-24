library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity mips is
    generic (
        WIDTH : positive := 32);
    port (
        clk    : in  std_logic;
        rst    : in  std_logic;
        switch : in std_logic_vector(9 downto 0);
        button0: in std_logic;
        output  : out std_logic_vector(WIDTH-1 downto 0)
        );
end mips;

architecture FSM_D2 of mips is
signal  op_code       : std_logic_vector(5 downto 0);
signal  PC_Write_Cond : std_logic;
signal  PC_Write      : std_logic;
signal  I_Or_D        : std_logic;
signal  Mem_Read      : std_logic;
signal  Mem_Write     : std_logic;
signal  Mem_To_Reg    : std_logic_vector(1 downto 0);
signal  IR_Write      : std_logic;
signal  Jump_And_Link : std_logic;
signal  Is_Signed     : std_logic;
signal  PC_Source     : std_logic_vector(1 downto 0);
signal  ALU_Op        : std_logic_vector(1 downto 0);
signal  ALU_Src_B     : std_logic_vector(1 downto 0);
signal  ALU_Src_A     : std_logic;
signal  Reg_Write     : std_logic;
signal  Reg_Dst       : std_logic;
signal from_inport    : std_logic;
signal output_splice  : std_logic_vector(5 downto 0);
begin
    U_CTRL : entity work.controller
    generic map(WIDTH => WIDTH)
    port map(
        clk           => clk,
        rst           => rst,
        op_code       => op_code,
        PC_Write_Cond => PC_Write_Cond,
        PC_Write      => PC_Write,
        I_Or_D        => I_Or_D,
        Mem_Read      => Mem_Read,
        Mem_Write     => Mem_Write,
        Mem_To_Reg    => Mem_To_Reg,
        IR_Write      => IR_Write,
        Jump_And_Link => Jump_And_Link,
        Is_Signed     => Is_Signed,
        PC_Source     => PC_Source,
        ALU_Op        => ALU_Op,
        ALU_Src_B     => ALU_Src_B,
        ALU_Src_A     => ALU_Src_A,
        Reg_Write     => Reg_Write,
        Reg_Dst       => Reg_Dst,
        from_inport   => from_inport,
        output_splice => output_splice);

    U_DATAPATH : entity work.datapath
    generic map(WIDTH => WIDTH)
    port map(
        clk           => clk,
        rst           => rst,
        switch        => switch,
        button0       => button0,
        PC_Write_Cond => PC_Write_Cond,
        PC_Write      => PC_Write,
        I_Or_D        => I_Or_D,
        Mem_Read      => Mem_Read,
        Mem_Write     => Mem_Write,
        Mem_To_Reg    => Mem_To_Reg,
        IR_Write      => IR_Write,
        Jump_And_Link => Jump_And_Link,
        Is_Signed     => Is_Signed,
        PC_Source     => PC_Source,
        ALU_Op        => ALU_Op,
        ALU_Src_B     => ALU_Src_B,
        ALU_Src_A     => ALU_Src_A,
        Reg_Write     => Reg_Write,
        Reg_Dst       => Reg_Dst,
        outport       => output,
        op_code       => op_code,
        from_inport   => from_inport,
        output_splice => output_splice);
end FSM_D2;