#!bin/bash
############################################################################
#Author: Toan Nguyen
#Date: Nov 17, 2013
#Description: Automated script to install TUF and modified script in Tails
############################################################################
#Copy modified Perl scripts to their destionations
sudo cp ../Modified-IUK-scripts/RunningSystem.pm /usr/share/perl5/Tails/IUK/RunningSystem.pm
sudo cp ../Modified-IUK-scripts/UpdateDescriptionFile/Download.pm /usr/share/perl5/Tails/IUK/UpdateDescriptionFile/Download.pm 
sudo cp ../Modified-IUK-scripts/TargetFile/Download.pm /usr/share/perl5/Tails/IUK/TargetFile/Download.pm

