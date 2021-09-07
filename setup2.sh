#!/bin/bash
        sudo apt update -y
         sudo apt upgrade -y
	sudo DEBIAN_FRONTEND=noninteractive apt-get install \
	openjdk-8-jdk android-tools-adb bc bison \
	build-essential curl flex g++-multilib gcc-multilib \
	gnupg gperf imagemagick lib32ncurses5-dev \
	lib32readline-dev lib32z1-dev liblz4-tool \
	libncurses5-dev libsdl1.2-dev libssl-dev \
	libwxgtk3.0-dev libxml2 libxml2-utils lzop \
	pngcrush rsync schedtool squashfs-tools xsltproc \
	yasm zip zlib1g-dev python bison build-essential \
	curl flex git gnupg gperf ccache \
	liblz4-tool libncurses5-dev libsdl1.2-dev \
	libxml2 libxml2-utils lzop pngcrush \
	schedtool squashfs-tools xsltproc zip zlib1g-dev \
	build-essential kernel-package libncurses5-dev bzip2 git \
	python wget gcc g++ curl sudo libssl-dev openssl vim nano -y


	export JACK_SERVER_VM_ARGUMENTS="-Dfile.encoding=UTF-8 -XX:+TieredCompilation -Xmx3g"

	sudo curl --create-dirs -L -o /usr/local/bin/repo -O -L https://storage.googleapis.com/git-repo-downloads/repo
	sudo chmod a+rx /usr/local/bin/repo

	sudo apt-get clean
	sudo rm -rf /var/cache/apt/*
	sudo rm -rf /var/lib/apt/lists/*
	sudo rm -rf /tmp/*

	sudo ln -sf /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

	# Claim more diskspace
	# Thanks to @yukosky

	sudo swapoff -av
	sudo rm -f /swapfile

	sudo rm -rf /usr/share/dotnet

	sudo rm -rf "/usr/local/share/boost"
	sudo rm -rf "$AGENT_TOOLSDIRECTORY"
	sudo swapoff -av
	sudo rm -rf /mnt/swapfile
	#sudo dpkg --purge '^ghc-8.*' '^dotnet-.*' '^llvm-.*' 'php.*' azure-cli google-cloud-sdk '^google-.*' hhvm google-chrome-stable firefox '^firefox-.*' powershell mono-devel '^account-plugin-.*' account-plugin-facebook account-plugin-flickr account-plugin-twitter account-plugin-windows-live aisleriot brltty duplicity empathy empathy-common example-content gnome-accessibility-themes gnome-contacts gnome-mahjongg gnome-mines gnome-orca gnome-screensaver gnome-sudoku gnome-video-effects gnomine landscape-common libreoffice-avmedia-backend-gstreamer libreoffice-base-core libreoffice-calc libreoffice-common libreoffice-core libreoffice-draw libreoffice-gnome libreoffice-gtk libreoffice-impress libreoffice-math libreoffice-ogltrans libreoffice-pdfimport libreoffice-style-galaxy libreoffice-style-human libreoffice-writer libsane libsane-common python3-uno rhythmbox rhythmbox-plugins rhythmbox-plugin-zeitgeist sane-utils shotwell shotwell-common telepathy-gabble telepathy-haze telepathy-idle telepathy-indicator telepathy-logger telepathy-mission-control-5 telepathy-salut totem totem-common totem-plugins printer-driver-brlaser printer-driver-foo2zjs printer-driver-foo2zjs-common printer-driver-m2300w printer-driver-ptouch printer-driver-splix
	# Bonus
	sudo dd if=/dev/zero of=swap bs=4k count=1048576
	sudo mkswap swap
	sudo swapon swap
        echo "color_prompt=yes" >> ~/.bashrc
        source ~/.bashrc
