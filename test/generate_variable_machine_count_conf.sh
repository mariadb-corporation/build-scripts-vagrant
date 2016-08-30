#!/bin/bash

if [ "$#" -ne 5 ]; then
	echo "Illegal number of parameters"
	echo "Usage: ./test/generate_variable_machine_count_conf.sh $machines_count $config_template_raw $server_cnf_path $node_template $server_cnf_template"
	exit 1
fi

machines_count=$1
template_raw=${2}
server_cnf_path=${3}
node_template=${4}
server_cnf_template=${5}

conf_file_name="`pwd`/$provider-$box-$machines_count-$JOB_NAME-$BUILD_ID"
cp $template_raw $conf_file_name
# TODO generate description for each node_00N and serverN+1.cnf and put it to the $results
results=""

mkdir -p ${server_cnf_path}

for i in `seq 1 $machines_count`; 
do
	echo "Generating $i node"
        # Configuring node number
        N=$(printf "%03d" $(( i - 1)) )
	node=`cat ${node_template} | sed -e "s/###N###/$N/g" `

	# Configuring cnf_template
        node=`cat ${node} | sed -e "s/###server.cnf###/server${i}.cnf/g" `

	# Configuring cnf_template_path
        node=`cat ${node} | sed -e "s/###server.cnf_path###/${server_cnf_path}/g" `

	# Generating server.cnf 
	generated_server_cnf="${server_cnf_path}/server${i}.cnf"
	if [ ! -f "${generated_server_cnf}"]
	then
		cp ${server_cnf_template} ${generated_server_cnf}
		sed -i "s/###id###/$i/g" ${generated_server_cnf}
	fi


	# Concatination of generated node
	result="${result}\n${node}"
done

results=`echo ${results} | tr '\n' "\\n"` # Multiline sed hack
sed -i "s/###nodes###/${results}/g" $conf_file_name

echo $conf_file_name
