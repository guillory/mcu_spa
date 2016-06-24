
require("settings")
dofile("wifi.lua")
dofile('postDomoticz.lua')
dofile('sensor.lua')
require('ds18b20_small')
print("init")
mesures={}
tmr.delay(1000000)
ConnectWifi()
