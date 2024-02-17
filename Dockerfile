# Use the official Rust image as a base
FROM rust:latest as builder

# Create a new empty shell project
RUN USER=root cargo new --bin myapp
WORKDIR /myapp

# Copy your manifests
COPY ./Cargo.lock ./Cargo.lock
COPY ./Cargo.toml ./Cargo.toml

# Build only the dependencies to cache them
RUN cargo build --release
RUN rm src/*.rs

# Now that the dependencies are built, copy your source code
COPY ./src ./src

# Build for release
RUN rm ./target/release/deps/myapp*
RUN cargo build --release

# Final base
FROM debian:buster-slim

# Copy the build artifact from the build stage
COPY --from=builder /myapp/target/release/myapp /golem/work

VOLUME /golem/output /golem/input
WORKDIR /golem/work

# Set the startup command to run your binary
CMD ["./golem/work/myapp"]


# # Use the official Ubuntu 22.04 base image
# FROM ubuntu:22.04

# # Update package lists and install necessary dependencies
# RUN apt update && apt install -y build-essential nvidia-cuda-toolkit git curl && rm -rf /var/lib/apt/lists/*

# # Get Rust using the Rustup installer; -y flag for automatic installation
# RUN curl https://sh.rustup.rs -sSf | sh -s -- -y

# # Add Rust binary directory to the PATH environment variable
# ENV PATH="/root/.cargo/bin:${PATH}"

# # Clone the createXcrunch repository from GitHub
# RUN git clone https://github.com/0xfraan/createXcrunch.git

# # Set the working directory to the createXcrunch directory
# WORKDIR /createXcrunch

# # Build the project using Cargo (Rust package manager) in release mode
# RUN cargo build --release