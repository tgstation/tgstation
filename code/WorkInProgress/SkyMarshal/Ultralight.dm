//UltraLight system, by Sukasa


#define UL_I_FALLOFF_SQUARE 0
#define UL_I_FALLOFF_ROUND 1

#define UL_I_LIT 0
#define UL_I_EXTINGUISHED 1
#define UL_I_ONZERO 2
#define UL_I_CHANGING 3

#define ul_LightingEnabled 1
//#define ul_LightingResolution 2
//Uncomment if you want maybe slightly smoother lighting
#define ul_Steps 7
#define ul_FalloffStyle UL_I_FALLOFF_ROUND // Sets the lighting falloff to be either squared or circular.
#define ul_Layer 10
#define ul_TopLuminosity 12 //Maximum brightness an object can have.

//#define ul_LightLevelChangedUpdates
//Uncomment if you have code that you want triggered when the light level on an atom changes.


#define ul_Clamp(Value) min(max(Value, 0), ul_Steps)
#define ul_IsLuminous(A) (A.ul_Red || A.ul_Green || A.ul_Blue)
#define ul_Luminosity(A) max(A.ul_Red, A.ul_Green, A.ul_Blue)


#ifdef ul_LightingResolution
var/ul_LightingResolutionSqrt = sqrt(ul_LightingResolution)
#endif
var/ul_SuppressLightLevelChanges = 0


var/list/ul_FastRoot = list(0, 1, 1, 1, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5,
							5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
							7, 7)

var/list/ul_IconCache = list()


proc/ul_UnblankLocal(var/list/ReApply = view(ul_TopLuminosity, src))
	for(var/atom/Light in ReApply)
		if(ul_IsLuminous(Light))
			Light.ul_Illuminate()
	return

atom/var/ul_Red = 0
atom/var/ul_Green = 0
atom/var/ul_Blue = 0
atom/var/turf/ul_LastIlluminated

atom/var/ul_Extinguished = UL_I_ONZERO

atom/proc/ul_SetLuminosity(var/Red = 0, var/Green = Red, var/Blue = Red)

	if(ul_Extinguished == UL_I_CHANGING) //Changing state, just supress any changes, to prevent glitches.
		return

	if(ul_Red == min(Red, ul_TopLuminosity) && ul_Green == min(Green, ul_TopLuminosity) && ul_Blue == min(Blue, ul_TopLuminosity))
		return //No point doing all that work if it won't have any effect anyways...

	if (ul_Extinguished == UL_I_EXTINGUISHED)
		ul_Red = min(Red,ul_TopLuminosity)
		ul_Green = min(Green,ul_TopLuminosity)
		ul_Blue = min(Blue,ul_TopLuminosity)

		return

	if (ul_IsLuminous(src))
		ul_Extinguish()

	ul_Red = min(Red,ul_TopLuminosity)
	ul_Green = min(Green,ul_TopLuminosity)
	ul_Blue = min(Blue,ul_TopLuminosity)

	ul_Extinguished = UL_I_ONZERO

	if (ul_IsLuminous(src))
		ul_Illuminate()

	return

atom/proc/ul_Illuminate()
	if (ul_Extinguished == UL_I_LIT)
		return

	ul_Extinguished = UL_I_CHANGING

	luminosity = ul_Luminosity(src)

	for(var/turf/Affected in view(luminosity, src))
		var/Falloff = ul_FalloffAmount(Affected)

		var/DeltaRed = ul_Red - Falloff
		var/DeltaGreen = ul_Green - Falloff
		var/DeltaBlue = ul_Blue - Falloff

		if(DeltaRed > 0 || DeltaGreen > 0 || DeltaBlue > 0)

			if(DeltaRed > 0)
				if(!Affected.MaxRed)
					Affected.MaxRed = list()
				Affected.MaxRed += DeltaRed

			if(DeltaGreen > 0)
				if(!Affected.MaxGreen)
					Affected.MaxGreen = list()
				Affected.MaxGreen += DeltaGreen

			if(DeltaBlue > 0)
				if(!Affected.MaxBlue)
					Affected.MaxBlue = list()
				Affected.MaxBlue += DeltaBlue

			Affected.ul_UpdateLight()

			#ifdef ul_LightLevelChangedUpdates
			if (ul_SuppressLightLevelChanges == 0)
				Affected.ul_LightLevelChanged()

				for(var/atom/AffectedAtom in Affected)
					AffectedAtom.ul_LightLevelChanged()
			#endif

	ul_LastIlluminated = get_turf(src)
	ul_Extinguished = UL_I_LIT

	return

