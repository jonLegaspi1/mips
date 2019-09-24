library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller_alu is
    generic(
        WIDTH : positive := 32);
    port(
        ALU_Op          : in std_logic_vector(1 downto 0);
        output_31_26    : in std_logic_vector(5 downto 0); --opcode
        output_splice   : in std_logic_vector(15 downto 0); --splice
        output_20_16    : in std_logic_vector(4 downto 0); 
        OP_Select       : out std_logic_vector(4 downto 0);
        HI_en           : out std_logic;
        LO_en           : out std_logic;
        ALU_LO_HI       : out std_logic_vector(1 downto 0);
        Mem_To_Reg_RS   : out std_logic_vector(0 downto 0));
    
end controller_alu;

architecture BHV of controller_alu is
signal output_5_0       : std_logic_vector(5 downto 0);
begin
    process(ALU_Op, output_31_26, output_5_0)
    begin
        HI_en <= '0';
        LO_en <= '0';
        Mem_To_Reg_RS <= "1";
        ALU_LO_HI <= "00";
        OP_Select <= "00000";
        if(ALU_Op = "00") then
            if(output_5_0 = "001000") then
                OP_Select <= "00000";
            end if;
            if (output_5_0 = "010000") then
                --choose hi
                ALU_LO_HI <= "10";
            elsif (output_5_0 = "010010") then
                --choose lo
                ALU_LO_HI <= "01";
            end if;
        elsif(ALU_Op = "10") then
            if(output_5_0 = "100000") then
                --ADD
                OP_Select <= "00000";
            elsif (output_5_0 = "100011") then
                --SUB
                OP_Select <= "00010";
            elsif (output_5_0 = "100100") then
                --AND
                OP_Select <= "00110";
            elsif (output_5_0 = "100101") then
                --OR
                OP_Select <= "01000";
            elsif (output_5_0 = "100110") then
                OP_Select <= "01010";
            elsif (output_5_0 = "011000") then
                --MULT
                OP_Select <= "00100";
                HI_en <= '1';
                LO_en <= '1';
                Mem_To_Reg_RS <= "0";
            elsif (output_5_0 = "011001") then
                --MULTU
                OP_Select <= "00101";
                HI_en <= '1';
                LO_en <= '1';
                Mem_To_Reg_RS <= "0";
            elsif (output_5_0 = "000010") then
                --SRL
                OP_Select <= "01100";
            elsif (output_5_0 = "000000") then
                --SLL
                OP_Select <= "01101";
            elsif (output_5_0 = "000011") then
                --SRA
                OP_Select <= "01110";
            elsif (output_5_0 = "101010") then
                --SLT
                OP_Select <= "01111";
            elsif (output_5_0 = "101011") then
                --SLT
                OP_Select <= "10010";
            elsif (output_5_0 = "010000") then
                --MFHI
                OP_Select <= "10011";
                ALU_LO_HI <= "10";
            elsif (output_5_0 = "010010") then
                --MFLO
                OP_Select <= "10100";
                ALU_LO_HI <= "01";
            end if;
        elsif (ALU_Op = "01") then
            if (output_31_26 = "001001") then
                --ADD_I(u)
                OP_Select <= "00001";
            elsif (output_31_26 = "010000") then
                --SUBI
                OP_Select <= "00011";
            elsif (output_31_26 = "001100") then
                --AND_I
                OP_Select <= "00111";
            elsif (output_31_26 = "001101") then
                --OR_i
                OP_Select <= "01001";
            elsif (output_31_26 = "001110") then
                --XOR_I
                OP_Select <= "01011";
            elsif (output_31_26 = "001010") then
                --SLTI
                OP_Select <= "10000";
            elsif (output_31_26 = "001011") then
                --SLTIU
                OP_Select <= "10001";
            end if;
        elsif (ALU_Op = "11") then
            if (output_31_26 = "000100") then
                --BEQ
                OP_Select <= "10111";
            elsif(output_31_26 = "000101") then
                --BNEQ
                OP_Select <= "11000";
            elsif(output_31_26 = "000110") then
                --BLEZ
                OP_Select <= "11001";
            elsif(output_31_26 = "000111") then
                --BGTZ
                OP_Select <= "11010";
            elsif (output_31_26 = "000001") then
                if (output_20_16 = "00000") then
                    --BLTZ
                    OP_Select <= "11011";
                elsif(output_20_16 = "00001") then
                    --BGEZ
                    OP_Select <= "11100";
                end if;
            end if;
        end if; 
    end process;

    output_5_0 <= output_splice(5 downto 0);

end BHV;
