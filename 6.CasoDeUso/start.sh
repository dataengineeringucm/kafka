echo "Levantando entorno"

docker-compose up -d

echo "Esperando 60 sg a que connect levante"

sleep 60

docker-compose exec connect confluent-hub install --no-prompt confluentinc/kafka-connect-datagen:0.6.3

docker-compose exec connect confluent-hub install --no-prompt confluentinc/kafka-connect-jdbc:10.7.4

docker-compose exec connect confluent-hub install --no-prompt  mongodb/kafka-connect-mongodb:1.11.2

docker cp $PWD/mysql/mysql-connector-java-5.1.45.jar connect:/usr/share/confluent-hub-components/confluentinc-kafka-connect-jdbc/lib/mysql-connector-java-5.1.45.jar

docker-compose restart connect

echo "Esperando 60 sg a que connect reinicie"

sleep 60

./create-mongo-flights.sh

docker cp $PWD/statements.sql ksqldb-cli:/tmp/statements.sql

sleep 10

docker-compose exec ksqldb-cli bash -c "ksql -u ksqlDBUser -p ksqlDBUser http://ksqldb-server:8088 <<EOF
RUN SCRIPT '/tmp/statements.sql';
exit ;
EOF
"



