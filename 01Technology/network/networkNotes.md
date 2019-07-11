# Network notes

## What is the meaning of "192.168.0.0/24"

https://social.technet.microsoft.com/Forums/windows/en-US/26de7e91-00e7-428e-a8d4-f76286e39c38/what-is-the-meaning-of-1921680024?forum=w7itpronetworking
this is CIDR format.  There are two parts to an IP address, the network number and the host number.  
The subnet mask shows what part is which.  /24 means that the first 24 bits of the IP address are part of the Network number (192.168.0) the last part is part of the host address (1-254).  

https://superuser.com/questions/158291/whats-the-meaning-of-10-0-0-1-24-address-of-my-computer-ip-addr-command
/8 = 255.0.0.0  
/16 = 255.255.0.0  
/24 = 255.255.255.0  
/32 = 255.255.255.255  
192.168.1.0/24 = 192.168.1.0-192.168.1.255  
192.168.1.5/24 is still in the same network as above we would have to go to 192.168.2.0 to be on a different network.  
192.168.1.1/16 = 192.168.1.0-192.168.255.255  

### IP Calculator / IP Subnetting

http://jodies.de/ipcalc?host=192.168.0.0&mask1=16&mask2=255.255.255.0

Address:   192.168.0.0           11000000.10101000 .00000000.00000000  
Netmask:   255.255.0.0 = 16      11111111.11111111 .00000000.00000000  
Wildcard:  0.0.255.255           00000000.00000000 .11111111.11111111  
=>  
Network:   192.168.0.0/16        11000000.10101000 .00000000.00000000 (Class C)  
Broadcast: 192.168.255.255       11000000.10101000 .11111111.11111111  
HostMin:   192.168.0.1           11000000.10101000 .00000000.00000001  
HostMax:   192.168.255.254       11000000.10101000 .11111111.11111110  
Hosts/Net: 65534                 (Private Internet)  

Subnets

Netmask:   255.255.255.0 = 24    11111111.11111111.11111111 .00000000  
Wildcard:  0.0.0.255             00000000.00000000.00000000 .11111111  

Network:   192.168.0.0/24        11000000.10101000.00000000 .00000000 (Class C)  
Broadcast: 192.168.0.255         11000000.10101000.00000000 .11111111  
HostMin:   192.168.0.1           11000000.10101000.00000000 .00000001  
HostMax:   192.168.0.254         11000000.10101000.00000000 .11111110  
Hosts/Net: 254                   (Private Internet)  
