--http://bbs.nodemcu.com/t/lite-ds18b20-lua-only-one-sensor-9bit-max-conversion-time-93-75ms/963
function bxor(a,b) --used when temperature below zero
   local r = 0
   for i = 0, 31 do
      if ( a % 2 + b % 2 == 1 ) then
         r = r + 2^i
      end
      a = a / 2
      b = b / 2
   end
   return r
end


function getTempone(pin)  
	ow.setup(pin) 
	ow.reset(pin)
	ow.skip(pin)  --only one DS18B20, no need addr
	ow.write(pin, 0x4E, 1)  --write Th,Tl and configuration register
	ow.write(pin, 0x32, 1)  --Th, 50?
	ow.write(pin, 0xF6, 1)  --Tl, -10?
	ow.write(pin, 0x1F, 1)  --conversion resolution, 9bit 93.75ms vs. 12bit 750ms
	ow.reset(pin)
	ow.skip(pin)
	ow.write(pin, 0x44, 1)  --conversion
	tmr.delay(100000)  --wait not 1s but 0.1s
	ow.reset(pin)
	ow.skip(pin)
	ow.write(pin,0xBE, 1)  --read 9 bytes
	local data = string.char(ow.read(pin))
	for i = 1, 8 do
		data = data .. string.char(ow.read(pin))
	end
	--print(data:byte(3))
	--print(data:byte(4))
	--print(data:byte(5))  --check 9bit 31, when 12bit 63
	local t = (data:byte(1) + data:byte(2) * 256)
	local crc = ow.crc8(string.sub(data,1,8))
	if (crc == data:byte(9)) then
		t = (data:byte(1) + data:byte(2) * 256)
		if (t > 32768) then  --when winter, below temperature zero
			t = (bxor(t, 0xffff)) + 1
			t = (-1) * t
		end
		t = t * 625
               return t / 100
	end
end
