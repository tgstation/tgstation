//Yes, hi. This is the file that handles Citadel's turf modifications.

//But before we touch turfs, we'll take some time to define a couple of things for footstep sounds.
/mob/living
	var/makesfootstepsounds
	var/footstepcount

/mob/living/carbon/human
	makesfootstepsounds = TRUE

/atom
	var/footstepsoundoverride

//All of these sounds are from CEV Eris as of 11/25/2017, the time when the original PR adding footstep sounds was made.
GLOBAL_LIST_INIT(turf_footstep_sounds, list(
				"floor" = list('modular_citadel/sound/footstep/floor1.ogg','modular_citadel/sound/footstep/floor2.ogg','modular_citadel/sound/footstep/floor3.ogg','modular_citadel/sound/footstep/floor4.ogg','modular_citadel/sound/footstep/floor5.ogg'),
				"plating" = list('modular_citadel/sound/footstep/plating1.ogg','modular_citadel/sound/footstep/plating2.ogg','modular_citadel/sound/footstep/plating3.ogg','modular_citadel/sound/footstep/plating4.ogg','modular_citadel/sound/footstep/plating5.ogg'),
				"wood" = list('modular_citadel/sound/footstep/wood1.ogg','modular_citadel/sound/footstep/wood2.ogg','modular_citadel/sound/footstep/wood3.ogg','modular_citadel/sound/footstep/wood4.ogg','modular_citadel/sound/footstep/wood5.ogg'),
				"carpet" = list('modular_citadel/sound/footstep/carpet1.ogg','modular_citadel/sound/footstep/carpet2.ogg','modular_citadel/sound/footstep/carpet3.ogg','modular_citadel/sound/footstep/carpet4.ogg','modular_citadel/sound/footstep/carpet5.ogg'),
				"hull" = list('modular_citadel/sound/footstep/hull1.ogg','modular_citadel/sound/footstep/hull2.ogg','modular_citadel/sound/footstep/hull3.ogg','modular_citadel/sound/footstep/hull4.ogg','modular_citadel/sound/footstep/hull5.ogg'),
				"catwalk" = list('modular_citadel/sound/footstep/catwalk1.ogg','modular_citadel/sound/footstep/catwalk2.ogg','modular_citadel/sound/footstep/catwalk3.ogg','modular_citadel/sound/footstep/catwalk4.ogg','modular_citadel/sound/footstep/catwalk5.ogg'),
				"asteroid" = list('modular_citadel/sound/footstep/asteroid1.ogg','modular_citadel/sound/footstep/asteroid2.ogg','modular_citadel/sound/footstep/asteroid3.ogg','modular_citadel/sound/footstep/asteroid4.ogg','modular_citadel/sound/footstep/asteroid5.ogg')
				))

/turf/open
	var/footstepsounds

/turf/open/floor
	footstepsounds = "floor"

/turf/open/floor/plating
	footstepsounds = "plating"

/turf/open/floor/wood
	footstepsounds = "wood"

/turf/open/floor/plating/asteroid
	footstepsounds = "asteroid"

/turf/open/floor/plating/dirt
	footstepsounds = "asteroid"

/turf/open/floor/grass
	footstepsounds = "asteroid"

/turf/open/floor/carpet
	footstepsounds = "carpet"

/turf/open/floor/plasteel/grimy
	footstepsounds = "carpet"

/obj/machinery/atmospherics/components/unary/vent_pump
	footstepsoundoverride = "catwalk"

/obj/machinery/atmospherics/components/unary/vent_scrubber
	footstepsoundoverride = "catwalk"

/obj/structure/disposalpipe
	footstepsoundoverride = "catwalk"

/obj/machinery/holopad
	footstepsoundoverride = "catwalk"

/obj/structure/table
	footstepsoundoverride = "hull"

/obj/structure/table/wood
	footstepsoundoverride = "wood"

/*
/turf/open/floor/Entered(atom/obj, atom/oldloc)
	. = ..()
	CitDirtify(obj, oldloc)*/

//Baystation-styled tile dirtification.
/turf/open/floor/proc/CitDirtify(atom/obj, atom/oldloc)
	if(prob(50))
		if(has_gravity(src) && !isobserver(obj))
			var/dirtamount
			var/obj/effect/decal/cleanable/dirt/dirt = locate(/obj/effect/decal/cleanable/dirt, src)
			if(!dirt)
				dirt = new/obj/effect/decal/cleanable/dirt(src)
				dirt.alpha = 0
				dirtamount = 0
			dirtamount = dirt.alpha + 1
			if(oldloc && istype(oldloc, /turf/open/floor))
				var/obj/effect/decal/cleanable/dirt/spreadindirt = locate(/obj/effect/decal/cleanable/dirt, oldloc)
				if(spreadindirt && spreadindirt.alpha)
					dirtamount += round(spreadindirt.alpha * 0.05)
			dirt.alpha = min(dirtamount,255)
	return TRUE

//The proc that handles footsteps! It's pure, unfiltered spaghetti code.
/mob/living/proc/CitFootstep(turf/open/floor)
	if(floor && istype(floor,/turf/open) && floor.footstepsounds)
		if(has_gravity(floor) || prob(25))
			footstepcount++
		if(canmove && !lying && !buckled && makesfootstepsounds && m_intent == MOVE_INTENT_RUN && footstepcount >= 3)
			footstepcount = 0
			var/overriddenfootstepsound
			if(footstepsoundoverride)
				if(isfile(footstepsoundoverride))
					overriddenfootstepsound = list(footstepsoundoverride)
				else
					overriddenfootstepsound = footstepsoundoverride
			if(!overriddenfootstepsound && istype(src, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = src
				if(H && H.shoes)
					var/obj/item/clothing/shoes/S = H.shoes
					if(S && S.footstepsoundoverride)
						if(isfile(S.footstepsoundoverride))
							overriddenfootstepsound = list(S.footstepsoundoverride)
						else
							overriddenfootstepsound = S.footstepsoundoverride
			if(!overriddenfootstepsound && floor.contents)
				var/objschecked
				for(var/atom/childobj in floor.contents)
					if(childobj.footstepsoundoverride && childobj.invisibility < INVISIBILITY_MAXIMUM)
						if(isfile(childobj.footstepsoundoverride))
							overriddenfootstepsound = list(childobj.footstepsoundoverride)
						else
							overriddenfootstepsound = childobj.footstepsoundoverride
						break
					objschecked++
					if(objschecked >= 25)
						break //walking on 50k foam darts didn't crash the server during my testing, but its better to be safe than sorry
			playsound(src,(overriddenfootstepsound ? (islist(overriddenfootstepsound) ? pick(overriddenfootstepsound) : pick(GLOB.turf_footstep_sounds[overriddenfootstepsound])) : (islist(floor.footstepsounds) ? pick(floor.footstepsounds) : pick(GLOB.turf_footstep_sounds[floor.footstepsounds]))),50, 1)
