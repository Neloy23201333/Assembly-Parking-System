I’ll shape this as paste-ready project documentation, grounded in the repository’s current README and the program’s actual behavior.

Read 

Replace the current README with this:

```markdown
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
```

The source uses DOS and BIOS interrupts and is intended to run in a DOS environment.

## Usage

Choose an option from the main menu and follow the prompts. Vehicle IDs, slot numbers, VIP codes, and parking hours are entered through the keyboard. Vehicle and slot data are held in memory, so the parking state resets when the program exits.

## Project Information

- **Course:** CSE341 – Microprocessors
- **Group:** 01
- **Group members:** 23201317, 23201333, 23201375
- **Source file:** `01_03_23201317_23201333_23201375.asm`
```
