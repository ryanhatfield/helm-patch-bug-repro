include kwok.mk

UPSTALL=helm upgrade --install test test/.
NULL=> /dev/null 2>&1

show:
	@kubectl get svc --selector repro=true

test-1.24:
	@echo "--> start clean"
	make clean $(NULL)
	make KWOK_KUBE_VERSION=1.24.0 kwok $(NULL)

	@echo "\n--> this installs without error"
	$(UPSTALL) --set servicePortA=1000 --set servicePortB=2000 $(NULL)
	@make show

	@echo "\n--> service-a and service-b both fail"
	$(UPSTALL) --set servicePortA=fail --set servicePortB=3000 $(NULL) || true
	@make show

	@echo "\n--> service-a and service-b both succeed"
	$(UPSTALL) --set servicePortA=4000 --set servicePortB=5000 $(NULL)
	@make show

test-1.25:
	@echo "--> start clean"
	make clean $(NULL)
	make KWOK_KUBE_VERSION=1.25.0 kwok $(NULL)

	@echo "\n--> this installs without error"
	$(UPSTALL) --set servicePortA=1000 --set servicePortB=2000 $(NULL)
	@make show

	@echo "\n--> helm upgrade fails, service-a fails, but service-b succeeds and is now 3000"
	$(UPSTALL) --set servicePortA=fail --set servicePortB=3000 $(NULL) || true
	@make show

	@echo "\n--> helm upgrade fails, service-a succeeds and is now 4000, but service-b fails"
	$(UPSTALL) --set servicePortA=4000 --set servicePortB=5000 $(NULL) || true
	@make show

	@echo "\n--> helm upgrade fails, service-a and service-b both fail consistently"
	$(UPSTALL) --set servicePortA=6000 --set servicePortB=7000 $(NULL) || true
	@make show

.PHONY: test
test:
	make --no-print-directory test-1.24
	@echo
	@echo =============================
	@echo
	make --no-print-directory test-1.25


clean: clean-kwok
