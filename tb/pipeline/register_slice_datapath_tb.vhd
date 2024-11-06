-------------------------------------------------------------------------------
-- register slice for forward data path,
-- testbench
--
-- Copyright 2025 Iztok Jeras <iztok.jeras@gmail.com>
--
-- Licensed under CERN-OHL-P v2 or later
-------------------------------------------------------------------------------

use std.env.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity register_slice_datapath_tb is
    generic (
        WIDTH : positive := 8
    );
end register_slice_datapath_tb;

architecture testbench of register_slice_datapath_tb is

    -- clock period
    constant T : time := 10.0 ns;

    -- system signals
    signal clk   : std_logic := '0';  -- clock
    signal rst   : std_logic := '1';  -- reset

    -- data type
    subtype DAT_T is std_logic_vector(WIDTH-1 downto 0);

    -- RX interface
    signal rx_vld : std_logic := '0';
    signal rx_dat : DAT_T;
    signal rx_rdy : std_logic;

    -- TX interface
    signal tx_vld : std_logic;
    signal tx_dat : DAT_T;
    signal tx_rdy : std_logic := '0';

begin

-------------------------------------------------------------------------------
-- test
-------------------------------------------------------------------------------

    -- clock source
    clock : process
    begin
        loop
            clk <= '1'; wait for T/2;
            clk <= '0'; wait for T/2;
        end loop;
    end process clock;

    -- test sequence
    test : process
    begin
        -- skip clock edge at time zero
        wait for 0 ns;
        -- TX/RX init
        rx_vld <= '0';
        rx_dat <= (others => 'X');
        tx_rdy <= '1';
        -- T0 (reset)
        rst <= '1';
        wait until rising_edge(clk);
        -- T1
        rst <= '0';
        wait until rising_edge(clk);
        -- T2
        rx_vld <= '1';
        rx_dat <= 8X"00";
        wait until rising_edge(clk);
        -- T3
        rx_vld <= '1';
        rx_dat <= 8X"01";
        wait until rising_edge(clk);
        assert (tx_dat = 8X"00") report "Step 3: TX data mismatch" severity ERROR;
        -- T4
        rx_vld <= '0';
        rx_dat <= (others => 'X');
        tx_rdy <= '0';
        wait until rising_edge(clk);
        -- T5
        tx_rdy <= '1';
        wait until rising_edge(clk);
        assert (tx_dat = 8X"01") report "Step 5: TX data mismatch" severity ERROR;
        -- T6
        tx_rdy <= '1';
        wait until rising_edge(clk);

        -- end simulation
        finish;
    end process test;

-------------------------------------------------------------------------------
-- DUT instance
-------------------------------------------------------------------------------

    dut : entity work.register_slice_datapath
    generic map (
        DAT_T => DAT_T
    )
    port map (
        -- system signals
        clk    => clk,
        rst    => rst,
        -- RX interface
        rx_vld => rx_vld,
        rx_dat => rx_dat,
        rx_rdy => rx_rdy,
        -- TX interface
        tx_vld => tx_vld,
        tx_dat => tx_dat,
        tx_rdy => tx_rdy
    );

end testbench;

