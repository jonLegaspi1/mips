library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity mem_control is
  generic (
    width : positive := 32);
  port (
    memRead            : in std_logic;
    memWrite           : in  std_logic;
    address            : in std_logic_vector(width-1 downto 0);
    sel                : out std_logic_vector(1 downto 0);
    outport_en         : out std_logic;
    from_inport        : out std_logic);
end mem_control;

architecture BHV of mem_control is
begin

process(memRead, memWrite, address)
begin
    sel <= "10";
    outport_en <= '0';
    from_inport <= '0';
    if(memRead = '1') then
        if(address(15 downto 0) = x"FFF8") then
            sel <= "00";
            from_inport <= '1';
        elsif(address(15 downto 0) = x"FFFC") then
            sel <= "01";
            from_inport <= '1';
        else
            sel <= "10";
            from_inport <= '0'; 
        end if;
        --if(unsigned(address) <= 1023) then
        --    sel <= "00";
        --elsif(unsigned(address(15 downto 0)) = x"FFF8") then
        --    sel <= "01";
        --elsif(unsigned(address(15 downto 0)) = x"FFFC") then
        --    sel <= "10";
        --else   
         --   sel <= "11";
        --end if;
    elsif(memWrite = '1') then
        if(address(15 downto 0) = x"FFFC") then
            outport_en <= '1';
        end if;
    end if;
    end process;
end BHV;


