## ============================================================
## PYNQ-Z2 - Button Debouncer
## Top module: button_debouncer_top
## Clock: 125 MHz
## ============================================================

## ------------------------------------------------------------
## 125 MHz System Clock
## ------------------------------------------------------------

set_property -dict {PACKAGE_PIN H16 IOSTANDARD LVCMOS33} [get_ports clk]

create_clock -add -name sys_clk_pin \
    -period 8.000 \
    -waveform {0 4} \
    [get_ports clk]


## ------------------------------------------------------------
## Push Button BTN0
## ------------------------------------------------------------

set_property -dict {PACKAGE_PIN D19 IOSTANDARD LVCMOS33} [get_ports btn]


## ------------------------------------------------------------
## On-board LED0
## ------------------------------------------------------------

set_property -dict {PACKAGE_PIN R14 IOSTANDARD LVCMOS33} [get_ports led]