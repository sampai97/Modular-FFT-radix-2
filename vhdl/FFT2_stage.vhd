library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;
use work.fft_types_pkg.all;
use work.twiddle_type_pkg.all;

entity modular_FFT_stage is
    generic(
        N : integer := 64;
        dist  : integer := 8;
        N_bit : integer := 15
    );
    port(
        clk,rst : in std_logic;
        x : in array_data;
        y : out array_data
    );
end modular_FFT_stage;

architecture Behavioral of modular_FFT_stage is
signal pipeline : array_data;                                                       --layer of pipeline between every stage
signal temp_array_re,temp_array_im,temp_result_re,temp_result_im : temp_result;     --signals to temporary storage partial result
signal temp_ac,temp_bd,temp_ad,temp_bc : temp_array;
signal temp_result_dist_re,temp_result_dist_im : temp_result_dist;

begin

L1Pipeline: process(clk,rst)    --single layer pipeline
begin
    if rst = '0' then
        for k in 0 to N-1 loop
            pipeline(k) <= (others => '0');
        end loop;
    elsif clk' event and clk = '1' then
        pipeline <= x;
    end if;
end process; 

butterfly: process(pipeline,temp_array_im,temp_array_re,temp_result_re,temp_result_im,temp_ac,temp_bd,temp_ad,temp_bc,temp_result_dist_re,temp_result_dist_im)
variable a_re,a_im,b_re,b_im,c : integer := 0;
begin
    -- generic complex number is z = a + j*b. In this project x(i) = a, x(i+1) = b
    -- twiddle factor is complex so w = c + j*d then twiddle_re = c, twiddle_im = d
    -- unpacking complex multiplication: (a + j*b)*(c + j*d) = a*c - b*d + j*(b*c + a*d)
    for base in 0 to (N/(dist*2))-1 loop
        for i in 0 to dist/2-1 loop
            a_re := base*2*dist + i*2;
            a_im := base*2*dist + i*2 + 1;
            b_re := a_re + dist;
            b_im := a_im + dist;
            c := base*2*dist + i;   
            temp_result_re(a_re) <= resize(pipeline(a_re),N_bit+1)+resize(pipeline(b_re),N_bit+1);                 
            y(a_re) <= temp_result_re(a_re)(N_bit downto 1);                                            --real part of upper butterfly part, throw away less significant bit
            temp_result_im(a_im) <= resize(pipeline(a_im),N_bit+1)+resize(pipeline(b_im),N_bit+1);                 
            y(a_im) <= temp_result_im(a_im)(N_bit downto 1);                                            --imaginary part of upper butterfly part
            temp_array_re(c) <= resize(pipeline(a_re),N_bit+1) - resize(pipeline(b_re),N_bit+1);
            temp_array_im(c) <= resize(pipeline(a_im),N_bit+1) - resize(pipeline(b_im),N_bit+1);
            temp_ac(c) <= resize(temp_array_re(c)*twiddle_re(c),2*N_bit);
            temp_bd(c) <= resize(temp_array_im(c)*twiddle_im(c),2*N_bit);
            temp_ad(c) <= resize(temp_array_re(c)*twiddle_im(c),2*N_bit);
            temp_bc(c) <= resize(temp_array_im(c)*twiddle_re(c),2*N_bit);
            temp_result_dist_re(c) <= resize(temp_ac(c),2*N_bit+1)-resize(temp_bd(c),2*N_bit+1);        -- a*c - b*d
            temp_result_dist_im(c) <= resize(temp_ad(c),2*N_bit+1)-resize(temp_bc(c),2*N_bit+1);        -- a*d + b*c
            y(b_re) <= temp_result_dist_re(c)(2*N_bit downto N_bit+1);                                  --real part of bottom butterfly part
            y(b_im) <= temp_result_dist_im(c)(2*N_bit downto N_bit+1);                                  --imaginary part of bottom butterfly part
        end loop;
    end loop;
end process;
end Behavioral;
