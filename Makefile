include kwok.mk

UPSTALL=helm upgrade --install test test/.

step-1: kwok ## Helm installs both services
	$(UPSTALL) --set servicePortA=1000 --set servicePortB=2000

step-2: kwok ## Helm fails to update service-a, but DOES update service-b
	$(UPSTALL) --set servicePortA=fail --set servicePortB=3000 || true

step-3: kwok ## Helm updates service-a, but DOES NOT update service-b
	$(UPSTALL) --set servicePortA=4000 --set servicePortB=5000 || true

step-4: kwok ## Helm DOES NOT update service-a or service-b
	$(UPSTALL) --set servicePortA=6000 --set servicePortB=7000 || true

show:
	kubectl get svc --selector repro=true

show-helm-secret-%:
	kubectl get secret sh.helm.release.v$*.test --output yaml

NULL=> /dev/null 2>&1

test-1.24:
	@echo "--> start clean"
	make clean $(NULL)
	make KWOK_KUBE_VERSION=1.24.0 kwok

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
	make KWOK_KUBE_VERSION=1.25.0 kwok

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
test: test-1.24 test-1.25


clean: clean-kwok
