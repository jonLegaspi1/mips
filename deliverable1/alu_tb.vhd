library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity alu_tb is
end alu_tb;

architecture TB of alu_tb is
    constant C_ADD      : std_logic_vector(4 downto 0) := "00000";
    constant C_ADD_I    : std_logic_vector(4 downto 0) := "00001";
    constant C_SUB      : std_logic_vector(4 downto 0) := "00010";
    constant C_SUB_I    : std_logic_vector(4 downto 0) := "00011";
    constant C_MULT     : std_logic_vector(4 downto 0) := "00100";
    constant C_MULT_U   : std_logic_vector(4 downto 0) := "00101";
    constant C_AND      : std_logic_vector(4 downto 0) := "00110";
    constant C_AND_I    : std_logic_vector(4 downto 0) := "00111";
    constant C_OR       : std_logic_vector(4 downto 0) := "01000";
    constant C_OR_I     : std_logic_vector(4 downto 0) := "01001";
    constant C_XOR      : std_logic_vector(4 downto 0) := "01010";
    constant C_XOR_I    : std_logic_vector(4 downto 0) := "01011";
    constant C_SRL      : std_logic_vector(4 downto 0) := "01100";
    constant C_SLL      : std_logic_vector(4 downto 0) := "01101";
    constant C_SRA      : std_logic_vector(4 downto 0) := "01110";
    constant C_SLT      : std_logic_vector(4 downto 0) := "01111";
    constant C_SLT_I    : std_logic_vector(4 downto 0) := "10000";
    constant C_SLT_I_U  : std_logic_vector(4 downto 0) := "10001";
    constant C_SLT_U    : std_logic_vector(4 downto 0) := "10010";
    constant C_MFHI     : std_logic_vector(4 downto 0) := "10011";
    constant C_MFLO     : std_logic_vector(4 downto 0) := "10100";
    constant C_LOAD     : std_logic_vector(4 downto 0) := "10101";
    constant C_STORE    : std_logic_vector(4 downto 0) := "10110";
    constant C_BEQ      : std_logic_vector(4 downto 0) := "10111";
    constant C_BNEQ     : std_logic_vector(4 downto 0) := "11000";
    constant C_BLEZ     : std_logic_vector(4 downto 0) := "11001";
    constant C_BGTZ     : std_logic_vector(4 downto 0) := "11010";
    constant C_BLTZ     : std_logic_vector(4 downto 0) := "11011";
    constant C_BGEZ     : std_logic_vector(4 downto 0) := "11100";
    constant C_J        : std_logic_vector(4 downto 0) := "11101";
    constant C_JAL      : std_logic_vector(4 downto 0) := "11110";
    constant C_JR       : std_logic_vector(4 downto 0) := "11111";

    component alu

        generic (
            WIDTH : positive := 32
            );
        port (
            input1          : in  std_logic_vector(WIDTH-1 downto 0);
            input2          : in  std_logic_vector(WIDTH-1 downto 0);
            shift_amount    : in std_logic_vector(5 downto 0);
            sel             : in  std_logic_vector(4 downto 0);
            branch_taken    : out std_logic;
            result_hi       : out std_logic_vector(WIDTH-1 downto 0);
            output          : out std_logic_vector(WIDTH-1 downto 0)            
            );

    end component;

    constant WIDTH          : positive                           := 32;
    signal input1           : std_logic_vector(WIDTH-1 downto 0) := (others => '0');
    signal input2           : std_logic_vector(WIDTH-1 downto 0) := (others => '0');
    signal shift_amount     : std_logic_vector(5 downto 0) := (others => '0');
    signal sel              : std_logic_vector(4 downto 0)       := (others => '0');
    signal branch_taken     : std_logic;
    signal result_hi        : std_logic_vector(WIDTH-1 downto 0) := (others => '0');
    signal output           : std_logic_vector(WIDTH-1 downto 0);


