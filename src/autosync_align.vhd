library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.math_real.all; 
entity autosync_align is
  generic(XXXXX_XXXXXToClkRatio : positive:=2); -- XXXXX_XXXXX_strb period / clk_period
  port( 
    );

end autosync_align;
 

architecture behavioral of autosync_align is

    -- Program Dependable parameters    
    signal ps_cnt_p  : std_logic_vector(2 downto 0) := '000';
    signal ps_cnt_n  : std_logic_vector(2 downto 0) := '000';
    signal trk_cnt_p : std_logic_vector(2 downto 0) := '000';
    signal trk_cnt_p : std_logic_vector(2 downto 0) := '000';
    signal numOfPulsesWithInXXXXX_XXXXX : std_logic_vector(2 downto 0);
 
    numOfPulsesWithInXXXXX_XXXXX <= std_logic_vector(to_unsigned(XXXXX_XXXXXToClkRatio, numOfPulsesWithInXXXXX_XXXXX'length)) ;
    type state_type is ( IDEAL , 
                         DET_FIRST_EDGE_P, 
                         DET_FIRST_EDGE_N, 
                         DET_PS_CNT_VALID_P,
                         DET_PS_CNT_VALID_N,
                         DET_TRK_CNT_VALID,
                         PHS_SHIFT,
                         XXXXX_XXXXX_LOCKED                                                                      
                         )
    signal state, next_state : state_type ;

begin

  SYNC_PROC : process (PS_CLK)
  begin
    if rising_edge(PS_CLK) then
      if (reset = '1') then
        state <= IDEAL;
      elsif(XXXXX_XXXXX_strb = '0') -- only change state after XXXXX_XXXXX strb 
        state <= next_state;
      end if;
    end if;
  end process;

  process_ps_rise : process(cci_strb, PS_CLK) 
  begin
    if(rising_edge(cci_strb) and rising_edge(PS_CLK)) then 
  end process;
  

 
  PS_CNT_WITHIN_XXXXX_XXXXX_P : process (PS_CLK)
  begin 
    if rising_edge(PS_CLK ) then

      if(XXXXX_XXXXX_strb = '0' or reset_mmcm = '1' or locked '0') then 
        ps_cnt_p <= '000' ;
      elsif (XXXXX_XXXXX = '1') then 
        ps_cnt_p <= ps_cnt_p + 1 ;
      end if ;
    end if; 
  end process ;
        
  PS_CNT_WITHIN_XXXXX_XXXXX_N : process (PS_CLK)
  begin 
    if falling_edge(PS_CLK) then

      if(XXXXX_XXXXX_strb = '0' or reset_mmcm = '1' or locked '0') then 
        ps_cnt_n <= '000' ;
      elsif (XXXXX_XXXXX = '1') then 
        ps_cnt_n <= ps_cnt_n + 1 ;
      end if ;
    end if ;
  end process ;
 
  PS_CNT_WITHIN_XXXXX_XXXXX_P : process (XXXXX_XXXXX_TRACKIN_CLK)
  begin 
    if rising_edge(XXXXX_XXXXX_TRACKIN_CLK ) then

      if(XXXXX_XXXXX_strb = '0' or reset_mmcm = '1' or locked '0') then 
        trk_cnt_p <= '000' ;
      elsif (XXXXX_XXXXX = '1') then 
        trk_cnt_p <= trk_cnt_p + 1 ;
      end if ;
    end if;
  end process ;
 
  PS_CNT_WITHIN_XXXXX_XXXXX_P : process (XXXXX_XXXXX_TRACKIN_CLK)
  begin 
    if falling_edge(XXXXX_XXXXX_TRACKIN_CLK ) then

      if(XXXXX_XXXXX_strb = '0' or reset_mmcm = '1' or locked '0') then 
        trk_cnt_n <= '000' ;
      elsif (XXXXX_XXXXX = '1') then 
        trk_cnt_n <= trk_cnt_n + 1 ;
      end if ;
    end if;
  end process ;
 
  STATE_MACHINE_PROC : process (
                                ps_cnt_p, ps_cnt_n,
                                trk_cnt_p, trk_cnt_n, 
                                PS_CLK, XXXXX_XXXXX_strb, ps_done

                              )
  begin 
    if(reset_mmcm = '1' or locked = '0') then 
      next_state <= IDEAL ;
    else

      case(state) is 
        when IDEAL => 
          if(rising_edge(XXXXX_XXXXX_strb)) then 
            next_state <= DET_FIRST_EDGE ;
          end if;
        when DET_FIRST_EDGE_P =>
-- protection to avoid combinotorial circuit to re-evalute next state within XXXXX_XXXXX strb

          if(next_state /= state)
            next_state <= next_state ; 
          elsif(XXXXX_XXXXX_strb = '1' and ps_cnt_p = '001') then -- first rising edge within XXXXX_XXXXX

            next_state <= DET_PS_CNT_VALID_P ;
          elsif(XXXXX_XXXXX_strb = '1' and ps_cnt_n = '001') then -- first falling edge within XXXXX_XXXXX

            next_state <= DET_PS_CNT_VALID_N ;
          end if;
        when DET_PS_CNT_VALID_P =>
          if(next_state /= state)
            next_state <= next_state ;
          elsif(XXXXX_XXXXX_strb = '1' and ps_cnt_p = numOfPulsesWithInXXXXX_XXXXX) then 
            next_state <= DET_TRK_CNT_VALID_P;
          end if;
        when DET_PS_CNT_VALID_N =>
          if(next_state /= state)
            next_state <= next_state ;
          elsif(XXXXX_XXXXX_strb = '1' and ps_cnt_n = numOfPulsesWithInXXXXX_XXXXX) then 
            next_state <= DET_TRK_CNT_VALID_N;
            XXXXX_XXXXX_counter_start <= '1';
          end if;
        when DET_TRK_CNT_VALID =>
          if(next_state /= state)
            next_state <= next_state ;
          elseif( trk_cnt_p = '001' and ps_cnt_p = '000' ) then 
            next_state <= XXXXX_XXXXX_LOCKED ;
          elsif(falling_edge(XXXXX_XXXXX_strb) and ps_cnt_p = trk_cnt_p) then 
            next_state <= PHS_SHIFT;
            ps_signal_q <= '1'
          end if;
        when PHS_SHIFT =>
          if(next_state /= state)
            next_state <= next_state ;
          elsif(ps_done = '1') then
            next_state <= IDEAL;
          end if;
 
        when XXXXX_XXXXX_LOCKED =>
          if(next_state /= state)
            next_state <= next_state ;
          if(XXXXX_XXXXX_counter_expired) then 
            next_state <= IDEAL;
          enf if;
end architecture;