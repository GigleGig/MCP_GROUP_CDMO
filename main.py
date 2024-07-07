import os
import subprocess
from nbconvert.preprocessors import ExecutePreprocessor
import nbformat

# Define input paths
CP_dir = './CP/'
SMT_dir = './SMT/'
MIP_dir = './MIP/'

def run_cp(input_dir):
    print("Running CP script...")
    cp_script = os.path.join(input_dir, "run_mcp.py")
    subprocess.run(["python", cp_script], check=True)

def run_notebook(notebook_path):
    print(f"Running notebook: {notebook_path}")
    with open(notebook_path) as f:
        nb = nbformat.read(f, as_version=4)
    ep = ExecutePreprocessor(timeout=600, kernel_name='python3')
    ep.preprocess(nb, {'metadata': {'path': './'}})
    with open(notebook_path, 'w', encoding='utf-8') as f:
        nbformat.write(nb, f)

def run_mip(input_dir):
    print("Running MIP script...")
    mip_script = os.path.join(input_dir, "MIP.ipynb")
    run_notebook(mip_script)

def run_smt(input_dir):
    print("Running SMT script...")
    smt_script = os.path.join(input_dir, "Optimize_SB.ipynb")
    run_notebook(smt_script)

if __name__ == "__main__":
    run_cp(CP_dir)
    run_smt(SMT_dir)
    run_mip(MIP_dir)

