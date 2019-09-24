library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller is 
    generic(width : positive := 32);
    port(
        clk           : in std_logic;
        rst           : in std_logic;
        op_code       : in std_logic_vector(5 downto 0);
        from_inport   : in std_logic;
        output_splice : in std_logic_vector(5 downto 0);
        PC_Write_Cond : out std_logic;
        PC_Write      : out std_logic;
        I_Or_D        : out std_logic;
        Mem_Read      : out std_logic;
        Mem_Write     : out std_logic;
        Mem_To_Reg    : out std_logic_vector(1 downto 0);
        IR_Write      : out std_logic;
        Jump_And_Link : out std_logic;
        Is_Signed     : out std_logic;
        PC_Source     : out std_logic_vector(1 downto 0);
        ALU_Op        : out std_logic_vector(1 downto 0);
        ALU_Src_B     : out std_logic_vector(1 downto 0);
        ALU_Src_A     : out std_logic;
        Reg_Write     : out std_logic;
        Reg_Dst       : out std_logic
    );
end controller;

architecture FSM_2P of controller is
    type STATE_TYPE is (FETCH, DECODE, J_COMPLETION, J_WAIT, COMPUTE_ADDR, LOAD_MEM_ACCESS, 
    EXECUTION, I_EXECUTION, I_COMPLETION, B_COMPLETION, B_WAIT, JAL_COMPLETION, 
    JAL_EXECUTION, JRA_EXECUTION, R_COMPLETION, STORE_MEM_ACCESS, STORE_WAIT, COMPLETE_MEM_READ);
    --JRA_COMPLETION
    signal state, next_state : STATE_TYPE;

begin
    process(clk, rst)
    begin
        if (rst ='1') then
            state <= FETCH;
        elsif(rising_edge(clk)) then
            state <= next_state;
        end if;
    end process;

    process(op_code, state, output_splice)
    begin
        PC_Write_Cond <= '0';
        PC_Write      <= '0';
        I_Or_D        <= '0';
        Mem_Read      <= '0';
        Mem_Write     <= '0';
        Mem_To_Reg    <= "00";
        IR_Write      <= '0';
        Jump_And_Link <= '0';
        Is_Signed     <= '0';
        PC_Source     <= "00";
        ALU_Op        <= "00";
        ALU_Src_B     <= "00";
        ALU_Src_A     <= '0';
        Reg_Write     <= '0';
        Reg_Dst       <= '0';

        next_state <= state;

        case state is
            when FETCH =>
                Mem_Read    <= '1';
                ALU_Src_A   <= '0';
                I_Or_D      <= '0';
                IR_Write    <= '1';
                ALU_Src_B   <= "01";
                ALU_Op      <= "00";
                PC_Write    <= '1';
                PC_Source   <= "00";

                next_state <= DECODE;

            when DECODE =>
                ALU_Src_A   <= '0';
                ALU_Src_B   <= "11";
                ALU_OP      <= "00";

                if (op_code = "100011") then
                    next_state <= COMPUTE_ADDR;
                elsif (op_code = "101011") then
                    next_state <= COMPUTE_ADDR;
                elsif (op_code = "000000" and output_splice = "001000") then
                        next_state <= JRA_EXECUTION;
                elsif (op_code = "000000" and output_splice /= "001000") then
                        next_state <= EXECUTION;
                
                elsif (op_code = "000010") then
                    next_state <= J_COMPLETION;
                elsif (op_code = "000011") then
                    next_state <= JAL_EXECUTION;
                    
                elsif (op_code = "001001" or op_code = "010000" or op_code = "001100" or op_code = "001101" or 
                op_code = "001110" or op_code = "001010" or op_code = "001011") then
                    next_state <= I_EXECUTION;
                elsif (op_code = "000100" or op_code = "000101" or op_code = "000110" or op_code = "000111" or op_code = "000001") then
                    next_state <= B_COMPLETION;                
                end if;             

            when EXECUTION =>
                ALU_Src_A <= '1';
                ALU_Src_B <= "00";
                ALU_Op <= "10";
                next_state <= R_COMPLETION;

            when JRA_EXECUTION =>
                ALU_Op <= "00";
                ALU_Src_A <= '1';
                ALU_Src_B <= "00";
                PC_Write <= '1';
                PC_Source <= "00";
                next_state <= J_WAIT;

            --when JRA_COMPLETION => 
            --    next_state <= FETCH;

            when B_COMPLETION =>
                ALU_Src_A <= '1';
                ALU_Src_B <= "00";
                ALU_Op <= "11";
                PC_Write_Cond <= '1';
                PC_Source <= "01";
                next_state <= B_WAIT;
                
            when B_WAIT => 
                next_state <= FETCH;

            when I_EXECUTION =>
                ALU_Src_A <= '1';
                ALU_Src_B <= "10";
                ALU_Op <= "01";
                next_state <= I_COMPLETION;

            when I_COMPLETION =>
                Reg_Dst <= '0';
                Reg_Write <= '1';
                ALU_Op <= "01";
                Mem_To_Reg <= "00";
                next_state <= FETCH;

            when J_COMPLETION =>
                PC_Write <= '1';
                PC_Source <= "10";
                next_state <= J_WAIT;

            when JAL_EXECUTION =>
                PC_Write <= '1';
                PC_Source <= "10";
                next_state <= JAL_COMPLETION;
                
            when JAL_COMPLETION =>
                Jump_And_Link <= '1';
                Reg_Dst <= '1';
                Reg_Write <= '1';
                Mem_To_Reg <= "00";
                next_state <= J_WAIT;

            when J_WAIT =>
                next_state <= FETCH;

            when R_COMPLETION =>
                
                Reg_Dst <= '1';
                Reg_Write <= '1';
                Mem_To_Reg <= "00";
                next_state <= FETCH;

            when COMPUTE_ADDR =>
                ALU_Src_A <= '1';
                ALU_Src_B <= "10";
                ALU_Op    <= "00";
                
                if (op_code = "100011") then
                    next_state <= LOAD_MEM_ACCESS;
                elsif (op_code = "101011") then
                    next_state <= STORE_MEM_ACCESS;
                end if; 

            when LOAD_MEM_ACCESS =>
                Mem_Read    <= '1';
                I_Or_D      <= '1';
                next_state <= COMPLETE_MEM_READ;
                
            when STORE_MEM_ACCESS =>
                Mem_Write   <= '1';
                I_Or_D      <= '1';
                next_state <= STORE_WAIT;

            when STORE_WAIT =>
                next_state <= FETCH;
                    
            when COMPLETE_MEM_READ =>
                Reg_Dst     <= '0';
                Reg_Write   <= '1';
                if (from_inport = '1') then
                    Mem_To_Reg <= "01";
                else
                    Mem_To_Reg  <= "10";
                end if;
                next_state <= FETCH;
        end case;
    end process;
end FSM_2P;