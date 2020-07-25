#!/usr/bin/env bash

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
rustup toolchain install nightly --allow-downgrade --profile minimal --component clippy
rustup component add rls rust-analysis rust-src


# Install cargo deps
cargo install cargo-outdated
cargo install cargo-audit --features=fix
cargo install cross


