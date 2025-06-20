#!/bin/bash
set -e

# Install build tools (gcc, make, etc.)
sudo apt-get update
sudo apt-get install -y build-essential pkg-config libssl-dev

# Install Rust non-interactively (auto-accept default)
curl https://sh.rustup.rs -sSf | sh -s -- -y

# Source cargo (add Rust to path for this session)
source "$HOME/.cargo/env"

# Install Oniux from Gitlab at specific tag
cargo install --git https://gitlab.torproject.org/tpo/core/oniux --tag v0.4.0 oniux
