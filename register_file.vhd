library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity register_file is
    generic ( width  :     positive := 32);
    port(
        clk         : in std_logic;
        rst         : in std_logic;
        rd_addr0    : in std_logic_vector(width-1 downto 0);
        rd_addr1    : in std_logic_vector(width-1 downto 0);
        wr_addr     : in std_logic_vector(width-1 downto 0);
        wr_en       : in std_logic;
        jal         : in std_logic;
        wr_data     : in std_logic_vector(width-1 downto 0);
        rd_data0    : out std_logic_vector(width-1 downto 0);
        rd_data1    : out std_logic_vector(width-1 downto 0)
        );
end register_file;


architecture async_read of register_file is
    type reg_array is array(0 to 31) of std_logic_vector(width-1 downto 0);
    signal regs : reg_array;
begin
    process (clk, rst) is
    begin
        if (rst = '1') then
            for i in regs'range loop
                regs(i) <= (others => '0');
            end loop;
        elsif (rising_edge(clk)) then
            if (wr_en = '1') then
                if (jal = '1') then
                    regs(31) <= wr_data;
                elsif(wr_addr = x"00000000") then
                
                else 
                    regs(to_integer(unsigned(wr_addr))) <= wr_data;
                    
                end if;
            end if;                
        end if;
    end process;

    rd_data0 <= regs(to_integer(unsigned(rd_addr0)));
    rd_data1 <= regs(to_integer(unsigned(rd_addr1)));
   
end async_read;