-------------------------------------------------------------------------------
-- synchronous FIFO with VALID/READY handshake
--
-- Copyright 2025 Iztok Jeras <iztok.jeras@gmail.com>
--
-- Licensed under CERN-OHL-P v2 or later
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity fifo_synchronous is
    generic (
        -- configuration
        DEPTH        : natural := 1;  -- depth of DATA buffer
        FALL_THROUGH : boolean := false;  -- combinational fall through enable
        -- data type
        type DAT_T
    );
    port (
        -- system signals
        clk    : in  std_logic;  -- clock
        rst    : in  std_logic;  -- reset
        -- receiver interface
        rx_vld : in  std_logic;  -- valid
        rx_dat : in  DAT_T;      -- data
        rx_rdy : out std_logic;  -- ready
        -- transmitter interface
        tx_vld : out std_logic;  -- valid
        tx_dat : out DAT_T;      -- data
        tx_rdy : in  std_logic   -- ready
    );
end fifo_synchronous;

architecture rtl of fifo_synchronous is

    -- counter width
    constant DEPTH_LOG : positive := integer(ceil(log2(real(DEPTH))));

    -- transfers
    signal rx_trn : std_logic;
    signal tx_trn : std_logic;

    -- buffer sets and address counters (current, next, end)
    signal rx_set    , tx_set    : std_logic := '0';
    signal rx_cnt    , tx_cnt    : unsigned(DEPTH_LOG-1 downto 0) := (others => '0');
    signal rx_cnt_nxt, tx_cnt_nxt: unsigned(DEPTH_LOG-1 downto 0);
    signal rx_cnt_end, tx_cnt_end: std_logic;
    -- set and counter equivalence, empty, full
    signal rx_full   , tx_empty  : std_logic;
    signal cnt_equal , set_equal : std_logic;

    -- memory
    type mem_t is array (0 to DEPTH-1) of DAT_T;
    signal mem : mem_t;

begin

-------------------------------------------------------------------------------
-- set and counter comparison
-------------------------------------------------------------------------------
    
    set_equal <= '1' when (rx_set = tx_set) else '0';
    cnt_equal <= '1' when (rx_cnt = tx_cnt) else '0';
    
-------------------------------------------------------------------------------
-- receiver side
-------------------------------------------------------------------------------
    
    -- stream data transfer
    rx_trn <= rx_vld and rx_rdy;
    
    -- counter increment
    rx_cnt_nxt <= rx_cnt + 1;
    
    -- counter reaching end
    rx_cnt_end <= '1' when (rx_cnt = DEPTH-1) else '0';
    
    -- FIFO full
    rx_full <= not set_equal and cnt_equal;
    
    -- receiver write pointer change (on RX transfer)
    rx_control: process(clk)
    begin
        if (rising_edge(clk)) then
            if (rst = '1') then
                rx_cnt <= (others => '0');
            else
                if (rx_trn = '1') then
                    rx_set <= not rx_set      when (rx_cnt_end = '1') else rx_set    ;
                    rx_cnt <= (others => '0') when (rx_cnt_end = '1') else rx_cnt_nxt;
                end if;
            end if;
        end if;
    end process rx_control;

    -- synchronous memory write (on RX transfer)
    rx_data: process(clk)
    begin
        if rising_edge(clk) then
            if (rx_trn = '1') then
                mem(to_integer(rx_cnt)) <= rx_dat;
            end if;
        end if;
    end process rx_data;

    -- drain ready signal (sets are complementary while counters are equal)
    rx_ready: if FALL_THROUGH generate
        rx_rdy <= tx_rdy when rx_full else '1';
    else generate
        rx_rdy <= '0'    when rx_full else '1';
    end generate rx_ready;

-------------------------------------------------------------------------------
-- transmitter side
-------------------------------------------------------------------------------

    -- stream data transfer
    tx_trn <= tx_vld and tx_rdy;

    -- counter increment
    tx_cnt_nxt <= tx_cnt + 1;

    -- counter reaching end
    tx_cnt_end <= '1' when (tx_cnt = DEPTH-1) else '0';

    -- FIFO empty
    tx_empty <= set_equal and cnt_equal;

    -- transmitter read pointer change (on TX transfer)
    tx_control: process(clk)
    begin
        if (rising_edge(clk)) then
            if (rst = '1') then
                tx_cnt <= (others => '0');
            else
                if (tx_trn = '1') then
                    tx_set <= not tx_set      when (tx_cnt_end = '1') else tx_set   ;
                    tx_cnt <= (others => '0') when (tx_cnt_end = '1') else tx_cnt_nxt;
                end if;
            end if;
        end if;
    end process tx_control;

    -- transmitter memory read
    tx_data: if FALL_THROUGH generate
        tx_dat <= rx_dat when tx_empty else mem(to_integer(tx_cnt));
    else generate
        tx_dat <=                           mem(to_integer(tx_cnt));
    end generate tx_data;

    -- transmitter valid signal (sets and counters are equal)
    tx_valid: if FALL_THROUGH generate
        tx_vld <= rx_vld when tx_empty else '1';
    else generate
        tx_vld <= '0'    when tx_empty else '1';
    end generate tx_valid;
  
end rtl;
