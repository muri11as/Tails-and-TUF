#!bin/bash
############################################################################
#Author: Kevin Ngao
#Date: Nov 26, 2013
#Description: Use a bandwidth shaping tool (SpeedLimit on mac, NetLimiter on win)
#             to slow down the speeds on a Tails VM.
############################################################################
date
tails-iuk-get-target-file --uri http://www.toannv.com/tuf/targets/Tails_i386_0.21_to_0.22.iuk --hash-type sha256 --hash-value 277db6d7371d82241603f5f87d124c6087050703caa951b22c8f37ed6cf31037 --output-file tails.iuk --size 184320
date