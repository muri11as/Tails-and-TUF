'''
AUTHOR:CESAR MURILLAS
CS9163
DESCRIPTION: MAIN SCRIPT TO RUN TO CHANGE TARGETS METADATA EX:NEW UPDATE
EVERYTHING SHOULD BE SPECIFIED IN THE CONFIG FILE: SWAPCONFIG.TXT
USAGE: RUN python editTargs.py path/to/swapconfig.txt
'''

import subprocess 
import sys 
import os 
channel,rolepwd,abspath,filled,repo,updatePath = '','','','','',''

try:
	filey = open(sys.argv[1],'r')
except:
	print "Can't read config file!"
	sys.exit(1)
	
for line in filey:
	liss = line.split('=',1)
	if liss[0] == "CHANNEL":
		channel = liss[1].strip()
	
	elif liss[0] == "CHANNELKEYPASSWORD":
		rolepwd = liss[1].strip()
		
	elif liss[0] == "PATHTODIRECTORY":
		abspath = liss[1].strip()
		
	elif liss[0] == "PATHTOTARGETS":
		filled = liss[1].strip()
		
	elif liss[0] == "REPO":
		repo = liss[1].strip()
	
	elif liss[0] == "TARGETSTRUCTURE":
		updatePath = liss[1].strip()

filey.close()
	
if channel != "stable" or channel != "beta" or channel !="nightly"
	print "Not a valid channel!"
	sys.exit(1)
rmscript = "clearTarg.py "
addscript = "addToRole.py "
#GET ALL PATHS 
rm = "rm -r "+repo+"targets/"+channel+"/"
mk = "mkdir "+repo+"targets/"+channel+"/"
fillTargs= "cp -r "+filled+" "+repo+"targets/"+channel
rmTarg = "python "+abspath+rmscript+abspath+"swaptargetconfig.txt "+channel+" "+rolepwd
addTarg = "python "+abspath+addscript+abspath+"swaptargetconfig.txt "+channel+" "+rolepwd
goLive = "cp -r "+repo+"metadata.staged "+repo+"metadata"

#RUN
subprocess.call(rmTarg, shell=True)
subprocess.call(rm,shell=True)
subprocess.call(mk,shell=True)
subprocess.call(fillTargs, shell=True)
subprocess.call(addTarg, shell=True)
subprocess.call(goLive,shell=True)
