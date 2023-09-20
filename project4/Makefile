# MPLAB IDE generated this makefile for use with GNU make.
# Project: project4.mcp
# Date: Wed Jul 26 19:43:05 2023

AS = MPASMWIN.exe
CC = 
LD = mplink.exe
AR = mplib.exe
RM = rm

project4.cof : project4.o
	$(CC) /p16F877A "16f877a_g.lkr" "project4.o" /u_DEBUG /z__MPLAB_BUILD=1 /z__MPLAB_DEBUG=1 /o"project4.cof" /M"project4.map" /W

project4.o : project4.asm P16F877A.INC LCDIS.INC
	$(AS) /q /p16F877A "project4.asm" /l"project4.lst" /e"project4.err" /o"project4.o" /d__DEBUG=1

clean : 
	$(CC) "project4.o" "project4.err" "project4.lst" "project4.cof" "project4.hex"

