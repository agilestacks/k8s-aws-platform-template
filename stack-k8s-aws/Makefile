.DEFAULT_GOAL := deploy
SHELL         := /bin/bash

export AWS_DEFAULT_REGION ?= us-east-2
export AWS_DEFAULT_OUTPUT := text
export TF_DATA_DIR        ?= $(abspath .terraform)
export TF_LOG             ?= info
export TF_LOG_PATH        := $(TF_DATA_DIR)/terraform.log
export TF_OPTS            ?=
export TF_UPDATE          ?= -update

MIN_NUMB_MASTERS          ?= 1
MIN_NUMB_NODES            ?= 1

terraform    = terraform-v0.11
aws          = aws
jq           = jq -c
curl         = curl -sL
MAKE        := $(MAKE) --no-print-directory
TMP         := $(abspath .tmp)

STATE_BUCKET ?= terraform.agilestacks.com
STATE_REGION ?= $(shell $(aws) s3api get-bucket-location \
								--bucket $(STATE_BUCKET) \
								--query 'LocationConstraint' \
								| sed -e 's/null/us-east-1/g')
DOMAIN_NAME  := $(TF_VAR_name).$(TF_VAR_base_domain)

R53_SYNC_ZIP_FILE					    := lambda/r53-sync/lambda.zip
export TF_VAR_name                      ?= dev
export TF_VAR_base_domain               ?= kubernetes.delivery
export TF_VAR_master_instance_type      ?= r4.large
export TF_VAR_backend_bucket            := $(STATE_BUCKET)
export TF_VAR_backend_region            := $(STATE_REGION)
export TF_VAR_backend_bucket_key_prefix := $(DOMAIN_NAME)/stack-k8s-aws
# To avoid confusion of terraform which has different cwd path
# we set lambda.zip as absolute path
export TF_VAR_route53_sync_lambda_zip   := $(abspath $(R53_SYNC_ZIP_FILE))

export TF_VAR_r53_sync_runtime ?= $(shell python3 -c 'import sys;v=sys.version_info; print(f"python{v.major}.{v.minor}")')
RESPECTED_LAMBDA_RUNTIMES      := python 3.6 python3.7 python3.8
ifeq (,$(filter $(TF_VAR_r53_sync_runtime),$(RESPECTED_LAMBDA_RUNTIMES)))
$(error Unsupported version lambda runtime detected: $(TF_VAR_r53_sync_runtime); expected [$(RESPECTED_LAMBDA_RUNTIMES)])
endif

WAIT_TIMEOUT := 1800

EC2_INSTANCE_TYPE := $(TF_VAR_master_instance_type)

NAT_ADDR_POOL ?=

ifneq ($(NAT_ADDR_POOL),)
# We take a comma ceparated pool of EIPs
# Filter out associated addresses
# And get allocationId as terraform list variable
space:= $(empty) $(empty)
export TF_VAR_asi_aws_nat_gw_eipallocs := $(shell \
	$(aws) --output=json ec2 describe-addresses --query "Addresses[?$(subst $(space),||,$(NAT_ADDR_POOL:%=PublicIp=='%'))]" \
	| $(jq) '[.[] | select(.AssociationId==null).AllocationId?]' \
)

$(info Proceed with EIP alloc pool: $(TF_VAR_asi_aws_nat_gw_eipallocs))

ifeq ($(strip $(TF_VAR_asi_aws_nat_gw_eipallocs)),[])
$(error All addresses [$(NAT_ADDR_POOL)] has been allocated)
endif
endif

$(TF_DATA_DIR) $(TMP):
	@ mkdir -p $@

init: $(TF_DATA_DIR)
	$(terraform) init -get=true $(TF_CMD_OPTS) -force-copy  \
		-backend=true -input=false -reconfigure \
		-backend-config="bucket=$(STATE_BUCKET)" \
		-backend-config="region=$(STATE_REGION)" \
		-backend-config="key=$(TF_VAR_backend_bucket_key_prefix)/terraform.tfstate" \
		-backend-config="profile=$(AWS_PROFILE)" \
		"platforms/aws"
.PHONY: init

plan:
	$(terraform) plan $(TF_OPTS) -refresh=true -module-depth=-1 -out=$(TF_DATA_DIR)/terraform.tfplan platforms/aws
.PHONY: plan

refresh:
	$(terraform) $(TF_OPTS) $@
.PHONY: refresh

define tf_output
$(strip $(shell \
	cd platforms/aws \
	&& $(terraform) output -state=$(TF_DATA_DIR)/terraform.tfstate $(1)
))
endef

output:
	$(call tf_output,$(TF_OPTS))
.PHONY: output

apply:
	$(terraform) apply $(TF_OPTS) -auto-approve $(TF_DATA_DIR)/terraform.tfplan
	@echo
.PHONY: apply

