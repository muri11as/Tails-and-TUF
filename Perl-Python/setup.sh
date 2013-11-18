#!bin/bash
######################################################################################
#Description: Copy all modified scripts to appropriate places
######################################################################################
clear
#Do the copies for scripts
sudo cp ./UpdateDescriptionFile/* /usr/share/perl5/Tails/IUK/UpdateDescriptionFile
sudo cp ./TargetFile/* /usr/share/perl5/Tails/IUK/TargetFile
#Do the copy for tuf-metadata
sudo cp -R tuf-metadata /usr/share/perl5/Tails/IUK/
sudo cp tuf.interposition.json /usr/share/perl5/Tails/IUK/tuf.interposition.json
#Create tuf.log
touch /usr/share/perl5/Tails/IUK/tuf.log
#Change permissions
sudo chmod 777 /usr/share/perl5/Tails/IUK/tuf.log
sudo chmod 755 /usr/share/perl5/Tails/IUK/tuf.interposition.json
sudo chmod -R 777 /usr/share/perl5/Tails/IUK/tuf-metadata
sudo chmod 755 /usr/share/perl5/Tails/IUK/UpdateDescriptionFile/download.py
#sudo chmod 755 /usr/share/perl5/Tails/IUK/TargetFile/download.py
