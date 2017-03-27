/obj/effect/landmark
	name = "landmark"
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "x2"
	anchored = 1
	invisibility = INVISIBILITY_ABSTRACT

/obj/effect/landmark/New()
	..()
	tag = text("landmark*[]", name)
	GLOB.landmarks_list += src

	switch(name)			//some of these are probably obsolete
		if("monkey")
			GLOB.monkeystart += loc
			qdel(src)
			return
		if("start")
			GLOB.newplayer_start += loc
			qdel(src)
			return
		if("wizard")
			GLOB.wizardstart += loc
			qdel(src)
			return
		if("JoinLate")
			GLOB.latejoin += loc
			qdel(src)
			return
		if("prisonwarp")
			GLOB.prisonwarp += loc
			qdel(src)
			return
		if("Holding Facility")
			GLOB.holdingfacility += loc
		if("tdome1")
			GLOB.tdome1	+= loc
		if("tdome2")
			GLOB.tdome2 += loc
		if("tdomeadmin")
			GLOB.tdomeadmin	+= loc
		if("tdomeobserve")
			GLOB.tdomeobserve += loc
		if("prisonsecuritywarp")
			GLOB.prisonsecuritywarp += loc
			qdel(src)
			return
		if("blobstart")
			GLOB.blobstart += loc
			qdel(src)
			return
		if("secequipment")
			GLOB.secequipment += loc
			qdel(src)
			return
		if("Emergencyresponseteam")
			GLOB.emergencyresponseteamspawn += loc
			qdel(src)
			return
		if("xeno_spawn")
			GLOB.xeno_spawn += loc
			qdel(src)
			return
	return 1

/obj/effect/landmark/Destroy()
	GLOB.landmarks_list -= src
	return ..()

/obj/effect/landmark/start
	name = "start"
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "x"
	anchored = 1

/obj/effect/landmark/start/New()
	GLOB.start_landmarks_list += src
	..()
	if(name != initial(name))
		tag = "start*[name]"
	return 1

/obj/effect/landmark/start/Destroy()
	GLOB.start_landmarks_list -= src
	return ..()

//Department Security spawns

/obj/effect/landmark/start/depsec
	name = "department_sec"

/obj/effect/landmark/start/depsec/New()
	..()
	GLOB.department_security_spawns += src

/obj/effect/landmark/start/depsec/Destroy()
	GLOB.department_security_spawns -= src
	return ..()

/obj/effect/landmark/start/depsec/supply
	name = "supply_sec"

/obj/effect/landmark/start/depsec/medical
	name = "medical_sec"

/obj/effect/landmark/start/depsec/engineering
	name = "engineering_sec"

/obj/effect/landmark/start/depsec/science
	name = "science_sec"

/obj/effect/landmark/latejoin
	name = "JoinLate"

//generic event spawns
/obj/effect/landmark/event_spawn
	name = "generic event spawn"
	icon_state = "x4"

/obj/effect/landmark/event_spawn/New()
	..()
	GLOB.generic_event_spawns += src

/obj/effect/landmark/event_spawn/Destroy()
	GLOB.generic_event_spawns -= src
	return ..()

/obj/effect/landmark/ruin
	var/datum/map_template/ruin/ruin_template

/obj/effect/landmark/ruin/New(loc, my_ruin_template)
	name = "ruin_[GLOB.ruin_landmarks.len + 1]"
	..(loc)
	ruin_template = my_ruin_template
	GLOB.ruin_landmarks |= src

/obj/effect/landmark/ruin/Destroy()
	GLOB.ruin_landmarks -= src
	ruin_template = null
	. = ..()
