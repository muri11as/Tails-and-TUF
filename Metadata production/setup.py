'''
AUTHOR:CESAR MURILLAS
CS9163
DESCRIPTION: MAIN SCRIPT TO RUN TO GENERATE METADATA
EVERYTHING SHOULD BE SPECIFIED IN THE CONFIG FILE: SETUPCONFIG.TXT
USAGE: RUN python setup.py path/to/setupconfig.txt
'''

import subprocess 
import sys 
abspath,filled, empty, old, live = '','','','',''

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
	elif liss[0] == "OLDTARGETSPATH":
		empty = liss[1].strip()
	elif liss[0] == "OLDREPO":
		old = liss[1].strip()
	elif liss[0] == "LIVEREPO":
		live = liss[1].strip()
		
filey.close()	

#GET ALL PATHS 

keys = "python "+abspath+"generateKeystore.py "+abspath+"keyconfig.txt"
makeRepo = "python "+abspath+"generateRepositoryLocal.py "+abspath+"repoconfig.txt"
addTarg = "python "+abspath+"addtargs.py "+abspath+"targetconfig.txt"
fillTargs= "cp -r "+filled+" "+empty
goLive = "cp -r "+old+" "+live
#print "keys: "+keys


subprocess.call(keys, shell=True)
subprocess.call(makeRepo, shell=True)
subprocess.call(fillTargs, shell=True)
subprocess.call(addTarg, shell=True)
subprocess.call(goLive,shell=True)
