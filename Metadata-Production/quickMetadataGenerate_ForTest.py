from tuf.libtuf import *

generate_and_write_rsa_keypair("/home/zeus/Desktop/quickstart/root", bits=3072, password="gogreen")
public_root_key = import_rsa_publickey_from_file("/home/zeus/Desktop/quickstart/root.pub")
private_root_key = import_rsa_privatekey_from_file("/home/zeus/Desktop/quickstart/root")

repository = create_new_repository("/home/zeus/Desktop/quickstart/repo")
repository.root.add_key(public_root_key)
repository.root.keys
repository.root.threshold = 1
repository.root.load_signing_key(private_root_key)

generate_and_write_rsa_keypair("/home/zeus/Desktop/quickstart/targets", password="gogreen")
generate_and_write_rsa_keypair("/home/zeus/Desktop/quickstart/release", password="gogreen")
generate_and_write_rsa_keypair("/home/zeus/Desktop/quickstart/timestamp", password="gogreen")

repository.targets.add_key(import_rsa_publickey_from_file("/home/zeus/Desktop/quickstart/targets.pub"))
repository.release.add_key(import_rsa_publickey_from_file("/home/zeus/Desktop/quickstart/release.pub"))
repository.timestamp.add_key(import_rsa_publickey_from_file("/home/zeus/Desktop/quickstart/timestamp.pub"))

private_targets_key = import_rsa_privatekey_from_file("/home/zeus/Desktop/quickstart/targets")

private_release_key = import_rsa_privatekey_from_file("/home/zeus/Desktop/quickstart/release")

private_timestamp_key = import_rsa_privatekey_from_file("/home/zeus/Desktop/quickstart/timestamp")

#list_of_targets = repository.get_filepaths_in_directory("/home/zeus/Desktop/quickstart/repo/targets/", recursive_walk=True, followlinks=True)

#repository.targets.compressions = ["gz"]
#repository.release.compressions = ["gz"]

#repository.targets.remove_target("/home/zeus/Desktop/quickstart/repo/targets/stable/0.21/update/v1/Tails/i386/updates.yml")
#repository.targets.remove_target("/home/zeus/Desktop/quickstart/repo/targets/stable/0.21/update/v1/Tails/i386/Tails_i386_0.21_to_0.22.iuk")

repository.targets.load_signing_key(private_targets_key)
repository.release.load_signing_key(private_release_key)
repository.timestamp.load_signing_key(private_timestamp_key)

repository.timestamp.expiration = "2014-10-28 12:08:00"
repository.release.expiration = "2014-10-28 12:08:00"
repository.targets.expiration = "2014-10-28 12:08:00"


generate_and_write_rsa_keypair("/home/zeus/Desktop/quickstart/stable", bits=3072, password="gogreen")
public_stable = import_rsa_publickey_from_file("/home/zeus/Desktop/quickstart/stable.pub")

generate_and_write_rsa_keypair("/home/zeus/Desktop/quickstart/beta", bits=3072, password="gogreen")
public_beta = import_rsa_publickey_from_file("/home/zeus/Desktop/quickstart/beta.pub")

generate_and_write_rsa_keypair("/home/zeus/Desktop/quickstart/nightly", bits=3072, password="gogreen")
public_nightly = import_rsa_publickey_from_file("/home/zeus/Desktop/quickstart/nightly.pub")

repository.targets.delegate("stable", [public_stable], [])
repository.targets.delegate("beta", [public_beta], [])
repository.targets.delegate("nightly", [public_nightly], [])

private_stable = import_rsa_privatekey_from_file("/home/zeus/Desktop/quickstart/stable")
repository.targets.stable.load_signing_key(private_stable)
private_beta = import_rsa_privatekey_from_file("/home/zeus/Desktop/quickstart/beta")
repository.targets.beta.load_signing_key(private_beta)
private_nightly = import_rsa_privatekey_from_file("/home/zeus/Desktop/quickstart/nightly")
repository.targets.nightly.load_signing_key(private_nightly)

repository.targets.stable.version = 2
repository.targets.beta.version = 2
repository.targets.nightly.version = 2

#repository.targets.stable.delegate("stable", [public_stable], [],restricted_paths=["/home/zeus/Desktop/quickstart/repo/targets/stable/"])
#repository.targets.stable.stable.load_signing_key(private_stable)
repository.targets.stable.add_target("/home/zeus/Desktop/quickstart/repo/targets/stable/0.21/update/v1/Tails/i386/updates.yml")
repository.targets.stable.add_target("/home/zeus/Desktop/quickstart/repo/targets/stable/0.21/update/v1/Tails/i386/Tails_i386_0.21_to_0.22.iuk")
#repository.targets.stable.stable.compressions = ["gz"]


#repository.targets.beta.delegate("beta", [public_beta], [],restricted_paths=["/home/zeus/Desktop/quickstart/repo/targets/beta/"])
#repository.targets.beta.beta.load_signing_key(private_beta)
#repository.targets.beta.beta.compressions = ["gz"]


#repository.targets.nightly.delegate("nightly", [public_nightly], [],restricted_paths=["/home/zeus/Desktop/quickstart/repo/targets/nightly/"])
#repository.targets.nightly.nightly.load_signing_key(private_nightly)
#repository.targets.nightly.nightly.compressions = ["gz"]
repository.write()
