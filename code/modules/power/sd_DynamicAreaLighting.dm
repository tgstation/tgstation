/* Overview of sd_DynamicAreaLighting as modified for SS13
 *
 *
 * Use sd_SetLuminosity(value) to change the luminosity of an atom
 * rather than setting the luminosity var directly.
 * Avoid having luminous objects at compile-time since this can mess up
 * the lighting system during map load. Instead use sd_SetLuminosity() in
 * the atom's New() proc after a small spawn delay.
 *
 * Use sd_SetOpacity(value) to change the opacity of an atom (e.g. doors)
 * rather than setting the opacity var directly. This ensures that lighting
 * will be blocked/unblocked as necessary.
 *
 * If creating a new opaque atom (e.g. a wall) at runtime, create the atom,
 * set its opacity var to zero, then perform sd_SetOpacity(1)
 * e.g.:
 *
 * var/obj/block/B = new(loc)
 * B.opacity = 0
 * B.sd_SetOpacity(1)
 *
 *
 * The library creates multiple instances of each /area to split a mapped area
 * into different lighting levels. Each area created has a "master" variable
 * which is a reference to the original un-split area, and a "related" variable
 * which is a reference to the list of split areas.

 */





/********************************************************************\
	sd_DynamicAreaLighting.dm
	Shadowdarke (shadowdarke@hotmail.com)
	December 12, 2002

	The sd_DynamicAreaLighting library provides dynamic lighting
	with minimal cpu and bandwidth usage by shifting turfs between
	five areas which represent varying shades of darkness.

**********************************************************************
Using sd_DynamicAreaLighting

	This library uses BYOND's built in luminousity variable. In most
	cases, all you have to do is set luminosity and let the library
	worry about the work.

	There are three cases that the library does not automatically
	compensate for, so you will need to use library procs:

	1)	Luminosity changes at run time.
		If your program makes changes in luminosity while it is
		running, you need to use sd_SetLuminosity(new_luminosity)
		so the library can remove the effect of the old luminosity
		and apply the new effect.

	2)	Opacity changes at run time.
		As with luminosity changes, you need to use
		sd_SetOpacity(new_opacity) if your program changes the opacity
		of atoms at runtime.

	3)	New atoms that change the opacity of a location.
		This is somewhat more complex, and the library doesn't
		have a simple proc to take care of it yet. You should use
		sd_StripLocalLum() to strip the luminosity effect of
		anything shining on that space, create the new atom, then
		use sd_ApplyLocalLum() to reapply the luminosity effect.
		Examine the sd_SetOpacity() proc for an example of the
		procedure.

	All areas will automatically use the sd_DynamicAreaLighting
	library when it is included in your project. You may disable
	lighting effect in an area by specifically setting the area's
	sd_lighting var to 0. For example:

	area/always_lit
		luminosity = 1
		sd_lighting = 0

	This library chops areas into 5 separate areas of differing
	light effect, so you may want to modify area Enter(), Exit(),
	Entered(), and Exited() procs to make sure the atom has moved
	from a different area instead of a different light zone of the
	same area.

	IMPORTANT NOTE: Since sd_DynamicAreaLighting uses the view()
	proc, large luminosity settings may cause strange effect. You
	should limit luminosity to (world.view * 2) or less.

----------------------------------------------------------------------
CUSTOM DARKNESS ICONS
	sd_DynamicAreaLighting was designed in a barbaric age when BYOND
	did not support alpha transperency. Thankfully that age is over.
	I left the old icon as the default, since not everyone has
	upgraded to BYOND 4.0 or in some cases like software graphics
	mode, in which case the old dithered icon is the better choice.

	The dithered icon used 4 standard dithers for the darkness shades
	and I saw little reason to allow variation. Starting with sd_DAL
	version 10, the library can support more or less shades of
	darkness as well.

	To change the icon and/or number of shades of darkness for your
	game, just call the sd_SetDarkIcon(dark_icon, num_shades) proc,
	where dark_icon is the new icon and num_shades is the number of
	shades of darkness in the icon. This is best done in the
	world.New() proc, to set it once for the entire game instance.

	For example, to make the included 7 shade alpha transparency icon
	your game's darkness icon, use the following code in your game.

world
	New()
		..()
		sd_SetDarkIcon('sd_dark_alpha7.dmi', 7)

	There are several demo icons included with this library:
		sd_darkstates.dmi	- the original 4 shade dithered icon
		sd_dark_dither3.dmi	- 3 shade dithered icon
		sd_dark_alpha4.dmi	- 4 shade alpha transparency icon
		sd_dark_alpha4b.dmi	- lighter version 4 shade alpha
								transparency icon
		sd_dark_alpha7.dmi	- 7 shade alpha transparency icon

	If you want to design your own custom darkness icons, they
	have to follow a specific format for the library to use them
	properly. The shades of darkness should have be numbered from 0
	as the darkest shade to the number of shades minus one as the
	lightest shade.

	For example, the four shade 4 shade transparent icon
	sd_dark_alpha4.dmi has 4 icon states:
		"0" is black with 204 alpha (80% darkness)
		"1" is black with 153 alpha (60% darkness)
		"2" is black with 102 alpha (40% darkness)
		"3" is black with 51 alpha  (20% darkness)


	The lightest shade ("3" in this case) is NOT completely clear.
	There will be no darkness overlay for completely lit areas. The
	lightest shade will only be used for places that are just beginning
	to get dark.

	The darkest shade ("0") likewise is not 100% obscured. "0" will
	be used in completely dark areas, but by leaving it slightly
	transparent, characters will be able to barely make out their
	immediate surroundings in the darkness (based on the mob
	see_in_dark var.) You might prefer to lighten the darkness for
	this purpose, like in demo icon sd_dark_alpha4b.dmi.


----------------------------------------------------------------------
DAY/NIGHT CYCLES

	sd_DynamicAreaLighting allows for separate indoor and outdoor
	lighting. Areas used for outdoor light cycles should be
	designated by setting the area's sd_outside var to 1. For example:

	area/outside
		sd_outside = 1

	You will need to write your own routine for the day/night
	cycle so that you can control the timing and degree of lighting
	changes. There is an example routine in lightingdemo.dm.

	After your routine determines the amount of light outdoors,
	call sd_OutsideLight(light_level) to update the light levels in
	all outside areas. light_level should be a value from 0 to
	sd_dark_shades, where 0 is darkest and sd_dark_shades is full
	light.

	The sd_OutsideLight() proc does not automatically detect a
	range out of bounds in case you want to use nonstandard values
	for interesting effect. For instance, you could use a negative
	value to dampen light sources.

If you want daylight to spill indoors:

	You will need to add turfs to sd_light_spill_turfs. The
	library will automatically add any turf created with
	sd_light_spill set, or you may add the turfs yourself at
	runtime.

	The turfs in this list act as a source of daylight, shining
	into the any areas that are not flagged with sd_outside.

**********************************************************************
LIBRARY PROCS:
Except in the cases noted above, you shouldn't need to use the procs
in this library. This reference is provided for advanced users.

Global vars and procs:
	var
		sd_dark_icon
			This is the icon used for the darkness in your world.
			DEFAULT VALUE: 'sd_darkstates.dmi' (A dithered icon
				designed for BYOND releases before 4.0.)

		sd_dark_shades
			The number of darkness icon states in your sd_dark_icon.
			DEFAULT VALUE: 4

		sd_light_layer
			The graphic layer that darkness overlays appear on.
			This should be higher than anything on the map, but
			lower than any HUD displays.
			DEFAULT VALUE: 50

		sd_light_outside
			This var is how bright it currently is outside. It
			should be a number between 0 and sd_dark_shades.
			DEFAULT VALUE: 0

		sd_top_luminosity
			keeps track of the highest luminosity in the world to
			prevent getting larger lists than necessary.

		list/sd_outside
			A list of outside areas.

		list/sd_light_spill_turfs
			A list of turfs where light spills from outside areas into
			inside areas.

	proc/sd_OutsideLight(n as num)
		Changes the level of light outside (sd_light_outside) to n
		and updates all the atoms in sd_outside.

	proc/sd_SetDarkIcon(icon, shades)
		Changes the darkness icon and the number shades of darkness
		in that icon.

All atoms have the following procs:
	sd_ApplyLum(list/V = view(luminosity,src), center = src)
		This proc adds a value to the sd_lumcount of all the
		turfs in V, depending on src.luminosity and  the
		distance between the turf and center.

	sd_StripLum(list/V = view(luminosity,src), center = src)
		The reverse of sd_ApplyLum(), sd_StripLum removes luminosity
		effect.

	sd_ApplyLocalLum(list/affected = viewers(20,src))
		Applies the lighting effect of all atoms in affected. This
		proc is used with sd_StripLocalLum() for effect that may
		change the opacity of a turf.

	sd_StripLocalLum()
		Strips effect of all local luminous atoms.
		RETURNS: list of all the luminous atoms stripped
		IMPORTANT! Each sd_StripLocalLum() call should have a matching
			sd_ApplyLocalLum() to restore the local effect.

	sd_SetLuminosity(new_luminosity as num)
		Sets the atom's luminosity, making adjustments to the
		sd_lumcount of local turfs.

	sd_SetOpacity(new_opacity as num)
		Sets the atom's opacity, making adjustments to the
		sd_lumcount of local turfs.

Areas have one additional proc and 4 variables:
	var
		sd_lighting
			Turn this flag off to prevent sd_DynamicAreaLighting
			from effecting this area.
			DEFAULT VALUE: 1 (allow dynamic lighting)

		sd_outside
			Set this flag to automatically add this area to the
			list of outside areas.
			DEAFAULT VALUE: 0 (not an outside area)

		sd_light_level
			The current light level of the area. You should use
			the sd_LightLevel() proc to set this value, so the
			darkness overlays will be changed as well.
			DEFAULT VALUE: 0

		sd_darkimage
			Tracks the darkness image of the area for easy
			removal in the sd_LightLevel() proc

	proc
		sd_LightLevel(level = sd_light_level as num,keep = 1)
			Updates the darkness overlay of the area.
			If keep = 1, it also updates the area's
			sd_light_level var.

Turfs have these additional procs and vars:
	var
		sd_lumcount
			Used to track the brightness of a turf.

		sd_light_spill
			If set, the turf will automatically be added to the
			global list sd_light_spill_turfs when created.
			DEFAULT VALUE: 0

	proc
		sd_LumUpdate()
			Places the turf in the appropriate sd_dark area,
			depending on its brightness (sd_lumcount).

		sd_LumReset()
			Resets a turf's lumcount by stripping local luminosity,
			zeroing the lumcount, then reapplying local luminosity.

		sd_ApplySpill()
			Applies to effect of daylight spilling into inside
			areas in view of this turf.

		sd_StripSpill()
			Removes to effect of daylight spilling into inside
			areas in view of this turf.

\********************************************************************/

