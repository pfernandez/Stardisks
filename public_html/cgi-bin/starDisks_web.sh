#!/bin/bash
# Called by web.up to generate star-disk and fixed star pages.

starDir=$1
scriptDir=$2
styleSheet=$3

	# get all parameters
V="${scriptDir}/./getValues $starDir"
nVec=`$V nVec`; qVec=`$V qVec`; mVec=`$V mVec`
jVec=`$V jVec`; MVec=`$V MVec`

header="<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\"><html><head><link rel=\"stylesheet\" type=\"text/css\" href=\"${styleSheet}\"/></head><body class=\"dataTable\">"

	# generate index page
echo -e "$header"  > $starDir/index.html.tmp
echo "Last update began $(date)." >> $starDir/index.html.tmp


##### Make data and image table code for the wiki; sort images into Dirs
for n in $nVec; do
	for q in $qVec; do
		for m in $mVec; do

			imagefiles="plotit plotit2 ee1 ee2m$m ee3 ee4 ee5 ee6 ee8 eqContour"
			nqmTitle=n${n}q${q}m${m}
			title=$starDir/${nqmTitle}
		
				# if any models for n_q_m combination, continue
			if [ -n "$(ls $starDir | grep $nqmTitle)" ]; then
				echo "Writing $nqmTitle..."
				
					# add links to index page
				echo "<a href=\"${nqmTitle}.html\"><h3>${nqmTitle}</h3></a>" >> $starDir/index.html.tmp
			
					# add main header to file
				echo -e "$header" > ${title}.html.tmp
				echo -e "<h1>${nqmTitle}</h1>" >> ${title}.html.tmp
				
				
					# Make data table code for web
				for M in $MVec; do
					rows="<h2>Star Mass ${M}</h2><table class=\"data\"><tr><td>T/|W|</td><td>R-/R+</td><td>jin</td><td>jmax</td><td>Y1</td><td>Y2</td><td>Rphi/ro</td><td>Q-/ro</td><td>Q+/ro</td><td>Rgamma/ro</td><td>Rilr/ro</td><td>lindoutAvg</td><td>Rco/ro</td><td>R+/ro</td><td>R-/ro</td><td>Rlambda/ro</td><td>p</td><td>sqrtTau</td><td>Mtorque/Md</td><td>Jtorque/J1</td><td>radstarMinus</td><td>radstar</td><td>radstarPlus</td></tr>"
					csv="T/|W|,R-/R+,jin,jmax,Y1,Y2,Rphi/ro,Q-/ro,Q+/ro,Rgamma/ro,Rilr/ro,lindoutAvg,Rco/ro,R+/ro,R-/ro,Rlambda/ro,p,sqrtTau,Mtorque/Md,Jtorque,radstarMinus,radstar,radstarPlus\n"
					isValid=$NULL
					for j in $jVec; do
						runName=n${n}q${q}m${m}M${M}j${j}
						Dir=${starDir}/$runName
						if [ -d $Dir ]; then
							val="$scriptDir/./getValues $Dir"
							isValid=true
							rows="$rows <tr><td>$($val TW)</td><td>$($val rInOut)</td><td>${j}</td><td>$($val jmax)</td><td>$($val Y1)</td><td>$($val Y2)</td><td>$($val rPhiR0)</td><td>$($val qMinusR0)</td><td>$($val qPlusR0)</td><td>$($val rGammaR0)</td><td>$($val RilrR0)</td><td>$($val lindoutAvg)</td><td>$($val RcoR0)</td><td>$($val rPlusR0)</td><td>$($val rMinusR0)</td><td>$($val rLambdaR0)</td><td>$($val p)</td><td>$($val sqrtTau)</td><td>$($val mTorqueMd)</td><td>$($val jTorqueJ1)</td><td>$($val radstarMinus)</td><td>$($val radstar)</td><td>$($val radstarPlus)</td></tr>"
							csv="$csv$($val TW),$($val rInOut),${j},$($val jmax),$($val Y1),$($val Y2),$($val rPhiR0),$($val qMinusR0),$($val qPlusR0),$($val rGammaR0),$($val RilrR0),$($val lindoutAvg),$($val RcoR0),$($val rPlusR0),$($val rMinusR0),$($val rLambdaR0),$($val p),$($val sqrtTau),$($val mTorqueMd),$($val jTorqueJ1),$($val radstarMinus),$($val radstar),$($val radstarPlus)\n"
							jmax=$($val jmax)  #for use with row headers below
						fi
					done
					if [ $isValid ]; then
						rows="$rows </table> <a href=\"${nqmTitle}M${M}.csv\" target=\"_blank\"><h3>.csv table</h3></a> </br></br></br>"
						echo -e $rows >> ${title}.html.tmp
						echo -e $csv > $starDir/${nqmTitle}M${M}.csv
					fi
				done
				
				
				##### Copy files and create image tables
				echo "<h2>Image Tables:</h2>" >> ${title}.html.tmp
				
				for i in $imagefiles; do
			
						# determine which columns should be in table
					newMVec=$NULL
					for M in $MVec; do
						if [ -n "$(ls $starDir | sed s/j.*// | grep -w n${n}q${q}m${m}M${M})" ]; then
							newMVec="$newMVec $M"
						fi
					done

						# if any columns, continue
					if [ "$newMVec" ]; then
					
							# get name of plot with greek symbols
						[ "$i" == "plotit" ] && tableName="<p class=\"formula\"><i>|&delta;&rho;|/&rho; </i>(<i>t</i>)</p>"
						[ "$i" == "plotit2" ] && tableName="<p class=\"formula\"><i>&delta;&rho; phase </i>(<i>t</i>)</p>"
						[ "$i" == "ee1" ] && tableName="<p class=\"formula\"><i>|&delta;&rho;|/&rho; </i>(<i>&piv;</i>)</p>"
						[ "$i" == "ee2m$m" ] && tableName="<p class=\"formula\"><i>&delta;&rho; phase </i>(<i>m</i>)</p>"
						[ "$i" == "ee3" ] && tableName="<p class=\"formula\"><i>torque</i></p>"
						[ "$i" == "ee4" ] && tableName="<p class=\"formula\"><i>work integrals</i></p>"
						[ "$i" == "ee5" ] && tableName="<p class=\"formula\"><i>stresses</i></p>"
						[ "$i" == "ee6" ] && tableName="<p class=\"formula\"><i>&delta;J</i></p>"
						[ "$i" == "ee8" ] && tableName="<p class=\"formula\"><i>stresses / E</i></p>"
						[ "$i" == "eqContour" ] && tableName="<p class=\"formula\"><i>eqContour</i></p>"

							# create link to title page
						echo "<a href=\"${nqmTitle}_${i}.html\">${tableName}</a>" >> ${title}.html.tmp

							# begin table page
						echo -e "$header"  > ${title}_${i}.html.tmp
						echo -e "<h1>${nqmTitle}</h1>" >> ${title}_${i}.html.tmp
						echo "<h2>${tableName}</h2><table class=\"image\">" >> ${title}_${i}.html.tmp
					
							# add column headers
						row="<tr><td></td>"
						for N in $newMVec; do
							row="$row <td>M${N}</td>"
						done
						row="$row </tr>"
						zeroCol="<tr><td></td><td>M0.0</td></tr>"
					
							# build image tables
						zeroColExists=$NULL
						zerosInTable=$NULL
						emptyZeros=$NULL
						for j in $jVec; do
						
								# check if any models in row, and if the only starmass is zero	
							validRow=$NULL
							MCheck=$NULL
							for N in $newMVec; do
								runName=n${n}q${q}m${m}M${N}j${j}
								Dir=$starDir/$runName
								if [ -d $Dir ]; then
									validRow=true
									MCheck="$MCheck $N" 
								fi
							done
							MCheck=$(echo $MCheck | sed 's/ /\n/' | sort -gu)
							
								# if the only starmass is zero, put in separate table
							if [ "$MCheck" = "0.0" ]; then
								runName=n${n}q${q}m${m}M0.0j${j}
								Dir=$starDir/$runName
								if [ -d $Dir ]; then
									iname=${runName}/${i}.png
									zeroCol="$zeroCol <tr><td>r-+$(echo "scale=2; ($j - 2)/($jmax - 2)" | bc)</td><td><a href=\"${iname}\" target=\"_blank\"/><img class=\"zeros\" src=\"${iname}\"/></td>"
									zeroColExists=true
								fi
								
								# else if valid folders in row, add row to table
							elif [ $validRow ]; then
							
									# add row header
								row="$row <tr><td>r-+$(echo "scale=2; ($j - 2)/($jmax - 2)" | bc)</td>"
				
									# for each possible model in row
								for N in $newMVec; do
									runName=n${n}q${q}m${m}M${N}j${j}
									Dir=$starDir/$runName
									
										# if folder exists and contains image, add to row and copy image to web
									if [ -d $Dir ]; then
										iname=${runName}/${i}.png
										row="$row <td><a href=\"${iname}\" target=\"_blank\"/><img class=\"imageTable\" src=\"${iname}\"/></td>"
										[ "$N" = "0.0" ] && zerosInTable=true
									else
										row="$row <td></td>"
										[ "$N" = "0.0" ] && emptyZeros=true
									fi
									
								done
															
									# end row
								row="$row </tr>"
							fi
						done

							# eliminate zero column from main table if empty
						if [ $emptyZeros ] && [ ! $zerosInTable ]; then
							row=$(echo $row | sed 's@<td>M0.0</td>@@;s@</td> <td></td>@@g')
						fi
						
							# write zeros-only table if necessary
						if [ $zeroColExists ]; then
							echo -e "<tr><td><table class=\"image\"> $zeroCol </td></table>" >> ${title}_${i}.html.tmp
						fi
						
							# write main table
						echo -e "<td><table class=\"image\"> $row </td></tr></table>" >> ${title}_${i}.html.tmp
					fi
					
						# end table page
					echo "</table></br></br></br>" >> ${title}_${i}.html.tmp
					echo "</body></html>" >> ${title}_${i}.html.tmp
					mv ${title}_${i}.html.tmp ${title}_${i}.html
				done
			
					# finish html code for page
				echo "</br></br></br></body></html>" >> ${title}.html.tmp
				mv ${title}.html.tmp ${title}.html
			fi

		done
	done
