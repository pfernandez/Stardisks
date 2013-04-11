#!/bin/bash
#
# Updates webpage at uoregon.edu/~/fernande, and backs up data to Dynamo at
# /data/shared_data/disks/eq_stardisks/. Repeats every 12 hours.


userNames="fernande"
copyfiles="eqContour.png fact polyout" # also set imagefiles below
scriptDir="/home1/fernande/public_html/cgi-bin"
webDir="/home1/fernande/public_html"
starDir="$webDir/eq_stardisks"
matsDir="$starDir/eq_mats"
zipTitle="eq_mats.zip"
exclusions="$(pwd)/exclusions"
mkdir -p $matsDir $starDir


####################################################################################################
# Update completed runs, remove old files and generate plots for running models

# ssh PaulFernandez@dynamo.uoregon.edu "mkdir -p ~/shared_data/disks/eq_stardisks"

for user in $userNames; do
	modelsDir=/scratch-hpc/$user/disk/eqModels
	for dir in `ls $modelsDir`; do
		if [ -f $modelsDir/$dir ] || [ ! -f $modelsDir/$dir/output.txt ]; then
			echo "$modelsDir/$dir" >> $exclusions
			echo "$dir" >> $exclusions
		fi
	done
	echo "$modelsDir" >> $exclusions
	
		# copy new files to login
	cd $modelsDir
	for i in $copyfiles; do
		rsync -Rru --exclude-from=$exclusions */$i $starDir/
	done
done

if [ ]; then #BEGIN COMMENTBLOCK
####################################################################################################
# generate web pages

	# get all parameters
