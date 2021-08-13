library ieee;
use ieee.std_logic_1164.all;
use work.Common.all;

entity mult_matrix_sum_float is
	generic (
		index_i : integer := 0;
		index_j : integer := 0;
		h : integer := 5;
		w : integer := 5
	);
	port (
		clk : in std_logic;
		m1 : in img_1d_vec_float(0 to ((row + (2*m_cap))*(col + (2*n_cap))) - 1);
		m2 : in img_1d_vec_float(0 to (h*w) - 1);
		result : out std_logic_vector(15 downto 0) := (others => '0');
		main_ready : out std_logic
	);
end entity;

architecture rch of mult_matrix_sum_float is
	constant new_i : integer := (cw*index_i) + index_j;
	
	component float_mul is
	generic (
	len : integer := 16;
	bits : integer := 4
	);
	port(
		clk : in std_logic;
		enable : in std_logic;
		A, B : in std_logic_vector(len-1 downto 0);
		result : out std_logic_vector(len-1 downto 0);
		ready : out std_logic
	);
	end component;
	
	component float_adder is
	generic (
		size : integer := 16;
		logsize : integer := 4
	);
	port (
		clk : in std_logic;
		enable : in std_logic;
		num1, num2 : in std_logic_vector(size-1 downto 0);
		result : out std_logic_vector(size-1 downto 0);
		ready : out std_logic
	);
	end component;
	
	signal tmp : img_1d_vec_float(0 to (h*w) - 1) := (others => (others => '0'));
	--signal k : integer := 2;
	--signal main_ready_signal : std_logic := '1';
	--signal cnt : integer := 0;
	
	----
	signal prod_en, add_en : std_logic := '0';
	
	signal num1, num2, output : std_logic_vector(15 downto 0) := (others => '0');
	signal dut_ready : std_logic := '1';
	signal k : integer := 0;
	
begin
	
	
	g1 : for i in 0 to m-1 generate
		g2 : for j in 0 to n-1 generate
			mult : float_mul port map (clk, prod_en, m1(new_i + cw*i + j), m2((i*n) + j), tmp((i*n) + j));
		end generate;
	end generate;
	
	
	prod_en <= '0' when add_en='1' else '1';
	
	adder : float_adder port map (clk, add_en, num1, num2, output, dut_ready);
	
	--main_ready <= main_ready_signal;
	
	process (clk)
	begin
		if(rising_edge(clk)) then
			--cnt <= cnt + 1;
			add_en <= '1';
		end if;
	end process;
	
--	process (clk)
--	begin
--		if (rising_edge(clk)) then
--			if (ready='1' and k=48) then
--				main_ready_signal <= '1';
--			elsif (ready = '1' and k/=48) then
--				if (main_ready_signal='1') then
--					num1 <= tmp(0);
--					num2 <= tmp(1);
--					main_ready <= '0';
--				else
--					num1 <= tmp(k);
--					num2 <= output;
--					k <= k+1;
--				end if;
--			end if;
--		end if;
--	end process;
	
	
--	process (clk)
--	begin
--		if(rising_edge(clk)) then
--			case state is
--				when 
--			end case;
--		end if;
--	end process;
	
	-------------
	
	process (clk)
	begin
		if (rising_edge(clk)) then
			if(add_en='1') then
				if ((dut_ready = '1') and (k=h*w)) then
					main_ready <= '1';
					k <= 0;
					result <= output;
					--add_en <= '0';
					--enable_sig <= '0';
				elsif ((dut_ready = '1') and (k=0)) then
					main_ready <= '0';
					--enable_sig <= '1';
					num1 <= tmp(0);
					num2 <= tmp(1);
					k <= 2;
				elsif ((dut_ready = '1') and (k/=0) and (k/=h*w)) then
					num1 <= tmp(k);
					num2 <= output;
					k <= k+1;
				end if;
			end if;
		end if;
	end process;
	
end architecture;