library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
  generic (
    width : positive := 32);
  port (
    input1              : in  std_logic_vector(width-1 downto 0);
    input2              : in  std_logic_vector(width-1 downto 0);
    shift_amount        : in  std_logic_vector(4 downto 0);
    sel                 : in  std_logic_vector(4 downto 0);
    branch_taken        : out std_logic;
    result_hi           : out std_logic_vector(width-1 downto 0);
    output              : out std_logic_vector(width-1 downto 0));
end alu;

architecture BHV of alu is  
    constant C_ADD      : std_logic_vector(4 downto 0) := "00000"; --done
    constant C_ADD_I    : std_logic_vector(4 downto 0) := "00001"; --done
    constant C_SUB      : std_logic_vector(4 downto 0) := "00010"; --done
    constant C_SUB_I    : std_logic_vector(4 downto 0) := "00011"; --done
    constant C_MULT     : std_logic_vector(4 downto 0) := "00100"; --done
    constant C_MULT_U   : std_logic_vector(4 downto 0) := "00101"; --done
    constant C_AND      : std_logic_vector(4 downto 0) := "00110"; --done
    constant C_AND_I    : std_logic_vector(4 downto 0) := "00111"; --done
    constant C_OR       : std_logic_vector(4 downto 0) := "01000"; --done
    constant C_OR_I     : std_logic_vector(4 downto 0) := "01001"; --done
    constant C_XOR      : std_logic_vector(4 downto 0) := "01010"; --done
    constant C_XOR_I    : std_logic_vector(4 downto 0) := "01011"; --done
    constant C_SRL      : std_logic_vector(4 downto 0) := "01100"; --done
    constant C_SLL      : std_logic_vector(4 downto 0) := "01101"; --done
    constant C_SRA      : std_logic_vector(4 downto 0) := "01110"; --done
    constant C_SLT      : std_logic_vector(4 downto 0) := "01111"; --done
    constant C_SLT_I    : std_logic_vector(4 downto 0) := "10000"; --done
    constant C_SLT_I_U  : std_logic_vector(4 downto 0) := "10001"; --done
    constant C_SLT_U    : std_logic_vector(4 downto 0) := "10010"; --done
    constant C_MFHI     : std_logic_vector(4 downto 0) := "10011"; --doesn't matter
    constant C_MFLO     : std_logic_vector(4 downto 0) := "10100"; --doesn't matter
    constant C_LOAD     : std_logic_vector(4 downto 0) := "10101"; --check with ta
    constant C_STORE    : std_logic_vector(4 downto 0) := "10110"; --check with ta
    constant C_BEQ      : std_logic_vector(4 downto 0) := "10111"; 
    constant C_BNEQ     : std_logic_vector(4 downto 0) := "11000"; 
    constant C_BLEZ     : std_logic_vector(4 downto 0) := "11001"; 
    constant C_BGTZ     : std_logic_vector(4 downto 0) := "11010"; 
    constant C_BLTZ     : std_logic_vector(4 downto 0) := "11011"; 
    constant C_BGEZ     : std_logic_vector(4 downto 0) := "11100"; 
    constant C_J        : std_logic_vector(4 downto 0) := "11101"; 
    constant C_JAL      : std_logic_vector(4 downto 0) := "11110"; 
    constant C_JR       : std_logic_vector(4 downto 0) := "11111"; 

begin
    process(input1, input2, sel)
        variable temp       : unsigned(width-1 downto 0);
        variable temp_mult  : signed(2*(width)-1 downto 0);
        variable temp_mult_u  : unsigned(2*(width)-1 downto 0);
        variable shift      : integer;
    begin
        result_hi <= (others => '0');
        branch_taken <= '0';
        temp := x"00000000";

        case sel is
        when C_ADD =>
            temp := unsigned(input1)+unsigned(input2);
            
        when C_ADD_I =>
            temp := unsigned(input1)+unsigned(input2);

        when C_SUB =>
            temp := unsigned(input1)-unsigned(input2);

        when C_SUB_I =>
            temp := unsigned(input1)-unsigned(input2);

        when C_MULT =>
            temp_mult := signed(input1)*signed(input2);
            result_hi <= std_logic_vector(temp_mult(2*(width)-1 downto width));
            temp := unsigned(temp_mult(width-1 downto 0));

        when C_MULT_U =>
            temp_mult_u := unsigned(input1)*unsigned(input2);
            result_hi <= std_logic_vector(temp_mult_u(2*(width)-1 downto width));
            temp := unsigned(temp_mult_u(width-1 downto 0));
        when C_AND =>
            temp := unsigned(input1) and unsigned(input2);

        when C_AND_I =>
            temp := unsigned(input1) and unsigned(input2);
        
        when C_OR =>
            temp := unsigned(input1) or unsigned(input2);
        when C_OR_I =>
            temp := unsigned(input1) or unsigned(input2);
        when C_XOR =>
            temp := unsigned(input1) xor unsigned(input2);
        when C_XOR_I =>
            temp := unsigned(input1) xor unsigned(input2);

        when C_SRL =>
            shift := to_integer(unsigned(shift_amount));
            temp := shift_right(unsigned(input2), shift);

        when C_SLL =>
            shift := to_integer(unsigned(shift_amount));
            temp := shift_left(unsigned(input2), shift);
            
        when C_SRA =>
            shift := to_integer(signed(shift_amount));
            temp := unsigned(shift_right(signed(input2), shift));

        when C_SLT => 
            if (signed(input1) < signed(input2)) then
                temp := x"00000001";
            else
                temp := x"00000000";
            end if;
        when C_SLT_I => 
            if (signed(input1) < signed(input2)) then
                temp := x"00000001";
            else
                temp := x"00000000";
            end if;
        when C_SLT_I_U =>
            if (unsigned(input1) < unsigned(input2)) then
                temp := x"00000001";
            else 
                temp := x"00000000";
            end if;
        when C_SLT_U =>
            if (unsigned(input1) < unsigned(input2)) then
                temp := x"00000001";
            else 
                temp := x"00000000";
            end if;
        when C_MFHI =>
        when C_MFLO =>
        when C_LOAD =>
            temp := unsigned(input1)+unsigned(input2);
        when C_STORE =>
            temp := unsigned(input1)+unsigned(input2);
        when C_BEQ =>
            if (signed(input1) = signed(input2)) then
                branch_taken <= '1';
            end if;
        when C_BNEQ =>
            if (signed(input1) /= signed(input2)) then
                branch_taken <= '1';
            end if;
        
        when C_BLEZ =>
            if (signed(input1) <= 0) then
                branch_taken <= '1';                
                temp := x"00000001";
            else 
                temp := x"00000000";
            end if;
        when C_BGTZ =>
            if (signed(input1) > 0) then
                branch_taken <= '1';
                temp := x"00000001";
            else 
                temp := x"00000000";
            end if;
        when C_BLTZ =>
            if (signed(input1) < 0) then
                branch_taken <= '1';
                temp := x"00000001";
            else 
                temp := x"00000000";
            end if;
        when C_BGEZ =>
            if (signed(input1) >= 0) then
                branch_taken <= '1';
                temp := x"00000001";
            else 
                temp := x"00000000";
            end if;
        when C_JR =>
            temp := unsigned(input1)+unsigned(input2) - 4;
        when others => null;
    end case;


        output <= std_logic_vector(temp);
    end process;
end BHV;
