#define DRYING_TIME 5 * 60*10			//for 1 unit of depth in puddle (amount var)

/obj/effect/decal/cleanable/blood
	name = "blood"
	desc = "It's red and gooey. Perhaps it's the chef's cooking?"
	gender = PLURAL
	density = 0
	anchored = 1
	layer = 2
	icon = 'icons/effects/blood.dmi'
	icon_state = "floor1"
	random_icon_states = list("floor1", "floor2", "floor3", "floor4", "floor5", "floor6", "floor7")
	var/list/viruses = list()
	blood_DNA = list()
	var/basecolor="#ff0000" // Color when wet.
	var/list/datum/disease2/disease/virus2 = list()
	var/amount = 5

/obj/effect/decal/cleanable/blood/Del()
	for(var/datum/disease/D in viruses)
		D.cure(0)
	..()

/obj/effect/decal/cleanable/blood/New()
	..()
	if(istype(src, /obj/effect/decal/cleanable/blood/gibs))
		return
	if(istype(src, /obj/effect/decal/cleanable/blood/tracks))
		return // We handle our own drying.
	if(src.type == /obj/effect/decal/cleanable/blood)
		if(src.loc && isturf(src.loc))
			for(var/obj/effect/decal/cleanable/blood/B in src.loc)
				if(B != src)
					if (B.blood_DNA)
						blood_DNA |= B.blood_DNA.Copy()
					del(B)
	spawn(DRYING_TIME * (amount+1))
		dry()

/obj/effect/decal/cleanable/blood/HasEntered(mob/living/carbon/human/perp)
	if (!istype(perp))
		return
	if(amount < 1)
		return

	if(perp.shoes)
		perp.shoes:track_blood = max(amount,perp.shoes:track_blood)		//Adding blood to shoes
		if(!perp.shoes.blood_overlay)
			perp.shoes.generate_blood_overlay()
		if(!perp.shoes.blood_DNA)
			perp.shoes.blood_DNA = list()
			perp.shoes.overlays += perp.shoes.blood_overlay
			perp.update_inv_shoes(1)
		perp.shoes.blood_DNA |= blood_DNA.Copy()
		perp.shoes.blood_color=basecolor
	else
		perp.track_blood = max(amount,perp.track_blood)				//Or feet
		if(!perp.feet_blood_DNA)
			perp.feet_blood_DNA = list()
		perp.feet_blood_DNA |= blood_DNA.Copy()
		perp.feet_blood_color=basecolor

	amount--

/obj/effect/decal/cleanable/blood/proc/dry()
	name = "dried [src]"
	desc = "It's dark red and crusty. Someone is not doing their job."
	var/icon/I = icon(icon,icon_state)
	I.SetIntensity(0.7)
	icon = I
	amount = 0

/obj/effect/decal/cleanable/blood/splatter
	random_icon_states = list("gibbl1", "gibbl2", "gibbl3", "gibbl4", "gibbl5")
	amount = 2

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

/datum/fluidtrack
	var/direction=0
	var/basecolor="#ff0000"
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

	/**
	* Add tracks to an existing trail.
	*
	* @param DNA bloodDNA to add to collection.
	* @param comingdir Direction tracks come from, or 0.
	* @param goingdir Direction tracks are going to (or 0).
	* @param bloodcolor Color of the blood when wet.
	*/
	proc/AddTracks(var/list/DNA, var/comingdir, var/goingdir, var/bloodcolor="#ff0000")
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

	process()
		return PROCESS_KILL // Do not process us or we'll lag like hell.

	update_icon()
		// Clear everything.
		overlays.Cut()
		var/truedir=0
		//var/b=0

		var/t=world.time

		/* This shit doesn't work for some reason.
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
			//if(!(updatedtracks&track.direction) && !track.fresh)
			//	continue
			var/stack_idx=setdirs["[track.direction]"]
			var/state=coming_state
			truedir=track.direction
			if(truedir&240) // Check if we're in the GOING block
				state=going_state
				truedir=truedir>>4
			if(track.overlay)
				del(track.overlay)
			var/icon/I = new /icon(icon, icon_state=state, dir=num2dir(truedir))
			I.SwapColor("#000000",track.basecolor);
			// This track is crusty.
			if(track.wet<t)
				I.SetIntensity(0.7)
				track.crusty=1
			track.fresh=0
			track.overlay=I
			stack[stack_idx]=track
			overlays += I
		updatedtracks=0 // Clear our memory of updated tracks.

/obj/effect/decal/cleanable/blood/tracks/footprints
	name = "bloody footprints"
	desc = "Whoops..."
	coming_state = "human1"
	going_state  = "human2"
	amount = 0

/obj/effect/decal/cleanable/blood/tracks/wheels
	name = "bloody tracks"
	desc = "Whoops..."
	coming_state = "wheels"
	going_state  = ""
	desc = "They look like tracks left by wheels."
	gender = PLURAL
	random_icon_states = null
	amount = 0

/obj/effect/decal/cleanable/blood/drip
	name = "drips of blood"
	desc = "It's red."
	gender = PLURAL
	icon = 'icons/effects/drip.dmi'
	icon_state = "1"
	amount = 0

/obj/effect/decal/cleanable/blood/gibs
	name = "gibs"
	desc = "They look bloody and gruesome."
	gender = PLURAL
	density = 0
	anchored = 1
	layer = 2
	icon = 'icons/effects/blood.dmi'
	icon_state = "gibbl5"
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6")

/obj/effect/decal/cleanable/blood/gibs/up
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6","gibup1","gibup1","gibup1")

/obj/effect/decal/cleanable/blood/gibs/down
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6","gibdown1","gibdown1","gibdown1")

/obj/effect/decal/cleanable/blood/gibs/body
	random_icon_states = list("gibhead", "gibtorso")

/obj/effect/decal/cleanable/blood/gibs/limb
	random_icon_states = list("gibleg", "gibarm")

/obj/effect/decal/cleanable/blood/gibs/core
	random_icon_states = list("gibmid1", "gibmid2", "gibmid3")


/obj/effect/decal/cleanable/blood/gibs/proc/streak(var/list/directions)
	spawn (0)
		var/direction = pick(directions)
		for (var/i = 0, i < pick(1, 200; 2, 150; 3, 50; 4), i++)
			sleep(3)
			if (i > 0)
				var/obj/effect/decal/cleanable/blood/b = new /obj/effect/decal/cleanable/blood/splatter(src.loc)
				for(var/datum/disease/D in src.viruses)
					var/datum/disease/ND = D.Copy(1)
					b.viruses += ND
					ND.holder = b

			if (step_to(src, get_step(src, direction), 0))
				break


/obj/effect/decal/cleanable/mucus
	name = "mucus"
	desc = "Disgusting mucus."
	gender = PLURAL
	density = 0
	anchored = 1
	layer = 2
	icon = 'icons/effects/blood.dmi'
	icon_state = "mucus"
	random_icon_states = list("mucus")
	var/list/datum/disease2/disease/virus2 = list()
