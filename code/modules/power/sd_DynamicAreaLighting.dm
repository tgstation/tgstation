// ROBUST LIGHTING
// Made by Tobba, submitted to #coderbus vultures
// CREDITS TO WHOEVER THE FUCK WROTE THAT PEICE OF SHIT THAT IS SD LIGHITING THAT I RIPPED APART AND MADE ACTUALLY WORK

var
	sd_light_layer = 10		// graphics layer for light effect
	sd_top_luminosity = 0
	list
		sd_FastRoot = list()
		sd_OpacityUpdates = list()
		sd_ToUpdate = list()

proc
	sd_Update()
		var/list/blankList = list()
		for (var/atom/Affected in sd_OpacityUpdates)
			var/oldOpacity = sd_OpacityUpdates[Affected]
			var/newOpacity = Affected.opacity
			Affected.opacity = oldOpacity
			for (var/atom/A in view(sd_top_luminosity, Affected))
				if (!isarea(A) && A.luminosity > 0 && !blankList[A])
					blankList[A] = 1
					A.sd_StripLum()
			Affected.opacity = newOpacity
		for (var/atom/Affected in blankList)
			Affected.sd_ApplyLum()
		for (var/i = 1; i <= sd_ToUpdate.len; i++)
			var/turf/Affected = sd_ToUpdate[i]
			if (!istype(Affected))
				continue
			Affected.sd_LumUpdate()

		sd_ToUpdate.len = 0
		sd_OpacityUpdates.len = 0

atom
	New()
		..()

	Del()
		// if this is not an area and is luminous
		if(!isarea(src) && luminosity > 0)
			sd_StripLum(,,1)
		..()

	var
		sd_ColorRed = 0.9
		sd_ColorGreen = 0.9
		sd_ColorBlue = 0.9

	proc
		sd_ApplyLum(list/V = view(luminosity, src), center = src, updateMode = 0)
			if (isarea(src))
				return
			if(src.luminosity > sd_top_luminosity)
				sd_top_luminosity = src.luminosity
			var/list/affected = list()
			var
				d = max(sd_ColorRed, sd_ColorGreen, sd_ColorBlue)
				r = sd_ColorRed / d
				g = sd_ColorGreen / d
				b = sd_ColorBlue / d
			for(var/turf/T in V)
				var/falloff = 0
				if (luminosity > 0)
					falloff = sd_FalloffAmount(T)

					if (falloff > luminosity)
						continue;
					falloff = (luminosity - falloff) / luminosity
				T.sd_LightsAlpha[src] = falloff * d
				T.sd_LightsRed[src] = r
				T.sd_LightsGreen[src] = g
				T.sd_LightsBlue[src] = b
				if (updateMode == 0)
					sd_ToUpdate[T] = 1
				else
					T.sd_LumUpdate()
				affected += T
			return affected

		sd_StripLum(list/V = view(luminosity,src), center = src, updateMode = 0)
			if (isarea(src))
				return
			var/list/affected = list()
			for(var/turf/T in V)
				T.sd_LightsAlpha -= src
				T.sd_LightsRed -= src
				T.sd_LightsGreen -= src
				T.sd_LightsBlue -= src
				if (updateMode == 0)
					sd_ToUpdate[T] = 1
				else
					T.sd_LumUpdate()
				affected += T
			return affected

		sd_FalloffAmount(var/atom/ref) // Borrowed from Ultralight
			var/x = (ref.x - src.x)
			var/y = (ref.y - src.y)
			if ((x*x + y*y + 1) > sd_FastRoot.len)
				for(var/i = sd_FastRoot.len, i <= x*x+y*y, i++)
					sd_FastRoot += sqrt(x*x+y*y) - 0.5
			return round(sd_FastRoot[x*x + y*y + 1], 1)

		sd_ApplyLocalLum(list/affected = view(sd_top_luminosity,src))
			// Reapplies the lighting effect of all atoms in affected.
			for(var/atom/A in affected)
				if(A.luminosity) A.sd_ApplyLum()

		sd_StripLocalLum()
			var/list/affected = list()
			for(var/atom/A in view(sd_top_luminosity,src))
				if(A.luminosity)
					A.sd_StripLum()
					affected += A

			return affected

		sd_SetLuminosity(new_luminosity as num)
			if (luminosity == new_luminosity)
				return

			if(luminosity > 0)
				sd_StripLum()
			luminosity = new_luminosity
			if(luminosity > 0)
				sd_ApplyLum()

		sd_SetColor(r as num, g as num, b as num)
			sd_StripLum()
			sd_ColorRed = r
			sd_ColorGreen = g
			sd_ColorBlue = b
			sd_ApplyLum()

		sd_SetOpacity(new_opacity as num)
			if (opacity != new_opacity)
				sd_OpacityUpdates[src] = opacity
				opacity = new_opacity
			sd_Update()

		sd_NewOpacity(var/new_opacity)
			sd_SetOpacity(new_opacity)

