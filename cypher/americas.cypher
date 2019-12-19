CALL {
    USE GRAPH fabric.region
    MATCH (r:Region { name: 'Americas' })<-[:IN]-(c:Country)
    RETURN collect(c.iso3) as countriesInRegion
}
CALL {
    USE GRAPH fabric.americas
    
    WITH countriesInRegion

    LOAD CSV WITH HEADERS 
    FROM 'https://raw.githubusercontent.com/moxious/fabric-demo-neo4j/master/worldcities.csv' AS line

    WITH line, countriesInRegion
    WHERE line.iso3 in countriesInRegion

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
        population: coalesce(
            toInteger(coalesce(line.population, '0')), 0),
        country_iso2: coalesce(line.iso2, ''),
        country_iso3: coalesce(line.iso3, '')
    })

    RETURN count(c) as citiesLoaded
}
RETURN *;

