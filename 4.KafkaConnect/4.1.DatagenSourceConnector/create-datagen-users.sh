#/bin/bash

curl -d @"datagen-users.json" -H "Content-Type: application/json" -X POST http://localhost:8083/connectors