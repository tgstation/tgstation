/*
	IconProcs
	by Lummox JR
	Check the icon_procs_readme.dm for how they work.
 */

#define TO_HEX_DIGIT(n) ascii2text((n&15) + ((n&15)<10 ? 48 : 87))

icon
	// Multiply all alpha values by this float
	proc/ChangeOpacity(opacity = 1.0)
		MapColors(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,opacity, 0,0,0,0)

	// Convert to grayscale
	proc/GrayScale()
		MapColors(0.3,0.3,0.3, 0.59,0.59,0.59, 0.11,0.11,0.11, 0,0,0)

	proc/ColorTone(tone)
		GrayScale()

		var/list/TONE = ReadRGB(tone)
		var/gray = round(TONE[1]*0.3 + TONE[2]*0.59 + TONE[3]*0.11, 1)

		var/icon/upper = (255-gray) ? new(src) : null

		if(gray)
			MapColors(255/gray,0,0, 0,255/gray,0, 0,0,255/gray, 0,0,0)
			Blend(tone, ICON_MULTIPLY)
		else SetIntensity(0)
		if(255-gray)
			upper.Blend(rgb(gray,gray,gray), ICON_SUBTRACT)
			upper.MapColors((255-TONE[1])/(255-gray),0,0,0, 0,(255-TONE[2])/(255-gray),0,0, 0,0,(255-TONE[3])/(255-gray),0, 0,0,0,0, 0,0,0,1)
			Blend(upper, ICON_ADD)

	// Take the minimum color of two icons; combine transparency as if blending with ICON_ADD
	proc/MinColors(icon)
		var/icon/I = new(src)
		I.Opaque()
		I.Blend(icon, ICON_SUBTRACT)
		Blend(I, ICON_SUBTRACT)

	// Take the maximum color of two icons; combine opacity as if blending with ICON_OR
	proc/MaxColors(icon)
		var/icon/I
		if(isicon(icon))
			I = new(icon)
		else
			// solid color
			I = new(src)
			I.Blend("#000000", ICON_OVERLAY)
			I.SwapColor("#000000", null)
			I.Blend(icon, ICON_OVERLAY)
		var/icon/J = new(src)
		J.Opaque()
		I.Blend(J, ICON_SUBTRACT)
		Blend(I, ICON_OR)

	// make this icon fully opaque--transparent pixels become black
	proc/Opaque(background = "#000000")
		SwapColor(null, background)
		MapColors(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,0, 0,0,0,1)

	// Change a grayscale icon into a white icon where the original color becomes the alpha
	// I.e., black -> transparent, gray -> translucent white, white -> solid white
	proc/BecomeAlphaMask()
		SwapColor(null, "#000000ff")	// don't let transparent become gray
		MapColors(0,0,0,0.3, 0,0,0,0.59, 0,0,0,0.11, 0,0,0,0, 1,1,1,0)

	proc/UseAlphaMask(mask)
		Opaque()
		AddAlphaMask(mask)

	proc/AddAlphaMask(mask)
		var/icon/M = new(mask)
		M.Blend("#ffffff", ICON_SUBTRACT)
		// apply mask
		Blend(M, ICON_ADD)

/*
	HSV format is represented as "#hhhssvv" or "#hhhssvvaa"

	Hue ranges from 0 to 0x5ff (1535)

		0x000 = red
		0x100 = yellow
		0x200 = green
		0x300 = cyan
		0x400 = blue
		0x500 = magenta

	Saturation is from 0 to 0xff (255)

		More saturation = more color
		Less saturation = more gray

	Value ranges from 0 to 0xff (255)

		Higher value means brighter color
 */

