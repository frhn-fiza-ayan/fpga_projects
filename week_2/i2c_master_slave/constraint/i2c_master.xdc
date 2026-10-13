
## ==========================================
## PYNQ-Z2 I2C MASTER CONSTRAINTS
## ==========================================

## 125 MHz system clock
set_property -dict {PACKAGE_PIN H16 IOSTANDARD LVCMOS33} [get_ports clk]
create_clock -add -name sys_clk -period 8.000 [get_ports clk]

## Push buttons
## BTN0: Trigger transmission
set_property -dict {PACKAGE_PIN D19 IOSTANDARD LVCMOS33} [get_ports btn]

## BTN1: Reset
set_property -dict {PACKAGE_PIN D20 IOSTANDARD LVCMOS33} [get_ports rst]

## Four onboard LEDs
set_property -dict {PACKAGE_PIN R14 IOSTANDARD LVCMOS33} [get_ports {led[0]}]
set_property -dict {PACKAGE_PIN P14 IOSTANDARD LVCMOS33} [get_ports {led[1]}]
set_property -dict {PACKAGE_PIN N16 IOSTANDARD LVCMOS33} [get_ports {led[2]}]
set_property -dict {PACKAGE_PIN M14 IOSTANDARD LVCMOS33} [get_ports {led[3]}]

## Arduino header GPIO
## SCL: Arduino GPIO0, package pin T14
set_property -dict {PACKAGE_PIN T14 IOSTANDARD LVCMOS33} [get_ports i2c_scl]

## SDA: Arduino GPIO1, package pin U12
set_property -dict {PACKAGE_PIN U12 IOSTANDARD LVCMOS33} [get_ports i2c_sda]
