# get the project name from setup.py
PROJECT := $(shell grep 'name=' setup.py | head -n1 | cut -d '=' -f 2 | sed "s/['\", ]//g")
PYTHON := $(PWD)/env/bin/python

VERSION := 0.1
NAME := inventory

PKGNAME := inventory-service
RPMSHORT := $(PKGNAME)-$(VERSION)-1.fc$(shell head -n1 /etc/issue | cut -d ' ' -f 3).x86_64.rpm
RPM := package/RPMS/x86_64/$(RPMSHORT)

SETTINGS := $(PROJECT).settings

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

put: $(RPM)
	rsync -az $(RPM) sdlabs.io:.
	ssh sdlabs.io -t sudo rpm --force -fvi ./$(RPMSHORT)

$(RPM): test_project
	rm -rf $(PKGNAME)-$(VERSION)
	cp -a env $(PKGNAME)-$(VERSION)
	cp -a test_project/manage.py $(PKGNAME)-$(VERSION)
	cp -a db.sqlite3 $(PKGNAME)-$(VERSION)
	find $(PKGNAME)-$(VERSION) -name '*.pyc' -print0 | xargs -0 rm -f
	perl -pi -e 's|$(shell pwd)/env|/opt/$(NAME)|' $(PKGNAME)-$(VERSION)/bin/*
	mkdir -p package/{RPMS,BUILD,SOURCES,BUILDROOT}
	tar -czf package/SOURCES/$(PKGNAME)-$(VERSION).tar.gz $(PKGNAME)-$(VERSION)
#	rm -rf $(PKGNAME)-$(VERSION)
	cat server.service.in | sed "s/%NAME%/$(NAME)/g" >package/SOURCES/server.service
	cat server.spec.in | sed "s/%NAME%/$(NAME)/g" | sed "s/%VERSION%/$(VERSION)/g" >server.spec
	rpmbuild --define "_topdir $(PWD)/package" -ba server.spec
	rm -rf package/{BUILD,BUILDROOT}

prereqs: test_project

build:
	virtualenv env
	$(PWD)/env/bin/easy_install -U distribute
	$(PWD)/env/bin/pip install -r requirements.txt --exists-action=w
	$(PWD)/env/bin/django-admin.py startproject test_project || echo "test_project already created"
	$(PYTHON) setup.py build install

test: test_project
	$(PYTHON) test_project/manage.py test $(PROJECT).tests --settings=$(SETTINGS)

coverage: test_project
	$(PWD)/env/bin/coverage run --source=$(PROJECT) --omit="$(PROJECT)/migrations/*" test_project/manage.py test $(PROJECT).tests --settings=$(SETTINGS)
	$(PWD)/env/bin/coverage report

style: env
	$(PWD)/env/bin/pep8 --max-line-length=500 $(PROJECT) --exclude=$(PROJECT)/migrations/
	$(PWD)/env/bin/pylint $(PROJECT) -E --disable=E1002,E1101,E1102,E1103,E0203,E1003 --enable=C0111,W0613 --ignore=migrations

server: test_project
	$(PYTHON) test_project/manage.py syncdb --noinput --settings=$(SETTINGS)
	$(PYTHON) test_project/manage.py migrate --settings=$(SETTINGS)
	$(PYTHON) test_project/manage.py runserver --settings=$(SETTINGS)

shell: test_project
	$(PYTHON) test_project/manage.py shell --settings=$(SETTINGS)

dbshell: test_project
	$(PYTHON) test_project/manage.py dbshell --settings=$(SETTINGS)

migrate: test_project
	$(PYTHON) test_project/manage.py migrate $(PROJECT) --settings=$(SETTINGS)

fake-migrate: test_project
	$(PYTHON) test_project/manage.py migrate $(PROJECT) --fake --settings=$(SETTINGS)

schemamigration: test_project
	$(PYTHON) test_project/manage.py schemamigration $(PROJECT) --auto --settings=$(SETTINGS)

clean:
	rm -f development.sql

distclean: clean
	rm -rf env test_project

.PHONY: clean distclean all prereqs build test coverage style server shell dbshell migrate fake-migrate schemamigration
