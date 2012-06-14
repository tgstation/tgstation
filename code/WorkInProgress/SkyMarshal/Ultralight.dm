//UltraLight system, by Sukasa


#define UL_I_FALLOFF_SQUARE 0
#define UL_I_FALLOFF_ROUND 1

#define UL_I_LIT 0
#define UL_I_EXTINGUISHED 1
#define UL_I_ONZERO 2
var
	ul_LightingEnabled = 1
	ul_LightingResolution = 1
	ul_Steps = 7
	ul_FalloffStyle = UL_I_FALLOFF_ROUND // Sets the lighting falloff to be either squared or circular.
	ul_TopLuminosity = 0
	ul_Layer = 10
	ul_SuppressLightLevelChanges = 0

	list/ul_FastRoot = list(0, 1, 1, 1, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5,
							5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
							7, 7)

var/list/light_to_instantiate = list()
var/UL_setup = 0

proc/setup_UL()
	UL_setup = 1
	world << "\red <b>Setting up UltraLight...</b>"
	for(var/atom/A in light_to_instantiate)
		if(A.ul_IsLuminous())
			A.ul_Illuminate()

proc/ul_Clamp(var/Value)
	return min(max(Value, 0), ul_Steps)

atom
	var
		LuminosityRed = 0
		LuminosityGreen = 0
		LuminosityBlue = 0

		ul_Extinguished = UL_I_ONZERO

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

	for(var/turf/Affected in view(ul_Luminosity(), src))
		var/Falloff = src.ul_FalloffAmount(Affected)

		var/DeltaRed = LuminosityRed - Falloff
		var/DeltaGreen = LuminosityGreen - Falloff
		var/DeltaBlue = LuminosityBlue - Falloff

		if(ul_IsLuminous(DeltaRed, DeltaGreen, DeltaBlue))

			Affected.LightLevelRed += max(DeltaRed, 0)
			Affected.LightLevelGreen += max(DeltaGreen, 0)
			Affected.LightLevelBlue += max(DeltaBlue, 0)

			Affected.MaxRed += LuminosityRed
			Affected.MaxGreen += LuminosityGreen
			Affected.MaxBlue += LuminosityBlue

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

		if(ul_IsLuminous(DeltaRed, DeltaGreen, DeltaBlue))

			Affected.LightLevelRed -= max(DeltaRed, 0)
			Affected.LightLevelGreen -= max(DeltaGreen, 0)
			Affected.LightLevelBlue -= max(DeltaBlue, 0)

			Affected.MaxRed -= LuminosityRed
			Affected.MaxGreen -= LuminosityGreen
			Affected.MaxBlue -= LuminosityBlue

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
		if ((x*x + y*y) > ul_FastRoot.len)
			for(var/i = ul_FastRoot.len, i <= x*x+y*y, i++)
				ul_FastRoot += round(sqrt(x*x+y*y))
		return round(ul_LightingResolution * ul_FastRoot[x*x + y*y + 1], 1)

	else if (ul_FalloffStyle == UL_I_FALLOFF_SQUARE)
		return get_dist(src, ref)

	return 0

atom/proc/ul_SetOpacity(var/NewOpacity)
	if(opacity != NewOpacity)

		var/list/Blanked = ul_BlankLocal()
		var/atom/T = src
		while(T && !isturf(T))
			T = T.loc

		opacity = NewOpacity

		if(T)
			T:LightLevelRed = 0
			T:LightLevelGreen = 0
			T:LightLevelBlue = 0

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
	if(UL_setup)
		if(ul_IsLuminous())
			ul_Illuminate()
	else
		light_to_instantiate |= src

atom/Del()
	if(ul_IsLuminous())
		ul_Extinguish()

	..()

	return

// formerly atom/proc/movable/Move(), this now overwrites other shit causing random inexplicable problems.
// need to find a way to plug it in to the root without overriding, might just do the snowflake treatment
/*atom/proc/Move()
	ul_Extinguish()
	..()
	ul_Illuminate()
	return*/

turf
	var
		LightLevelRed = 0
		LightLevelGreen = 0
		LightLevelBlue = 0

		list/MaxRed = list( )
		list/MaxGreen = list( )
		list/MaxBlue = list( )



turf/proc/ul_GetRed()
	return ul_Clamp(min(LightLevelRed, max(MaxRed)))
turf/proc/ul_GetGreen()
	return ul_Clamp(min(LightLevelGreen, max(MaxGreen)))
turf/proc/ul_GetBlue()
	return ul_Clamp(min(LightLevelBlue, max(MaxBlue)))

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

	LightLevelRed = 0
	LightLevelGreen = 0
	LightLevelBlue = 0

	ul_UnblankLocal(Lights)

	ul_SuppressLightLevelChanges--

	return

area
	var
		ul_Overlay = null
		ul_Lighting = 1

		LightLevelRed = 0
		LightLevelGreen = 0
		LightLevelBlue = 0


area/proc/ul_Light(var/Red = LightLevelRed, var/Green = LightLevelGreen, var/Blue = LightLevelBlue)

	if(!src || !src.ul_Lighting)
		return

	overlays -= ul_Overlay

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