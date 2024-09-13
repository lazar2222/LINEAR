restart -f -nolist -nowave -nolog -nobreak -novirtuals -noassertions -nofcovers -noatv
onerror {resume}
radix define TARGET {
    "26'h0000" "IM0_0"
    "26'h0400" "IM0_1"
    "26'h0800" "DM0_0"
    "26'h0C00" "DM0_1"
    "26'h1000" "CM0_0"
    "26'h1400" "CM0_1"
    "26'h1800" "CM0_2"
    "26'h1C00" "CM0_3"
    "26'h2000" "IM1_0"
    "26'h2400" "IM1_1"
    "26'h2800" "DM1_0"
    "26'h2C00" "DM1_1"
    "26'h3000" "CM1_0"
    "26'h3400" "CM1_1"
    "26'h3800" "CM1_2"
    "26'h3C00" "CM1_3"
    "26'h4000" "SMC_0"
    "26'h4400" "MISS"
    -default hex
}
radix define SOURCE {
    "10" "SM0_IM"
    "11" "SM0_DM"
    "20" "SM1_IM"
    "21" "SM1_DM"
    "30" "HAB"
    -default unsigned
}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench_bus/clk
add wave -noupdate /testbench_bus/rst

add wave -noupdate -expand -group masters -expand -group sm0_im -radix TARGET /testbench_bus/sm0_im/data_ptc
add wave -noupdate -expand -group masters -expand -group sm0_im -radix TARGET /testbench_bus/sm0_im/address
add wave -noupdate -expand -group masters -expand -group sm0_im /testbench_bus/sm0_im/read
add wave -noupdate -expand -group masters -expand -group sm0_im /testbench_bus/sm0_im/write
add wave -noupdate -expand -group masters -expand -group sm0_im /testbench_bus/sm0_im/hit
add wave -noupdate -expand -group masters -expand -group sm0_im /testbench_bus/sm0_im/complete
add wave -noupdate -expand -group masters -expand -group sm0_im /testbench_bus/sm0_im/error

add wave -noupdate -expand -group masters -expand -group sm0_dm -radix TARGET /testbench_bus/sm0_dm/data_ptc
add wave -noupdate -expand -group masters -expand -group sm0_dm -radix TARGET /testbench_bus/sm0_dm/address
add wave -noupdate -expand -group masters -expand -group sm0_dm /testbench_bus/sm0_dm/read
add wave -noupdate -expand -group masters -expand -group sm0_dm /testbench_bus/sm0_dm/write
add wave -noupdate -expand -group masters -expand -group sm0_dm /testbench_bus/sm0_dm/hit
add wave -noupdate -expand -group masters -expand -group sm0_dm /testbench_bus/sm0_dm/complete
add wave -noupdate -expand -group masters -expand -group sm0_dm /testbench_bus/sm0_dm/error

add wave -noupdate -expand -group masters -expand -group sm1_im -radix TARGET /testbench_bus/sm1_im/data_ptc
add wave -noupdate -expand -group masters -expand -group sm1_im -radix TARGET /testbench_bus/sm1_im/address
add wave -noupdate -expand -group masters -expand -group sm1_im /testbench_bus/sm1_im/read
add wave -noupdate -expand -group masters -expand -group sm1_im /testbench_bus/sm1_im/write
add wave -noupdate -expand -group masters -expand -group sm1_im /testbench_bus/sm1_im/hit
add wave -noupdate -expand -group masters -expand -group sm1_im /testbench_bus/sm1_im/complete
add wave -noupdate -expand -group masters -expand -group sm1_im /testbench_bus/sm1_im/error

add wave -noupdate -expand -group masters -expand -group sm1_dm -radix TARGET /testbench_bus/sm1_dm/data_ptc
add wave -noupdate -expand -group masters -expand -group sm1_dm -radix TARGET /testbench_bus/sm1_dm/address
add wave -noupdate -expand -group masters -expand -group sm1_dm /testbench_bus/sm1_dm/read
add wave -noupdate -expand -group masters -expand -group sm1_dm /testbench_bus/sm1_dm/write
add wave -noupdate -expand -group masters -expand -group sm1_dm /testbench_bus/sm1_dm/hit
add wave -noupdate -expand -group masters -expand -group sm1_dm /testbench_bus/sm1_dm/complete
add wave -noupdate -expand -group masters -expand -group sm1_dm /testbench_bus/sm1_dm/error

