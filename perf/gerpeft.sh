#!/bin/bash 

PERF_OUT=perf_result.csv


################################################
# Do not modify below this line
################################################
TFILE=/tmp/getperf_catx.txt

#################################
# Get the performance data for a given job id
# Output is appeded to csv file
#################################
GetPerf ()
{ 
    jobid=$1
    obtool catx -fl0 $jobid > $TFILE
    start_time=`cat $TFILE | grep start_time | awk '{print $NF}' | tr -d '(' | tr -d ')'`
    end_time=`cat $TFILE | grep end_time | awk '{print $NF}' | tr -d '(' | tr -d ')'`
    dev_iorate=`cat $TFILE | grep dev_iorate | awk '{printf ("%s %s", $3, $4)}'`
    wrt_iorate=`cat $TFILE | grep wrt_iorate | awk '{printf ("%s %s", $3, $4)}'`
    file_kb=`cat $TFILE | grep file_kbytes | awk '{printf ("%s", $3)}'`

    #files_cnt=`cat $TFILE | grep files | awk '{printf ("%s", $3)}'`

    echo $jobid,$start_time,$end_time,$dev_iorate,$wrt_iorate,$file_kb >> $PERF_OUT
}


######################################
# Main starts here
#####################################

GetPerf $1
