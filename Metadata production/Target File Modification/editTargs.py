'''
AUTHOR:CESAR MURILLAS
CS9163
DESCRIPTION: MAIN SCRIPT TO RUN TO CHANGE TARGETS METADATA EX:NEW UPDATE
EVERYTHING SHOULD BE SPECIFIED IN THE CONFIG FILE: SWAPCONFIG.TXT
USAGE: RUN python setup.py path/to/swapconfig.txt
'''

import subprocess 
import sys 
abspath,filled, repo = '','',''

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

filey.close()	

#GET ALL PATHS 
rmTarg = "python "+abspath+"removeTargs.py "+abspath+"targetconfig.txt"
addTarg = "python "+abspath+"addtargs.py "+abspath+"targetconfig.txt"
fillTargs= "cp -r "+filled+" "+repo+"targets"
goLive = "cp -r "+repo+"metadata.staged "+repo+"metadata"

subprocess.call(rmTarg, shell=True)
subprocess.call("rm -r "+repo+"targets", shell=True)
subprocess.call("mkdir "+repo+"targets", shell=True)
subprocess.call(fillTargs, shell=True)
subprocess.call(addTarg, shell=True)
#subprocess.call(goLive,shell=True)
