#/bin/bash

curl -d @"mongo-flights.json" -H "Content-Type: application/json" -X POST http://localhost:8083/connectors