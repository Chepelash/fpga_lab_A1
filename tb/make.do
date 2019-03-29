transcript on


vlib work

vlog -sv ../src/rtc_clock.sv
vlog -sv ./rtc_clock_tb.sv

vsim -novopt rtc_clock_tb 

add wave /rtc_clock_tb/clk
add wave /rtc_clock_tb/rst
add wave /rtc_clock_tb/cmd_valid_i
add wave /rtc_clock_tb/cmd_type_i
add wave /rtc_clock_tb/cmd_data_i
add wave /rtc_clock_tb/hours_o
add wave /rtc_clock_tb/minutes_o
add wave /rtc_clock_tb/seconds_o
add wave /rtc_clock_tb/milliseconds_o


run -all

