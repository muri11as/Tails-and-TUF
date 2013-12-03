'''
Author: Cesar Murillas
'''
import os 
from tuf.libtuf import *

##IMPORT RSA KEYS

public_root_key = import_rsa_publickey_from_file("/Users/Ceeze/Desktop/assignment3.3/tuf/rootkeys/root_key1.pub")
private_root_key = import_rsa_privatekey_from_file("/Users/Ceeze/Desktop/assignment3.3/tuf/rootkeys/root_key1",password="gogreen")


##CREATE ROOT

#CREATE NEW REPOSITORY
repository = create_new_repository("/Users/Ceeze/Desktop/assignment3.3/tuf")

repository.root.add_key(public_root_key)
repository.root.threshold = 1
repository.root.load_signing_key(private_root_key)

##CREATE TIMESTAMP, RELEASE, && TARGETS ROLES

#ADD PUBLIC KEYS
repository.timestamp.add_key(import_rsa_publickey_from_file("/Users/Ceeze/Desktop/assignment3.3/tuf/keys/timestamp.pub"))
repository.release.add_key(import_rsa_publickey_from_file("/Users/Ceeze/Desktop/assignment3.3/tuf/keys/release.pub"))
repository.targets.add_key(import_rsa_publickey_from_file("/Users/Ceeze/Desktop/assignment3.3/tuf/keys/targets.pub"))

#SET THRESHOLDS
repository.timestamp.threshold = 1
repository.release.threshold = 1
repository.targets.threshold = 1

#IMPORT SIGNING KEYS
private_timestamp_key = import_rsa_privatekey_from_file("/Users/Ceeze/Desktop/assignment3.3/tuf/keys/timestamp",password="gogreen")
private_release_key = import_rsa_privatekey_from_file("/Users/Ceeze/Desktop/assignment3.3/tuf/keys/release",password="gogreen")
private_targets_key = import_rsa_privatekey_from_file("/Users/Ceeze/Desktop/assignment3.3/tuf/keys/targets",password="gogreen")
#LOAD KEYS
repository.timestamp.load_signing_key(private_timestamp_key)
repository.release.load_signing_key(private_release_key)
repository.targets.load_signing_key(private_targets_key)
#EXPIRE DATE FOR TIMESTAMP
repository.timestamp.expiration = "2013-12-06 12:00:00"
#WRITE OUT
repository.write()


