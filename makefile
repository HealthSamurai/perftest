BENCHMARKS=$(shell ls benchmarks)
PATIENTS=100
CONCURRENCY=4

all: populate bench

populate:
	psql proto -U postgres -p 5432 -h localhost -f load.sql
	psql proto -U postgres -p 5432 -h localhost -f tables.sql
	psql proto -U postgres -p 5432 -h localhost -v patients_count=$(PATIENTS) -f generate.sql

bench: $(BENCHMARKS)
	column -s, -t < results.csv
	rm results.csv

%.sql:
	docker exec -it aiddb pgbench -c $(CONCURRENCY) -j 2 -r -t 1000 -s $(PATIENTS) -f /benchmarks/$*.sql proto > results.txt
	echo "$*, $(PATIENTS), $$(grep "(including connections establishing)" results.txt | cut -d " " -f 3)" >> results.csv
	rm results.txt

connect:
	psql proto -U postgres -p 5432 -h localhost

tables:
	psql proto -U postgres -p 5432 -h localhost -f sizes.sql

options:
	psql proto -U postgres -p 5432 -h localhost -f options.sql

# # loop in for?
# RUNS= 1.patients 2.patients
# patients: $(RUNS)

# proxy: patients
# 	@echo $(PATIENTS)

# %.patients: PATIENTS = $*
# %.patients:
# 	# @echo $(PATIENTS)
#   @echo 1




# NUMBERS = 1 2 3 4
# doit:
# 	$(foreach PATIENTS, $(NUMBERS), populate;)

# qwert:
# 	for PATIENTS in 1 2 3 4 ; do \
# 	$(exec populate) ; \
# 	done
