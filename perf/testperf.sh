#!/bin/bash 
#################################################################
# This program runs backup job to test the performance for 
# various tunable parameters.
# The out is written in CSV file
################################################################

DS=30gb
DEV=cloud2
FAM=6hr


################################################################
# Wait for completion of backup job
################################################################
waitForJob ()
{
    jobnum=$1
    while [ 1 ]
    do
        gret=`obtool -u admin lsj | grep $jobnum`
        gtry=`obtool -u admin lsj | grep $jobnum | grep -i retry`
        if [[ -z "${gret// }" ]]
        then
            echo "job $jobnum completed"
            obtool -u admin lsjob $jobnum
            return
        fi

        if [[ ! -z "${gtry// }" ]]
        then
            echo "cancelling $jobnum"
            obtool -u admin lsj $jobnum.1
            obtool -u admin cancel $jobnum.1
            obtool -u admin chdev -o $DEV
        fi
        sleep 10
    done
}

# perfmomance settings
# segmetn size,blocksize,streams

setParams ()
{
   inval=$1
   seg=`echo $inval | awk -F',' '{print $1}'`
   blk=`echo $inval | awk -F',' '{print $2}'`
   stm=`echo $inval |awk -F',' '{print $3}'`

   obtool setp cloud/segmentsize $seg
   obtool setp cloud/streamsperjob $stm
   obtool setp media/blocking $blk
}

################################################################
# Get performance data
################################################################
GetPerf ()
{
    TFILE=/tmp/getperf_catx.txt

    jobid=$1
    obtool catx -fl0 $jobid > $TFILE
    start_time=`cat $TFILE | grep start_time | awk '{print $NF}' | tr -d '(' | tr -d ')'`
    end_time=`cat $TFILE | grep end_time | awk '{print $NF}' | tr -d '(' | tr -d ')'`
    dev_iorate=`cat $TFILE | grep dev_iorate | awk '{printf ("%s %s", $3, $4)}'`
    wrt_iorate=`cat $TFILE | grep wrt_iorate | awk '{printf ("%s %s", $3, $4)}'`
    file_kb=`cat $TFILE | grep file_kbytes | awk '{printf ("%s", $3)}'`

    #files_cnt=`cat $TFILE | grep files | awk '{printf ("%s", $3)}'`

    echo $jobid,$start_time,$end_time,$dev_iorate,$wrt_iorate,$file_kb >> perf_result.csv
}



######################################
# Main starts here
#####################################

# login and list host details
obtool -u admin lsh

# Tunable parameters
# Segment size, Blocking factor, streams per job

param="
10mb,128,4
10mb,4096,4
100mb,4096,4
200mb,4096,4
200mb,4096,8
200mb,4096,10
1GB,4096,10
"


## Do the work here
for i in $param
do
    # Set and print tuable parameters
    setParams $i
    echo $i
    
    # submit a new backup job and get job id
    jout=`obtool -u admin backup -D $DS -f $FAM -r $DEV --go`
    jnum=`echo $jout | awk '{print $NF}' | tr -d "."`

    # wait for the backup job to complete
    echo "submitted job $jnum with $i"
    waitForJob $jnum

    # Get Perforamnce data for the job.
    GetPerf $jnum
done

