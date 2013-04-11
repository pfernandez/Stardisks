#!/bin/bash
#
# Updates webpages at uoregon.edu/~/fernande, and backs up data to Dynamo at
# /data/shared_data/disks/stardisks/. Repeats every 12 hours.
#
# Run this script on the compute nodes with the following command:
# qsub -l nodes=1:ppn=1,walltime=20:00:00 -j oe -o web.out ./web.sh
#
# Run it as a cron job (preferred method) at noon and midnight each day by
# creating a crontab file using the following command:
#
# echo -e "PATH=$PATH\n00 00,12 * * * `pwd`/./web.sh &> `pwd`/web.out\n" > crontab.txt
#
# then schedule your job by entering:
#
# crontab crontab.txt
# 
# You can check it with:  crontab -l
# and delete it with:  crontab -r


usernames="khadley"
modeltypes="stardisks fixedStar 1024Converge koji"

copyfiles="plotit.png plotit2.png ee1.png ee2m*.png ee3.png ee4.png ee5.png ee6.png ee8.png eqContour.png fact polyout fort.50 torus.out" # also set imagefiles below
webDir="/home1/fernande/public_html" # must be absolute path on server
scriptDir="$webDir/cgi-bin"
styleSheet="http://pages.uoregon.edu/fernande/cgi-bin/stardisks.css"
#backupDir="PaulFernandez@dynamo.uoregon.edu:~/shared_data/disks"
backupDir="PaulFernandez@dynamo.uoregon.edu:~/group_data/NASdata/disks"

#
####################################################################################################
# Update completed runs, remove old files and generate plots for running models


runningDir="$webDir/running"
runningFile="$webDir/running.html"
exclusions="$webDir/exclusions"

echo "Update begun $(date)"
rm -rf $webDir/temp_running
mkdir -p $webDir/temp_running 



for userName in $usernames; do


	> $exclusions
	echo output.txt >> $exclusions

	# copy files and create plots for current models page
	for run in `qselect`; do
		jobOwner=$(echo `qstat -f $run | grep Job_Owner | sed s/Job_Owner\ =\ // | sed s/@.*//`)
		validUser=$NULL
		for u in $userName; do [ "$jobOwner" = "$u" ] && validUser=true; done
		if [ $validUser ]; then
			path1=`qstat -f $run | grep Output_Path | sed s/.*://`
			path2=`qstat -f $run | grep -A 1 Output_Path | tail -n 1`
			path=`echo $path1$path2 | sed s/\ // | sed s@/output.txt@@`
			if [ -n "$(echo $path | grep -v web.)" ]; then
				echo "$path running"
				dir=`basename $path`
				echo "$dir/" >> $exclusions
				if [ -f $path/fort.50 ]; then
					if [ -f $path/fort.23a ]; then
						cp $path/fort.23a $webDir/temp
						cat $path/fort.23 >> $webDir/temp
					elif [ -f $path/fort.23 ]; then
						cp $path/fort.23 $webDir/temp
					fi
					if [ -f $webDir/temp ]; then
						echo -e "
						reset\n
						set terminal png\n
						set output \"${webDir}/temp_running/${jobOwner}_${dir}.png\"\n
						set title \"${dir}\"\n
						set logscale y\n
						set autoscale\n
						plot '$webDir/temp' using 1:2 with lines ti \"Perturbed density amplitude\",\
							 '$webDir/temp' using 1:4 with lines notitle,\
							 '$webDir/temp' using 1:6 with lines notitle\n
						" | gnuplot
					fi
					rm -f $webDir/temp
				fi
			fi
		fi
	done


	for modelType in $modeltypes; do
	
	
modelsDir=/scratch-hpc/${userName}/${modelType}/Models	
starDir="$webDir/${modelType}"
mkdir -p $starDir

echo -e "\n\n$modelsDir : $starDir\n\n"


#if [ ]; then # BEGIN COMMENTBLOCK  
for dir in `ls $modelsDir`; do
	if [ -d $modelsDir/$dir ] && [ -f $modelsDir/$dir/fort.50 ]; then
		mkdir -p $starDir/$dir
		echo $starDir/$dir/output.txt >> $exclusions
	else
		echo "$modelsDir/$dir" >> $exclusions
	fi
done

	# backup data to remote server
echo "Updating Dynamo archive..."
rsync -ru --exclude-from=$exclusions $modelsDir/* ${backupDir}/${modelType}/


for dir in $(ls $modelsDir); do
	for i in $copyfiles; do
		if  [ -f $modelsDir/$dir/fort.50 ] && [ -f $modelsDir/$dir/$i ]; then
			cp -u $modelsDir/$dir/$i $starDir/$dir/
		fi
	done
done
#fi # END COMMENTBLOCK


	done
	rm $exclusions
done

#
####################################################################################################
# generate web pages


#### currently running models

echo -e "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">" > $webDir/running.html.tmp
echo -e "<html><head><link rel=\"stylesheet\" type=\"text/css\" href=\"${styleSheet}\"/></head><body>" >> $webDir/running.html.tmp
echo -e "<h1>Currently Running Models</h1>Last update began $(date).<table class=\"image\">" >> $webDir/running.html.tmp
count=0
for img in $(ls $webDir/temp_running); do
	if [ "$(echo $img | tail -c 5)" = ".png" ]; then
		if [ $count = 4 ]; then
			echo -e "<tr> $runningRow </tr>" >> $webDir/running.html.tmp
			count=0
			runningRow=$NULL
		fi
		runningRow="$runningRow <td><a href=\"running/${img}\"/><img class=\"running\" src=\"running/${img}\"/><br/>$(echo $img | sed s/.png//)</td>" >> $webDir/running.html.tmp
		count=$((count + 1))
	fi
done
if [ -n "$runningRow" ]; then
	echo -e "<tr> $runningRow </tr>" >> $webDir/running.html.tmp
fi
echo "</table></body></html>" >> $webDir/running.html.tmp

rm -rf $runningDir
mv $webDir/temp_running $runningDir
mv $webDir/running.html.tmp $runningFile
rm -rf $webDir/temp_running

#if [ ]; then # BEGIN COMMENTBLOCK
#### table pages

for modelType in $modeltypes; do

	starDir="$webDir/${modelType}"
	if [ "$modelType" = "stardisks" ] || [ "$modelType" = "fixedStar" ] || [ "$modelType" = "1024Converge" ]; then
		${scriptDir}/./starDisks_web.sh $starDir $scriptDir $styleSheet
	elif [ "$modelType" = "koji" ]; then
		${scriptDir}/./koji_web.sh $starDir $scriptDir $styleSheet
	fi
done

echo "Update completed $(date)"



#fi # END COMMENTBLOCK
