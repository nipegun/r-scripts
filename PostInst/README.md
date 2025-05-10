# Scripts

.

## Router-wlan0.sh

Transforma un Debian recién instalado en un router WiFi que sirva IPs en la interfaz inalámbrica.
Es necesario que el ordenador cuente con, al menos, una interfaz cableada (eth0) y una inalámbrica (wlan0) con la capacidad AP.
El script tiene en cuenta que el router al que está conectado el ordenador está en una subred distinta de 192.168.100.0/24 dado que, al finalizar la ejecución del script, el Debian proporcionará IPs en esa subred. Desde la 192.168.100.100 hasta la 192.168.100.199.