add wave -noupdate -expand -group masters -expand -group hab -radix TARGET /testbench_bus/hab/data_ptc
add wave -noupdate -expand -group masters -expand -group hab -radix TARGET /testbench_bus/hab/address
add wave -noupdate -expand -group masters -expand -group hab /testbench_bus/hab/read
add wave -noupdate -expand -group masters -expand -group hab /testbench_bus/hab/write
add wave -noupdate -expand -group masters -expand -group hab /testbench_bus/hab/hit
add wave -noupdate -expand -group masters -expand -group hab /testbench_bus/hab/complete
add wave -noupdate -expand -group masters -expand -group hab /testbench_bus/hab/error

add wave -noupdate -expand -group slaves -expand -group im0_a -radix SOURCE /testbench_bus/im0_a/data_ctp
add wave -noupdate -expand -group slaves -expand -group im0_a -radix TARGET /testbench_bus/im0_a/data_ptc
add wave -noupdate -expand -group slaves -expand -group im0_a -radix TARGET /testbench_bus/im0_a/address
add wave -noupdate -expand -group slaves -expand -group im0_a /testbench_bus/im0_a/read
add wave -noupdate -expand -group slaves -expand -group im0_a /testbench_bus/im0_a/write
add wave -noupdate -expand -group slaves -expand -group im0_a /testbench_bus/im0_a/hit
add wave -noupdate -expand -group slaves -expand -group im0_a /testbench_bus/im0_a/complete
add wave -noupdate -expand -group slaves -expand -group im0_a /testbench_bus/im0_a/error

add wave -noupdate -expand -group slaves -expand -group im0_b -radix SOURCE /testbench_bus/im0_b/data_ctp
add wave -noupdate -expand -group slaves -expand -group im0_b -radix TARGET /testbench_bus/im0_b/data_ptc
add wave -noupdate -expand -group slaves -expand -group im0_b -radix TARGET /testbench_bus/im0_b/address
add wave -noupdate -expand -group slaves -expand -group im0_b /testbench_bus/im0_b/read
add wave -noupdate -expand -group slaves -expand -group im0_b /testbench_bus/im0_b/write
add wave -noupdate -expand -group slaves -expand -group im0_b /testbench_bus/im0_b/hit
add wave -noupdate -expand -group slaves -expand -group im0_b /testbench_bus/im0_b/complete
add wave -noupdate -expand -group slaves -expand -group im0_b /testbench_bus/im0_b/error

add wave -noupdate -expand -group slaves -expand -group dm0_a -radix SOURCE /testbench_bus/dm0_a/data_ctp
add wave -noupdate -expand -group slaves -expand -group dm0_a -radix TARGET /testbench_bus/dm0_a/data_ptc
add wave -noupdate -expand -group slaves -expand -group dm0_a -radix TARGET /testbench_bus/dm0_a/address
add wave -noupdate -expand -group slaves -expand -group dm0_a /testbench_bus/dm0_a/read
add wave -noupdate -expand -group slaves -expand -group dm0_a /testbench_bus/dm0_a/write
add wave -noupdate -expand -group slaves -expand -group dm0_a /testbench_bus/dm0_a/hit
add wave -noupdate -expand -group slaves -expand -group dm0_a /testbench_bus/dm0_a/complete
add wave -noupdate -expand -group slaves -expand -group dm0_a /testbench_bus/dm0_a/error

