#!/bin/bash

# run.sh - execute the emulation and display waves
# SYNOPSIS
# ./run.sh number
# Paramters
# number: 0, the BasicOp.txt will be load | 1, the Branch.txt will be load | 2, the Control.txt will be load | 3, the DataDependence.txt will be load | 4, the Loop.txt will be load | 5, the LwStall.txt will be load

# set -xv
computername="cpu_ppl_cache"
dirTest="ProjectStage2Tests"
files=("BasicOp.txt" "Branch.txt" "Control.txt" "DataDependence.txt" "Loop.txt" "LwStall.txt")
instrFile="instr.hex"

# copy the test file to instr.txt
path=$dirTest"/"${files[$1]}
cp $path $instrFile

vvp $computername
gtkwave cpu_watched_wave.vcd
 
