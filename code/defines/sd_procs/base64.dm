//This file was auto-corrected by findeclaration.exe on 29/05/2012 15:03:04

/* base 64 procs
	These procs convert plain text to a hexidecimal string to 64 encoded text and vice versa.

	sd_base64toHex(encode64, pad_code = 67)
		Accepts a base 64 encoded text and returns the hexidecimal equivalent.
		ARGS:
			encode64	= the base64 text to convert
			pad_code = the character or ASCII code used to pad the base64 text.
					DEFAULT: 67 (= sign)
		RETURNS: the hexidecimal text

	sd_hex2base64(hextext, pad_char = "=")
		Accepts a hexidecimal string and returns the base 64 encoded text equivalent.
		ARGS:
			hextext		= hex text to convert
			pad_char	= the character or ASCII code used to pad the base64 text.
					DEFAULT: "=" (ASCII 67)
		RETURNS: the base64 text

	sd_hex2text(hex)
		Accepts a hexidecimal string and returns the plain text equivalent.

	sd_text2hex(txt)
		Accepts a plain text string and returns the hexidecimal equivalent.
*/

/*********************************************
*  Implimentation: No need to read further.  *
*********************************************/
proc
	sd_base64toHex(encode64, pad_code = 67)
		/* convert the base 64 text encode64 to hexidecimal text
			pad_code = the character or ASCII code used to pad the base64 text.
					DEFAULT: 67 (= sign)
			RETURNS: the hexidecimal text */
		var/pos = 1
		var/offset = 2
		var/current = 0
		var/padding = 0
		var/hextext = ""
		if(istext(pad_code)) pad_code = text2ascii(pad_code)
		while(pos <= length(encode64))
			var/val = text2ascii(encode64, pos++)
			if((val >= 65) && (val <= 90))			// A to Z
				val -= 65
			else if((val >= 97) && (val <= 122))	// a to z
				val -= 71
			else if((val >= 48) && (val <= 57))		// 0 to 9
				val += 4
			else if(val == 43)						// + sign
				val = 62
			else if(val == 47)						// / symbol
				val = 63
			else if(pad_code)						// padding
				// the = sign indicates that some 0 bits were appended to pad the original string to
				val = -1
				padding ++
			else									// anything else (presumably whitespace)
				val = -1
			if(val < 0)	continue	// whitespace and padding ignored

			if(offset>2)
				var/lft = val >> (8 - offset)
				current |= lft
				hextext += sd_dec2base(current,,2)

			current = (val << offset) & 0xFF

			offset += 2
			if(offset > 8)
				offset = 2

		if(padding)
			hextext = copytext(hextext, 1, length(hextext) + 1 - padding * 2)
		return hextext

	sd_hex2base64(hextext, pad_char = "=")
		/* convert the hexidecimal string hextext to base 64 encoded text
			pad_char = the character or ASCII code used to pad the base64 text.
					DEFAULT: "=" (ASCII 67)
			RETURNS: the base 64 encoded text */
		var/key64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
		var/encode64 = ""
		var/pos = 1
		var/offset = 2
		var/current = 0
		var/len = length(hextext)
		var/end = len
		var/padding = end%6
		if(padding)
			padding = 6 - padding
			end += padding
			padding >>= 1
		if(isnum(pad_char)) pad_char = ascii2text(pad_char)
		while(pos <= end)
			var/val = 0	// pad with 0s
			if(pos < len) val = sd_base2dec(copytext(hextext, pos, pos+2))
			pos+=2

			var/lft = val >> offset
			current |= lft
			encode64 += copytext(key64,current+1,current+2)

			current = (val << (6-offset)) & 0x3F

			offset += 2
			if(offset>6)
				encode64 += copytext(key64,current+1,current+2)
				offset = 2
				current = 0
		for(var/x = 1 to padding)
			encode64 += pad_char
		return encode64

	sd_hex2text(hex)
		/* convert hexidecimal text to a plain text string
			RETURNS: the plain text */
		var/txt = ""
		for(var/loop = 1 to length(hex) step 2)
			txt += ascii2text(sd_base2dec(copytext(hex,loop, loop+2)))
		return txt

	sd_text2hex(txt)
		/* convert plain text to a hexidecimal string
			RETURNS: the hexidecimal text */
		var/hex = ""
		for(var/loop = 1 to length(txt))
			hex += sd_dec2base(text2ascii(txt,loop),,2)
		return hex
