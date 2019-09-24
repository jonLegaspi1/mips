library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity datapath is
  generic (
    width : positive := 32);
  port ( 
    clk           : in std_logic;
    rst           : in std_logic;
    switch        : in std_logic_vector(9 downto 0);
    button0       : in std_logic;
    PC_Write_Cond : in std_logic;
    PC_Write      : in std_logic;
    I_Or_D        : in std_logic;
    Mem_Read      : in std_logic;
    Mem_Write     : in std_logic;
    Mem_To_Reg    : in std_logic_vector(1 downto 0);
    IR_Write      : in std_logic;
    Jump_And_Link : in std_logic;
    Is_Signed     : in std_logic;
    PC_Source     : in std_logic_vector(1 downto 0);
    ALU_Op        : in std_logic_vector(1 downto 0);
    ALU_Src_B     : in std_logic_vector(1 downto 0);
    ALU_Src_A     : in std_logic;
    Reg_Write     : in std_logic;
    Reg_Dst       : in std_logic;
    outport       : out std_logic_vector(width-1 downto 0);
    op_code       : out std_logic_vector(5 downto 0);
    from_inport   : out std_logic;
    output_splice  : out std_logic_vector(5 downto 0));
end datapath;

architecture STR of datapath is
  signal PC_Input     : std_logic_vector(width-1 downto 0);
  signal Branch_Taken : std_logic;
  signal Mux_Out_Addr : std_logic_vector(width-1 downto 0);
  signal PC_Output    : std_logic_vector(width-1 downto 0);
  signal PC_Load      : std_logic;

  signal Mux_Out_Ram  : std_logic_vector(width-1 downto 0);
  signal Reg_ALU_Out  : std_logic_vector(width-1 downto 0);

  signal RegA_Out     : std_logic_vector(width-1 downto 0);
  signal RegB_Out     : std_logic_vector(width-1 downto 0);
  signal rd_data      : std_logic_vector(width-1 downto 0);

  signal output_25_0     : std_logic_vector(25 downto 0);
  signal output_31_26    : std_logic_vector(5 downto 0);
  signal output_25_21    : std_logic_vector(4 downto 0);
  signal output_20_16    : std_logic_vector(4 downto 0);
  signal output_15_11    : std_logic_vector(4 downto 0);
  signal output_15_0     : std_logic_vector(15 downto 0);
  signal output_10_6     : std_logic_vector(4 downto 0);

  signal output_31_26_extended    : std_logic_vector(width-1 downto 0);
  signal output_25_21_extended    : std_logic_vector(width-1 downto 0);
  signal output_20_16_extended    : std_logic_vector(width-1 downto 0);
  signal output_15_11_extended    : std_logic_vector(width-1 downto 0);




  signal Reg_Data_Mem_Out : std_logic_vector(width-1 downto 0);

  signal Mux_Out_WR_Reg   : std_logic_vector(width-1 downto 0);

  signal Mux_Out_ALU      : std_logic_vector(width-1 downto 0);
  signal Mux_Out_WR_Data  : std_logic_vector(width-1 downto 0);

  signal Reg_A            : std_logic_vector(width-1 downto 0);
  signal Reg_B            : std_logic_vector(width-1 downto 0);

  signal input1           : std_logic_vector(width-1 downto 0);
  signal input2           : std_logic_vector(width-1 downto 0);

  signal in3              : std_logic_vector(width-1 downto 0);
  signal in4              : std_logic_vector(width-1 downto 0);

  signal OP_Select        : std_logic_vector(4 downto 0);
  signal Reg_HI_In        : std_logic_vector(width-1 downto 0);
  signal ALU_Out_In       : std_logic_vector(width-1 downto 0);

  signal HI_en            : std_logic;
  signal HI_Out           : std_logic_vector(width-1 downto 0);
  signal LO_en            : std_logic;
  signal LO_Out           : std_logic_vector(width-1 downto 0);

  signal ALU_LO_HI        : std_logic_vector(1 downto 0);

  signal next_PC_addr     : std_logic_vector(width-1 downto 0);

  signal Mem_To_Reg_AND   : std_logic;
  signal Mem_To_Reg_RS    : std_logic_vector(0 downto 0);
  signal Mem_To_Reg_RS_Delay : std_logic_vector(0 downto 0);
  signal Reg_Write_AND    : std_logic;

