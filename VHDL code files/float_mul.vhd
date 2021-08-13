library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity float_mul is
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
end entity;

architecture rch of float_mul is
	constant exp_size : integer := (3*(bits)) - 7;
	signal product : std_logic_vector(len-1 downto 0) := (others => '0');
begin
	
	process(clk)
	begin
		if(rising_edge(clk)) then
			if (enable='1') then
				result <= product;
				ready <= '1';
			end if;
			--result <= product;
		end if;
	end process;
	
	process (A, B)
		variable A_exponent, B_exponent, product_exponent : std_logic_vector(exp_size-1 downto 0) := (others => '0');
		variable A_mantissa, B_mantissa, product_mantissa : std_logic_vector(len - exp_size -2 downto 0) := (others => '0');
		variable A_sign, B_sign, product_sign : std_logic := '0';
		variable temp_reg : std_logic_vector((2*(len - exp_size) - 1) downto 0) := (others => '0');
		variable x : std_logic := '0';
		variable prod_exponent_int : integer := 0;
	
	begin
		A_exponent := A(len-2 downto len-exp_size-1);
		A_mantissa := A(len-exp_size-2 downto 0);
		A_sign := A(len-1);
		
		B_exponent := B(len-2 downto len-exp_size-1);
		B_mantissa := B(len-exp_size-2 downto 0);
		B_sign := B(len-1);
		
		--product_exponent := A_exponent + B_exponent - ((2**(exp_size-1))-1);
		prod_exponent_int := to_integer(unsigned(A_exponent)) + to_integer(unsigned(B_exponent)) - ((2**(exp_size-1))-1);
		product_sign := A_sign xor B_sign;
		
		temp_reg := ('1' & A_mantissa) * ('1' & B_mantissa);
		
		if(temp_reg((2*(len - exp_size) - 1)) = '1') then
			product_mantissa := temp_reg((2*(len - exp_size) - 2) downto (len-exp_size)) + temp_reg(len-exp_size-1);
			--product_exponent := product_exponent + 1;
			prod_exponent_int := prod_exponent_int + 1;
		else
			product_mantissa := temp_reg((2*(len - exp_size) - 3) downto (len-exp_size-1)) + temp_reg(len-exp_size-2);
			--product_exponent := product_exponent;
			prod_exponent_int := prod_exponent_int;
		end if;
		
		product(len-1) <= product_sign;
		--product((len-2) downto (len-exp_size-1)) <= product_exponent;
		
		product((len-exp_size-2) downto 0) <= product_mantissa;
		
		if (prod_exponent_int < 0) then
			product((len-2) downto (len-exp_size-1)) <= (others => '0'); --it is representation of 0
			product((len-exp_size-2) downto 0) <= (others => '0');
		elsif (prod_exponent_int > 255) then
			product((len-2) downto (len-exp_size-1)) <= (others => '1'); -- it is representation of infinity
			product((len-exp_size-2) downto 0) <= (others => '0');
		else
			product((len-2) downto (len-exp_size-1)) <= std_logic_vector(to_unsigned(prod_exponent_int, exp_size));
		end if;
		
	end process;
end architecture;