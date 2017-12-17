/obj/effect/landmark
	name = "landmark"
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "x2"
	anchored = TRUE
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
	icon = 'icons/mob/roles.dmi'
	icon_state = "x"
	anchored = TRUE
	var/jobspawn_override = FALSE
	var/delete_after_roundstart = TRUE

/obj/effect/landmark/start/New()
	GLOB.start_landmarks_list += src
	if(jobspawn_override)
		if(!GLOB.jobspawn_overrides[name])
			GLOB.jobspawn_overrides[name] = list()
		GLOB.jobspawn_overrides[name] += src
	..()
	if(name != "start")
		tag = "start*[name]"

/obj/effect/landmark/start/Destroy()
	GLOB.start_landmarks_list -= src
	if(jobspawn_override)
		GLOB.jobspawn_overrides[name] -= src
	return ..()

// START LANDMARKS FOLLOW. Don't change the names unless
// you are refactoring shitty landmark code.

/obj/effect/landmark/start/assistant
	name = "Assistant"
	icon_state = "assistant"

/obj/effect/landmark/start/assistant/override
	jobspawn_override = TRUE
	delete_after_roundstart = FALSE

/obj/effect/landmark/start/janitor
	name = "Janitor"
	icon_state = "janitor"

/obj/effect/landmark/start/cargo_technician
	name = "Cargo Technician"
	icon_state = "cargotech"

/obj/effect/landmark/start/bartender
	name = "Bartender"
	icon_state = "bartender"

/obj/effect/landmark/start/clown
	name = "Clown"
	icon_state = "clown"

/obj/effect/landmark/start/mime
	name = "Mime"
	icon_state = "mime"

/obj/effect/landmark/start/quartermaster
	name = "Quartermaster"
	icon_state = "qm"

/obj/effect/landmark/start/atmospheric_technician
	name = "Atmospheric Technician"
	icon_state = "atmostech"

/obj/effect/landmark/start/cook
	name = "Cook"
	icon_state = "cook"

/obj/effect/landmark/start/shaft_miner
	name = "Shaft Miner"
	icon_state = "shaftminer"

/obj/effect/landmark/start/security_officer
	name = "Security Officer"
	icon_state = "securityofficer"

/obj/effect/landmark/start/botanist
	name = "Botanist"
	icon_state = "botanist"

/obj/effect/landmark/start/head_of_security
	name = "Head of Security"
	icon_state = "hos"

/obj/effect/landmark/start/ai
	name = "AI"
	delete_after_roundstart = FALSE

/obj/effect/landmark/start/captain
	name = "Captain"
	icon_state = "captain"

/obj/effect/landmark/start/detective
	name = "Detective"
	icon_state = "detective"

/obj/effect/landmark/start/warden
	name = "Warden"
	icon_state = "warden"

/obj/effect/landmark/start/chief_engineer
	name = "Chief Engineer"
	icon_state = "ce"

/obj/effect/landmark/start/cyborg
	name = "Cyborg"

/obj/effect/landmark/start/head_of_personnel
	name = "Head of Personnel"
	icon_state = "hop"

/obj/effect/landmark/start/librarian
	name = "Curator"
	icon_state = "curator"

/obj/effect/landmark/start/lawyer
	name = "Lawyer"
	icon_state = "lawyer"

/obj/effect/landmark/start/station_engineer
	name = "Station Engineer"
	icon_state = "engineer"

/obj/effect/landmark/start/medical_doctor
	name = "Medical Doctor"
	icon_state = "medicaldoctor"

/obj/effect/landmark/start/scientist
	name = "Scientist"
	icon_state = "scientist"

/obj/effect/landmark/start/chemist
	name = "Chemist"
	icon_state = "chemist"

/obj/effect/landmark/start/roboticist
	name = "Roboticist"
	icon_state = "roboticist"

/obj/effect/landmark/start/research_director
	name = "Research Director"
	icon_state = "rd"

