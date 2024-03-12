echo "Levantando entorno"

set -u -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
      echo "Ejecutando en Linux cambio no necesario"
elif [[ "$OSTYPE" == "darwin"* ]]; then
      echo "Ejecutando en MAC cambio no necesario"
elif [[ "$OSTYPE" == "cygwin" ]]; then
      echo "Ejecutando en Cygwin swapeando retornos de carro"
      sed -i 's/\r//' $DIR/mongo/init.sh
elif [[ "$OSTYPE" == "msys" ]]; then
       echo "Ejecutando en Cygwin swapeando retornos de carro"
       sed -i 's/\r//' $DIR/mongo/init.sh
else
       echo "OS desconocido swapeando retornos de carro"
       sed -i 's/\r//' $DIR/mongo/init.sh
fi

docker-compose up -d

echo "Esperando 120 sg a que connect levante"

sleep 120

docker-compose exec connect confluent-hub install --no-prompt confluentinc/kafka-connect-datagen:0.6.3

docker-compose exec connect confluent-hub install --no-prompt confluentinc/kafka-connect-jdbc:10.7.4

docker-compose exec connect confluent-hub install --no-prompt  mongodb/kafka-connect-mongodb:1.11.2

docker cp $DIR/mysql/mysql-connector-java-5.1.45.jar connect:/usr/share/confluent-hub-components/confluentinc-kafka-connect-jdbc/lib/mysql-connector-java-5.1.45.jar

docker-compose restart connect

echo "Esperando 120 sg a que connect reinicie"

sleep 120

$DIR/create-mongo-flights.sh

docker cp $DIR/statements.sql ksqldb-cli:/tmp/statements.sql

echo "Esperando 60 sg a la creación de las queries KSQL"
sleep 60

docker-compose exec ksqldb-cli bash -c "ksql -u ksqlDBUser -p ksqlDBUser http://ksqldb-server:8088 <<EOF
RUN SCRIPT '/tmp/statements.sql';
exit ;
EOF
"


