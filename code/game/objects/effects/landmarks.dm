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
		if("Emergencyresponseteam")
			emergencyresponseteamspawn += loc
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
	if(name != "start")
		tag = "start*[name]"
	return 1

/obj/effect/landmark/start/Destroy()
	start_landmarks_list -= src
	return ..()

// START LANDMARKS FOLLOW. Don't change the names unless
// you are refactoring shitty landmark code.

/obj/effect/landmark/start/assistant
	name = "Assistant"

/obj/effect/landmark/start/janitor
	name = "Janitor"

/obj/effect/landmark/start/cargo_technician
	name = "Cargo Technician"

/obj/effect/landmark/start/bartender
	name = "Bartender"

/obj/effect/landmark/start/clown
	name = "Clown"

/obj/effect/landmark/start/mime
	name = "Mime"

/obj/effect/landmark/start/quartermaster
	name = "Quartermaster"

/obj/effect/landmark/start/atmospheric_technician
	name = "Atmospheric Technician"

/obj/effect/landmark/start/chef
	name = "Chef"

/obj/effect/landmark/start/shaft_miner
	name = "Shaft Miner"

/obj/effect/landmark/start/security_officer
	name = "Security Officer"

/obj/effect/landmark/start/botanist
	name = "Botanist"

/obj/effect/landmark/start/head_of_security
	name = "Head of Security"

/obj/effect/landmark/start/ai
	name = "AI"

/obj/effect/landmark/start/captain
	name = "Captain"

/obj/effect/landmark/start/detective
	name = "Detective"

/obj/effect/landmark/start/warden
	name = "Warden"

/obj/effect/landmark/start/chief_engineer
	name = "Chief Engineer"

/obj/effect/landmark/start/cyborg
	name = "Cyborg"

/obj/effect/landmark/start/head_of_personnel
	name = "Head of Personnel"

/obj/effect/landmark/start/librarian
	name = "Librarian"

/obj/effect/landmark/start/lawyer
	name = "Lawyer"

/obj/effect/landmark/start/station_engineer
	name = "Station Engineer"

/obj/effect/landmark/start/medical_doctor
	name = "Medical Doctor"

/obj/effect/landmark/start/scientist
	name = "Scientist"

/obj/effect/landmark/start/chemist
	name = "Chemist"

/obj/effect/landmark/start/roboticist
	name = "Roboticist"

/obj/effect/landmark/start/research_director
	name = "Research Director"

/obj/effect/landmark/start/geneticist
	name = "Geneticist"

/obj/effect/landmark/start/chief_medical_officer
	name = "Chief Medical Officer"

/obj/effect/landmark/start/virologist
	name = "Virologist"

/obj/effect/landmark/start/chaplain
	name = "Chaplain"

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

/obj/effect/landmark/latejoin/Initialize(mapload)
	..()
	latejoin += loc
	qdel(src)

// carp.
/obj/effect/landmark/carpspawn
	name = "carpspawn"

// lightsout.
/obj/effect/landmark/lightsout
	name = "lightsout"

// observer-start.
/obj/effect/landmark/observer_start
	name = "Observer-Start"

// revenant spawn.
/obj/effect/landmark/revenantspawn
	name = "revnantspawn"

// triple ais.
/obj/effect/landmark/tripai
	name = "tripai"

// marauder entry (XXX WTF IS MAURADER ENTRY???)

/obj/effect/landmark/marauder_entry
	name = "Marauder Entry"

// syndicate breach area (XXX I DON'T KNOW WHAT THIS IS EITHER)

/obj/effect/landmark/syndicate_breach_area
	name = "Syndicate Breach Area"

// xenos.
/obj/effect/landmark/xeno_spawn
	name = "xeno_spawn"

/obj/effect/landmark/xeno_spawn/Initialize(mapload)
	..()
	xeno_spawn += loc
	qdel(src)

// blobs.
/obj/effect/landmark/blobstart
	name = "blobstart"

/obj/effect/landmark/blobstart/Initialize(mapload)
	..()
	blobstart += loc
	qdel(src)

/obj/effect/landmark/secequipment
	name = "secequipment"

/obj/effect/landmark/secequipment/Initialize(mapload)
	..()
	secequipment += loc
	qdel(src)

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
