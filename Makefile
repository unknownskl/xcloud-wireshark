install: clean
	mkdir -p ~/.local/lib/wireshark/plugins/3-6/xcloud
	
	ln -s `pwd`/xcloud.lua ~/.local/lib/wireshark/plugins/3-6/xcloud/xcloud.lua
	ln -s `pwd`/lib ~/.local/lib/wireshark/plugins/3-6/xcloud/lib

install_linux: clean
	mkdir -p ~/.local/lib/wireshark/plugins/xcloud
	
	ln -s `pwd`/xcloud.lua ~/.local/lib/wireshark/plugins/xcloud/xcloud.lua
	ln -s `pwd`/lib ~/.local/lib/wireshark/plugins/xcloud/lib

clean:
	rm -rf ~/.local/lib/wireshark/plugins/3-6/xcloud
	rm -rf ~/.local/lib/wireshark/plugins/3.6/xcloud