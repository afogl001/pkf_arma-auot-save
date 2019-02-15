#!/bin/bash

n=1
for OUTPUT in $(find ~/ -name save.fps.* -type f -print | grep ARMA | tail -5)
do
	#echo $OUTPUT
	#echo $n

	Save_$n=$OUTPUT
	((n++))
done
echo $Save_1
echo $Save_2
echo $Save_3
