## =========================================================
## PYNQ-Z2 Button Controlled 4-bit Counter
## =========================================================

## =========================================================
## 125 MHz Clock
## =========================================================

set_property -dict {PACKAGE_PIN H16 IOSTANDARD LVCMOS33} [get_ports clk]

create_clock -add -name sys_clk_pin \
    -period 8.000 \
    -waveform {0.000 4.000} \
    [get_ports clk]


## =========================================================
## BTN0
## =========================================================

set_property -dict {PACKAGE_PIN D19 IOSTANDARD LVCMOS33} [get_ports btn]


## =========================================================
## LEDs LD0 - LD3
##
## led[0] -> LD0
## led[1] -> LD1
## led[2] -> LD2
## led[3] -> LD3
## =========================================================

set_property -dict {PACKAGE_PIN R14 IOSTANDARD LVCMOS33} [get_ports {led[0]}]

set_property -dict {PACKAGE_PIN P14 IOSTANDARD LVCMOS33} [get_ports {led[1]}]

set_property -dict {PACKAGE_PIN N16 IOSTANDARD LVCMOS33} [get_ports {led[2]}]

set_property -dict {PACKAGE_PIN M14 IOSTANDARD LVCMOS33} [get_ports {led[3]}]