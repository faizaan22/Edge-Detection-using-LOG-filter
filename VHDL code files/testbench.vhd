library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Common.all;
use std.textio.all;

entity testbench is
end entity;

architecture rch of testbench is
	
	constant ImaGE_FILE_NAME : string := "F:\python_projects\python essentials\edge_detection_project_log\img_8b_100s.mif";
	
	subtype mem_type is img_1d_vec (0 to (row*col) - 1);
	
	impure function init_mem(mif_file_name : in string) return mem_type is
		 file mif_file : text open read_mode is mif_file_name;
		 variable mif_line : line;
		 variable temp_bv : bit_vector(7 downto 0);
		 variable temp_mem : mem_type;
	begin
		 for i in mem_type'range loop
			  readline(mif_file, mif_line);
			  read(mif_line, temp_bv);
			  temp_mem(i) := to_stdlogicvector(temp_bv);
		 end loop;
		 return temp_mem;
	end function;

	signal result_img : img_1d_vec (0 to (row*col) - 1) := init_mem(IMAGE_FILE_NAME);
begin
	
--	process
--		file test_vector : text open read_mode is "F:\python_projects\python essentials\edge_detection_project_log\img_8b_100s.mif";
--		
--		variable row : line;
--		
--		--variable v_data_read : std_logic_vector(15 downto 0);
--		variable v_data_read : img_1d_vec (0 to (row*col) - 1) := (others => (others => '0'));
--		
--	begin
--		for i in 0 to row-1 loop
--			for j in 0 to col-1 loop
--				if(not endfile(test_vector)) then
--				  readline(test_vector,row);
--				  read(row,v_data_read(col*i + j));
--				end if;
--			end loop;
--		end loop;
--		
--		result_img <= v_data_read;
--		wait;
--	end process;
	
end architecture;