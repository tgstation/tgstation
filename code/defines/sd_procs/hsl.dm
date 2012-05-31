//This file was auto-corrected by findeclaration.exe on 29/05/2012 15:03:04

/* HSL procs
	These procs convert between RGB (red, green, blu) and HSL (hue, saturation, light)
		color spaces. The algorithms used for these procs were found at
		http://www.paris-pc-gis.com/MI_Enviro/Colors/color_models.htm

	hsl2rgb(hue, sat, lgh, scale = 240)
		Returns the RRGGBB format of an HSL color.

		ALTERNATE FORMAT:
			hsl2rgb(HSL, scale)
		ARGS:
			hue		- hue
			sat		- saturation
			lgh		- light/dark
			HSL		- a hex string in format HHSSLL where:
						HH = Hue from
						SS = Saturation
						LL = light
			scale	- high end of the HSL values. Some programs (like BYOND Dream Maker)
						use 240, others use 255. The H {0-360}, S {0-100}, L {0-100}
						scale is not supported.
						DEFAULT: 240
		RETURNS:
			RGB color string in RRGGBB format.

	rgb2hsl(red, grn, blu, scale = 240)
		Returns the HSL color string of an RGB color

		ALTERNATE FORMAT:
			rgb2hsl(RGB, scale)
		ARGS:
			red		- red componant {0-255}
			grn		- green componant {0-255}
			blu		- blue componant {0-255}
			RGB		- a hex string in format RRGGBB
			scale	- high end of the HSL values. Some programs (like BYOND Dream Maker)
						use 240, others use 255. The H {0-360}, S {0-100}, L {0-100}
						scale is not supported.
						DEFAULT: 240
		RETURNS:
			HHSSLL color string
*/

/*********************************************
*  Implimentation: No need to read further.  *
*********************************************/

proc
	hsl2rgb(hue, sat, lgh, scale = 240)
		/* Returns the RRGGBB format of an HSL color string
			algorithm from http://www.paris-pc-gis.com/MI_Enviro/Colors/color_models.htm
		ALTERNATE FORMAT:
			hsl2rgb(HSL, scale)
		ARGS:
			hue		- hue
			sat		- saturation
			lgh		- light/dark
			HSL		- a hex string in format HHSSLL where:
						HH = Hue from
						SS = Saturation
						LL = light
			scale	- high end of the HSL values. Some programs (like BYOND Dream Maker)
						use 240, others use 255. The H {0-360}, S {0-100}, L {0-100}
						scale is not supported.
						DEFAULT: 240
		RETURNS:
			RGB color string in RRGGBB format. */

		if(istext(hue)) // used alternate hsl2rgb("HHSSLL", scale)
			if(length(hue)!=6)
				CRASH("hsl2rbg('[hue]'): text argument must be a 6 character hex code.")
				return
			if(isnum(sat)) scale = sat
			lgh = sd_base2dec(copytext(hue,5))
			sat = sd_base2dec(copytext(hue,3,5))
			hue = sd_base2dec(copytext(hue,1,3))

		// scale decimal {0-1}
		hue /= scale
		sat /= scale
		lgh /= scale

		var/red
		var/grn
		var/blu

		if(!sat)	// greyscale
			red = lgh
			grn = lgh
			blu = lgh
		else
			var/temp1
			var/temp2
			var/temp3
			if(lgh < 0.5) temp2 = lgh * (1 + sat)
			else temp2 = lgh + sat - lgh * sat
			temp1 = 2 * lgh - temp2

			// red
			temp3 = hue + 1/3
			if(temp3 > 1) temp3--
			if(6*temp3<1) red = temp1 + (temp2 - temp1) * 6 * temp3
			else if(2*temp3<1) red = temp2
			else if(3*temp3<2) red = temp1 + (temp2 - temp1) * ((2/3) - temp3) * 6
			else red = temp1

			// green
			temp3 = hue
			if(6*temp3<1) grn = temp1 + (temp2 - temp1) * 6 * temp3
			else if(2*temp3<1) grn = temp2
			else if(3*temp3<2) grn = temp1 + (temp2 - temp1) * ((2/3) - temp3) * 6
			else grn = temp1

			// blue
			temp3 = hue - 1/3
			if(temp3 < 0) temp3++
			if(6*temp3<1) blu = temp1 + (temp2 - temp1) * 6 * temp3
			else if(2*temp3<1) blu = temp2
			else if(3*temp3<2) blu = temp1 + (temp2 - temp1) * ((2/3) - temp3) * 6
			else blu = temp1

		// shift from {0-1} scale to integers {0-255}
		red = round(red*255, 1)
		grn = round(grn*255, 1)
		blu = round(blu*255, 1)

		// return 6 digit hex string
		return sd_dec2base(red,16, 2) + sd_dec2base(grn,16, 2) + sd_dec2base(blu,16, 2)


	rgb2hsl(red, grn, blu, scale = 240)
		/* Returns the HSL color string of a RGB color
			algorithm from http://www.paris-pc-gis.com/MI_Enviro/Colors/color_models.htm
		ALTERNATE FORMAT:
			rgb2hsl(RGB, scale)
		ARGS:
			red		- red componant {0-255}
			grn		- green componant {0-255}
			blu		- blue componant {0-255}
			RGB		- a hex string in format RRGGBB
			scale	- high end of the HSL values. Some programs (like BYOND Dream Maker)
						use 240, others use 255. The H {0-360}, S {0-100}, L {0-100}
						scale is not supported.
						DEFAULT: 240
		RETURNS:
			HHSSLL color string	*/

		if(istext(red))	// used alternate rgb2hsl("RRGGBB", scale) format
			if(length(red)!=6)
				CRASH("rbg2hsl('[red]'): text argument must be a 6 character hex code.")
				return
			if(isnum(grn)) scale = grn
			blu = sd_base2dec(copytext(red,5))
			grn = sd_base2dec(copytext(red,3,5))
			red = sd_base2dec(copytext(red,1,3))

		// scale decimal {0-1}
		red /= 255
		grn /= 255
		blu /= 255
		var/lo = min(red, grn, blu)
		var/hi = max(red, grn, blu)
		var/hue = 0
		var/sat = 0
		var/lgh = (lo + hi)/2

		if(lo != hi)	// if equal, hue and sat may both stay 0
			if(lgh < 0.5) sat = (hi - lo) / (hi + lo)
			else sat = (hi - lo) / (2 - hi - lo)
			// produce hue as value from 0-6
			if(red == hi) hue = (grn - blu) / (hi - lo)
			else if(grn == hi) hue = 2 + (blu - red) / (hi - lo)
			else hue = 4 + (red - grn) / (hi - lo)
			if(hue<0) hue += 6

		// convert decimal {0-1} to integer {0-scale}
		lgh = round(lgh * scale, 1)
		sat = round(sat * scale, 1)
		// convert hue as decimal 0-6 to integer {0-scale}
		hue = round((hue / 6) * scale, 1)

		// return 6 digit hex string
		return sd_dec2base(hue,16, 2) + sd_dec2base(sat,16, 2) + sd_dec2base(lgh,16, 2)