clean:
	rm -rf $(TF_DATA_DIR) $(TMP) $(R53_SYNC_ZIP_FILE)
.PHONY: clean

clean-state: clean
	@ $(aws) --region=$(STATE_REGION) \
		s3 rm s3://$(STATE_BUCKET)/$(TF_VAR_backend_bucket_key_prefix)/terraform.tfstate
.PHONY: clean-state

import:
	$(eval DOMAIN_NAME2 := $(subst .,-,$(DOMAIN_NAME)))
	$(eval DOMAIN_NAME3 := $(TF_VAR_name)-$(TF_VAR_base_domain))
	$(eval selected_asg := $(if $(filter $(TF_VAR_asi_r53sync_lifecycle_hook_enabled),true)without_hook,with_hook))
	$(eval lambda_name := $(shell echo r53-sync-$(DOMAIN_NAME2) | cut -c 1-64))

	$(eval TF_IMPORTS += module.lambda_r53_sync.aws_lambda_function.main $(lambda_name))
	$(eval TF_IMPORTS += module.lambda_r53_sync.aws_iam_role.lambda_role $(lambda_name))
	$(eval TF_IMPORTS += module.lambda_r53_sync.aws_iam_role_policy.lambda_policy $(lambda_name):$(lambda_name)-lambda-execution)
	$(eval TF_IMPORTS += module.masters.aws_iam_role.master_role master-role-$(DOMAIN_NAME3))
	$(eval TF_IMPORTS += module.masters.aws_autoscaling_group.$(selected_asg) master-$(DOMAIN_NAME3))
	$(eval TF_IMPORTS += module.workers.aws_iam_role.worker_role worker-role-$(DOMAIN_NAME3))
	$(eval TF_IMPORTS += module.etcd.aws_iam_role.etcd_role  etcd-role-$(DOMAIN_NAME3))
	$(eval TF_IMPORTS += module.masters.aws_iam_instance_profile.master_profile master-profile-$(DOMAIN_NAME3))
	$(eval TF_IMPORTS += module.workers.aws_iam_instance_profile.worker_profile worker-profile-$(DOMAIN_NAME3))
	$(eval TF_IMPORTS += module.etcd.aws_iam_instance_profile.etcd etcd-profile-$(DOMAIN_NAME3))
	$(eval TF_IMPORTS += aws_resourcegroups_group.cluster $(DOMAIN_NAME))

	@ echo "Importing..."
	- @ echo $(TF_IMPORTS) \
		|  xargs -t -n 2 \
			$(terraform) import -config=platforms/aws $1 $2
.PHONY: import

import_route53: init
	bin/route53-zone-by-domain.sh $(DOMAIN_NAME)
	$(eval export AWS       := $(aws))
	$(eval export JQ        := $(jq))
	$(eval export zone_id   := $(shell bin/route53-zone-by-domain.sh $(DOMAIN_NAME)))
	$(eval export base_zone := $(shell bin/route53-zone-by-domain.sh $(TF_VAR_base_domain)))
	$(eval tf_import        := $(terraform) import -config=platforms/aws)

	@ echo "Trying to import DNS records if exists..."
	- test -n "$$zone_id" && \
		$(tf_import) module.dns.aws_route53_zone.main $(zone_id)
	- test -n "$$zone_id" && \
		$(tf_import) module.dns.aws_route53_record.master_a_ext $(zone_id)_api_A
	- test -n "$$base_zone" && \
		$(tf_import) module.dns.aws_route53_record.parent $(base_zone)_$(TF_VAR_name)_NS
.PHONY: import_route53

deploy: clean lambda init import_route53
ifeq ($(TF_VAR_k8s_api_fqdn),)
deploy:
	# workaround for bug with ignition data source (27.03.2018)
	$(MAKE) plan apply || \
	$(MAKE) import import_route53 plan apply || \
	$(MAKE) plan apply || \
	$(MAKE) plan apply
	$(MAKE) wait_nodes_ready cooldown
else
deploy:
	# workaround for bug with ignition data source (27.03.2018)
	$(MAKE) plan apply || \
	$(MAKE) import import_route53 plan apply || \
	$(MAKE) plan apply || \
	$(MAKE) plan apply
	$(MAKE) wait_route53 wait_nodes_ready cooldown
endif
.PHONY: deploy

undeploy: init $(R53_SYNC_ZIP_FILE)
	$(MAKE) plan TF_OPTS="-destroy"
	$(MAKE) apply
.PHONY: undeploy

lambda/%:
	$(MAKE) -C "$(dir $@)" install package PACKAGE=$(abspath $@)

lambda: $(R53_SYNC_ZIP_FILE)