begin
process(PC_Write, Branch_Taken, PC_Write_Cond)
  begin
    PC_Load <= ((PC_Write_Cond and Branch_Taken) or PC_Write);
end process;

process(output_31_26)
begin
  op_code <= output_31_26;
end process;

output_splice <= output_15_0(5 downto 0);
  U_PC: entity work.reg 
    generic map(width => 32)
    port map(
      clk => clk,
      rst => rst,
      load => PC_Load,
      input => Mux_Out_Addr,
      output => PC_Output);

  U_MUX_2x1_RAM: entity work.mux2x1
    generic map(width => 32)
    port map(
      in1 => PC_Output,
      in2 => Reg_ALU_Out,
      sel => I_Or_D,
      output  => Mux_Out_Ram);

  U_RAM : entity work.sram_io
    generic map(width => 32)
    port map(
      clk => clk,
      rst => rst,
      switch  => switch,
      button0 => button0,
      wr_data => RegB_Out,
      mem_Read  => Mem_Read,
      mem_Write => Mem_Write,
      address   => Mux_Out_Ram,
      outport => outport,
      rd_data => rd_data,
      from_inport => from_inport);

  U_REG_IR  : entity work.reg_ir
    generic map(width => 32)
    port map(
      clk => clk,
      rst => rst,
      load  => IR_Write,
      input => rd_data,
      output_25_0  => output_25_0,
      output_31_26 => output_31_26,
      output_25_21 => output_25_21,
      output_20_16 => output_20_16,
      output_15_11 => output_15_11,
      output_15_0  => output_15_0);

  

output_31_26_extended <= x"000000" & "00" & output_31_26;
output_25_21_extended <= x"000000" & "000" & output_25_21;
output_20_16_extended <= x"000000" & "000" & output_20_16;
output_15_11_extended <= x"000000" & "000" & output_15_11;

  U_REG_DATA_MEM  : entity work.reg
    generic map(width => 32)
    port map(
      clk => clk,
      rst => rst,
      load  => '1',
      input => rd_data,
      output => Reg_Data_Mem_Out);
  U_MUX_2x1_WR_REG  : entity work.mux2x1
    generic map(width => 32)
    port map(
      in1 => output_20_16_extended,
      in2 => output_15_11_extended,
      sel => Reg_Dst,
      output => Mux_Out_WR_Reg);
  --Mem_To_Reg_AND <= Reg_Dst and Mem_To_Reg_RS;
  --U_MUX_2x1_WR_DATA : entity work.mux2x1
  --  generic map(width => 32)
  --  port map(
  --    in1 => Mux_Out_ALU,
  --    in2 => Reg_Data_Mem_Out,
  --    sel => Mem_To_Reg,
  --    output => Mux_Out_WR_Data);
  U_MUX_3x1_WR_DATA : entity work.mux3x1
    generic map(width => 32)
    port map(
      in1 => Mux_Out_ALU,
      in2 => Reg_Data_Mem_Out,
      in3 => rd_data,
      sel => Mem_To_Reg,
      output => Mux_Out_WR_Data);

  U_REG_FILE  : entity work.register_file
    generic map(width => 32)
    port map(
      clk => clk,
      rst => rst,
      rd_addr0  => output_25_21_extended,
      rd_addr1  => output_20_16_extended,
      wr_addr => Mux_Out_WR_Reg,
      wr_en => Reg_Write,
      jal => Jump_And_Link,
      wr_data => Mux_Out_WR_Data,
      rd_data0 => Reg_A,
      rd_data1 => Reg_B);
      