add wave -noupdate -expand -group slaves -expand -group dm0_b -radix SOURCE /testbench_bus/dm0_b/data_ctp
add wave -noupdate -expand -group slaves -expand -group dm0_b -radix TARGET /testbench_bus/dm0_b/data_ptc
add wave -noupdate -expand -group slaves -expand -group dm0_b -radix TARGET /testbench_bus/dm0_b/address
add wave -noupdate -expand -group slaves -expand -group dm0_b /testbench_bus/dm0_b/read
add wave -noupdate -expand -group slaves -expand -group dm0_b /testbench_bus/dm0_b/write
add wave -noupdate -expand -group slaves -expand -group dm0_b /testbench_bus/dm0_b/hit
add wave -noupdate -expand -group slaves -expand -group dm0_b /testbench_bus/dm0_b/complete
add wave -noupdate -expand -group slaves -expand -group dm0_b /testbench_bus/dm0_b/error

add wave -noupdate -expand -group slaves -expand -group cm0_a -radix SOURCE /testbench_bus/cm0_a/data_ctp
add wave -noupdate -expand -group slaves -expand -group cm0_a -radix TARGET /testbench_bus/cm0_a/data_ptc
add wave -noupdate -expand -group slaves -expand -group cm0_a -radix TARGET /testbench_bus/cm0_a/address
add wave -noupdate -expand -group slaves -expand -group cm0_a /testbench_bus/cm0_a/read
add wave -noupdate -expand -group slaves -expand -group cm0_a /testbench_bus/cm0_a/write
add wave -noupdate -expand -group slaves -expand -group cm0_a /testbench_bus/cm0_a/hit
add wave -noupdate -expand -group slaves -expand -group cm0_a /testbench_bus/cm0_a/complete
add wave -noupdate -expand -group slaves -expand -group cm0_a /testbench_bus/cm0_a/error

add wave -noupdate -expand -group slaves -expand -group cm0_b -radix SOURCE /testbench_bus/cm0_b/data_ctp
add wave -noupdate -expand -group slaves -expand -group cm0_b -radix TARGET /testbench_bus/cm0_b/data_ptc
add wave -noupdate -expand -group slaves -expand -group cm0_b -radix TARGET /testbench_bus/cm0_b/address
add wave -noupdate -expand -group slaves -expand -group cm0_b /testbench_bus/cm0_b/read
add wave -noupdate -expand -group slaves -expand -group cm0_b /testbench_bus/cm0_b/write
add wave -noupdate -expand -group slaves -expand -group cm0_b /testbench_bus/cm0_b/hit
add wave -noupdate -expand -group slaves -expand -group cm0_b /testbench_bus/cm0_b/complete
add wave -noupdate -expand -group slaves -expand -group cm0_b /testbench_bus/cm0_b/error

add wave -noupdate -expand -group slaves -expand -group im1_a -radix SOURCE /testbench_bus/im1_a/data_ctp
add wave -noupdate -expand -group slaves -expand -group im1_a -radix TARGET /testbench_bus/im1_a/data_ptc
add wave -noupdate -expand -group slaves -expand -group im1_a -radix TARGET /testbench_bus/im1_a/address
add wave -noupdate -expand -group slaves -expand -group im1_a /testbench_bus/im1_a/read
add wave -noupdate -expand -group slaves -expand -group im1_a /testbench_bus/im1_a/write
add wave -noupdate -expand -group slaves -expand -group im1_a /testbench_bus/im1_a/hit
add wave -noupdate -expand -group slaves -expand -group im1_a /testbench_bus/im1_a/complete
add wave -noupdate -expand -group slaves -expand -group im1_a /testbench_bus/im1_a/error

add wave -noupdate -expand -group slaves -expand -group im1_b -radix SOURCE /testbench_bus/im1_b/data_ctp
add wave -noupdate -expand -group slaves -expand -group im1_b -radix TARGET /testbench_bus/im1_b/data_ptc
add wave -noupdate -expand -group slaves -expand -group im1_b -radix TARGET /testbench_bus/im1_b/address
add wave -noupdate -expand -group slaves -expand -group im1_b /testbench_bus/im1_b/read
add wave -noupdate -expand -group slaves -expand -group im1_b /testbench_bus/im1_b/write
add wave -noupdate -expand -group slaves -expand -group im1_b /testbench_bus/im1_b/hit
add wave -noupdate -expand -group slaves -expand -group im1_b /testbench_bus/im1_b/complete
add wave -noupdate -expand -group slaves -expand -group im1_b /testbench_bus/im1_b/error

