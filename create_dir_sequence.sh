#!/bin/bash
#mkdir  ./Chapter{1..15}


for i in $(seq -f "%02g" 1 15);
	do mkdir ./Chapter${i} ;
done
