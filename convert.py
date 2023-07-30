#! /usr/bin/python
# -*- coding: utf-8 -*-
# convert

import time
import struct

# FPGA bit file

fname= './tmp.dat'
ofname = './imem.dat'
of=open(ofname, mode='w')
for line in open(fname).readlines():
	if('_' in line):
		sline = line.split('_')
		mode = sline[0]
		imm = sline[1]
		rs1 = sline[2]
		funct3 = sline[3]
		if(mode[0:2]!='11'):
			rd = sline[4]
			opcode = sline[5]
			if(mode=='100'):
#				print(imm[1:8],imm[8:],'_',rs1,'_',funct3,'_',rd,'_',opcode, sep='', end='')
				s=imm[1:8]+imm[8:]+'_'+rs1+'_'+funct3+'_'+rd+'_'+opcode
				of.write(s)
			if(mode=='001'):
#				print(imm[1:],'_',rs1,'_',funct3,'_',rd,'_',opcode, sep='', end='')
				s=imm[1:]+'_'+rs1+'_'+funct3+'_'+rd+'_'+opcode
				of.write(s)
			if(mode=='011'):
#				print(imm[0],imm[2:8],'_',rd,'_',rs1,'_',funct3,'_',imm[8:12],imm[1],'_',opcode, sep='', end='')
				s=imm[0]+imm[2:8]+'_'+rd+'_'+rs1+'_'+funct3+'_'+imm[8:12]+imm[1]+'_'+opcode
				of.write(s)
			if(mode=='010'):
#				print(imm[1:8],'_',rd,'_',rs1,'_',funct3,'_',imm[8:],'_',opcode, sep='', end='')
				s=imm[1:8]+'_'+rd+'_'+rs1+'_'+funct3+'_'+imm[8:]+'_'+opcode
				of.write(s)
		else:
			if(mode=='110'):
#				print(imm[1:],'_',rs1,'_',funct3, sep='', end='')
				s=imm[1:]+'_'+rs1+'_'+funct3
				of.write(s)
			else:
#				print(imm[0],imm[10:20],imm[9],imm[1:9],'_',rs1,'_',funct3, sep='', end='')
				s=imm[0]+imm[10:20]+imm[9]+imm[1:9]+'_'+rs1+'_'+funct3
				of.write(s)
