echo "
============================================================================================      CYPWare 1.0 script and HTML tool     ==========================================================================================================================

WELCOME to CYPWare web interface to calculate Marcus ET parameters for Cytochrome P450 BM3 reactions.  
This script requires the following information for successful calculations (also note the dependencies on other software which are required to be in the USER-PATH are given below).

This user-friendly HTML tool (CYPWar-1.0.html) can be used to put all the required information in a text file which CYPWare 1.0 (this script) will read direclty.

If you have these requirements ready, then proceed with the next steps, else perform the docking calculation first and then come back to this CYPWare 1.0 web interface.
1) Name the ligand (without file extension) that was docked into CYP450 active site using Autodock Vina.

2) Name the protein (without file extension) that was used for the Autodock Vina docking simulations.

3) Unix path on your server/workstation where you wish the new files should be created.  You should have write-permissions for that folder. It could be your home directory or any of the sub-directories.

4) Name the folders of the oxidized and reduced states of the Heme center. These directories will be created by the script.

5) Unix path where all the parameter files for the oxidized and reduced states are kept.  These are essential for successfully running the MD simulations.  
	These are kept in a folder called parameters on the GitHub page (in case of query you can post a question to the CYPWare 1.0 development team).

6) Posenumber for the ligand docked pose for which a complex will be created followed by MD simulations and Marcus ET parameter extraction.  
	Currently, CYPWare 1.0 takes Autodock Vina output (pdbqt file) to create the complex, but it can be modified by the user to accept other file formats (which obabel can read).

7) Net molecular charge on the ligand.  This is required to successfully generate ligand parameters with the antechamber program and is required for MD simulations.

The methodology underlying the CYPWare is developed by the PI: Dr. Vaibhav A. Dixit, Asst. Prof., Dept. of Med. Chem., NIPER Guwahati in the Advanced Center of Computer-Aided Drug Design (A-CADD).
The web interface (GUI) is developed in collaboration with C-DAC (Dr. Vinod, Mr. Saurabh, and the team)
CYPWare software, GUI, websites, tools, layouts, and logos are subject to copyright protection and are the exclusive property of the Department of Medicinal Chemistry, NIPER Guwahati. 
The name and logos of the NIPER Guwahati website must not be associated with publicity or business promotion without NIPER G's prior written approval. 

CYPWare 1.0 is available under the creative commons license and is free for academic research groups working in a degree-granting university/institute.  
Any work/report/thesis/research-article/review-article resulting from the use of CYPWare 1.0 should properly cite the software and publication associated with the same.


===========================================================================  Dependencies  ===========================================================================================
CYPWare 1.0 makes use of the following opensource tools, thus these need to be installed first from GitHub, Sourceforge, or as a conda package.
Ensure that dependencies are satisfied before running CYPWare 1.0, else the calculation will not complete as expected.

1) Openbabel 3.1 or higher 

	Openbabel is available as a conda package and can be installed with one of the following commands.

	conda install -c conda-forge openbabel
	conda install -c conda-forge/label/cf202003 openbabel

If you don't have conda, then install it from the main website https://www.anaconda.com/
Instructions for conda installation can be found on its website.

2) AmberTools and Amber18 or higher
	
	AmberTools is a freely available software used for the setup and analysis of MD simulations. It is available from the http://ambermd.org/ website.
	It can also be installed as a conda package with any one of the following command.
	
	conda install -c conda-forge ambertools
	conda install -c conda-forge/label/cf202003 ambertools

	Amber18, 20 or the latest 22 version is a widely used MD engine and includes sander, pmemd, and their serial, parallel (MPI), and GPU (cuda) versions.
	It is available at a reasonable price from Prof. David Case's group at UCSF http://ambermd.org/GetAmber.php#amber

	AMBERHOME directory should be in your path for CYPWare 1.0 to run correctly

3) AmberMdPrep is a wrapper script by Daniel R. Roe used for equilibrating a biomolecular system for MD simulations

	It can be downloaded from https://github.com/drroe/AmberMdPrep
	Untar the AmberMdPrep folder and make sure that the AmberMdPrep.sh script is in your path
	
	AmberMdPrep depends on the latest GitHub version of cpptraj which is available here https://github.com/Amber-MD/cpptraj
	The GitHub version of cpptraj should be installed in a separate directory and sourced before running AmberMdPrep.  CYPWare 1.0 will source cpptraj automatically if the path is set correctly.

4) Statistical tool st
	A simple statistical tool available on GitHub is used to extract the averages and standard deviations in vertical energy gaps.
	This is available at https://github.com/nferraz/st
	st can be installed using the following commands

	git clone https://github.com/nferraz/st
	cd perl5
	perl Makefile.PL
	make
	make test
	make install

5) Extracting Marcus ET parameters
	This can be done by calling additional scripts on the Linux terminal.
	bash get-Marcus-ET-parm-LB.sh file (for ligand-bound state)
	bash get-Marcus-ET-parm-LF.sh file (for ligand-free state)

For commercial usage of CYPWare 1.0, please contact the PI at vaibhavadixit@gmail.com or vaibhav@niperguwahati.in
============================================================================================================================================================================================================================================= "

source /home/$USER/.bashrc
source $AMBERHOME/amber.sh
module load cuda/10.1
module load new_amber/20
module load openbabel/2.4.0
cwd=$(pwd)
export $(xargs <$1)
echo Reading $1 file for job parameters
echo "ligand and protein used for MD are $ligand $protein " > $protein-$ligand-MD-logfile.txt
echo "$dirpath used in the calculation" >> $protein-$ligand-MD-logfile.txt
echo "$oxddir used in the calculation" >> $protein-$ligand-MD-logfile.txt
echo "$reddir used in the calculation" >> $protein-$ligand-MD-logfile.txt

mkdir $dirpath/$reddir
mkdir $dirpath/$oxddir

echo "created directories for oxd and red state " >> $protein-$ligand-MD-logfile.txt
echo "parameters for oxd and red states read from $oxdparm $redparm " >> $protein-$ligand-MD-logfile.txt

echo "Copying ligand and protein Changing directory to Ferrous or the reduced state i.e. $dirpath/$reddir"
cp $ligand.pdbqt $dirpath/$reddir
cp $protein.pdb $dirpath/$reddir
cd $dirpath/$reddir
echo "parameterizing ligand and generating the protein complex"

obabel $ligand.pdbqt -O $ligand.pdb -m 

for i in $(ls $ligand*.pdb | grep -v $posenumber ); do echo removing file $i; rm $i ; done

echo "pose number $posenumber from the vina docking output $ligand.pdbqt file was used for MD simulations " >> ../$protein-$ligand-MD-logfile.txt
echo "pose number $posenumber from the vina docking output $ligand.pdbqt file was used for MD simulations " 
#rm $ligand"2".pdb $ligand"3".pdb $ligand"4".pdb $ligand"5".pdb $ligand"6".pdb $ligand"7".pdb $ligand"8".pdb $ligand"9".pdb

obabel $ligand"$posenumber".pdb -O $ligand"$posenumber"-h.pdb -h

