// --------------------------------------------------
// ----------------- CREATE DB ----------------------
// --------------------------------------------------
// Create the nodes for people
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///neo-people.csv" AS row
CREATE (:Person {iid: row.iid, gender: row.gender, age: row.age, field_cd: row.field_cd, race: row.race, imprace: row.imprace, income: row.income, goal: row.goal, date: row.date, go_out: row.go_out, career_c: row.career_c, sports: row.sports, tvsports: row.tvsports, exercise: row.exercise, dining: row.dining, museums: row.museums, art: row.art, hiking: row.hiking, gaming: row.gaming, clubbing: row.clubbing, reading: row.reading, tv: row.tv, theater: row.theater, movies: row.movies, concerts: row.concerts, music: row.music, shopping: row.shopping, yoga: row.yoga});

// Create the nodes for cities
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///neo-people.csv" AS row
CREATE (:City {zipcode: row.zipcode})

// Create indexes
CREATE INDEX ON :Person(iid);
CREATE INDEX ON :City(zipcode);

// Create the MET connexion unidirectional: If A met B, there will be A -> B and A <- B.
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///neo-dates.csv" AS row
MATCH (person1:Person {iid: row.iid})
MATCH (person2:Person {iid: row.pid})
MERGE (person1)-[me:MET]->(person2)
ON CREATE SET me.match = row.match, me.wave = row.wave, me.round = row.round, me.position = row.position, me.order = row.order, me.int_corr = row.int_corr, me.samerace = row.samerace, me.dec = row.dec;

// Create bi-directional MET connexion
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///neo-dates.csv" AS row
MATCH (person1:Person {iid: row.iid})
MATCH (person2:Person {iid: row.pid})
MERGE (person1)<-[me:BI_MET]->(person2)
ON CREATE SET me.match = row.match, me.wave = row.wave, me.round = row.round, me.position = row.position, me.order = row.order, me.int_corr = row.int_corr, me.samerace = row.samerace, me.dec = row.dec;

// Create LIVES connexion
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///neo-people.csv" AS row
MATCH (person:Person {iid: row.iid})
MATCH (city:City {zipcode: row.zipcode})
MERGE (person)-[li:LIVES]->(city)


// --------------------------------------------------
// ----------------- QUERY DB ----------------------
// --------------------------------------------------
// Dummie filter on met: person iid 1, with a match and a positive decision
MATCH (p1:Person)-[m:MET]->(p2:Person) 
WHERE p1.iid = '1' AND m.match = '1' AND m.dec = '1' 
RETURN *
LIMIT 100

// Dummie filter on person age
MATCH (p1:Person)-[m:BI_MET]-(p2:Person) 
WHERE p1.age > "30" AND p2.age > "30"
RETURN p1
LIMIT 100

// Find the dates of the dates for persons aged of 22 yo
MATCH (p1:Person { age: '22' })-[m1:MET {match: '1'}]-()-[m2:MET {match: '1'}]-(p2)
RETURN *
LIMIT 100

MATCH (p1:Person { age: '30' })-[m1:BI_MET]-()-[m2:BI_MET]-(p2)
RETURN *
LIMIT 100

MATCH (p1:Person { zipcode: '10,021' })-[m1:BI_MET]-(p2: Person)
RETURN *
LIMIT 100

// Get the person with the more entering degree
MATCH (p1:Person)-->() 
RETURN p1.iid, count(*) as degree 
ORDER BY degree DESC LIMIT 10

// Get the persons with the more matches
MATCH (p:Person)-[:MET {match: '1'}]->(p2:Person) 
WITH p2, count(p) as degree 
RETURN p2.iid, degree
ORDER BY degree DESC LIMIT 10

MATCH (p:Person)-[:MET {match: '1'}]->(p2:Person) 
WITH p2, count(p) as degree 
RETURN p2
ORDER BY degree DESC LIMIT 1

// Get the persons with the fewer matches
MATCH (p:Person)-[:MET {match: '0'}]->(p2:Person) 
WITH p2, count(p) as degree 
RETURN p2.iid, degree
ORDER BY degree DESC LIMIT 10

MATCH (p:Person)-[:MET {match: '0'}]->(p2:Person) 
WITH p2, count(p) as degree 
RETURN p2
ORDER BY degree DESC LIMIT 1

// Remove duplicates nodes for LIVES relation
MATCH (c:City)
WITH c.zipcode as zipcode, collect(c) as cities, count(*) as cnt
WHERE cnt > 1
WITH head(cities) as first, tail(cities) as rest
LIMIT 1000
UNWIND rest AS to_delete
MATCH (to_delete)<-[r:LIVES]-(e:Person)
MERGE (first)<-[:LIVES]-(e)
DELETE r
DELETE to_delete
RETURN count(*);

// Match on a city
MATCH (p:Person)-[:LIVES]->(c:City)<-[:LIVES]-(p2:Person)
WHERE NOT c.zipcode = 'NA'
RETURN *
LIMIT 100

// Find the ten cities with the most people living in
MATCH (p:Person)-[:LIVES]->(c:City)
WITH count(p) as degree, c
WHERE NOT c.zipcode = 'NA'
RETURN c.zipcode, degree
ORDER BY degree DESC LIMIT 10

MATCH (p:Person)-[:LIVES]->(c:City)
WITH count(p) as degree, c
WHERE NOT c.zipcode = 'NA'
RETURN c
ORDER BY degree DESC LIMIT 10



