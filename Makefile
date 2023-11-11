PYTHON_VERSION := 3.11
PYTHON_BLACK_VERSION := py311
PYTHON_GLOBAL_EXE := python$(PYTHON_VERSION)
VENV := .venv
PYTHON_VENV_EXE := $(VENV)/bin/python
PIP_VENV_EXE := $(VENV)/bin/pip
BLACK_VENV_EXE := $(VENV)/bin/black
FLAKE_VENV_EXE := $(VENV)/bin/flake8
ISORT_VENV_EXE := $(VENV)/bin/isort
PYTEST_VENV_EXE := $(VENV)/bin/pytest
DJANGO_SETTINGS := alexandru_optica_app.settings.development
DJANGO_SETTINGS_TEST := alexandru_optica_app.settings.testing
DJANGO_SERV_ADDR := localhost:8000
DB_DEV := db.sqlite3


venv:
	$(PYTHON_GLOBAL_EXE) -m venv $(VENV)
.PHONY: venv

install: venv
	$(PIP_VENV_EXE) install -r requirements.txt
.PHONY: install

install_dev: venv
	$(PIP_VENV_EXE) install -r requirements-dev.txt
.PHONY: install_dev

freeze_requirements: venv
	$(PIP_VENV_EXE) freeze --all > requirements-freeze.txt
.PHONY: freeze_requirements

clean:
	rm -rf $(VENV)
	find . -type f -name '*.pyc' -delete
.PHONY: clean

clean_db:
	rm $(DB_DEV)

migrations:
	$(PYTHON_VENV_EXE) manage.py makemigrations --settings=$(DJANGO_SETTINGS)
.PHONY: makemigrations

migrate:
	$(PYTHON_VENV_EXE) manage.py migrate --settings=$(DJANGO_SETTINGS)
.PHONY: migrate

superuser:
	$(PYTHON_VENV_EXE) manage.py createsuperuser --settings=$(DJANGO_SETTINGS)
.PHONY: superuser

run:
	$(PYTHON_VENV_EXE) manage.py runserver --settings=$(DJANGO_SETTINGS) $(DJANGO_SERV_ADDR)
.PHONY: run

static:
	mkdir -p static
	$(PYTHON_VENV_EXE) manage.py collectstatic --settings=$(DJANGO_SETTINGS)
.PHONY: static

black_diff:
	$(BLACK_VENV_EXE) -t $(PYTHON_BLACK_VERSION) --diff .
.PHONY: black_diff

black_apply:
	$(BLACK_VENV_EXE) -t $(PYTHON_BLACK_VERSION) .
.PHONY: black_apply

flake:
	$(FLAKE_VENV_EXE) $(QA_PATHS) .
.PHONY: flake

isort:
	$(ISORT_VENV_EXE) .
.PHONY: isort

tests:
	$(PYTEST_VENV_EXE) -s -vv --ds=${DJANGO_SETTINGS_TEST} tests/
.PHONY: tests

tests_lf:
	$(PYTEST_VENV_EXE) -s -vv --ds=${DJANGO_SETTINGS_TEST} --lf tests/
.PHONY: tests_lf

tests_lf_pdb:
	$(PYTEST_VENV_EXE) -s -vv --ds=${DJANGO_SETTINGS_TEST} --lf --pdb tests/
.PHONY: tests_lf_pdb

qa: black_diff flake
.PHONY: check_qa

ci: check_qa tests
.PHONY: ci
