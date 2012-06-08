//This file was auto-corrected by findeclaration.exe on 29/05/2012 15:03:04

/* sd_color and procs
	sd_color is a special datum that contains color data in various
	formats. Sample colors are available in samplecolors.dm.

sd_color
	var/name		// the name of the color
	var/red			// red componant of the color
	var/green		// green componant of the color
	var/blue		// red componant of the color
	var/html		// html string for the color
	var/icon/Icon	// contains the icon produced by the rgb2icon() proc

	PROCS
		brightness()
			Returns the grayscale brightness of the RGB color set.

		html2rgb()
			Calculates the rgb colors from the html colors.

		rgb2html()
			Calculates the html color from the rbg colors.

		rgb2icon()
			Converts the rgb value to a solid icon stored as src.Icon

*/

/*********************************************
*  Implimentation: No need to read further.  *
*********************************************/
sd_color
	var/name		// the name of the color
	var/red = 0		// red componant of the color
	var/green = 0	// green componant of the color
	var/blue = 0	// red componant of the color
	var/html		// html string for the color
	var/icon/Icon	// contains the icon produced by the rgb2icon() proc

	proc
		brightness()
		/* returns the grayscale brightness of the RGB colors. */
			return round((red*30 + green*59 + blue*11)/100,1)

		html2rgb()
		/* Calculates the rgb colors from the html colors */
			red = sd_base2dec(copytext(html,1,3))
			green = sd_base2dec(copytext(html,3,5))
			blue = sd_base2dec(copytext(html,5,7))

		rgb2html()
		/* Calculates the html color from the rbg colors */
			html = sd_dec2base(red,,2) + sd_dec2base(green,,2) + sd_dec2base(blue,,2)
			return html

		rgb2icon()
		/* Converts the rgb value to a solid icon stored as src.Icon */
			Icon = 'Black.dmi' + rgb(red,green,blue)
			return Icon

	New()
		..()
		// if this is an unnamed subtype, name it according to it's type
		if(!name)
			name = "[type]"
			var/slash = sd_findlast(name,"/")
			if(slash)
				name = copytext(name,slash+1)
			name = sd_replacetext(name,"_"," ")

		if(html)	// if there is an html string
			html2rgb()	// convert the html to red, green, & blue values
		else
			rgb2html()	// convert the red, green, & blue values to html
