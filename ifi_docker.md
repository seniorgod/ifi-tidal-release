For all instalations based on different distributions than debian stretch, e.g. Debian buster there is a different solution: Docker

On a raspberry with debian buster i experimented with docker to find an approach to run the ifi-tidal-streamer inside a docker container in order to avoid the installation of outdated software.
It is tricky than there is one challange: avahi. 
ifi-tidal-streamer is announcing its service via avahi (bonjour, zeroconf). Because avahi is (at least what i know) a servicediscovery in your local network (means in your subnet) i need to announce the service inside these network.
If you create a docker container, there are three network mode: Bridge, Host, mavlan 
A Bridge network (the default for docker) create a seperate network for the container. You can forward traffic from your local network to the container, but the avahi daemon inside the container (inside the bridged network) announce the service in these network only - but nobody outside of the container network will see it.
In that case you have a running avahi daemon in your network but without any recipient. 

A host network uses the same network for the host and the container. Sounds perfect but if you run two avahi daemons on the same host you run into trouble. I tried these but some services are announced, some not. 
I found no solution that two avahi stacks can run without problems on the same host in the same network. 

The third option macvlan create a soltion which seems to work fine. It create a virtual IP which belongs as virtual card to the network which the host is connected on. The mus configured manually.
You have to define a new subnet and IP in a range where your DHCP don't issue IP adresses. But i cant use these solution, because i prepared that raspi for a friend which is not an IT guy and there is no way to explain that to a "normal people".

So i go for creating a bridge network, forwoard the port needed for ifi-tidal-streamer (port 2019) from the host to the docker container and announce the TIDAL service "manually" by a handwritten avahi-service file. 

The order of steps is: 
1. download the ifi-tidal-service
2. prepare the configuration of ifi-tidal-streamer 
3. create the needed image for the docker container 
4. create and run the container with the right configuration
5. write ahavi service file on the host in order to announce the tidal streaming service 