proc/ReadRGB(rgb)
	if(!rgb) return

	// interpret the HSV or HSVA value
	var/i=1,start=1
	if(text2ascii(rgb) == 35) ++start // skip opening #
	var/ch,which=0,r=0,g=0,b=0,alpha=0,usealpha
	var/digits=0
	for(i=start, i<=length(rgb), ++i)
		ch = text2ascii(rgb, i)
		if(ch < 48 || (ch > 57 && ch < 65) || (ch > 70 && ch < 97) || ch > 102) break
		++digits
		if(digits == 8) break

	var/single = digits < 6
	if(digits != 3 && digits != 4 && digits != 6 && digits != 8) return
	if(digits == 4 || digits == 8) usealpha = 1
	for(i=start, digits>0, ++i)
		ch = text2ascii(rgb, i)
		if(ch >= 48 && ch <= 57) ch -= 48
		else if(ch >= 65 && ch <= 70) ch -= 55
		else if(ch >= 97 && ch <= 102) ch -= 87
		else break
		--digits
		switch(which)
			if(0)
				r = (r << 4) | ch
				if(single)
					r |= r << 4
					++which
				else if(!(digits & 1)) ++which
			if(1)
				g = (g << 4) | ch
				if(single)
					g |= g << 4
					++which
				else if(!(digits & 1)) ++which
			if(2)
				b = (b << 4) | ch
				if(single)
					b |= b << 4
					++which
				else if(!(digits & 1)) ++which
			if(3)
				alpha = (alpha << 4) | ch
				if(single) alpha |= alpha << 4

	. = list(r, g, b)
	if(usealpha) . += alpha

proc/ReadHSV(hsv)
	if(!hsv) return

	// interpret the HSV or HSVA value
	var/i=1,start=1
	if(text2ascii(hsv) == 35) ++start // skip opening #
	var/ch,which=0,hue=0,sat=0,val=0,alpha=0,usealpha
	var/digits=0
	for(i=start, i<=length(hsv), ++i)
		ch = text2ascii(hsv, i)
		if(ch < 48 || (ch > 57 && ch < 65) || (ch > 70 && ch < 97) || ch > 102) break
		++digits
		if(digits == 9) break
	if(digits > 7) usealpha = 1
	if(digits <= 4) ++which
	if(digits <= 2) ++which
	for(i=start, digits>0, ++i)
		ch = text2ascii(hsv, i)
		if(ch >= 48 && ch <= 57) ch -= 48
		else if(ch >= 65 && ch <= 70) ch -= 55
		else if(ch >= 97 && ch <= 102) ch -= 87
		else break
		--digits
		switch(which)
			if(0)
				hue = (hue << 4) | ch
				if(digits == (usealpha ? 6 : 4)) ++which
			if(1)
				sat = (sat << 4) | ch
				if(digits == (usealpha ? 4 : 2)) ++which
			if(2)
				val = (val << 4) | ch
				if(digits == (usealpha ? 2 : 0)) ++which
			if(3)
				alpha = (alpha << 4) | ch

	. = list(hue, sat, val)
	if(usealpha) . += alpha

proc/HSVtoRGB(hsv)
	if(!hsv) return "#000000"
	var/list/HSV = ReadHSV(hsv)
	if(!HSV) return "#000000"

	var/hue = HSV[1]
	var/sat = HSV[2]
	var/val = HSV[3]

	// Compress hue into easier-to-manage range
	hue -= hue >> 8
	if(hue >= 0x5fa) hue -= 0x5fa

	var/hi,mid,lo,r,g,b
	hi = val
	lo = round((255 - sat) * val / 255, 1)
	mid = lo + round(abs(round(hue, 510) - hue) * (hi - lo) / 255, 1)
	if(hue >= 765)
		if(hue >= 1275)      {r=hi;  g=lo;  b=mid}
		else if(hue >= 1020) {r=mid; g=lo;  b=hi }
		else                 {r=lo;  g=mid; b=hi }
	else
		if(hue >= 510)       {r=lo;  g=hi;  b=mid}
		else if(hue >= 255)  {r=mid; g=hi;  b=lo }
		else                 {r=hi;  g=mid; b=lo }

	return (HSV.len > 3) ? rgb(r,g,b,HSV[4]) : rgb(r,g,b)

