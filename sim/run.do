# ============================================================
# run.do - Questasim Do File for UART UVM Testbench
# Usage: do run.do
# ============================================================

# ---------- Variables ----------
quietly set RTL     "../rtl/*"
quietly set WORK    "work"
quietly set SVTB1   "../tb/top.sv"
quietly set SVTB2   "../test/test_pkg.sv"
quietly set INC     "+incdir+../tb +incdir+../test +incdir+../agt_top"
quietly set VSIMOPT "-vopt -voptargs=+acc"
quietly set VSIMCOV "-coverage -sva"

# ---------- Compile ----------
proc sv_cmp {} {
    global RTL WORK SVTB1 SVTB2 INC
    vlib $WORK
    vmap work $WORK
    vlog -work $WORK {*}$RTL {*}$INC $SVTB2 $SVTB1
}

# ---------- Run Tests ----------
proc run_test {} {
    global VSIMOPT VSIMCOV
    sv_cmp
    vsim -cvgperinstance {*}$VSIMOPT {*}$VSIMCOV \
        -c -do "log -r /* ; coverage save -onexit uart_cov1 ; run -all ; exit" \
        -wlf wave_file1.wlf -l test1.log -sv_seed random \
        work.top +UVM_TESTNAME=base_test
    vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html uart_cov1
}

proc run_test1 {} {
    global VSIMOPT VSIMCOV
    vsim -cvgperinstance {*}$VSIMOPT {*}$VSIMCOV \
        -c -do "log -r /* ; coverage save -onexit uart_cov2 ; run -all ; exit" \
        -wlf wave_file2.wlf -l test2.log -sv_seed random \
        work.top +UVM_TESTNAME=fd_test
    vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html uart_cov2
}

proc run_test2 {} {
    global VSIMOPT VSIMCOV
    vsim -cvgperinstance {*}$VSIMOPT {*}$VSIMCOV \
        -c -do "log -r /* ; coverage save -onexit uart_cov3 ; run -all ; exit" \
        -wlf wave_file3.wlf -l test3.log -sv_seed random \
        work.top +UVM_TESTNAME=hd_test
    vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html uart_cov3
}

proc run_test3 {} {
    global VSIMOPT VSIMCOV
    vsim -cvgperinstance {*}$VSIMOPT {*}$VSIMCOV \
        -c -do "log -r /* ; coverage save -onexit uart_cov4 ; run -all ; exit" \
        -wlf wave_file4.wlf -l test4.log -sv_seed random \
        work.top +UVM_TESTNAME=lb_test
    vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html uart_cov4
}

proc run_test4 {} {
    global VSIMOPT VSIMCOV
    vsim -cvgperinstance {*}$VSIMOPT {*}$VSIMCOV \
        -c -do "log -r /* ; coverage save -onexit uart_cov5 ; run -all ; exit" \
        -wlf wave_file5.wlf -l test5.log -sv_seed random \
        work.top +UVM_TESTNAME=parity_test
    vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html uart_cov5
}

proc run_test5 {} {
    global VSIMOPT VSIMCOV
    vsim -cvgperinstance {*}$VSIMOPT {*}$VSIMCOV \
        -c -do "log -r /* ; coverage save -onexit uart_cov6 ; run -all ; exit" \
        -wlf wave_file6.wlf -l test6.log -sv_seed random \
        work.top +UVM_TESTNAME=framing_test
    vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html uart_cov6
}

proc run_test6 {} {
    global VSIMOPT VSIMCOV
    vsim -cvgperinstance {*}$VSIMOPT {*}$VSIMCOV \
        -c -do "log -r /* ; coverage save -onexit uart_cov7 ; run -all ; exit" \
        -wlf wave_file7.wlf -l test7.log -sv_seed random \
        work.top +UVM_TESTNAME=thr_empty_test
    vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html uart_cov7
}

proc run_test7 {} {
    global VSIMOPT VSIMCOV
    vsim -cvgperinstance {*}$VSIMOPT {*}$VSIMCOV \
        -c -do "log -r /* ; coverage save -onexit uart_cov8 ; run -all ; exit" \
        -wlf wave_file8.wlf -l test8.log -sv_seed random \
        work.top +UVM_TESTNAME=orr_test
    vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html uart_cov8
}

proc run_test8 {} {
    global VSIMOPT VSIMCOV
    vsim -cvgperinstance {*}$VSIMOPT {*}$VSIMCOV \
        -c -do "log -r /* ; coverage save -onexit uart_cov9 ; run -all ; exit" \
        -wlf wave_file9.wlf -l test9.log -sv_seed random \
        work.top +UVM_TESTNAME=timeout_test
    vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html uart_cov9
}

# ---------- Regression ----------
proc regress {} {
    run_test
    run_test1
    run_test2
    run_test3
    run_test4
    run_test5
    run_test6
    run_test7
    run_test8
    vcover merge uart_cov uart_cov1 uart_cov2 uart_cov3 uart_cov4 uart_cov5 uart_cov6 uart_cov7 uart_cov8
    vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html uart_cov
}

# ---------- View Waveforms ----------
proc view_wave1 {} { vsim -view wave_file1.wlf }
proc view_wave2 {} { vsim -view wave_file2.wlf }
proc view_wave3 {} { vsim -view wave_file3.wlf }
proc view_wave4 {} { vsim -view wave_file4.wlf }
proc view_wave5 {} { vsim -view wave_file5.wlf }
proc view_wave6 {} { vsim -view wave_file6.wlf }
proc view_wave7 {} { vsim -view wave_file7.wlf }
proc view_wave8 {} { vsim -view wave_file8.wlf }

# ---------- Clean ----------
proc clean {} {
    file delete -force transcript
    foreach f [glob -nocomplain *.log] { file delete -force $f }
    foreach f [glob -nocomplain *.wlf] { file delete -force $f }
    foreach f [glob -nocomplain uart_cov*] { file delete -force $f }
    foreach f [glob -nocomplain covhtmlreport*] { file delete -force $f }
    file delete -force work
    file delete -force modelsim.ini
    echo "Clean done."
}

# ---------- Help ----------
proc help {} {
    echo "======================================================"
    echo " Available commands - type in Questasim console:"
    echo "======================================================"
    echo "  sv_cmp      => compile RTL + TB"
    echo "  run_test    => compile + run base_test"
    echo "  run_test1   => run fd_test"
    echo "  run_test2   => run hd_test"
    echo "  run_test3   => run lb_test"
    echo "  run_test4   => run parity_test"
    echo "  run_test5   => run framing_test"
    echo "  run_test6   => run thr_empty_test"
    echo "  run_test7   => run orr_test"
    echo "  run_test8   => run timeout_test"
    echo "  regress     => run all tests + merge coverage"
    echo "  view_wave1  => open waveform for test1"
    echo "  clean       => delete all generated files"
    echo "======================================================"
}

# ---------- Entry Point ----------
echo "Do file loaded. Type 'help' to see available commands."
echo "To compile and run base_test: run_test"
echo "To run full regression:       regress"