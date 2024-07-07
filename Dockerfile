# Use a base image with Python
FROM python:3.12.4

# Set the working directory
WORKDIR /app

# Copy the requirements.txt file and install dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt

# Install Jupyter and nbconvert
RUN pip install jupyter nbconvert

# Create directories for input and output
RUN mkdir input output

# Copy the scripts and notebooks into the container
COPY run_mcp.py input/
COPY MIP.ipynb input/
COPY SMT.ipynb input/
COPY main.py ./

# Set the command to run the main script
CMD ["python", "main.py"]