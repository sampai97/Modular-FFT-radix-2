
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.fft_types_pkg.all;
use std.textio.all;

entity FFT2_main_tb is
end;

architecture bench of FFT2_main_tb is
  --constant
  constant clk_period : time := 5 ns;
  constant N : integer := 128;
  constant N_bit : integer := 15;
  --ports
  signal clk : std_logic;
  signal rst : std_logic;
  signal x : signed(N_bit-1 downto 0);
  signal y : signed(N_bit-1 downto 0);
  
begin

  FFT2 : entity work.FFT2_main
  generic map (
    N => N,
    N_bit => N_bit
  )
  port map (
    clk => clk,
    rst => rst,
    x => x,
    y => y
  );

process
begin
  clk <= '0';
  wait for clk_period/2;
  clk <= '1';
  wait for clk_period/2;
end process;

read_from_file:process(clk,rst)
  --input from file
  file test_vector : text open read_mode is "wave_samples";
  variable row : line;
  variable str : string(1 to N_bit);
  variable data_read : signed(N_bit-1 downto 0);

begin

  if rst = '0' then
      data_read := (others => '0');
  elsif clk'event and clk = '0' then
    if not endfile(test_vector) then
      readline(test_vector,row);
    end if;
    read(row,str);
    for i in 1 to N_bit loop  --convert string into 1 and 0 value
      if str(i) = '1' then
        data_read(N_bit-i) :=  '1';
      else
        data_read(N_bit-i) :=  '0';
      end if;
    end loop;
    x <= data_read;
  end if;
end process;

write_file : process(clk,rst)
--write on file output
  file result : text open write_mode is "FFT_out";  --file with results
  variable row_out : line;
  variable bin_str : string(1 to N_bit);
begin
  if(clk'event and clk = '1') then
    for i in 0 to N_bit-1 loop
      if y(i) = '1' then
        bin_str(N_bit-i) := '1';
      else
        bin_str(N_bit-i) := '0';
      end if;
    end loop;
    row_out := null;
    write(row_out,string'("'"));
    write(row_out,bin_str);
    write(row_out,string'("'"));
    writeline(result,row_out);
  end if;
end process;
rst <= '0', '1' after clk_period;
end;
