#!/bin/bash 
service dbus start;
service avahi-daemon start;
/usr/ifi/ifi-tidal-release/bin/tidal_connect_application \
				--tc-certificate-path "/usr/ifi/ifi-tidal-release/id_certificate/IfiAudio_ZenStream.dat" \
				--netif-for-deviceid eth0 \
				-f "Rasp Tidal" \
				--codec-mpegh true \
			  --model-name "raspi Tidal" \
        --codec-mqa false \
				--disable-app-security false \
				--disable-web-security false \
				--enable-mqa-passthrough false \
				--playback-device "snd_rpi_hifiberry_dacplus: HiFiBerry DAC+ Pro HiFi pcm512x-hifi-0 (hw:0,0)" \
				--log-level 3
