import os
import sys
from cocotb.runner import get_runner

def get_sources():
    sources = []
    for root, _, files in os.walk("..\\src"):
        for file in files:
            if file.endswith(".sv"):
                sources.append(os.path.join(root, file))
    return sources

def run(gui, convert, wave):
    sim       = "questa"
    top       = "top"
    testbench = "testbench"

    os.environ["COCOTB_RESOLVE_X"] = "ZEROS"

    runner = get_runner(sim)
    runner.build(sources=get_sources(), parameters={"PLL": 0}, hdl_toplevel=top, waves=True, log_file="sim_build\\build.log")
    runner.test(test_module=testbench, hdl_toplevel=top, test_args= ["-L", "altera_mf"], waves=True, gui=gui, log_file="sim_build\\test.log")

    if convert or wave:
        os.system("wlf2vcd -o sim_build\\vsim.vcd sim_build\\vsim.wlf ")

    if wave:
        os.system("gtkwave sim_build\\vsim.vcd")

if __name__ == "__main__":
    if "clean" in sys.argv:
        os.system("rmdir /s /q sim_build")
    else:
        run("gui" in sys.argv, "convert" in sys.argv, "wave" in sys.argv)
