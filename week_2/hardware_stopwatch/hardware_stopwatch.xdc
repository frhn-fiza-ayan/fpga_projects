## ============================================================
## PYNQ-Z2 Hardware Stopwatch
## Display : 5161AS Common-Cathode 7-Segment
## Clock   : 125 MHz
##
## BTN0    : Reset
## BTN1    : Start / Stop
##
## PMOD-A  : 7-Segment A-G
## ============================================================


## ============================================================
## 125 MHz Clock
## ============================================================

set_property PACKAGE_PIN H16 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

create_clock -period 8.000 -name sys_clk -waveform {0.000 4.000} [get_ports clk]


## ============================================================
## Push Buttons
## ============================================================

## BTN0 - Reset
set_property PACKAGE_PIN D19 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports reset]

## BTN1 - Start / Stop
set_property PACKAGE_PIN D20 [get_ports start_stop]
set_property IOSTANDARD LVCMOS33 [get_ports start_stop]


## ============================================================
## 5161AS 7-Segment Display
##
## seg[6] = A
## seg[5] = B
## seg[4] = C
## seg[3] = D
## seg[2] = E
## seg[1] = F
## seg[0] = G
##
## PMOD-A pins used:
## JA1 = Y18
## JA2 = Y19
## JA3 = Y16
## JA4 = Y17
## JA7 = U18
## JA8 = U19
## JA9 = W18
##
## DP is not required for the stopwatch.
## ============================================================


## Segment A
set_property PACKAGE_PIN Y18 [get_ports {seg[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[6]}]

## Segment B
set_property PACKAGE_PIN Y19 [get_ports {seg[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[5]}]

## Segment C
set_property PACKAGE_PIN Y16 [get_ports {seg[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[4]}]

## Segment D
set_property PACKAGE_PIN Y17 [get_ports {seg[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[3]}]

## Segment E
set_property PACKAGE_PIN U18 [get_ports {seg[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[2]}]

## Segment F
set_property PACKAGE_PIN U19 [get_ports {seg[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[1]}]

## Segment G
set_property PACKAGE_PIN W18 [get_ports {seg[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[0]}]


## ============================================================
## Decimal Point
## ============================================================

## DP is not connected.
## If you want to connect DP later, use:
##
## set_property PACKAGE_PIN W19 [get_ports dp]
## set_property IOSTANDARD LVCMOS33 [get_ports dp]
##
## But keep DP disconnected for this project.
## ============================================================