/obj/effect/landmark/start/geneticist
	name = "Geneticist"
	icon_state = "geneticist"

/obj/effect/landmark/start/chief_medical_officer
	name = "Chief Medical Officer"
	icon_state = "cmo"

/obj/effect/landmark/start/virologist
	name = "Virologist"
	icon_state = "virologist"

/obj/effect/landmark/start/chaplain
	name = "Chaplain"
	icon_state = "chaplain"

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

/obj/effect/landmark/start/wizard/Initialize()
	..()
	GLOB.wizardstart += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/start/nukeop
	name = "nukeop"

/obj/effect/landmark/start/nukeop/Initialize()
	..()
	GLOB.nukeop_start += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/start/nukeop_leader
	name = "nukeop leader"

/obj/effect/landmark/start/nukeop_leader/Initialize()
	..()
	GLOB.nukeop_leader_start += loc
	return INITIALIZE_HINT_QDEL

// Must be immediate because players will
// join before SSatom initializes everything.
INITIALIZE_IMMEDIATE(/obj/effect/landmark/start/new_player)

/obj/effect/landmark/start/new_player
	name = "New Player"

/obj/effect/landmark/start/new_player/Initialize()
	..()
	GLOB.newplayer_start += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/latejoin
	name = "JoinLate"

/obj/effect/landmark/latejoin/Initialize(mapload)
	..()
	SSjob.latejoin_trackers += loc
	return INITIALIZE_HINT_QDEL

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

// xenos.
/obj/effect/landmark/xeno_spawn
	name = "xeno_spawn"

/obj/effect/landmark/xeno_spawn/Initialize(mapload)
	..()
	GLOB.xeno_spawn += loc
	return INITIALIZE_HINT_QDEL

// blobs.
/obj/effect/landmark/blobstart
	name = "blobstart"

/obj/effect/landmark/blobstart/Initialize(mapload)
	..()
	GLOB.blobstart += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/secequipment
	name = "secequipment"

/obj/effect/landmark/secequipment/Initialize(mapload)
	..()
	GLOB.secequipment += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/prisonwarp
	name = "prisonwarp"

/obj/effect/landmark/prisonwarp/Initialize(mapload)
	..()
	GLOB.prisonwarp += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/ert_spawn
	name = "Emergencyresponseteam"

/obj/effect/landmark/ert_spawn/Initialize(mapload)
	..()
	GLOB.emergencyresponseteamspawn += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/holding_facility
	name = "Holding Facility"

/obj/effect/landmark/holding_facility/Initialize(mapload)
	..()
	GLOB.holdingfacility += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/thunderdome/observe
	name = "tdomeobserve"

/obj/effect/landmark/thunderdome/observe/Initialize(mapload)
	..()
	GLOB.tdomeobserve += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/thunderdome/one
	name = "tdome1"

/obj/effect/landmark/thunderdome/one/Initialize(mapload)
	..()
	GLOB.tdome1	+= loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/thunderdome/two
	name = "tdome2"

/obj/effect/landmark/thunderdome/two/Initialize(mapload)
	..()
	GLOB.tdome2 += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/thunderdome/admin
	name = "tdomeadmin"

/obj/effect/landmark/thunderdome/admin/Initialize(mapload)
	..()
	GLOB.tdomeadmin += loc
	return INITIALIZE_HINT_QDEL

//Servant spawn locations
/obj/effect/landmark/servant_of_ratvar
	name = "servant of ratvar spawn"

/obj/effect/landmark/servant_of_ratvar/Initialize(mapload)
	..()
	GLOB.servant_spawns += loc
	return INITIALIZE_HINT_QDEL

//City of Cogs entrances
/obj/effect/landmark/city_of_cogs
	name = "city of cogs entrance"
	icon_state = "x4"

/obj/effect/landmark/city_of_cogs/Initialize(mapload)
	..()
	GLOB.city_of_cogs_spawns += loc
	return INITIALIZE_HINT_QDEL

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
