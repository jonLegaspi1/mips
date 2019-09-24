-- Greg Stitt
-- University of Florida

library ieee;
use ieee.std_logic_1164.all;

entity reg_ir is
  generic (
    width  :     positive := 32);
  port (
    clk             : in  std_logic;
    rst             : in  std_logic;
    load            : in  std_logic;
    input           : in  std_logic_vector(width-1 downto 0);
    output_25_0     : out std_logic_vector(25 downto 0);
    output_31_26    : out std_logic_vector(5 downto 0);
    output_25_21    : out std_logic_vector(4 downto 0);
    output_20_16    : out std_logic_vector(4 downto 0);
    output_15_11    : out std_logic_vector(4 downto 0);
    output_15_0     : out std_logic_vector(15 downto 0));


end reg_ir;


architecture BHV of reg_ir is
begin
  process(clk, rst)
  begin
    if (rst = '1') then
        output_25_0     <= (others => '0');
        output_31_26    <= (others => '0');
        output_25_21    <= (others => '0');
        output_20_16    <= (others => '0');
        output_15_11    <= (others => '0');
        output_15_0     <= (others => '0');
    elsif (clk'event and clk = '1') then
      if (load = '1') then
        output_25_0 <= input(25 downto 0);
        output_31_26 <= input(31 downto 26);
        output_25_21 <= input(25 downto 21);
        output_20_16 <= input(20 downto 16);
        output_15_11 <= input(15 downto 11);
        output_15_0 <= input(15 downto 0);
      end if;
    end if;
  end process;
end BHV;
