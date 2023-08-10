#!/bin/bash

## set -x

alias xtime='/usr/bin/time -f "CPU: %Us\tReal: %es\tElapsed: %E\tRAM: %MKB\t%C"'
function techo() { 
	echo ">>> $(date '+%Y/%m/%d %H:%M:%S.%3N'): $1";
}

V="${V:-./v}"
CC="${CC:-gcc}"
V_OPTIONS="${V_OPTIONS:--prod}"
VO='-keepc'
PROGRAM="${PROGRAM:-examples/nbody.v}"
PROGRAM_OPTIONS="${PROGRAM_OPTIONS:-}"
HYPERFINE_OPTIONS="${HYPERFINE_OPTIONS:- --warmup=1 --shell=none}"

techo "CC: $CC | VO: '$VO' | V_OPTIONS: '$V_OPTIONS' | PROGRAM: $PROGRAM | PROGRAM_OPTIONS: '$PROGRAM_OPTIONS' | HYPERFINE_OPTIONS: '$HYPERFINE_OPTIONS'"

## ensure a clean experiment
techo "Cleanup..."
rm -rf profile_folder/
$V wipe-cache

techo "Compiling normal ..."
xtime $V $VO $V_OPTIONS -cc $CC                                           -o normal           $PROGRAM

techo "Compiling pgo_profile ..."
xtime $V $VO $V_OPTIONS -cc $CC -cflags -fprofile-generate=profile_folder -o pgo_profile $PROGRAM
xtime ./pgo_profile $PROGRAM_OPTIONS
techo "Compiling pgo ..."
xtime $V $VO $V_OPTIONS -cc $CC -cflags -fprofile-use=profile_folder      -o pgo         $PROGRAM

ls -lart normal pgo_profile pgo

techo "Measuring normal vs pgo, with hyperfine $HYPERFINE_OPTIONS"
hyperfine $HYPERFINE_OPTIONS "./normal $PROGRAM_OPTIONS" "./pgo $PROGRAM_OPTIONS"
hyperfine $HYPERFINE_OPTIONS "./normal $PROGRAM_OPTIONS" "./pgo $PROGRAM_OPTIONS"
hyperfine $HYPERFINE_OPTIONS "./normal $PROGRAM_OPTIONS" "./pgo $PROGRAM_OPTIONS"
