library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity float_adder is
	generic (
		size : integer := 16;
		logsize : integer := 4
	);
	port (
		clk : in std_logic;
		enable : in std_logic;
		num1, num2 : in std_logic_vector(size-1 downto 0);
		result : out std_logic_vector(size-1 downto 0) := (others => '0');
		ready : out std_logic
	);
end entity;

architecture rch of float_adder is
	constant esize : integer := (3*(logsize)) - 7;
	constant msize : integer := size - esize - 1;
	constant bigsize : integer := (2**esize) + msize;
	constant bias : integer := (2**(esize-1)) - 1;
	
	type t_state is (RDY, START, NEGPOS, OP, SHIFT, WRT, RSLT);
	signal state : t_state := RDY;
	
	signal bigreg, smallreg, resultreg : std_logic_vector(bigsize-1 downto 0);
	signal resultsign : std_logic;
	signal resultshift : std_logic_vector(esize-1 downto 0);
	signal resultfrac : std_logic_vector(msize-1 downto 0);
	--signal position : integer := 0;
	signal position : std_logic_vector(esize downto 0) := (others => '0');
	signal bigshift, smallshift : integer;
	
	constant z_bias_size : std_logic_vector(bias-1 downto 0) := (others => '0');
	constant z_bias_size1 : std_logic_vector(bias downto 0) := (others => '0');
	constant z_msize : std_logic_vector(msize-1 downto 0) := (others => '0');
