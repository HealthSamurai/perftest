BENCHMARKS=$(shell ls benchmarks)
PATIENTS=100
CONCURRENCY=4

all: populate bench

populate:
	psql proto -U postgres -p 5432 -h localhost -f util/create_tables.sql > /dev/null
	psql proto -U postgres -p 5432 -h localhost -f util/functions.sql > /dev/null
	time psql proto -U postgres -p 5432 -h localhost -c "select insert_patients($(PATIENTS));"
	time psql proto -U postgres -p 5432 -h localhost -c "select insert_observations(1000 * $(PATIENTS));"
	time psql proto -U postgres -p 5432 -h localhost -c "select insert_medicationstatements(100 * $(PATIENTS));"


bench: $(BENCHMARKS)
	column -s, -t < results.csv
	rm results.csv

%.sql:
	docker exec -it aiddb pgbench -c $(CONCURRENCY) -j 2 -r -t 1000 -s $(PATIENTS) -f /benchmarks/$*.sql proto > results.txt
	echo "$*, $(PATIENTS), $$(grep "(including connections establishing)" results.txt | cut -d " " -f 3)" >> results.csv
	rm results.txt

stats:
	psql proto -U postgres -p 5432 -h localhost -f util/db_information.sql

connect:
	psql proto -U postgres -p 5432 -h localhost
