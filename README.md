# Neo4j Fabric Quickstart

What's this all about?

In Neo4j 4.0 Enterprise Edition, there's a 
[major new feature called Fabric](https://neo4j.com/docs/operations-manual/4.0/fabric/) 
that allows you to write queries that span more than one graph.

This repo is intended as a quickstart guide to show how it works, with running examples.

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

- *head* which will serve fabric queries out of a database called fabric, and also contain a master "sharding" database called regions
- *fabric1* which will contain a database called europe
- *fabric2* which will contain a database called americas

Note that this stack will run 3 copies of Neo4j on your local machine.  Head will operate
on the usual ports.  Fabric1 and fabric2 (to deconflict them) will run on non-standard higher ports.

### Populate with some data

Run these two scripts:

```
./load-regions.sh
./load-europe.sh
./load-americas.sh
```

These scripts load simple CSV file, putting cities into 2 sharded databases, one for
Europe, and one for the Americas.

### Connect to the Head Fabric Node, and Start Querying!

*How many cities does each shard have?*

```
UNWIND [
    { id: 1, region: "Europe" },
    { id: 2, region: "Americas" }
] as shard
CALL {
  USE fabric.graph(shard.id)
  MATCH (c:City) return count(n) as citiesHere
}
RETURN shard.region, citiesHere;
```

*Show all cities across all regions with more than 5,000,000 population*

```
  USE fabric.europe
  MATCH (c:City) 
  WHERE c.population > 5000000
  RETURN 'Europe' as region, c.name as name, c.population as population

UNION

  USE fabric.americas
  MATCH (c:City)
  WHERE c.population > 5000000
  RETURN 'Americas' as region, c.name as name, c.population as population
```

*Aggregation: Show Total Regional Population, Twice Aggregated*

```
UNWIND fabric.graphIds() AS graphId
CALL {
  USE fabric.graph(graphId)
  MATCH (c:City)
  RETURN sum(c.population) as regionPopulation
}
RETURN sum(regionPopulation) as totalTrackedPopulation;
```