proc/RGBtoHSV(rgb)
	if(!rgb) return "#0000000"
	var/list/RGB = ReadRGB(rgb)
	if(!RGB) return "#0000000"

	var/r = RGB[1]
	var/g = RGB[2]
	var/b = RGB[3]
	var/hi = max(r,g,b)
	var/lo = min(r,g,b)

	var/val = hi
	var/sat = hi ? round((hi-lo) * 255 / hi, 1) : 0
	var/hue = 0

	if(sat)
		var/dir
		var/mid
		if(hi == r)
			if(lo == b) {hue=0; dir=1; mid=g}
			else {hue=1535; dir=-1; mid=b}
		else if(hi == g)
			if(lo == r) {hue=512; dir=1; mid=b}
			else {hue=511; dir=-1; mid=r}
		else if(hi == b)
			if(lo == g) {hue=1024; dir=1; mid=r}
			else {hue=1023; dir=-1; mid=g}
		hue += dir * round((mid-lo) * 255 / (hi-lo), 1)

	return hsv(hue, sat, val, (RGB.len>3 ? RGB[4] : null))

proc/hsv(hue, sat, val, alpha)
	if(hue < 0 || hue >= 1536) hue %= 1536
	if(hue < 0) hue += 1536
	if((hue & 0xFF) == 0xFF)
		++hue
		if(hue >= 1536) hue = 0
	if(sat < 0) sat = 0
	if(sat > 255) sat = 255
	if(val < 0) val = 0
	if(val > 255) val = 255
	. = "#"
	. += TO_HEX_DIGIT(hue >> 8)
	. += TO_HEX_DIGIT(hue >> 4)
	. += TO_HEX_DIGIT(hue)
	. += TO_HEX_DIGIT(sat >> 4)
	. += TO_HEX_DIGIT(sat)
	. += TO_HEX_DIGIT(val >> 4)
	. += TO_HEX_DIGIT(val)
	if(!isnull(alpha))
		if(alpha < 0) alpha = 0
		if(alpha > 255) alpha = 255
		. += TO_HEX_DIGIT(alpha >> 4)
		. += TO_HEX_DIGIT(alpha)

/*
	Smooth blend between HSV colors

	amount=0 is the first color
	amount=1 is the second color
	amount=0.5 is directly between the two colors

	amount<0 or amount>1 are allowed
 */
proc/BlendHSV(hsv1, hsv2, amount)
	var/list/HSV1 = ReadHSV(hsv1)
	var/list/HSV2 = ReadHSV(hsv2)

	// add missing alpha if needed
	if(HSV1.len < HSV2.len) HSV1 += 255
	else if(HSV2.len < HSV1.len) HSV2 += 255
	var/usealpha = HSV1.len > 3

	// normalize hsv values in case anything is screwy
	if(HSV1[1] > 1536) HSV1[1] %= 1536
	if(HSV2[1] > 1536) HSV2[1] %= 1536
	if(HSV1[1] < 0) HSV1[1] += 1536
	if(HSV2[1] < 0) HSV2[1] += 1536
	if(!HSV1[3]) {HSV1[1] = 0; HSV1[2] = 0}
	if(!HSV2[3]) {HSV2[1] = 0; HSV2[2] = 0}

	// no value for one color means don't change saturation
	if(!HSV1[3]) HSV1[2] = HSV2[2]
	if(!HSV2[3]) HSV2[2] = HSV1[2]
	// no saturation for one color means don't change hues
	if(!HSV1[2]) HSV1[1] = HSV2[1]
	if(!HSV2[2]) HSV2[1] = HSV1[1]

	// Compress hues into easier-to-manage range
	HSV1[1] -= HSV1[1] >> 8
	HSV2[1] -= HSV2[1] >> 8

	var/hue_diff = HSV2[1] - HSV1[1]
	if(hue_diff > 765) hue_diff -= 1530
	else if(hue_diff <= -765) hue_diff += 1530

	var/hue = round(HSV1[1] + hue_diff * amount, 1)
	var/sat = round(HSV1[2] + (HSV2[2] - HSV1[2]) * amount, 1)
	var/val = round(HSV1[3] + (HSV2[3] - HSV1[3]) * amount, 1)
	var/alpha = usealpha ? round(HSV1[4] + (HSV2[4] - HSV1[4]) * amount, 1) : null

	// normalize hue
	if(hue < 0 || hue >= 1530) hue %= 1530
	if(hue < 0) hue += 1530
	// decompress hue
	hue += round(hue / 255)

	return hsv(hue, sat, val, alpha)

