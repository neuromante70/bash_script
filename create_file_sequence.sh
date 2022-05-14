#!/bin/bash
#touch  file{1..15}


for i in $(seq -f "%02g" 1 15);
	do touch file${i} ;
done
