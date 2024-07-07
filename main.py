import os
import subprocess

# Define input and output paths
CP_dir = './CP/'
SMT_dir = './SMT/'
MIP_dir = './MIP/'
output_SMT = './res/SMT/'
output_MIP = './res/MIP/'

def run_cp(input_dir):
    print("Running CP script...")
    cp_script = os.path.join(input_dir, "run_mcp.py")
    subprocess.run(["python", cp_script], check=True)

def run_mip(input_dir, output):
    print("Running MIP script...")
    mip_script = os.path.join(input_dir, "MIP.ipynb")
    mip_output = os.path.join(output, "MIP_out.ipynb")
    subprocess.run(["jupyter", "nbconvert", "--to", "notebook", "--execute", mip_script, "--output", mip_output], check=True)

def run_smt(input_dir, output):
    print("Running SMT script...")
    smt_script = os.path.join(input_dir, "Optimize_SB.ipynb")
    smt_output = os.path.join(output, "SMT_out.ipynb")
    subprocess.run(["jupyter", "nbconvert", "--to", "notebook", "--execute", smt_script, "--output", smt_output], check=True)

if __name__ == "__main__":
    run_cp(CP_dir)
    run_smt(SMT_dir, output_SMT)
    run_mip(MIP_dir, output_MIP)

