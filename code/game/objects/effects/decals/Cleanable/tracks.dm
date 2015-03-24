// The idea is to have 4 bits for coming and 4 for going.
#define TRACKS_COMING_NORTH 1
#define TRACKS_COMING_SOUTH 2
#define TRACKS_COMING_EAST  4
#define TRACKS_COMING_WEST  8
#define TRACKS_GOING_NORTH  16
#define TRACKS_GOING_SOUTH  32
#define TRACKS_GOING_EAST   64
#define TRACKS_GOING_WEST   128

// 5 seconds
#define TRACKS_CRUSTIFY_TIME   50

// color-dir-dry
var/global/list/image/fluidtrack_cache=list()

/datum/fluidtrack
	var/direction=0
	var/basecolor="#A10808"
	var/wet=0
	var/fresh=1
	var/crusty=0
	var/image/overlay

/datum/fluidtrack/New(_direction,_color,_wet)
	src.direction=_direction
	src.basecolor=_color
	src.wet=_wet

// Footprints, tire trails...
/obj/effect/decal/cleanable/blood/tracks
	amount = 0
	random_icon_states = null
	var/dirs=0
	icon = 'icons/effects/fluidtracks.dmi'
	icon_state = ""
	var/coming_state="blood1"
	var/going_state="blood2"
	var/updatedtracks=0

	// dir = id in stack
	var/list/setdirs=list(
		"1"=0,
		"2"=0,
		"4"=0,
		"8"=0,
		"16"=0,
		"32"=0,
		"64"=0,
		"128"=0
	)

	// List of laid tracks and their colors.
	var/list/datum/fluidtrack/stack=list()


	/** DO NOT FUCKING REMOVE THIS. **/
	process()
		return PROCESS_KILL

	/**
	* Add tracks to an existing trail.
	*
	* @param DNA bloodDNA to add to collection.
	* @param comingdir Direction tracks come from, or 0.
	* @param goingdir Direction tracks are going to (or 0).
	* @param bloodcolor Color of the blood when wet.
	*/
/obj/effect/decal/cleanable/blood/tracks/resetVariables()
	stack = list()
	..("stack", "setdirs")
	setdirs=list(
		"1"=0,
		"2"=0,
		"4"=0,
		"8"=0,
		"16"=0,
		"32"=0,
		"64"=0,
		"128"=0
	)

/obj/effect/decal/cleanable/blood/tracks/proc/AddTracks(var/list/DNA, var/comingdir, var/goingdir, var/bloodcolor="#A10808")
	var/updated=0
	// Shift our goingdir 4 spaces to the left so it's in the GOING bitblock.
	var/realgoing=goingdir<<4

	// When tracks will start to dry out
	var/t=world.time + TRACKS_CRUSTIFY_TIME

	var/datum/fluidtrack/track

	for (var/b in cardinal)
		// COMING BIT
		// If setting
		if(comingdir&b)
			// If not wet or not set
			if(dirs&b)
				var/sid=setdirs["[b]"]
				track=stack[sid]
				if(track.wet==t && track.basecolor==bloodcolor)
					continue
				// Remove existing stack entry
				stack.Remove(track)
			track=new /datum/fluidtrack(b,bloodcolor,t)
			if(!istype(stack))
				stack = list()
			stack.Add(track)
			if(!setdirs || !istype(setdirs, /list) || setdirs.len < 8 || isnull(setdirs["[b]"]))
				warning("[src] had a bad directional [b] or bad list [setdirs.len]")
				warning("Setdirs keys:")
				for(var/key in setdirs)
					warning(key)
				setdirs=list (
				"1"=0,
				"2"=0,
				"4"=0,
				"8"=0,
				"16"=0,
				"32"=0,
				"64"=0,
				"128"=0
				)
			setdirs["[b]"]=stack.Find(track)
			updatedtracks |= b
			updated=1

		// GOING BIT (shift up 4)
		b=b<<4
		if(realgoing&b)
			// If not wet or not set
			if(dirs&b)
				var/sid=setdirs["[b]"]
				track=stack[sid]
				if(track.wet==t && track.basecolor==bloodcolor)
					continue
				// Remove existing stack entry
				stack.Remove(track)
			track=new /datum/fluidtrack(b,bloodcolor,t)
			if(!istype(stack))
				stack = list()
			stack.Add(track)
			if(!setdirs || !istype(setdirs, /list) || setdirs.len < 8 || isnull(setdirs["[b]"]))
				warning("[src] had a bad directional [b] or bad list [setdirs.len]")
				warning("Setdirs keys:")
				for(var/key in setdirs)
					warning(key)
				setdirs=list (
								"1"=0,
								"2"=0,
								"4"=0,
								"8"=0,
								"16"=0,
								"32"=0,
								"64"=0,
								"128"=0
							)
			setdirs["[b]"]=stack.Find(track)
			updatedtracks |= b
			updated=1

	dirs |= comingdir|realgoing
	blood_DNA |= DNA.Copy()
	if(updated)
		update_icon()

/obj/effect/decal/cleanable/blood/tracks/update_icon()
	// Clear everything.
	// Comment after the FIXME below is fixed.

	var/truedir=0
	//var/t=world.time

	/* FIXME: This shit doesn't work for some reason.
	   The Remove line doesn't remove the overlay given, so this is defunct.
	var/b=0
	for(var/image/overlay in overlays)
		b=overlay.dir
		if(overlay.icon_state==going_state)
			b=b<<4
		if(updatedtracks&b)
			overlays.Remove(overlay)
			//del(overlay)
	*/

	// We start with a blank canvas, otherwise some icon procs crash silently
	var/icon/flat = icon('icons/effects/fluidtracks.dmi')

	// Update ONLY the overlays that have changed.
	for(var/datum/fluidtrack/track in stack)
		// TODO: Uncomment when the block above is fixed.
		//if(!(updatedtracks&track.direction) && !track.fresh)
		//	continue
		var/stack_idx=setdirs["[track.direction]"]
		var/state=coming_state
		truedir=track.direction
		if(truedir&240) // Check if we're in the GOING block
			state=going_state
			truedir=truedir>>4
		var/icon/add = icon('icons/effects/fluidtracks.dmi', state, num2dir(truedir))
		add.Blend(track.basecolor,ICON_MULTIPLY)
		flat.Blend(add,ICON_OVERLAY)

		track.fresh=0
		stack[stack_idx]=track

	icon = flat
	updatedtracks=0 // Clear our memory of updated tracks.

/obj/effect/decal/cleanable/blood/tracks/footprints
	name = "wet footprints"
	desc = "Whoops..."
	coming_state = "human1"
	going_state  = "human2"
	amount = 0

/obj/effect/decal/cleanable/blood/tracks/footprints/vox
	coming_state = "claw1"
	going_state  = "claw2"

/obj/effect/decal/cleanable/blood/tracks/wheels
	name = "wet tracks"
	desc = "Whoops..."
	coming_state = "wheels"
	going_state  = ""
	desc = "They look like tracks left by wheels."
	gender = PLURAL
	random_icon_states = null
	amount = 0

