#!/bin/bash

declare -a Ne
declare -a mu
declare -a r
while IFS=, read N m x; do
	Ne[N]=$N
	echo $N
	mu[m]=$mu
	r[x]=$x
done < ./parameters.txt

echo "$(Ne)\n$(mu)\n$(r)"
