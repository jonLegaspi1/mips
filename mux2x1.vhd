library ieee;
use ieee.std_logic_1164.all;

entity mux2x1 is
  generic (
    width  :     positive := 32);
  port (
    in1    : in  std_logic_vector(width-1 downto 0);
    in2    : in  std_logic_vector(width-1 downto 0);
    sel    : in  std_logic;
    output : out std_logic_vector(width-1 downto 0));
end mux2x1;

architecture BHV of mux2x1 is
begin
  process (sel, in1, in2)
  begin
    case SEL is 
        when '0' => output <= in1; 
        when '1' => output <= in2;
        when others => output <= (others => '0');
    end case;
  end process;
end BHV;
