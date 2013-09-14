/proc/Getcolours(hex)
	hex = uppertext(hex)
	var/hi1 = text2ascii(hex, 2)
	var/lo1 = text2ascii(hex, 3)
	var/hi2 = text2ascii(hex, 4)
	var/lo2 = text2ascii(hex, 5)
	var/hi3 = text2ascii(hex, 6)
	var/lo3 = text2ascii(hex, 7)
	return list(((hi1>= 65 ? hi1-55 : hi1-48)<<4) | (lo1 >= 65 ? lo1-55 : lo1-48),
		((hi2 >= 65 ? hi2-55 : hi2-48)<<4) | (lo2 >= 65 ? lo2-55 : lo2-48),
		((hi3 >= 65 ? hi3-55 : hi3-48)<<4) | (lo3 >= 65 ? lo3-55 : lo3-48))

/proc/mix_colour_from_reagents(var/list/reagent_list)
	if(!reagent_list || !reagent_list.len) return 0

	var/list/rgbcolour = list(0,0,0)
	var/finalcolour = 0
	for(var/datum/reagent/re in reagent_list) // natural colour mixing bullshit/algorithm
		if(!finalcolour)
			rgbcolour = Getcolours(re.colour)
			finalcolour = re.colour
		else
			var/newcolour[3]
			var/prergbcolour[3]
			prergbcolour = rgbcolour
			newcolour = Getcolours(re.colour)

			rgbcolour[1] = (prergbcolour[1]+newcolour[1])/2
			rgbcolour[2] = (prergbcolour[2]+newcolour[2])/2
			rgbcolour[3] = (prergbcolour[3]+newcolour[3])/2

			finalcolour = rgb(rgbcolour[1], rgbcolour[2], rgbcolour[3])

	return finalcolour

// This isn't a perfect colour mixing system, the more reagents that are inside,
// the darker it gets until it becomes absolutely pitch black! I dunno, maybe
// that's pretty realistic? I don't do a whole lot of colour-mixing anyway.
// If you add brighter colours to it it'll eventually get lighter, though.