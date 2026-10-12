
## ==========================================
## PYNQ-Z2 UART Receiver Constraints
## ==========================================

## 1. System clock: 125 MHz
set_property -dict {PACKAGE_PIN H16 IOSTANDARD LVCMOS33} \
    [get_ports {clk}]

create_clock -name sys_clk_pin -period 8.000 \
    -waveform {0 4} [get_ports {clk}]


## 2. UART RX: PMOD JA1
set_property -dict {PACKAGE_PIN Y18 IOSTANDARD LVCMOS33} \
    [get_ports {uart_rx}]


## 3. Four onboard LEDs: LD0-LD3
set_property -dict {PACKAGE_PIN R14 IOSTANDARD LVCMOS33} \
    [get_ports {led_data[0]}]

set_property -dict {PACKAGE_PIN P14 IOSTANDARD LVCMOS33} \
    [get_ports {led_data[1]}]

set_property -dict {PACKAGE_PIN N16 IOSTANDARD LVCMOS33} \
    [get_ports {led_data[2]}]

set_property -dict {PACKAGE_PIN M14 IOSTANDARD LVCMOS33} \
    [get_ports {led_data[3]}]


## 4. Success indicator: RGB LED LD4 Green
set_property -dict {PACKAGE_PIN G17 IOSTANDARD LVCMOS33} \
    [get_ports {success}]
