library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity convert_int_to_float1 is
	port(
		clk : in std_logic;
		enable : in std_logic;
		A : in std_logic_vector(7 downto 0);
		B: out std_logic_vector(15 downto 0)
	);
end entity;

architecture rch of convert_int_to_float1 is
	signal B_next: std_logic_vector(15 downto 0);
begin
	
	process (clk)
	begin
		if (rising_edge(clk)) then
			if (enable = '1') then
				B <= B_next;
			end if;
		end if;
	end process;
	
	process (A)
		variable position : integer := -1;
		variable mantissa : std_logic_vector(9 downto 0) := (others => '0');
	begin
		for i in 7 downto 0 loop
			if (A(i) = '1') then
				position := i;
				exit;
				end if;
		end loop;
		
		if (position = 0) then
			mantissa := (others => '0');
			B_next <= '0' & std_logic_vector(to_unsigned(position+15, 5)) & mantissa;
		elsif (position = -1) then
			--return "0000000000000000";
			B_next <= (others => '0'); 
		else
			--mantissa := (9 downto 7 => A(position-1 downto 0), others => '0');
			mantissa(9 downto 9-position+1) := A(position-1 downto 0);
			mantissa(9-position downto 0) := (others => '0');
			B_next <= '0' & std_logic_vector(to_unsigned(position+15, 5)) & mantissa;
		end if;
		
		--B <= '0' & std_logic_vector(to_unsigned(position+15, 5)) & mantissa;
			
	end process;
	
end architecture;