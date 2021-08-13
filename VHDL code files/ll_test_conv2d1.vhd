library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Common.all;
use std.textio.all;

entity ll_test_conv2d1 is
	port (
		CLOCK_50 : in std_logic;
		LEDR : out std_logic_vector(17 downto 0)
	);
end entity;

architecture rch of ll_test_conv2d1 is
	
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
	
	component conv2d1 is
		generic (
			row : integer := 10;
			col : integer := 10;
			m : integer := 7;
			n : integer := 7
		);
		port (
			clk : in std_logic;
			img : in img_1d_vec (0 to (row*col) - 1);
			mask : in img_1d_vec_float(0 to (m*n) - 1);
			filtered_img : out img_1d_vec (0 to (row*col) - 1) := (others => (others => '0'));
			conv2d_ready : out std_logic
		);
	end component;
	
	signal input_img : img_1d_vec (0 to (row*col) - 1) := init_mem(IMAGE_FILE_NAME);
	
	signal filtered_img : img_1d_vec (0 to (row*col) - 1) := (others => (others => '0'));
	signal conv2d_ready : std_logic;
begin
	
	dut : conv2d1 generic map (100,100,7,7) port map (CLOCK_50, input_img, log_rom, filtered_img, conv2d_ready);
	
end architecture;