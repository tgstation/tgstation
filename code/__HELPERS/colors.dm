/// Given a color in the format of "#RRGGBB", will return if the color
/// is dark.
/proc/is_color_dark(color, threshold = 25)
	var/hsl = rgb2num(color, COLORSPACE_HSL)
	return hsl[3] < threshold

/// Given a 3 character color (no hash), converts it into #RRGGBB (with hash)
/proc/expand_three_digit_color(color)
	if (length_char(color) != 3)
		CRASH("Invalid 3 digit color: [color]")

	var/final_color = "#"

	for (var/digit = 1 to 3)
		final_color += copytext(color, digit, digit + 1)
		final_color += copytext(color, digit, digit + 1)

	return final_color

/// Given a color in the format of "#RRGGBB" or "#RRGGBBAA", gives back a 4 entry list with the number values of each
/proc/split_color(color)
	var/list/output = rgb2num(color)
	if(length(output) == 3)
		output += 255
	return output

///Returns a random color picked from a list, has 2 modes (0 and 1), mode 1 doesn't pick white, black or gray
/proc/random_colour(mode = 0)
	switch(mode)
		if(0)
			return pick("white","black","gray","red","green","blue","brown","yellow","orange","darkred",
						"crimson","lime","darkgreen","cyan","navy","teal","purple","indigo")
		if(1)
			return pick("red","green","blue","brown","yellow","orange","darkred","crimson",
						"lime","darkgreen","cyan","navy","teal","purple","indigo")
		else
			return "white"

///Inverts the colour of an HTML string
/proc/invert_HTML_colour(HTMLstring)
	if(!istext(HTMLstring))
		CRASH("Given non-text argument!")
	else if(length(HTMLstring) != 7)
		CRASH("Given non-HTML argument!")
	else if(length_char(HTMLstring) != 7)
		CRASH("Given non-hex symbols in argument!")
	var/list/color = rgb2num(HTMLstring)
	return rgb(255 - color[1], 255 - color[2], 255 - color[3])

///Flash a color on the passed mob
/proc/flash_color(mob_or_client, flash_color=COLOR_CULT_RED, flash_time=20)
	var/mob/flashed_mob
	if(ismob(mob_or_client))
		flashed_mob = mob_or_client
	else if(istype(mob_or_client, /client))
		var/client/flashed_client = mob_or_client
		flashed_mob = flashed_client.mob

	if(!istype(flashed_mob))
		return

	var/datum/client_colour/temp/temp_color = new(flashed_mob)
	temp_color.colour = flash_color
	temp_color.fade_in = flash_time * 0.25
	temp_color.fade_out = flash_time * 0.25
	QDEL_IN(temp_color, (flash_time * 0.5) + 1)
	flashed_mob.add_client_colour(temp_color)

/// Blends together two colors (passed as 3 or 4 length lists) using the screen blend mode
/// Much like multiply, screen effects the brightness of the resulting color
/// Screen blend will always lighten the resulting color, since before multiplication we invert the colors
/// This makes our resulting output brighter instead of darker
/proc/blend_screen_color(list/first_color, list/second_color)
	var/list/output = new /list(4)

	// max out any non existant alphas
	if(length(first_color) < 4)
		first_color[4] = 255
	if(length(second_color) < 4)
		second_color[4] = 255

	// time to do our blending
	for(var/i in 1 to 4)
		output[i] = (1 - (1 - first_color[i] / 255) * (1 - second_color[i] / 255)) * 255
	return output

/// Used to blend together two different color cutoffs
/// Uses the screen blendmode under the hood, essentially just [/proc/blend_screen_color]
/// But paired down and modified to work for our color range
/// Accepts the color cutoffs as two 3 length list(0-100,...) arguments
/proc/blend_cutoff_colors(list/first_color, list/second_color)
	// These runtimes usually mean that either the eye or the glasses have an incorrect color_cutoffs
	ASSERT(first_color?.len == 3, "First color must be a 3 length list, received [json_encode(first_color)]")
	ASSERT(second_color?.len == 3, "Second color must be a 3 length list, received [json_encode(second_color)]")

	var/list/output = new /list(3)

	// Invert the colors, multiply to "darken" (actually lights), then uninvert to get back to what we want
	for(var/i in 1 to 3)
		output[i] = (1 - (1 - first_color[i] / 100) * (1 - second_color[i] / 100)) * 100

	return output

/**
 * Gets a color for a name, will return the same color for a given string consistently within a round.atom
 *
 * Note that this proc aims to produce pastel-ish colors using the HSL colorspace. These seem to be favorable for displaying on the map.
 *
 * Arguments:
 * * name - The name to generate a color for
 * * sat_shift - A value between 0 and 1 that will be multiplied against the saturation
 * * lum_shift - A value between 0 and 1 that will be multiplied against the luminescence
 */
/proc/colorize_string(name, sat_shift = 1, lum_shift = 1)
	// seed to help randomness
	var/static/rseed = rand(1,26)

	// get hsl using the selected 6 characters of the md5 hash
	var/hash = copytext(md5(name + GLOB.round_id), rseed, rseed + 6)
	var/h = hex2num(copytext(hash, 1, 3)) * (360 / 255)
	var/s = (hex2num(copytext(hash, 3, 5)) >> 2) * ((CM_COLOR_SAT_MAX - CM_COLOR_SAT_MIN) / 63) + CM_COLOR_SAT_MIN
	var/l = (hex2num(copytext(hash, 5, 7)) >> 2) * ((CM_COLOR_LUM_MAX - CM_COLOR_LUM_MIN) / 63) + CM_COLOR_LUM_MIN

	// adjust for shifts
	s = clamp(s * sat_shift, 0, 1)
	l = clamp(l * lum_shift, 0, 1)

	// convert to rgb
	var/h_int = round(h/60) // mapping each section of H to 60 degree sections
	var/c = (1 - abs(2 * l - 1)) * s
	var/x = c * (1 - abs((h / 60) % 2 - 1))
	var/m = l - c * 0.5
	x = (x + m) * 255
	c = (c + m) * 255
	m *= 255
	switch(h_int)
		if(0)
			return "#[num2hex(c, 2)][num2hex(x, 2)][num2hex(m, 2)]"
		if(1)
			return "#[num2hex(x, 2)][num2hex(c, 2)][num2hex(m, 2)]"
		if(2)
			return "#[num2hex(m, 2)][num2hex(c, 2)][num2hex(x, 2)]"
		if(3)
			return "#[num2hex(m, 2)][num2hex(x, 2)][num2hex(c, 2)]"
		if(4)
			return "#[num2hex(x, 2)][num2hex(m, 2)][num2hex(c, 2)]"
		if(5)
			return "#[num2hex(c, 2)][num2hex(m, 2)][num2hex(x, 2)]"

#define RANDOM_COLOUR (rgb(rand(0,255),rand(0,255),rand(0,255)))
