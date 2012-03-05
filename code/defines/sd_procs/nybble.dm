/* Nybble Colors
	Nybble colors is used to compact RGB colors to "nybble" (4 bits, 1 hex
	digit, or decimal numbers 0 to 15.) Since BYOND allows up to 16 bits in
	bitwise mathematics, you could store up to 4 color values in a single
	number. (The project inspiring these procs stores a foreground nybble
	color, background nybble color, and 8 bit text character in each 16 bit
	number.)

	The value of each bit is:
		Bit:		4			3			2			1
		Component:	Intensity	Red			Green		Blue

	Nybble color values are:
		Dec Hex Bin 	Color
		0	0	0000	null color. See the note below.
		1	1	0001	dark blue (navy)
		2	2	0010	dark green
		3	3	0011	dark cyan
		4	4	0100	dark red
		5	5	0101	dark magenta
		6	6	0110	brown
		7	7	0111	grey
		8	8	1000	black
		9	9	1001	blue
		10	A	1010	green
		11	B	1011	cyan
		12	C	1100	red
		13	D	1101	magenta
		14	E	1110	yellow
		15	F	1111	white

		Null color note: rgb2nybble() will return a value of 8 for black, so
		that you may use 0 value nybbles for special cases in your own code.
		For example, in the project that inspired these procs, color 0
		indicates the default background, which is a textured image.
		nybble2rgb() will convert values of 0 or 8 to "000000" (or "000" if
		you specify short rgb.)

PROCS
	sd_nybble2rgb(original, bit = 8, short = 0)
		Converts a nybble color to an RGB hex color string.
		ARGS:
			value	- the number containing the nibble
			bit		- the MSB (most significant bit) of the nybble. The
						default value of 8 uses the lowest 4 bits of original.
						DEFAULT: 8
			short	- short RGB flag. If this is set, the proc returns a
						3 character RGB string. Otherwise it returns a 6
						character RGB string.
						DEFAULT: 0 (return 6 characters)
		RETURNS:
			A 3 or 6 character hexidecimal RGB color string.

	sd_rgb2nybble(rgb, bit = 8)
		Converts an rgb color string to a nybble color.
		ARGS:
			rgb - The color string to be converted. This may be a 3 or 6
					character color code with or without a leading "#".
					Examples: "000", "000000", "#000", "#000000" all
					indicate black.
			bit		- the MSB (most significant bit) of the nybble. You can
						use this to shift the position of your nybble within
						the return value. The default value of 8 uses the
						lowest 4 bits.
						DEFAULT: 8
		RETURNS:
			A nybble color value or null if the proc failed.
*/

/*********************************************
*  Implimentation: No need to read further.  *
*********************************************/
proc
	sd_nybble2rgb(original, bit = 8, short = 0)
		/* Converts a nybble color to an RGB hex color string.
			ARGS:
				value	- the number containing the nibble
				bit		- the MSB (most significant bit) of the nybble. The
							default value of 8 uses the lowest 4 bits of original.
							DEFAULT: 8
				short	- short RGB flag. If this is set, the proc returns a
							3 character RGB string. Otherwise it returns a 6
							character RGB string.
							DEFAULT: 0 (return 6 characters)
			RETURNS:
				A 3 or 6 character hexidecimal RGB color string. */
		var {intensity = "9"; off = "0"}
		if(original & bit)	intensity = "F"
		if(!short)
			intensity += intensity
			off = "00"
		. = ""
		for(var/loop = 1 to 3)
			bit >>= 1
			if(original & bit)	. += intensity
			else				. += off
		if(. == "990") . = "940"
		else if(. == "999900") . = "994400"
		if(intensity == "F" && . == "000000") . = "00FF99"

	sd_rgb2nybble(rgb, bit = 8)
		/* Converts an rgb color string to a nybble color.
			ARGS:
				rgb - The color string to be converted. This may be a 3 or 6
						character color code with or without a leading "#".
						Examples: "000", "000000", "#000", "#000000" all
						indicate black.
				bit		- the MSB (most significant bit) of the nybble. You can
							use this to shift the position of your nybble within
							the return value. The default value of 8 uses the
							lowest 4 bits.
							DEFAULT: 8
			RETURNS:
				A nybble color value or null if the proc failed. */
		if(!istext(rgb)) return
		if(text2ascii(rgb) == 35) 	// leading "#"
			rgb = copytext(rgb,2)
		var{char; cmp[3]; cmp_size; hi = 0; loop; pos = 1}
		switch(length(rgb))
			if(3)	cmp_size = 1
			if(6)	cmp_size = 2
			else	return
		for(loop = 1 to 3)
			char = copytext(rgb, pos, pos+1)
			// char 0 to 3 => 0, 4 to 9 => 1,  A to F => 2
			// cmp[loop] = round(sd_base2dec(char, 16) * 0.15, 1)
			// previous line takes over twice as long as switch() method below
			switch(char)
				if("0", "1", "2", "3")				cmp[loop] = 0
				if("4", "5", "6", "7", "8", "9")	cmp[loop] = 1
				else								cmp[loop] = 2
			if(cmp[loop] > hi)	hi = cmp[loop]
			pos += cmp_size
		switch(hi)
			if(0)	return bit	// color 8: black
			if(2)	. = bit		// high intensity
			else	. = 0		// low intensity
		for(loop = 1 to 3)
			bit >>= 1
			if(cmp[loop] == hi)	. |= bit
