#/bin/bash

curl -d @"mysql-users-sink.json" -H "Content-Type: application/json" -X POST http://localhost:8083/connectors