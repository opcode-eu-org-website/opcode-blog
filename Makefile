serve:
	python3 obraz.py serve -w
	
build:
	python3 obraz.py build

installDependencies:
	apt install python3.7 python3-yaml python3-jinja2 python3-markdown python3-docopt