/*
	Smooth blend between RGB colors

	amount=0 is the first color
	amount=1 is the second color
	amount=0.5 is directly between the two colors

	amount<0 or amount>1 are allowed
 */
proc/BlendRGB(rgb1, rgb2, amount)
	var/list/RGB1 = ReadRGB(rgb1)
	var/list/RGB2 = ReadRGB(rgb2)

	// add missing alpha if needed
	if(RGB1.len < RGB2.len) RGB1 += 255
	else if(RGB2.len < RGB1.len) RGB2 += 255
	var/usealpha = RGB1.len > 3

	var/r = round(RGB1[1] + (RGB2[1] - RGB1[1]) * amount, 1)
	var/g = round(RGB1[2] + (RGB2[2] - RGB1[2]) * amount, 1)
	var/b = round(RGB1[3] + (RGB2[3] - RGB1[3]) * amount, 1)
	var/alpha = usealpha ? round(RGB1[4] + (RGB2[4] - RGB1[4]) * amount, 1) : null

	return isnull(alpha) ? rgb(r, g, b) : rgb(r, g, b, alpha)

proc/BlendRGBasHSV(rgb1, rgb2, amount)
	return HSVtoRGB(RGBtoHSV(rgb1), RGBtoHSV(rgb2), amount)

proc/HueToAngle(hue)
	// normalize hsv in case anything is screwy
	if(hue < 0 || hue >= 1536) hue %= 1536
	if(hue < 0) hue += 1536
	// Compress hue into easier-to-manage range
	hue -= hue >> 8
	return hue / (1530/360)

proc/AngleToHue(angle)
	// normalize hsv in case anything is screwy
	if(angle < 0 || angle >= 360) angle -= 360 * round(angle / 360)
	var/hue = angle * (1530/360)
	// Decompress hue
	hue += round(hue / 255)
	return hue


// positive angle rotates forward through red->green->blue
proc/RotateHue(hsv, angle)
	var/list/HSV = ReadHSV(hsv)

	// normalize hsv in case anything is screwy
	if(HSV[1] >= 1536) HSV[1] %= 1536
	if(HSV[1] < 0) HSV[1] += 1536

	// Compress hue into easier-to-manage range
	HSV[1] -= HSV[1] >> 8

	if(angle < 0 || angle >= 360) angle -= 360 * round(angle / 360)
	HSV[1] = round(HSV[1] + angle * (1530/360), 1)

	// normalize hue
	if(HSV[1] < 0 || HSV[1] >= 1530) HSV[1] %= 1530
	if(HSV[1] < 0) HSV[1] += 1530
	// decompress hue
	HSV[1] += round(HSV[1] / 255)

	return hsv(HSV[1], HSV[2], HSV[3], (HSV.len > 3 ? HSV[4] : null))

// Convert an rgb color to grayscale
proc/GrayScale(rgb)
	var/list/RGB = ReadRGB(rgb)
	var/gray = RGB[1]*0.3 + RGB[2]*0.59 + RGB[3]*0.11
	return (RGB.len > 3) ? rgb(gray, gray, gray, RGB[4]) : rgb(gray, gray, gray)

// Change grayscale color to black->tone->white range
proc/ColorTone(rgb, tone)
	var/list/RGB = ReadRGB(rgb)
	var/list/TONE = ReadRGB(tone)

	var/gray = RGB[1]*0.3 + RGB[2]*0.59 + RGB[3]*0.11
	var/tone_gray = TONE[1]*0.3 + TONE[2]*0.59 + TONE[3]*0.11

	if(gray <= tone_gray) return BlendRGB("#000000", tone, gray/(tone_gray || 1))
	else return BlendRGB(tone, "#ffffff", (gray-tone_gray)/((255-tone_gray) || 1))


