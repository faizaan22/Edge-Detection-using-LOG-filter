library ieee;
use ieee.std_logic_1164.all;
use work.Common.all;

entity test_convert is
end entity test_convert;

architecture rtl of test_convert is
    component convert_int_to_float is
	port (
		clk : in std_logic;
		img_int : in img_1d_vec(0 to (row*col)-1);
		img_float : out img_1d_vec_float(0 to (row*col)-1)
	);
    end component;

    signal clk : std_logic := '0';
    signal img_int : img_1d_vec(0 to (row*col)-1) := (others => (others => '0'));
    signal img_float : img_1d_vec_float(0 to (row*col)-1) := (others => (others => '0'));

    type t_fl_slv8 is file of std_logic_vector(7 downto 0);
    file myfile : t_fl_slv8;

    type t_fl_slv16 is file of std_logic_vector(15 downto 0);
    file myfile1 : t_fl_slv16;
begin
    process begin
        clk <= not clk after 10 ns;
    end process;

    dut : convert_int_to_float port map (
        clk, img_int, img_float
    );

    process
        variable slv8 : std_logic_vector(7 downto 0);
        variable img_var : img_1d_vec(0 to (row*col - 1)) := (others => (others => '0'));
    begin
        file_open(myfile, "G:\intelFPGAlite_workspace\edge_detection_vhdl1\img_8bit.txt", read_mode);
        file_open(myfile1, "G:\intelFPGAlite_workspace\edge_detection_vhdl1\output_of_convert.txt", write_mode);

        for i in 0 to (row*col)-1 loop
            read(myfile, slv8);
            img_var(i) := slv8;
        end loop;

        img_int <= img_var;

        wait for 100 ns;
        
        for i in 0 to (row*col)-1 loop
            write(myfile1, img_float(i));
        end loop;

        wait for 100 ns;
        wait;
    end process;
    

end architecture;