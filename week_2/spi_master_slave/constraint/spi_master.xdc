
## ==========================================
## PYNQ-Z2 SPI MASTER
## Verify all package pins against the
## official PYNQ-Z2 master XDC before use.
## ==========================================

## 125 MHz system clock
set_property -dict { PACKAGE_PIN H16 IOSTANDARD LVCMOS33 } [get_ports clk]
create_clock -add -name sys_clk_pin -period 8.000 [get_ports clk]

## BTN0
set_property -dict { PACKAGE_PIN D19 IOSTANDARD LVCMOS33 } [get_ports btn]

## Four onboard LEDs
set_property -dict { PACKAGE_PIN R14 IOSTANDARD LVCMOS33 } [get_ports {led[0]}]
set_property -dict { PACKAGE_PIN P14 IOSTANDARD LVCMOS33 } [get_ports {led[1]}]
set_property -dict { PACKAGE_PIN N16 IOSTANDARD LVCMOS33 } [get_ports {led[2]}]
set_property -dict { PACKAGE_PIN M14 IOSTANDARD LVCMOS33 } [get_ports {led[3]}]

## SPI Chip Select output
set_property -dict { PACKAGE_PIN T14 IOSTANDARD LVCMOS33 } [get_ports spi_cs]

## SPI Clock output
set_property -dict { PACKAGE_PIN U12 IOSTANDARD LVCMOS33 } [get_ports spi_sclk]

## SPI Master Out, Slave In output
set_property -dict { PACKAGE_PIN V12 IOSTANDARD LVCMOS33 } [get_ports spi_mosi]
