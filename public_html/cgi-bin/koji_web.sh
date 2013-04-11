#!/bin/bash
# Called by web.up to generate Kojima pages.

starDir=$1
scriptDir=$2

# get all parameters
V="${scriptDir}/./getKojiValues $starDir"
nVec=`$V nVec`; kVec=`$V kVec`; mVec=`$V mVec`; rVec=`$V rVec`;


# generate index page
echo "<html><body>Last update began $(date)." > $starDir/index.html.tmp


##### Make data and image table code for the wiki; sort images into Dirs
for n in $nVec; do
	for k in $kVec; do
		for m in $mVec; do

			imagefiles="plotit plotit2 ee1 ee2m$m ee4 ee5 ee6 ee8 eqContour"
			nkmTitle=n${n}k${k}m${m}
			title=$starDir/${nkmTitle}

			# if any models for n_k_m combination, continue
			if [ -n "$(ls $starDir | grep $nkmTitle)" ]; then
				echo "Writing $nkmTitle..."
				
				# add links to index page
				echo "<a href=\"${nkmTitle}.html\"><h3>${nkmTitle}</h3></a>" >> $starDir/index.html.tmp
			
				# add main header to file
				header="<html><body><h1>${nkmTitle}</h1>"
				echo -e "$header" > ${title}.html.tmp
				
				
				# Make data table code for web
				rows="<table border=\"1\" cellspacing=\"0\" bgcolor=\"EDEDED\"><tr><td><h3>T/|W|</h3></td><td><h3>R-/R+</h3></td><td><h3>jin</h3></td><td><h3>jmax</h3></td><td><h3>Y1</h3></td><td><h3>Y2</h3></td><td><h3>Rphi/ro</h3></td><td><h3>Rilr/ro</h3></td><td><h3>lindoutAvg</h3></td><td><h3>Rco/ro</h3></td><td><h3>R+/ro</h3></td><td><h3>R-/ro</h3></td><td><h3>Star Mass</h3></td></tr>"
				csv="T/|W|,R-/R+,jin,jmax,Y1,Y2,Rphi/ro,Rilr/ro,lindoutAvg,Rco/ro,R+/ro,R-/ro,Star Mass\n"
				isValid=$NULL
				for Dir in $(ls -d ${starDir}/${nkmTitle}*); do			
					if [ -f "${Dir}/fort.50" ]; then
						val="$scriptDir/./getKojiValues $Dir"
						isValid=true
						rows="$rows <tr><td>$($val TW)</td><td>$($val rInOut)</td><td>$($val jin)</td><td>$($val jmax)</td><td>$($val Y1)</td><td>$($val Y2)</td><td>$($val rPhiR0)</td><td>$($val RilrR0)</td><td>$($val lindoutAvg)</td><td>$($val RcoR0)</td><td>$($val rPlusR0)</td><td>$($val rMinusR0)</td><td>$($val starMass)</td></tr>"
						csv="$csv$($val TW),$($val rInOut),$($val jin),$($val jmax),$($val Y1),$($val Y2),$($val rPhiR0),$($val RilrR0),$($val lindoutAvg),$($val RcoR0),$($val rPlusR0),$($val rMinusR0),$($val starMass)\n"
						jmax=$($val jmax)  #for use with row headers below
					fi
				done
				if [ $isValid ]; then
					rows="$rows </table> <a href=\"${nkmTitle}.csv\" target=\"_blank\"><h3>.csv table</h3></a> </br></br>"
					echo -e $rows >> ${title}.html.tmp
					echo -e $csv > $starDir/${nkmTitle}.csv
				fi
				
				

				##### Copy files and create image tables						
			
				# create link to title page
				echo "<a href=\"${nkmTitle}_imageTable.html\"><h2>Image Table</h2></a>" >> ${title}.html.tmp
			
				# begin table page
				echo -e "<html><body><h1>${nkmTitle}</h1>" > ${title}_imageTable.html.tmp
				echo "<table cellpadding=\"50\" border=\"1\" cellspacing=\"0\" bgcolor=\"Silver\">" >> ${title}_imageTable.html.tmp

				# add column headers
				row="<tr><td></td>"
				for i in $imagefiles; do

					# get name of plot with greek symbols
					[ "$i" == "plotit" ] && tableName="<h3><i>|&delta;&rho;|/&rho; </i>(<i>t</i>)</h3>"
					[ "$i" == "plotit2" ] && tableName="<h3><i>&delta;&rho; phase </i>(<i>t</i>)</h3>"
					[ "$i" == "ee1" ] && tableName="<h3><i>|&delta;&rho;|/&rho; </i>(<i>&piv;</i>)</h3>"
					[ "$i" == "ee2m$m" ] && tableName="<h3><i>&delta;&rho; phase </i>(<i>m</i>)</h3>"
					[ "$i" == "ee3" ] && tableName="<h3><i>torque</i></h3>"
					[ "$i" == "ee4" ] && tableName="<h3><i>work integrals</i></h3>"
					[ "$i" == "ee5" ] && tableName="<h3><i>stresses</i></h3>"
					[ "$i" == "ee6" ] && tableName="<h3><i>&delta;J</i></h3>"
					[ "$i" == "ee8" ] && tableName="<h3><i>stresses / E</i></h3>"
					[ "$i" == "eqContour" ] && tableName="<h3><i>eqContour</i></h3>"

					row="$row <td  valign=\"bottom\"><center>${tableName}</center></td>"
				done
				row="$row </tr>"
			
				# build image tables
				for r in $rVec; do
					runName=n${n}k${k}m${m}r${r}_512
					Dir=$starDir/$runName
					
					if [ -d $Dir ]; then
					
						# add row header
						row="$row <tr><td><center><h3>r-/ro $r</h3></center></td>"
	
						# for each image in row
						for i in $imagefiles; do
					
							# add image to row
							iname=${runName}/${i}.png
							row="$row <td bgcolor=\"White\"><a href=\"${iname}\" target=\"_blank\"/><img src=\"${iname}\" width=\"125\"/></td>"
						done
						
						# end row
						row="$row </tr>"
					fi
				done

				# write main table
				echo -e "<td valign=\"top\"><table border=\"0\" cellpadding=\"0\" cellspacing=\10\"> $row </td></tr></table>" >> ${title}_imageTable.html.tmp
			
				# end table page
				echo "</table></br></br></br></body></html>" >> ${title}_imageTable.html.tmp
				mv ${title}_imageTable.html.tmp ${title}_imageTable.html

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
	val="$scriptDir/./getKojiValues $runDir"
	if [ -f $runDir/fort.50 ]; then
		newestFile=$(ls -t $runDir | head -1)
		if [ "$(unzip -l ${matsDir}.zip | grep $run)" ] && [ $(date -r $runDir/$newestFile +%s) -lt $(date -r ${matsDir}.zip +%s) ]; then
			# skip if model is already in zip archive, and older than last export
			echo "Skipping $run."
		elif [ "$excludeRunningModels" = "true" ] && [ $($val isRunning) ]; then
			echo "Omitting active model $run."
		
		else
				cd $runDir	
				m=${run%%r*}; m=${m##*m}
				k=${run%%m*}; k=${k##*k}
				n=${run%%k*}; n=${n##*n}
				q=$(echo "scale=4; $k/100" | bc)
				echo -n "Exporting $run to Matlab..."
echo "
n          = $n;
k          = $k;
q		   = $q;
m          = $m;
starmass   = $($val starMass);
jin        = $($val jin);
jmax       = $($val jmax);
rInOut     = $($val rInOut);
TW         = $($val TW);
Y1         = $($val Y1);
Y2         = $($val Y2);
RcoR0      = $($val RcoR0);
rPhiR0     = $($val rPhiR0);
RilrR0     = $($val RilrR0);
rPlusR0    = $($val rPlusR0);
rMinusR0   = $($val rMinusR0);
rhomax     = $($val rhomax);
lindoutAvg = $($val lindoutAvg);
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

#if [ ]; then # BEGIN COMMENTBLOCK	fi	#END COMMENTBLOCK
