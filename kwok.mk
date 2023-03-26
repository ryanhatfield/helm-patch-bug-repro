# Helper makefile for using kwok as part of testing
# https://kwok.sigs.k8s.io/
# Author: Ryan Hatfield
# https://gist.github.com/ryanhatfield/1ec81e468abf8cd0803b4d578adb1de4

CLUSTER_NAME:=$(shell basename $$PWD)
export KUBECONFIG=$(CLUSTER_NAME).kubeconfig
KWOKCTL:=kwokctl --name=$(CLUSTER_NAME)

isRunning=$(patsubst $(1),true,$(filter $(shell $(KWOKCTL) get clusters),$(1)))
isNotRunning=$(if $(call isRunning, $(1)),,true)
fileExists=$(patsubst $(1),true,$(wildcard $(1)))

kwok-create: ## Create cluster if not running
	$(if $(call isNotRunning,$(CLUSTER_NAME)),$(KWOKCTL) create cluster)

$(KUBECONFIG): ## Create kubeconfig
	$(KWOKCTL) get kubeconfig > $@

kwok: kwok-create $(KUBECONFIG) ## Use kwok
	@kubectl config use-context kwok-$(CLUSTER_NAME)

clean-kwok: ## Clean kwok cluster and kubeconfig file
	$(if $(call isRunning,$(CLUSTER_NAME)),$(KWOKCTL) delete cluster)
	$(if $(call fileExists,$(KUBECONFIG)),rm -rf $(KUBECONFIG))
