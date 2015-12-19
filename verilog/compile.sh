#!/bin/bash

# compile the program
# format
# ./compile.sh -num
# num: 0 (single cycle) | 1 (pipelined with register bypassing)

filename="filelist_final.txt"
computername="cpu_ppl_cache"
dir="./filelist"

path=$dir"/"$filename

iverilog -o $computername -c $path
