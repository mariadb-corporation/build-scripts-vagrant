#!/bin/bash


machines_count=$1
template_raw=$2
conf_file_name="`pwd`/$provider-$box-$machines_count-$JOB_NAME-$BUILD_ID"
cp $template_raw $conf_file_name
# TODO generate description for each node_00N and serverN+1.cnf and put it to the $results
results=""

# TODO write results to $conf_file_name
results=`echo ${results} | tr '\n' "\\n"` # Multiline sed hack
sed -i "s/###nodes###/${results}/g" $conf_file_name

echo $conf_file_name
