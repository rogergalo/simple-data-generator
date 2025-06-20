#!/bin/bash
set -e

# Update package list
sudo apt-get update

# Install build dependencies
sudo apt-get install -y build-essential pkg-config libssl-dev git curl rustc 

# Install Oniux from the specified git repo and tag
cargo install --git https://gitlab.torproject.org/tpo/core/oniux --tag v0.4.0 oniux

echo "Oniux installed successfully!"
