#!/bin/bash
set -e

# Update package list
sudo apt-get update

# Install build dependencies
sudo apt-get install -y build-essential pkg-config libssl-dev git curl

# Install Rust and Cargo (if not already installed)
if ! command -v cargo >/dev/null 2>&1; then
    echo "Installing Rust and Cargo via rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    # Source Cargo environment for current shell
    export PATH="$HOME/.cargo/bin:$PATH"
else
    echo "Cargo already installed."
fi

# Make sure cargo is in PATH
export PATH="$HOME/.cargo/bin:$PATH"

# Install Oniux from the specified git repo and tag
cargo install --git https://gitlab.torproject.org/tpo/core/oniux --tag v0.4.0 oniux

echo "Oniux installed successfully!"
