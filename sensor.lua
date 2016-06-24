
function Sensor()
		mesures={}
		values1={}
		--  ds18b20 --------------------
		for i=1, 10 do 
			table.insert(values1, decimal(getTemp(5),100) )
		end
		value1=moyenne(values1, 60)
		print (" OK temp is "..value1.. " °C")
		table.insert(mesures, {idx=16,nvalue=0, svalue=value1} )		
	
		--  DHT11 --------------------
		values1={}
		values2={}
		for i=1, 10 do 
			status, temp, humi, temp_dec, humi_dec = dht.read(6)
			if status == dht.OK then
			     	print(string.format("DHT Temperature:%d.%03d;Humidity:%d.%03d\r\n", math.floor(temp),temp_dec,math.floor(humi),humi_dec))			
			     	table.insert(values1, math.floor(temp))
				table.insert(values2, math.floor(humi))
			elseif status == dht.ERROR_CHECKSUM then
				print( "  DHT Checksum error." )
			elseif status == dht.ERROR_TIMEOUT then
				print( "  DHT timed out." )
			end
			value2=moyenne(values1, 60)
			value3=moyenne(values2, 60)
			table.insert(mesures, {idx=2,nvalue=0, svalue=value2..";"..value3..";0"} )	
		end		
		--  hx711.init(1,2) --------------------
		values1={}
		for i=1, 10 do 
			hx711.init(1,2)
			table.insert(values1, decimal(((hx711.read(0) - 130000) / 654 )/2,10) )
		end
		value4=moyenne(values1, 60)
		print (" OK O2 is "..value4.." %")
		table.insert(mesures, {idx=3,nvalue=0, svalue=value4} )

		--  hx711.init(3, 4) --------------------
		values1={}
		for i=1, 10 do 
			hx711.init(3,4)
			table.insert(values1, decimal(((hx711.read(0) - 33000) / 654 )/2,10) )
		end
		value5=moyenne(values1, 60)
		print (" OK Acid is "..value5.." %")
		table.insert(mesures, {idx=4,nvalue=0, svalue=value5} )

		--  Sonde EAU --------------------
			gpio.write(8,gpio.LOW)
			gpio.write(8,gpio.HIGH)
			value6= adc.read(0)	 or 0
			gpio.write(8,gpio.LOW)		
			print ("Field6")
			print (" Niveau eau ="..value6)
			if (value6<=4) then  LEVEL=0  elseif (value6<=50) then  LEVEL=1  elseif (value6<=100) then  LEVEL=2  elseif (value6<=200) then  LEVEL=3  else  LEVEL=4  end  
			table.insert(mesures, {idx=15,nvalue=LEVEL, svalue=value6} )
		
		--  ds18b20 --------------------
			print ("Field7")
			value7=decimal(getTemp(7),100) or 0
			print (" OK temp eau is "..value7.. " °C")
			table.insert(mesures, {idx=1,nvalue=0, svalue=value7} )
		print("-----------")
	  	
	  	nbtry=0
	  	TIMOUT=30 * table.getn(mesures)
	  	if (table.getn(mesures)>0) then 
			print ("postDomoticz "..table.getn(mesures).."")
			-- timer de sécurité 30 secondes par mesure au cas ou perte de signal
			nbtry=0 tmr.alarm(0, 1000,1, function() 	
			if 	(nbtry==0) then postDomoticz(mesures)  end
			print("waiting"..nbtry) 	nbtry=nbtry+1		if (nbtry>=TIMOUT ) then 	print("abandon")  WAIT_MN=1 tmr.stop(0) 	NodeSleep()		end		end) 
		else
			print("Aucune valeure à poster")
		end
		

end
function decimal(nb, base)
	local nb_int = nb / base
        local nb_float = (nb >= 0 and nb % base) or (base - nb % base)
	return nb_int.."."..nb_float
end

function moyenne(tab,ratio)
	table.sort (tab)
	-- on va garder ratio% des valeurs , on supprime les 20% les plus petite et les 20% les plus grandes
	nb_ele_delete=math.ceil(table.getn(tab)* (100 - ratio)/200  )
	for i=1, nb_ele_delete do 
		table.remove(tab,table.getn(tab))
		table.remove(tab,1)
	end
	i=0
	total=0
	table.foreach (tab, 
		function() 
			i=i+1 
			total=tab[i]+total
		end 
	)
	return (total/i)
end