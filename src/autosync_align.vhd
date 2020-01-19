library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.math_real.all; 
entity autosync_align is
  generic(cci_strbToClkRatio : positive:=2); -- cci_strb period / clk_period
  port( 
    );
end autosync_align;

architecture behavioral of autosync_align is
    -- Program Dependable parameters    
    signal numOfPulsesWithIncci_strb : std_logic_vector(2 downto 0);

    signal ps_cnt_p_D  : std_logic_vector(2 downto 0) := '000';
    signal ps_cnt_n_D  : std_logic_vector(2 downto 0) := '000';
    signal trk_cnt_p_D : std_logic_vector(2 downto 0) := '000';
    signal trk_cnt_n_D : std_logic_vector(2 downto 0) := '000';
    signal ps_cnt_p_Q  : std_logic_vector(2 downto 0) := '000';
    signal ps_cnt_n_Q  : std_logic_vector(2 downto 0) := '000';
    signal trk_cnt_p_Q : std_logic_vector(2 downto 0) := '000';
    signal trk_cnt_n_Q : std_logic_vector(2 downto 0) := '000';

    signal cci_strb    : std_logic :='0';
    signal ps_incdec   : std_logic :='1';

    numOfPulsesWithIncci_strb <= std_logic_vector(to_unsigned(cci_strbToClkRatio, numOfPulsesWithIncci_strb'length)) ;
    type state_type is ( IDEAL , 
                         DETERMINE_FIRST_CLK_EDGE_WITHIN_CCI, 
                         DETERMINE_NEG_CLK_COUNT_VALID_WITHIN_CCI,
                         DETERMINE_POS_CLK_COUNT_VALID_WITHIN_CCI,
                         CHECK_INPUT_CLK_ALIGNMENT_WITH_CCI,
                         SHIFT_INPUT_CLK_TO_PERFECT_ALIGNMENT,
                         INTERMITTENT_PHS_SHIFT,
                         FINAL_PHS_SHIFT,
                         INPUT_CLK_PHASE_LOCKED_WITH_CCI                                                                      
                         )
    signal state, next_state : state_type ;
begin
  SYNC_PROC_P : process (PS_CLK)
  begin
    if rising_edge(PS_CLK) then
      if (reset_mmcm = '1' or locked = '0') then
        state <= IDEAL;
        ps_cnt_p_Q  <= '000'  ;  
        trk_cnt_p_Q <= '000'  ;   
      elsif(cci_strb = '1') 
        ps_cnt_p_Q  <= ps_cnt_p_D  ;  
        trk_cnt_p_Q <= trk_cnt_p_D ; 
        state <= next_state;
      end if;
    end if;
  end process;
  SYNC_PROC_N : process (PS_CLK)
  begin
    if falling_edge(PS_CLK) then
      if (reset_mmcm = '1' or locked = '0') then
        ps_cnt_n_Q  <= '000'  ;  
        trk_cnt_n_Q <= '000'  ; 
      elsif(cci_strb='1') 
        ps_cnt_n_Q  <= ps_cnt_n_D  ;  
        trk_cnt_n_Q <= trk_cnt_n_D ; 
      end if;
    end if;
  end process;

  COUNT_PS_CLK_RISING_EDGE_WITHIN_CCI : process (PS_CLK)
  begin 
    if rising_edge(PS_CLK ) then
      if(cci_strb = '0' or reset_mmcm = '1' or locked = '0') then 
        ps_cnt_p_D <= '000' ;
      elsif (cci_strb = '1') then 
        ps_cnt_p_D <= ps_cnt_p_D + 1 ;
      end if ;
    end if; 
  end process ;
        
  COUNT_PS_CLK_FALLING_EDGE_WITHIN_CCI : process (PS_CLK)
  begin 
    if falling_edge(PS_CLK) then
      if(cci_strb = '0' or reset_mmcm = '1' or locked = '0') then 
        ps_cnt_n_D <= '000' ;
      elsif (cci_strb = '1') then 
        ps_cnt_n_D <= ps_cnt_n_D + 1 ;
      end if ;
    end if ;
  end process ;
 
  COUNT_INPUT_CLK_RISING_EDGE_WITHIN_CCI : process (INPUT_CLK)
  begin 
    if rising_edge(INPUT_CLK) then
      if(cci_strb = '0' or reset_mmcm = '1' or locked = '0') then 
        trk_cnt_p_D <= '000' ;
      elsif (cci_strb = '1') then 
        trk_cnt_p_D <= trk_cnt_p_D + 1 ;
      end if ;
    end if;
  end process ;
 
  COUNT_INPUT_CLK_FALLING_EDGE_WITHIN_CCI : process (INPUT_CLK)
  begin 
    if falling_edge(INPUT_CLK) then
      if(cci_strb = '0' or reset_mmcm = '1' or locked = '0') then 
        trk_cnt_n_D <= '000' ;
      elsif (cci_strb = '1') then 
        trk_cnt_n_D <= trk_cnt_n_D + 1 ;
      end if ;
    end if;
  end process ;
  STATE_MACHINE_PROC : process (
                                ps_cnt_p_Q, ps_cnt_n_Q,
                                trk_cnt_p_Q, trk_cnt_n_Q,
                                ps_done
                              )
  begin
    if(reset_mmcm = '1' or locked = '0') then 
      next_state <= IDEAL ;
    else
      case(state) is 
        when IDEAL => 
          if(cci_strb = '1') then 
            next_state <= DET_FIRST_EDGE ;
            ps_incdec  <= '1';
          end if;
        when DETERMINE_FIRST_CLK_EDGE_WITHIN_CCI =>
          -- protection to avoid combinotorial circuit to 
          -- re-evalute next state within cci_strb interval
          if(next_state /= state)
            next_state <= next_state ; 
          elsif(ps_cnt_p_Q = '001' and ps_cnt_n_Q = '000') then -- first rising edge within cci_strb
            next_state <= DETERMINE_POS_CLK_COUNT_VALID_WITHIN_CCI ;
          elsif(ps_cnt_n_Q = '001' and ps_cnt_p_Q = '000') then -- first falling edge within cci_strb
            next_state <= DETERMINE_NEG_CLK_COUNT_VALID_WITHIN_CCI ;
          end if;
        when DETERMINE_NEG_CLK_COUNT_VALID_WITHIN_CCI =>
          if(next_state /= state)
            next_state <= next_state ;
          elsif(ps_cnt_n_Q = numOfPulsesWithIncci_strb) then
            next_state <= CHECK_INPUT_CLK_ALIGNMENT_WITH_CCI;
          end if;
        when DETERMINE_POS_CLK_COUNT_VALID_WITHIN_CCI =>
          if(next_state /= state)
            next_state <= next_state ;
          elsif(ps_cnt_p_D = numOfPulsesWithIncci_strb) then 
            next_state <= CHECK_INPUT_CLK_ALIGNMENT_WITH_CCI;
            cci_strb_counter_start <= '1';
          end if;
        when CHECK_INPUT_CLK_ALIGNMENT_WITH_CCI =>
          if(next_state /= state)
            next_state <= next_state ;
          -- tracking clk rising edge comes first before reference clock. This condition exist when tracking 
          -- clk moved one tap delay after perfect alignment with cci strb
          elsif( trk_cnt_p_Q = '001' and ps_cnt_p_Q = '000' ) then 
            next_state <= SHIFT_INPUT_CLK_TO_PERFECT_ALIGNMENT ;
          elsif(cci_strb = '0') then 
            next_state <= INTERMITTENT_PHS_SHIFT;
            ps_signal_q <= '1'
          end if;
        when SHIFT_INPUT_CLK_TO_PERFECT_ALIGNMENT =>
          if(next_state /= state)
            next_state <= next_state ;
          elsif(cci_strb = '0') then
            ps_incdec  <= '0' ; 
            next_state <= FINAL_PHS_SHIFT;
            ps_signal_q <= '1'
            next_state <= IDEAL;
          end if;
        when INTERMITTENT_PHS_SHIFT =>
          if(next_state /= state)
            next_state <= next_state ;
          elsif(ps_done = '1') then
            next_state <= IDEAL;
          end if;
        when FINAL_PHS_SHIFT =>
          if(next_state /= state)
            next_state <= next_state ;
          elsif(ps_done = '1') then
            next_state <= INPUT_CLK_PHASE_LOCKED_WITH_CCI;
          end if;
        when INPUT_CLK_PHASE_LOCKED_WITH_CCI =>
          if(next_state /= state)
            next_state <= next_state ;
          if(cci_strb_counter_expired) then 
            next_state <= IDEAL;
          enf if;
end architecture;