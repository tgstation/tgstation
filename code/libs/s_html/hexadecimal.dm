/**************************************
Hexadecimal Number Manipulation
             by Jeremy "Spuzzum" Gibson
***************************************
12345678901234567890123456789012345678901234567890
These are hexadecimal manipulation procs that let
you convert between decimals and hexadecimals.
Note well that you can already convert numbers
into an HTML colour string with BYOND's rgb()
proc.  This is designed for hexadecimal, which
encompasses a larger field.

**************************************/

proc/hex2num(hex)
	//Converts a hexadecimal string (eg. "9F") into a numeral (eg. 159).

	if(!istext(hex))
		CRASH("hex2num not given a hexadecimal string argument (user error)")
		return

	var/num = 0
	var/power = 0

	for(var/i = lentext(hex), i > 0, i--)
		var/char = copytext(hex, i, i+1) //extract hexadecimal character from string
		switch(char)
			if("0")
				power++  //We don't do anything with a zero, so we'll just increase the power,
				continue // then go onto the next iteration.

			if("1","2","3","4","5","6","7","8","9")
				num += text2num(char) * (16 ** power)

			if("A","a") num += 10 * (16 ** power)
			if("B","b") num += 11 * (16 ** power)
			if("C","c") num += 12 * (16 ** power)
			if("D","d") num += 13 * (16 ** power)
			if("E","e") num += 14 * (16 ** power)
			if("F","f") num += 15 * (16 ** power)

			else
				CRASH("hex2num given non-hexadecimal string (user error)")
				return

		power++

	return(num)


proc/num2hex(num, placeholder=2)
	//Converts a numeral (eg. 255) into a hexadecimal string (eg. "FF")
	//The 'placeholder' argument inserts zeroes in front of the string
	// until the string is that length -- eg. 15 in hexadecimal is "F",
	// but the placeholder of 2 would make it "0F".

	if(!isnum(num))
		CRASH("num2hex not given a numeric argument (user error)")
		return

	if(!num) return("0") //no computation necessary

	var/hex = ""

	var/i = 0
	while(16**i < num) i++

	for(var/power = i-1, power >= 0, power--)
		var/val = round( num / (16 ** power) )
		num -= val * (16 ** power)
		switch(val)
			if(0,1,2,3,4,5,6,7,8,9) hex += "[val]"

			if(10) hex += "A"
			if(11) hex += "B"
			if(12) hex += "C"
			if(13) hex += "D"
			if(14) hex += "E"
			if(15) hex += "F"

	while(lentext(hex) < placeholder) hex = "0[hex]"

	return(hex)