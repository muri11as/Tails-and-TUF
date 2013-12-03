'''
Author: Cesar Murillas
'''
import os 
from tuf.libtuf import *

##PARSE CONFIG FILE FOR ROOTPATH, PATH AND PASSWORD
rootkey,repoName,keystore,pword = '','','',''

filey = open("/Users/Ceeze/Desktop/repoconfig.txt",'r')
for line in filey:
	liss= line.split('=',1)
	if liss[0] == "ROOTKEY":
		rootkey = liss[1].strip()
	elif liss[0] == "REPONAME":
		repoName = liss[1].strip()
	elif liss[0] == "KEYSTORE":
		keystore = liss[1].strip()
	elif liss[0] == "PASSWORD":
		pword = liss[1].strip()
filey.close()

##IMPORT RSA KEYS

public_root_key = import_rsa_publickey_from_file(rootkey+".pub")
private_root_key = import_rsa_privatekey_from_file(rootkey,password=pword)


#CREATE NEW REPOSITORY
repository = create_new_repository(repoName)

repository.root.add_key(public_root_key)
repository.root.threshold = 1
repository.root.load_signing_key(private_root_key)

##CREATE TIMESTAMP, RELEASE, && TARGETS ROLES

#ADD PUBLIC KEYS
path = repoName+keystore

repository.timestamp.add_key(import_rsa_publickey_from_file(path+"timestamp.pub"))
repository.release.add_key(import_rsa_publickey_from_file(path+"release.pub"))
repository.targets.add_key(import_rsa_publickey_from_file(path+"targets.pub"))

#SET THRESHOLDS
repository.timestamp.threshold = 1
repository.release.threshold = 1
repository.targets.threshold = 1

#IMPORT SIGNING KEYS
private_timestamp_key = import_rsa_privatekey_from_file(path+"timestamp",password=pword)
private_release_key = import_rsa_privatekey_from_file(path+"release",password=pword)
private_targets_key = import_rsa_privatekey_from_file(path+"targets",password=pword)
#LOAD KEYS
repository.timestamp.load_signing_key(private_timestamp_key)
repository.release.load_signing_key(private_release_key)
repository.targets.load_signing_key(private_targets_key)
#EXPIRE DATE FOR TIMESTAMP
repository.timestamp.expiration = "2013-12-06 12:00:00"
#WRITE OUT
repository.write()


