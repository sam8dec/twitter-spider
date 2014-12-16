#!/bin/bash

# Folder name is Twitter
dumploc="Twitter"

# Takes the previous day's tweets by default
dumpdate="$(date --date yesterday +'%Y%m%d')"

if [ $# -ne 0 ]
    then
        dumpdate=$1
fi

export HADOOP_HOME=/scratch/hadoop/hadoop-1.0.2
export HBASE_HOME=/scratch/hadoop/hbase-0.94.22
export JAVA_HOME=/usr/lib/jvm/jdk1.7.0_45
export LOCAL_DUMP_LOC=/scratch2/hadoop/Twitter/dumps

if $HADOOP_HOME/bin/hadoop fs -test -d $dumploc; then
    echo "Directory "$dumploc" exists"
else
    echo "Creating Directory "$dumploc
    $HADOOP_HOME/bin/hadoop fs -mkdir $dumploc
fi
if $HADOOP_HOME/bin/hadoop fs -test -d $dumploc'/'$dumpdate; then
    echo "Directory "$dumploc'/'$dumpdate" exists"
else
    echo "Creating Directory "$dumploc'/'$dumpdate
    $HADOOP_HOME/bin/hadoop fs -mkdir $dumploc'/'$dumpdate
fi
echo "Now putting $LOCAL_DUMP_LOC/$dumpdate.json to HDFS"
$HADOOP_HOME/bin/hadoop fs -put $LOCAL_DUMP_LOC'/'$dumpdate.json $dumploc'/'$dumpdate'/'
echo "Now counting number of tweets"
lines=`wc -l $LOCAL_DUMP_LOC'/'$dumpdate.json | awk '{print $1;}'`
# Store the count in an HBase Table
echo "put 'andy_tweetcounts','$dumpdate','tweetcount:ALL','$lines'" | $HBASE_HOME/bin/hbase shell
echo "Deleting $LOCAL_DUMP_LOC/$dumpdate.json from disk"
rm $LOCAL_DUMP_LOC'/'$dumpdate.json
echo "Done!"

