BENCHMARKS=$(shell ls benchmarks)

all: populate bench

populate:
	psql proto -U postgres -p 5432 -h localhost -f load.sql
	psql proto -U postgres -p 5432 -h localhost -f tables.sql
	psql proto -U postgres -p 5432 -h localhost -f generate.sql

bench: $(BENCHMARKS)

%.sql:
	docker exec -it aiddb pgbench -c 8 -j 2 -r -T 10 -f /benchmarks/$*.sql proto
