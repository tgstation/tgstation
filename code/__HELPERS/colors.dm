/// Given a color in the format of "#RRGGBB", will return if the color
/// is dark.
/proc/is_color_dark(color, threshold = 0.25)
	var/list/rgb = hex2rgb(color)
	var/list/hsl = rgb2hsl(rgb[1], rgb[2], rgb[3])
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
