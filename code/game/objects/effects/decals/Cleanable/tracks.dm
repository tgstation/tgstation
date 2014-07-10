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

	New(_direction,_color,_wet)
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
	proc/AddTracks(var/list/DNA, var/comingdir, var/goingdir, var/bloodcolor="#A10808")
		var/updated=0
		// Shift our goingdir 4 spaces to the left so it's in the GOING bitblock.
		var/realgoing=goingdir<<4

		// Current bit
		var/b=0

		// When tracks will start to dry out
		var/t=world.time + TRACKS_CRUSTIFY_TIME

		var/datum/fluidtrack/track

		// Process 4 bits
		for(var/bi=0;bi<4;bi++)
			b=1<<bi
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
				stack.Add(track)
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
				stack.Add(track)
				setdirs["[b]"]=stack.Find(track)
				updatedtracks |= b
				updated=1

		dirs |= comingdir|realgoing
		blood_DNA |= DNA.Copy()
		if(updated)
			update_icon()

	update_icon()
		// Clear everything.
		// Comment after the FIXME below is fixed.
		overlays.Cut()

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

			if(track.overlay)
				track.overlay=null
			var/image/I = image(icon, icon_state=state, dir=num2dir(truedir))
			I.color = track.basecolor

			track.fresh=0
			track.overlay=I
			stack[stack_idx]=track
			overlays += I
		updatedtracks=0 // Clear our memory of updated tracks.

/obj/effect/decal/cleanable/blood/tracks/footprints
	name = "wet footprints"
	desc = "Whoops..."
	coming_state = "human1"
	going_state  = "human2"
	amount = 0

/obj/effect/decal/cleanable/blood/tracks/wheels
	name = "wet tracks"
	desc = "Whoops..."
	coming_state = "wheels"
	going_state  = ""
	desc = "They look like tracks left by wheels."
	gender = PLURAL
	random_icon_states = null
	amount = 0