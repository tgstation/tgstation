//UltraLight system, by Sukasa


#define UL_I_FALLOFF_SQUARE 0
#define UL_I_FALLOFF_ROUND 1

#define UL_I_LIT 0
#define UL_I_EXTINGUISHED 1
#define UL_I_ONZERO 2

var
	ul_LightingEnabled = 1
	ul_LightingResolution = 1
	ul_LightingResolutionSqrt = sqrt(ul_LightingResolution)
	ul_Steps = 7
	ul_FalloffStyle = UL_I_FALLOFF_ROUND // Sets the lighting falloff to be either squared or circular.
	ul_TopLuminosity = 0
	ul_Layer = 10
	ul_SuppressLightLevelChanges = 0

	list/ul_FastRoot = list(0, 1, 1, 1, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5,
							5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
							7, 7)


proc/ul_Clamp(var/Value)
	return min(max(Value, 0), ul_Steps)

atom/var/LuminosityRed = 0
atom/var/LuminosityGreen = 0
atom/var/LuminosityBlue = 0

atom/var/ul_Extinguished = UL_I_ONZERO

atom/proc/ul_SetLuminosity(var/Red, var/Green = Red, var/Blue = Red)

	if(LuminosityRed == Red && LuminosityGreen == Green && LuminosityBlue == Blue)
		return //No point doing all that work if it won't have any effect anyways...

	if (ul_Extinguished == UL_I_EXTINGUISHED)
		LuminosityRed = Red
		LuminosityGreen = Green
		LuminosityBlue = Blue

		return

	if (ul_IsLuminous())
		ul_Extinguish()

	LuminosityRed = Red
	LuminosityGreen = Green
	LuminosityBlue = Blue

	ul_Extinguished = UL_I_ONZERO

	if (ul_IsLuminous())
		ul_Illuminate()

	return

atom/proc/ul_Illuminate()
	if (ul_Extinguished == UL_I_LIT)
		return

	ul_Extinguished = UL_I_LIT

	ul_UpdateTopLuminosity()
	luminosity = ul_Luminosity()

	for(var/turf/Affected in view(luminosity, src))
		var/Falloff = src.ul_FalloffAmount(Affected)

		var/DeltaRed = LuminosityRed - Falloff
		var/DeltaGreen = LuminosityGreen - Falloff
		var/DeltaBlue = LuminosityBlue - Falloff

		if(DeltaRed > 0 || DeltaGreen > 0 || DeltaBlue > 0)

			if(DeltaRed > 0)
				if(!Affected.MaxRed)
					Affected.MaxRed = list()
				if("[DeltaRed]" in Affected.MaxRed)
					Affected.MaxRed["[DeltaRed]"]++
				else
					Affected.MaxRed["[DeltaRed]"] = 1

			if(DeltaGreen > 0)
				if(!Affected.MaxGreen)
					Affected.MaxGreen = list()
				if("[DeltaGreen]" in Affected.MaxGreen)
					Affected.MaxGreen["[DeltaGreen]"]++
				else
					Affected.MaxGreen["[DeltaGreen]"] = 1

			if(DeltaBlue > 0)
				if(!Affected.MaxBlue)
					Affected.MaxBlue = list()
				if("[DeltaBlue]" in Affected.MaxBlue)
					Affected.MaxBlue["[DeltaBlue]"]++
				else
					Affected.MaxBlue["[DeltaBlue]"] = 1

			Affected.ul_UpdateLight()

			if (ul_SuppressLightLevelChanges == 0)
				Affected.ul_LightLevelChanged()

				for(var/atom/AffectedAtom in Affected)
					AffectedAtom.ul_LightLevelChanged()
	return