add wave -noupdate -expand -group slaves -expand -group dm1_a -radix SOURCE /testbench_bus/dm1_a/data_ctp
add wave -noupdate -expand -group slaves -expand -group dm1_a -radix TARGET /testbench_bus/dm1_a/data_ptc
add wave -noupdate -expand -group slaves -expand -group dm1_a -radix TARGET /testbench_bus/dm1_a/address
add wave -noupdate -expand -group slaves -expand -group dm1_a /testbench_bus/dm1_a/read
add wave -noupdate -expand -group slaves -expand -group dm1_a /testbench_bus/dm1_a/write
add wave -noupdate -expand -group slaves -expand -group dm1_a /testbench_bus/dm1_a/hit
add wave -noupdate -expand -group slaves -expand -group dm1_a /testbench_bus/dm1_a/complete
add wave -noupdate -expand -group slaves -expand -group dm1_a /testbench_bus/dm1_a/error

add wave -noupdate -expand -group slaves -expand -group dm1_b -radix SOURCE /testbench_bus/dm1_b/data_ctp
add wave -noupdate -expand -group slaves -expand -group dm1_b -radix TARGET /testbench_bus/dm1_b/data_ptc
add wave -noupdate -expand -group slaves -expand -group dm1_b -radix TARGET /testbench_bus/dm1_b/address
add wave -noupdate -expand -group slaves -expand -group dm1_b /testbench_bus/dm1_b/read
add wave -noupdate -expand -group slaves -expand -group dm1_b /testbench_bus/dm1_b/write
add wave -noupdate -expand -group slaves -expand -group dm1_b /testbench_bus/dm1_b/hit
add wave -noupdate -expand -group slaves -expand -group dm1_b /testbench_bus/dm1_b/complete
add wave -noupdate -expand -group slaves -expand -group dm1_b /testbench_bus/dm1_b/error

add wave -noupdate -expand -group slaves -expand -group cm1_a -radix SOURCE /testbench_bus/cm1_a/data_ctp
add wave -noupdate -expand -group slaves -expand -group cm1_a -radix TARGET /testbench_bus/cm1_a/data_ptc
add wave -noupdate -expand -group slaves -expand -group cm1_a -radix TARGET /testbench_bus/cm1_a/address
add wave -noupdate -expand -group slaves -expand -group cm1_a /testbench_bus/cm1_a/read
add wave -noupdate -expand -group slaves -expand -group cm1_a /testbench_bus/cm1_a/write
add wave -noupdate -expand -group slaves -expand -group cm1_a /testbench_bus/cm1_a/hit
add wave -noupdate -expand -group slaves -expand -group cm1_a /testbench_bus/cm1_a/complete
add wave -noupdate -expand -group slaves -expand -group cm1_a /testbench_bus/cm1_a/error

add wave -noupdate -expand -group slaves -expand -group cm1_b -radix SOURCE /testbench_bus/cm1_b/data_ctp
add wave -noupdate -expand -group slaves -expand -group cm1_b -radix TARGET /testbench_bus/cm1_b/data_ptc
add wave -noupdate -expand -group slaves -expand -group cm1_b -radix TARGET /testbench_bus/cm1_b/address
add wave -noupdate -expand -group slaves -expand -group cm1_b /testbench_bus/cm1_b/read
add wave -noupdate -expand -group slaves -expand -group cm1_b /testbench_bus/cm1_b/write
add wave -noupdate -expand -group slaves -expand -group cm1_b /testbench_bus/cm1_b/hit
add wave -noupdate -expand -group slaves -expand -group cm1_b /testbench_bus/cm1_b/complete
add wave -noupdate -expand -group slaves -expand -group cm1_b /testbench_bus/cm1_b/error

