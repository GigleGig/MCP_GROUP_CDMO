# Use a base image with Python
FROM python:3.12

# Set the working directory
WORKDIR /app

# Copy the requirements.txt file and install dependencies
COPY . .
RUN pip install -r requirements.txt

# Install Jupyter and nbconvert
RUN pip install jupyter nbconvert

# Set the command to run the main script
CMD python3 main.py