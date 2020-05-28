function ?= "asg-sync-r53-dev-kubernetes-delivery"

aws       ?= aws
VENV_DIR  := .venv
python    := test -f $(VENV_DIR)/bin/activate && . $(VENV_DIR)/bin/activate; python3
pip       := test -f $(VENV_DIR)/bin/activate && . $(VENV_DIR)/bin/activate; pip

PACKAGE := lambda.zip

default: init install package

clear:
	rm -rf $(VENV_DIR) $(PACKAGE)
.PHONY: deploy

init:
	rm -rf $(VENV_DIR)
	python3 -m venv $(VENV_DIR)

deploy: install package
	$(aws) lambda update-function-code --function-name="$(function)" --zip-file=fileb://$(PACKAGE) --publish
.PHONY: deploy

install: init
	$(pip) install -r requirements.txt -t lib --upgrade --no-cache

test:
	$(python) test_main.py

$(PACKAGE):
	zip -qr9 $@ . -x@.zipignore

package: $(PACKAGE)