grep ATOM $ligand"$posenumber"-h.pdb > $ligand.pdb
echo "Give the expeced net-charge on the molecule as an integer e.g. -1, 0 or 1"
#babel test-$ligand.pdb -O test.mol2 --partialcharge gasteiger
#molchrg=$(egrep -A1000 ATOM test.mol2 | grep -v ROOT | grep LIG | sed -e "1d" | awk '{print $9}' | st | awk '{print $4}' | tail -1 | xargs printf "%1.0f")

$AMBERHOME/bin/antechamber -i $ligand.pdb -fi pdb -o $ligand.mol2 -fo mol2 -c bcc -s 2 -nc $molchrg
$AMBERHOME/bin/parmchk2 -i $ligand.mol2 -f mol2 -o $ligand.frcmod
$AMBERHOME/bin/antechamber -i $ligand.mol2 -fi mol2 -o $ligand.ac -fo ac 
$AMBERHOME/bin/antechamber -i $ligand.ac -fi ac -o $ligand-test.pdb -fo pdb 

echo "Antechamber used to prepare ligand parameters and atomtypes for $ligand " >> ../$protein-$ligand-MD-logfile.txt
echo "Antechamber used to prepare ligand parameters and atomtypes for $ligand "
#cp test-$ligand.pdb test.pdb
sed 's/[[:space:]]*[^[:space:]]*$//' $ligand-test.pdb | sed 's/[[:space:]]*[^[:space:]]*$//'  > $ligand.pdb
#rm test.pdb
echo " "
echo "Combining $protien $ligand into a complex" | tee -a $protein-$ligand-MD-logfile.txt

