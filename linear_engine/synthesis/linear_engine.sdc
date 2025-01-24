create_clock -period "50.000000 MHz" -name clk [get_ports clock_50]

create_clock -name {altera_reserved_tck} -period 40 {altera_reserved_tck}
set_input_delay  -clock altera_reserved_tck -clock_fall 3 [get_ports altera_reserved_tdi]
set_input_delay  -clock altera_reserved_tck -clock_fall 3 [get_ports altera_reserved_tms]
set_output_delay -clock altera_reserved_tck             3 [get_ports altera_reserved_tdo]

derive_pll_clocks

derive_clock_uncertainty

set_false_path -from [get_clocks g_pll.system_pll|altera_pll|general[0].gpll~PLL_OUTPUT_COUNTER|divclk] -to [get_clocks g_pll.vga_pll|altera_pll|general[0].gpll~PLL_OUTPUT_COUNTER|divclk]
set_false_path -from [get_clocks g_pll.vga_pll|altera_pll|general[0].gpll~PLL_OUTPUT_COUNTER|divclk] -to [get_clocks g_pll.system_pll|altera_pll|general[0].gpll~PLL_OUTPUT_COUNTER|divclk]

set_false_path -from [get_ports {key*}] -to *
set_false_path -from [get_ports {sw*} ] -to *
set_false_path -from * -to [get_ports {led*}]
set_false_path -from * -to [get_ports {vga_*}]

set_false_path -from [get_ports {sim_rx} ] -to *
set_false_path -from * -to [get_ports {sim_tx}]

set_false_path -from [get_ports {hab_clk*} ] -to *
set_false_path -from [get_ports {hab_mosi*} ] -to *
set_false_path -from * -to [get_ports {hab_miso*}]

set_false_path -from [get_ports {hab_reset} ] -to *
set_false_path -from * -to [get_ports {hab_power}]
set_false_path -from * -to [get_ports {hab_int*}]
