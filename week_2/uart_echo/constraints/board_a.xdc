
## =========================================================
## UART Echo Project - Board A
## Board: PYNQ-Z2 (XC7Z020-CLG400-1)
## =========================================================

## 1. System clock: 125 MHz
set_property -dict { PACKAGE_PIN H16 IOSTANDARD LVCMOS33 } [get_ports clk]
create_clock -add -name sys_clk_pin -period 8.000 -waveform {0 4} [get_ports clk]

## 2. Reset button: BTN0
set_property -dict { PACKAGE_PIN D19 IOSTANDARD LVCMOS33 } [get_ports rst]

## 3. UART signals: PMOD JA
## Board A TX -> Board B RX
## Board B TX -> Board A RX
set_property -dict { PACKAGE_PIN Y18 IOSTANDARD LVCMOS33 } [get_ports uart_tx]
set_property -dict { PACKAGE_PIN Y19 IOSTANDARD LVCMOS33 } [get_ports uart_rx]

## 4. Nibble selection button: BTN1
set_property -dict { PACKAGE_PIN D20 IOSTANDARD LVCMOS33 } [get_ports btn_nibble]

## 5. Four onboard user LEDs
## data_led[0] = LD0
## data_led[1] = LD1
## data_led[2] = LD2
## data_led[3] = LD3
set_property -dict { PACKAGE_PIN R14 IOSTANDARD LVCMOS33 } [get_ports {data_led[0]}]
set_property -dict { PACKAGE_PIN P14 IOSTANDARD LVCMOS33 } [get_ports {data_led[1]}]
set_property -dict { PACKAGE_PIN N16 IOSTANDARD LVCMOS33 } [get_ports {data_led[2]}]
set_property -dict { PACKAGE_PIN M14 IOSTANDARD LVCMOS33 } [get_ports {data_led[3]}]

## 6. RGB LED LD4
## Green channel: PASS
## Red channel: FAIL
## RGB channels are active-low
set_property -dict { PACKAGE_PIN G17 IOSTANDARD LVCMOS33 } [get_ports rgb_green_n]
set_property -dict { PACKAGE_PIN N15 IOSTANDARD LVCMOS33 } [get_ports rgb_red_n]
