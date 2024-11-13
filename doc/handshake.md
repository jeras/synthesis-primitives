# VALID/READY handshake

## Introduction

The AMBA AXI family of standards uses a well defined
handshaking protocol using signals VALID/READY.
The handshake is best documented as part of the AXI-Stream standard.
Here the protocol is stripped-down to it's minimum,
just the handshake and generic data.

This document provides a correct and optimal implementation of the protocol.

## Source code

### SystemVerilog modules

| module | RTL | TB | description |
|--------|-----|----|-------------|
| `register_slice_datapath`     | [RTL](../rtl/handshake/register_slice_datapath.sv)     | [TB](../tb/handshake/register_slice_datapath_tb.sv) | Register slice for the VALID signal and data path. |
| `register_slice_backpressure` | [RTL](../rtl/handshake/register_slice_backpressure.sv) | [TB](../tb/handshake/register_slice_backpressure_tb.sv) | Register slice for the backpressure signal READY. |
| `register_slice_datapath`     | [RTL](../rtl/handshake/register_slice_datapath.sv)     | [TB](../rtl/handshake/register_slice_datapath_tb.sv) | Register slice combining forward and backward paths.


### VHDL-2008 entities

| component | RTL | TB | description |
|-----------|-----|----|-------------|
| `register_slice_datapath`     | [RTL](../rtl/handshake/register_slice_datapath.vhd)    | [TB](../tb/handshake/register_slice_datapath_tb.vhd)    | Register slice for the VALID signal and data path. |
| `register_slice_backpressure` | [RTL](../rtl/handshakeregister_slice_backpressure.vhd) | [TB](../tb/handshakeregister_slice_backpressure_tb.vhd) | Register slice for the backpressure signal READY. |
| `register_slice_datapath`     | [RTL](../rtl/handshake/register_slice_datapath.vhd)    | [TB](../tb/handshake/register_slice_datapath_tb.vhd)    | Register slice combining forward and backward paths.



