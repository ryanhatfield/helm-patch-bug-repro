include kwok.mk

step-1: kwok ## Helm installs both services
	helm upgrade --install test test/. --set servicePortA=1000 --set servicePortB=2000

step-2: kwok ## Helm fails to update service-a, but DOES update service-b
	helm upgrade --install test test/. --set servicePortA=fail --set servicePortB=3000 || true

step-3: kwok ## Helm updates service-a, but DOES NOT update service-b
	helm upgrade --install test test/. --set servicePortA=4000 --set servicePortB=5000 || true

step-4: kwok ## Helm DOES NOT update service-a or service-b
	helm upgrade --install test test/. --set servicePortA=6000 --set servicePortB=7000 || true

show:
	kubectl get svc

.PHONY: test
test:
	@echo "start clean"
	make clean > /dev/null 2>&1
	@echo "\n--> this installs without error"
	make step-1 > /dev/null 2>&1
	make show # ports 1000 and 2000
	@echo "\n--> service-a fails, but service-b succeeds and is now 3000"
	make step-2 > /dev/null 2>&1
	make show # ports 1000 and 3000
	@echo "\n--> service-a succeeds and is now 4000, but service-b fails"
	make step-3 > /dev/null 2>&1
	make show
	@echo '\n--> service-a and service-b both fail consistently'
	make step-3 > /dev/null 2>&1
	make show
	@echo
	make step-3 > /dev/null 2>&1
	make show


clean: clean-kwok
