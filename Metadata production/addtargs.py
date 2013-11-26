from tuf.libtuf import *
import os 
##ADD TARGET FILES
'''Make sure the target files are saved in the targets directory of the repository'''
repository = load_repository("/Users/Ceeze/Desktop/assignment3.3/tuf")
#Get list of file all file paths

list_of_targets = repository.get_filepaths_in_directory("/Users/Ceeze/Desktop/assignment3.3/tuf/targets", recursive_walk=True, followlinks=True)


#GET RID OF .DS_Stores PRODUCED BY MACOSX, COMMENT OUT IF NEEDED
os.system("cd /Users/Ceeze/Desktop/assignment3.3/tuf/targets")
os.system("find . -name '*.DS_Store' -type f -delete")

#print list_of_targets

#Add List of target files to the targets metadata

repository.targets.add_target(list_of_targets[0])
repository.targets.add_target(list_of_targets[1])

#IMPORT SIGNING KEYS
private_root_key = import_rsa_privatekey_from_file("/Users/Ceeze/Desktop/assignment3.3/tuf/rootkeys/root_key1",password="gogreen")
#private_root_key2 = import_rsa_privatekey_from_file("/Users/Ceeze/Desktop/assignment3.3/tuf/rootkeys/root_key2",password="gogreen")
private_timestamp_key = import_rsa_privatekey_from_file("/Users/Ceeze/Desktop/assignment3.3/tuf/keys/timestamp",password="gogreen")
private_release_key = import_rsa_privatekey_from_file("/Users/Ceeze/Desktop/assignment3.3/tuf/keys/release",password="gogreen")
private_targets_key = import_rsa_privatekey_from_file("/Users/Ceeze/Desktop/assignment3.3/tuf/keys/targets",password="gogreen")


#LOAD SIGNING KEYS

repository.targets.load_signing_key(private_targets_key)
repository.timestamp.load_signing_key(private_timestamp_key)
repository.release.load_signing_key(private_release_key)
repository.targets.load_signing_key(private_targets_key)
repository.root.load_signing_key(private_root_key)
#repository.root.load_signing_key(private_root_key2)
#NEW VERSIONS OF METADATA

repository.write()
