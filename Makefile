
# create a zip file containing these files, preserving the directory structure:
# install.sh
# run.sh
# _dot_conkyrc
# lua/i2pcontrol.lua
# lua/README.md
# lua/craigmj/json4lua/README.md
# lua/craigmj/json4lua/json/json.lua
# lua/craigmj/json4lua/json/rpc.lua
# lua/craigmj/json4lua/json/rpcserver.lua
# lua/craigmj/json4lua/json/doc/LICENSE.txt
check-files: update
	@for f in install.sh run.sh _dot_conkyrc lua/i2pcontrol.lua lua/README.md \
		lua/craigmj/json4lua/README.md lua/craigmj/json4lua/json/json.lua lua/craigmj/json4lua/json/rpc.lua \
		lua/craigmj/json4lua/json/rpcserver.lua lua/craigmj/json4lua/json/doc/LICENSE.txt; do \
		if [ ! -f "$$f" ]; then \
			echo "Missing file: $$f"; \
			exit 1; \
		fi \
	done

update:
	git submodule update --init --recursive
	git submodule update --recursive --remote

zip: check-files
	zip -r i2pconky.zip install.sh run.sh _dot_conkyrc lua/i2pcontrol.lua lua/README.md \
		lua/craigmj/json4lua/README.md lua/craigmj/json4lua/json/json.lua lua/craigmj/json4lua/json/rpc.lua \
		lua/craigmj/json4lua/json/rpcserver.lua lua/craigmj/json4lua/json/doc/LICENSE.txt

tar: check-files
	tar -cvzf i2pconky.tar.gz install.sh run.sh _dot_conkyrc lua/i2pcontrol.lua lua/README.md \
		lua/craigmj/json4lua/README.md lua/craigmj/json4lua/json/json.lua lua/craigmj/json4lua/json/rpc.lua \
		lua/craigmj/json4lua/json/rpcserver.lua lua/craigmj/json4lua/json/doc/LICENSE.txt

unzip:
	rm -rf tmp
	unzip -o i2pconky.zip -d tmp

untar:
	rm -rf tmp
	mkdir tmp
	tar -xvzf i2pconky.tar.gz -C tmp