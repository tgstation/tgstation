/obj/effect/landmark
	name = "landmark"
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "x2"
	anchored = 1
	invisibility = INVISIBILITY_ABSTRACT

/obj/effect/landmark/New()
	..()
	tag = text("landmark*[]", name)
	landmarks_list += src

	switch(name)			//some of these are probably obsolete
		if("start")
			newplayer_start += loc
			qdel(src)
			return
		if("wizard")
			wizardstart += loc
			qdel(src)
			return
		if("JoinLate")
			latejoin += loc
			qdel(src)
			return
		if("prisonwarp")
			prisonwarp += loc
			qdel(src)
			return
		if("Holding Facility")
			holdingfacility += loc
		if("tdome1")
			tdome1	+= loc
		if("tdome2")
			tdome2 += loc
		if("tdomeadmin")
			tdomeadmin	+= loc
		if("tdomeobserve")
			tdomeobserve += loc
		if("prisonsecuritywarp")
			prisonsecuritywarp += loc
			qdel(src)
			return
		if("blobstart")
			blobstart += loc
			qdel(src)
			return
		if("secequipment")
			secequipment += loc
			qdel(src)
			return
		if("Emergencyresponseteam")
			emergencyresponseteamspawn += loc
			qdel(src)
			return
		if("xeno_spawn")
			xeno_spawn += loc
			qdel(src)
			return
	return 1

/obj/effect/landmark/Destroy()
	landmarks_list -= src
	return ..()

/obj/effect/landmark/start
	name = "start"
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "x"
	anchored = 1

/obj/effect/landmark/start/New()
	start_landmarks_list += src
	..()
	if(name != initial(name))
		tag = "start*[name]"
	return 1

/obj/effect/landmark/start/Destroy()
	start_landmarks_list -= src
	return ..()

//Department Security spawns

/obj/effect/landmark/start/depsec
	name = "department_sec"

/obj/effect/landmark/start/depsec/New()
	..()
	department_security_spawns += src

/obj/effect/landmark/start/depsec/Destroy()
	department_security_spawns -= src
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
	generic_event_spawns += src

/obj/effect/landmark/event_spawn/Destroy()
	generic_event_spawns -= src
	return ..()

/obj/effect/landmark/ruin
	var/datum/map_template/ruin/ruin_template

/obj/effect/landmark/ruin/New(loc, my_ruin_template)
	name = "ruin_[ruin_landmarks.len + 1]"
	..(loc)
	ruin_template = my_ruin_template
	ruin_landmarks |= src

/obj/effect/landmark/ruin/Destroy()
	ruin_landmarks -= src
	ruin_template = null
	. = ..()