begin
	
	process (clk)
		variable flag : integer := 0;
	begin
		if (rising_edge(clk)) then
			case state is
				when RDY =>
					if (enable='1') then
						--bigreg <= x"0000" & '1' & X"000000" & '0';
						bigreg <= z_bias_size1 & '1' & z_msize & z_bias_size;
						--smallreg <= X"0000" & '1' & X"000000" & '0';
						smallreg <= z_bias_size1 & '1' & z_msize & z_bias_size;
						position <= (others => '0');
						ready <= '0';
						state <= START;
					end if;
				when START =>
					flag := 0;
					
					if (num1(size-1) /= num2(size-1)) then
						if (num1(size-2 downto msize) > num2(size-2 downto msize)) then
							--bigreg(24 downto 15) <= num1(9 downto 0);
							bigreg(bias+msize-1 downto bias) <= num1(msize-1 downto 0);
							--bigshift <= to_integer(unsigned(num1(size-2 downto msize))) - 15;
							bigshift <= to_integer(unsigned(num1(size-2 downto msize))) - bias;
							resultsign <= num1(size-1);
							--smallreg(24 downto 15) <= num2(9 downto 0);
							--smallshift <= to_integer(unsigned(num2(size-2 downto msize))) - 15;
							smallreg(bias+msize-1 downto bias) <= num2(msize-1 downto 0);
							smallshift <= to_integer(unsigned(num2(size-2 downto msize))) - bias;
							
						elsif (num2(size-2 downto msize) > num1(size-2 downto msize)) then
							--bigreg(24 downto 15) <= num2(9 downto 0);
							--bigshift <= to_integer(unsigned(num2(size-2 downto msize))) - 15;
							--resultsign <= num2(15);
							--smallreg(24 downto 15) <= num1(9 downto 0);
							--smallshift <= to_integer(unsigned(num1(size-2 downto msize))) - 15;
							bigreg(bias+msize-1 downto bias) <= num2(msize-1 downto 0);
							bigshift <= to_integer(unsigned(num2(size-2 downto msize))) - bias;
							resultsign <= num2(size-1);
							smallreg(bias+msize-1 downto bias) <= num1(msize-1 downto 0);
							smallshift <= to_integer(unsigned(num1(size-2 downto msize))) - bias;
							
						else
							if (num1(9 downto 0) > num2(9 downto 0)) then
								--bigreg(24 downto 15) <= num1(9 downto 0);
								--bigshift <= to_integer(unsigned(num1(size-2 downto msize))) - 15;
								--resultsign <= num1(15);
								--smallreg(24 downto 15) <= num2(9 downto 0);
								--smallshift <= to_integer(unsigned(num2(size-2 downto msize))) - 15;
								bigreg(bias+msize-1 downto bias) <= num1(msize-1 downto 0);
								bigshift <= to_integer(unsigned(num1(size-2 downto msize))) - bias;
								resultsign <= num1(size-1);
								smallreg(bias+msize-1 downto bias) <= num2(msize-1 downto 0);
								smallshift <= to_integer(unsigned(num2(size-2 downto msize))) - bias;
								
							elsif (num2(9 downto 0) > num1(9 downto 0)) then
								--bigreg(24 downto 15) <= num2(9 downto 0);
								--bigshift <= to_integer(unsigned(num2(size-2 downto msize))) - 15;
								--resultsign <= num2(15);
								--smallreg(24 downto 15) <= num1(9 downto 0);
								--smallshift <= to_integer(unsigned(num1(size-2 downto msize))) - 15;
								bigreg(bias+msize-1 downto bias) <= num2(msize-1 downto 0);
								bigshift <= to_integer(unsigned(num2(size-2 downto msize))) - bias;
								resultsign <= num2(size-1);
								smallreg(bias+msize-1 downto bias) <= num1(msize-1 downto 0);
								smallshift <= to_integer(unsigned(num1(size-2 downto msize))) - bias;
								
							else
								result <= (others => '0');
								ready <= '1';
								--state <= RDY;
								flag := 1;
							end if;
						end if;
					
					else
						--bigreg(24 downto 15) <= num1(9 downto 0);
						--bigshift <= to_integer(unsigned(num1(size-2 downto msize))) - 15;
						--resultsign <= num1(15);
						--smallreg(24 downto 15) <= num2(9 downto 0);
						--smallshift <= to_integer(unsigned(num2(size-2 downto msize))) - 15;
						bigreg(bias+msize-1 downto bias) <= num1(msize-1 downto 0);
						bigshift <= to_integer(unsigned(num1(size-2 downto msize))) - bias;
						resultsign <= num1(size-1);
						smallreg(bias+msize-1 downto bias) <= num2(msize-1 downto 0);
						smallshift <= to_integer(unsigned(num2(size-2 downto msize))) - bias;
						
					end if;
					
					--state <= NEGPOS;
					
					if (flag=1) then
						state <= RDY;
					else
						state <= NEGPOS;
					end if;
					
				when NEGPOS =>
					if (bigshift > 0) then
						bigreg <= std_logic_vector(shift_left(unsigned(bigreg), bigshift));
					else
						bigreg <= std_logic_vector(shift_right(unsigned(bigreg), (-1*bigshift)));
					end if;
					
					if (smallshift > 0) then
						smallreg <= std_logic_vector(shift_left(unsigned(smallreg), smallshift));
					else
						smallreg <= std_logic_vector(shift_right(unsigned(smallreg), (-1*smallshift)));
					end if;
					
					state <= OP;
					
				when OP =>
					if (num1(size-1) /= num2(size-1)) then
						resultreg <= std_logic_vector(unsigned(bigreg) - unsigned(smallreg));
					else
						resultreg <= std_logic_vector(unsigned(bigreg) + unsigned(smallreg));
					end if;
					
					state <= SHIFT;
					
				when SHIFT =>
					for i in bigsize-1 downto 0 loop
						if ((resultreg(i) = '1') or (i=0)) then
							--position <= i;
							position <= std_logic_vector(to_unsigned(i, esize+1));
							exit;
						end if;
					end loop;
					
					state <= WRT;
					
				when WRT =>
					--resultshift <= std_logic_vector(to_unsigned(position - msize, esize));
					resultshift <= std_logic_vector(to_unsigned(to_integer(unsigned(position)) - msize, esize));
					if (unsigned(position) >= msize+1) then
						--resultfrac <= resultreg(position-1 downto position - msize);
						resultfrac <= resultreg(to_integer(unsigned(position))-1 downto to_integer(unsigned(position)) - msize);	
					end if;
					state <= RSLT;
					
				when RSLT =>
					result <= resultsign & resultshift & resultfrac;
					ready <= '1';
					state <= RDY;
			end case;
		end if;
	end process;
end architecture;