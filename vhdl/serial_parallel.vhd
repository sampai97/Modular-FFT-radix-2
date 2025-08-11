library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;
use work.fft_types_pkg.all;

entity serial_parallel is
    generic(
        N       : integer := 64;
        N_bit   : integer := 15
    );
    port(
        clk,rst         : in STD_LOGIC;
        serial_in       : in signed(N_bit-1 downto 0);
        parallel_out    : out array_data
        );
end serial_parallel;

architecture Behavioral of serial_parallel is

signal cnt_N        : unsigned(log2ceil(N)-1 downto 0); --counter signal
signal reg_array    : array_data;                       --shift register signal
begin

counter_N: process(clk,rst)                             --counter for sending input sample in parallel all together (windowing rectangle 0-N)
begin
    if rst = '0' then
        cnt_N <= (others => '0');        
    elsif(clk' event and clk = '1') then
        if (cnt_N = N-1) then
            cnt_N <= (others => '0');
        else
            cnt_N <= cnt_N + 1;
        end if;
    end if;
end process;

shift_reg: process(clk,rst)                             --shift register to transition to serial to parallel
begin    
    if (rst = '0') then
        for i in 0 to N-1 loop
            reg_array(i) <= (others => '0');
        end loop;
    elsif (clk'event and clk = '1') then
        reg_array(0) <= serial_in;                      --input position
        for i in 0 to N-2 loop
            reg_array(i+1) <= reg_array(i);             --shifting for
        end loop;
    end if;
end process;

window: process(clk,rst)                                --FFD bank, keeps samples into FFT first stage
begin    
    if (rst = '0') then
        for i in 0 to N-1 loop
            parallel_out(i) <= (others => '0');
        end loop;
    elsif (clk'event and clk = '1' and cnt_N = N-1) then
        for i in 0 to N-1 loop
            parallel_out(i) <= reg_array(N-1-i);
        end loop;
    end if;
end process;


end Behavioral;