--U_REG_MULT_WR_STOP : entity work.reg
--  generic map(width => 1)
--  port map(
--    clk => clk,
--    rst => rst,
--    load => '1',
--    input => Mem_To_Reg_RS,
--    output => Mem_To_Reg_RS_Delay);
--  Reg_Write_AND <= Reg_Write and Mem_To_Reg_RS_Delay(0);

  U_REG_A : entity work.reg
    generic map(width => 32)
    port map(
      clk => clk,
      rst => rst,
      load => '1',
      input => Reg_A,
      output => RegA_Out);
  U_REG_B : entity work.reg
    generic map(width => 32)
    port map(
      clk => clk,
      rst => rst,
      load => '1',
      input => Reg_B,
      output => RegB_Out);
  U_MUX_2x1_ALU_INPUT1 : entity work.mux2x1
    generic map(width => 32)
    port map(
      in1 => PC_Output,
      in2 => RegA_Out,
      sel => ALU_Src_A,
      output => input1);
  U_MUX_4x1_ALU_INPUT2 : entity work.mux4x1
    generic map(width => 32)
    port map(
      in1 => RegB_Out,
      in2 => x"00000004",
      in3 => in3,
      in4 => in4,
      sel => ALU_Src_B,
      output => input2);
      
  process(output_15_0)
  begin
    if(output_15_0(15) = '1') then
      --in3 and in4 might need to be signals
      in3 <= x"FFFF" & output_15_0;
      in4 <= x"FFFF" & std_logic_vector(shift_left(unsigned(output_15_0), 2));
    else
      in3 <= x"0000" & output_15_0;
      in4 <= x"0000" & std_logic_vector(shift_left(unsigned(output_15_0), 2));
    end if;
  end process;

  U_ALU : entity work.alu
    generic map(width => 32)
    port map(
      input1 => input1,
      input2 => input2,
      shift_amount => output_10_6,
      sel => OP_Select,
      branch_taken => Branch_Taken,
      result_hi => Reg_HI_In,
      output => ALU_Out_In);
  U_ALU_CONTROLLER : entity work.controller_alu
    generic map(width => 32)
    port map(
      ALU_Op => ALU_Op,
      output_31_26 => output_31_26,
      output_20_16 => output_20_16,
      output_splice => output_15_0,
      OP_Select => OP_select,
      HI_en => HI_en,
      LO_en => LO_en,
      ALU_LO_HI => ALU_LO_HI,
      Mem_To_Reg_RS => Mem_To_Reg_RS);
  --CHECK WITH TA
  output_10_6 <= output_15_0(10 downto 6);
  
  U_REG_ALU_OUT : entity work.reg
    generic map(width => 32)
    port map(
      clk => clk,
      rst => rst,
      load => '1',
      input => ALU_Out_In,
      output => Reg_ALU_Out);
  U_REG_LO  : entity work.reg
    generic map(width => 32)
    port map(
      clk => clk,
      rst => rst,
      load => LO_en,
      input => ALU_Out_In,
      output => LO_Out);
  U_REG_HI  : entity work.reg
    generic map(width => 32)
    port map(
      clk => clk,
      rst => rst,
      load => HI_en,
      input => Reg_HI_In,
      output => HI_Out);
  U_MUX_3x1_ALU : entity work.mux3x1
    generic map(width => 32)
    port map(
      in1 => Reg_ALU_Out,
      in2 => LO_Out,
      in3 => HI_Out,
      sel => ALU_LO_HI,
      output => Mux_Out_ALU);
  U_MUX_3x1_ADDRESS : entity work.mux3x1
    generic map(width => 32)
    port map(
      in1 => ALU_Out_In,
      in2 => Reg_ALU_Out,
      in3 => next_PC_addr,
      sel => PC_Source,
      output => Mux_Out_Addr);
  next_PC_addr <= PC_Output(31 downto 28) & output_25_0 (25 downto 0) & "00";

end STR;  