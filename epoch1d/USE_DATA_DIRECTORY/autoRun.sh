#!/bin/bash
#A script to automatically run and create plots for multiple values of parameters.

#Syntax summary

#counter=1
#while [ $counter -le 10 ]
#do
#   echo $counter
#   ((counter++))
#done
#echo Done and dusted

#times='01:00 02:00 03:00'
#for i in $times
#do
#  echo $i
#done
#echo Rock!

#for value in {1..5}
#do
#  echo $value
#done
#echo Once I saw a fish alive

#Define values to loop over intensities
maxIntensity=`echo "2*10^23" | bc` #W/cm2
minIntensity=`echo "1*10^22" | bc` #W/cm2
wavelength=`echo "1.06" | bc`      #um
intensityRange=5                   #Number of sampled intensities
densityRange=5                     #Number of sampled densities between critical
                                   #and relativistic critical density
nProc=4                            #Number of processors (for running EPOCH)

#Obtain intensity range
for ((i=0; i<intensityRange; i++))
do
  intensity=`echo "scale=9; ($maxIntensity-$minIntensity)*$i/($intensityRange-1)+$minIntensity" | bc`
  maxDensity=`echo "scale=9; 6.749*10^11*sqrt($intensity)/$wavelength" | bc` #cm^-3
  minDensity=`echo "scale=9; (1.116*10^21/$wavelength^2)" | bc`        #cm^-3
  for ((j=0; j<densityRange; j++))
  do
    #Take a density from an evenly spaced density range between minDensity and maxDensity
    density=`echo "scale=9; ($maxDensity-$minDensity)*$j/($densityRange-1)+$minDensity" | bc`
    newI=`printf "%.10e\n" $intensity`
    newD=`printf "%.10e\n" $density`

    #Update input.deck
    intensityLine=`grep 'intens = ' input.deck` #Need the full line to replace number
    sed "s/$intensityLine/  intens = $newI/" input.deck > temp.deck #Replace whole line, save to dummy
    mv temp.deck input.deck #Replace original with dummy
    densityLine=`grep 'nel = ' input.deck`
    sed "s/$densityLine/  nel = $newD/" input.deck > temp.deck #Replace whole line, save to dummy
    mv temp.deck input.deck

    #Run EPOCH
    directory=`pwd`
    cd ..
    (mpirun -np $nProc ./bin/epoch1d <<< $directory) >> $directory/report.out
    cd $directory

    #Run plotting function
    matlab -nodesktop -nosplash -r autoPlotter #generates output.png and output.fig
    intensityShort=`printf "%1.1e" $intensity`
    densityShort=`printf "%1.1e" $density`
    mv output.png plot-I$intensityShort-n$densityShort.png
    mv output.fig plot-I$intensityShort-n$densityShort.fig

    #Delete obsolete .sdf files
    rm *sdf
  done
done
