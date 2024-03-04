set -u -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

echo "Levantando entorno"

docker-compose up -d

echo "Esperando 60 sg a que connect levante"

sleep 60

docker-compose exec connect confluent-hub install --no-prompt confluentinc/kafka-connect-datagen:0.6.3

docker-compose exec connect confluent-hub install --no-prompt confluentinc/kafka-connect-jdbc:10.7.4

docker cp $DIR/mysql/mysql-connector-java-5.1.45.jar connect:/usr/share/confluent-hub-components/confluentinc-kafka-connect-jdbc/lib/mysql-connector-java-5.1.45.jar

docker-compose restart connect

echo "Esperando 60 sg a que connect reinicie"

sleep 60

cd $DIR/../4.KafkaConnect/4.1.DatagenSourceConnector
./create-datagen-users.sh

cd $DIR/../4.KafkaConnect/4.2.MySQLSinkConnector
./create-users-mysql-sink.sh



