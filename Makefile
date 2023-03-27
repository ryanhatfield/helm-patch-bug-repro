include kwok.mk

UPSTALL=helm upgrade --install test test/.
TEMPLATE=helm template test/.
NULL=> /dev/null 2>&1
EXTRA_UPSTALL_ARGS:=

show:
	@kubectl get svc --selector repro=true

test-success-%:
	@echo "--> start clean"
	make clean
	make KWOK_KUBE_VERSION=$* kwok

	@echo "\n--> this installs without error"
	$(UPSTALL) --set servicePortA=1000 --set servicePortB=2000 $(NULL)
	@make show

	@echo "\n--> service-a and service-b both fail"
	$(UPSTALL) --set servicePortA=fail --set servicePortB=3000 $(NULL) || true
	@make show

	@echo "\n--> service-a and service-b both succeed"
	$(UPSTALL) --set servicePortA=4000 --set servicePortB=5000 $(NULL)
	@make show

test-failure-%:
	@echo "--> start clean"
	make clean
	make KWOK_KUBE_VERSION=$* kwok

	@echo "\n--> this installs without error"
	$(UPSTALL) --set servicePortA=1000 --set servicePortB=2000 $(EXTRA_UPSTALL_ARGS) $(NULL)
	@make show

	@echo "\n--> helm upgrade fails, service-a fails, but service-b succeeds and is now 3000"
	$(UPSTALL) --set servicePortA=fail --set servicePortB=3000 $(EXTRA_UPSTALL_ARGS) $(NULL) || true
	@make show

	@echo "\n--> helm upgrade fails, service-a succeeds and is now 4000, but service-b fails"
	$(UPSTALL) --set servicePortA=4000 --set servicePortB=5000 $(EXTRA_UPSTALL_ARGS) $(NULL) || true
	@make show

	@echo "\n--> helm upgrade fails, service-a and service-b both fail consistently"
	$(UPSTALL) --set servicePortA=6000 --set servicePortB=7000 $(EXTRA_UPSTALL_ARGS) $(NULL) || true
	@make show

test-kubectl-1.24.12:
	@echo "--> start clean"
	make clean
	make KWOK_KUBE_VERSION=1.24.12 kwok

	@echo "\n--> this installs without error"
	$(TEMPLATE) --set servicePortA=1000 --set servicePortB=2000 $(EXTRA_UPSTALL_ARGS) | kubectl apply -f- --server-side=true $(NULL)
	@make show

	@echo "\n--> service-a and service-b both fails"
	$(TEMPLATE) --set servicePortA=fail --set servicePortB=3000 $(EXTRA_UPSTALL_ARGS) | kubectl apply -f- --server-side=true $(NULL) || true
	@make show

	@echo "\n--> service-a and service-b both succeed"
	$(TEMPLATE) --set servicePortA=4000 --set servicePortB=5000 $(EXTRA_UPSTALL_ARGS) | kubectl apply -f- --server-side=true $(NULL)
	@make show

test-kubectl-1.25.8:
	@echo "--> start clean"
	make clean
	make KWOK_KUBE_VERSION=1.25.8 kwok

	@echo "\n--> this installs without error"
	$(TEMPLATE) --set servicePortA=1000 --set servicePortB=2000 $(EXTRA_UPSTALL_ARGS) | kubectl apply -f- --server-side=true $(NULL)
	@make show

	@echo "\n--> service-a fails, and service-b succeeds"
	$(TEMPLATE) --set servicePortA=fail --set servicePortB=3000 $(EXTRA_UPSTALL_ARGS) | kubectl apply -f- --server-side=true $(NULL) || true
	@make show

	@echo "\n--> service-a and service-b both succeed"
	$(TEMPLATE) --set servicePortA=4000 --set servicePortB=5000 $(EXTRA_UPSTALL_ARGS) | kubectl apply -f- --server-side=true $(NULL)
	@make show

test-extra-args:
	make --no-print-directory EXTRA_UPSTALL_ARGS="--atomic" test-failure-1.25.8

.PHONY: test
test:
	make --no-print-directory test-success-1.24.12
	@echo
	@echo =============================
	@echo
	make --no-print-directory test-failure-1.25.8
	@echo
	@echo =============================
	@echo
	make --no-print-directory test-kubectl-1.24.12
	@echo
	@echo =============================
	@echo
	make --no-print-directory test-kubectl-1.25.8


clean: clean-kwok
