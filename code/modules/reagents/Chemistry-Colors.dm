/proc/GetColors(hex)
	hex = uppertext(hex)
	// No alpha set? Default to full alpha.
	if(length(hex) == 7)
		hex += "FF"
	var/hi1 = text2ascii(hex, 2) // R
	var/lo1 = text2ascii(hex, 3) // R
	var/hi2 = text2ascii(hex, 4) // G
	var/lo2 = text2ascii(hex, 5) // G
	var/hi3 = text2ascii(hex, 6) // B
	var/lo3 = text2ascii(hex, 7) // B
	var/hi4 = text2ascii(hex, 8) // A
	var/lo4 = text2ascii(hex, 9) // A
	return list(((hi1>= 65 ? hi1-55 : hi1-48)<<4) | (lo1 >= 65 ? lo1-55 : lo1-48),
		((hi2 >= 65 ? hi2-55 : hi2-48)<<4) | (lo2 >= 65 ? lo2-55 : lo2-48),
		((hi3 >= 65 ? hi3-55 : hi3-48)<<4) | (lo3 >= 65 ? lo3-55 : lo3-48),
		((hi4 >= 65 ? hi4-55 : hi4-48)<<4) | (lo4 >= 65 ? lo4-55 : lo4-48))

/proc/mix_color_from_reagents(var/list/reagent_list)
	if(!reagent_list || !reagent_list.len) return 0

	var/list/rgbcolor = list(0,0,0,0)
	var/finalcolor = 0
	for(var/datum/reagent/re in reagent_list) // natural color mixing bullshit/algorithm
		if(!finalcolor)
			rgbcolor = GetColors(re.color)
			finalcolor = re.color
		else
			var/newcolor[4]
			var/prergbcolor[4]
			prergbcolor = rgbcolor
			newcolor = GetColors(re.color)

			rgbcolor[1] = (prergbcolor[1]+newcolor[1])/2
			rgbcolor[2] = (prergbcolor[2]+newcolor[2])/2
			rgbcolor[3] = (prergbcolor[3]+newcolor[3])/2
			rgbcolor[4] = (prergbcolor[4]+newcolor[4])/2

			finalcolor = rgb(rgbcolor[1], rgbcolor[2], rgbcolor[3], rgbcolor[4])
	return finalcolor

// This isn't a perfect color mixing system, the more reagents that are inside,
// the darker it gets until it becomes absolutely pitch black! I dunno, maybe
// that's pretty realistic? I don't do a whole lot of color-mixing anyway.
// If you add brighter colors to it it'll eventually get lighter, though.