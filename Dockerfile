# Use a Python image as base
FROM python:3.12.4

# Set the working directory inside the container
WORKDIR /app

# Copy the entire project's contents into the /app directory of the container
COPY . .

# Install dependencies specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

RUN pip install jupyter

# Commands to run main.py
CMD ["python", "main.py"]