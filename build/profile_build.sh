#!/bin/bash
# This script may be useful for developers to profile the build process itself.
#
# This shell script runs CMake and make, dumping all output into a log file.
# It also logs the CPU usage and memory information during the build.
# All log messages are timestamped to enable profiling.
#
# Dependencies:
# - ts 
# sudo apt-get install -y libtime-duration-perl moreutils
# - vmstat and mpstat 
# sudo apt-get install -y sysstat
#
# Usage: ./profile_build.sh [num_parallel_jobs]
# The number of parallel make jobs can be passed as argument to this script.
# By default, it is the number of (virtual) CPUs on the machine (nproc).
# Set the CMake flags you want to use below.
#
# If CMakeCache.txt is detected, the script skips cmake and runs make only.
#

NUM_JOBS=`nproc`
if [[ "$1" != "" ]]; then 
    NUM_JOBS=$1
fi

echo "Starting build in " `pwd`  >> build.log
echo 

# Continuously dump memory usage and cpu load info to files for later analysis
rm -f stats_*.txt
vmstat -SM 3 | ts "%.s (%H:%M:%S)" > stats_mem.txt 3>&1 &
PID_vmstat=$!
mpstat 3 | ts "%.s (%H:%M:%S)" > stats_cpu.txt 2>&1  &
PID_mpstat=$!

START_TIME=`date +"%s"`
if [[ ! -f CMakeCache.txt ]]; then 
  CMAKE_COMMAND="cmake -D BUILD_SHARED_LIBS=On -D USE_TCMALLOC=0 \
               -D CMAKE_BUILD_TYPE=Debug \
               -D CMAKE_C_COMPILER=/usr/bin/clang -D CMAKE_CXX_COMPILER=/usr/bin/clang++ .. "
  echo "$CMAKE_COMMAND" | tee -a build.log
  if ! $CMAKE_COMMAND 2>&1 | ts "%.s (%H:%M:%S)" | tee -a build.log; then exit 1; fi
else 
  echo "CMakeCache.txt detected. Not running CMake again."
fi

MAKE_COMMAND="make VERBOSE=1 -j $NUM_JOBS"
echo "$MAKE_COMMAND" | tee -a build.log
if ! $MAKE_COMMAND 2>&1 | ts "%.s (%H:%M:%S)" | tee -a build.log; then exit 1; fi

END_TIME=`date +"%s"`

kill $PID_vmstat
kill $PID_mpstat

avg_mem=`grep -v r stats_mem.txt | tr -s ' ' | awk -F " " '{s+= $6; c++} END {print s/c/1024}'`
echo
echo
echo "Average memory used was $avg_mem GB"  | tee -a build.log

time_taken=`expr $END_TIME - $START_TIME`
mins=`expr $time_taken / 60`
secs=`expr $time_taken % 60`
echo "Time taken was ${mins}m ${secs}s" | tee -a build.log