add wave -noupdate -expand -group slaves -expand -group smc_a -radix SOURCE /testbench_bus/smc_a/data_ctp
add wave -noupdate -expand -group slaves -expand -group smc_a -radix TARGET /testbench_bus/smc_a/data_ptc
add wave -noupdate -expand -group slaves -expand -group smc_a -radix TARGET /testbench_bus/smc_a/address
add wave -noupdate -expand -group slaves -expand -group smc_a /testbench_bus/smc_a/read
add wave -noupdate -expand -group slaves -expand -group smc_a /testbench_bus/smc_a/write
add wave -noupdate -expand -group slaves -expand -group smc_a /testbench_bus/smc_a/hit
add wave -noupdate -expand -group slaves -expand -group smc_a /testbench_bus/smc_a/complete
add wave -noupdate -expand -group slaves -expand -group smc_a /testbench_bus/smc_a/error

add wave -noupdate -expand -group filters -expand -group mf_sm0_im -label im0 /testbench_bus/bus_matrix_inst/bus_filter_sm0_im/filter_hit
add wave -noupdate -expand -group filters -expand -group mf_sm0_im -label im1 /testbench_bus/bus_matrix_inst/bus_filter_sm0_im_pass1/filter_hit

add wave -noupdate -expand -group filters -expand -group mf_sm0_dm -label im0 /testbench_bus/bus_matrix_inst/bus_filter_sm0_dm/filter_hit
add wave -noupdate -expand -group filters -expand -group mf_sm0_dm -label dm0 /testbench_bus/bus_matrix_inst/bus_filter_sm0_dm_pass1/filter_hit
add wave -noupdate -expand -group filters -expand -group mf_sm0_dm -label cm0 /testbench_bus/bus_matrix_inst/bus_filter_sm0_dm_pass2/filter_hit
add wave -noupdate -expand -group filters -expand -group mf_sm0_dm -label im1 /testbench_bus/bus_matrix_inst/bus_filter_sm0_dm_pass3/filter_hit
add wave -noupdate -expand -group filters -expand -group mf_sm0_dm -label dm1 /testbench_bus/bus_matrix_inst/bus_filter_sm0_dm_pass4/filter_hit
add wave -noupdate -expand -group filters -expand -group mf_sm0_dm -label cm1 /testbench_bus/bus_matrix_inst/bus_filter_sm0_dm_pass5/filter_hit
add wave -noupdate -expand -group filters -expand -group mf_sm0_dm -label smc /testbench_bus/bus_matrix_inst/bus_filter_sm0_dm_pass6/filter_hit

add wave -noupdate -expand -group filters -expand -group mf_sm1_im -label im0 /testbench_bus/bus_matrix_inst/bus_filter_sm1_im/filter_hit
add wave -noupdate -expand -group filters -expand -group mf_sm1_im -label im1 /testbench_bus/bus_matrix_inst/bus_filter_sm1_im_pass1/filter_hit

add wave -noupdate -expand -group filters -expand -group mf_sm1_dm -label im0 /testbench_bus/bus_matrix_inst/bus_filter_sm1_dm/filter_hit
add wave -noupdate -expand -group filters -expand -group mf_sm1_dm -label dm0 /testbench_bus/bus_matrix_inst/bus_filter_sm1_dm_pass1/filter_hit
add wave -noupdate -expand -group filters -expand -group mf_sm1_dm -label cm0 /testbench_bus/bus_matrix_inst/bus_filter_sm1_dm_pass2/filter_hit
add wave -noupdate -expand -group filters -expand -group mf_sm1_dm -label im1 /testbench_bus/bus_matrix_inst/bus_filter_sm1_dm_pass3/filter_hit
add wave -noupdate -expand -group filters -expand -group mf_sm1_dm -label dm1 /testbench_bus/bus_matrix_inst/bus_filter_sm1_dm_pass4/filter_hit
add wave -noupdate -expand -group filters -expand -group mf_sm1_dm -label cm1 /testbench_bus/bus_matrix_inst/bus_filter_sm1_dm_pass5/filter_hit
add wave -noupdate -expand -group filters -expand -group mf_sm1_dm -label smc /testbench_bus/bus_matrix_inst/bus_filter_sm1_dm_pass6/filter_hit

