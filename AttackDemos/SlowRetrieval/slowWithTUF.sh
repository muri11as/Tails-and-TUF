#!bin/bash
############################################################################
#Author: Kevin Ngao
#Date: Nov 26, 2013
#Description: Use a bandwidth shaping tool (SpeedLimit on mac, NetLimiter on win)
#             to slow down the speeds on a Tails VM.
############################################################################
START=$(date +%s)
tails-iuk-get-target-file --uri http://dl.amnesia.boum.org/Tails_i386_0.21_to_0.22.iuk --hash-type sha256 --hash-value fc14986953d085d1240905bf64d511b5bf21491d795912bb5ebd5ef779850bb1 --output-file Tails_i386_0.21_to_0.22.iuk --size 18341264
echo "Tails_i386_0.21_to_0.22.iuk, should've been downloaded into the temporary directory"
END=$(date +%s)
DIFF=$(( $END - $START ))
echo "Operation completed in $DIFF seconds"