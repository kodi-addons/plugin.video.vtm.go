ENVS := flake8,py27,py36
export PYTHONPATH := $(CURDIR):$(CURDIR)/test
addon_xml = addon.xml

# Collect information to build as sensible package name
name = $(shell xmllint --xpath 'string(/addon/@id)' $(addon_xml))
version = $(shell xmllint --xpath 'string(/addon/@version)' $(addon_xml))
git_branch = $(shell git rev-parse --abbrev-ref HEAD)
git_hash = $(shell git rev-parse --short HEAD)

zip_name = $(name)-$(version)-$(git_branch)-$(git_hash).zip
include_files = main.py addon.xml LICENSE README.md resources/
include_paths = $(patsubst %,$(name)/%,$(include_files))
exclude_files = \*.new \*.orig \*.pyc \*.pyo
zip_dir = $(name)/

blue = \e[1;34m
white = \e[1;37m
reset = \e[0;39m

.PHONY: test

all: test zip

package: zip

test: sanity unit run

sanity: tox pylint

tox:
	@echo -e "$(white)=$(blue) Starting sanity tox test$(reset)"
	tox -q -e $(ENVS)

pylint:
	@echo -e "$(white)=$(blue) Starting sanity pylint test$(reset)"
	pylint *.py resources/lib/ test/

addon: clean
	@echo -e "$(white)=$(blue) Starting sanity addon tests$(reset)"
	odi-addon-checker . --branch=leia

unit:
	@echo -e "$(white)=$(blue) Starting unit tests$(reset)"
	python -m unittest discover

run:
	@echo -e "$(white)=$(blue) Run CLI$(reset)"
	python test/run.py /

zip: clean
	@echo -e "$(white)=$(blue) Building new package$(reset)"
	@rm -f ../$(zip_name)
	cd ..; zip -r $(zip_name) $(include_paths) -x $(exclude_files)
	@echo -e "$(white)=$(blue) Successfully wrote package as: $(white)../$(zip_name)$(reset)"

clean:
	find . -name '*.pyc' -type f -delete
	find . -name '__pycache__' -type d -delete
	rm -rf .pytest_cache/ .tox/
	rm -f *.log
