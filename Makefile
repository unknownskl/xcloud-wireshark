install: clean
	mkdir -p ~/.local/lib/wireshark/plugins/3-6/xcloud
	
	ln -s `pwd`/xcloud.lua ~/.local/lib/wireshark/plugins/3-6/xcloud/xcloud.lua
	ln -s `pwd`/lib ~/.local/lib/wireshark/plugins/3-6/xcloud/lib

clean:
	rm -rf ~/.local/lib/wireshark/plugins/3-6/xcloud