atom/proc/ul_Extinguish()

	if (ul_Extinguished != UL_I_LIT)
		return

	ul_Extinguished = UL_I_EXTINGUISHED

	for(var/turf/Affected in view(ul_Luminosity(), src))

		var/Falloff = ul_FalloffAmount(Affected)

		var/DeltaRed = LuminosityRed - Falloff
		var/DeltaGreen = LuminosityGreen - Falloff
		var/DeltaBlue = LuminosityBlue - Falloff

		if(DeltaRed > 0 || DeltaGreen > 0 || DeltaBlue > 0)

			if(DeltaRed > 0)
				if(Affected.MaxRed)
					if(Affected.MaxRed["[DeltaRed]"] > 1)
						Affected.MaxRed["[DeltaRed]"]--
					else
						Affected.MaxRed.Remove("[DeltaRed]")
					if(!Affected.MaxRed.len)
						del Affected.MaxRed

			if(DeltaGreen > 0)
				if(Affected.MaxGreen)
					if(Affected.MaxGreen["[DeltaGreen]"] > 1)
						Affected.MaxGreen["[DeltaGreen]"]--
					else
						Affected.MaxGreen.Remove("[DeltaGreen]")
					if(!Affected.MaxGreen.len)
						del Affected.MaxGreen

			if(DeltaBlue > 0)
				if(Affected.MaxBlue)
					if(Affected.MaxBlue["[DeltaBlue]"] > 1)
						Affected.MaxBlue["[DeltaBlue]"]--
					else
						Affected.MaxBlue.Remove("[DeltaBlue]")
					if(!Affected.MaxBlue.len)
						del Affected.MaxBlue

			Affected.ul_UpdateLight()

			if (ul_SuppressLightLevelChanges == 0)
				Affected.ul_LightLevelChanged()

				for(var/atom/AffectedAtom in Affected)
					AffectedAtom.ul_LightLevelChanged()

	luminosity = 0

	return


/*
 Calculates the correct lighting falloff value (used to calculate what brightness to set the turf to) to use,
  when called on a luminous atom and passed an atom in the turf to be lit.

 Supports multiple configurations, BS12 uses the circular falloff setting. This setting uses an array lookup
  to avoid the cost of the square root function.
*/
atom/proc/ul_FalloffAmount(var/atom/ref)
	if (ul_FalloffStyle == UL_I_FALLOFF_ROUND)
		var/x = (ref.x - src.x)
		var/y = (ref.y - src.y)
		if(ul_LightingResolution != 1)
			if (round((x*x + y*y)*ul_LightingResolutionSqrt,1) > ul_FastRoot.len)
				for(var/i = ul_FastRoot.len, i <= round(x*x+y*y*ul_LightingResolutionSqrt,1), i++)
					ul_FastRoot += round(sqrt(i))
			return ul_FastRoot[round((x*x + y*y)*ul_LightingResolutionSqrt, 1) + 1]/ul_LightingResolution

		else
			if ((x*x + y*y) > ul_FastRoot.len)
				for(var/i = ul_FastRoot.len, i <= x*x+y*y, i++)
					ul_FastRoot += round(sqrt(i))
			return ul_FastRoot[x*x + y*y + 1]/ul_LightingResolution

	else if (ul_FalloffStyle == UL_I_FALLOFF_SQUARE)
		return get_dist(src, ref)

	return 0

atom/proc/ul_SetOpacity(var/NewOpacity)
	if(opacity != NewOpacity)

		var/list/Blanked = ul_BlankLocal()

		opacity = NewOpacity

		ul_UnblankLocal(Blanked)

	return

atom/proc/ul_UnblankLocal(var/list/ReApply = view(ul_TopLuminosity, src))
	for(var/atom/Light in ReApply)
		if(Light.ul_IsLuminous())
			Light.ul_Illuminate()

	return

atom/proc/ul_BlankLocal()
	var/list/Blanked = list( )
	var/TurfAdjust = isturf(src) ? 1 : 0

	for(var/atom/Affected in view(ul_TopLuminosity, src))
		if(Affected.ul_IsLuminous() && Affected.ul_Extinguished == UL_I_LIT && (ul_FalloffAmount(Affected) <= Affected.luminosity + TurfAdjust))
			Affected.ul_Extinguish()
			Blanked += Affected

	return Blanked

