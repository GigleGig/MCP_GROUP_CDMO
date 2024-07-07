# Use a Python image as base
FROM python:3.12.4

# Set the working directory inside the container
WORKDIR /app

# Copy the entire project's contents into the /app directory of the container
COPY . .

# Install dependencies specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Install Jupyter
RUN pip install jupyter

# Install MiniZinc
RUN apt-get update && \
    apt-get install -y wget libgl1-mesa-glx libglu1-mesa && \
    wget https://github.com/MiniZinc/MiniZincIDE/releases/download/2.8.5/MiniZincIDE-2.8.5-bundle-linux-x86_64.tgz && \
    tar -xzf MiniZincIDE-2.8.5-bundle-linux-x86_64.tgz && \
    mv MiniZincIDE-2.8.5-bundle-linux-x86_64 /usr/local/minizinc && \
    ln -s /usr/local/minizinc/bin/minizinc /usr/local/bin/minizinc && \
    rm MiniZincIDE-2.8.5-bundle-linux-x86_64.tgz

# Commands to run main.py
CMD ["python", "main.py"]
