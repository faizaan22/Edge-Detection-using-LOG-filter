library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package Common is
	
	constant row : integer := 200;
	constant col : integer := 200;
	constant m : integer := 7;
	constant n : integer := 7;
	constant m_cap : integer := m/2;
	constant n_cap : integer := n/2;
	constant ch : integer := row + (2*m_cap);
	constant cw : integer := col + (2*n_cap);
	
	type img_1d_vec is array (Natural range <>) of std_logic_vector(7 downto 0);
	--subtype slv8 is std_logic_vector(7 downto 0);
	type img_1d_vec_float is array(Natural range <>) of std_logic_vector(15 downto 0);
	
	constant log_rom : img_1d_vec_float(0 to (m*n)-1) := (
		"0000000000000000", "0010100100011100", "0010100100011110", "0010100100011111", "0010100100011110", "0010100100011100", "0000000000000000", "0010100100011100", "1010110100011010", "1010100100011101", "1010100100011110", "1010100100011101", "1010110100011010", "0010100100011100", "0010100100011110", "1010100100011101", "1000010111010011", "1000010111010101", "1000010111010011", "1010100100011101", "0010100100011110", "0010100100011111", "1010100100011110", "1000010111010101", "1000010111010110", "1000010111010101", "1010100100011110", "0010100100011111", "0010100100011110", "1010100100011101", "1000010111010011", "1000010111010101", "1000010111010011", "1010100100011101", "0010100100011110", "0010100100011100", "1010110100011010", "1010100100011101", "1010100100011110", "1010100100011101", "1010110100011010", "0010100100011100", "0000000000000000", "0010100100011100", "0010100100011110", "0010100100011111", "0010100100011110", "0010100100011100", "0000000000000000"
	);

	function int8_to_float16(A : in std_logic_vector(7 downto 0)) return std_logic_vector;

end package;

package body Common is

		function int8_to_float16(A : in std_logic_vector(7 downto 0)) return std_logic_vector is
			--variable tmp : std_logic_vector(15 downto 0) := (others => '0');
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
			elsif (position = -1) then
				return "0000000000000000";
			else
				--mantissa := (9 downto 7 => A(position-1 downto 0), others => '0');
				mantissa(9 downto 9-position+1) := A(position-1 downto 0);
				mantissa(9-position downto 0) := (others => '0');
			end if;
			return '0' & std_logic_vector(to_unsigned(position+15, 5)) & mantissa;
		end;
		
end package body;