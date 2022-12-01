#!/bin/zsh

gcc -Wall 2.2.c
./a.out & pstree | grep a.out