add wave -noupdate -expand -group filters -expand -group mf_hab -label im0 /testbench_bus/bus_matrix_inst/bus_filter_hab/filter_hit
add wave -noupdate -expand -group filters -expand -group mf_hab -label dm0 /testbench_bus/bus_matrix_inst/bus_filter_hab_pass1/filter_hit
add wave -noupdate -expand -group filters -expand -group mf_hab -label cm0 /testbench_bus/bus_matrix_inst/bus_filter_hab_pass2/filter_hit
add wave -noupdate -expand -group filters -expand -group mf_hab -label im1 /testbench_bus/bus_matrix_inst/bus_filter_hab_pass3/filter_hit
add wave -noupdate -expand -group filters -expand -group mf_hab -label dm1 /testbench_bus/bus_matrix_inst/bus_filter_hab_pass4/filter_hit
add wave -noupdate -expand -group filters -expand -group mf_hab -label cm1 /testbench_bus/bus_matrix_inst/bus_filter_hab_pass5/filter_hit
add wave -noupdate -expand -group filters -expand -group mf_hab -label smc /testbench_bus/bus_matrix_inst/bus_filter_hab_pass6/filter_hit

add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_sm0_dm_im0 /testbench_bus/bus_matrix_inst/bus_arbiter_sm0_dm_im0/grant_a
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_sm0_dm_im0 /testbench_bus/bus_matrix_inst/bus_arbiter_sm0_dm_im0/grant_b
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_sm0_dm_im0 /testbench_bus/bus_matrix_inst/bus_arbiter_sm0_dm_im0/request_a
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_sm0_dm_im0 /testbench_bus/bus_matrix_inst/bus_arbiter_sm0_dm_im0/request_b
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_sm0_dm_im0 /testbench_bus/bus_matrix_inst/bus_arbiter_sm0_dm_im0/complete
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_sm0_dm_im0 /testbench_bus/bus_matrix_inst/bus_arbiter_sm0_dm_im0/arbiter/priority_a
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_sm0_dm_im0 /testbench_bus/bus_matrix_inst/bus_arbiter_sm0_dm_im0/arbiter/contention

add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_sm1_dm_im0 /testbench_bus/bus_matrix_inst/bus_arbiter_sm1_dm_im0/grant_a
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_sm1_dm_im0 /testbench_bus/bus_matrix_inst/bus_arbiter_sm1_dm_im0/grant_b
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_sm1_dm_im0 /testbench_bus/bus_matrix_inst/bus_arbiter_sm1_dm_im0/request_a
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_sm1_dm_im0 /testbench_bus/bus_matrix_inst/bus_arbiter_sm1_dm_im0/request_b
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_sm1_dm_im0 /testbench_bus/bus_matrix_inst/bus_arbiter_sm1_dm_im0/complete
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_sm1_dm_im0 /testbench_bus/bus_matrix_inst/bus_arbiter_sm1_dm_im0/arbiter/priority_a
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_sm1_dm_im0 /testbench_bus/bus_matrix_inst/bus_arbiter_sm1_dm_im0/arbiter/contention

add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_hab_im0 /testbench_bus/bus_matrix_inst/bus_arbiter_hab_im0/grant_a
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_hab_im0 /testbench_bus/bus_matrix_inst/bus_arbiter_hab_im0/grant_b
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_hab_im0 /testbench_bus/bus_matrix_inst/bus_arbiter_hab_im0/request_a
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_hab_im0 /testbench_bus/bus_matrix_inst/bus_arbiter_hab_im0/request_b
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_hab_im0 /testbench_bus/bus_matrix_inst/bus_arbiter_hab_im0/complete
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_hab_im0 /testbench_bus/bus_matrix_inst/bus_arbiter_hab_im0/arbiter/priority_a
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_hab_im0 /testbench_bus/bus_matrix_inst/bus_arbiter_hab_im0/arbiter/contention

