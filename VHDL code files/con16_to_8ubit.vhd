library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity con16_to_8ubit is
	port (
		A_16bit : in std_logic_vector(15 downto 0);
		A_8bit : out std_logic_vector(7 downto 0)
	);
end entity;

architecture rch of con16_to_8ubit is

begin
	
	process (A_16bit)
		variable b : integer;
		variable sign : std_logic;
		variable d : std_logic_vector(7 downto 0);
		variable c : unsigned(7 downto 0);
	begin
		--b := (2**(to_integer() - 15));
		b := to_integer(unsigned(A_16bit(14 downto 10)));
		sign := A_16bit(15);
		
		if (b < 15) then
			b := 0;
		else
			b := b - 15;
		end if;
		
		if (sign='1') then
			c := to_unsigned(b, 8);
			d := std_logic_vector(unsigned(not(std_logic_vector(c))) + 1);
		else
			d := std_logic_vector(to_unsigned(b, 8));
		end if;
		
		A_8bit <= d;
	end process;
	
end architecture;