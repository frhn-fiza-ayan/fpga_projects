
## ==========================================
## PYNQ-Z2 SPI SLAVE
## Verify all package pins against the
## official PYNQ-Z2 master XDC before use.
## ==========================================

## 125 MHz system clock
set_property -dict { PACKAGE_PIN H16 IOSTANDARD LVCMOS33 } [get_ports clk]
create_clock -add -name sys_clk_pin -period 8.000 [get_ports clk]

## Four onboard LEDs
set_property -dict { PACKAGE_PIN R14 IOSTANDARD LVCMOS33 } [get_ports {led[0]}]
set_property -dict { PACKAGE_PIN P14 IOSTANDARD LVCMOS33 } [get_ports {led[1]}]
set_property -dict { PACKAGE_PIN N16 IOSTANDARD LVCMOS33 } [get_ports {led[2]}]
set_property -dict { PACKAGE_PIN M14 IOSTANDARD LVCMOS33 } [get_ports {led[3]}]

## SPI Chip Select input
set_property -dict { PACKAGE_PIN W14 IOSTANDARD LVCMOS33 } [get_ports spi_cs]

## SPI Clock input
set_property -dict { PACKAGE_PIN Y14 IOSTANDARD LVCMOS33 } [get_ports spi_sclk]

## SPI Master Out, Slave In input
set_property -dict { PACKAGE_PIN T11 IOSTANDARD LVCMOS33 } [get_ports spi_mosi]
