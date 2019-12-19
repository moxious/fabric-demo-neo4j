# Neo4j Fabric Quickstart

## Setup

### Setup Network Aliases

First, add these local host aliases to your /etc/hosts file.  This is just a convenience to help
us use docker network names as synonymous with localhost.

```
127.0.0.1	head
127.0.0.1	fabric1
127.0.0.1	fabric2
```

### Start the Stack

`docker-compose up`

This will create *3* containers:

- *head* which will serve fabric queries out of a database called fabric
- *fabric1* which will contain a database called city
- *fabric2* which will contain a database called country

Note that this stack will run 3 copies of Neo4j on your local machine.  Head will operate
on the usual ports.  Fabric1 and fabric2 (to deconflict them) will run on non-standard higher ports.

### Populate with some data

Run these two scripts:

```
./load-cities.sh
./load-countries.sh
```

These scripts load the same simple CSV file, putting the cities in 1 database, the countries in
another, to simulate our sharding setup.

### Connect to the Head Fabric Node, and Start Querying!

*How many nodes does each database have?*

```
UNWIND fabric.graphIds() AS graphId
CALL {
  USE fabric.graph(graphId)
  MATCH (n) return count(n) as nodesHere
}
RETURN graphId, nodesHere;
```

*Most populous cities*

Note that this is done from the fabric database, not from cities, and shows how to use
cities in fabric.

```
CALL {
  USE fabric.city
  MATCH (c:City)
  WHERE c.population is not null and
  c.population <> ""
  RETURN c 
}
return c.name, c.population
ORDER BY toInteger(c.population) DESC
LIMIT 10;
```





