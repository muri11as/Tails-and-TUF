#!bin/bash
######################################################################################
#Description: Copy all modified scripts to appropriate places
######################################################################################
clear
#Do the copies for scripts
sudo cp ./UpdateDescriptionFile/* /usr/share/perl5/Tails/IUK/UpdateDescriptionFile
sudo cp ./TargetFile/* /usr/share/perl5/Tails/IUK/TargetFile
sudo cp Frontend.pm /usr/share/perl5/Tails/IUK/
#Do the copy for tuf-metadata
sudo cp -R tuf-metadata /usr/share/perl5/Tails/IUK/
sudo cp tuf.interposition_meta.json /usr/share/perl5/Tails/IUK/tuf.interposition_meta.json
sudo cp tuf.interposition_target.json /usr/share/perl5/Tails/IUK/tuf.interposition_target.json
#Change permissions
sudo chmod 755 /usr/share/perl5/Tails/IUK/tuf.interposition_meta.json
sudo chmod 755 /usr/share/perl5/Tails/IUK/tuf.interposition_target.json
sudo chmod -R 777 /usr/share/perl5/Tails/IUK/tuf-metadata
sudo chmod 755 /usr/share/perl5/Tails/IUK/UpdateDescriptionFile/download.py
sudo chmod 755 /usr/share/perl5/Tails/IUK/TargetFile/download.py
