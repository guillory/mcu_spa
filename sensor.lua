
function Sensor()
	gpio.mode(8,gpio.OUTPUT)
	gpio.write(8,gpio.LOW)
	gpio.mode(5,gpio.OUTPUT)
	gpio.write(5,gpio.LOW)
	mesures={}
--  hx711.init(1,2) --------------------
	values1={}
	hx711.init(1,2)
	for i=1, 10 do 
		tmr.delay(500000)
		val=((hx711.read(0) - TARREO2) / HX711RATIO )/2 -- 2 car pourcetage sur 20 kg
		table.insert(values1,val)
	end
	value4=decimal(moyenne(values1, 60),10)
	print ("O2 = "..value4.." %")
	table.insert(mesures, {idx=3,nvalue=0, svalue=value4} )

--  hx711.init(3, 4) --------------------
	values1={}
	hx711.init(3,4)
	for i=1, 10 do 
		tmr.delay(500000)
		val=((hx711.read(0) - TARREACID) / HX711RATIO )/2 
		table.insert(values1, val)
	end
	value5=decimal(moyenne(values1, 60),10)
	print ("Acid = "..value5.." %")
	table.insert(mesures, {idx=4,nvalue=0, svalue=value5} )
	
-- PH SENSOR --
	values1={}
	gpio.write(5,gpio.HIGH)
	for i=1, 10 do 
		tmr.delay(500000)
		ph=(adc.read(0)-TARREPH)*1400/1024 -- 55 correctif
	     	--print("->ph"..ph)
	     	table.insert(values1, ph)
	end
	gpio.write(5,gpio.LOW)
	value5=decimal(moyenne(values1, 60),100)
	print("PH = "..value5)
	table.insert(mesures, {idx=18,nvalue=0, svalue=value5} )
--  DHT11 --------------------
	values1={}
	values2={}
	for i=1, 10 do 
		tmr.delay(500000)
		status, temp, humi, temp_dec, humi_dec = dht.read(6)
		if status == dht.OK then
		     	-- print(string.format("DHT Temperature:%d.%03d;Humidity:%d.%03d\r\n", math.floor(temp),temp_dec,math.floor(humi),humi_dec))
		     	table.insert(values1, temp)
			table.insert(values2, humi)
		elseif status == dht.ERROR_CHECKSUM then
			-- print( "  DHT Checksum error." )
		elseif status == dht.ERROR_TIMEOUT then
			-- print( "  DHT timed out." )
		end
		
	end	
	value2=moyenne(values1, 60)
	print("Temp = "..value2.." °C")
	value3=moyenne(values2, 60)
	print("Humid = "..value3.." %")
	table.insert(mesures, {idx=2,nvalue=0, svalue=value2..";"..value3..";0"} )		
	--  ds18b20 --------------------
	values1={}
	for i=1, 10 do 
		tmr.delay(500000)
		value7=getTempone(7) or 0
		table.insert(values1,value7)
	end
	value7=decimal(moyenne(values1, 60),100)
	print ("Temp eau  = "..value7.. " °C")
	table.insert(mesures, {idx=1,nvalue=0, svalue=value7} )
	
	--  Sonde EAU --------------------
	values1={}
	gpio.write(8,gpio.HIGH)
	for i=1, 10 do 
		tmr.delay(500000)
		value6= adc.read(0)or 0
		table.insert(values1,value6)
	end
	gpio.write(8,gpio.LOW)		
	value6=moyenne(values1, 60)
	print ("Niveau eau = "..value6)
	if (value6<=4) then  LEVEL=0  elseif (value6<=50) then  LEVEL=1  elseif (value6<=100) then  LEVEL=2  elseif (value6<=200) then  LEVEL=3  else  LEVEL=4  end  
	table.insert(mesures, {idx=15,nvalue=LEVEL, svalue=value6} )
	
	print("-----------")
  	
  	nbtry=0
  	TIMOUT=30 * table.getn(mesures)
  	if (table.getn(mesures)>0) then 
		print ("postDomoticz "..table.getn(mesures).." values")
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