var/const/sd_dark_icon = 'icons/effects/ss13_dark_alpha7.dmi'	// icon used for darkness
var/const/sd_dark_shades = 7									// number of icon state in sd_dark_icon
var/const/sd_light_layer = 10									// graphics layer for light effect
var/sd_top_luminosity = 0

	// since we're not using these, comment out all occurances to save CPU
	/*
	list
		sd_outside_areas = list()	// list of outside areas
		sd_light_spill_turfs = list()	// list of turfs to calculate light spill from
	*/

//	slog = file("DALlog.txt")

/*
proc
	sd_OutsideLight(n as num)
	// set the brightness of the outside sunlight
		if(sd_light_outside == n) return	// same level, no update
		if(sd_light_outside)
			for(var/turf/T in sd_light_spill_turfs)
				T.sd_StripSpill()
		sd_light_outside = n

		// make all the outside areas update themselves
		for(var/area/A in sd_outside_areas)
			A.sd_LightLevel(sd_light_outside + A.sd_light_level,0)
		if(n)
			for(var/turf/T in sd_light_spill_turfs)
				T.sd_ApplySpill()
*/
/*
proc/sd_SetDarkIcon(icon, shades)
	// reset the darkness icon and number of shades of darkness
	sd_dark_icon = icon
	sd_dark_shades = shades
	// change existing areas
	for(var/area/A)
		if(A.sd_darkimage) A.sd_LightLevel(A.sd_light_level,0)
*/

