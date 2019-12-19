#!/bin/bash
#
# MAKE SURE YOU HAVE STARTED THE STACK FIRST
# Note the non-standard ports I'm using because we're doing docker-compose
CONTAINER_NAME=fabric-demo-neo4j_fabric1_1
PASSWORD=admin
PORT=7688

echo "
CREATE INDEX ON :City(id);
CREATE INDEX ON :City(country_iso2);
CREATE INDEX ON :City(country_iso3);

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS 
FROM 'https://storage.googleapis.com/meetup-data/worldcities.csv' AS line

MERGE (c:City {
    id: coalesce(line.id, ''),
    name: coalesce(line.city, ''),
    ascii_name: coalesce(line.city_ascii, ''),
    admin_name: coalesce(line.admin_name, ''),
    capital: coalesce(line.capital, ''),
    location: point({
        latitude: toFloat(coalesce(line.lat, '0.0')),
        longitude: toFloat(coalesce(line.lng, '0.0'))
    }),
    population: coalesce(line.population, 0),
    country_iso2: coalesce(line.iso2, ''),
    country_iso3: coalesce(line.iso3, '')
});

MATCH (n) RETURN count(n);
" | docker exec --interactive $CONTAINER_NAME bin/cypher-shell -a localhost:$PORT -u neo4j -p $PASSWORD
