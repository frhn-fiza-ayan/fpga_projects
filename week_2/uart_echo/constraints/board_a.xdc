
## =========================================================
## Board A: UART Echo Test
## PYNQ-Z2 (Zynq-7000)
## =========================================================

## 125 MHz system clock
set_property -dict { PACKAGE_PIN H16 IOSTANDARD LVCMOS33 } [get_ports clk]
create_clock -add -name sys_clk_pin -period 8.000 -waveform {0 4} [get_ports clk]

## Reset input: PMOD JA pin 1
set_property -dict { PACKAGE_PIN C17 IOSTANDARD LVCMOS33 } [get_ports rst]

## UART TX: PMOD JA pin 2
set_property -dict { PACKAGE_PIN D18 IOSTANDARD LVCMOS33 } [get_ports uart_tx]

## UART RX: PMOD JA pin 3
set_property -dict { PACKAGE_PIN E18 IOSTANDARD LVCMOS33 } [get_ports uart_rx]

## PASS LED: LD4 red
set_property -dict { PACKAGE_PIN Y11 IOSTANDARD LVCMOS33 } [get_ports led_pass]

## FAIL LED: LD5 red
set_property -dict { PACKAGE_PIN T10 IOSTANDARD LVCMOS33 } [get_ports led_fail]