atom/New()
	..()
	// if this is not an area and is luminous
	if(!isarea(src)&&(luminosity>0))
		spawn(1)			// delay to allow map load
			sd_ApplyLum()

atom/Del()
	// if this is not an area and is luminous
	if(!isarea(src)&&(luminosity>0))
		sd_StripLum()
	..()

atom/proc/sd_ApplyLum(list/V = view(luminosity,src), center = src)
	if(src.luminosity>sd_top_luminosity)
		sd_top_luminosity = src.luminosity
	// loop through all the turfs in V
	for(var/turf/T in V)
		/*	increase the turf's brightness depending on the
			brightness and distance of the lightsource */
		T.sd_lumcount += (luminosity-get_dist(center,T))
		T.sd_LumUpdate()

atom/proc/sd_StripLum(list/V = view(luminosity,src), center = src)
	// loop through all the turfs in V
	for(var/turf/T in V)
		/*	increase the turf's brightness depending on the
			brightness and distance of the lightsource */
		T.sd_lumcount -= (luminosity-get_dist(center,T))
		T.sd_lumcount = max(0, T.sd_lumcount)
		//	update the turf's area
		T.sd_LumUpdate()

atom/proc/sd_ApplyLocalLum(list/affected = view(sd_top_luminosity,src))
	// Reapplies the lighting effect of all atoms in affected.
	for(var/atom/A in affected)
		if(A.luminosity) A.sd_ApplyLum()

