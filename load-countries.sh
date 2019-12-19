#!/bin/bash
#
# MAKE SURE YOU HAVE STARTED THE STACK FIRST
# Note the non-standard ports I'm using because we're doing docker-compose
CONTAINER_NAME=fabric-demo-neo4j_fabric2_1
PASSWORD=admin
PORT=7689

echo "
CREATE INDEX ON :Country(iso2);
CREATE INDEX ON :Country(iso3);

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS 
FROM 'https://storage.googleapis.com/meetup-data/worldcities.csv' AS line

MERGE (country:Country {
    name: coalesce(line.country, ''),
    iso2: coalesce(line.iso2, ''),
    iso3: coalesce(line.iso3, '')    
});

MATCH (n) RETURN count(n);
" | docker exec --interactive $CONTAINER_NAME bin/cypher-shell -a localhost:$PORT -u neo4j -p $PASSWORD

