library ieee;
use ieee.std_logic_1164.all;
use work.Common.all;

entity convert_int_to_float is
	port (
		clk : in std_logic;
		img_int : in img_1d_vec(0 to (row*col)-1);
		img_float : out img_1d_vec_float(0 to (row*col)-1)
	);
end entity;

architecture rch of convert_int_to_float is
	signal tmp : img_1d_vec_float(0 to (row*col)-1) := (others => (others => '0'));
begin
	
	process(img_int)
	begin
		for i in 0 to (row*col)-1 loop
			tmp(i) <= int8_to_float16(img_int(i));
		end loop;
	end process;
	
	process (clk)
		--variable tmp : img_1d_vec_float(0 to (row*col)-1) := (others => (others => '0'));
	begin
		if (rising_edge(clk)) then
			img_float <= tmp;
		end if;
	end process;
	
end architecture;