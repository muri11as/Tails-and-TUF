'''
AUTHOR:CESAR MURILLAS
DESCRIPTION: MANUAL SCRIPT FOR CHANGING OUT .STAGED to "live" METADATA
USAGE: run python copytoRepository.py path/to/copyconfig.txt
'''

import subprocess 
old, live = '',''
try:
	filey = open(sys.argv[1],'r')
except:
	print "Can't read config file!"
	sys.exit(1)
for line in filey:
	liss = line.split('=',1)
	if liss[0] == "PATHTO.STAGED":
		old = liss[1].strip()
		
	elif liss[0] == "PATHTOLIVE":
		live = liss[1].strip()

filey.close()	
cmd = "cp -r "+old+" "+live
subprocess.call(cmd,shell=True)