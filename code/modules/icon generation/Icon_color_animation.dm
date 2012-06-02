//----------------------------------------
//
//   Return a copy of the provided icon,
//  after calling MapColors on it. The
//  color values are linearily interpolated
//  between the pairs provided, based on
//  the ratio argument.
//
//----------------------------------------

/proc/MapColors_interpolate(icon/input, ratio,
							rr1, rg1, rb1, ra1, rr2, rg2, rb2, ra2,
							gr1, gg1, gb1, ga1, gr2, gg2, gb2, ga2,
							br1, bg1, bb1, ba1, br2, bg2, bb2, ba2,
							ar1, ag1, ab1, aa1, ar2, ag2, ab2, aa2,
							zr1, zg1, zb1, za1, zr2, zg2, zb2, za2)
	var/r = ratio
	var/i = 1 - ratio
	var/icon/I = icon(input)

	I.MapColors(
		(rr1 * r + rr2 * i) / 255.0, (rg1 * r + rg2 * i) / 255.0, (rb1 * r + rb2 * i) / 255.0, (ra1 * r + ra2 * i) / 255.0,
		(gr1 * r + gr2 * i) / 255.0, (gg1 * r + gg2 * i) / 255.0, (gb1 * r + gb2 * i) / 255.0, (ga1 * r + ga2 * i) / 255.0,
		(br1 * r + br2 * i) / 255.0, (bg1 * r + bg2 * i) / 255.0, (bb1 * r + bb2 * i) / 255.0, (ba1 * r + ba2 * i) / 255.0,
		(ar1 * r + ar2 * i) / 255.0, (ag1 * r + ag2 * i) / 255.0, (ab1 * r + ab2 * i) / 255.0, (aa1 * r + aa2 * i) / 255.0,
		(zr1 * r + zr2 * i) / 255.0, (zg1 * r + zg2 * i) / 255.0, (zb1 * r + zb2 * i) / 255.0, (za1 * r + za2 * i) / 255.0)

	return I




//----------------------------------------
//
//   Extension of the above that takes a
//  list of lists of color values, rather
//  than a large number of arguments.
//
//----------------------------------------

/proc/MapColors_interpolate_list(icon/I, ratio, list/colors)
	var/list/c[10]

	//Provide default values for any missing colors (without altering the original list
	for(var/i = 1, i <= 10, i++)
		c[i] = list(0, 0, 0, (i == 7 || i == 8)? 255 : 0)

		if(istype(colors[i], /list))
			for(var/j = 1, j <= 4, j++)
				if(j <= length(colors[i]) && isnum(colors[i][j]))
					c[i][j] = colors[i][j]

	return MapColors_interpolate(I, ratio,
		 colors[ 1][1], colors[ 1][2], colors[ 1][3], colors[ 1][4], // Red 1
		 colors[ 2][1], colors[ 2][2], colors[ 2][3], colors[ 2][4], // Red 2
		 colors[ 3][1], colors[ 3][2], colors[ 3][3], colors[ 3][4], // Green 1
		 colors[ 4][1], colors[ 4][2], colors[ 4][3], colors[ 4][4], // Green 2
		 colors[ 5][1], colors[ 5][2], colors[ 5][3], colors[ 5][4], // Blue 1
		 colors[ 6][1], colors[ 6][2], colors[ 6][3], colors[ 6][4], // Blue 2
		 colors[ 7][1], colors[ 7][2], colors[ 7][3], colors[ 7][4], // Alpha 1
		 colors[ 8][1], colors[ 8][2], colors[ 8][3], colors[ 8][4], // Alpha 2
		 colors[ 9][1], colors[ 9][2], colors[ 9][3], colors[ 9][4], // Added 1
		 colors[10][1], colors[10][2], colors[10][3], colors[10][4]) // Added 2





//----------------------------------------
//
//   Take the source image, and return an animated
//  version, that transitions between the provided
//  color mappings, according to the provided
//  pattern.
//
//   Colors should be in a format suitable for
//  MapColors_interpolate_list, and frames should
//  be a list of 'frames', where each frame is itself
//  a list, element 1 being the ratio of the first
//  color to the second, and element 2 being how
//  long the frame lasts, in tenths of a second.
//
//----------------------------------------

/proc/generate_color_animation(icon/icon, list/colors, list/frames)
	var/icon/out = icon('uristrunes.dmi', "")
	var/frame_num = 1

	for(var/frame in frames)
		var/icon/I = MapColors_interpolate_list(icon, frame[1], colors)
		out.Insert(I, "", 2, frame_num++, 0, frame[2])

	return out



