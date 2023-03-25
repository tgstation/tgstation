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
	var/textr = copytext(HTMLstring, 2, 4)
	var/textg = copytext(HTMLstring, 4, 6)
	var/textb = copytext(HTMLstring, 6, 8)
	return rgb(255 - hex2num(textr), 255 - hex2num(textg), 255 - hex2num(textb))

///Flash a color on the client
/proc/flash_color(mob_or_client, flash_color="#960000", flash_time=20)
	var/client/flashed_client
	if(ismob(mob_or_client))
		var/mob/client_mob = mob_or_client
		if(client_mob.client)
			flashed_client = client_mob.client
		else
			return
	else if(istype(mob_or_client, /client))
		flashed_client = mob_or_client

	if(!istype(flashed_client))
		return

	var/animate_color = flashed_client.color
	flashed_client.color = flash_color
	animate(flashed_client, color = animate_color, time = flash_time)

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
	var/list/output = new /list(3)

	// Invert the colors, multiply to "darken" (actually lights), then uninvert to get back to what we want
	for(var/i in 1 to 3)
		output[i] = (1 - (1 - first_color[i] / 100) * (1 - second_color[i] / 100)) * 100

	return output


#define RANDOM_COLOUR (rgb(rand(0,255),rand(0,255),rand(0,255)))

