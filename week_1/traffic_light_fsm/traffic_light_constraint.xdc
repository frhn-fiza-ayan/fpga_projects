## ============================================================
## PYNQ-Z2 TRAFFIC LIGHT FSM
## ============================================================


## ============================================================
## 125 MHz CLOCK
## ============================================================

set_property -dict {PACKAGE_PIN H16 IOSTANDARD LVCMOS33} \
    [get_ports clk]

create_clock -add -name sys_clk_pin \
    -period 8.000 \
    -waveform {0.000 4.000} \
    [get_ports clk]


## ============================================================
## RESET
## BTN0
## ============================================================

set_property -dict {PACKAGE_PIN D19 IOSTANDARD LVCMOS33} \
    [get_ports reset]


## ============================================================
## LD4 - NORTH/SOUTH RGB LED
## ACTIVE-LOW
## ============================================================

# LD4 RED
set_property -dict {PACKAGE_PIN N15 IOSTANDARD LVCMOS33} \
    [get_ports led4_r]

# LD4 GREEN
set_property -dict {PACKAGE_PIN G17 IOSTANDARD LVCMOS33} \
    [get_ports led4_g]

# LD4 BLUE
set_property -dict {PACKAGE_PIN L15 IOSTANDARD LVCMOS33} \
    [get_ports led4_b]


## ============================================================
## LD5 - EAST/WEST RGB LED
## ACTIVE-LOW
## ============================================================

# LD5 RED
set_property -dict {PACKAGE_PIN M15 IOSTANDARD LVCMOS33} \
    [get_ports led5_r]

# LD5 GREEN
set_property -dict {PACKAGE_PIN L14 IOSTANDARD LVCMOS33} \
    [get_ports led5_g]

# LD5 BLUE
set_property -dict {PACKAGE_PIN G14 IOSTANDARD LVCMOS33} \
    [get_ports led5_b]