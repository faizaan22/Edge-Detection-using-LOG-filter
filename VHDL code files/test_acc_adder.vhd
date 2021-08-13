library ieee;
use ieee.std_logic_1164.all;
use work.Common.all;

entity test_acc_adder is
	port (
		clk : in std_logic;
		enable : in std_logic;
		--A : in std_logic_vector(7 downto 0);
		B : out std_logic_vector(15 downto 0);
		ready : out std_logic
	);
end entity;

architecture rch of test_acc_adder is
	
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
	
	constant input_rom : img_1d_vec_float := (
		"0100001010011010", "1100110011101111", "0101001010101001" , "1010100000011001"
	);
	
	signal num1, num2, output : std_logic_vector(15 downto 0) := (others => '0');
	signal dut_ready : std_logic := '1';
	signal k : integer := 0;
	--signal enable_sig : std_logic := '0';

begin

	dut : float_adder port map (clk, enable, num1, num2, output, dut_ready);
	
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
	
	--enable_sig <= enable;
	
	process (clk)
	begin
		if (rising_edge(clk)) then
			if(enable='1') then
				if ((dut_ready = '1') and (k=4)) then
					ready <= '1';
					k <= 0;
					B <= output;
					--enable_sig <= '0';
				elsif ((dut_ready = '1') and (k=0)) then
					ready <= '0';
					--enable_sig <= '1';
					num1 <= input_rom(0);
					num2 <= input_rom(1);
					k <= 2;
				elsif ((dut_ready = '1') and (k/=0) and (k/=4)) then
					num1 <= input_rom(k);
					num2 <= output;
					k <= k+1;
				end if;
			end if;
		end if;
	end process;
	
	
end architecture;