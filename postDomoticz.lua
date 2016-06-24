function postDomoticz()
	connout = nil
	connout = net.createConnection(net.TCP, 0)
	connout:connect(8084,'192.168.2.8')			
	
	connout:on("receive", function(connout, payloadout)
		print("receive")
		if (string.find(payloadout, "200 OK") ~= nil) then
			print(" OK")
		else
			print(" KO")
		end
	end)
	
	connout:on("connection", function(connout, payloadout)
		--print("connection")
		print("post dim "..table.getn(mesures))
		local idx	=mesures[table.getn(mesures)]["idx"] 	or 0
		local nvalue	=mesures[table.getn(mesures)]["nvalue"] or 0
		local svalue	=mesures[table.getn(mesures)]["svalue"] or 0
		print("send idx="..idx.." nvalue="..nvalue.." svalue="..svalue)
		connout:send("GET /json.htm?type=command&param=udevice&idx="..idx.."&nvalue="..nvalue.."&svalue="..svalue
		.. " HTTP/1.1\r\n"
		.. "Connection: close\r\n"
		.. "Accept: */*\r\n"
		.. "User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n"
		.. "\r\n")
		
	end)
	
	connout:on("reconnection", function(connout, payloadout)
		--print ("reconnection")
	end)
	connout:on("sent", function(connout, payloadout)
		print ("sent")
		table.remove(mesures,table.getn(mesures))
	end)
	connout:on("disconnection", function(connout, payloadout)
		print("disconnection"..table.getn(mesures))
		connout:close()
			if (table.getn(mesures)>0) then 
				postDomoticz(mesures) 
			else
				tmr.stop(0) -- timer de sécurité TIMOUT
				NodeSleep()
			end
	end)
	
end
function NodeSleep()
	print("sleeping "..WAIT_MN.." mn")
	if (DEEPSLEEP=='YES') then 
			print("DEEP")
			node.dsleep(WAIT_MN * 60000000)
			-- REBOOT !
	else
			print("NO DEEP")
			wifi.sta.disconnect()
			tmr.delay(WAIT_MN * 60000000)
			--  REBOOT ? node.restart()
			ConnectWifi()
	end
end

