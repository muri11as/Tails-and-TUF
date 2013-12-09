'''
AUTHOR:CESAR MURILLAS
CS9163
DESCRIPTION: MAIN SCRIPT TO RUN TO CHANGE TARGETS METADATA EX:NEW UPDATE
EVERYTHING SHOULD BE SPECIFIED IN THE CONFIG FILE: SWAPCONFIG.TXT
USAGE: RUN python editTargs.py path/to/swapconfig.txt
'''

import subprocess 
import sys 
abspath,filled,repo,updatePath = '','','',''
'''add compability mode to switch between scripts ex: pass in stable: use stable scripts!'''

try:
	filey = open(sys.argv[1],'r')
except:
	print "Can't read config file!"
	sys.exit(1)
for line in filey:
	liss = line.split('=',1)
	if liss[0] == "PATHTODIRECTORY":
		abspath = liss[1].strip()
		
	elif liss[0] == "PATHTOTARGETS":
		filled = liss[1].strip()
		
	elif liss[0] == "REPO":
		repo = liss[1].strip()
	
	elif liss[0] == "TARGETSTRUCTURE":
		updatePath = liss[1].strip()

filey.close()	

#GET ALL PATHS 
rmstab = "rm -r "+repo+updatePath+"stable/"
mkstab = "mkdir "+repo+updatePath+"stable/"
fillTargs= "cp -r "+filled+" "+repo+updatePath+"stable/"
rmTarg = "python "+abspath+"removeStable.py "+abspath+"targetconfig.txt"
addTarg = "python "+abspath+"addToStable.py "+abspath+"targetconfig.txt"
goLive = "cp -r "+repo+"metadata.staged "+repo+"metadata"


subprocess.call(rmTarg, shell=True)
#subprocess.call(rmstab,shell=True)
#subprocess.call(mkstab,shell=True)
#subprocess.call(fillTargs, shell=True)
#subprocess.call(addTarg, shell=True)
#subprocess.call(goLive,shell=True)
