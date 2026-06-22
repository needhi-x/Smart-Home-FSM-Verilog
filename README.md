# 🏠 Smart Home Automation System (FSM-Based Verilog Design)

## 📌 Overview
This project implements an industry-grade Smart Home Automation System using SystemVerilog.  
It uses a Finite State Machine (FSM) to control lighting, temperature, and security.

## 🚀 Features
- FSM-based control
- Motion detection
- Light automation
- Temperature-based fan & AC control
- Security alert system
- Manual override mode
- Energy-saving mode with timer

## 🧠 Design Architecture
- Top Module
- FSM Controller
- Timer Counter
- Output Logic

## 🛠 Tools Used
- Icarus Verilog (iverilog)
- GTKWave
- EDA Playground

## ▶️ How to Run

```bash
iverilog -g2012 design.sv testbench.sv
vvp a.out
gtkwave wave.vcd
```

## 📊 Simulation Output
Waveform generated using GTKWave shows:
- State transitions
- Output control signals
- Timer-based behavior

## 💡 Learning Outcome
- FSM design
- Modular coding
- Industry-level SystemVerilog practices
- Simulation and debugging

## 📎 Author
Nidhi Apotikar