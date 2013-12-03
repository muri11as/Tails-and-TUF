'''
Author: Cesar Murillas
Modified: Toan Nguyen
Usage: python generateMetadata.py path/to/repoconfig.txt
'''
import os 
import sys
from tuf.libtuf import *

##PARSE CONFIG FILE, STORE VARIABLES
rootkey,repoName,keystore,tstampExp  = '','','',''
rootpwd,targetpwd,releasepwd,timestamppwd = '','','',''
rthresh,tthresh,rethresh,tathresh = 0,0,0,0

try:
	filey = open(sys.argv[1],'r')
except:
	print "Can't read config file"
	sys.exit(1)
	
for line in filey:
	liss= line.split('=',1)
	if liss[0] == "ROOTKEY":
		rootkey = liss[1].strip()
		
	elif liss[0] == "REPONAME":
		repoName = liss[1].strip()
		
	elif liss[0] == "KEYSTORE":
		keystore = liss[1].strip()
		
	elif liss[0] == "ROOTPASSWORD":
		rootpwd = liss[1].strip()
		
	elif liss[0] == "TARGETPASSWORD":
		targetpwd = liss[1].strip()
		
	elif liss[0] == "RELEASEPASSWORD":
		releasepwd = liss[1].strip()
		
	elif liss[0] == "TIMESTAMPPASSWORD":
		timestamppwd = liss[1].strip()
		
	elif liss[0] == "ROOTTHRESH":
		rthresh = int(liss[1].strip())
		
	elif liss[0] == "TIMESTAMPTHRESH":
		tthresh = int(liss[1].strip())
		
	elif liss[0] == "RELEASETHRESH":
		rethresh = int(liss[1].strip())
		
	elif liss[0] == "TARGETSTHRESH":
		tathresh = int(liss[1].strip())
		
	elif liss[0] == "TIMESTAMPEXP":
		tstampExp = liss[1].strip()
		
filey.close()

##IMPORT RSA KEYS

public_root_key = import_rsa_publickey_from_file(rootkey+".pub")
private_root_key = import_rsa_privatekey_from_file(rootkey,password=rootpwd)

#CREATE NEW REPOSITORY
repository = create_new_repository(repoName)

repository.root.add_key(public_root_key)
repository.root.threshold = rthresh
repository.root.load_signing_key(private_root_key)

##CREATE TIMESTAMP, RELEASE, && TARGETS ROLES ##

#ADD PUBLIC KEYS

repository.timestamp.add_key(import_rsa_publickey_from_file(keystore+"timestamp.pub"))
repository.release.add_key(import_rsa_publickey_from_file(keystore+"release.pub"))
repository.targets.add_key(import_rsa_publickey_from_file(keystore+"targets.pub"))

#SET THRESHOLDS
repository.timestamp.threshold = tthresh
repository.release.threshold = rethresh
repository.targets.threshold = tathresh

#IMPORT SIGNING KEYS
private_timestamp_key = import_rsa_privatekey_from_file(keystore+"timestamp",password=timestamppwd)
private_release_key = import_rsa_privatekey_from_file(keystore+"release",password=releasepwd)
private_targets_key = import_rsa_privatekey_from_file(keystore+"targets",password=targetpwd)
#LOAD KEYS
repository.timestamp.load_signing_key(private_timestamp_key)
repository.release.load_signing_key(private_release_key)
repository.targets.load_signing_key(private_targets_key)
#EXPIRE DATE FOR TIMESTAMP
repository.timestamp.expiration = tstampExp
#WRITE OUT
repository.write()