atom/proc/ul_UpdateTopLuminosity()
	if (ul_TopLuminosity < LuminosityRed)
		ul_TopLuminosity = LuminosityRed

	if (ul_TopLuminosity < LuminosityGreen)
		ul_TopLuminosity = LuminosityGreen

	if (ul_TopLuminosity < LuminosityBlue)
		ul_TopLuminosity = LuminosityBlue

	return

atom/proc/ul_Luminosity()
	return max(LuminosityRed, LuminosityGreen, LuminosityBlue)

atom/proc/ul_IsLuminous(var/Red = LuminosityRed, var/Green = LuminosityGreen, var/Blue = LuminosityBlue)
	return (Red > 0 || Green > 0 || Blue > 0)

atom/proc/ul_LightLevelChanged()
	//Designed for client projects to use.  Called on items when the turf they are in has its light level changed
	return

atom/New()
	..()
	if(ul_IsLuminous())
		spawn(1)
			ul_Illuminate()
	return

atom/Del()
	if(ul_IsLuminous())
		ul_Extinguish()
	..()

atom/movable/Move()
	if(ul_IsLuminous())
		ul_Extinguish()
		..()
		ul_Illuminate()
	else
		..()


turf/var/list/MaxRed
turf/var/list/MaxGreen
turf/var/list/MaxBlue

turf/proc/ul_GetRed()
	if(MaxRed)
		return ul_Clamp(text2num(max(MaxRed)))
	return 0
turf/proc/ul_GetGreen()
	if(MaxGreen)
		return ul_Clamp(text2num(max(MaxGreen)))
	return 0
turf/proc/ul_GetBlue()
	if(MaxBlue)
		return ul_Clamp(text2num(max(MaxBlue)))
	return 0

turf/proc/ul_UpdateLight()
	var/area/CurrentArea = loc

	if(!isarea(CurrentArea) || !CurrentArea.ul_Lighting)
		return

	var/LightingTag = copytext(CurrentArea.tag, 1, findtext(CurrentArea.tag, ":UL")) + ":UL[ul_GetRed()]_[ul_GetGreen()]_[ul_GetBlue()]"

	if(CurrentArea.tag != LightingTag)
		var/area/NewArea = locate(LightingTag)

		if(!NewArea)
			NewArea = new CurrentArea.type()
			NewArea.tag = LightingTag

			for(var/V in CurrentArea.vars - "contents")
				if(issaved(CurrentArea.vars[V]))
					NewArea.vars[V] = CurrentArea.vars[V]

			NewArea.tag = LightingTag

			NewArea.ul_Light(ul_GetRed(), ul_GetGreen(), ul_GetBlue())


		NewArea.contents += src

	return

turf/proc/ul_Recalculate()

	ul_SuppressLightLevelChanges++

	var/list/Lights = ul_BlankLocal()

	ul_UnblankLocal(Lights)

	ul_SuppressLightLevelChanges--

	return

area/var/ul_Overlay = null
area/var/ul_Lighting = 1

area/var/LightLevelRed = 0
area/var/LightLevelGreen = 0
area/var/LightLevelBlue = 0
area/var/list/LightLevels

area/proc/ul_Light(var/Red = LightLevelRed, var/Green = LightLevelGreen, var/Blue = LightLevelBlue)

	if(!src || !src.ul_Lighting)
		return

	overlays -= ul_Overlay
	if(LightLevels)
		if(Red < LightLevels["Red"])
			Red = LightLevels["Red"]
		if(Green < LightLevels["Green"])
			Green = LightLevels["Green"]
		if(Blue < LightLevels["Blue"])
			Blue = LightLevels["Blue"]

	LightLevelRed = Red
	LightLevelGreen = Green
	LightLevelBlue = Blue

	luminosity = ul_IsLuminous(LightLevelRed, LightLevelGreen, LightLevelBlue)

	ul_Overlay = image('ULIcons.dmi', , num2text(LightLevelRed) + "-" + num2text(LightLevelGreen) + "-" + num2text(LightLevelBlue), ul_Layer)

	overlays += ul_Overlay

	return

area/proc/ul_Prep()

	if(!tag)
		tag = "[type]"
	if(ul_Lighting)
		if(!findtext(tag,":UL"))
			ul_Light()
	//world.log << tag

	return