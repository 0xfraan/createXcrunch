# syntax=docker/dockerfile:1.3-labs

FROM rust:latest as build
WORKDIR /app
RUN apt update && apt install -y ocl-icd-opencl-dev
RUN cargo new --bin /app/createXcrunch
COPY Cargo.toml Cargo.lock /app/createXcrunch/
WORKDIR /app/createXcrunch
RUN --mount=type=cache,target=/usr/local/cargo/registry --mount=type=cache,target=/app/createXcrunch/target RUST_LOG=debug cargo build --release

COPY src  src
COPY tests tests

RUN --mount=type=cache,target=/usr/local/cargo/registry --mount=type=cache,target=/app/createXcrunch/target <<EOF
  set -e
  # update timestamps to force a new build
  touch /app/createXcrunch/src/main.rs
  cargo build --release
  cp target/release/createxcrunch .

EOF

FROM debian:stable AS app
RUN apt-get update && apt-get install --no-install-recommends --yes mesa-opencl-icd pocl-opencl-icd
COPY --from=build /app/createXcrunch/createxcrunch /createXcrunch