add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_hab_dm0 /testbench_bus/bus_matrix_inst/bus_arbiter_hab_dm0/grant_a
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_hab_dm0 /testbench_bus/bus_matrix_inst/bus_arbiter_hab_dm0/grant_b
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_hab_dm0 /testbench_bus/bus_matrix_inst/bus_arbiter_hab_dm0/request_a
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_hab_dm0 /testbench_bus/bus_matrix_inst/bus_arbiter_hab_dm0/request_b
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_hab_dm0 /testbench_bus/bus_matrix_inst/bus_arbiter_hab_dm0/complete
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_hab_dm0 /testbench_bus/bus_matrix_inst/bus_arbiter_hab_dm0/arbiter/priority_a
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_hab_dm0 /testbench_bus/bus_matrix_inst/bus_arbiter_hab_dm0/arbiter/contention

add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_hab_cm0 /testbench_bus/bus_matrix_inst/bus_arbiter_hab_cm0/grant_a
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_hab_cm0 /testbench_bus/bus_matrix_inst/bus_arbiter_hab_cm0/grant_b
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_hab_cm0 /testbench_bus/bus_matrix_inst/bus_arbiter_hab_cm0/request_a
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_hab_cm0 /testbench_bus/bus_matrix_inst/bus_arbiter_hab_cm0/request_b
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_hab_cm0 /testbench_bus/bus_matrix_inst/bus_arbiter_hab_cm0/complete
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_hab_cm0 /testbench_bus/bus_matrix_inst/bus_arbiter_hab_cm0/arbiter/priority_a
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_hab_cm0 /testbench_bus/bus_matrix_inst/bus_arbiter_hab_cm0/arbiter/contention

add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_sm1_dm_im1 /testbench_bus/bus_matrix_inst/bus_arbiter_sm1_dm_im1/grant_a
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_sm1_dm_im1 /testbench_bus/bus_matrix_inst/bus_arbiter_sm1_dm_im1/grant_b
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_sm1_dm_im1 /testbench_bus/bus_matrix_inst/bus_arbiter_sm1_dm_im1/request_a
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_sm1_dm_im1 /testbench_bus/bus_matrix_inst/bus_arbiter_sm1_dm_im1/request_b
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_sm1_dm_im1 /testbench_bus/bus_matrix_inst/bus_arbiter_sm1_dm_im1/complete
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_sm1_dm_im1 /testbench_bus/bus_matrix_inst/bus_arbiter_sm1_dm_im1/arbiter/priority_a
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_sm1_dm_im1 /testbench_bus/bus_matrix_inst/bus_arbiter_sm1_dm_im1/arbiter/contention

add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_sm0_dm_im1 /testbench_bus/bus_matrix_inst/bus_arbiter_sm0_dm_im1/grant_a
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_sm0_dm_im1 /testbench_bus/bus_matrix_inst/bus_arbiter_sm0_dm_im1/grant_b
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_sm0_dm_im1 /testbench_bus/bus_matrix_inst/bus_arbiter_sm0_dm_im1/request_a
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_sm0_dm_im1 /testbench_bus/bus_matrix_inst/bus_arbiter_sm0_dm_im1/request_b
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_sm0_dm_im1 /testbench_bus/bus_matrix_inst/bus_arbiter_sm0_dm_im1/complete
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_sm0_dm_im1 /testbench_bus/bus_matrix_inst/bus_arbiter_sm0_dm_im1/arbiter/priority_a
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_sm0_dm_im1 /testbench_bus/bus_matrix_inst/bus_arbiter_sm0_dm_im1/arbiter/contention

