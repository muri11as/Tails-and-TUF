#!bin/bash
############################################################################
#Author: Toan Nguyen
#Date: Nov 17, 2013
#Description: Automated script to install TUF and modified script in Tails
############################################################################
#Extract TUF Binary and install it
mkdir tufbinary
tar -xf tuf-binary-installation.tar.gz --directory ./tufbinary
cd tufbinary
sudo sh setup.sh
cd ..
#Extract modified scripts and copy to destination
echo Copying scripts...
tar -xf Perl-Python.tar.gz
cd Perl-Python
sudo sh setup.sh
