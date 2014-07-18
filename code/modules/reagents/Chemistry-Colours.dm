/proc/mix_color_from_reagents(var/list/reagent_list)
	if(!reagent_list || !reagent_list.len) return 0

	var/list/rgbcolor = list(0,0,0,0)
	var/finalcolor = 0
	for(var/datum/reagent/re in reagent_list) // natural color mixing bullshit/algorithm
		if(!finalcolor)
			rgbcolor = ReadRGB(re.color)
			finalcolor = re.color
		else
			var/newcolor[4]
			var/prergbcolor[4]
			prergbcolor = rgbcolor
			newcolor = ReadRGB(re.color)

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