turf
	var
		tmp
			list
				sd_LightsAlpha = list()
				sd_LightsRed = list()
				sd_LightsGreen = list()
				sd_LightsBlue = list()
			sd_LevelRed = 0
			sd_LevelGreen = 0
			sd_LevelBlue = 0
			sd_lumcount = 0
	proc
		sd_LumReset()
			var/list/affected = sd_StripLocalLum()
			sd_ApplyLocalLum(affected)

		sd_LumUpdate()
			set background = 1
			var/area/Loc = loc
			if(!istype(Loc) || !Loc.sd_lighting) return

			var/light_r = 0
			var/light_g = 0
			var/light_b = 0

			sd_LevelRed = 0
			sd_LevelGreen = 0
			sd_LevelBlue = 0

			var/alpha = 0

			for (var/i = 1; i <= sd_LightsAlpha.len; i++)
				var/a = sd_LightsAlpha[sd_LightsAlpha[i]]
				var/r = sd_LightsRed[sd_LightsRed[i]]
				var/g = sd_LightsGreen[sd_LightsGreen[i]]
				var/b = sd_LightsBlue[sd_LightsBlue[i]]
				alpha = 1 - ((1 - a) * (1 - alpha))
				sd_LevelRed += r * a
				sd_LevelGreen += g * a
				sd_LevelBlue += b * a

			if (src.density > 0)
				var/a = (sd_LevelRed + sd_LevelGreen + sd_LevelBlue)/3
				sd_LevelRed = a
				sd_LevelGreen = a
				sd_LevelBlue = a

			var/d = max(sd_LevelRed, sd_LevelGreen, sd_LevelBlue)
			if (d > 0)
				sd_LevelRed /= d
				sd_LevelGreen /= d
				sd_LevelBlue /= d
			else
				sd_LevelRed = 1
				sd_LevelGreen = 1
				sd_LevelBlue = 1
			sd_LevelRed *= alpha
			sd_LevelGreen *= alpha
			sd_LevelBlue *= alpha

			light_r = round(sd_LevelRed * 7)
			light_g = round(sd_LevelGreen * 7)
			light_b = round(sd_LevelBlue * 7)

			sd_lumcount = light_r + light_g + light_b

			var/ltag = copytext(Loc.tag,1,findtext(Loc.tag,"sd_L")) + "sd_L[light_r]-[light_g]-[light_b]"

			if (Loc.tag != ltag)
				var/area/A = locate(ltag)
				if(!A)
					A = new Loc.type()
					A.tag = ltag

					// replicate vars
					for(var/V in Loc.vars-"contents")
						if(issaved(Loc.vars[V])) A.vars[V] = Loc.vars[V]

					A.tag = ltag
					A.sd_LightLevel(light_r, light_g, light_b)

				A.contents += src

atom/movable/Move()
	var/turf/oldloc = loc
	var/list/oldview
	if(luminosity > 0)		// if atom is luminous
		if(isturf(loc))
			oldview = view(luminosity,loc)
		else
			oldview = list()

	. = ..()

	if(. && luminosity > 0)
		if(istype(oldloc))
			var/list/Affected1 = sd_StripLum(oldview,oldloc, 2)
			var/list/Affected2
			if (!loc.opacity)
				Affected2 = sd_ApplyLum(,,2)
			else
				Affected2 = list()
			var/list/Affected3 = list()
			for (var/turf/T in Affected1)
				Affected3[T] = 1
			for (var/turf/T in Affected2)
				Affected3[T] = 1
			for (var/i = 1; i <= Affected3.len; i++)
				var/turf/T = Affected3[i]
				T.sd_LumUpdate()


area
	var
		sd_lighting = 1

		sd_LevelRed = 0	// the current light level of the area
		sd_LevelGreen = 0
		sd_LevelBlue = 0
		sd_darkimage	// tracks the darkness image of the area for easy removal


	proc
		sd_LightLevel(rlevel = sd_LevelRed as num, glevel = sd_LevelGreen as num, blevel = sd_LevelBlue as num, keep = 1)
			if (!src) return
			overlays -= sd_darkimage

			if(keep)
				sd_LevelRed = rlevel
				sd_LevelGreen = glevel
				sd_LevelBlue = blevel

			if(rlevel > 0 || glevel > 0 || blevel > 0)
				luminosity = 1
			else
				luminosity = 0

			sd_darkimage = image('ULIcons.dmi',,"[rlevel]-[glevel]-[blevel]",sd_light_layer)
			overlays += sd_darkimage

	proc/sd_New(sd_created)
		if(!tag) tag = "[type]"
		spawn(1)	// wait a tick
			if(sd_lighting)
				if(!sd_created)
					sd_LightLevel()

	Del()
		..()
		related -= src

mob
	sd_ApplyLum(list/V, center = src, updateMode)
		if(!V)
			if(isturf(loc))
				V = view(luminosity,loc)
			else
				V = view(luminosity,src)
		. = ..(V, center, updateMode)

	sd_StripLum(list/V, center = src, updateMode)
		if(!V)
			if(isturf(loc))
				V = view(luminosity,loc)
			else
				V = view(luminosity,src)
		. = ..(V, center, updateMode)

	sd_ApplyLocalLum(list/affected)
		if(!affected)
			if(isturf(loc))
				affected = view(sd_top_luminosity,loc)
			else
				affected = view(sd_top_luminosity,src)
		. = ..(affected)