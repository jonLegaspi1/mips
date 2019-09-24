-- Greg Stitt
-- University of Florida

library ieee;
use ieee.std_logic_1164.all;

entity mux4x1 is
  generic (
    width  :     positive);
  port (
    in1    : in  std_logic_vector(width-1 downto 0);
    in2    : in  std_logic_vector(width-1 downto 0);
    in3    : in  std_logic_vector(width-1 downto 0);
    in4    : in  std_logic_vector(width-1 downto 0);
    sel    : in  std_logic_vector(1 downto 0);
    output : out std_logic_vector(width-1 downto 0));
end mux4x1;

architecture BHV of mux4x1 is
begin
  process (sel, in1, in2, in3, in4)
  begin
  case SEL is 
  when "00" => output <= in1; 
  when "01" => output <= in2;
  when "10" => output <= in3;
  when "11" => output <= in4;
  when others => output <= (others => '0');
  end case;
  end process;
end BHV;