add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_hab_im1 /testbench_bus/bus_matrix_inst/bus_arbiter_hab_im1/grant_a
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_hab_im1 /testbench_bus/bus_matrix_inst/bus_arbiter_hab_im1/grant_b
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_hab_im1 /testbench_bus/bus_matrix_inst/bus_arbiter_hab_im1/request_a
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_hab_im1 /testbench_bus/bus_matrix_inst/bus_arbiter_hab_im1/request_b
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_hab_im1 /testbench_bus/bus_matrix_inst/bus_arbiter_hab_im1/complete
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_hab_im1 /testbench_bus/bus_matrix_inst/bus_arbiter_hab_im1/arbiter/priority_a
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_hab_im1 /testbench_bus/bus_matrix_inst/bus_arbiter_hab_im1/arbiter/contention

add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_hab_dm1 /testbench_bus/bus_matrix_inst/bus_arbiter_hab_dm1/grant_a
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_hab_dm1 /testbench_bus/bus_matrix_inst/bus_arbiter_hab_dm1/grant_b
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_hab_dm1 /testbench_bus/bus_matrix_inst/bus_arbiter_hab_dm1/request_a
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_hab_dm1 /testbench_bus/bus_matrix_inst/bus_arbiter_hab_dm1/request_b
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_hab_dm1 /testbench_bus/bus_matrix_inst/bus_arbiter_hab_dm1/complete
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_hab_dm1 /testbench_bus/bus_matrix_inst/bus_arbiter_hab_dm1/arbiter/priority_a
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_hab_dm1 /testbench_bus/bus_matrix_inst/bus_arbiter_hab_dm1/arbiter/contention

add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_hab_cm1 /testbench_bus/bus_matrix_inst/bus_arbiter_hab_cm1/grant_a
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_hab_cm1 /testbench_bus/bus_matrix_inst/bus_arbiter_hab_cm1/grant_b
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_hab_cm1 /testbench_bus/bus_matrix_inst/bus_arbiter_hab_cm1/request_a
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_hab_cm1 /testbench_bus/bus_matrix_inst/bus_arbiter_hab_cm1/request_b
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_hab_cm1 /testbench_bus/bus_matrix_inst/bus_arbiter_hab_cm1/complete
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_hab_cm1 /testbench_bus/bus_matrix_inst/bus_arbiter_hab_cm1/arbiter/priority_a
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_hab_cm1 /testbench_bus/bus_matrix_inst/bus_arbiter_hab_cm1/arbiter/contention

add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_sm1_dm_smc /testbench_bus/bus_matrix_inst/bus_arbiter_sm1_dm_smc/grant_a
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_sm1_dm_smc /testbench_bus/bus_matrix_inst/bus_arbiter_sm1_dm_smc/grant_b
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_sm1_dm_smc /testbench_bus/bus_matrix_inst/bus_arbiter_sm1_dm_smc/request_a
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_sm1_dm_smc /testbench_bus/bus_matrix_inst/bus_arbiter_sm1_dm_smc/request_b
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_sm1_dm_smc /testbench_bus/bus_matrix_inst/bus_arbiter_sm1_dm_smc/complete
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_sm1_dm_smc /testbench_bus/bus_matrix_inst/bus_arbiter_sm1_dm_smc/arbiter/priority_a
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_sm1_dm_smc /testbench_bus/bus_matrix_inst/bus_arbiter_sm1_dm_smc/arbiter/contention

add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_hab_smc /testbench_bus/bus_matrix_inst/bus_arbiter_hab_smc/grant_a
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_hab_smc /testbench_bus/bus_matrix_inst/bus_arbiter_hab_smc/grant_b
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_hab_smc /testbench_bus/bus_matrix_inst/bus_arbiter_hab_smc/request_a
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_hab_smc /testbench_bus/bus_matrix_inst/bus_arbiter_hab_smc/request_b
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_hab_smc /testbench_bus/bus_matrix_inst/bus_arbiter_hab_smc/complete
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_hab_smc /testbench_bus/bus_matrix_inst/bus_arbiter_hab_smc/arbiter/priority_a
add wave -noupdate -expand -group arbiters -expand -group bus_arbiter_hab_smc /testbench_bus/bus_matrix_inst/bus_arbiter_hab_smc/arbiter/contention

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 141
configure wave -valuecolwidth 70
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod {100 ps}
configure wave -griddelta 20
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {3904 ps}