wait_route53:
	$(eval timeout := $(shell echo "`date +%s` + $(WAIT_TIMEOUT)" | bc ))
	$(eval undefined = None null 127.0.0.1)
	$(eval zone_id = $(shell $(aws) route53 \
		list-hosted-zones-by-name \
		--max-items=1 --dns-name=$(DOMAIN_NAME) \
		--query 'HostedZones[0].Id' --output=text))
	$(eval get_hosts_cmd = $(aws) route53 \
		list-resource-record-sets \
		--hosted-zone-id='$(zone_id)' \
		--start-record-name='api.$(DOMAIN_NAME).' \
		--start-record-type='A' --max-items=1 \
		--query='ResourceRecordSets[0].ResourceRecords[*].Value' --output=text)
	@ echo Waiting for master node to boot "api.$(DOMAIN_NAME)"
	@ while [ "`date +%s`" -le "$(timeout)" ]; do \
		actual="`$(get_hosts_cmd)`"; \
		if echo '$(undefined)' | grep -vqE "(\s|^)+$$actual(\s|$$)+" \
		&& [ "`echo $$actual | wc -w | xargs`" -ge "$(MIN_NUMB_MASTERS)" ]; then \
			echo "api.$(DOMAIN_NAME) resolved to $$actual"; \
			exit 0; \
		fi; \
		echo "Still waiting..."; \
		sleep 2; \
	done; \
	echo "ERROR timeout $(WAIT_TIMEOUT)sec"; \
	exit 1
.PHONY: wait_route53

wait_nodes_ready: $(TMP)
	@ echo "Retrieving cluster credentials"
	$(eval timeout        := $(shell echo "`date +%s` + $(WAIT_TIMEOUT)" | bc ))
	$(eval api_ca_crt     := $(lastword $(subst ://, ,$(call tf_output,api_ca_crt))))
	$(eval api_client_key := $(lastword $(subst ://, ,$(call tf_output,api_client_key))))
	$(eval api_client_crt := $(lastword $(subst ://, ,$(call tf_output,api_client_crt))))
	$(eval api_server     := $(call tf_output,api_server_host):$(call tf_output,api_server_port))
	$(eval kube_curl      := $(curl) --cacert $(api_ca_crt) --cert $(api_client_crt) --key $(api_client_key))
	$(eval strip_000      := sed -e 's/^[[:blank:]]*//' -e 's/^\[http code 000\]//')
	$(eval current_time   := date +%s)

	@ echo "Waiting for API server $(api_server) to boot"
	@ while [ `$(current_time)` -le "$(timeout)" ]; do \
		resp=`$(kube_curl) -w " [http code %{http_code}]" https://$(api_server)/healthz/ping | $(strip_000)`; \
		result="$$?"; \
		test -n "$$resp" && \
			echo "Cluster $(api_server) healthcheck responded: $$resp"; \
		if [ "$$result" = "0" ] && [ "$$resp" = 'ok [http code 200]' ]; then \
			exit 0; \
		fi; \
		echo "Still waiting..."; \
		sleep 8; \
	done; \
	echo "ERROR timeout $(WAIT_TIMEOUT)sec"; \
	exit 1;

	@ echo "API server "$(api_server)" is up and running"
.PHONY: wait_nodes_ready

master_hosts:
	@$(aws) --output=json ec2 describe-instances | \
		jq -r ".Reservations[].Instances[] \
			| select(.Tags != null) \
			| {addr: .PublicDnsName, tag: .Tags[] } \
			| select(.tag.Key == \"Name\" and (.tag.Value | startswith(\"master-$(TF_VAR_name)-\"))) \
			| .addr"
.PHONY: master_hosts

check-spot:
	@$(aws) --output=json ec2 describe-spot-price-history \
		--instance-types $(EC2_INSTANCE_TYPE) \
		--start-time=$(shell date +%s) \
		--product-descriptions="Linux/UNIX" \
		--query 'SpotPriceHistory[*].{az:AvailabilityZone, price:SpotPrice}' | jq -r '.[]|"\(.price) \(.az)"'
.PHONY: check-spot

spot-prices:
	@echo "*** Spot prices: $(EC2_INSTANCE_TYPE) ***"
	@($(MAKE) check-spot AWS_DEFAULT_REGION=us-east-1; \
	  $(MAKE) check-spot AWS_DEFAULT_REGION=us-east-2; \
	  $(MAKE) check-spot AWS_DEFAULT_REGION=us-west-2; \
	  $(MAKE) check-spot AWS_DEFAULT_REGION=eu-west-1; \
	  $(MAKE) check-spot AWS_DEFAULT_REGION=eu-central-1; \
	  $(MAKE) check-spot AWS_DEFAULT_REGION=eu-west-1; \
	  $(MAKE) check-spot AWS_DEFAULT_REGION=eu-west-2; \
	  $(MAKE) check-spot AWS_DEFAULT_REGION=ap-southeast-2) | sort -g
.PHONY: spot-prices

cooldown:
	@ echo "Waiting for cluster to settle down"
	@ sleep 40
.PHONY: cooldown