cat $protein.pdb $ligand.pdb > $protein-$ligand.pdb
echo "unloading abmer20" | tee -a $protein-$ligand-MD-logfile.txt
module unload new_amber/20
echo "loading amber/18" | tee -a $protein-$ligand-MD-logfile.txt
module load amber/18
echo "Preparing the complex for Amber usage" | tee -a $protein-$ligand-MD-logfile.txt
$AMBERHOME/bin/pdb4amber -i $protein-$ligand.pdb -o $protein-$ligand-comp.pdb
echo "copying files $ligand $protein into $oxddir" | tee -a $protein-$ligand-MD-logfile.txt
cp $ligand.mol2 $dirpath/$oxddir
cp $ligand.frcmod $dirpath/$oxddir
cp $protein-$ligand-comp.pdb $dirpath/$oxddir
echo "unloading abmer18" | tee -a $protein-$ligand-MD-logfile.txt
module unload amber/18
echo "loading new_amber/20" | tee -a $protein-$ligand-MD-logfile.txt
module load new_amber/20
echo "$protein-$ligand complex formed and saved for MD simulations " | tee -a ../$protein-$ligand-MD-logfile.txt
echo "returning to the partent directory" | tee -a $protein-$ligand-MD-logfile.txt
cd ..
echo "Writing tleap input file for the ferric or oxidized state" | tee -a $protein-$ligand-MD-logfile.txt
echo "
source leaprc.protein.ff14SB
source leaprc.gaff2
addAtomTypes { " > $dirpath/$oxddir/$protein-$ligand-tleap.in
echo '        { "M1"  "Fe" "sp3" }' >> $dirpath/$oxddir/$protein-$ligand-tleap.in
echo '        { "Y1"  "S" "sp3" }' >> $dirpath/$oxddir/$protein-$ligand-tleap.in
echo '        { "Y2"  "N" "sp3" }' >> /$dirpath/$oxddir/$protein-$ligand-tleap.in
echo '        { "Y3"  "N" "sp3" }' >> $dirpath/$oxddir/$protein-$ligand-tleap.in
echo '        { "Y4"  "N" "sp3" }' >> $dirpath/$oxddir/$protein-$ligand-tleap.in
echo '        { "Y5"  "N" "sp3" }' >> $dirpath/$oxddir/$protein-$ligand-tleap.in
echo '}' >> $dirpath/$oxddir/$protein-$ligand-tleap.in
echo "CM1 = loadmol2 $oxdparm/CM1.mol2
HM1 = loadmol2 $oxdparm/HM1.mol2
FE1 = loadmol2 $oxdparm/FE1.mol2
FMN = loadmol2 $oxdparm/FMN-sq-H.mol2
LIG = loadmol2 $dirpath/$oxddir/$ligand.mol2
loadamberparams $oxdparm/HEM.frcmod
loadamberparams $dirpath/$oxddir/$ligand.frcmod
loadamberparams frcmod.ions1lm_126_tip3p
loadamberparams $oxdparm/4ZF6_mcpbpy.frcmod
loadamberparams $oxdparm/FMN-sq-H.frcmod
source leaprc.water.tip3p
mol = loadpdb $dirpath/$oxddir/$protein-$ligand-comp.pdb
bond mol.381.SG mol.613.FE
bond mol.612.NA mol.613.FE
bond mol.612.NB mol.613.FE
bond mol.612.NC mol.613.FE
bond mol.612.ND mol.613.FE
bond mol.380.C mol.381.N
bond mol.381.C mol.382.N
savepdb mol $dirpath/$oxddir/$protein-$ligand-dry.pdb
saveamberparm mol $dirpath/$oxddir/$protein-$ligand-dry.prmtop $dirpath/$oxddir/$protein-$ligand-dry.inpcrd
charge mol
solvatebox mol TIP3PBOX 10.0
addions mol K+ 29
#addions mol Cl- 0
charge mol
savepdb mol $dirpath/$oxddir/$protein-$ligand-solv.pdb
saveamberparm mol $dirpath/$oxddir/$protein-$ligand-solv.prmtop $dirpath/$oxddir/$protein-$ligand-solv.inpcrd
quit" >> $dirpath/$oxddir/$protein-$ligand-tleap.in
echo "tleap input file has been created for the ferric or oxidized state. Please check if the system charged is 0, if not make appropriate changes in the type and number of ions to be added in the addions file and rerun this main script"

echo "Writing tleap input file for the ferrous or reduced state"
echo '
source leaprc.protein.ff14SB
source leaprc.gaff2
addAtomTypes {' > $dirpath/$reddir/$protein-$ligand-tleap.in
echo '        { "M1"  "Fe" "sp3" }' >> $dirpath/$reddir/$protein-$ligand-tleap.in
echo '        { "Y1"  "S" "sp3" }' >> $dirpath/$reddir/$protein-$ligand-tleap.in
echo '        { "Y2"  "N" "sp3" }' >> /$dirpath/$reddir/$protein-$ligand-tleap.in
echo '        { "Y3"  "N" "sp3" }' >> $dirpath/$reddir/$protein-$ligand-tleap.in
echo '        { "Y4"  "N" "sp3" }' >> $dirpath/$reddir/$protein-$ligand-tleap.in
echo '        { "Y5"  "N" "sp3" }' >> $dirpath/$reddir/$protein-$ligand-tleap.in
echo '}' >> $dirpath/$reddir/$protein-$ligand-tleap.in
echo "CM1 = loadmol2 $redparm/CM1.mol2
HM1 = loadmol2 $redparm/HM1.mol2
FE1 = loadmol2 $redparm/FE1.mol2
FMN = loadmol2 $redparm/FMN-ox-H.mol2
LIG = loadmol2 $dirpath/$reddir/$ligand.mol2
loadamberparams $redparm/HEM.frcmod
loadamberparams $dirpath/$reddir/$ligand.frcmod
loadamberparams frcmod.ions1lm_126_tip3p
loadamberparams $redparm/4ZF6_mcpbpy.frcmod
loadamberparams $redparm/FMN-ox-H.frcmod
source leaprc.water.tip3p
mol = loadpdb $dirpath/$reddir/$protein-$ligand-comp.pdb
bond mol.381.SG mol.613.FE
bond mol.612.NA mol.613.FE
bond mol.612.NB mol.613.FE
bond mol.612.NC mol.613.FE
bond mol.612.ND mol.613.FE
bond mol.380.C mol.381.N
bond mol.381.C mol.382.N
savepdb mol $dirpath/$reddir/$protein-$ligand-dry.pdb
saveamberparm mol $dirpath/$reddir/$protein-$ligand-dry.prmtop $dirpath/$reddir/$protein-$ligand-dry.inpcrd
charge mol
solvatebox mol TIP3PBOX 10.0
addions mol K+ 29
#addions mol Cl- 0
charge mol
savepdb mol $dirpath/$reddir/$protein-$ligand-solv.pdb
saveamberparm mol $dirpath/$reddir/$protein-$ligand-solv.prmtop $dirpath/$reddir/$protein-$ligand-solv.inpcrd
quit" >> $dirpath/$reddir/$protein-$ligand-tleap.in
echo "tleap input file has been created for the ferric or oxidized state. Please check if the system charged is 0 if not make appropriate changes in the type and number of ions to be added in the addions file and rerun this main script"

echo "Writing cpptraj input files"

writemdfiles () {
	echo "
parm $protein-$ligand-solv.prmtop
trajin $protein-$ligand-solv-prod.nc 
autoimage
center
strip :WAT,Cl-,Na+,K+
trajout $protein-$ligand-prot.nc 
trajout $protein-$ligand-prot.rst7 onlyframes 1 
" > $dirpath/$1/protein-reorgE-cpptraj.in 

	echo "
parm $protein-$ligand-solv.prmtop
trajin $protein-$ligand-solv-prod-rp.nc 
autoimage
center
strip :WAT,Cl-,Na+,K+
trajout $protein-$ligand-prot-rp.nc 
trajout $protein-$ligand-prot-rp.rst7 onlyframes 1
" > $dirpath/$1/protein-reorgE-cpptraj1.in

	echo "
parm $protein-$ligand-solv.prmtop
trajin $protein-$ligand-solv-prod-rp1.nc 
autoimage
center
strip :WAT,Cl-,Na+,K+
trajout $protein-$ligand-prot-rp1.nc 
trajout $protein-$ligand-prot-rp1.rst7 onlyframes 1
" > $dirpath/$1/protein-reorgE-cpptraj2.in

	echo "Writing sp-MD input file"
	echo "single point energy calculations of ferric state coordinates using ferrous parameters
&cntrl
  ntx=1, ntpr=1, ntwx=1,
  imin=5, maxcyc=1, !Single-point energy calculation on each frame
  ntb=1, ntp=0, ntc=2, !periodic
  cut=9, !Calculate all solute-solute interactions
/
" > $dirpath/$1/MD-sp-periodic.mdin

	echo "Writing MD input file for a 20 ns MD production run"
	echo "Production Stage in Explicit Solvent 20 ns
&cntrl
  ntt=3,           ! Temperature scaling (=3, Langevin dynamics)
  gamma_ln=2.0,    ! Collision frequency of the Langevin dynamics in ps-1
  ntc=2,           ! SHAKE constraints (=2, hydrogen bond lengths constrained)
  ntf=2,           ! Force evaluation (=2, hydrogen bond interactions omitted)
  ntb=1,           ! Boundaries (=1, constant volume)
  cut=10.0,        ! Cutoff
  dt=0.002,        ! The time step in picoseconds
  nstlim=10000000, ! Number of MD steps to be performed
  ig=-1,           ! Random seed (=-1, get a number from current date and time)
  ntwr=5000,      ! Restart file written every ntwr steps
  ntwx=5000,      ! Trajectory file written every ntwx steps
  ntpr=5000,      ! The mdout and mdinfo files written every ntpr steps
  ioutfm=1,        ! Trajectory file format (=1, Binary NetCDF)
  iwrap=1,         ! Translate water molecules into the original simulation box
  igb=0,           ! GB model (=0, explicit solvent)
  irest=1,         ! Flag to restart the simulation
  ntx=5,           ! Initial condition (=5, coord. and veloc. read from the inpcrd file)
/
" > $dirpath/$1/prod20ns.in

#Ferrousdir=$(echo Ferrous-$protein-$ligand | sed 's/_out//g')

	echo "Writing sp-MD input files for the ferric/ferrous or oxidized/reduced state to be submitted by task spoolar ts"
	echo "
mpirun -np 12 sander.MPI -O -i MD-sp-periodic.mdin -o $protein-$ligand-solv-$3.out -c $protein-$ligand-solv-prod.rst7 -ref $protein-$ligand-solv-prod.rst7 -r restrt -y $protein-$ligand-solv-prod.nc -p $protein-$ligand-solv.prmtop 
wait 
sander -O -i MD-sp-periodic.mdin -o $protein-$ligand-solv-$4.out -c $protein-$ligand-solv-prod.rst7 -ref $protein-$ligand-solv-prod.rst7 -r restrt -y $protein-$ligand-solv-prod.nc -p ../$2/$protein-$ligand-solv.prmtop " > $dirpath/$1/sp-MD.sh

	echo "
mpirun -np 12 sander.MPI -O -i MD-sp-periodic.mdin -o $protein-$ligand-solv-$3-rp.out -c $protein-$ligand-solv-prod-rp.rst7 -ref $protein-$ligand-solv-prod-rp.rst7 -r restrt -y $protein-$ligand-solv-prod-rp.nc -p $protein-$ligand-solv.prmtop 
wait 
mpirun -np 12 sander.MPI -O -i MD-sp-periodic.mdin -o $protein-$ligand-solv-$4-rp.out -c $protein-$ligand-solv-prod-rp.rst7 -ref $protein-$ligand-solv-prod-rp.rst7 -r restrt -y $protein-$ligand-solv-prod-rp.nc -p ../$2/$protein-$ligand-solv.prmtop " > $dirpath/$1/sp-MD1.sh

	echo "
mpirun -np 12 sander.MPI -O -i MD-sp-periodic.mdin -o $protein-$ligand-solv-$3-rp1.out -c $protein-$ligand-solv-prod-rp1.rst7 -ref $protein-$ligand-solv-prod-rp1.rst7 -r restrt -y $protein-$ligand-solv-prod-rp1.nc -p $protein-$ligand-solv.prmtop 
wait 
mpirun -np 12 sander.MPI -O -i MD-sp-periodic.mdin -o $protein-$ligand-solv-$4-rp1.out -c $protein-$ligand-solv-prod-rp1.rst7 -ref $protein-$ligand-solv-prod-rp1.rst7 -r restrt -y $protein-$ligand-solv-prod-rp1.nc -p ../$2/$protein-$ligand-solv.prmtop " > $dirpath/$1/sp-MD2.sh

	echo "
mpirun -np 12 sander.MPI -O -i MD-sp-periodic.mdin -o $protein-$ligand-prot-$3.out -c $protein-$ligand-prot.rst7 -ref $protein-$ligand-prot.rst7 -r restrt -y $protein-$ligand-prot.nc -p $protein-$ligand-dry.prmtop 
wait 
mpirun -np 12 sander.MPI -O -i MD-sp-periodic.mdin -o $protein-$ligand-prot-$4.out -c $protein-$ligand-prot.rst7 -ref $protein-$ligand-prot.rst7 -r restrt -y $protein-$ligand-prot.nc -p ../$2/$protein-$ligand-dry.prmtop " > $dirpath/$1/sp-MD-prot.sh

	echo "
mpirun -np 12 sander.MPI -O -i MD-sp-periodic.mdin -o $protein-$ligand-prot-$3-rp.out -c $protein-$ligand-prot-rp.rst7 -ref $protein-$ligand-prot-rp.rst7 -r restrt -y $protein-$ligand-prot-rp.nc -p $protein-$ligand-dry.prmtop 
wait 
mpirun -np 12 sander.MPI -O -i MD-sp-periodic.mdin -o $protein-$ligand-prot-$4-rp.out -c $protein-$ligand-prot-rp.rst7 -ref $protein-$ligand-prot-rp.rst7 -r restrt -y $protein-$ligand-prot-rp.nc -p ../$2/$protein-$ligand-dry.prmtop " > $dirpath/$1/sp-MD-prot1.sh

	echo "
mpirun -np 12 sander.MPI -O -i MD-sp-periodic.mdin -o $protein-$ligand-prot-$3-rp1.out -c $protein-$ligand-prot-rp1.rst7 -ref $protein-$ligand-prot-rp1.rst7 -r restrt -y $protein-$ligand-prot-rp1.nc -p $protein-$ligand-dry.prmtop 
wait 
mpirun -np 12 sander.MPI -O -i MD-sp-periodic.mdin -o $protein-$ligand-prot-$4-rp1.out -c $protein-$ligand-prot-rp1.rst7 -ref $protein-$ligand-prot-rp1.rst7 -r restrt -y $protein-$ligand-prot-rp1.nc -p ../$2/$protein-$ligand-dry.prmtop " > $dirpath/$1/sp-MD-prot2.sh
	echo "
parm $protein-$ligand-solv.prmtop
trajin $protein-$ligand-solv-prod.nc
autoimage
center
reference final.1.ncrst

nativecontacts name $protein-$ligand :1-439 :459-611 byresidue out $protein-$ligand-contacts.dat mindist maxdist distance 7.0 first map mapout $protein-$ligand-resmap.gnu contactpdb $protein-$ligand-contactmap.pdb series seriesout $protein-$ligand-nativecontacts.dat writecontacts $protein-$ligand-writecontacts.dat
nativecontacts name $protein-$ligand-HEM :612&!@H= :459-611&!@H= byresidue out $protein-$ligand-HEMcontacts.dat mindist maxdist distance 10.0 first map mapout $protein-$ligand-HEMresmap.gnu contactpdb $protein-$ligand-HEMcontactmap.pdb series seriesout $protein-$ligand-HEMnativecontacts.dat writecontacts $protein-$ligand-HEMwritecontacts.dat
nativecontacts name $protein-$ligand-FMN :614&!@H= :1-439&!@H= byresidue out $protein-$ligand-FMNcontacts.dat mindist maxdist distance 10.0 first map mapout $protein-$ligand-FMNresmap.gnu contactpdb $protein-$ligand-FMNcontactmap.pdb series seriesout $protein-$ligand-FMNnativecontacts.dat writecontacts $protein-$ligand-FMNwritecontacts.dat
nativecontacts name $protein-$ligand-FMN-HEM :612&!@H= :614&!@H= byresidue out $protein-$ligand-FMN-HEMcontacts.dat mindist maxdist distance 10.0 first map mapout $protein-$ligand-FMN-HEMresmap.gnu contactpdb $protein-$ligand-FMN-HEMcontactmap.pdb series seriesout $protein-$ligand-FMN-HEMnativecontacts.dat writecontacts $protein-$ligand-FMN-HEMwritecontacts.dat " > $dirpath/$1/contacts.in

echo "
parm $protein-$ligand-solv.prmtop
trajin $protein-$ligand-solv-prod-rp.nc
autoimage
center
reference final.1.ncrst

nativecontacts name $protein-$ligand :1-439 :459-611 byresidue out $protein-$ligand-contacts-rp.dat mindist maxdist distance 7.0 first map mapout $protein-$ligand-resmap-rp.gnu contactpdb $protein-$ligand-contactmap-rp.pdb series seriesout $protein-$ligand-nativecontacts-rp.dat writecontacts $protein-$ligand-writecontacts-rp.dat

nativecontacts name $protein-$ligand-HEM :612&!@H= :459-611&!@H= byresidue out $protein-$ligand-HEMcontacts-rp.dat mindist maxdist distance 10.0 first map mapout $protein-$ligand-HEMresmap-rp.gnu contactpdb $protein-$ligand-HEMcontactmap-rp.pdb series seriesout $protein-$ligand-HEMnativecontacts-rp.dat writecontacts $protein-$ligand-HEMwritecontacts-rp.dat

nativecontacts name $protein-$ligand-FMN :614&!@H= :1-439&!@H= byresidue out $protein-$ligand-FMNcontacts-rp.dat mindist maxdist distance 10.0 first map mapout $protein-$ligand-FMNresmap-rp.gnu contactpdb $protein-$ligand-FMNcontactmap-rp.pdb series seriesout $protein-$ligand-FMNnativecontacts-rp.dat writecontacts $protein-$ligand-FMNwritecontacts-rp.dat

nativecontacts name $protein-$ligand-FMN-HEM :612&!@H= :614&!@H= byresidue out $protein-$ligand-FMN-HEMcontacts-rp.dat mindist maxdist distance 10.0 first map mapout $protein-$ligand-FMN-HEMresmap-rp.gnu contactpdb $protein-$ligand-FMN-HEMcontactmap-rp.pdb series seriesout $protein-$ligand-FMN-HEMnativecontacts-rp.dat writecontacts $protein-$ligand-FMN-HEMwritecontacts-rp.dat " > $dirpath/$1/contacts-rp.in

	echo "
parm $protein-$ligand-solv.prmtop
trajin $protein-$ligand-solv-prod-rp1.nc
autoimage
center
reference final.1.ncrst
nativecontacts name $protein-$ligand :1-439 :459-611 byresidue out $protein-$ligand-contacts-rp1.dat mindist maxdist distance 7.0 first map mapout $protein-$ligand-resmap-rp1.gnu contactpdb $protein-$ligand-contactmap-rp1.pdb series seriesout $protein-$ligand-nativecontacts-rp1.dat writecontacts $protein-$ligand-writecontacts-rp1.dat

nativecontacts name $protein-$ligand-HEM :612&!@H= :459-611&!@H= byresidue out $protein-$ligand-HEMcontacts-rp1.dat mindist maxdist distance 10.0 first map mapout $protein-$ligand-HEMresmap-rp1.gnu contactpdb $protein-$ligand-HEMcontactmap-rp1.pdb series seriesout $protein-$ligand-HEMnativecontacts-rp1.dat writecontacts $protein-$ligand-HEMwritecontacts-rp1.dat

nativecontacts name $protein-$ligand-FMN :614&!@H= :1-439&!@H= byresidue out $protein-$ligand-FMNcontacts-rp1.dat mindist maxdist distance 10.0 first map mapout $protein-$ligand-FMNresmap-rp1.gnu contactpdb $protein-$ligand-FMNcontactmap-rp1.pdb series seriesout $protein-$ligand-FMNnativecontacts-rp1.dat writecontacts $protein-$ligand-FMNwritecontacts-rp1.dat

nativecontacts name $protein-$ligand-FMN-HEM :612&!@H= :614&!@H= byresidue out $protein-$ligand-FMN-HEMcontacts-rp1.dat mindist maxdist distance 10.0 first map mapout $protein-$ligand-FMN-HEMresmap-rp1.gnu contactpdb 1bvy-af-FMN-HEMcontactmap-rp1.pdb series seriesout $protein-$ligand-FMN-HEMnativecontacts-rp1.dat writecontacts $protein-$ligand-FMN-HEMwritecontacts-rp1.dat " > $dirpath/$1/contacts-rp1.in

}

writemdfiles $oxddir $reddir fe3crdfe3prm fe3crdfe2prm
writemdfiles $reddir $oxddir fe2crdfe2prm fe2crdfe3prm


#echo "give leap input and output file names one after the other and press enter before entering the next file name"
leapinput=$protein-$ligand-tleap.in
leapoutput=$protein-$ligand-tleap.out
#echo "give base file names to be used for MD prmtop, inpcrd, out, rst7, mdinfo and trajectory (nc) files"
basefile=$protein-$ligand-solv
echo $leapinput $leapoutput $basefile | tee -a $protein-$ligand-MD-logfile.txt
echo "creating MD prmtop inpcrd files for the Ferric or the oxidized state in $dirpath/$oxddir " | tee -a $protein-$ligand-MD-logfile.txt
echo "creating gpu-job head" | tee -a $protein-$ligand-MD-logfile.txt
echo "#!/bin/bash
#SBATCH -N 1
#SBATCH --ntasks-per-node=2
#SBATCH --time=95:50:20
#SBATCH --job-name=$protein-$ligand-solv
#SBATCH --error=job.%J.err_node_40
#SBATCH --output=job.%J.out_node_40
#SBATCH --partition=gpu
#SBATCH --gres=gpu:1
export I_MPI_FABRICS=shm:dapl
hostname

" > gpu-job-head.txt


echo "creating cpu-job head " | tee -a $protein-$ligand-MD-logfile.txt
echo "#!/bin/bash
#SBATCH -N 1
#SBATCH --ntasks-per-node=2
#SBATCH --time=95:50:20
#SBATCH --job-name=$protein-$ligand-solv
#SBATCH --error=job.%J.err_node_40
#SBATCH --output=job.%J.out_node_40
#SBATCH --partition=cpu
export I_MPI_FABRICS=shm:dapl
hostname

" > cpu-job-head.txt
echo "creating tleap input and sbatch file for $oxddir state" | tee -a $protein-$ligand-MD-logfile.txt
cat cpu-job-head.txt > $dirpath/$oxddir/$protein-$ligand-tleap.batch
echo "module load new_amber/20" >> $dirpath/$oxddir/$protein-$ligand-tleap.batch
echo "source $AMBERHOME/amber.sh" >> $dirpath/$oxddir/$protein-$ligand-tleap.batch
echo "$AMBERHOME/bin/tleap -s -f $dirpath/$oxddir/$leapinput > $dirpath/$oxddir/$leapoutput " >> $dirpath/$oxddir/$protein-$ligand-tleap.batch


oxdtleapjobid=$(sbatch $dirpath/$oxddir/$protein-$ligand-tleap.batch | awk '{print $4}')
echo "sleeping for 2m"
sleep 2m
oxdtleapjobstatus=$(sacct | grep $oxdtleapjobid | awk '{print $6}' | head -1)

echo "creating tleap input and sbatch file for $reddir state" | tee -a $protein-$ligand-MD-logfile.txt
cat cpu-job-head.txt > $dirpath/$reddir/$protein-$ligand-tleap.batch
echo "creating MD prmtop inpcrd files for the Ferrous or the reduced state in $dirpath/$reddir "
echo "module load new_amber/20" >> $dirpath/$reddir/$protein-$ligand-tleap.batch
echo "source $AMBERHOME/amber.sh" >> $dirpath/$oxddir/$protein-$ligand-tleap.batch
echo "$AMBERHOME/bin/tleap -s -f $dirpath/$reddir/$leapinput > $dirpath/$reddir/$leapoutput " >> $dirpath/$reddir/$protein-$ligand-tleap.batch

redtleapjobid=$(sbatch $dirpath/$reddir/$protein-$ligand-tleap.batch | awk '{print $4}')
echo "sleeping for 2m"
sleep 2m
redtleapjobstatus=$(sacct | grep $redtleapjobid | awk '{print $6}' | head -1)

echo "creating input and submitting equil jobs" | tee -a $dirpath/$protein-$ligand-MD-logfile.txt

while [[ $redtleapjobstatus == RUNNING ]];
do
	sleep 1m
done
echo "finished equiliration of $oxddir structure" | tee -a $dirpath/$protein-$ligand-MD-logfile.txt

while [[ $oxdtleapjobstatus == RUNNING ]];
do
	sleep 1m
done
echo "finished equiliration of $reddir structure" | tee -a $dirpath/$protein-$ligand-MD-logfile.txt
#ts -S 1 
chmod a+x $dirpath/$oxddir/sp-MD*.sh
chmod a+x $dirpath/$reddir/sp-MD*.sh

source /home/vaibhavdixit.bitspilani/cpptraj-master/cpptraj.sh
echo "changing directory to $oxddir" | tee -a $dirpath/$protein-$ligand-MD-logfile.txt
cd $dirpath/$oxddir
cp ../gpu-job-head.txt .
echo "creating MDequil sbatch files and submitting the job $oxddir state" | tee -a $dirpath/$protein-$ligand-MD-logfile.txt
cat gpu-job-head.txt > $dirpath/$oxddir/$protein-$ligand-MDequil.batch
echo "module load new_amber/20" >> $dirpath/$oxddir/$protein-$ligand-MDequil.batch
echo "source $AMBERHOME/amber.sh" >> $dirpath/$oxddir/$protein-$ligand-tleap.batch
echo "source /home/vaibhavdixit.bitspilani/cpptraj-master/cpptraj.sh" >> $dirpath/$oxddir/$protein-$ligand-MDequil.batch
echo "/home/vaibhavdixit.bitspilani/AmberMdPrep-master/AmberMdPrep.sh -O -p $dirpath/$oxddir/$basefile.prmtop -c $dirpath/$oxddir/$basefile.inpcrd --temp 300 --ares HD1 --ares HM1 --ares FE1 --ares CM1 --ares FMN --ares LIG " >> $dirpath/$oxddir/$protein-$ligand-MDequil.batch
oxdequiljobid=$(sbatch $dirpath/$oxddir/$protein-$ligand-MDequil.batch | awk '{print $4}')
oxdequiljobstatus=$(sacct | grep $oxdequiljobid | awk '{print $6}' | head -1)

source /home/vaibhavdixit.bitspilani/cpptraj-master/cpptraj.sh
cd $dirpath/$reddir
cp ../gpu-job-head.txt .
echo "creating MDequil sbatch files and submitting the job $reddir state" | tee -a $dirpath/$protein-$ligand-MD-logfile.txt
cat gpu-job-head.txt > $dirpath/$reddir/$protein-$ligand-MDequil.batch
echo "source $AMBERHOME/amber.sh" >> $dirpath/$reddir/$protein-$ligand-MDequil.batch
echo "source /home/vaibhavdixit.niperg/cpptraj-master/cpptraj.sh" >> $dirpath/$reddir/$protein-$ligand-MDequil.batch
echo "module load new_amber/20" >> $dirpath/$reddir/$protein-$ligand-MDequil.batch
echo "/home/vaibhavdixit.niperg/AmberMdPrep-master/AmberMdPrep.sh -O -p $dirpath/$reddir/$basefile.prmtop -c $dirpath/$reddir/$basefile.inpcrd --temp 300 --ares HD1 --ares HM1 --ares FE1 --ares CM1 --ares FMN --ares LIG " >> $dirpath/$reddir/$protein-$ligand-MDequil.batch
redequiljobid=$(sbatch $dirpath/$reddir/$protein-$ligand-MDequil.batch | awk '{print $4}')
redequiljobstatus=$(sacct | grep $redequiljobid | awk '{print $6}' | head -1)

echo "sleeping for the equiljobs to finish"

while [[ $(sacct | grep $oxdequiljobid | awk '{print $6}' | head -1 ) == RUNNING ]];
do
	sleep 1m
done
echo "finished equiliration of $oxddir structure" | tee -a $dirpath/$protein-$ligand-MD-logfile.txt

while [[ $(sacct | grep $redequiljobid | awk '{print $6}'  | head -1 ) == RUNNING ]];
do
	sleep 1m
done


echo "changing directory to $oxddir and submitting 20ns MD jobs in triplicate (prod, prod-rp and prod-rp1) after equilibriation is success" | tee -a $dirpath/$protein-$ligand-MD-logfile.txt
cd $dirpath/$oxddir
cat gpu-job-head.txt > $dirpath/$oxddir/oxdMD-rp-rp1.batch
echo "module load new_amber/20" >> $dirpath/$oxddir/oxdMD-rp-rp1.batch
echo "source $AMBERHOME/amber.sh" >> $dirpath/$oxddir/oxdMD-rp-rp1.batch
echo "pmemd.cuda -O -i $dirpath/$oxddir/prod20ns.in -p $dirpath/$oxddir/$basefile.prmtop -c $dirpath/$oxddir/final.1.ncrst -ref $dirpath/$oxddir/final.1.ncrst -r $dirpath/$oxddir/$basefile-prod.rst7 -inf $dirpath/$oxddir/$basefile-prod.mdinfo -o $dirpath/$oxddir/$basefile-prod.mdout -x $dirpath/$oxddir/$basefile-prod.nc 
pmemd.cuda -O -i $dirpath/$oxddir/prod20ns.in -p $dirpath/$oxddir/$basefile.prmtop -c $dirpath/$oxddir/final.1.ncrst -ref $dirpath/$oxddir/final.1.ncrst -r $dirpath/$oxddir/$basefile-prod-rp.rst7 -inf $dirpath/$oxddir/$basefile-prod-rp.mdinfo -o $dirpath/$oxddir/$basefile-prod-rp.mdout -x $dirpath/$oxddir/$basefile-prod-rp.nc 
pmemd.cuda -O -i $dirpath/$oxddir/prod20ns.in -p $dirpath/$oxddir/$basefile.prmtop -c $dirpath/$oxddir/final.1.ncrst -ref $dirpath/$oxddir/final.1.ncrst -r $dirpath/$oxddir/$basefile-prod-rp1.rst7 -inf $dirpath/$oxddir/$basefile-prod-rp1.mdinfo -o $dirpath/$oxddir/$basefile-prod-rp1.mdout -x $dirpath/$oxddir/$basefile-prod-rp1.nc 
cpptraj.cuda -i $dirpath/$oxddir/contacts.in
cpptraj.cuda -i $dirpath/$oxddir/contacts-rp.in
cpptraj.cuda -i $dirpath/$oxddir/contacts-rp1.in 

" >> $dirpath/$oxddir/oxdMD-rp-rp1.batch 
oxdMDjobid=$(sbatch --dependency=afterok:$oxdequiljobid $dirpath/$oxddir/oxdMD-rp-rp1.batch | awk '{print $4}')
oxdMDjobstatus=$(sacct | grep $oxdMDjobid | awk '{print $6}'  | head -1)

echo "changing directory to $reddir and submitting 20ns MD jobs in triplicate (prod, prod-rp and prod-rp1) after equilibriation is success" | tee -a $dirpath/$protein-$ligand-MD-logfile.txt
cd $dirpath/$reddir
cat gpu-job-head.txt > $dirpath/$reddir/redMD-rp-rp1.batch
echo "module load new_amber/20" >> $dirpath/$reddir/redMD-rp-rp1.batch
echo "source $AMBERHOME/amber.sh" >> $dirpath/$reddir/redMD-rp-rp1.batch
echo "pmemd.cuda -O -i $dirpath/$reddir/prod20ns.in -p $dirpath/$reddir/$basefile.prmtop -c $dirpath/$reddir/final.1.ncrst -ref $dirpath/$reddir/final.1.ncrst -r $dirpath/$reddir/$basefile-prod.rst7 -inf $dirpath/$reddir/$basefile-prod.mdinfo -o $dirpath/$reddir/$basefile-prod.mdout -x $dirpath/$reddir/$basefile-prod.nc 
pmemd.cuda -O -i $dirpath/$reddir/prod20ns.in -p $dirpath/$reddir/$basefile.prmtop -c $dirpath/$reddir/final.1.ncrst -ref $dirpath/$reddir/final.1.ncrst -r $dirpath/$reddir/$basefile-prod-rp.rst7 -inf $dirpath/$reddir/$basefile-prod-rp.mdinfo -o $dirpath/$reddir/$basefile-prod-rp.mdout -x $dirpath/$reddir/$basefile-prod-rp.nc 
pmemd.cuda -O -i $dirpath/$reddir/prod20ns.in -p $dirpath/$reddir/$basefile.prmtop -c $dirpath/$reddir/final.1.ncrst -ref $dirpath/$reddir/final.1.ncrst -r $dirpath/$reddir/$basefile-prod-rp1.rst7 -inf $dirpath/$reddir/$basefile-prod-rp1.mdinfo -o $dirpath/$reddir/$basefile-prod-rp1.mdout -x $dirpath/$reddir/$basefile-prod-rp1.nc 
cpptraj.cuda -i $dirpath/$reddir/contacts.in
cpptraj.cuda -i $dirpath/$reddir/contacts-rp.in
cpptraj.cuda -i $dirpath/$reddir/contacts-rp1.in
" >> $dirpath/$reddir/redMD-rp-rp1.batch 
redMDjobid=$(sbatch --dependency=afterok:$redequiljobid $dirpath/$reddir/redMD-rp-rp1.batch | awk '{print $4}')
redMDjobstatus=$(sacct | grep $redMDjobid | awk '{print $6}'  | head -1)


while [[ $(sacct | grep $oxdMDjobid | awk '{print $6}'  | head -1 ) == RUNNING ]];
do
	sleep 5m
done

while [[ $(sacct | grep $redMDjobid | awk '{print $6}'  | head -1 ) == RUNNING ]];
do
	sleep 5m
done

echo "changing directory to $oxddir and submitting cpptraj, SP MD jobs for MD trajectories (prod, prod-rp and prod-rp1) after production runs is success" | tee -a $dirpath/$protein-$ligand-MD-logfile.txt
cd $dirpath/$oxddir
cat ../cpu-job-head.txt > $dirpath/$oxddir/cpptraj-rp-rp1.batch
echo "module load new_amber/20" >> $dirpath/$oxddir/cpptraj-rp-rp1.batch
echo "source $AMBERHOME/amber.sh" >> $dirpath/$oxddir/cpptraj-rp-rp1.batch
echo "cpptraj -i $dirpath/$oxddir/protein-reorgE-cpptraj.in
cpptraj -i $dirpath/$oxddir/protein-reorgE-cpptraj1.in
cpptraj -i $dirpath/$oxddir/protein-reorgE-cpptraj2.in" >> $dirpath/$oxddir/cpptraj-rp-rp1.batch
oxdcpptrajjobid=$(sbatch --dependency=afterok:$oxdMDjobid $dirpath/$oxddir/cpptraj-rp-rp1.batch | awk '{print $4}')

cat ../cpu-job-head.txt > $dirpath/$oxddir/sp-MD-rp-rp1.batch
echo "module load new_amber/20" >> $dirpath/$oxddir/sp-MD-rp-rp1.batch
echo "source $AMBERHOME/amber.sh" >> $dirpath/$oxddir/sp-MD-rp-rp1.batch
echo "$dirpath/$oxddir/./sp-MD.sh 
$dirpath/$oxddir/./sp-MD1.sh 
$dirpath/$oxddir/./sp-MD2.sh " >> $dirpath/$oxddir/sp-MD-rp-rp1.batch
oxdspMDjobid=$(sbatch --dependency=afterok:$oxdcpptrajjobid $dirpath/$oxddir/sp-MD-rp-rp1.batch | awk '{print $4}')

cat ../cpu-job-head.txt > $dirpath/$oxddir/sp-MD-prot-rp-rp1.batch
echo "module load new_amber/20
source $AMBERHOME/amber.sh " >> $dirpath/$oxddir/sp-MD-prot-rp-rp1.batch
echo "$dirpath/$oxddir/./sp-MD-prot.sh 
$dirpath/$oxddir/./sp-MD-prot1.sh 
$dirpath/$oxddir/./sp-MD-prot2.sh " >> $dirpath/$oxddir/sp-MD-prot-rp-rp1.batch
oxdspMDprotjobid=$(sbatch --dependency=afterok:$oxdcpptrajjobid $dirpath/$oxddir/sp-MD-prot-rp-rp1.batch | awk '{print $4}')

echo "changing directory to $reddir and submitting cpptraj, SP MD jobs for MD trajectories (prod, prod-rp and prod-rp1) after production runs is success" | tee -a $dirpath/$protein-$ligand-MD-logfile.txt
cd $dirpath/$reddir
cat ../cpu-job-head.txt > $dirpath/$reddir/cpptraj-rp-rp1.batch
echo "module load new_amber/20
source $AMBERHOME/amber.sh " >> $dirpath/$reddir/cpptraj-rp-rp1.batch
echo "cpptraj -i $dirpath/$reddir/protein-reorgE-cpptraj.in
cpptraj -i $dirpath/$reddir/protein-reorgE-cpptraj1.in
cpptraj -i $dirpath/$reddir/protein-reorgE-cpptraj2.in" >> $dirpath/$reddir/cpptraj-rp-rp1.batch
redcpptrajjobid=$(sbatch --dependency=afterok:$redMDjobid $dirpath/$reddir/cpptraj-rp-rp1.batch | awk '{print $4}')


cat ../cpu-job-head.txt > $dirpath/$reddir/sp-MD-rp-rp1.batch
echo "module load new_amber/20
source $AMBERHOME/amber.sh " >> $dirpath/$reddir/sp-MD-rp-rp1.batch
echo "$dirpath/$reddir/./sp-MD.sh 
$dirpath/$reddir/./sp-MD1.sh 
$dirpath/$reddir/./sp-MD2.sh " >> $dirpath/$reddir/sp-MD-rp-rp1.batch
redspMDjobid=$(sbatch --dependency=afterok:$redcpptrajjobid $dirpath/$reddir/sp-MD-rp-rp1.batch | awk '{print $4}')

cat ../cpu-job-head.txt > $dirpath/$reddir/sp-MD-prot-rp-rp1.batch
echo "module load new_amber/20
source $AMBERHOME/amber.sh " >> $dirpath/$reddir/sp-MD-prot-rp-rp1.batch
echo "$dirpath/$reddir/./sp-MD-prot.sh 
$dirpath/$reddir/./sp-MD-prot1.sh 
$dirpath/$reddir/./sp-MD-prot2.sh " >> $dirpath/$reddir/sp-MD-prot-rp-rp1.batch
redspMDprotjobid=$(sbatch --dependency=afterok:$redcpptrajjobid $dirpath/$reddir/sp-MD-prot-rp-rp1.batch | awk '{print $4}')


oxdspMDjobstatus=$(sacct | grep $oxdspMDjobid | awk '{print $6}'  | head -1 )

redspMDjobstatus=$(sacct | grep $redspMDjobid | awk '{print $6}'  | head -1 )

oxdspMDprotjobstatus=$(sacct | grep $oxdspMDprotjobid | awk '{print $6}'  | head -1 )

redspMDprotjobstatus=$(sacct | grep $redspMDprotjobid | awk '{print $6}'  | head -1 )



while [[ $(sacct | grep $oxdspMDjobid | awk '{print $6}'  | head -1 ) == RUNNING ]];
do
	sleep 2m
done

while [[ $(sacct | grep $redspMDjobid | awk '{print $6}'  | head -1 ) == RUNNING ]];
do
	sleep 2m
done

while [[ $(sacct | grep $oxdspMDprotjobid | awk '{print $6}'  | head -1 ) == RUNNING ]];
do
	sleep 2m
done

while [[ $(sacct | grep $redspMDprotjobid | awk '{print $6}'  | head -1 ) == RUNNING ]];
do
	sleep 2m
done

> $dirpath/$oxddir/$protein-$ligand-vertEs.txt
> $dirpath/$oxddir/AvgDE_$oxddir.txt
> $dirpath/$oxddir/AvgStdDE_$oxddir.txt
> $dirpath/$oxddir/AvgDEprot_$oxddir.txt
> $dirpath/$oxddir/AvgStdDEprot_$oxddir.txt
> $dirpath/$reddir/$protein-$ligand-vertEs.txt
> $dirpath/$reddir/AvgDE_$reddir.txt
> $dirpath/$reddir/AvgStdDE_$reddir.txt
> $dirpath/$reddir/AvgDEprot_$reddir.txt
> $dirpath/$reddir/AvgStdDEprot_$reddir.txt

calverE () {

        cd $dirpath/$1
        sto1D=$(grep -A1 NSTEP $dirpath/$1/$protein-$ligand-solv-$3.out | grep -v NSTEP | sed '/--/d' | awk '{print $2}' | st |  awk '{print $1, $5, $6}' | tail -n+2 | head -1)
        sto2D=$(grep -A1 NSTEP $dirpath/$1/$protein-$ligand-solv-$4.out | grep -v NSTEP | sed '/--/d' | awk '{print $2}' | st |  awk '{print $1, $5, $6}' | tail -n+2 | head -1)

        pto1D=$(grep -A1 NSTEP $dirpath/$1/$protein-$ligand-prot-$3.out | grep -v NSTEP | sed '/--/d' | awk '{print $2}' | st |  awk '{print $1, $5, $6}' | tail -n+2 | head -1)
        pto2D=$(grep -A1 NSTEP $dirpath/$1/$protein-$ligand-prot-$4.out | grep -v NSTEP | sed '/--/d' | awk '{print $2}' | st |  awk '{print $1, $5, $6}' | tail -n+2 | head -1)

        echo "$sto1D $sto2D $pto1D $pto2D $5" >> $dirpath/$1/$protein-$ligand-vertEs.txt
        sto1E=$(cat $dirpath/$1/$protein-$ligand-vertEs.txt | awk '{print $2}' | tail -1)
        stdev1E=$(cat $dirpath/$1/$protein-$ligand-vertEs.txt | awk '{print $3}' | tail -1)
        sto2E=$(cat $dirpath/$1/$protein-$ligand-vertEs.txt | awk '{print $5}' | tail -1)
        stdev2E=$(cat $dirpath/$1/$protein-$ligand-vertEs.txt | awk '{print $6}' | tail -1)

	pto1E=$(cat $dirpath/$1/$protein-$ligand-vertEs.txt | awk '{print $8}' | tail -1)
	ptdev1E=$(cat $dirpath/$1/$protein-$ligand-vertEs.txt | awk '{print $9}' | tail -1)
	pto2E=$(cat $dirpath/$1/$protein-$ligand-vertEs.txt | awk '{print $11}' | tail -1)
	ptdev2E=$(cat $dirpath/$1/$protein-$ligand-vertEs.txt | awk '{print $12}' | tail -1)

	AvgDE=$(bc -l <<< "scale=6; ( ($sto1E - $sto2E) * 0.043 )" | xargs printf "%6.6f")
	echo "AvgDE $AvgDE $5" >> $dirpath/$1/AvgDE_$1.txt
	AvgStdDE=$(bc -l <<< "scale=6; ( ($stdev1E - $stdev2E) * 0.043 )" | xargs printf "%4.6f")
	echo "AvgStdDE $AvgStdDE $5" >> $dirpath/$1/AvgStdDE_$1.txt

	AvgDEprot=$(bc -l <<< "scale=6; ( ($pto1E - $pto2E) * 0.043 )" | xargs printf "%6.6f")
	echo "AvgDEprot $AvgDEprot $5">> $dirpath/$1/AvgDEprot_$1.txt
	AvgStdDEprot=$(bc -l <<< "scale=6; ( ($ptdev1E - $ptdev2E) * 0.043 )" | xargs printf "%6.6f")
	echo "AvgStdDEprot $AvgStdDEprot $5">> $dirpath/$1/AvgStdDEprot_$1.txt

}

while [[ $spMDjobidrp1status == RUNNING ]];
do
	sleep 2m
done


calverE $oxddir $reddir fe3crdfe3prm fe3crdfe2prm prm
calverE $reddir $oxddir fe2crdfe2prm fe2crdfe3prm prm

calverE $oxddir $reddir fe3crdfe3prm-rp fe3crdfe2prm-rp -rp
calverE $reddir $oxddir fe2crdfe2prm-rp fe2crdfe3prm-rp -rp

calverE $oxddir $reddir fe3crdfe3prm-rp1 fe3crdfe2prm-rp1 -rp1
calverE $reddir $oxddir fe2crdfe2prm-rp1 fe2crdfe3prm-rp1 -rp1

echo "Printing Marcus ET parameters for $protein $ligand complex " > $dirpath/$ligand-MarcusET-parm.txt
echo "MD-traj AvgDEa AvgStdDEa AvgDEb AvgStdDEb lambdaET lambdaStdET DGET StdDGET lambdaETprot lambdaStdETprot cofacdis" >> $dirpath/$ligand-MarcusET-parm.txt
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
	        oxdcofacdis=$(tail -n +2 $dirpath/$oxddir/$protein-$ligand-FMN-HEMcontacts.dat | awk '{print $4}' | st | tail -1 | awk '{print $5}')
	        redcofacdis=$(tail -n +2 $dirpath/$reddir/$protein-$ligand-FMN-HEMcontacts.dat | awk '{print $4}' | st | tail -1 | awk '{print $5}')
	        avgcofacdis=$(bc -l <<< "scale=6; ( ( $oxdcofacdis + $redcofacdis )/2)" | xargs printf "%6.6f")
		echo "$1 $AvgDEoxd $AvgStdDEoxd $AvgDEred $AvgStdDEred $lambdaET $lambdaETStd $DGET $StdDGET $lambdaETprot $lambdaStdETprot $avgcofacdis" >> $dirpath/$ligand-MarcusET-parm.txt
	else
		oxdcofacdis=$(tail -n +2 $dirpath/$oxddir/$protein-$ligand-FMN-HEMcontacts"$1".dat | awk '{print $4}' | st | tail -1 | awk '{print $5}')
	        redcofacdis=$(tail -n +2 $dirpath/$reddir/$protein-$ligand-FMN-HEMcontacts"$1".dat | awk '{print $4}' | st | tail -1 | awk '{print $5}')
	        avgcofacdis=$(bc -l <<< "scale=6; ( ( $oxdcofacdis + $redcofacdis )/2)" | xargs printf "%6.6f")
		echo "$1 $AvgDEoxd $AvgStdDEoxd $AvgDEred $AvgStdDEred $lambdaET $lambdaETStd $DGET $StdDGET $lambdaETprot $lambdaStdETprot $avgcofacdis" >> $dirpath/$ligand-MarcusET-parm.txt
	fi
	
}

calMarcusETparm prm
calMarcusETparm -rp
calMarcusETparm -rp1
more $dirpath/$ligand-MarcusET-parm.txt

