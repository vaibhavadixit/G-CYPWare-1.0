
cwd=$(pwd)

export $(xargs <$1)


> $dirpath/$oxddir/$protein-$uniquename-vertEs.txt
> $dirpath/$oxddir/AvgDE_$oxddir.txt
> $dirpath/$oxddir/AvgStdDE_$oxddir.txt
> $dirpath/$oxddir/AvgDEprot_$oxddir.txt
> $dirpath/$oxddir/AvgStdDEprot_$oxddir.txt
> $dirpath/$reddir/$protein-vertEs.txt
> $dirpath/$reddir/AvgDE_$reddir.txt
> $dirpath/$reddir/AvgStdDE_$reddir.txt
> $dirpath/$reddir/AvgDEprot_$reddir.txt
> $dirpath/$reddir/AvgStdDEprot_$reddir.txt

calverE () {

        cd $dirpath/$1
        sto1D=$(grep -A1 NSTEP $dirpath/$1/$protein-solv-$3.out | grep -v NSTEP | sed '/--/d' | awk '{print $2}' | st |  awk '{print $1, $5, $6}' | tail -n+2 | head -1)
        sto2D=$(grep -A1 NSTEP $dirpath/$1/$protein-solv-$4.out | grep -v NSTEP | sed '/--/d' | awk '{print $2}' | st |  awk '{print $1, $5, $6}' | tail -n+2 | head -1)

        pto1D=$(grep -A1 NSTEP $dirpath/$1/$protein-prot-$3.out | grep -v NSTEP | sed '/--/d' | awk '{print $2}' | st |  awk '{print $1, $5, $6}' | tail -n+2 | head -1)
        pto2D=$(grep -A1 NSTEP $dirpath/$1/$protein-prot-$4.out | grep -v NSTEP | sed '/--/d' | awk '{print $2}' | st |  awk '{print $1, $5, $6}' | tail -n+2 | head -1)

        echo "$sto1D $sto2D $pto1D $pto2D $5" >> $dirpath/$1/$protein-vertEs.txt
	echo "print sto1D $sto1D sto2D $sto2D pto1d $pto1D pto2d $pto2D for $1 and $5"
        sto1E=$(cat $dirpath/$1/$protein-vertEs.txt | awk '{print $2}' | tail -1)
        stdev1E=$(cat $dirpath/$1/$protein-vertEs.txt | awk '{print $3}' | tail -1)
        sto2E=$(cat $dirpath/$1/$protein-vertEs.txt | awk '{print $5}' | tail -1)
        stdev2E=$(cat $dirpath/$1/$protein-vertEs.txt | awk '{print $6}' | tail -1)

	pto1E=$(cat $dirpath/$1/$protein-vertEs.txt | awk '{print $8}' | tail -1)
	ptdev1E=$(cat $dirpath/$1/$protein-vertEs.txt | awk '{print $9}' | tail -1)
	pto2E=$(cat $dirpath/$1/$protein-vertEs.txt | awk '{print $11}' | tail -1)
	ptdev2E=$(cat $dirpath/$1/$protein-vertEs.txt | awk '{print $12}' | tail -1)

	AvgDE=$(bc -l <<< "scale=6; ( ($sto1E - $sto2E) * 0.043 )" | xargs printf "%6.6f")
	echo "AvgDE $AvgDE $5" >> $dirpath/$1/AvgDE_$1.txt
	echo "AvgDE $AvgDE for $1 and $5"
	AvgStdDE=$(bc -l <<< "scale=6; ( ($stdev1E - $stdev2E) * 0.043 )" | xargs printf "%4.6f")
	echo "AvgStdDE $AvgStdDE $5" >> $dirpath/$1/AvgStdDE_$1.txt
	echo "AvgStdDE $AvgStdDE for $1 and $5"

	AvgDEprot=$(bc -l <<< "scale=6; ( ($pto1E - $pto2E) * 0.043 )" | xargs printf "%6.6f")
	echo "AvgDEprot $AvgDEprot $5">> $dirpath/$1/AvgDEprot_$1.txt
	echo "AvgDEprot $AvgDEprot for $1 and $5"
	AvgStdDEprot=$(bc -l <<< "scale=6; ( ($ptdev1E - $ptdev2E) * 0.043 )" | xargs printf "%6.6f")
	echo "AvgStdDEprot $AvgStdDEprot $1 and $5">> $dirpath/$1/AvgStdDEprot_$1.txt

}




