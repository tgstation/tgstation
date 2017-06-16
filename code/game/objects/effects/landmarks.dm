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
	if(name != "start")
		tag = "start*[name]"

/obj/effect/landmark/start/Destroy()
	GLOB.start_landmarks_list -= src
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

/obj/effect/landmark/start/cook
	name = "Cook"

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
	name = "Curator"

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

/obj/effect/landmark/start/wizard
	name = "wizard"

/obj/effect/landmark/start/wizard/Initialize(mapload)
	..()
	GLOB.wizardstart += loc
	qdel(src)

/obj/effect/landmark/start/new_player
	name = "New Player"

// Must be on New() rather than Initialize, because players will
// join before SSatom initializes everything.
/obj/effect/landmark/start/new_player/New(loc)
	..()
	GLOB.newplayer_start += loc

/obj/effect/landmark/start/new_player/Initialize(mapload)
	..()
	qdel(src)



/obj/effect/landmark/latejoin
	name = "JoinLate"

/obj/effect/landmark/latejoin/Initialize(mapload)
	..()
	SSjob.latejoin_trackers += loc
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

// teleport scroll landmark, XXX DOES THIS DO ANYTHING?
/obj/effect/landmark/teleport_scroll
	name = "Teleport-Scroll"

/obj/effect/landmark/syndicate_spawn
	name = "Syndicate-Spawn"

// xenos.
/obj/effect/landmark/xeno_spawn
	name = "xeno_spawn"

/obj/effect/landmark/xeno_spawn/Initialize(mapload)
	..()
	GLOB.xeno_spawn += loc
	qdel(src)

// blobs.
/obj/effect/landmark/blobstart
	name = "blobstart"

/obj/effect/landmark/blobstart/Initialize(mapload)
	..()
	GLOB.blobstart += loc
	qdel(src)

/obj/effect/landmark/secequipment
	name = "secequipment"

/obj/effect/landmark/secequipment/Initialize(mapload)
	..()
	GLOB.secequipment += loc
	qdel(src)

/obj/effect/landmark/prisonwarp
	name = "prisonwarp"

/obj/effect/landmark/prisonwarp/Initialize(mapload)
	..()
	GLOB.prisonwarp += loc
	qdel(src)

/obj/effect/landmark/ert_spawn
	name = "Emergencyresponseteam"

/obj/effect/landmark/ert_spawn/Initialize(mapload)
	..()
	GLOB.emergencyresponseteamspawn += loc
	qdel(src)

/obj/effect/landmark/holding_facility
	name = "Holding Facility"

/obj/effect/landmark/holding_facility/Initialize(mapload)
	..()
	GLOB.holdingfacility += loc
	qdel(src)

/obj/effect/landmark/thunderdome/observe
	name = "tdomeobserve"

/obj/effect/landmark/thunderdome/observe/Initialize(mapload)
	..()
	GLOB.tdomeobserve += loc
	qdel(src)

/obj/effect/landmark/thunderdome/one
	name = "tdome1"

/obj/effect/landmark/thunderdome/one/Initialize(mapload)
	..()
	GLOB.tdome1	+= loc
	qdel(src)

/obj/effect/landmark/thunderdome/two
	name = "tdome2"

/obj/effect/landmark/thunderdome/two/Initialize(mapload)
	..()
	GLOB.tdome2 += loc
	qdel(src)

/obj/effect/landmark/thunderdome/admin
	name = "tdomeadmin"

/obj/effect/landmark/thunderdome/admin/Initialize(mapload)
	..()
	GLOB.tdomeadmin += loc
	qdel(src)

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
