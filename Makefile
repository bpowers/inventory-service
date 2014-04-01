# get the project name from setup.py
PROJECT := $(shell grep 'name=' setup.py | head -n1 | cut -d '=' -f 2 | sed "s/['\", ]//g")
PYTHON := $(PWD)/env/bin/python

# first rule in a makefile is the default one, calling it "all" is a
# common GNU Make convention.
all: test style

env: Makefile requirements.txt
	@echo "  VENV update"
	@virtualenv env -q
	@$(PWD)/env/bin/easy_install -q -U distribute
	@$(PWD)/env/bin/easy_install -q -U pip
	$(PWD)/env/bin/pip install -r requirements.txt
	$(PYTHON) setup.py develop
	@touch -c env

env/bin/django-admin.py: env
	@touch -c $@

test_project: env env/bin/django-admin.py
	@echo "  PROJ update"
	$(PWD)/env/bin/django-admin.py startproject test_project >/dev/null || touch -c test_project

prereqs: test_project

build:
	virtualenv env
	$(PWD)/env/bin/easy_install -U distribute
	$(PWD)/env/bin/pip install -r requirements.txt --exists-action=w
	$(PWD)/env/bin/django-admin.py startproject test_project || echo "test_project already created"
	$(PYTHON) setup.py build install

test: test_project
	$(PYTHON) test_project/manage.py test $(PROJECT).tests

coverage: test_project
	$(PWD)/env/bin/coverage run --source=$(PROJECT) --omit="$(PROJECT)/migrations/*" test_project/manage.py test $(PROJECT).tests --settings=$(TEST_SETTINGS)
	$(PWD)/env/bin/coverage report

style: env
	$(PWD)/env/bin/pep8 --max-line-length=500 $(PROJECT) --exclude=$(PROJECT)/migrations/
	$(PWD)/env/bin/pylint $(PROJECT) -E --disable=E1002,E1101,E1102,E1103,E0203,E1003 --enable=C0111,W0613 --ignore=migrations

server: test_project
	$(PYTHON) test_project/manage.py syncdb --noinput --settings=$(DEV_SETTINGS)
	$(PYTHON) test_project/manage.py migrate --settings=$(DEV_SETTINGS)
	$(PYTHON) test_project/manage.py runserver --settings=$(DEV_SETTINGS)

shell: test_project
	$(PYTHON) test_project/manage.py shell --settings=$(DEV_SETTINGS)

dbshell: test_project
	$(PYTHON) test_project/manage.py dbshell --settings=$(DEV_SETTINGS)

migrate: test_project
	$(PYTHON) test_project/manage.py migrate $(PROJECT) --settings=$(PROD_SETTINGS)

fake-migrate: test_project
	$(PYTHON) test_project/manage.py migrate $(PROJECT) --fake --settings=$(PROD_SETTINGS)

schemamigration: test_project
	$(PYTHON) test_project/manage.py schemamigration $(PROJECT) --auto --settings=$(PROD_SETTINGS)

clean:
	rm -f development.sql

distclean: clean
	rm -rf env test_project

.PHONY: clean distclean all prereqs build test coverage style server shell dbshell migrate fake-migrate schemamigration