calverE $oxddir $reddir fe3crdfe3prm fe3crdfe2prm prm
calverE $reddir $oxddir fe2crdfe2prm fe2crdfe3prm prm

calverE $oxddir $reddir fe3crdfe3prm-rp fe3crdfe2prm-rp -rp
calverE $reddir $oxddir fe2crdfe2prm-rp fe2crdfe3prm-rp -rp

calverE $oxddir $reddir fe3crdfe3prm-rp1 fe3crdfe2prm-rp1 -rp1
calverE $reddir $oxddir fe2crdfe2prm-rp1 fe2crdfe3prm-rp1 -rp1

echo "Printing Marcus ET parameters for $protien $ligand complex " > $dirpath/$protein-MarcusET-parm.txt
echo "MD-traj AvgDEa AvgStdDEa AvgDEb AvgStdDEb lambdaET lambdaStdET DGET StdDGET lambdaETprot lambdaStdETprot cofacdis" >> $dirpath/$protein-MarcusET-parm.txt
calMarcusETparm () {
	echo "printing-for-trajectory $1"
	AvgDEred=$(cat $dirpath/$reddir/AvgDE_$reddir.txt | grep -- $1 | head -1 | awk '{print $2}')
	AvgStdDEred=$(cat $dirpath/$reddir/AvgStdDE_$reddir.txt | grep -- $1 | head -1 | awk '{print $2}')
	AvgStdDEred=$(echo $AvgStdDEred | awk '{print ($1>=0)? $1:0-$1}'  )
	AvgDEoxd=$(cat $dirpath/$oxddir/AvgDE_$oxddir.txt | grep -- $1 | head -1 | awk '{print $2}')
	AvgStdDEoxd=$(cat $dirpath/$oxddir/AvgStdDE_$oxddir.txt | grep -- $1 | head -1 | awk '{print $2}')
	AvgStdDEoxd=$(echo $AvgStdDEoxd | awk '{print ($1>=0)? $1:0-$1}'  )
	lambdaET=$(bc -l <<< "scale=6; ((- $AvgDEred - $AvgDEoxd)/2)")
	lambdaETStd=$(bc -l <<< "scale=6; ((- $AvgStdDEred - $AvgStdDEoxd))")
	lambdaETStd=$(echo $lambdaETStd | awk '{print ($1>=0)? $1:0-$1}'  )
	DGET=$(bc -l <<< "scale=6; ((- $AvgDEred + $AvgDEoxd)/2)")
	StdDGET=$(bc -l <<< "scale=6; ((- $AvgStdDEred - $AvgStdDEoxd))")
	StdDGET=$(echo $StdDGET | awk '{print ($1>=0)? $1:0-$1}' )

	AvgDEprotred=$(cat $dirpath/$reddir/AvgDEprot_$reddir.txt | grep -- $1 | head -1 | awk '{print $2}')
	AvgStdDEprotred=$(cat $dirpath/$reddir/AvgStdDEprot_$reddir.txt | grep -- $1 | head -1 | awk '{print $2}')
	AvgStdDEprotred=$(echo $AvgStdDEprotred | awk '{print ($1>=0)? $1:0-$1}'  )
	AvgDEprotoxd=$(cat $dirpath/$oxddir/AvgDEprot_$oxddir.txt | grep -- $1 | head -1 | awk '{print $2}')
	AvgStdDEprotoxd=$(cat $dirpath/$oxddir/AvgStdDEprot_$oxddir.txt | grep -- $1 | head -1 | awk '{print $2}')
	AvgStdDEprotoxd=$(echo $AvgStdDEprotoxd | awk '{print ($1>=0)? $1:0-$1}')
	lambdaETprot=$(bc -l <<< "scale=6; ((- $AvgDEprotred - $AvgDEprotoxd)/2)")
	lambdaStdETprot=$(bc -l <<< "scale=6; ((- $AvgStdDEprotred - $AvgStdDEprotoxd))")
	lambdaStdETprot=$(echo $lambdaStdETprot | awk '{print ($1>=0)? $1:0-$1}'  )
	AvgDEred=$(bc -l <<< "scale=6; (- $AvgDEred)")
#	DGETprot=$(bc -l <<< "scale=6; (($AvgDEprotred + $AvgDEprotoxd)/2)"
	filename=$1

        if [[ $filename == prm ]];
        then
                oxdcofacdis=$(tail -n +2 $dirpath/$oxddir/$protein-FMN-HEMcontacts.dat | awk '{print $4}' | st | tail -1 | awk '{print $5}')
                redcofacdis=$(tail -n +2 $dirpath/$reddir/$protein-FMN-HEMcontacts.dat | awk '{print $4}' | st | tail -1 | awk '{print $5}')
                oxdcofacdisstd=$(tail -n +2 $dirpath/$oxddir/$protein-FMN-HEMcontacts.dat | awk '{print $4}' | st | tail -1 | awk '{print $6}')
                redcofacdisstd=$(tail -n +2 $dirpath/$reddir/$protein-FMN-HEMcontacts.dat | awk '{print $4}' | st | tail -1 | awk '{print $6}')
                avgcofacdis=$(bc -l <<< "scale=6; ( ( $oxdcofacdis + $redcofacdis )/2)" | xargs printf "%6.6f")
                avgcofacdisstd=$(bc -l <<< "scale=6; ( ( $oxdcofacdisstd + $redcofacdisstd ))")
                echo "$1 $AvgDEoxd $AvgStdDEoxd $AvgDEred $AvgStdDEred $lambdaET $lambdaETStd $DGET $StdDGET $lambdaETprot $lambdaStdETprot $avgcofacdis $avgcofacdisstd" >> $dirpath/$protein-MarcusET-parm.txt
        else
                oxdcofacdis=$(tail -n +2 $dirpath/$oxddir/$protein-FMN-HEMcontacts"$1".dat | awk '{print $4}' | st | tail -1 | awk '{print $5}')
                redcofacdis=$(tail -n +2 $dirpath/$reddir/$protein-FMN-HEMcontacts"$1".dat | awk '{print $4}' | st | tail -1 | awk '{print $5}')
                oxdcofacdisstd=$(tail -n +2 $dirpath/$oxddir/$protein-FMN-HEMcontacts"$1".dat | awk '{print $4}' | st | tail -1 | awk '{print $6}')
                redcofacdisstd=$(tail -n +2 $dirpath/$reddir/$protein-FMN-HEMcontacts"$1".dat | awk '{print $4}' | st | tail -1 | awk '{print $6}')
                avgcofacdis=$(bc -l <<< "scale=6; ( ( $oxdcofacdis + $redcofacdis )/2)" | xargs printf "%6.6f")
                avgcofacdisstd=$(bc -l <<< "scale=6; ( ( $oxdcofacdisstd + $redcofacdisstd ))")
                echo "$1 $AvgDEoxd $AvgStdDEoxd $AvgDEred $AvgStdDEred $lambdaET $lambdaETStd $DGET $StdDGET $lambdaETprot $lambdaStdETprot $avgcofacdis $avgcofacdisstd" >> $dirpath/$protein-MarcusET-parm.txt
        fi

}

calMarcusETparm prm
calMarcusETparm -rp
calMarcusETparm -rp1
more $dirpath/$protein-MarcusET-parm.txt


