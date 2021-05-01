#!/bin/bash

# Simple template script to run a bunch of SLiM scripts in parallel, with different seeds (for replication)
# and different parameter values for population size, mutation rate, and recombination rate 

# First we read all the seeds from a file into an array
declare -a seeds

while read seed; do
    seeds[seed]=$seed
done < seeds.csv

# Discard the header, keep the rest
seeds=seeds[0:(@-1)]


for s in seeds; do 
    for Ne in 100 1000; do
        for mu in 1e-7 1e-6; do
            for r in 1e-8 1e-7; do
                slim -s $s -d Ne=$Ne -d mu=$mu -d rwide=$r ~/Desktop/example_script.slim & 
            done
        done
    done
done
