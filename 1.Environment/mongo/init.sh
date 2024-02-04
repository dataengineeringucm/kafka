#bin/bash

cd /setup/data

for filename in *.json; do mongoimport --host mongo --port 27017  --username admin --password admin --authenticationDatabase admin --db test --collection flights --jsonArray --file $filename; done
