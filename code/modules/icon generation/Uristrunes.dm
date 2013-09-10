//----------------------------------------
//
//   Take a source icon, convert into a mask,
//  then create a border around it.
//
//   The output then uses the colors and
//  alpha values provided.
//
//----------------------------------------

/proc/create_border_image(icon/input, border_color = "#000000", fill_color = "#000000", border_alpha = 255, fill_alpha = 255)
	var/icon/I = icon('icons/effects/uristrunes.dmi', "blank")
	I.Blend(input, ICON_OVERLAY)

	//Discard the image
	I.MapColors(0,	0,	0,	0, //-\  Ignore
				0,	0,	0,	0, //--> The
				0,	0,	0,	0, //-/  Colors
				0,255,	0,	1, //Keep alpha channel, any pixel with non-zero alpha gets max green channel
				0,	0,	0,	0)

	//Loop over the image, calculating the border value, and storing it in the red channel
	//Store border's alpha in the blue channel
	for(var/x = 1, x <= 32, x++)
		for(var/y = 1, y <= 32, y++)
			var/p = I.GetPixel(x, y)

			if(p == null)
				var/n = I.GetPixel(x, y + 1)
				var/s = I.GetPixel(x, y - 1)
				var/e = I.GetPixel(x + 1, y)
				var/w = I.GetPixel(x - 1, y)
				var/ne = I.GetPixel(x + 1, y + 1)
				var/se = I.GetPixel(x + 1, y - 1)
				var/nw = I.GetPixel(x - 1, y + 1)
				var/sw = I.GetPixel(x - 1, y - 1)

				var/sum_adj = ((n == "#00ff00"? 1 : 0) \
				             + (s == "#00ff00"? 1 : 0) \
				             + (e == "#00ff00"? 1 : 0) \
				             + (w == "#00ff00"? 1 : 0))

				var/sum_diag = ((ne == "#00ff00"? 1 : 0) \
				              + (se == "#00ff00"? 1 : 0) \
				              + (nw == "#00ff00"? 1 : 0) \
				              + (sw == "#00ff00"? 1 : 0))


				if(sum_adj)
					I.DrawBox(rgb(255, 0, 200, 0), x, y)

				else if(sum_diag)
					I.DrawBox(rgb(255, 0, 100, 0), x, y)

				else
					I.DrawBox(rgb(0, 0, 0, 0), x, y)

			else if(p != "#00ff00")
				var/a = 255

				if(length(p) == 9) // "#rrggbbaa", we want the aa
					a = hex2num(copytext(p, 8))

				I.DrawBox(rgb(255 - a, a, 255 - a, a), x, y)

	//Map the red and green channels to the desired output colors
	I.MapColors(border_color, fill_color, rgb(0, 0, 0, border_alpha), rgb(0, 0, 0, fill_alpha), "#00000000")

	return I




//----------------------------------------
//
//   Take a source icon, convert into a mask,
//  and border. Color them according to args,
//  and animate.
//
//----------------------------------------

/proc/animate_rune_full(icon/input, rr1, rg1, rb1, ra1, rr2, rg2, rb2, ra2, br1, bg1, bb1, ba1, br2, bg2, bb2, ba2, ar1, ag1, ab1, aa1, ar2, ag2, ab2, aa2, or1, og1, ob1, oa1, or2, og2, ob2, oa2, frames)

	var/list/colors[10]
	colors[ 1] = list(rr1, rg1, rb1, ra1) //Rune color 1
	colors[ 2] = list(rr2, rg2, rb2, ra2) //Rune color 2
	colors[ 3] = list(br1, bg1, bb1, ba1) //Border color 1
	colors[ 4] = list(br2, bg2, bb2, ba2) //Border color 2
	colors[ 5] = list(  0,   0,   0,   0) //Unused
	colors[ 6] = list(  0,   0,   0,   0) //Unused
	colors[ 7] = list(ar1, ag1, ab1, aa1) //Alpha color 1
	colors[ 8] = list(ar2, ag2, ab2, aa2) //Alpha color 2
	colors[ 9] = list(or1, og1, ob1, oa1) //Added color 1
	colors[10] = list(or2, og2, ob2, oa2) //Added color 2

	var/icon/base = create_border_image(input, "#00ff0000", "#ff000000")

	return generate_color_animation(base, colors, frames)




//----------------------------------------
//
//   Calls the above, but accepts colors in
//  the form of "#RRGGBBAA", and provides
//  default values.
//
//   Main limit is that it doesn't accept
//  negative values, which you probably
//  don't need anyway. Also missing a few
//  color inputs, which would also be rarely
//  used.
//
//----------------------------------------


