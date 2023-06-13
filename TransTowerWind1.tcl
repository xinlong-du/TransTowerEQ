# --------------------------------------------------------------------------------------------------
# 3D Steel L-section transmission tower
# Xinlong Du, 7/18/2019
# DispBeamColumn element, inelastic fiber section
# --------------------------------------------------------------------------------------------------
set systemTime [clock seconds] 
puts "Starting Analysis: [clock format $systemTime -format "%d-%b-%Y %H:%M:%S"]"
set startTime [clock clicks -milliseconds];
# SET UP --------------------------------------------------------------------------------
wipe;				# clear memory of all past model definitions
set pid [getPID]
set np [getNP]
puts "Processor $pid of $np number of processors"

model BasicBuilder -ndm 3 -ndf 6;	# Define the model builder, ndm=#dimension, ndf=#dofs
set dataDir Data;			# set up name of data directory
file mkdir $dataDir; 			# create data directory
source LibUnits.tcl;			# define units

# define GEOMETRY ------------------------------------------------------------------
# ------ define nodes
source INPnodes.tcl; # 1 input
# ------ define boundary conditions
fix 93 1 1 1 1 1 1; #do we need to use a pin connection?
fix 66 1 1 1 1 1 1;
fix 34 1 1 1 1 1 1;
fix 4  1 1 1 1 1 1;

# Define  SECTIONS ------------------------------------------------------------------
# define MATERIAL properties and residual stress patterns
source INPmaterial.tcl;

# define fiber SECTION properties
source INPLsection.tcl; # 2 input

# --------------------------------------------------------------------------------------------------------------------------------
# define ELEMENTS
# set up geometric transformations of element: Corotational
source INPgeometricTransformation.tcl; # 3 input

# Define Beam-Column Elements
set numIntgrPts 2;	# number of Gauss integration points for nonlinear curvature distribution
source INPelements.tcl; # 4 input

# --------------------------------------------------------------------------------------------------------------------------------
# Define masses              this may be too heavy
set massG1 [expr 5.80*$kip/$g];
set massG2 [expr 5.80*$kip/$g];
set massC1 [expr 12.55*$kip/$g];
set massC2 [expr 12.55*$kip/$g];
set massC3 [expr 12.55*$kip/$g];
mass 119 $massG1 $massG1 $massG1 0.0 0.0 0.0;
mass 128 $massG2 $massG2 $massG2 0.0 0.0 0.0;
mass 91  $massC1 $massC1 $massC1 0.0 0.0 0.0;
mass 129 [expr $massC2/2.0] [expr $massC2/2.0] [expr $massC2/2.0] 0.0 0.0 0.0;
mass 124 [expr $massC2/2.0] [expr $massC2/2.0] [expr $massC2/2.0] 0.0 0.0 0.0;
mass 99  [expr $massC3/2.0] [expr $massC3/2.0] [expr $massC3/2.0] 0.0 0.0 0.0;
mass 130 [expr $massC3/2.0] [expr $massC3/2.0] [expr $massC3/2.0] 0.0 0.0 0.0;

# define GRAVITY -------------------------------------------------------------
# GRAVITY LOADS # define gravity load
pattern Plain 101 Linear {
	#source NodeGravity.tcl
	load 119 0.0 [expr -5.8*$kip]   0.0 0.0 0.0 0.0;
	load 128 0.0 [expr -5.8*$kip]   0.0 0.0 0.0 0.0;
	load 91  0.0 [expr -12.55*$kip] 0.0 0.0 0.0 0.0;
	load 129 0.0 [expr -6.275*$kip] 0.0 0.0 0.0 0.0;
	load 124 0.0 [expr -6.275*$kip] 0.0 0.0 0.0 0.0;
	load 99  0.0 [expr -6.275*$kip] 0.0 0.0 0.0 0.0;
	load 130 0.0 [expr -6.275*$kip] 0.0 0.0 0.0 0.0;
}

# apply GRAVITY-- # apply gravity load, set it constant and reset time to zero, load pattern has already been defined
puts goGravity
# Gravity-analysis parameters -- load-controlled static analysis
set Tol 1.0e-8;			# convergence tolerance for test
constraints Plain;     		# how it handles boundary conditions
numberer RCM;			# renumber dof's to minimize band-width (optimization), if you want to
#system BandGeneral ;		# how to store and solve the system of equations in the analysis (large model: try UmfPack)
system UmfPack;
test EnergyIncr $Tol 50; 		# determine if convergence has been achieved at the end of an iteration step
#algorithm Newton;			# use Newton's solution algorithm: updates tangent stiffness at every iteration
algorithm KrylovNewton;
set NstepGravity 10;  		# apply gravity in 10 steps
set DGravity [expr 1./$NstepGravity]; 	# first load increment;
integrator LoadControl $DGravity;	# determine the next time step for an analysis
analysis Static;			# define type of analysis static or transient
analyze $NstepGravity;		# apply gravity
# ------------------------------------------------- maintain constant gravity loads and reset time to zero
loadConst -time 0.0
set Tol 1.0e-4;			# reduce tolerance after gravity loads
# -------------------------------------------------------------
puts "Model Built"
# --------------------------------------------------------------------------------------------------