/*
Get flat icon by DarkCampainger. As it says on the tin, will return an icon with all the overlays
as a single icon. Useful for when you want to manipulate an icon via the above as overlays are not normally included.
The _flatIcons list is a cache for generated icon files.
*/

// Associative list of [md5 values = Icon] for determining if the icon already exists
var/list/_flatIcons = list()

proc
	getFlatIcon(atom/A, dir, cache=1) // 1 = use cache, 2 = override cache, 0 = ignore cache
		// Layers will be a sorted list of icons/overlays, based on the order in which they are displayed
		var/list/layers = list()
		var/hash = "" // Hash of overlay combination

		// Add the atom's icon itself
		if(A.icon)
			// Make a copy without pixel_x/y settings
			var/image/copy = image(icon=A.icon,icon_state=A.icon_state,layer=A.layer,dir=A.dir)
			layers[copy] = A.layer

		// dir defaults to A's dir
		if(!dir) dir = A.dir

		// Loop through the underlays, then overlays, sorting them into the layers list
		var
			list/process = A.underlays // Current list being processed
			pSet=0 // Which list is being processed: 0 = underlays, 1 = overlays
			curIndex=1 // index of 'current' in list being processed
			current // Current overlay being sorted
			currentLayer // Calculated layer that overlay appears on (special case for FLOAT_LAYER)
			compare // The overlay 'add' is being compared against
			cmpIndex // The index in the layers list of 'compare'
		while(TRUE)
			if(curIndex<=process.len)
				current = process[curIndex]

				currentLayer = current:layer
				if(currentLayer<0) // Special case for FLY_LAYER
					if(currentLayer <= -1000) return 0
					if(pSet == 0) // Underlay
						currentLayer = A.layer+currentLayer/1000
					else // Overlay
						currentLayer = A.layer+(1000+currentLayer)/1000

				// Sort add into layers list
				for(cmpIndex=1,cmpIndex<=layers.len,cmpIndex++)
					compare = layers[cmpIndex]
					if(currentLayer < layers[compare]) // Associated value is the calculated layer
						layers.Insert(cmpIndex,current)
						layers[current] = currentLayer
						break
				if(cmpIndex>layers.len) // Reached end of list without inserting
					layers[current]=currentLayer // Place at end

				curIndex++

			if(curIndex>process.len)
				if(pSet == 0) // Switch to overlays
					curIndex = 1
					pSet = 1
					process = A.overlays
				else // All done
					break

		if(cache!=0) // If cache is NOT disabled
			// Create a hash value to represent this specific flattened icon
			for(var/I in layers)
				hash += "\ref[I:icon],[I:icon_state],[I:dir ? I:dir : dir],[I:pixel_x],[I:pixel_y];_;"
			hash=md5(hash)

			if(cache!=2) // If NOT overriding cache
				// Check if the icon has already been generated
				for(var/h in _flatIcons)
					if(h == hash)
						// Icon already exists, just return that one
						return _flatIcons[h]

		var
			// We start with a blank canvas, otherwise some icon procs crash silently
			icon/flat = icon('icons/effects/effects.dmi', "icon_state"="nothing") // Final flattened icon
			icon/add // Icon of overlay being added

			// Current dimensions of flattened icon
			flatX1=1;flatX2=flat.Width();flatY1=1;flatY2=flat.Height()
			// Dimensions of overlay being added
			addX1;addX2;addY1;addY2

		for(var/I in layers)

			if(I:icon)
				if(I:icon_state)
					// Has icon and state set
					add = icon(I:icon, I:icon_state)
				else
					if(A.icon_state in icon_states(I:icon))
						// Inherits icon_state from atom
						add = icon(I:icon, A.icon_state)
					else
						// Uses default state ("")
						add = icon(I:icon)
			else if(I:icon_state)
				// Inherits icon from atom
				add = icon(A.icon, I:icon_state)
			else
				// Unknown
				continue

			// Find the new dimensions of the flat icon to fit the added overlay
			addX1 = min(flatX1, I:pixel_x+1)
			addX2 = max(flatX2, I:pixel_x+add.Width())
			addY1 = min(flatY1, I:pixel_y+1)
			addY2 = max(flatY2, I:pixel_y+add.Height())

			if(addX1!=flatX1 || addX2!=flatX2 || addY1!=flatY1 || addY2!=flatY2)
				// Resize the flattened icon so the new icon fits
				flat.Crop(addX1-flatX1+1, addY1-flatY1+1, addX2-flatX1+1, addY2-flatY1+1)
				flatX1=addX1;flatX2=addX2
				flatY1=addY1;flatY2=addY2

			// Blend the overlay into the flattened icon
			flat.Blend(add,ICON_OVERLAY,I:pixel_x+2-flatX1,I:pixel_y+2-flatY1)

		if(cache!=0) // If cache is NOT disabled
			// Cache the generated icon in our list so we don't have to regenerate it
			_flatIcons[hash] = flat

		return flat

	getIconMask(atom/A)//By yours truly. Creates a dynamic mask for a mob/whatever. /N
		var/icon/alpha_mask = new(A.icon,A.icon_state)//So we want the default icon and icon state of A.
		for(var/I in A.overlays)//For every image in overlays. var/image/I will not work, don't try it.
			if(I:layer>A.layer)	continue//If layer is greater than what we need, skip it.
			var/icon/image_overlay = new(I:icon,I:icon_state)//Blend only works with icon objects.
			//Also, icons cannot directly set icon_state. Slower than changing variables but whatever.
			alpha_mask.Blend(image_overlay,ICON_OR)//OR so they are lumped together in a nice overlay.
		return alpha_mask//And now return the mask.

