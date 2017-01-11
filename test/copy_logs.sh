set -x
rsync -a --no-o --no-g LOGS $logs_publish_dir
chmod a+r $logs_publish_dir/*
cp -r ~/mdbci/$name $logs_publish_dir
cp  ~/mdbci/$name.json $logs_publish_dir