nVec=1.5
qVec="1.0 1.5 1.75 2.0"
for folder in `ls $starDir`; do
	if [ -f $starDir/$folder/polyout ]; then
		j=${folder##*j}; jVec="$jVec $j"
		M=${folder%%j*}; M=${M##*M}; MVec="$MVec $M"
	fi
done
jVec=`echo $jVec | sed 's/ /\n/g' | sort -gu`
MVec=`echo $MVec | sed 's/ /\n/g' | sort -gu`
jmax=512

	# generate index page
echo "<html><body>" > $starDir/index.html


##### Make data and image table code for the wiki; sort images into Dirs
for n in $nVec; do
	for q in $qVec; do

		imagefiles="eqContour"
		nqmTitle=n${n}q${q}
		title=$starDir/${nqmTitle}.html
		
			# if any models for n_q_m combination, continue
		if [ -n "$(ls $starDir | grep $nqmTitle)" ]; then
			echo "Writing $nqmTitle..."
			
				# add links to index page
			echo "<a href=\"${nqmTitle}.html\"><h3>${nqmTitle}</h3></a>" >> $starDir/index.html
		
				# add main header to file
			header="<html><body><h1>${nqmTitle}</h1>"
			echo -e "$header" > $title
			
			
				# Make data table code for web
			for M in $MVec; do
				rows="<h2>Star Mass ${M}</h2><table border=\"1\" cellspacing=\"0\" bgcolor=\"EDEDED\"><tr><td><h3>T/|W|</h3></td><td><h3>R-/R+</h3></td><td><h3>jin</h3></td><td><h3>jmax</h3></td><td><h3>Q-/ro</h3></td><td><h3>Q+/ro</h3></td><td><h3>R+/ro</h3></td><td><h3>R-/ro</h3></td><td><h3>Rlambda/ro</h3></td><td><h3>p</h3></td><td><h3>sqrtTau</h3></td><td><h3>virialError</h3></td><td><h3>mass</h3></td><td><h3>1 - r-/r0</h3></td><td><h3>r0</h3></td><td><h3>omegaMax</h3></td><td><h3>etot</h3></td><td><h3>tjeans</h3></td><td><h3>tsound</h3></td></tr>"
				csv="T/|W|,R-/R+,jin,jmax,Q-/ro,Q+/ro,R+/ro,R-/ro,Rlambda/ro,p,sqrtTau,virialError,mass,1 - r-/r0,r0,omegaMax,etot,tjeans,tsound\n"
				isValid=$NULL
				count=0
				for j in $jVec; do
					runName=eq_n${n}q${q}M${M}j${j}
					Dir=${starDir}/$runName
					if [ -d $Dir ]; then
						val="$scriptDir/./getValues $Dir"
						isValid=true
						rows="$rows <tr><td>$($val TW)</td><td>$($val rInOut)</td><td>${j}</td><td>$($val jmax)</td><td>$($val qMinusR0)</td><td>$($val qPlusR0)</td><td>$($val rPlusR0)</td><td>$($val rMinusR0)</td><td>$($val rLambdaR0)</td><td>$($val p)</td><td>$($val sqrtTau)</td><td>$($val virialError)</td><td>$($val mass)</td><td>$($val oneMinusRInR0)</td><td>$($val r0)</td><td>$($val omegaMax)</td><td>$($val etot)</td><td>$($val tjeans)</td><td>$($val tsound)</td></tr>"
						[ $count -eq 0 ] && csv="$csv$($val TW),$($val rInOut),${j},$($val jmax),$($val qMinusR0),$($val qPlusR0),$($val rPlusR0),$($val rMinusR0),$($val rLambdaR0),$($val p),$($val sqrtTau),$($val virialError),$($val mass),$($val oneMinusRInR0),$($val r0),$($val omegaMax),$($val etot),$($val tjeans),$($val tsound)\n"
						count=$(($count + 1))
						[ $count -ge 5 ] && count=0
					fi
					
				done
				if [ $isValid ]; then
					rows="$rows </table> <a href=\"eq_${nqmTitle}M${M}.csv\" target=\"_blank\"><h3>Sparse .csv table</h3></a> </br></br></br>"
					echo -e $rows >> $title
					echo -e $csv > $starDir/eq_${nqmTitle}M${M}.csv
				fi
			done
			
				# finish html code for page
			echo "</body></html>" >> $title
		fi
	done
done

#
####################################################################################################
fi #END COMMENTBLOCK

	# generate downloadable .mat variables
echo "Exporting Matlab data..."
excludeRunningModels=true

for run in $(ls $starDir); do
	runDir=$starDir/$run
	val="$scriptDir/./getValues $runDir"
	if [ -d $runDir ] && [ -n "$(echo `ls $runDir` | grep polyout)" ]; then
		cd $runDir	
		j=${run##*j}
		M=${run%%j*}; M=${M##*M}
		q=${run%%M*}; q=${q##*q}
		n=1.5
		echo -n "Exporting $run to Matlab..."
echo "
n             = $n;
q             = $q;
starmass      = $M;
jin           = $j;
jmax          = $($val jmax);
rInOut        = $($val rInOut);
TW            = $($val TW);
qMinusR0      = $($val qMinusR0);
qPlusR0       = $($val qPlusR0);
rPlusR0       = $($val rPlusR0);
rMinusR0      = $($val rMinusR0);
rLambdaR0     = $($val rLambdaR0);
jtotp         = $($val jtotp);
rhomax        = $($val rhomax);
MIRP          = $($val MIRP);
eta           = $($val eta);
p             = $($val p);
sqrtTau       = $($val sqrtTau);
tauzero       = $($val tauzero);
omegazero     = $($val omegazero);
jeansfreq     = $($val jeansfreq);
cfreqzero     = $($val cfreqzero);
keplerfreq    = $($val keplerfreq);
virialError   = $($val virialError);
mass          = $($val mass);
oneMinusRInR0 = $($val oneMinusRInR0);
r0            = $($val r0);
omegaMax      = $($val omegaMax);
etot          = $($val etot);
tjeans        = $($val tjeans);
tsound        = $($val tsound);
save ${matsDir}/${run}.mat;
" | matlab -nodesktop -nosplash | tail -n +15
		echo "done."
	fi
done
zip -jmqru $matsDir $matsDir

	# finish index page
echo "<a href=\"${zipTitle}\" target=\"_blank\"><h3>Download Matlab equilibrium variables</h3></a>" >> $starDir/index.html
echo "</html></body>" >> $starDir/index.html

#
####################################################################################################
#

	# backup data to remote server
echo "Updating Dynamo archive..."
rsync -ru --exclude-from=$exclusions $starDir/* PaulFernandez@dynamo.uoregon.edu:~/shared_data/disks/eq_stardisks/
rm $exclusions

#
####################################################################################################
# pause and restart

#sleep 12h
#cd ~/
#qsub -l nodes=1:ppn=1,walltime=20:00:00 -j oe -o eq.out ./eq.up
