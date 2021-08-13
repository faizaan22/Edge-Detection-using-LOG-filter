library ieee;
use ieee.std_logic_1164.all;
use work.Common.all;

entity conv2d is
	generic (
		row : integer := 10;
		col : integer := 10;
		m : integer := 7;
		n : integer := 7
	);
	port (
		clk : in std_logic;
		img : in img_1d_vec_float (0 to (row*col) - 1);
		mask : in img_1d_vec_float(0 to (m*n) - 1);
		filtered_img : out img_1d_vec_float (0 to (row*col) - 1) := (others => (others => '0'));
		conv2d_ready : out std_logic
	);
end entity;

architecture rch of conv2d is
	constant m_cap : integer := m/2;
	constant n_cap : integer := n/2;
	
	signal canvas : img_1d_vec_float(0 to ((row + (2*m_cap))*(col + (2*n_cap))) - 1) := (others => (others => '0'));
	
--	component mult_matrix_sum_float1 is
--	generic (
--		h : integer := 5;
--		w : integer := 5
--	);
--	port (
--		clk : in std_logic;
--		index_i : in integer;
--		index_j : in integer;
--		m1 : in img_1d_vec_float(0 to ((row + (2*m_cap))*(col + (2*n_cap))) - 1);
--		m2 : in img_1d_vec_float(0 to (h*w) - 1);
--		result : out std_logic_vector(15 downto 0) := (others => '0');
--		main_ready : out std_logic
--	);
--	end component;
	
	component mult_matrix_sum_float1 is
	generic (
--		index_i : integer := 0;
--		index_j : integer := 0;
		h : integer := 7;
		w : integer := 7
	);
	port (
		clk : in std_logic;
		mmsf_enable : in std_logic;
		index_i : in integer;
		index_j : in integer;
		m1 : in img_1d_vec_float(0 to ((row + (2*m_cap))*(col + (2*n_cap))) - 1);
		m2 : in img_1d_vec_float(0 to (h*w) - 1);
		result : out std_logic_vector(15 downto 0) := (others => '0');
		main_ready : out std_logic
	);
	end component;
	
	signal ready : std_logic;
	--signal i1, j1 : integer := 0;
	signal index_i,index_j : integer := 0;
	
	signal mmsf_enable : std_logic := '1';
	
	type t_state is (idle, start, fin);
	signal state : t_state := idle;
	
	signal dut_result : std_logic_vector(15 downto 0) := (others => '0');
begin
	--canvas(m_cap to (row + m_cap - 1))(n_cap to (col + n_cap - 1)) <= img(1)(1);
	canvas_initialization : process (img)
	begin
		for i in m_cap to (row + m_cap - 1) loop
			for j in n_cap to (col + n_cap - 1) loop
				canvas((i*cw) + j) <= img(((i-m_cap)*(col)) + (j-n_cap));
			end loop;
		end loop;
	end process;
	
--	g1: for i in 0 to row-1 generate
--		g2 : for j in 0 to col-1 generate
--			g3 : mult_matrix_sum_float generic map (i,j,7,7) port map (clk, canvas, mask, filtered_img((col*i) + j));
--		end generate;
--	end generate;
	
--	mmsf_dut : mult_matrix_sum_float generic map (7,7) port map (clk, i,j, canvas, mask, dut_result, ready);
	
	--mmsf1_dut : mult_matrix_sum_float1 generic map (7,7) port map (clk, index_i,index_j, canvas, mask, dut_result, ready);
	
	mmsf1_dut : mult_matrix_sum_float1 generic map (7,7) port map (clk, mmsf_enable, index_i,index_j, canvas, mask, dut_result, ready);
	
	filtered_img((col*index_i) + index_j) <= dut_result;
	
--	process (clk, ready)
--	begin
--		if ((rising_edge(clk)) and (rising_edge(ready))) then
--			report ("i and j " & integer'image(index_i) & " " & integer'image(index_j));
--			
--			if (index_i=0 and index_j=0) then
--				conv2d_ready <= '0';
--			elsif (index_i=row) then
--				conv2d_ready <= '1';
--			end if;
--					
--			if (index_i < row) then
--				if (index_j < col) then
--					--start loop here
----					filtered_img((col*i) + j) <= dut_result;
--					
--					index_j <= index_j+1;
--				end if;
--				if (index_j = col-1) then
--					index_j <= 0;
--					index_i <= index_i + 1;
--				end if;
--			end if;
--		end if;
--	end process;
	
	process (clk)
	begin
		if (rising_edge(clk)) then
			case state is
				when idle =>
					--this is important
--					mmsf_enable <= '1';
--					index_i <= 0;
--					index_j <= 0;
--					conv2d_ready <= '0';
--					state <= start;
					
					-------------------------------
					--farji trick to stop
					if (mmsf_enable = '1') then
						index_i <= 0;
						index_j <= 0;
						conv2d_ready <= '0';
						state <= start;
					end if;
					-------------------------------
					
				when start =>
					if (ready='1') then
						if (index_i < row) then
							if (index_j < col) then
								index_j <= index_j+1;
							end if;
							if (index_j = col-1) then
								index_j <= 0;
								index_i <= index_i + 1;
							end if;
						end if;
						if ((index_i=row-1) and (index_j=col-1)) then
							mmsf_enable <= '0';
							conv2d_ready <= '1';
							state <= fin;
						end if;
					end if;
					
				when fin => 
					state <= idle;
				
			end case;
		end if;
	end process;
	
end architecture;