#!/bin/sh
flex lexico.l
bison -t -d -v sintactico.y
gcc lex.yy.c sintactico.tab.c -lfl