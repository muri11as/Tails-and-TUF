from tuf.libtuf import *
import os 
##ADD TARGET FILES
'''Make sure the target files are saved in the targets directory of the repository'''
repository = load_repository("/Users/Ceeze/Desktop/assignment3.3/tuf")
#os.system("echo 'file1' > /Users/Ceeze/Desktop/assignment3.3/tuf/targets/updates.txt")
#os.system('touch /Users/Ceeze/Desktop/assignment3.3/tuf/targets/updates2.txt')
#os.system('touch /Users/Ceeze/Desktop/assignment3.3/tuf/targets/updates3.txt')
#Get list of file all file paths
list_of_targets = repository.get_filepaths_in_directory("/Users/Ceeze/Desktop/assignment3.3/tuf/targets", recursive_walk=False, followlinks=True)

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
