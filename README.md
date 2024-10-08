# Multiple Couriers Planning (MCP) Project

This repository contains the implementation of the project for the Combinatorial Decision Making & Optimization course for the academic year 2023/2024. The project involves modeling and solving the Multiple Couriers Planning (MCP) problem using Constraint Programming (CP), Satisfiability Modulo Theories (SMT), and Mixed-Integer Linear Programming (MIP).

## Project Structure

The project repository is organized as follows:

### CP (Constraint Programming)

- **MCP_final.mzn**: This code is the final version of the CP code that models and solves the MCP problem.
- **MCP_no_boundaries.mzn**: This code is a variation without the boundaries and with another variable.
- **Instances**: This directory contains the instances of the MCP problem used for testing and validation.
- **run_mcp.py**: This python code is used to execute the .mzn codes
    ```bash
    python run_mcp.py
    ```

### SMT (Satisfiability modulo theories)

- **Optimize_BINARY.ipynb**: This code is the final version of SMT model that used Optimize and Binary Search method.
- **OPTIMIZE_WITH_SB.ipynb**: This code is the final version of SMT model that used Optimize and Binary Search method but plus symmetry breaking constraint.
- **Integrating Json,ipynb**: This code is for the purpose of integrating two different methods' output into one json file for each instance.
- **Test.ipynb**: This code is working for revising code, after code works well, it will be seperated into different code files.


### MIP (Mixed-Integer Linear Programming)

- **model.mod**: This file contains the MIP model written in the AMPL language without the symmetry breaking contraint
- **model_SB.mod**: This file contains the MIP model written in the AMPL language with the symmetry breaking contraint.
- **MIP.ipynb**: Jupyter notebook to run both the MIP models.

### res folder

This folder holds the solutions found using the CP, SMT and MIP approaches.

## Run the check code

```bash
python solution_check.py Instances_dat/ res/
```

### Building the Docker Image

Navigate to the code directory and build the Docker image using the provided Dockerfile:

```sh
docker build -t mcp_project_Sasdelli_Fossi_Zhang .
