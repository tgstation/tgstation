/* Math procs
	These procs contain basic math routines.

	sd_base2dec(number as text, base = 16 as num)
		Accepts a number in any base (2 to 36) and returns the equivelent
		value in decimal.
		ARGS:
			number	- number to convert as a text string
			base	- number base
		RETURNS:
			decimal value of the number

	sd_dec2base(decimal,base = 16 as num,digits = 0 as num)
		Accepts a decimal number and returns the equivelent value in the
		new base as a string.
		ARGS:
			decimal	- number to convert
			base	- new number base
			digits	- if output is less than digits, it will add
						preceeding 0s to pad it out
		RETURNS:
			equivelent value in the new base as a string

	sd_get_dist(atom/A, atom/B)
		Returns the mathematical 3D distance between two atoms.

	sd_get_dist_squared(atom/A, atom/B)
		Returns the square of the mathematical 3D distance between two atoms. (More processor
		friendly than sd_get_dist() and useful for modelling realworld physics.)
*/

/*********************************************
*  Implimentation: No need to read further.  *
*********************************************/
proc
	sd_base2dec(number as text, base = 16 as num)
	/* Accepts a number in any base (2 to 36) and returns the equivelent
		value in decimal.
		ARGS:
			number	- number to convert as a text string
			base	- number base
		RETURNS:
			decimal value of the number
	*/
		if(!istext(number))
			world.log << "sd_base2dec: invalid number string- [number]"
			return null
		if(!isnum(base) || (base < 2) || (base > 36))
			world.log << "sd_base2dec: invalid base - [base]"
			return null

		var/decimal = 0
		number = uppertext(number)

		for(var/loop = 1, loop <= lentext(number))
			var/digit = copytext(number,loop,++loop)
			if((digit >= "0") && (digit <= "9"))
				decimal = decimal * base + text2num(digit)
			else if((digit >= "A") && (digit <= "Z"))
				decimal = decimal * base + (text2ascii(digit) - 55)
			else
				break	// terminate when it encounters an invalid character

		return decimal


	sd_dec2base(decimal,base = 16 as num,digits = 0 as num)
	/* Accepts a decimal number and returns the equivelent value in the
		new base as a string.
		ARGS:
			decimal	- number to convert
			base	- new number base
			digits	- if output is less than digits, it will add
						preceeding 0s to pad it out
		RETURNS:
			equivelent value in the new base as a string
	*/
		if(istext(decimal)) decimal = text2num(decimal)
		decimal = round(decimal)
		if(!isnum(decimal) || (decimal < 0))
			world.log << "sd_dec2base: invalid decimal number - [decimal]"
			return null
		if(!isnum(base) || (base < 2) || (base > 36))
			world.log << "sd_dec2base: invalid base - [base]"
			return null

		var/text = ""
		if(!decimal) text = "0"
		while(decimal)
			var/n = decimal%base
			if(n<10)
				text = num2text(n) + text
			else
				text = ascii2text(55+n) + text

			decimal = (decimal - n)/base

		while(lentext(text) < digits)
			text = "0" + text

		return text


	sd_get_dist(atom/A, atom/B)
	/* Returns the mathematical 3D distance between two atoms. */
		var/X = (A.x - B.x)
		var/Y = (A.y - B.y)
		var/Z = (A.z - B.z)
		return sqrt(X * X + Y * Y + Z * Z)

	sd_get_dist_squared(atom/A, atom/B)
	/* Returns the square of the mathematical 3D distance between two atoms. (More processor
		friendly than sd_get_dist() and useful for modelling realworld physics.) */
		var/X = (A.x - B.x)
		var/Y = (A.y - B.y)
		var/Z = (A.z - B.z)
		return X * X + Y * Y + Z * Z