atom/proc/ul_Extinguish()

	if (ul_Extinguished != UL_I_LIT)
		return

	ul_Extinguished = UL_I_CHANGING

	for(var/turf/Affected in view(ul_Luminosity(src), ul_LastIlluminated))

		var/Falloff = ul_LastIlluminated.ul_FalloffAmount(Affected)

		var/DeltaRed = ul_Red - Falloff
		var/DeltaGreen = ul_Green - Falloff
		var/DeltaBlue = ul_Blue - Falloff

		if(DeltaRed > 0 || DeltaGreen > 0 || DeltaBlue > 0)

			if(DeltaRed > 0)
				if(Affected.MaxRed)
					var/removed_light_source = Affected.MaxRed.Find(DeltaRed)
					if(removed_light_source)
						Affected.MaxRed.Cut(removed_light_source, removed_light_source+1)
					if(!Affected.MaxRed.len)
						del Affected.MaxRed

			if(DeltaGreen > 0)
				if(Affected.MaxGreen)
					var/removed_light_source = Affected.MaxGreen.Find(DeltaGreen)
					if(removed_light_source)
						Affected.MaxGreen.Cut(removed_light_source, removed_light_source+1)
					if(!Affected.MaxGreen.len)
						del Affected.MaxGreen

			if(DeltaBlue > 0)
				if(Affected.MaxBlue)
					var/removed_light_source = Affected.MaxBlue.Find(DeltaBlue)
					if(removed_light_source)
						Affected.MaxBlue.Cut(removed_light_source, removed_light_source+1)
					if(!Affected.MaxBlue.len)
						del Affected.MaxBlue

			Affected.ul_UpdateLight()

			#ifdef ul_LightLevelChangedUpdates
			if (ul_SuppressLightLevelChanges == 0)
				Affected.ul_LightLevelChanged()

				for(var/atom/AffectedAtom in Affected)
					AffectedAtom.ul_LightLevelChanged()
			#endif

	ul_Extinguished = UL_I_EXTINGUISHED
	luminosity = 0
	ul_LastIlluminated = null

	return


/*
 Calculates the correct lighting falloff value (used to calculate what brightness to set the turf to) to use,
  when called on a luminous atom and passed an atom in the turf to be lit.

 Supports multiple configurations, BS12 uses the circular falloff setting. This setting uses an array lookup
  to avoid the cost of the square root function.
*/
atom/proc/ul_FalloffAmount(var/atom/ref)
	if (ul_FalloffStyle == UL_I_FALLOFF_ROUND)
		var/delta_x = (ref.x - src.x)
		var/delta_y = (ref.y - src.y)

		#ifdef ul_LightingResolution
		if (round((delta_x*delta_x + delta_y*delta_y)*ul_LightingResolutionSqrt,1) > ul_FastRoot.len)
			for(var/i = ul_FastRoot.len, i <= round(delta_x*delta_x+delta_y*delta_y*ul_LightingResolutionSqrt,1), i++)
				ul_FastRoot += round(sqrt(i))
		return ul_FastRoot[round((delta_x*delta_x + delta_y*delta_y)*ul_LightingResolutionSqrt, 1) + 1]/ul_LightingResolution

		#else
		if ((delta_x*delta_x + delta_y*delta_y) > ul_FastRoot.len)
			for(var/i = ul_FastRoot.len, i <= delta_x*delta_x+delta_y*delta_y, i++)
				ul_FastRoot += round(sqrt(i))
		return ul_FastRoot[delta_x*delta_x + delta_y*delta_y + 1]

		#endif

	else if (ul_FalloffStyle == UL_I_FALLOFF_SQUARE)
		return get_dist(src, ref)

	return 0

atom/proc/ul_SetOpacity(var/NewOpacity)
	if(opacity != NewOpacity)

		var/list/Blanked = ul_BlankLocal()

		opacity = NewOpacity

		ul_UnblankLocal(Blanked)

	return

atom/proc/ul_BlankLocal()
	var/list/Blanked = list( )
	var/TurfAdjust = isturf(src) ? 1 : 0

	for(var/atom/Affected in view(ul_TopLuminosity, src))
		if(ul_IsLuminous(Affected) && Affected.ul_Extinguished == UL_I_LIT && (ul_FalloffAmount(Affected) <= ul_Luminosity(Affected) + TurfAdjust))
			Affected.ul_Extinguish()
			Blanked += Affected

	return Blanked

atom/proc/ul_LightLevelChanged()
	//Designed for client projects to use.  Called on items when the turf they are in has its light level changed
	return

atom/New()
	. = ..()
	if(ul_IsLuminous(src))
		spawn(5)
			ul_Illuminate()

atom/Del()
	if(ul_IsLuminous(src))
		ul_Extinguish()
	. = ..()

atom/movable/Move()
	if(ul_IsLuminous(src))
		ul_Extinguish()
		. = ..()
		ul_Illuminate()
	else
		return ..()


turf/var/list/MaxRed
turf/var/list/MaxGreen
turf/var/list/MaxBlue

turf/proc/ul_GetRed()
	if(MaxRed)
		return ul_Clamp(max(MaxRed))
	return 0
turf/proc/ul_GetGreen()
	if(MaxGreen)
		return ul_Clamp(max(MaxGreen))
	return 0
turf/proc/ul_GetBlue()
	if(MaxBlue)
		return ul_Clamp(max(MaxBlue))
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

	luminosity = LightLevelRed || LightLevelGreen || LightLevelBlue

	var/ul_CachedOverlay = ul_IconCache["[LightLevelRed]-[LightLevelGreen]-[LightLevelBlue]"]
	if(ul_CachedOverlay)
		ul_Overlay = ul_CachedOverlay
	else
		ul_IconCache["[LightLevelRed]-[LightLevelGreen]-[LightLevelBlue]"] = image('ULIcons.dmi', , "[LightLevelRed]-[LightLevelGreen]-[LightLevelBlue]", ul_Layer)
		ul_Overlay = ul_IconCache["[LightLevelRed]-[LightLevelGreen]-[LightLevelBlue]"]

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

#undef UL_I_FALLOFF_SQUARE
#undef UL_I_FALLOFF_ROUND
#undef UL_I_LIT
#undef UL_I_EXTINGUISHED
#undef UL_I_ONZERO
#undef ul_LightingEnabled
#undef ul_LightingResolution
#undef ul_Steps
#undef ul_FalloffStyle
#undef ul_Layer
#undef ul_TopLuminosity
#undef ul_Clamp
#undef ul_LightLevelChangedUpdates