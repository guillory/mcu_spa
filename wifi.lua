
function ConnectWifi()
	local nbtry=0
	tmr.alarm(0, 1000, 1, function()
	  if (wifi.sta.getip()== nil and nbtry<=30) then 
	    	if (nbtry==0) then
	    		wifi.setmode(wifi.STATION)
	    		wifi.sta.config(WIFI_SSID, WIFI_PWD)
	    		if (WIFI_IP!=nil)
	    			wifi.sta.setip({ip=WIFI_IP,netmask="255.255.255.0",gateway=WIFI_GATEWAY})
			end
			--wifi.sta.autoconnect(WIFI_AUTOCONNECT)
		end
	    	nbtry=nbtry + 1
	        print("Connecting to ssid ", WIFI_SSID)
	  elseif (wifi.sta.getip()== nil and nbtry>30) then 
		print("NO WIFI wait "..WAIT_MN.." mn")
		tmr.stop(0)
		tmr.delay(WAIT_MN * 60000000)
		--ConnectWifi()  
		NodeSleep()
	  else
	        ip, nm, gw=wifi.sta.getip()
	        print("Wifi Status:\t\t", getStatusString(wifi.sta.status()))
		      --  print("Wifi mode:\t\t", wifi.getmode())
		      --  print("IP Address:\t\t", ip)
		      --  print("IP Netmask:\t\t", nm)
		      --  print("IP Gateway Addr:\t", gw)
		      --  print("DNS 1:\t\t\t", net.dns.getdnsserver(0))
		      --  print("DNS 2:\t\t\t", net.dns.getdnsserver(1))
	        tmr.stop(0)
	        print("Sensor")
		Sensor()
	   end
	end)
end
function getStatusString(status)
    if status == 0 then
        return "STATION IDLE"
    elseif status == 4 then
        return "STATION CONNECTING"
    elseif status == 2 then
        return "STATION WRONG PASSWORD"
    elseif status == 3 then
        return "STATION NO AP FOUND"
    elseif status == 4 then
        return "STATION CONNECT FAIL"
    elseif status == 5 then
        return "STATION GOT IP"
    end
end