SET 'auto.offset.reset' = 'earliest';

create stream flights_json( 
  _id string,
  FlightDate string,
  Tail_Number string,
  arrival_performance struct<ArrTime double, ArrDelay int, ArrDelayMinutes int, ArrDel15 int, ArrivalDelayGroups int, ArrTimeBlk string>,
  departure_performance struct<DepTime int, DepDelay int, DepDelayMinutes int, DepDel15 int, DepartureDelayGroups int, DepTimeBlk string>,
  airline_info struct<Reporting_Airline string, DOT_ID_Reporting_Airline string, IATA_CODE_Reporting_Airline string, Flight_Number_Reporting_Airline string>,
  origin_info struct<OriginAirportID double, OriginAirportSeqID double, OriginCityMarketID double, Origin string, OriginCityName string, OriginState string, OriginStateFips int, OriginStateName string, OriginWac int>,
  destination_info struct<DestAirportID double, DestAirportSeqID double, DestCityMarketID double, Dest string, DestCityName string, DestState string, DestStateFips int, DestStateName string, DestWac int>,
  Cancelled int,
  Diverted int,
  delay_info struct<CarrierDelay int, WeatherDelay int, NASDelay int, SecurityDelay int, LateAircraftDelay int>,
  diverted_info struct<DivAirportLandings int>,
  CRSDepTime double,
  TaxiOut int,
  WheelsOff double,
  WheelsOn double,
  TaxiIn int,
  CRSArrTime double,
  CRSElapsedTime double,
  ActualElapsedTime double,
  AirTime int,
  Flights int,
  Distance double,
  DistanceGroup int
)
with(kafka_topic='mongo.test.flights', value_format='json');

CREATE STREAM flights 
WITH (
  KAFKA_TOPIC = 'flights',
  PARTITIONS = 3,
  VALUE_FORMAT = 'AVRO'
)
AS SELECT   
  FLIGHTDATE,
  TAIL_NUMBER AS TAILNUMBER,
  DEPARTURE_PERFORMANCE -> DEPTIME AS DEPARTURETIME,
  ARRIVAL_PERFORMANCE -> ARRTIME AS ARRIVALTIME,
  AIRTIME,      
  DEPARTURE_PERFORMANCE -> DEPDELAY AS DEPARTUREDELAY,
  ARRIVAL_PERFORMANCE -> ARRDELAY AS ARRIVLDELAY,
  ORIGIN_INFO -> ORIGIN AS ORIGINAIRPORT,
  ORIGIN_INFO -> ORIGINCITYNAME AS ORIGINCITY,
  DESTINATION_INFO -> DEST AS DESTINATIONAIRPORT,
  DESTINATION_INFO -> DESTCITYNAME AS DESTINATIONCITY,
  CANCELLED,
  DIVERTED
FROM FLIGHTS_JSON
EMIT CHANGES;