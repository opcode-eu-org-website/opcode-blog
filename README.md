** This is source code repo for [blog.opcode.eu.org](http://blog.opcode.eu.org) **

## Technical background

Blog use MIT licensed static site generator [obraz](https://github.com/vlasovskikh/obraz).

*Obraz* require *Python* 3.7 (don't work with python 3.5) and next *Debian* packages:

	python3-yaml python3-jinja2 python3-markdown python3-docopt

### Automated build

For automated build can be used non-bare remote git repo ([more info](_posts/2019-04-13-push_to_non-bare_git_repo.md))  
with post-receive hook. In sample [hook script](files/post-receive.sh) after git command can be add *Obraz* build command:

	if python3 obraz.py build -d /PATH/TO/WEBSITE/BLOG/DIR/; then
		echo -e "\\033[0;30;42m  BUILD OK  \\033[0m"
	else
		echo -e "\\033[1;5;33;41m  BUILD ERROR  \\033[0m"
	fi


## Licence

All blog files (including content, template and generator scripts) is under MIT Licence.

* `obraz.py` `_plugins/tags.py` – original files from *Obraz*
    * Copyright © 2013-2014 Andrey Vlasovskikh
* `_layouts/*` `main.css` – modificated version of files from *Obraz*
    * Copyright © 2013-2014 Andrey Vlasovskikh
    * Copyright © 2019 Robert Ryszard Paciorek
* `_plugins/utils.py` – my addons for *Obraz*
    * Copyright © 2019 Robert Ryszard Paciorek
* `_posts/*` – blog content
    * Copyright © 2019 Robert Ryszard Paciorek

### The MIT Licence

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:
	 
	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.
	 
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