/mob/proc/AddCamoOverlay(atom/A)//A is the atom which we are using as the overlay.
	var/icon/opacity_icon = new(A.icon, A.icon_state)//Don't really care for overlays/underlays.
	//Now we need to culculate overlays+underlays and add them together to form an image for a mask.
	//var/icon/alpha_mask = getFlatIcon(src)//Accurate but SLOW. Not designed for running each tick. Could have other uses I guess.
	var/icon/alpha_mask = getIconMask(src)//Which is why I created that proc. Also a little slow since it's blending a bunch of icons together but good enough.
	opacity_icon.AddAlphaMask(alpha_mask)//Likely the main source of lag for this proc. Probably not designed to run each tick.
	opacity_icon.ChangeOpacity(0.4)//Front end for MapColors so it's fast. 0.5 means half opacity and looks the best in my opinion.
	for(var/i=0,i<5,i++)//And now we add it as overlays. It's faster than creating an icon and then merging it.
		var/image/I = image("icon" = opacity_icon, "icon_state" = A.icon_state, "layer" = layer+0.8)//So it's above other stuff but below weapons and the like.
		switch(i)//Now to determine offset so the result is somewhat blurred.
			if(1)
				I.pixel_x -= 1
			if(2)
				I.pixel_x += 1
			if(3)
				I.pixel_y -= 1
			if(4)
				I.pixel_y += 1
		overlays += I//And finally add the overlay.

/proc/getHologramIcon(icon/A, safety=1)//If safety is on, a new icon is not created.
	var/icon/flat_icon = safety ? A : new(A)//Has to be a new icon to not constantly change the same icon.
	flat_icon.ColorTone(rgb(125,180,225))//Let's make it bluish.
	flat_icon.ChangeOpacity(0.5)//Make it half transparent.
	var/icon/alpha_mask = new('icons/effects/effects.dmi', "scanline")//Scanline effect.
	flat_icon.AddAlphaMask(alpha_mask)//Finally, let's mix in a distortion effect.
	return flat_icon

//For photo camera.
/proc/build_composite_icon(atom/A)
	var/icon/composite = icon(A.icon, A.icon_state, A.dir, 1)
	for(var/O in A.overlays)
		var/image/I = O
		composite.Blend(icon(I.icon, I.icon_state, I.dir, 1), ICON_OVERLAY)
	return composite