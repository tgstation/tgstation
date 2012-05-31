/proc/bsi_cast_ray(icon/I, list/start, list/end)

	if(abs(start[1] - end[1]) > abs(start[2] - end[2]))
		var/dist = abs(start[1] - end[1]) * 2

		for(var/i = 1, i <= dist, i++)
			var/x = round((start[1] * i / dist) + (end[1] * (1 - i / dist)))
			var/y = round((start[2] * i / dist) + (end[2] * (1 - i / dist)))

			if(I.GetPixel(x, y) != null)
				return list(x, y)

	else
		var/dist = abs(start[2] - end[2]) * 2

		for(var/i = 1, i <= dist, i++)
			var/x = round((start[1] * i / dist) + (end[1] * (1 - i / dist)))
			var/y = round((start[2] * i / dist) + (end[2] * (1 - i / dist)))

			if(I.GetPixel(x, y) != null)
				return list(x, y)

	return null

/proc/bsi_split_colors(color)
	if(color == null)
		return list(0, 0, 0, 0)

	var/list/colors = list(0, 0, 0, 0)
	colors[1] = hex2num(copytext(color, 2, 4))
	colors[2] = hex2num(copytext(color, 4, 6))
	colors[3] = hex2num(copytext(color, 6, 8))
	colors[4] = (length(color) > 7)? hex2num(copytext(color, 8, 10)) : 255

	return colors

/proc/bsi_spread(icon/I, list/start_point)
	var/list/queue = list()
	queue[++queue.len] = start_point

	var/i = 0

	while(i++ < length(queue))
		var/x = queue[i][1]
		var/y = queue[i][2]

		var/list/pixel = bsi_split_colors(I.GetPixel(x, y))
		if(pixel[4] == 0)
			continue

		var/list/n = (y < I.Height())? bsi_split_colors(I.GetPixel(x, y + 1)) : list(0, 0, 0, 0)
		var/list/s = (y > 1)? bsi_split_colors(I.GetPixel(x, y - 1)) : list(0, 0, 0, 0)
		var/list/e = (x < I.Width())? bsi_split_colors(I.GetPixel(x + 1, y)) : list(0, 0, 0, 0)
		var/list/w = (x > 1)? bsi_split_colors(I.GetPixel(x - 1, y)) : list(0, 0, 0, 0)

		var/value = (i == 1)? 16 : max(n[1] - 1, e[1] - 1, s[1] - 1, w[1] - 1)

		if(prob(50))
			value = max(0, value - 1)

		if(prob(50))
			value = max(0, value - 1)

		if(prob(50))
			value = max(0, value - 1)

		if(value <= pixel[1])
			continue

		var/v2 = 256 - ((16 - value) * (16 - value))

		I.DrawBox(rgb(value, v2, pixel[4] - v2, pixel[4]), x, y)

		if(n[4] != 0 && n[1] < value - 1)
			queue[++queue.len] = list(x, y + 1)

		if(s[4] != 0 && s[1] < value - 1)
			queue[++queue.len] = list(x, y - 1)

		if(e[4] != 0 && e[1] < value - 1)
			queue[++queue.len] = list(x + 1, y)

		if(w[4] != 0 && w[1] < value - 1)
			queue[++queue.len] = list(x - 1, y)





/proc/bsi_generate_mask(icon/source, state)
	var/icon/mask = icon(source, state)

	mask.MapColors(
			0, 0, 0, 0,
			0, 0, 0, 0,
			0, 0, 0, 0,
			0, 0, 1, 1,
			0, 0, 0, 0)

	var/hits = 0

	for(var/i = 1, i <= 10, i++)
		var/point1
		var/point2

		if(prob(50))
			if(prob(50))
				point1 = list(rand(1, mask.Width()), mask.Height())
				point2 = list(rand(1, mask.Width()), 1)

			else
				point2 = list(rand(1, mask.Width()), mask.Height())
				point1 = list(rand(1, mask.Width()), 1)

		else
			if(prob(50))
				point1 = list(mask.Width(), rand(1, mask.Height()))
				point2 = list(1,            rand(1, mask.Height()))

			else
				point2 = list(mask.Width(), rand(1, mask.Height()))
				point1 = list(1,            rand(1, mask.Height()))

		var/hit = bsi_cast_ray(mask, point1, point2)

		if(hit == null)
			continue

		hits++

		bsi_spread(mask, hit)

		if(prob(20 + hits * 20))
			break

	if(hits == 0)
		return null

	else
		return mask

/proc/generate_bluespace_icon(icon/source, state)

	var/icon/mask = bsi_generate_mask(source, state)

	if(mask == null)
		return source

	var/icon/unaffected = icon(mask)
	unaffected.MapColors(
			0, 0, 0, 0,
			0, 0, 0, 0,
			0, 0, 0, 1,
			0, 0, 0, 0,
			255, 255, 255, 0)

	var/icon/temp = icon(source, state) //Mask already contains the original alpha values, avoid squaring them
	temp.MapColors(
			1, 0, 0, 0,
			0, 1, 0, 0,
			0, 0, 1, 0,
			0, 0, 0, 0,
			0, 0, 0, 255)

	unaffected.Blend(temp, ICON_MULTIPLY)

	var/icon/bluespaced = icon(mask)
	bluespaced.MapColors(
			0, 0, 0, 0,
			0, 0, 0, 1,
			0, 0, 0, 0,
			0, 0, 0, 0,
			1, 1, 1, 0)

	bluespaced.Blend(icon(source, state), ICON_MULTIPLY)

	var/list/frames = list(
			list(0.000,20),
			list(0.020, 5),
			list(0.050, 4),
			list(0.080, 5),
			list(0.100,10),
			list(0.080, 5),
			list(0.050, 4),
			list(0.020, 5),

			list(0.000,20),
			list(0.020, 5),
			list(0.050, 4),
			list(0.080, 5),
			list(0.100,10),
			list(0.080, 5),
			list(0.050, 4),
			list(0.020, 5),

			list(0.000,20),
			list(0.020, 5),
			list(0.050, 4),
			list(0.080, 5),
			list(0.100,10),
			list(0.080, 5),
			list(0.050, 4),
			list(0.020, 5),
		)

	var/list/colors = list(
			list( 75,  75,  75,   0),
			list( 25,  25,  25,   0),
			list( 75,  75,  75,   0),
			list( 25,  25,  75,   0),
			list( 75,  75, 300,   0),
			list( 25,  25, 300,   0),
			list(255, 255, 255,   0),
			list(  0,   0,   0, 255),
			list(  0,   0,   0,   0),
			list(  0,   0,   0,   0),
		)

	for(var/i = 1, i <= rand(1, 5), i++)
		var/f = rand(1, length(frames))

		if(frames[f][2] > 1)
			frames[f][2]--
			frames.Insert(f, 0)

		frames[f] = list(0.8, 1)

	var/icon/result = generate_color_animation(bluespaced, colors, frames)
	result.Blend(unaffected, ICON_UNDERLAY)

	return result



/atom/verb/test()
	set src in view()
	src.icon = generate_bluespace_icon(src.icon, src.icon_state)

/mob/verb/bluespam()
	for(var/turf/t in view(5))
		var/obj/s = new /obj/square(t)
		s.icon = generate_bluespace_icon(s.icon, s.icon_state)

