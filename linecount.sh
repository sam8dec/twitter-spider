#!/bin/bash

# Folder name is Twitter
dumploc="Twitter"

# Takes the previous day's tweets by default
dumpdate="$(date --date yesterday +'%Y%m%d')"

# If a date is provided as an argument, it takes that date
if [ $# -ne 0 ]
    then
        dumpdate=$1
fi

export HADOOP_HOME=/scratch/hadoop/hadoop-1.0.2
export HBASE_HOME=/scratch/hadoop/hbase-0.94.22
export JAVA_HOME=/usr/lib/jvm/java-6-openjdk-amd64

if $HADOOP_HOME/bin/hadoop fs -test -d $dumploc'/'$dumpdate; then
    echo "Directory "$dumploc'/'$dumpdate" exists"
    cd /scratch2/hadoop/preprocess/lydia2-preprocess
    $HADOOP_HOME/bin/hadoop fs -get /user/hadoop/$dumploc/$dumpdate/$dumpdate.json .
    echo "Successfully downloaded file from HDFS. Now counting the number of lines."
    lines=`wc -l $dumpdate.json | awk '{print $1;}'`
    echo "put 'tweetcounts','$dumpdate','tweetcount:ALL','$lines'" | $HBASE_HOME/bin/hbase shell
    echo "Now deleting local file."
    rm $dumpdate.json
    echo "Done!"
else
    echo "[ERROR] Directory "$dumploc'/'$dumpdate" does not exist"
fi

