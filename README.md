# tidal connect service raspberry/ARM based on ppy2/ifi-tidal-release

I found that repository called ifi-tidal-release here on github, created by ppy2. Included are some binaries and some scripts. The names of the binaries intended that this is a tidal connect client. Because the lack of any description i downloaded the repo and play around with the included stuff.

I downloaded the git repos to my DietPi based arm-singleboard-computer. It turns out, that the binaries runs on ARMv7 on raspbian (perhaps on any LINUX version on ARM). All what you need to setup a tidal connect client 

There are some binaries included in the repo. You do not need all binaries and all scripts for a tidal connect client. 

These are the basic steps to create your tidal connect client:

1. install required shared libraries
2. download the repository
3. adjust the systemd service description
4. copy everything to the final directories
5. start the tidal connect client 

# install required shared libraries
the binaries rely on the presence of some required libraries:
  * libssl1.0.0 
  * libportaudio2
  * libflac++6v5

  ## libssl1.0.0 
  go to /etc/apt
  add following line in sources.list  
  *deb http://security.debian.org/debian-security jessie/updates main* 
  
  then update apt and install libssl1.0.0

     apt-get update
     apt-get install libssl1.0.0*

  ## libportaudio 
  run:
      
      apt-get install libportaudio2*

  ## libflac##6v5
  run:
  
     apt-get install libflac++6v5*

# download the repository 
download the needed files from ifi-audio (or from this repo)

    git clone https://github.com/ifi-audio/ifi-tidal-release.git

# adjust the systemd service description
the service description must be adapted to fit your needs. This means (more or less) to change the DAC device to that which is connected to your system

the systemd service description i use look like these: 

    [Unit]
    Description=Tidal Connect Service*
    
    [Service]
    Restart=on-failure
    ExecStart=/usr/ifi/ifi-tidal-release/bin/tidal_connect_application \
				--tc-certificate-path "/usr/ifi/ifi-tidal-release/id_certificate/IfiAudio_ZenStream.dat" \
				--netif-for-deviceid eth0 \
				-f "DietPi stream to project“ \
				--codec-mpegh true \
				--codec-mqa false \
				--model-name "DietPi Streamer" \
				--disable-app-security false \
				--disable-web-security false \
				--enable-mqa-passthrough false \
				--playback-device "Project RS USB Audio 2.0: - (hw:1,0)" \
				--log-level 3
    User=root
    Group=root
    RestartSec=1
    KillMode=control-group*
    
    [Install]
    WantedBy=multi-user.target*

What you have to do is to change the playback-device. The implementation relies on portaudio. It exist an application in the repo, that list the DAC connected at your computer. You have to copy the devices you want to use as playback-device. As you can see. My DAC, means my playback-device is a PROJECT Audio RS DAC. 

In order to get a list of your devices run a binary included in the downloaded repo. 

    cd $REPO 

run: 

    ifi-tidal-release/pa_devs/bin/run.sh

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
    device#0=atm7059_link: - (hw:0,0)
    device#1=atm7059_link: - (hw:0,1)
    device#2=atm7059_link: - (hw:0,2)
    device#3=Project RS USB Audio 2.0: - (hw:1,0)
    device#4=sysdefault
    device#5=dmix
    device#6=default
    Number of devices = 7

The devices which are present at the computer are located at the end of the list. Copy the whole name and insert it as playback_device in the service description.

# copy everything to the final directories
Therefore run the deploy command which is included in the repo. 

    cd $REPO 
    ./ifi-tidal-release/file-deploy.sh 

# start the tidal connect client 

    systemctl daemon-reload
    systemctl start ifi-streamer-tidal-connect.service 
    
Check the status

    systemctl status ifi-streamer-tidal-connect.service
