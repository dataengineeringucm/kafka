
# Kafka - Práctica Guiada

## Prerrequisitos

* Docker Instalado: Para facilitar la práctica y el manejo montaremos nuestro propio "cluster" de Kafka en contenedores docker.

  [Instala Docker](https://docs.docker.com/get-docker/)

* JDK 11+ Instalado
* Maven Instalado

**Nota:** Para la instalación de SDKs mi recomendación es usar [SDKman](https://sdkman.io/)

## Organización del Repositorio

El repositorio estará organizado en carpetas, por temática (API), dentro de la cual encontraréis una
con el ejercicio propuesto a resolver y otra con el ejercicio resuelto.

El proyecto contiene bash script, código Python y código Java organizado en dos módulos Maven, para 
compilar el proyecto situarse en la carpeta root y ejecutar:

````bash
mvn clean install
````

## Arrancando el Clúster

Abre la carpeta _**1.Environment**_ :

Para la ejecución de un cluster multinodo completo ejecuta:

```bash
docker-compose up -d
```

## Admin API

En este apartado veremos como setear algunas de las propiedades basicas de Kafka.

Para ver el listado de todas las configuraciones posibles:

[Kafka Broker-Level Config](http://kafka.apache.org/10/documentation.html#brokerconfigs)

[Kafka Topic-Level Configs](http://kafka.apache.org/10/documentation.html#topicconfigs)

### Settings Básicos

Utilizaremos el comando kafka-configs que nos da la instalación de kafka para comprobar el estado de
algunos settings básicos de nuestro clúster, para ello deberemos ejecutar dicho comando dentro de
cualquiera de nuestros broker.

Por tanto lo primero que necesitaremos será habilitar una consola interactiva dentro del contenedor
de uno de nuestros broker para lo que ejecutamos:

```bash
docker exec -it broker-1 /bin/bash
```

Una vez dentro ejecutaremos el comando **kafka-configs** para listar la configuración de brokers
activa en este momento:

```bash
kafka-configs --bootstrap-server broker-1:29092 --entity-type brokers --describe --all
```

### Ejercicio 1 - Administración de Configuración básica del clúster desde línea de comandos

````text
1. Utiliza el comando **kafka-configs** para setear la propiedad _message.max.bytes_ a _512_ en el broker 1

2. Utiliza el comando **kafka-configs** para comprobar el efecto de tu acción.

3. Utiliza el comando **kafka-configs** para setear la propiedad _message.max.bytes_ a _512_ en todos los brokers

4. Revierte la propiedad al valor por defecto para todos los broker.

5. ¿Qué pasa si usa configuración solo existe en un broker e intentamos borrarla de todos a la vez?, ¿Testealo con los scripts anteriores?
````

### Creación y Administración de un Topic

Utilizaremos el comando **kafka-topics** para crear y administrar topics dentro de nuestro cluster:

Para monitorizar lo que está pasando en nuestro cluster, abriremos el log de cada broker en una
consola aparte ejecutando:

````bash
docker logs -f broker-<id>
````

Dentro del contenedor (recuerda docker exec...) de cual quiera de nuestros broker ejecutaremos:

````bash
kafka-topics --bootstrap-server broker-1:29092 --create --topic my-topic --partitions 1 --replication-factor 1 --config max.message.bytes=64000 --config flush.messages=1
````

Vamos a modificar el numero de particiones y replicas de nuestro topic y observemos lo que pasa:

Para el número de particiones:

````bash
kafka-topics --bootstrap-server broker-1:29092 --alter --topic my-topic --partitions 2
````

El incremento de réplicas más "tricky", necesitaremos reasignar la réplica de cada partición a
mano (algo a evitar tanto como sea posible).

Primero necesitamos saber cual es la configuración actual del topic:

```bash
kafka-topics --bootstrap-server broker-1:29092 --topic my-topic --describe
```

También necesitaremos un fichero JSON que describa esta reasignación,
increase-replication-factor.json:

```JSON
{
  "version": 1,
  "partitions": [
    {
      "topic": "my-topic",
      "partition": 0,
      "replicas": [
        1,
        3,
        2
      ]
    },
    {
      "topic": "my-topic",
      "partition": 1,
      "replicas": [
        2,
        3,
        1
      ]
    }
  ]
}
```

Para crear el archivo dentro de nuestro broker podemos usar el comando:

```bash
cat << EOF > increase-replication-factor.json
```

y pegar el contenido del mensaje en el prompt

Por último ejecutaremos el comando:

```bash
kafka-reassign-partitions --bootstrap-server broker-1:29092 --reassignment-json-file    increase-replication-factor.json --execute
```

### Ejercicio 2 - Administración de Topics

````text
1. Crea un topic con 1 particion, factor de replica 1, y que sincronice tras 5 mensajes

2. Cambia el número de particiones a 3 y reasigna la replicación de manera óptima.

3. Cambia la configuración de sincronizacón para que esta se haga tras cada mensaje.

4. Experimenta matando y levantando brokers, ¿Crees que tu asignación del factor de replica fue adecuada?
````

## Producer / Consumer API

### Console Producer

Primero crea un topic **console-example** con 3 particiones y factor de réplica 3.

Produciremos varios mensajes en el topic mediante el comando kafka-console-producer y observaremos el comportamiento:

El mensaje a producir será uno simple que solo contendrá un id como body:

```JSON
1,{"id": "1"}
```

```bash
kafka-console-producer --bootstrap-server broker-1:29092 --topic console-example --property "parse.key=true" --property "key.separator=,"
```

Ahora crearemos un consumidor de consola:

```bash
kafka-console-consumer --bootstrap-server broker-1:29092 --topic console-example --property print.key=true --from-beginning
```

¿Qué pasa cuando este arranca?:

<details>
  <summary><b>Solución</b></summary>

¡El consumidor consume todos los mensajes!.
</details>

¿Que pasara si añadimos otro consumidor?

<details>
  <summary><b>Solución</b></summary>

¡Tenemos dos consumidores consumiendo exactamente los mismos mensajes!.
</details>



Ahora introduciremos dos consumidores formando un grupo de consumo:

```bash
kafka-console-consumer --bootstrap-server broker-1:29092 --topic console-example --property print.key=true --from-beginning  --consumer-property group.id=console-group-1
```

Observad el rebalanceo y particionado que se produce mediante la partition key elegida. ¿Qué casos de uso encontramos para esta funcionalidad?.

### Ejercicio1 - Console Producer / Consumer

````text
Necesitamos crear un productor para que un operador desde consola introduzca las lecturas de n (15??) medidores de temperatura de una sala.

Cada lectura la recibira un dispositivo distinto simulado a través de un consumidor de consola independentiente, queremos que cada consumidor solo reciba la medición correspondiente a su medidor teniendo en cuenta que es muy importante preservar el orden de las mediciones tomadas.
````

### Java/Python Producer / Consumer

**Nota:** Si eliges Python como lenguaje, necesitarás instalar el módulo kafka

```bash
pip install confluent-kafka
```

Ejemplo de ejecución de los scripts python

```bash
python simpleProducer.py 127.0.0.1:9092 simple-topic
```

Observemos la configuración de la clase SimpleProducer. ¿Qué pasa en nuestro cluster si la ejecutamos "directamente"?

```text
Usa el comando kafka-topics para ver que ha pasado con nuestro simple-topic
```

Es momento ahora de crear nuestro primer consumidor. ¿Sabrías decir que pasará cuando arranquemos nuestro SimpleConsumer1?

¿Que pasará si arrancamos SimpleConsumer2 y SimpleConsumer3? (o más instancias de simpleConsumer.py)

<details>
  <summary><b>Solución</b></summary>

Estarán preparados para consumir, pero no consumirán nada, ya que todos los mensajes han sido consumidos por en el arranque anterior y nuestros nuevos procesos pertenecen al mismo grupo de consumo.
</details>

¿Y si corremos de nuevo SimpleProducer?, ¿Habrá algún cambio en la manera de consumir?

<details>
  <summary><b>Solución</b></summary>

Los nuevos mensajes empezarán a ser consumidos por el proceso perteneciente al grupo que tenga la partición a la que corresponda el mensaje asignada. 
</details>

```text
Ejemplos python traidos desde:

https://github.com/confluentinc/confluent-kafka-python
```

### Ejercicio2 - Console Producer / Consumer

````text
Es tiempo ahora de volver a nuestro medidor de temperatura. Esta vez simularemos cada dispositivo en una clase productora equivalente.

De nuevo necesitamos que los eventos de cada medidor sean atendidos por un solo consumidor y en el orden establecido.
````

### Java Transactional Producer/Consumer (Exactly Once Semantics)

En la carpeta tx del punto 3.1 encontraremos un ejemplo de un productor consumidor transaccional, es decir que asegura una semantica Exactly Once!.

Hay que tener en cuenta que esta semántica solo esta garantizada out of the box en operaciones dentro del cluster es decir cuando consumimos un topic para producir en otro. 

De ese modo debemos asegurar la idempotencia de los mensajes que producimos, asegurar la entrega de los mismos (minimo de ACKS de cada réplica), además en la parte consumidora tendremos que asegurar la transacción en la producción a nuestro topic de salida (recordamos que produciremos en otro topic) poniendo el isolation level en READ_COMMITED, es decir solo consumiremos aquellos mensajes que vengan marcados como comiteados por el productor.

Para los casos en los que no escribamos en otro topic tendra que ser la lógica de consumo la que asegure la transaccionalidad en su parte.

**¡De este modo como veremos más adelante las APIs construidas por encima de producer consumer asegura esta semántica by the face!.**

#### TX Word Count

En este ejemplo TxMessageProducer produce dos textos, marcados con un id, es decir nos aseguramos la idempotencia en la producción (ver comentarios en las clases de configuración).

Más tarde TxWordCount consumirá los textos separando y contando las palabras de cada mensaje para producir idempotentemente la cuenta de cada palabra en un topic de salida. Para ello:

* Iniciaremos un productor en modo transaccional antes de empezar a consumir.
* En cada poll iniciaremos una nueva transacción
* Ejecutaremos nuestra lógica de consumo para luego mandar todos los commit de los offset consumidos en este poll con el consumer group asegurandonos de ese modo que tanto productor como consumidor han marcado el mensaje como procesado.

## Anexo: Como ejecutar Aplicaciones Java desde Maven

Como ejemplo usaremos el ejercicio de productor/consumidor simple contenido en la carpeta: `3.1.JavaConsumerProducerAPI/src/main/java/org/ogomez/nontx`.

Para la ejecución del mismo usaremos el plugin maven `exec`.

1. Ve a la carpeta raiz de proyecto kafka-exercises y ejecuta:

```bash
mvn clean install
```

Con esto habremos conseguido compilar nuestro proyecto correctamente.

2. Ve a la carpeta raiz de los ejercicio JAVA:

```bash
cd 3.1.JavaConsumerProducerAPI
```

3. Ejecuta en **una consola aparte cada una de las aplicaciones**:

```bash
mvn exec:java -Dexec.mainClass="org.ogomez.nontx.SimpleConsumer"
```

```bash
mvn exec:java -Dexec.mainClass="org.ogomez.nontx.SimpleConsumer2"
```

```bash
mvn exec:java -Dexec.mainClass="org.ogomez.nontx.SimpleConsumer3"
```

```bash
mvn exec:java -Dexec.mainClass="org.ogomez.nontx.SimpleProducer"
```

![til](./assets/mvn_exec.gif)
