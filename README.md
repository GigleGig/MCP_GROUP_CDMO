# Multiple Couriers Planning (MCP) Project

This repository contains the implementation of the project for the Combinatorial Decision Making & Optimization course for the academic year 2023/2024. The project involves modeling and solving the Multiple Couriers Planning (MCP) problem using Constraint Programming (CP), Satisfiability Modulo Theories (SMT), and Mixed-Integer Linear Programming (MIP).

## Project Structure

The project repository is organized as follows:

### CP (Constraint Programming)

- **final_code**: This folder contains the final version of the CP code that models and solves the MCP problem.
- **variations**: This directory includes different variations and attempts of the CP models explored during the development phase.
- **instances**: This directory contains the instances of the MCP problem used for testing and validation.

### MIP (Mixed-Integer Linear Programming)

This section contains the models and solutions for the MCP problem using MIP techniques.

### STM (Satisfiability Modulo Theories)

This section contains the models and solutions for the MCP problem using STM techniques.

### Solutions

This folder holds the solutions found using the CP, SMT and MIP approaches.

### Control Code Provided

This section includes the control code provided by the course instructors to verify the correctness of the solutions.

## Getting Started

To reproduce the results and run the models, please follow the instructions provided below.

### Prerequisites

- [Docker](https://www.docker.com/)
- [MiniZinc](https://www.minizinc.org/) for CP models
- [Z3 Solver](https://github.com/Z3Prover/z3) for SAT/SMT models


### Run the control code provided

**WE HAVE TO WRITE HERE THE LINE OF CODE**


### Run the check code

```bash
python solution_check.py Instances_dat/ res/
```

### Building the Docker Image

Navigate to the code directory and build the Docker image using the provided Dockerfile:

```sh
docker build -t mcp_project_Sasdelli_Fossi_Zhang .
docker run --rm -v $(pwd)/output:/app/output mcp_project_Sasdelli_Fossi_Zhang
