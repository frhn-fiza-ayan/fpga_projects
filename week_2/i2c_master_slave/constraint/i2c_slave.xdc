
## ==========================================
## PYNQ-Z2 I2C SLAVE CONSTRAINTS
## ==========================================

## 125 MHz system clock
set_property -dict {PACKAGE_PIN H16 IOSTANDARD LVCMOS33} [get_ports clk]
create_clock -add -name sys_clk -period 8.000 [get_ports clk]

## Reset button: BTN1
set_property -dict {PACKAGE_PIN D20 IOSTANDARD LVCMOS33} [get_ports rst]

## Four onboard LEDs
set_property -dict {PACKAGE_PIN R14 IOSTANDARD LVCMOS33} [get_ports {led[0]}]
set_property -dict {PACKAGE_PIN P14 IOSTANDARD LVCMOS33} [get_ports {led[1]}]
set_property -dict {PACKAGE_PIN N16 IOSTANDARD LVCMOS33} [get_ports {led[2]}]
set_property -dict {PACKAGE_PIN M14 IOSTANDARD LVCMOS33} [get_ports {led[3]}]

## Arduino header: I2C clock input
set_property -dict {PACKAGE_PIN T14 IOSTANDARD LVCMOS33} [get_ports i2c_scl]

## Arduino header: I2C bidirectional data
set_property -dict {PACKAGE_PIN U12 IOSTANDARD LVCMOS33} [get_ports i2c_sda]
