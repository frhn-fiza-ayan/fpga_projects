## ============================================================
## PYNQ-Z2 PWM LED
## Top module: pwm_led
## ============================================================


## ============================================================
## 125 MHz Clock
## ============================================================

set_property -dict {PACKAGE_PIN H16 IOSTANDARD LVCMOS33} [get_ports clk]

create_clock -add -name sys_clk_pin \
    -period 8.000 \
    -waveform {0.000 4.000} \
    [get_ports clk]


## ============================================================
## Push Buttons
## PYNQ-Z2 button pins
## ============================================================

set_property -dict {PACKAGE_PIN D19 IOSTANDARD LVCMOS33} [get_ports {btn[0]}]

set_property -dict {PACKAGE_PIN D20 IOSTANDARD LVCMOS33} [get_ports {btn[1]}]

set_property -dict {PACKAGE_PIN L20 IOSTANDARD LVCMOS33} [get_ports {btn[2]}]

set_property -dict {PACKAGE_PIN L19 IOSTANDARD LVCMOS33} [get_ports {btn[3]}]


## ============================================================
## Onboard LEDs
## ============================================================

set_property -dict {PACKAGE_PIN R14 IOSTANDARD LVCMOS33} [get_ports led]


## ============================================================
## End of Constraints
## ============================================================