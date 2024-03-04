#bin/bash

cd /setup/data

for filename in *.json; do mongoimport --host mongo --port 27017  --db test --collection flights --jsonArray --file $filename; done