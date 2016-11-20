USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///neo-people.csv" AS row
CREATE (:Person {iid: row.iid, gender: row.gender, age: row.age, field_cd: row.field_cd, race: row.race, imprace: row.imprace, zipcode: row.zipcode, income: row.income, goal: row.goal, date: row.date, go_out: row.go_out, career_c: row.career_c, sports: row.sports, tvsports: row.tvsports, exercise: row.exercise, dining: row.dining, museums: row.museums, art: row.art, hiking: row.hiking, gaming: row.gaming, clubbing: row.clubbing, reading: row.reading, tv: row.tv, theater: row.theater, movies: row.movies, concerts: row.concerts, music: row.music, shopping: row.shopping, yoga: row.yoga});

CREATE INDEX ON :Person(iid);

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///neo-dates.csv" AS row
MATCH (person1:Person {iid: row.iid})
MATCH (person2:Person {iid: row.pid})
MERGE (person1)-[me:MET]->(person2)
ON CREATE SET me.match = row.match, me.wave = row.wave, me.round = row.round, me.position = row.position, me.order = row.order, me.int_corr = row.int_corr, me.samerace = row.samerace, me.dec = row.dec;

MATCH (p1:Person)-[m:MET]->(p2:Person) WHERE p1.iid = '1' AND m.match = '1'  AND m.dec = '1' RETURN *
