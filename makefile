BENCHMARKS=$(shell ls benchmarks)
PATIENTS=100

# TODO external counts of patients

all: populate bench

populate:
	psql proto -U postgres -p 5432 -h localhost -f load.sql
	psql proto -U postgres -p 5432 -h localhost -f tables.sql
	psql proto -U postgres -p 5432 -h localhost -v patients_count=$(PATIENTS) -f generate.sql

bench: $(BENCHMARKS)

%.sql:
	docker exec -it aiddb pgbench -c 4 -j 2 -r -t 1000 -s $(PATIENTS) -f /benchmarks/$*.sql proto

connect:
	psql proto -U postgres -p 5432 -h localhost
