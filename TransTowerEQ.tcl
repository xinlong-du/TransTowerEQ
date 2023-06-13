# --------------------------------------------------------------------------------------------------
# 3D Steel L-section transmission tower
# Xinlong Du, 2023
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
set numIntgrPts 5;	# number of Gauss integration points for nonlinear curvature distribution
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

# DYNAMIC ground-motion analysis -------------------------------------------------------------
# create load pattern
set accelSeries "Series -dt 0.01 -filePath BM68elc.acc -factor 1";	# define acceleration vector from file (dt=0.01 is associated with the input file gm)
pattern UniformExcitation 2 1 -accel $accelSeries;		# define where and how (pattern tag, dof) acceleration is applied

recorder Node -file $dataDir/$pid.out -time -dT 0.1 -node 119 128 111 112 -dof 1 2 3 disp;			# displacements

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
analyze 1000 0.02;

puts "Done!"

#--------------------------------------------------------------------------------
set finishTime [clock clicks -milliseconds];
puts "Time taken: [expr ($finishTime-$startTime)/1000] sec"
set systemTime [clock seconds] 
puts "Finished Analysis: [clock format $systemTime -format "%d-%b-%Y %H:%M:%S"]"