# PiHPSDR RigCtld Service

Automatically start Hamlib rigctld for PiHPSDR at boot with systemd persistence.

## Overview

This service creates a permanent bridge between PiHPSDR (listening on port 19090) and your logging software using Hamlib's rigctld daemon. The service survives power cycles, reboots, and automatically restarts if it crashes.

## Prerequisites

- PiHPSDR installed and running (listening on port 19090)
- Hamlib utilities installed:
  ```bash
  sudo apt update
  sudo apt install libhamlib-utils