/proc/animate_rune(icon/input, rune_color = "#00000000", border_color = "#c8000000", rune_color2 = "#00000000", border_color2 = "#d8380000", alpha = 255, alpha2 = 255, frames = rune_animation)
	var/rr1 = hex2num(copytext(rune_color, 2, 4))
	var/rg1 = hex2num(copytext(rune_color, 4, 6))
	var/rb1 = hex2num(copytext(rune_color, 6, 8))
	var/ra1 = hex2num(copytext(rune_color, 8, 10))
	var/rr2 = hex2num(copytext(rune_color2, 2, 4))
	var/rg2 = hex2num(copytext(rune_color2, 4, 6))
	var/rb2 = hex2num(copytext(rune_color2, 6, 8))
	var/ra2 = hex2num(copytext(rune_color2, 8, 10))
	var/br1 = hex2num(copytext(border_color, 2, 4))
	var/bg1 = hex2num(copytext(border_color, 4, 6))
	var/bb1 = hex2num(copytext(border_color, 6, 8))
	var/ba1 = hex2num(copytext(border_color, 8, 10))
	var/br2 = hex2num(copytext(border_color2, 2, 4))
	var/bg2 = hex2num(copytext(border_color2, 4, 6))
	var/bb2 = hex2num(copytext(border_color2, 6, 8))
	var/ba2 = hex2num(copytext(border_color2, 8, 10))

	return animate_rune_full(input, rr1, rg1, rb1, ra1, rr2, rg2, rb2, ra2, br1, bg1, bb1, ba1, br2, bg2, bb2, ba2, 0, 0, 0, alpha, 0, 0, 0, alpha2, 0, 0, 0, 0, 0, 0, 0, 0, frames)


/proc/inanimate_rune(icon/input, rune_color = "#00000000", border_color = "#c8000000")
	var/icon/base = create_border_image(input, "#00ff0000", "#ff000000")

	base.MapColors(rune_color, border_color, "#00000000", "#000000ff", "#00000000")

	return base

var/list/rune_animation = list(
		list(0.000, 5),
		list(0.020, 1),
		list(0.050, 1),
		list(0.090, 1),
		list(0.140, 1),
		list(0.200, 1),
		list(0.270, 1),
		list(0.340, 1),
		list(0.420, 1),
		list(0.500, 1),
		list(0.590, 1),
		list(0.675, 1),
		list(0.750, 1),
		list(0.900, 1),
		list(1.000, 6),
		list(0.875, 1),
		list(0.750, 1),
		list(0.625, 1),
		list(0.500, 1),
		list(0.375, 1),
		list(0.250, 1),
		list(0.125, 1),
	)

/var/list/rune_cache = list()

/proc/get_rune(rune_bits, animated = 0)
	var/lookup = "[rune_bits]-[animated]"

	if(lookup in rune_cache)
		return rune_cache[lookup]

	var/icon/base = icon('icons/effects/uristrunes.dmi', "")

	for(var/i = 0, i < 10, i++)
		if(rune_bits & (1 << i))
			base.Blend(icon('icons/effects/uristrunes.dmi', "rune-[1 << i]"), ICON_OVERLAY)

	var/icon/result

	if(animated == 1)
		result = animate_rune(base)

	else
		result = inanimate_rune(base)

	rune_cache[lookup] = result
	return result





//  Testing procs and Fun procs




/mob/verb/create_rune()
	var/obj/o = new(locate(x, y, z))
	o.icon = get_rune(rand(1, 1023), 1)

/mob/verb/runes_15x15()
	for(var/turf/t in range(7))
		var/obj/o = new /obj(t)
		o.icon = get_rune(rand(1, 1023), 1)


/*
/mob/verb/create_rune_custom(rune as num, color1 as color, border1 as color, color2 as color, border2 as color, alpha1 as num, alpha2 as num)
	var/icon/I = icon('icons/effects/uristrunes.dmi', "blank")

	for(var/i = 0, i < 10, i++)
		if(rune & (1 << i))
			I.Blend(icon('icons/effects/uristrunes.dmi', "rune-[1 << i]"), ICON_OVERLAY)

	var/obj/o = new(locate(x, y, z))
	o.icon = animate_rune(I, color1, border1, color2, border2, alpha1, alpha2)

/mob/verb/spam()
	for(var/turf/t in range(4))
		var/icon/I = icon('icons/effects/uristrunes.dmi', "blank")

		var/rune = rand(1, 1023)
		for(var/i = 0, i < 10, i++)
			if(rune & (1 << i))
				I.Blend(icon('icons/effects/uristrunes.dmi', "rune-[1 << i]"), ICON_OVERLAY)

		var/obj/o = new(t)
		o.icon = animate_rune_full(I, rand(0, 255), rand(0, 255), rand(0, 255), rand(-255, 255),
		                                       rand(0, 255), rand(0, 255), rand(0, 255), rand(-255, 255),
		                                       rand(0, 255), rand(0, 255), rand(0, 255), rand(-255, 255),
		                                       rand(0, 255), rand(0, 255), rand(0, 255), rand(-255, 255),
		                                       0,            0,            0,            rand(0, 255),
		                                       0,            0,            0,            rand(0, 255),
		                                       0,            0,            0,            0,
		                                       0,            0,            0,            0,
		                                       list(
		                                       		list(0.000, 5),
		                                       		list(0.020, 1),
		                                       		list(0.050, 1),
		                                       		list(0.090, 1),
		                                       		list(0.140, 1),
		                                       		list(0.200, 1),
		                                       		list(0.270, 1),
		                                       		list(0.340, 1),
		                                       		list(0.420, 1),
		                                       		list(0.500, 1),
		                                       		list(0.590, 1),
		                                       		list(0.675, 1),
		                                       		list(0.750, 1),
		                                       		list(0.900, 1),
		                                       		list(1.000, 6),
		                                       		list(0.875, 1),
		                                       		list(0.750, 1),
		                                       		list(0.625, 1),
		                                       		list(0.500, 1),
		                                       		list(0.375, 1),
		                                       		list(0.250, 1),
		                                       		list(0.125, 1),
		                                       	))
*/