#!bin/bash
######################################################################################
#Description: Copy all modified scripts to appropriate places
######################################################################################

#Do the copies for scripts
sudo cp Download.pm /usr/share/perl5/Tails/IUK/TargetFile/Download.pm
sudo cp download.py /usr/share/perl5/Tails/IUK/TargetFile/download.py
sudo cp tuf.interposition_target.json /usr/share/perl5/Tails/IUK/tuf.interposition_target.json
#Change permissions
sudo chmod 755 /usr/share/perl5/Tails/IUK/TargetFile/*
sudo chmod 755 /usr/share/perl5/Tails/IUK/tuf.interposition_target.json