atom/proc/sd_StripLocalLum()
	/*	strips all local luminosity

		RETURNS: list of all the luminous atoms stripped

		IMPORTANT! Each sd_StripLocalLum() call should have a matching
			sd_ApplyLocalLum() to restore the local effect. */
	var/list/affected = list()
	for(var/atom/A in view(sd_top_luminosity,src))
		var/turfflag = (isturf(src)?1:0)
		if(A.luminosity && (get_dist(src,A) <= A.luminosity + turfflag))
			A.sd_StripLum()
			affected += A
	return affected

atom/proc/sd_SetLuminosity(new_luminosity as num)
	/*	This proc should be called everytime you want to change the
		luminosity of an atom instead of setting it directly.

		new_luminosity is the new value for luminosity. */
	if(luminosity>0)
		sd_StripLum()
	luminosity = new_luminosity
	if(luminosity>0)
		sd_ApplyLum()


atom/proc/sd_SetOpacity(new_opacity as num)
	if(opacity == (new_opacity ? 1 : 0)) return

	var/list/affected = new
	var/atom/A
	var/turf/T
	var/turf/ATurf

	for(A in range(sd_top_luminosity,src))
		T = A
		while(T && !istype(T)) T = T.loc
		if(T)
			var/list/V = view(A.luminosity,T)
			if(!(src in V)) continue
			var/turfflag = 0
			if(A == T) turfflag = 1
			if(A.luminosity && get_dist(A,src)<=A.luminosity+turfflag)
				affected[A] = V
	opacity = new_opacity
	if(opacity)
		for(A in affected)
			ATurf = A
			while(ATurf && !istype(ATurf)) ATurf = ATurf.loc
			if(ATurf)
				for(T in affected[A]-view(A.luminosity, ATurf))
					T.sd_lumcount -= (A.luminosity-get_dist(A,T))
					T.sd_lumcount = max(0, T.sd_lumcount)
					T.sd_LumUpdate()


	else
		for(A in affected)
			ATurf = A
			while(ATurf && !istype(ATurf)) ATurf = ATurf.loc
			if(ATurf)
				for(T in view(A.luminosity, ATurf) - affected[A])
					T.sd_lumcount += (A.luminosity-get_dist(A,T))
					T.sd_LumUpdate()

