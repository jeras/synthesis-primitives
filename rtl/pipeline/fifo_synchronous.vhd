-------------------------------------------------------------------------------
-- synchronous FIFO with VALID/READY handshake
--
-- Copyright 2025 Iztok Jeras <iztok.jeras@gmail.com>
--
-- Licensed under CERN-OHL-P v2 or later
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity fifo_synchronous is
    generic (
        -- data type
        type DAT_T
    );
    port (
        -- system signals
        clk    : in  std_logic;  -- clock
        rst    : in  std_logic;  -- reset
        -- receiver interface
        rx_vld : in  std_logic;
        rx_dat : in  DAT_T;
        rx_rdy : out std_logic;
        -- transmitter interface
        tx_vld : out std_logic;
        tx_dat : out DAT_T;
        tx_rdy : in  std_logic
    );
end fifo_synchronous;

architecture rtl of fifo_synchronous is

    -- transfer signals
    signal rx_trn : std_logic;
    signal tx_trn : std_logic;

begin

    -- transfer signals
    rx_trn <= rx_vld and rx_rdy;
    tx_trn <= tx_vld and tx_rdy;

end rtl;