# DYNAMIC wind analysis -------------------------------------------------------------
set loadPath "Series -dt 1 -filePath windForce/"
set LongAname "LongA.txt -factor 1";
set LongBname "LongB.txt -factor 1";
set LongCname "LongC.txt -factor 1";
set LongDname "LongD.txt -factor 1";
set LongEname "LongE.txt -factor 1";
set TranAname "TranA.txt -factor 1";
set TranBname "TranB.txt -factor 1";
set TranCname "TranC.txt -factor 1";
set TranDname "TranD.txt -factor 1";
set TranEname "TranE.txt -factor 1";
set TranConame "TranCo.txt -factor 1";
set TranGWname "TranGW.txt -factor 1";

#for loop and if branch here are not necessary because the code are copied to each processor
#for {set i 0} {$i<$np} {incr i 1} {
#	if {$i==$pid} {
		recorder Node -file $dataDir/$pid.out -time -dT 1.0 -node 119 128 111 112 -dof 1 2 3 disp;			# displacements
		# create load pattern
		set LongA $loadPath$pid$LongAname;
		set LongB $loadPath$pid$LongBname;
		set LongC $loadPath$pid$LongCname;
		set LongD $loadPath$pid$LongDname;
		set LongE $loadPath$pid$LongEname;
		set TranA $loadPath$pid$TranAname;
		set TranB $loadPath$pid$TranBname;
		set TranC $loadPath$pid$TranCname;
		set TranD $loadPath$pid$TranDname;
		set TranE $loadPath$pid$TranEname;
		set TranCo $loadPath$pid$TranConame;
		set TranGW $loadPath$pid$TranGWname;

		# Count the number of lines in the load file
		set fileName1 "windForce/";
		set fileName2 "TranCo.txt";
		set fileName $fileName1$pid$fileName2;
		set infile [open $fileName r]
		set nLines 0;
		# gets with two arguments returns the length of the line,
		# -1 if the end of the file is found
		while { [gets $infile line] >= 0 } {
		    incr nLines
		}
		close $infile
		puts "Number of lines: $nLines"
#	}
#}

