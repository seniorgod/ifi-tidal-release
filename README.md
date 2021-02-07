# tidal connect service raspberry/ARM based on ppy2/ifi-tidal-release

I found that repository called ifi-tidal-release here on github, created by ppy2. Included are some binaries and some scripts. The names of the binaries intended that this is a tidal connect client. Because the lack of any description i downloaded the repo and play around with the included stuff.

I downloaded the git repos to m< arm-singleboard-computer. I use a (audio optimized) arm singleboard name sparky from allo.com based on a minimal debian system called DietPi (https://github.com/MichaIng/DietPi). It turns out, that the binaries runs on ARMv7 on debian stretch and (more difficult to set up) on debian buster (perhaps on any LINUX version on ARM). There are several binaries included in the repo. You do not need all binaries and all scripts for a tidal connect client. 

Below you find the description to get that tidal connect client running for Debian stretch and Debian buster on ARM. 
The description ist written initially for stretch. Because buster lacks some older libraries there is more to do to get the tidal connect client running on buster.
The only difference therefore is to load more "older" libraries which ar not present by default in Debian buster. 

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
     
  ## more shared libraries for debian buster 
  In order to install the required libraries not present in buster you have to add the repositories for stretch in sources.list
  go to /etc/apt
  add following line in sources.list:  
  *deb https://deb.debian.org/debian/ stretch main contrib non-free*
  
  *deb https://deb.debian.org/debian/ stretch-updates main contrib non-free*
  
  *deb http://security.debian.org/debian-security stretch/updates main contrib non-free*
  
  Then install libavfromat57 and libcurl3.
  If you need libcurl4 you are in trouble because libcurl3 deinstall libcurl4. 
  
  ### libavformat57 
     
    apt-get install libavformat57
    
  ### libcurl3
  
    apt-get install libcurl3
  

# download the repository 
The install steps later on expects the downloaded files in a directory called /usr/ifi.

    mkdir /usr/ifi
    cd /usr/ifi
    git clone https://github.com/seniorgod/ifi-tidal-release

# adjust the systemd service description
the service description located in /usr/ifi/ifi-streamer-tidal-connect.service must be adapted to fit your needs. This means (more or less) to change the DAC device to that which is connected to your system.

First create a copy of the sample service file, and edit your version:
    cp /usr/ifi/ifi-tidal-release/ifi-streamer-tidal-connect.service /usr/ifi/ifi-streamer-tidal-connect.service
    vim /usr/ifi/ifi-streamer-tidal-connect.service

the systemd service description i use look like these: 

    [Unit]
    Description=Tidal Connect Service*
    
    [Service]
    Restart=on-failure
    ExecStart=/usr/ifi/ifi-tidal-release/bin/tidal_connect_application \
				--tc-certificate-path "/usr/ifi/ifi-tidal-release/id_certificate/IfiAudio_ZenStream.dat" \
				--netif-for-deviceid eth0 \
				-f "DietPi stream to project" \
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

What you have to do is to change the playback-device. The implementation relies on portaudio. It exist an application inside the repo, that list all audio devices connected to your computer. You have to copy the devices you want to use as playback-device to the config. 
As you can see. My DAC, means my playback-device is a PROJECT Audio RS DAC connected at (hw:1,0). 

In order to get a list of your devices run a commnand included in the downloaded repo. 

    cd /usr/ifi

run: 

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

In the example above devices are listed from device#0 till device#6. Copy the whole name of the device you want to use and insert it as playback_device in the service description of systemd (see above).

# copy everything to the final directories
In order to copy everything to the final destination run the deploy command which is included in the repo. 

    cd /usr/ifi
    ./ifi-tidal-release/file-deploy.sh 

# start the tidal connect client 

    systemctl daemon-reload
    systemctl start ifi-streamer-tidal-connect.service 
    
Check the status

    systemctl status ifi-streamer-tidal-connect.service
    
 if you want to start the tidal-connect-service automatically run 
 
     systemctl enable ifi-streamer-tidal-connect.service
