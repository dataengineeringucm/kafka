#!/bin/bash

cd /setup/data || exit

if [ -z "$(ls -A ./*.json)" ]; then
echo "No se encontraron archivos JSON en /setup/data."
exit 1
fi

for filename in *.json; do
mongoimport --host mongo --port 27017 --db test --collection flights --jsonArray --file "$filename"
done