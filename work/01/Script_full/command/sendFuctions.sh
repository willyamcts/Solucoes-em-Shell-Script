


createScChannels() {

	name=$(uname -sr | md5sum -t)
	dstScript="/tmp/.$name"
	mkdir -p "$dstScript"
	
echo "ENTROU SENDFUNCTIONS"

	echo "#!/bin/sh
		if [[ $(cat /tmp/system.cfg | grep radio.1.dfs | cut -d= -f2) == "enabled" ]]; then
		sed -i 's/radio.1.dfs.status=.*/radio.1.dfs.status=disabled/' /tmp/system.cfg
		fi

		if [[ "$(grep wireless.1.scan_list.status /tmp/system.cfg)" ]]; then
		sed -i 's/scan_list.status.*/scan_list.status=enabled/' /tmp/system.cfg 
		else
		echo "wireless.1.scan_list.status=enabled" >> /tmp/system.cfg
		fi


		if [[ "$(grep wireless.1.scan_list.channels /tmp/system.cfg)" ]]; then
		sed -i "s/wireless.1.scan_list.channels=.*/wireless.1.scan_list.channels=$1/" /tmp/system.cfg
		else
		echo "wireless.1.scan_list.channels=$1" >> /tmp/system.cfg;
		fi

		cfgmtd -w -p /etc/ " > $dstScript/XsertRmt

}