
## PYNQ-Z2 clock: 125 MHz
set_property -dict { PACKAGE_PIN H16 IOSTANDARD LVCMOS33 } [get_ports { clk }]
create_clock -add -name sys_clk_pin -period 8.000 -waveform {0 4} [get_ports { clk }]

## UART RX: PMOD JA pin 1 (JA1_P)
set_property -dict { PACKAGE_PIN Y18 IOSTANDARD LVCMOS33 } [get_ports { uart_rx }]

## Four onboard LEDs: LD0-LD3
## led_data[0] -> LD0
## led_data[1] -> LD1
## led_data[2] -> LD2
## led_data[3] -> LD3
set_property -dict { PACKAGE_PIN R14 IOSTANDARD LVCMOS33 } [get_ports { led_data[0] }]
set_property -dict { PACKAGE_PIN P14 IOSTANDARD LVCMOS33 } [get_ports { led_data[1] }]
set_property -dict { PACKAGE_PIN N16 IOSTANDARD LVCMOS33 } [get_ports { led_data[2] }]
set_property -dict { PACKAGE_PIN M14 IOSTANDARD LVCMOS33 } [get_ports { led_data[3] }]

## Success indicator: RGB LED LD4 Green
set_property -dict { PACKAGE_PIN G17 IOSTANDARD LVCMOS33 } [get_ports { success }]
