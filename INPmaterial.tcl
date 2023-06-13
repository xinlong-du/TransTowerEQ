# define MATERIAL properties
set E [expr 29000.0*$ksi];		# Steel Young's Modulus
set nu 0.3;
set G [expr $E/2./[expr 1+$nu]];  # Torsional stiffness Modulus
set Fy36 [expr 36.0*$ksi];
set Fy50 [expr 50.0*$ksi];
set Biso 0.031;
set matID36 3600;
set matID50 5000;
uniaxialMaterial Steel01 $matID36 $Fy36 $E $Biso;
uniaxialMaterial Steel01 $matID50 $Fy50 $E $Biso;

# residual stress for A36 Steel
set matID361 3601;
set matID362 3602;
set matID363 3603;
set matID364 3604;
set matID365 3605;
set matID366 3606;
set matID367 3607;
set matID368 3608;
set matID369 3609;
set matID3610 3610;
set matID3611 3611;
set matID3612 3612;
set matID3613 3613;
set matID3614 3614;
set matID3615 3615;
set matID3616 3616;
set matID3617 3617;

uniaxialMaterial InitStressMaterial $matID361 $matID36 [expr -0.3*$Fy36];
uniaxialMaterial InitStressMaterial $matID362 $matID36 [expr -0.15*$Fy36];
uniaxialMaterial InitStressMaterial $matID363 $matID36 [expr 0.0*$Fy36];
uniaxialMaterial InitStressMaterial $matID364 $matID36 [expr 0.15*$Fy36];
uniaxialMaterial InitStressMaterial $matID365 $matID36 [expr 0.3*$Fy36];
uniaxialMaterial InitStressMaterial $matID366 $matID36 [expr 0.15*$Fy36];
uniaxialMaterial InitStressMaterial $matID367 $matID36 [expr 0.0*$Fy36];
uniaxialMaterial InitStressMaterial $matID368 $matID36 [expr -0.15*$Fy36];
uniaxialMaterial InitStressMaterial $matID369 $matID36 [expr -0.3*$Fy36];
uniaxialMaterial InitStressMaterial $matID3610 $matID36 [expr -0.15*$Fy36];
uniaxialMaterial InitStressMaterial $matID3611 $matID36 [expr 0.0*$Fy36];
uniaxialMaterial InitStressMaterial $matID3612 $matID36 [expr 0.15*$Fy36];
uniaxialMaterial InitStressMaterial $matID3613 $matID36 [expr 0.3*$Fy36];
uniaxialMaterial InitStressMaterial $matID3614 $matID36 [expr 0.15*$Fy36];
uniaxialMaterial InitStressMaterial $matID3615 $matID36 [expr 0.0*$Fy36];
uniaxialMaterial InitStressMaterial $matID3616 $matID36 [expr -0.15*$Fy36];
uniaxialMaterial InitStressMaterial $matID3617 $matID36 [expr -0.3*$Fy36];

# residual stress for Grade50 Steel
set matID501 5001;
set matID502 5002;
set matID503 5003;
set matID504 5004;
set matID505 5005;
set matID506 5006;
set matID507 5007;
set matID508 5008;
set matID509 5009;
set matID5010 5010;
set matID5011 5011;
set matID5012 5012;
set matID5013 5013;
set matID5014 5014;
set matID5015 5015;
set matID5016 5016;
set matID5017 5017;

uniaxialMaterial InitStressMaterial $matID501 $matID50 [expr -0.3*$Fy50];
uniaxialMaterial InitStressMaterial $matID502 $matID50 [expr -0.15*$Fy50];
uniaxialMaterial InitStressMaterial $matID503 $matID50 [expr 0.0*$Fy50];
uniaxialMaterial InitStressMaterial $matID504 $matID50 [expr 0.15*$Fy50];
uniaxialMaterial InitStressMaterial $matID505 $matID50 [expr 0.3*$Fy50];
uniaxialMaterial InitStressMaterial $matID506 $matID50 [expr 0.15*$Fy50];
uniaxialMaterial InitStressMaterial $matID507 $matID50 [expr 0.0*$Fy50];
uniaxialMaterial InitStressMaterial $matID508 $matID50 [expr -0.15*$Fy50];
uniaxialMaterial InitStressMaterial $matID509 $matID50 [expr -0.3*$Fy50];
uniaxialMaterial InitStressMaterial $matID5010 $matID50 [expr -0.15*$Fy50];
uniaxialMaterial InitStressMaterial $matID5011 $matID50 [expr 0.0*$Fy50];
uniaxialMaterial InitStressMaterial $matID5012 $matID50 [expr 0.15*$Fy50];
uniaxialMaterial InitStressMaterial $matID5013 $matID50 [expr 0.3*$Fy50];
uniaxialMaterial InitStressMaterial $matID5014 $matID50 [expr 0.15*$Fy50];
uniaxialMaterial InitStressMaterial $matID5015 $matID50 [expr 0.0*$Fy50];
uniaxialMaterial InitStressMaterial $matID5016 $matID50 [expr -0.15*$Fy50];
uniaxialMaterial InitStressMaterial $matID5017 $matID50 [expr -0.3*$Fy50];