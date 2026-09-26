# Parking Management System

A menu-driven parking management system written in 16-bit x86 assembly for DOS. It was created for the CSE341 Microprocessors course.

## Features

- Automatically assign the next available slot for a vehicle.
- Select a slot manually, with checks for occupancy and vehicle category.
- Search for a parked vehicle by ID.
- Exit a vehicle, release its slot, and calculate its parking fee.
- Display available slots and free-slot totals by category.
- Verify VIP customers using a four-digit access code.

## Parking Rules

- The car park has 10 slots.
- Slots 01–03 are reserved for VIP vehicles.
- Slots 04–10 are reserved for regular vehicles.
- Vehicle IDs must be between 01 and 99 and must be unique among currently parked vehicles.
- VIP access codes in this version are `1234`, `2580`, `3412`, `7777`, and `9001`.
- The parking fee is 10 Taka per hour. Hours are entered manually when a vehicle exits.

## Requirements

- DOSBox or another 16-bit DOS environment.
- A MASM- or TASM-compatible assembler and linker available inside that environment.

## Build and Run

Mount the folder containing the source file in DOSBox, switch to that drive, and run:

```text
TASM 01_03_23201317_23201333_23201375.ASM
TLINK 01_03_23201317_23201333_23201375.OBJ
01_03_23201317_23201333_23201375.EXE
