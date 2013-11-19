'''
Author: Cesar Murillas
'''
from tuf.libtuf import *

##CREATE RSA KEYS

generate_and_write_rsa_keypair("path2rootkey",bits=3072,password="gogreen")
generate_and_write_rsa_keypair("path2root2",bits=3072,password="gogreen")


##IMPORT RSA KEYS

public_root_key = import_rsa_publickey_from_file("path2rootkey.pub")
private_root_key = import_rsa_privatekey_from_file("path2rootkey",password="gogreen")
public_root_key2 = import_rsa_publickey_from_file("path2root2.pub")
private_root_key2 = import_rsa_privatekey_from_file("path2root2",password="gogreen")

##CREATE ROOT

#CREATE NEW REPOSITORY
repository = create_new_repository("path2repo")

repository.root.add_key(public_root_key)
repository.root.threshold = 2

repository.root.load_signing_key(private_root_key)
repository.root.load_signing_key(private_root_key2)

try:
	repository.write()
	
except tuf.Error, e:
	print e 
	
##CREATE TIMESTAMP, RELEASE, && TARGETS ROLES

generate_and_write_rsa_keypair("path2timestamp",bits=3072,password="gogreen")
generate_and_write_rsa_keypair("path2release",bits=3072,password="gogreen")
generate_and_write_rsa_keypair("path2targets",bits=3072,password="gogreen")
#ADD PUBLIC KEYS
repository.timestamp.add_key(import_rsa_publickey_from_file("path2timestamp.pub"))
repository.release.add_key(import_rsa_publickey_from_file("path2release.pub"))
repository.targets.add_key(import_rsa_publickey_from_file("path2targets.pub"))
#IMPORT SIGNING KEYS
private_timestamp_key = import_rsa_privatekey_from_file("path2timestamp",password="gogreen")
private_release_key = import_rsa_privatekey_from_file("path2release",password="gogreen")
private_targets_key = import_rsa_privatekey_from_file("path2targets",password="gogreen")
#LOAD KEYS
repository.timestamp.load_signing_key(private_timestamp_key)
repository.release.load_signing_key(private_release_key)
repository.targets.load_signing_key(private_targets_key)
#EXPIRE DATE FOR TIMESTAMP
repository.timestamp.expiration = "2013-12-06 12:00:00"
#WRITE OUT
repository.write()

##ADD TARGET FILES
'''Make sure the target files are saved in the targets directory of the repository'''

#Get list of file all file paths
list_of_targets = repository.get_filepaths_in_directory("path to repo/targets", recursive_walk=False, followlinks=True)

#Add List of target files to the targets metadata
repository.targets.add_target(list_of_targets)
repository.targets.load_signing_key(private_targets_key)

#LOAD SIGNING KEYS

repository.timestamp.load_signing_key(private_timestamp_key)
repository.release.load_signing_key(private_release_key)
repository.targets.load_signing_key(private_targets_key)
repository.root.load_signing_key(private_root_key)
repository.root.load_signing_key(private_root_key2)
#NEW VERSIONS OF METADATA
repository.write()


