#!/bin/bash
#
# MAKE SURE YOU HAVE STARTED THE STACK FIRST
# Note the non-standard ports I'm using because we're doing docker-compose
#
# Region data is stored on the fabric head.  It will serve region queries generally,
# which are small, and will act as the routing node.
CONTAINER_NAME=fabric-demo-neo4j_head_1
PASSWORD=admin
PORT=7687
DATABASE=regions

cat cypher/regions.cypher | docker exec --interactive $CONTAINER_NAME bin/cypher-shell -a localhost:$PORT -u neo4j -p $PASSWORD --database region
