GLOBAL_LIST_INIT(pathogen_clouds, list())
GLOBAL_LIST_INIT(science_goggles_wearers, list())

/obj/effect/pathogen_cloud
	name = ""
	icon = 'monkestation/code/modules/virology/icons/96x96.dmi'
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	icon_state = ""
	color = COLOR_GREEN
	pixel_x = -32
	pixel_y = -32
	opacity = 0
	anchored = 0
	density = 0
	var/mob/source = null
	var/sourceIsCarrier = TRUE
	var/list/viruses = list()
	var/lifetime = 10 SECONDS//how long until we naturally disappear, humans breath about every 8 seconds, so it has to survive at least this long to have a chance to infect
	var/turf/target = null//when created, we'll slowly move toward this turf
	var/image/pathogen
	var/core = TRUE
	var/modified = FALSE
	var/moving = TRUE

/obj/effect/pathogen_cloud/New(turf/loc, mob/sourcemob, list/virus, isCarrier = TRUE)
	..()
	if (!loc || !virus || virus.len <= 0)
		qdel(src)
		return

	sourceIsCarrier = isCarrier
	GLOB.pathogen_clouds += src

	pathogen = image('monkestation/code/modules/virology/icons/96x96.dmi',src,"pathogen_airborne")
	pathogen.plane = HUD_PLANE
	pathogen.appearance_flags = RESET_COLOR|RESET_ALPHA
	for (var/mob/living/L as anything in GLOB.science_goggles_wearers)
		if (L.client)
			L.client.images |= pathogen

	source = sourcemob
	viruses = virus
	addtimer(CALLBACK(src, PROC_REF(delete_self)), lifetime)

/obj/effect/pathogen_cloud/proc/delete_self()
	qdel(src)

/obj/effect/pathogen_cloud/Destroy()
	if (pathogen)
		for (var/mob/living/L in GLOB.science_goggles_wearers)
			if (L.client)
				L.client.images -= pathogen
		pathogen = null
	GLOB.pathogen_clouds -= src
	source = null
	viruses = list()
	lifetime = 3
	target = null
	..()

/obj/effect/pathogen_cloud/core/New(turf/loc, mob/sourcemob, list/virus)
	..()
	if (!loc || !virus || virus.len <= 0)
		return

	var/strength = 0
	for (var/datum/disease/advanced/V as anything in viruses)
		strength += V.infectionchance
	strength = round(strength/viruses.len)
	var/list/possible_turfs = list()
	for (var/turf/T in range(max(0,(strength/20)-1),loc))//stronger viruses can reach turfs further away.
		possible_turfs += T
	target = pick(possible_turfs)
	spawn()
		sleep (1 SECONDS)
		while (src && src.loc)
			if (src.loc != target)

				//If we come across other pathogenic clouds, we absorb their diseases that we don't have, then delete those clouds
				//This should prevent mobs breathing in hundreds of clouds at once
				for (var/obj/effect/pathogen_cloud/other_C in src.loc)
					if (!other_C.core)
						for (var/datum/disease/advanced/B as anything in viruses)
							for(var/datum/disease/advanced/V as anything in other_C.viruses)
								if("[B.uniqueID]-[B.subID]" == "[V.uniqueID]-[V.subID]")
									continue
								viruses |= V.Copy()
								modified = TRUE
						qdel(other_C)

				var/obj/effect/pathogen_cloud/C = new /obj/effect/pathogen_cloud(src.loc, source, viruses, sourceIsCarrier)
				C.core = FALSE
				C.modified = modified
				C.moving = FALSE

				if (prob(75))
					step_towards(src,target)
				else
					step_rand(src)
				sleep (1 SECONDS)
			else
				for (var/obj/effect/pathogen_cloud/core/other_C in src.loc)
					if (!other_C.moving)
						for (var/datum/disease/advanced/B as anything in viruses)
							for(var/datum/disease/advanced/V as anything in other_C.viruses)
								if("[B.uniqueID]-[B.subID]" == "[V.uniqueID]-[V.subID]")
									continue
								viruses |= V.Copy()
								modified = TRUE
						qdel(other_C)
				moving = FALSE
