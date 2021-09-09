## Seed Generator

The programs in this folder are seed generators, using different methods for generating unsigned integers of either 32 or 64 bits.

Uniformly Distributed Seed Generator

This program generates a .csv of uniformly distributed 32-bit integers for use as RNG seeds.
Usage: ./seedgenerator [OPTION]...
Example: ./seedgenerator -h

-h             Print this help manual.

-l             

-n N           Generate N random samples. Defaults to 10.

-v             Turn on verbose mode.

-t NAME        Choose a header name. Defaults to 'Seed'. Enter nothing to have no header.
               Example: -t=Number OR -tNumber

-d FILEPATH    Specify a filepath and name for the generated seeds to be saved. Defaults to ./seeds.csv.
               Example: -d ~/Desktop/seeds.csv