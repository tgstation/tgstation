/* sd_procs
	by: Shadowdarke (shadowdarke@hotmail.com)

	A collection of general purpose procs I use often in
	other projects.

The following is a summary of all the procs and other additions included in
the sd_procs library. Please refer to the specific file for detailed information.


Atom (atom.dm)
	These procs expand on the basic built in procs.

	Bumped(O)
		Automatically called whenever a movable atom O Bump()s into src.
		Proc protype designed to be overridden for specific objects.

	Trigger(O)
		Automatically called whenever a movable atom O steps into the same
		turf with src.
		Proc protype designed to be overridden for specific objects.


Base 64 (base64.dm)
	These procs convert plain text to a hexidecimal string to 64 encoded text and vice versa.

	sd_base64toHex(encode64, pad_code = 67)
		Accepts a base 64 encoded text and returns the hexidecimal equivalent.

	sd_hex2base64(hextext, pad_char = "=")
		Accepts a hexidecimal string and returns the base 64 encoded text equivalent.

	sd_hex2text(hex)
		Accepts a hexidecimal string and returns the plain text equivalent.

	sd_text2hex(txt)
		Accepts a plain text string and returns the hexidecimal equivalent.


Colors(color.dm)
	sd_color
		sd_color is a special datum that contains color data in various
		formats. Sample colors are available in samplecolors.dm.
		VARS
			name		// the name of the color
			red			// red componant of the color
			green		// green componant of the color
			blue		// red componant of the color
			html		// html string for the color
			icon/Icon	// contains the icon produced by rgb2icon() proc

		PROCS
			brightness()
				Returns the grayscale brightness of the RGB color set.

			html2rgb()
				Calculates the rgb colors from the html colors.

			rgb2html()
				Calculates the html color from the rbg colors.

			rgb2icon()
				Converts the rgb value to a solid icon stored as src.Icon

Direction procs (direction.dm)
	sd_get_approx_dir(atom/ref,atom/target)
		returns the approximate direction from ref to target.

	sd_degrees2dir(degrees as num)
		Accepts an angle in degrees and returns the closest BYOND
		direction value.

	sd_dir2degrees(dir as num)
		Accepts a BYOND direction value and returns the angle North of
		East in degrees.

	sd_dir2radial(dir as num)
		Accepts a BYOND direction value and returns the radial direction
		(0-7) North of East.

	sd_dir2radians(dir as num)
		Accepts a BYOND direction value and returns the angle North of
		East in radians.

	sd_dir2text(dir as num)
		Accepts a BYOND direction value and returns the lowercase text
		name of the direction.

	sd_dir2Text(dir as num)
		Accepts a BYOND direction value and returns the Capitalized text
		name of the direction

	sd_radial2dir(radial as num)
		Accepts a radial direction (0-7) and returns the BYOND direction
		value.

HSL procs (hsl.dm)
	hsl2rgb(hue, sat, lgh, scale = 240)
		Returns the RRGGBB format of an HSL color.
		ALTERNATE FORMAT: hsl2rgb(HSL, scale)

	rgb2hsl(red, grn, blu, scale = 240)
		Returns the HHSSLL string of an RGB color
		ALTERNATE FORMAT: rgb2hsl(RGB, scale)

Math procs (math.dm)
	sd_base2dec(number as text, base = 16 as num)
		Accepts a number in any base (2 to 36) and returns the equivelent
		value in decimal.

	sd_dec2base(decimal,base = 16 as num,digits = 0 as num)
		Accepts a decimal number and returns the equivelent value in the
		new base as a string.

	sd_get_dist(atom/A, atom/B)
		Returns the mathematical 3D distance between two atoms.

	sd_get_dist_squared(atom/A, atom/B)
		Returns the square of the mathematical 3D distance between two atoms. (More processor
		friendly than sd_get_dist() and useful for modelling realworld physics.)

Nybble Color procs (nybble.dm)
	sd_nybble2rgb(original, bit = 8, short = 0)
		Converts a nybble color to a hexidecimal RGB color string.

	sd_rgb2nybble(rgb, bit = 8)
		Converts an RGB color string to a nybble color.


Sample sd_colors. (samplecolors.dm)
	This file includes 142 predefined sd_colors. It will not automatically
	be included in your projects, since you may want to define them differently.


Test program (test.dm)
	This file provides a brief demo of some library functions.
	It is not included in your projects.


Text procs (text.dm)
	sd_findlast(maintext as text, searchtext as text)
		Returns the location of the last instance of searchtext in
		maintext. sd_findlast is not case sensitive.

	sd_findLast(maintext as text, searchtext as text)
		Returns the location of the last instance of searchtext in
		maintext. sd_findLast is case sensitive.

	sd_htmlremove(T as text)
		Returns the text string with all potential html tags (anything
		between < and >) removed.

	sd_replacetext(maintext as text, oldtext as text, newtext as text)
		Replaces all instances of oldtext within maintext with newtext.
		sd_replacetext is not case sensitive.

	sd_replaceText(maintext as text, oldtext as text, newtext as text)
		Replaces all instances of oldtext within maintext with newtext.
		sd_replaceText is case sensitive.

*/