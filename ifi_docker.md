# ifi-tidal-streamer based on docker 
For all instalations based on different distributions than debian stretch, e.g. Debian buster there is a different solution: Docker
I expect that docker is installed on your SBC. I use DietPi which offer docker as a predefined package (https://github.com/MichaIng/DietPi). 

On a raspberry with debian buster i experimented with docker to find an approach to run the ifi-tidal-streamer inside a docker container in order to avoid the installation of outdated software.
It is tricky than there is one challange: avahi. 
tidal-connect-application is announcing its service via avahi (bonjour, zeroconf). Because avahi is (at least what i know) a servicediscovery in your local network (means in your subnet) i need to announce the service inside these network.
If you create a docker container, there are three network mode: Bridge, Host, mavlan 
A Bridge network (the default for docker) create a seperate network for the container. You can forward traffic from your local network to the container, but the avahi daemon inside the container (inside the bridged network) announce the service in these network only - but nobody outside of the container network will see it.
In that case you have a running avahi daemon in your network but without any recipient. 

A host network uses the same network for the host and the container. Sounds perfect but if you run two avahi daemons on the same host you run into trouble. I tried these but some services are announced, some not. 
I found no solution that two avahi stacks can run without problems on the same host in the same network. 

The third option macvlan create a soltion which seems to work fine. It create a virtual IP which belongs as virtual card to the network which the host is connected on. The mus configured manually.
You have to define a new subnet and IP in a range where your DHCP don't issue IP adresses. But i cant use these solution, because i prepared that raspi for a friend which is not an IT guy and there is no way to explain that to a "normal people".

So i go for creating a bridge network, forwoard the port needed for tidal-connect-application (port 2019) from the host to the docker container and announce the TIDAL service "manually" by a handwritten avahi-service file. 

The order of steps is: 
1. prepare the docker image we need as base
2. download the ifi-tidal-service 
3. prepare the configuration of tidal-connect-application
4. create and run the container with the right configuration
5. write ahavi service file on the host in order to announce the tidal connect application

## prepare the docker image we need as base
I experimented a lot to find out a solution with small footprint. I ended with a Docker Container based on debian stretch with all need libs in it. 
You can create it by that Dockerfile: 

    FROM debian:stretch-slim
    RUN echo "deb http://security.debian.org/debian-security jessie/updates main" > /etc/apt/sources.list.d/jessie-updates.list
    RUN apt-get -y update 
    RUN apt-get -y  install libssl1.0.0 libportaudio2 libflac++6v5 libcurl3 libavformat57 libavahi-common3 libavahi-client3  avahi-daemon
    RUN mkdir /usr/ifi/
    RUN mkdir /usr/ifi/ifi_tidal_release
    RUN apt-get 
    
In order to create the image call following command in the same directory where the dockerfile is saved: 

    docker build -t stretch_ifi_image .
    
It creates an image called stretch-ifi-image which included all neccessary libraries.    

## download the ifi-tidal-service 
You have to clone the github repository and install portaudio2 in order to prepare the container

run:

    mkdir /usr/ifi
    cd /usr/ifi
    git clone https://github.com/seniorgod/ifi-tidal-release
    apt-get install libportaudio2*

You need to identify your DAC or whatever you want to use with portaudio2:
    
    cd /usr/ifi 
    ifi-tidal-release/pa_devs/run.sh

You get an output like this, from which you have to read the "name" of the DAC device you wish to use. While you are doing this the connected DAC must be plugged in and switched on.

    ALSA lib confmisc.c:1281:(snd_func_refer) Unable to find definition 'cards.atm7059_link.pcm.front.0:CARD=0'
    ALSA lib conf.c:4528:(_snd_config_evaluate) function snd_func_refer returned error: No such file or directory
    ALSA lib conf.c:5007:(snd_config_expand) Evaluate error: No such file or directory
    ALSA lib pcm.c:2495:(snd_pcm_open_noupdate) Unknown PCM front
    ALSA lib pcm.c:2495:(snd_pcm_open_noupdate) Unknown PCM cards.pcm.rear
    ALSA lib pcm.c:2495:(snd_pcm_open_noupdate) Unknown PCM cards.pcm.center_lfe
    ALSA lib pcm.c:2495:(snd_pcm_open_noupdate) Unknown PCM cards.pcm.side
    ALSA lib confmisc.c:1281:(snd_func_refer) Unable to find definition 'cards.atm7059_link.pcm.surround51.0:CARD=0'
    ALSA lib conf.c:4528:(_snd_config_evaluate) function snd_func_refer returned error: No such file or directory
    ALSA lib conf.c:5007:(snd_config_expand) Evaluate error: No such file or directory
    ALSA lib pcm.c:2495:(snd_pcm_open_noupdate) Unknown PCM surround21
    ALSA lib confmisc.c:1281:(snd_func_refer) Unable to find definition 'cards.atm7059_link.pcm.surround51.0:CARD=0'
    ALSA lib conf.c:4528:(_snd_config_evaluate) function snd_func_refer returned error: No such file or directory
    ALSA lib conf.c:5007:(snd_config_expand) Evaluate error: No such file or directory
    ALSA lib pcm.c:2495:(snd_pcm_open_noupdate) Unknown PCM surround21
    ALSA lib confmisc.c:1281:(snd_func_refer) Unable to find definition 'cards.atm7059_link.pcm.surround40.0:CARD=0'
    ALSA lib conf.c:4528:(_snd_config_evaluate) function snd_func_refer returned error: No such file or directory
    ALSA lib conf.c:5007:(snd_config_expand) Evaluate error: No such file or directory
    ALSA lib pcm.c:2495:(snd_pcm_open_noupdate) Unknown PCM surround40
    ALSA lib confmisc.c:1281:(snd_func_refer) Unable to find definition 'cards.atm7059_link.pcm.surround51.0:CARD=0'
    ALSA lib conf.c:4528:(_snd_config_evaluate) function snd_func_refer returned error: No such file or directory
    ALSA lib conf.c:5007:(snd_config_expand) Evaluate error: No such file or directory
    ALSA lib pcm.c:2495:(snd_pcm_open_noupdate) Unknown PCM surround41
    ALSA lib confmisc.c:1281:(snd_func_refer) Unable to find definition 'cards.atm7059_link.pcm.surround51.0:CARD=0'
    ALSA lib conf.c:4528:(_snd_config_evaluate) function snd_func_refer returned error: No such file or directory
    ALSA lib conf.c:5007:(snd_config_expand) Evaluate error: No such file or directory
    ALSA lib pcm.c:2495:(snd_pcm_open_noupdate) Unknown PCM surround50
    ALSA lib confmisc.c:1281:(snd_func_refer) Unable to find definition 'cards.atm7059_link.pcm.surround51.0:CARD=0'
    ALSA lib conf.c:4528:(_snd_config_evaluate) function snd_func_refer returned error: No such file or directory
    ALSA lib conf.c:5007:(snd_config_expand) Evaluate error: No such file or directory
    ALSA lib pcm.c:2495:(snd_pcm_open_noupdate) Unknown PCM surround51
    ALSA lib confmisc.c:1281:(snd_func_refer) Unable to find definition 'cards.atm7059_link.pcm.surround71.0:CARD=0'
    ALSA lib conf.c:4528:(_snd_config_evaluate) function snd_func_refer returned error: No such file or directory
    ALSA lib conf.c:5007:(snd_config_expand) Evaluate error: No such file or directory
    ALSA lib pcm.c:2495:(snd_pcm_open_noupdate) Unknown PCM surround71
    ALSA lib confmisc.c:1281:(snd_func_refer) Unable to find definition 'cards.atm7059_link.pcm.iec958.0:CARD=0,AES0=4,AES1=130,AES2=0,AES3=2'
    ALSA lib conf.c:4528:(_snd_config_evaluate) function snd_func_refer returned error: No such file or directory
    ALSA lib conf.c:5007:(snd_config_expand) Evaluate error: No such file or directory
    ALSA lib pcm.c:2495:(snd_pcm_open_noupdate) Unknown PCM iec958
    ALSA lib confmisc.c:1281:(snd_func_refer) Unable to find definition 'cards.atm7059_link.pcm.iec958.0:CARD=0,AES0=4,AES1=130,AES2=0,AES3=2'
    ALSA lib conf.c:4528:(_snd_config_evaluate) function snd_func_refer returned error: No such file or directory
    ALSA lib conf.c:5007:(snd_config_expand) Evaluate error: No such file or directory
    ALSA lib pcm.c:2495:(snd_pcm_open_noupdate) Unknown PCM spdif
    ALSA lib confmisc.c:1281:(snd_func_refer) Unable to find definition 'cards.atm7059_link.pcm.iec958.0:CARD=0,AES0=4,AES1=130,AES2=0,AES3=2'
    ALSA lib conf.c:4528:(_snd_config_evaluate) function snd_func_refer returned error: No such file or directory
    ALSA lib conf.c:5007:(snd_config_expand) Evaluate error: No such file or directory
    ALSA lib pcm.c:2495:(snd_pcm_open_noupdate) Unknown PCM spdif
    ALSA lib pcm.c:2495:(snd_pcm_open_noupdate) Unknown PCM cards.pcm.hdmi
    ALSA lib pcm.c:2495:(snd_pcm_open_noupdate) Unknown PCM cards.pcm.hdmi
    ALSA lib pcm.c:2495:(snd_pcm_open_noupdate) Unknown PCM cards.pcm.modem
    ALSA lib pcm.c:2495:(snd_pcm_open_noupdate) Unknown PCM cards.pcm.modem
    ALSA lib pcm.c:2495:(snd_pcm_open_noupdate) Unknown PCM cards.pcm.phoneline
    ALSA lib pcm.c:2495:(snd_pcm_open_noupdate) Unknown PCM cards.pcm.phoneline
    Cannot connect to server socket err = No such file or directory
    Cannot connect to server request channel
    jack server is not running or cannot be started
    JackShmReadWritePtr::~JackShmReadWritePtr - Init not done for -1, skipping unlock
    JackShmReadWritePtr::~JackShmReadWritePtr - Init not done for -1, skipping unlock

The run command creates a file called devices inside the directory /usr/ifi/ifi-tidal-release/pa_devs. The content looks like this: 
    
    device#0=atm7059_link: - (hw:0,0)
    device#1=atm7059_link: - (hw:0,1)
    device#2=atm7059_link: - (hw:0,2)
    device#3=Project RS USB Audio 2.0: - (hw:1,0)
    device#4=sysdefault
    device#5=dmix
    device#6=default
    Number of devices = 7

In the example above devices are listed from device#0 till device#6. Copy or select the whole name of the device you want to use. 

## prepare the configuration of tidal-connect-application
When we use docker we don't run docker as a systemd service, we run it simply by script. We prepare a script called start.sh which is later on linked into the container and start the tidal connect app. start.sh start dbus, avahi, ifi-tidal-release inside the container (ifi-tidal-release require avahi, which require dbus):
In the example below the used DAC ist not the Project RS USB Audio DAC, it is hifibarry DAC card for a raspi. We save the start.sh in /usr/ifi/ifi-tidal-release

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

## create and run the container with the right configuration
We create and run the container and give the container the name ifi_image_start use journald as logging system on the host, inject the sound device to the container, forwared the port 2019 from the host to the container, define to restart the container if the host restarts, and link the local directory "/usr/ifi/ifi-tidal-release/" from the host to the container. All that is based in the create image "stretch_ifi_image" and the container start the start.sh file inside the container. 

    docker run -di  --name ifi_image_start --log-driver journald --device /dev/snd -p 2019:2019 --restart unless-stopped -v /usr/ifi/ifi-tidal-release/:/usr/ifi/ifi-tidal-release stretch_ifi_image /usr/ifi/ifi-tidal-release/start.sh

At these moment the container should run on the host and inside the container the tidal-connect-application should run. 
If you want to check that you can open a bash in the container by: 
    
    docker exec -it  ifi_image_start  bash 
    
## write ahavi service file on the host in order to announce the tidal connect application
In order to announce the service you have to create a service description on the host. 
In the directory /etc/avahi/services create a file called tidalconnect.service with following content:

    <?xml version="1.0" standalone='no'?><!--*-nxml-*-->
    <!DOCTYPE service-group SYSTEM "avahi-service.dtd">

    <service-group>

      <name replace-wildcards="yes">tidal on %h-00e39f05aea430f501a368c55e1b8eff</name>

      <service>
        <type>_tidalconnect._tcp</type>
        <port>2019</port>
        <txt-record>mn=abacus aroio</txt-record>
        <txt-record>ca=0</txt-record>
        <txt-record>id=00e39f05aea430f501a368c55e1b8eff</txt-record>
        <txt-record>fn=Tidal stream to abacus</txt-record>
        <txt-record>ve=1</txt-record>
      </service>

    </service-group>
    
 Than  restart avahi with 
 
    systemctl restart avahi-daemon.service 
 
 the tidal connect service should be visible now in your network