begin  
    UUT : alu
        generic map (WIDTH => WIDTH)
        port map (
            input1          => input1,
            input2          => input2,
            shift_amount    => shift_amount,
            sel             => sel,
            branch_taken    => branch_taken,
            result_hi       => result_hi,
            output          => output);
    process
    begin
        sel    <= C_ADD;
        input1 <= conv_std_logic_vector(10, input1'length);
        input2 <= conv_std_logic_vector(15, input2'length);
        wait for 40 ns;
        assert(output = conv_std_logic_vector(25, output'length)) report "Error : 10+15 = " & integer'image(conv_integer(output)) & " instead of 25" severity warning;
    
        sel    <= C_SUB;
        input1 <= conv_std_logic_vector(25, input1'length);
        input2 <= conv_std_logic_vector(10, input2'length);
        wait for 40 ns;
        assert(output = conv_std_logic_vector(15, output'length)) report "Error : 25-10 = " & integer'image(conv_integer(output)) & " instead of 15" severity warning;
    
        sel    <= C_MULT;
        input1 <= conv_std_logic_vector(10, input1'length);
        input2 <= conv_std_logic_vector(-4, input2'length);
        wait for 40 ns;
        assert(output = conv_std_logic_vector(-40, output'length)) report "Error : 10 * -4 = " & integer'image(conv_integer(output)) & " instead of -40" severity warning;
        assert(result_hi = x"FFFFFFFF") report "Error result_hi =  " & integer'image(conv_integer(result_hi)) & " instead of FFFF FFFF" severity warning;
 
        sel    <= C_MULT_U;
        input1 <= conv_std_logic_vector(65536, input1'length);
        input2 <= conv_std_logic_vector(131072, input2'length);
        wait for 40 ns;
        assert(output = x"00000000") report "Error : 65536 * 131072 = " & integer'image(conv_integer(output)) & " instead of " severity warning;
        assert(result_hi = x"00000002") report "Error result_hi =  " & integer'image(conv_integer(result_hi)) & " instead of 0000 0002" severity warning;

        sel     <= C_AND;
        input1 <= x"0000FFFF";
        input2 <= x"FFFF1234";
        wait for 40 ns;
        assert(output = x"00001234") report "Error : 0x0000FFFF * FFFF1234 = " & integer'image(conv_integer(output)) & " instead of 4660" severity warning;

        sel     <= C_SRL;
        input1  <= x"0000000F";
        input2  <= x"FFFFFFFF";
        shift_amount <= "000100";
        wait for 40 ns;
        assert(output = x"00000000") report "Error : shift right logic 0x0000000F = " & integer'image(conv_integer(output)) & " instead of 0x0000003" severity warning;

        sel     <= C_SRA;
        input1  <= x"F0000008";
        input2  <= x"FFFFFFFF";
        shift_amount <= "000001";
        wait for 40 ns;
        assert(output = x"F8000004") report "Error : shift right logic 0x8000000F = " & integer'image(conv_integer(output)) & " instead of 0x78000004" severity warning;

        sel     <= C_SRA;
        input1  <= x"00000008";
        input2  <= x"FFFFFFFF";
        shift_amount <= "000001";
        wait for 40 ns;
        assert(output = x"00000004") report "Error : shift right logic 0x00000008 = " & integer'image(conv_integer(output)) & " instead of 0x00000004" severity warning;

        sel     <= C_SLT_U;
        input1 <= conv_std_logic_vector(10, input1'length);
        input2 <= conv_std_logic_vector(15, input2'length);
        wait for 40 ns;
        assert(output = x"00000001") report "Error : set on less than (unsigned) of 10 and 15 is " & integer'image(conv_integer(output)) & " instead of 1" severity warning;
    
        sel     <= C_SLT_U;
        input1 <= conv_std_logic_vector(15, input1'length);
        input2 <= conv_std_logic_vector(10, input2'length);
        wait for 40 ns;
        assert(output = x"00000000") report "Error : set on less than (unsigned) of 10 and 15 is " & integer'image(conv_integer(output)) & " instead of 0" severity warning;

        sel     <= C_BLEZ;
        input1 <= conv_std_logic_vector(5, input1'length);
        input2 <= conv_std_logic_vector(12345, input2'length);
        wait for 40 ns;
        assert(output = x"00000000") report "Error : BLEZ with input1 = 5 is  " & integer'image(conv_integer(output)) & " instead of 0" severity warning;

        sel     <= C_BGTZ;
        input1 <= conv_std_logic_vector(5, input1'length);
        input2 <= conv_std_logic_vector(12345, input2'length);
        wait for 40 ns;
        assert(output = x"00000001") report "Error : BLEZ with input1 = 5 is  " & integer'image(conv_integer(output)) & " instead of 1" severity warning;

        wait;
    end process;
end TB;