///

atom/proc/sd_NewOpacity(var/new_opacity)
	if(opacity != new_opacity)
		var/list/affected = sd_StripLocalLum()
		opacity = new_opacity
		var/atom/T = src
		while(T && !isturf(T))
			T = T.loc
		if(T)
			T:sd_lumcount = 0

		sd_ApplyLocalLum(affected)

///

turf
	var/tmp/sd_lumcount = 0	// the brightness of the turf


turf/proc/sd_LumReset()
	/* Clear local lum, reset this turf's sd_lumcount, and
		re-apply local lum*/
	var/list/affected = sd_StripLocalLum()
	sd_lumcount = 0
	sd_ApplyLocalLum(affected)

turf/proc/sd_LumUpdate()
	set background = 1
	var/area/Loc = loc
	if(!istype(Loc) || !Loc.sd_lighting) return

	// change the turf's area depending on its brightness
	// restrict light to valid levels
	var/light = min(max(sd_lumcount,0),sd_dark_shades)
	var/ltag = copytext(Loc.tag,1,findtext(Loc.tag,"sd_L")) + "sd_L[light]"

	if(Loc.tag!=ltag)	//skip if already in this area
		var/area/A = locate(ltag)	// find an appropriate area
		if(!A)
			A = new Loc.type()    // create area if it wasn't found
			// replicate vars
			for(var/V in Loc.vars-"contents")
				if(issaved(Loc.vars[V])) A.vars[V] = Loc.vars[V]

			A.tag = ltag
			A.sd_LightLevel(light)

		A.contents += src	// move the turf into the area

atom/movable/Move() // when something moves

	var/turf/oldloc = loc	// remember for range calculations
	// list turfs in view and luminosity range of old loc
	var/list/oldview
	if(luminosity>0)		// if atom is luminous
		if(isturf(loc))
			oldview = view(luminosity,loc)
		else
			oldview = list()

	. = ..()

	if(.&&(luminosity>0))	// if the atom actually moved
		if(istype(oldloc))
			sd_StripLum(oldview,oldloc)
			oldloc.sd_lumcount++	// correct "off by 1" error in oldloc
		sd_ApplyLum()

area
	var/sd_lighting = 1		//Turn this flag off to prevent sd_DynamicAreaLighting from affecting this area
	var/sd_light_level = 0	//This is the current light level of the area
	var/sd_darkimage		//This tracks the darkness image of the area for easy removal


area/proc/sd_LightLevel(slevel = sd_light_level as num, keep = 1)
	if(!src) return
	overlays -= sd_darkimage

	if(keep) sd_light_level = slevel

	slevel = min(max(slevel,0),sd_dark_shades)	// restrict range

	if(slevel > 0)
		luminosity = 1
	else
		luminosity = 0

	sd_darkimage = image(sd_dark_icon,,num2text(slevel),sd_light_layer)
	overlays += sd_darkimage

area/proc/sd_New(sd_created)

	if(!tag) tag = "[type]"
	spawn(1)	// wait a tick
		if(sd_lighting)
			// see if this area was created by the library
			if(!sd_created)
				/*	show the dark overlay so areas outside of luminous regions
					won't be bright as day when they should be dark. */
				sd_LightLevel()

area/Del()
	..()
	related -= src


	/* extend the mob procs to compensate for sight settings. */
mob/sd_ApplyLum(list/V, center = src)
	if(!V)
		if(isturf(loc))
			V = view(luminosity,loc)
		else
			V = view(luminosity,src)
	. = ..(V, center)

mob/sd_StripLum(list/V, center = src)
	if(!V)
		if(isturf(loc))
			V = view(luminosity,loc)
		else
			V = view(luminosity,src)
	. = ..(V, center)

mob/sd_ApplyLocalLum(list/affected)
	if(!affected)
		if(isturf(loc))
			affected = view(sd_top_luminosity,loc)
		else
			affected = view(sd_top_luminosity,src)
	. = ..(affected)
