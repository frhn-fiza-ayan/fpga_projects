
## =========================================================
## UART Echo Project - Board B
## Board: PYNQ-Z2 (XC7Z020-CLG400-1)
## Function: Receive and echo the byte
## =========================================================

## 1. System clock: 125 MHz
set_property -dict { PACKAGE_PIN H16 IOSTANDARD LVCMOS33 } [get_ports clk]
create_clock -add -name sys_clk_pin -period 8.000 -waveform {0 4} [get_ports clk]

## 2. Reset button: BTN0
set_property -dict { PACKAGE_PIN D19 IOSTANDARD LVCMOS33 } [get_ports rst]

## 3. UART connections: PMOD JA
## Board B RX uses package pin Y18
## Board B TX uses package pin Y19
set_property -dict { PACKAGE_PIN Y18 IOSTANDARD LVCMOS33 } [get_ports uart_rx]
set_property -dict { PACKAGE_PIN Y19 IOSTANDARD LVCMOS33 } [get_ports uart_tx]
