#!/bin/bash
#
# Begin a model from step 0 on compute nodes.
# $1 = model name.

run=$1
maxSteps=50000

# strip params from name
j=${run##*j}
M=${run%%j*}; M=${M##*M}
m=${run%%M*}; m=${m##*m}
q=${run%%m*}; q=${q##*q}
n=${run%%q*}; n=${n##*n}


echo "j=$j M=$M m=$m q=$q n=$n maxSteps=$maxSteps" >> fromStep.list