#!/bin/bash
#
# MAKE SURE YOU HAVE STARTED THE STACK FIRST
CONTAINER_NAME=fabric-demo-neo4j_head_1
PASSWORD=admin
PORT=7687

cat cypher/europe.cypher | docker exec --interactive \
    $CONTAINER_NAME bin/cypher-shell \
    -a localhost:$PORT \
    -u neo4j \
    -p $PASSWORD \
    --database fabric
