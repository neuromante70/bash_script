#!/bin/bash 
   function pacman_with_par {
	   echo y | sudo pacman -Syu $1
   }
