# Use the official Ubuntu 22.04 base image
FROM ubuntu:22.04

# Update package lists and install necessary dependencies
RUN apt update && apt install -y build-essential nvidia-cuda-toolkit git curl && rm -rf /var/lib/apt/lists/*

# Get Rust using the Rustup installer; -y flag for automatic installation
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y

# Add Rust binary directory to the PATH environment variable
ENV PATH="/root/.cargo/bin:${PATH}"

# Clone the createXcrunch repository from GitHub
RUN git clone https://github.com/0xfraan/createXcrunch.git

# Set the working directory to the createXcrunch directory
WORKDIR /createXcrunch

# Build the project using Cargo (Rust package manager) in release mode
RUN cargo build --release