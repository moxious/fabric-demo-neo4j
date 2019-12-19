CREATE INDEX ON :BoundingBox(iso2);
CREATE INDEX ON :BoundingBox(name);

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS 
FROM 'https://raw.githubusercontent.com/moxious/fabric-demo-neo4j/master/bounding-boxes.csv' AS line

MERGE (:BoundingBox {
    iso2: line.iso2,
    name: line.name,
    min_lng: toFloat(line.min_lng),
    min_lat: toFloat(line.min_lat),
    max_lng: toFloat(line.min_lng),
    max_lat: toFloat(line.min_lat)
})

RETURN count(line);

CREATE INDEX ON :Country(iso2);
CREATE INDEX ON :Country(iso3);
CREATE INDEX ON :Region(code);

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS
FROM 'https://raw.githubusercontent.com/moxious/fabric-demo-neo4j/master/countries-by-continent.csv' AS line

WITH line
WHERE line.region is not null and
line.region <> ''

MERGE (c:Country {
    name: line.name,
    iso2: line.iso2,
    iso3: line.iso3,
    iso3166_2: line.iso3166_2
})

MERGE (r:Region { 
    name: line.region,
    code: line.region_code
})
MERGE (c)-[:IN]->(r)
WITH c, r, line
WHERE line.sub_region is not null and line.sub_region <> ''
MERGE (r2:Region {
    name: line.sub_region,
    code: line.sub_region_code
})
MERGE (r2)-[:IN]->(r)
MERGE (c)-[:IN]->(r2)

RETURN count(line);

MATCH (b:BoundingBox)
WITH b
MATCH (c:Country { iso2: b.iso2 })
MERGE (c)-[r:BOX]->(b)
RETURN count(r);
