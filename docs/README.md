# LINEAR

Combined "Real-Time Programming" and "Development and application of computer hardware accelerators" project.

## About

LINEAR explores hard real-time computing on heterogenous computing systems.

Goal is developing a hard real-time drone control software which relies on timely processed image data. Drone control is executed on an off-the-shelf MCU while image processing is offloaded to a custom multi-core SIMD accelerator.

## Components

### Hardware

* Off-the-shelf MCU for general computing tasks \[STM32F303ZE]
* Custom multi-core SIMD accelerator for offloading image processing \[LINEAR Engine]
* Desktop PC running the simulation and providing user interface

### Software

* Drone control software running on the MCU
* Compute kernels for image processing running on the LINEAR Engine
* Simulation and UI software running on the desktop PC