done

#
####################################################################################################
#

	# generate downloadable .mat variables
echo "Exporting Matlab data..."
matsDir="$starDir/mats"
mkdir -p $matsDir
excludeRunningModels=true
for run in $(ls $starDir); do
	runDir=$starDir/$run
	val="$scriptDir/./getValues $runDir"
	if [ -f $runDir/fort.50 ]; then
		newestFile=$(ls -t $runDir | head -1)
		if [ "$(unzip -l ${matsDir}.zip | grep $run)" ] && [ $(date -r $runDir/$newestFile +%s) -lt $(date -r ${matsDir}.zip +%s) ]; then
			# skip if model is already in zip archive, and older than last export
			echo "Skipping $run."
		elif [ "$excludeRunningModels" = "true" ] && [ $($val isRunning) ]; then
			echo "Omitting active model $run."
		
		else
				cd $runDir	
				j=${run##*j}
				M=${run%%j*}; M=${M##*M}
				m=${run%%M*}; m=${m##*m}
				q=${run%%m*}; q=${q##*q}
				n=${run%%q*}; n=${n##*n}
				echo -n "Exporting $run to Matlab..."
echo "
n          = $n;
q          = $q;
m          = $m;
starmass   = $M;
jin        = $j;
jmax       = $($val jmax);
rInOut     = $($val rInOut);
TW         = $($val TW);
Y1         = $($val Y1);
Y2         = $($val Y2);
RcoR0      = $($val RcoR0);
rPhiR0     = $($val rPhiR0); 
qMinusR0   = $($val qMinusR0);
qPlusR0    = $($val qPlusR0);
rGammaR0   = $($val rGammaR0);
RilrR0     = $($val RilrR0);
rPlusR0    = $($val rPlusR0);
rMinusR0   = $($val rMinusR0);
rLambdaR0  = $($val rLambdaR0);
mTorqueMd  = $($val mTorqueMd);
jTorqueJ1  = $($val jTorqueJ1);
jtotp      = $($val jtotp);
rhomax     = $($val rhomax);
MIRP       = $($val MIRP);
eta        = $($val eta);
p          = $($val p);
sqrtTau    = $($val sqrtTau);
tauzero    = $($val tauzero);
omegazero  = $($val omegazero);
jeansfreq  = $($val jeansfreq);
cfreqzero  = $($val cfreqzero);
keplerfreq = $($val keplerfreq);
lindoutAvg = $($val lindoutAvg);
radstarMinus = $($val radstarMinus);
radstar      = $($val radstar);
radstarPlus  = $($val radstarPlus);
save ${matsDir}/${run}.mat;
" | matlab -nodesktop -nosplash | tail -n +18
				echo "done."
		fi
	fi
done
zip -jmqru $matsDir $matsDir

	# finish index page
echo "<a href=\"mats.zip\" target=\"_blank\"><h3>Download Matlab variables</h3></a>" >> $starDir/index.html.tmp
echo "</html></body>" >> $starDir/index.html.tmp
mv $starDir/index.html.tmp $starDir/index.html
