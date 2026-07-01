#!/bin/bash
# =============================================================================
#Script de compilation du projet ChaCha20 (sous Ubuntu)
#À executer dans la racine
#Le script cree les bibliotheques LIB_RTL et LIB_BENCH puis compile les
#fichiers SystemVerilog dans le bon ordre (packages, modules, testbenchs).
# =============================================================================

# Arrete le script des qu'une commande echoue
set -e

# Repertoires sources 
RTL_DIR="./SRC/RTL"
BENCH_DIR="./SRC/BENCH"

echo "=== Compilation du projet ChaCha20 ==="

# Initialisation de Modelsim
source /etc/profile.d/modules.sh
module load mentor/modelsim/2020.4

# Creation des bibliotheques 
if [ ! -d "./LIB" ]; then
    mkdir ./LIB
fi
if [ ! -d "./LIB/LIB_RTL" ]; then
    mkdir ./LIB/LIB_RTL
    vlib ./LIB/LIB_RTL
    vmap LIB_RTL ./LIB/LIB_RTL
fi
if [ ! -d "./LIB/LIB_BENCH" ]; then
    mkdir ./LIB/LIB_BENCH
    vlib ./LIB/LIB_BENCH
    vmap LIB_BENCH ./LIB/LIB_BENCH
fi

# Compilation des packages 
echo "--- Packages ---"
vlog -sv +acc -svinputport=net -work LIB_RTL $RTL_DIR/package_mat.sv
vlog -sv +acc -svinputport=net -work LIB_RTL $RTL_DIR/package_state.sv

# Compilation des modules ARX 
echo "--- Modules ARX ---"
vlog -sv +acc -svinputport=net -work LIB_RTL $RTL_DIR/ARX7.sv
vlog -sv +acc -svinputport=net -work LIB_RTL $RTL_DIR/ARX8.sv
vlog -sv +acc -svinputport=net -work LIB_RTL $RTL_DIR/ARX12.sv
vlog -sv +acc -svinputport=net -work LIB_RTL $RTL_DIR/ARX16.sv

# QuarterRound et rondes 
echo "--- QuarterRound et rondes ---"
vlog -sv +acc -svinputport=net -work LIB_RTL $RTL_DIR/QuarterRound.sv
vlog -sv +acc -svinputport=net -work LIB_RTL $RTL_DIR/RondeV.sv
vlog -sv +acc -svinputport=net -work LIB_RTL $RTL_DIR/RondeD.sv
vlog -sv +acc -svinputport=net -work LIB_RTL $RTL_DIR/Ronde.sv

# Compteur, block et FSM 
echo "--- Compteur, block et FSM ---"
vlog -sv +acc -svinputport=net -work LIB_RTL $RTL_DIR/round_counter.sv
vlog -sv +acc -svinputport=net -work LIB_RTL $RTL_DIR/chacha20_block.sv
vlog -sv +acc -svinputport=net -work LIB_RTL $RTL_DIR/chacha20_fsm_moore.sv

# Top
echo "--- Top ---"
vlog -sv +acc -svinputport=net -work LIB_RTL $RTL_DIR/chacha20_top.sv

# Compilation des testbenchs
echo "--- Testbenchs ---"
vlog -sv +acc -svinputport=net -work LIB_BENCH -L LIB_RTL $BENCH_DIR/ARX7_tb.sv
vlog -sv +acc -svinputport=net -work LIB_BENCH -L LIB_RTL $BENCH_DIR/QuarterRound_tb.sv
vlog -sv +acc -svinputport=net -work LIB_BENCH -L LIB_RTL $BENCH_DIR/chacha20_fsm_moore_tb.sv
vlog -sv +acc -svinputport=net -work LIB_BENCH -L LIB_RTL $BENCH_DIR/chacha20_top_tb.sv
vlog -sv +acc -svinputport=net -work LIB_BENCH -L LIB_RTL $BENCH_DIR/Ronde_tb.sv
vlog -sv +acc -svinputport=net -work LIB_BENCH -L LIB_RTL $BENCH_DIR/chacha20_block_tb.sv

echo ""
echo "=== Compilation terminee ==="
echo "Pour lancer une simulation, par exemple :"
echo "  vsim -L LIB_RTL LIB_BENCH.chacha20_top_tb"
echo "  vsim -L LIB_RTL LIB_BENCH.chacha20_fsm_moore_tb"
