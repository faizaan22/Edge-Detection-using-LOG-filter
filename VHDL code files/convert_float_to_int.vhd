library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity convert_float_to_int is
	port(
		clk : in std_logic;
		enable : in std_logic;
		A : in std_logic_vector(15 downto 0);
		B: out std_logic_vector(7 downto 0)
	);
end entity;

architecture rch of convert_float_to_int is
	signal B_next : std_logic_vector(31 downto 0);
begin
	
	process (clk)
	begin
		if (rising_edge(clk)) then
			if (enable = '1') then
				B <= B_next(7 downto 0);
			end if;
		end if;
	end process;
	
	process (A)
		variable sign : std_logic;
		variable Ex : integer;
	begin
		sign := A(15);
		Ex := to_integer(unsigned(A(14 downto 10)));
		--Ex := Ex - 15;
		
--		if (Ex < 15) then
--			Ex := 0;
--		else
--			Ex := Ex - 15;
--		end if;
--		
--		if (sign='0') then
--			B_next <= std_logic_vector(to_unsigned(2**Ex, 32));
--		else
--			B_next <= std_logic_vector(unsigned(not std_logic_vector(to_unsigned(2**Ex, 32))) + 1);
--		end if;
		
		if (Ex < 15) then
			B_next <= (others => '0');
		else
			Ex := Ex - 15;
			if (sign='0') then
				B_next <= std_logic_vector(to_unsigned(2**Ex, 32));
			else
				B_next <= std_logic_vector(unsigned(not std_logic_vector(to_unsigned(2**Ex, 32))) + 1);
			end if;
		end if;
		
	end process;
	
	
	
end architecture;