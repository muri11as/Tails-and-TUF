**Creating TUF Metadata**
========================================================================================================================

TUF Metadata for Tails has been created with three delegated roles in mind.
* Stable
* Beta
* Nightly

The stable channel is currently the only one being implemented in Tails, so we have placed our focus on that channel.
We have, however, implemented the other two delegated roles in anticipation of these future channels.

## First time Metadata Generation
	
###1. Download the TUF Repository Tools

To create a new repository, you will need to generate all the initial metadata files.  Enter the following shell commands to download the TUF Repository Tools.

```shell
virtualenv --no-site-packages (Pick a name)
source (Name you picked)/bin/activate
pip install --upgrade https://github.com/theupdateframework/tuf/archive/repository-tools.zip
```

Source: https://docs.google.com/document/d/1n-4G8cfuGMCBwXDgkj52DuBhRG5Di6YW9p8IaH-fIxc/edit?pli=1#

###2. Clone this repository and navigate to the Metadata-Production folder

You may skip this step if you have already cloned this repo.  Otherwise enter the following command in a shell.

```shell
git clone https://github.com/muri11as/Tails-and-TUF
```

###3. Edit the configuration files

Inside the Config Files (or current if did step 4 first) directory, open the following configuration files, and make the changes according to your environment.

* setupconfig.txt
* keyconfig.txt
* repoconfig.txt
* targetconfig.txt

You may do step 4 first, then move on to this step if you do not want to keep a fresh copy of the configuration files.  The configuration files should be self explanatory, however, more details on each configuration file and its associated variables is available in the wiki.

###4. Copy the configuration files to the Metadata-Production directory

This will copy all the configuration files in the Config Files directory to the Metadata-Production directory (one level up)

```shell
sh copyfiles.sh
```

###5. Run the setup

In a terminal run the following command to begin generating the initial metadata for your TUF repository.  The metadata will be generated in the location specified in the setupconfig.txt.  If for any reason your configuration files is stored elsewhere, be sure to change setupconfig.txt to whereever it is stored in.

```shell
python setup.py setupconfig.txt
```

## Modify Existing Repository Metadata

When you have already generated a repository, you will need to update it whenever there is a new release.  The following will walk you through on how to modify an existing repository's metadata depending on what you wish to do.  Again, all configuration files should be stored on the current directory, but configuration files stored elsewhere are also supported as long as you specify the correct path.

### Generate a new key
-------

#### 1. Modify the keyconfig.txt file

If you did steps 3/4 above, you will need to modify the keyconfig.txt file according to your setup.  More details can be found on the wiki.

#### 2. Generate the key.

```shell
python generateKeystore.py path/to/keyconfig.txt
```

### Generate a new repository
-------

#### 1. Modify the repoconfig.txt file

If you did steps 3/4 above, you will need to modify the repoconfig.txt file according to your setup.  More details can be found on the wiki.  The repoconfig.txt will require you to enter a root key.  Remember to store your Root Private Key(s) OFFLINE.

#### 2. Generate the repository.

```shell
python generateMetadata.py path/to/repoconfig.txt
```

### Copy the repository to a "live" folder
-------

#### 1. Modify the copyconfig.txt file

If you did steps 3/4 above, you will need to modify the copyconfig.txt file according to your setup.  More details can be found on the wiki.

#### 2. Copy the repository.

This is used to create a final copy of your metadata and you can then upload to your TUF server.

```shell
python copyToRepository.py path/to/copyconfig.txt
```

### Create a delegation
-------

#### 1. Modify the delconfig.txt file

If you did steps 3/4 above, you will need to modify the delconfig.txt file according to your setup.  More details can be found on the wiki.

#### 2. Add a delegation repository.

This is used to create a new delegated role for your TUF Metadata.

```shell
python addDelegation.py path/to/delconfig.txt
```

### Adding Files
-------

The metadata needs to be updated in the event a new file is added.  You will need to regenerate the metadata file when this happens.

### 1. Navigate to the Target File Modification directory and modify swapconfig.txt and swaptargetconfig.txt.

You will need to modify the delconfig.txt file according to your setup.  The option to specify the specific delegation/channel is available in the configuration files.  More details on them can be found on the wiki.

### 2. Generate the new metadata for the new target files

This will effectively add new target files to the TUF metadata for the specified channel you inputed. This script calls removeTarg.py and the script to add target files to whatever channel (delegated role) you picked.

```shell
python editTargs.py path/to/swapconfig.txt
```

======

Notes:
TUF Metadata is relatively small and efficient. It contains our updates.yml (Update Description File) as a target, as well as the
Target files (either IUK, or full ISO) and the URL's from where they can be downloaded. 