pattern Plain 1 $TranGW -fact 1 {
	load 119 [expr 1.0*$kip] 0.0 0.0 0.0 0.0 0.0;			# node#, FX FY MZ -- representative lateral load 
	load 128 [expr 1.0*$kip] 0.0 0.0 0.0 0.0 0.0;
}
pattern Plain 2 $TranCo -fact 1 {
	load 91  [expr 1.0*$kip] 0.0 0.0 0.0 0.0 0.0;          # use WindSeriesGW to ensure all forces have the same pattern
	load 129 [expr 0.5*$kip] 0.0 0.0 0.0 0.0 0.0;
	load 124 [expr 0.5*$kip] 0.0 0.0 0.0 0.0 0.0;
	load 99  [expr 0.5*$kip] 0.0 0.0 0.0 0.0 0.0;
	load 130 [expr 0.5*$kip] 0.0 0.0 0.0 0.0 0.0;
}
pattern Plain 3 $TranA -fact 1 {
	load 78  [expr 0.5*$kip] 0.0 0.0 0.0 0.0 0.0;          # Seires TranA is 1/2 wind force on the surface
	load 84  [expr 0.5*$kip] 0.0 0.0 0.0 0.0 0.0;          # After using 0.5 here, the total wind force is 2*TranA
	load 117 [expr 0.5*$kip] 0.0 0.0 0.0 0.0 0.0;
	load 92  [expr 0.5*$kip] 0.0 0.0 0.0 0.0 0.0;
}
pattern Plain 4 $TranB -fact 1 {
	load 74  [expr 0.5*$kip] 0.0 0.0 0.0 0.0 0.0;          # Seires TranA is 1/2 wind force on the surface
	load 57  [expr 0.5*$kip] 0.0 0.0 0.0 0.0 0.0;          # After using 0.5 here, the total wind force is 2*TranA
	load 87  [expr 0.5*$kip] 0.0 0.0 0.0 0.0 0.0;
	load 69  [expr 0.5*$kip] 0.0 0.0 0.0 0.0 0.0;
}
pattern Plain 5 $TranC -fact 1 {
	load 43  [expr 0.5*$kip] 0.0 0.0 0.0 0.0 0.0;          # Seires TranA is 1/2 wind force on the surface
	load 39  [expr 0.5*$kip] 0.0 0.0 0.0 0.0 0.0;          # After using 0.5 here, the total wind force is 2*TranA
	load 29  [expr 0.5*$kip] 0.0 0.0 0.0 0.0 0.0;
	load 21  [expr 0.5*$kip] 0.0 0.0 0.0 0.0 0.0;
}
pattern Plain 6 $TranD -fact 1 {
	load 1   [expr 0.5*$kip] 0.0 0.0 0.0 0.0 0.0;          # Seires TranA is 1/2 wind force on the surface
	load 15  [expr 0.5*$kip] 0.0 0.0 0.0 0.0 0.0;          # After using 0.5 here, the total wind force is 2*TranA
	load 31  [expr 0.5*$kip] 0.0 0.0 0.0 0.0 0.0;
	load 25  [expr 0.5*$kip] 0.0 0.0 0.0 0.0 0.0;
}
pattern Plain 7 $TranE -fact 1 {
	load 3   [expr 0.5*$kip] 0.0 0.0 0.0 0.0 0.0;          # Seires TranA is 1/2 wind force on the surface
	load 52  [expr 0.5*$kip] 0.0 0.0 0.0 0.0 0.0;          # After using 0.5 here, the total wind force is 2*TranA
	load 10  [expr 0.5*$kip] 0.0 0.0 0.0 0.0 0.0;
	load 109 [expr 0.5*$kip] 0.0 0.0 0.0 0.0 0.0;
}
pattern Plain 8 $LongA -fact 1 {
	load 78  0.0 0.0 [expr 0.5*$kip] 0.0 0.0 0.0;          # Seires TranA is 1/2 wind force on the surface
	load 84  0.0 0.0 [expr 0.5*$kip] 0.0 0.0 0.0;          # After using 0.5 here, the total wind force is 2*TranA
	load 117 0.0 0.0 [expr 0.5*$kip] 0.0 0.0 0.0;
	load 92  0.0 0.0 [expr 0.5*$kip] 0.0 0.0 0.0;
}
pattern Plain 9 $LongB -fact 1 {
	load 74  0.0 0.0 [expr 0.5*$kip] 0.0 0.0 0.0;          # Seires TranA is 1/2 wind force on the surface
	load 57  0.0 0.0 [expr 0.5*$kip] 0.0 0.0 0.0;          # After using 0.5 here, the total wind force is 2*TranA
	load 87  0.0 0.0 [expr 0.5*$kip] 0.0 0.0 0.0;
	load 69  0.0 0.0 [expr 0.5*$kip] 0.0 0.0 0.0;
}
pattern Plain 10 $LongC -fact 1 {
	load 43  0.0 0.0 [expr 0.5*$kip] 0.0 0.0 0.0;          # Seires TranA is 1/2 wind force on the surface
	load 39  0.0 0.0 [expr 0.5*$kip] 0.0 0.0 0.0;          # After using 0.5 here, the total wind force is 2*TranA
	load 29  0.0 0.0 [expr 0.5*$kip] 0.0 0.0 0.0;
	load 21  0.0 0.0 [expr 0.5*$kip] 0.0 0.0 0.0;
}
pattern Plain 11 $LongD -fact 1 {
	load 1   0.0 0.0 [expr 0.5*$kip] 0.0 0.0 0.0;          # Seires TranA is 1/2 wind force on the surface
	load 15  0.0 0.0 [expr 0.5*$kip] 0.0 0.0 0.0;          # After using 0.5 here, the total wind force is 2*TranA
	load 31  0.0 0.0 [expr 0.5*$kip] 0.0 0.0 0.0;
	load 25  0.0 0.0 [expr 0.5*$kip] 0.0 0.0 0.0;
}
pattern Plain 12 $LongE -fact 1 {
	load 3   0.0 0.0 [expr 0.5*$kip] 0.0 0.0 0.0;          # Seires TranA is 1/2 wind force on the surface
	load 52  0.0 0.0 [expr 0.5*$kip] 0.0 0.0 0.0;          # After using 0.5 here, the total wind force is 2*TranA
	load 10  0.0 0.0 [expr 0.5*$kip] 0.0 0.0 0.0;
	load 109 0.0 0.0 [expr 0.5*$kip] 0.0 0.0 0.0;
}

rayleigh 0. 0. 0. [expr 2*0.02/pow([eigen 1],0.5)];		# set damping based on first eigen mode

# create the analysis
# wipeAnalysis;					# clear previously-define analysis parameters
constraints Plain;     				# how it handles boundary conditions
#numberer Plain;					# renumber dof's to minimize band-width (optimization), if you want to
numberer RCM;
#system BandGeneral;					# how to store and solve the system of equations in the analysis
system UmfPack;
test NormDispIncr $Tol 50;				# determine if convergence has been achieved at the end of an iteration step
#algorithm Newton;					# use Newton's solution algorithm: updates tangent stiffness at every iteration
algorithm KrylovNewton;
integrator Newmark 0.5 0.25;			# determine the next time step for an analysis
#algorithm Linear
#integrator CentralDifference
analysis Transient;					# define type of analysis: time-dependent

#for {set i 0} {$i<$np} {incr i 1} {
#	if {$i==$pid} {
		set nSteps [expr 10*($nLines-1)]
		puts "Number of steps: $nSteps"
		analyze $nSteps 0.1;
#	}
#}

puts "Done!"

#--------------------------------------------------------------------------------
set finishTime [clock clicks -milliseconds];
puts "Time taken: [expr ($finishTime-$startTime)/1000] sec"
set systemTime [clock seconds] 
puts "Finished Analysis: [clock format $systemTime -format "%d-%b-%Y %H:%M:%S"]"