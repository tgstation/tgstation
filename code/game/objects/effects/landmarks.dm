/obj/effect/landmark
	name = "landmark"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "x2"
	anchored = TRUE
	layer = OBJ_LAYER
	plane = GAME_PLANE
	invisibility = INVISIBILITY_ABSTRACT
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/effect/landmark/singularity_act()
	return

/obj/effect/landmark/singularity_pull()
	return

INITIALIZE_IMMEDIATE(/obj/effect/landmark)

/obj/effect/landmark/Initialize(mapload)
	. = ..()
	GLOB.landmarks_list += src

/obj/effect/landmark/Destroy()
	GLOB.landmarks_list -= src
	return ..()

/obj/effect/landmark/start
	name = "start"
	icon = 'icons/mob/landmarks.dmi'
	icon_state = "x"
	anchored = TRUE
	layer = MOB_LAYER
	var/jobspawn_override = FALSE
	var/delete_after_roundstart = TRUE
	var/used = FALSE

/obj/effect/landmark/start/proc/after_round_start()
	// We'd like to keep these around for unit tests, so we can check that they exist.
#ifndef UNIT_TESTS
	if(delete_after_roundstart)
		qdel(src)
#endif

/obj/effect/landmark/start/Initialize(mapload)
	. = ..()
	GLOB.start_landmarks_list += src
	if(jobspawn_override)
		LAZYADDASSOCLIST(GLOB.jobspawn_overrides, name, src)
	if(name != "start")
		tag = "start*[name]"

/obj/effect/landmark/start/Destroy()
	GLOB.start_landmarks_list -= src
	if(jobspawn_override)
		LAZYREMOVEASSOC(GLOB.jobspawn_overrides, name, src)
	return ..()

// START LANDMARKS FOLLOW. Don't change the names unless
// you are refactoring shitty landmark code.
/obj/effect/landmark/start/assistant
	name = JOB_ASSISTANT
	icon_state = JOB_ASSISTANT //icon_state is case sensitive. why are all of these capitalized? because fuck you that's why

/obj/effect/landmark/start/assistant/override
	jobspawn_override = TRUE
	delete_after_roundstart = FALSE

/obj/effect/landmark/start/prisoner
	name = "Prisoner"
	icon_state = "Prisoner"

/obj/effect/landmark/start/janitor
	name = "Janitor"
	icon_state = "Janitor"

/obj/effect/landmark/start/cargo_technician
	name = "Cargo Technician"
	icon_state = "Cargo Technician"

/obj/effect/landmark/start/bartender
	name = "Bartender"
	icon_state = "Bartender"

/obj/effect/landmark/start/clown
	name = "Clown"
	icon_state = "Clown"

/obj/effect/landmark/start/mime
	name = "Mime"
	icon_state = "Mime"

/obj/effect/landmark/start/quartermaster
	name = "Quartermaster"
	icon_state = "Quartermaster"

/obj/effect/landmark/start/atmospheric_technician
	name = "Atmospheric Technician"
	icon_state = "Atmospheric Technician"

/obj/effect/landmark/start/cook
	name = "Cook"
	icon_state = "Cook"

/obj/effect/landmark/start/shaft_miner
	name = "Shaft Miner"
	icon_state = "Shaft Miner"

/obj/effect/landmark/start/security_officer
	name = "Security Officer"
	icon_state = "Security Officer"

/obj/effect/landmark/start/botanist
	name = "Botanist"
	icon_state = "Botanist"

/obj/effect/landmark/start/head_of_security
	name = "Head of Security"
	icon_state = "Head of Security"

/obj/effect/landmark/start/captain
	name = "Captain"
	icon_state = "Captain"

/obj/effect/landmark/start/detective
	name = "Detective"
	icon_state = "Detective"

/obj/effect/landmark/start/warden
	name = "Warden"
	icon_state = "Warden"

/obj/effect/landmark/start/chief_engineer
	name = "Chief Engineer"
	icon_state = "Chief Engineer"

/obj/effect/landmark/start/head_of_personnel
	name = "Head of Personnel"
	icon_state = "Head of Personnel"

/obj/effect/landmark/start/librarian
	name = "Curator"
	icon_state = "Curator"

/obj/effect/landmark/start/lawyer
	name = "Lawyer"
	icon_state = "Lawyer"

/obj/effect/landmark/start/station_engineer
	name = "Station Engineer"
	icon_state = "Station Engineer"

/obj/effect/landmark/start/medical_doctor
	name = "Medical Doctor"
	icon_state = "Medical Doctor"

/obj/effect/landmark/start/coroner
	name = "Coroner"
	icon_state = "Coroner"

/obj/effect/landmark/start/paramedic
	name = "Paramedic"
	icon_state = "Paramedic"

/obj/effect/landmark/start/scientist
	name = "Scientist"
	icon_state = "Scientist"

/obj/effect/landmark/start/chemist
	name = "Chemist"
	icon_state = "Chemist"

/obj/effect/landmark/start/roboticist
	name = "Roboticist"
	icon_state = "Roboticist"

/obj/effect/landmark/start/research_director
	name = JOB_RESEARCH_DIRECTOR
	icon_state = JOB_RESEARCH_DIRECTOR

/obj/effect/landmark/start/geneticist
	name = "Geneticist"
	icon_state = "Geneticist"

/obj/effect/landmark/start/chief_medical_officer
	name = "Chief Medical Officer"
	icon_state = "Chief Medical Officer"

/obj/effect/landmark/start/virologist
	name = "Virologist"
	icon_state = "Virologist"

/obj/effect/landmark/start/psychologist
	name = "Psychologist"
	icon_state = "Psychologist"

/obj/effect/landmark/start/chaplain
	name = "Chaplain"
	icon_state = "Chaplain"

/obj/effect/landmark/start/cyborg
	name = "Cyborg"
	icon_state = "Cyborg"

/obj/effect/landmark/start/ai
	name = "AI"
	icon_state = "AI"
	delete_after_roundstart = FALSE
	var/primary_ai = TRUE
	var/latejoin_active = TRUE

/obj/effect/landmark/start/ai/after_round_start()
	if(latejoin_active && !used)
		new /obj/structure/ai_core/latejoin_inactive(loc)
	return ..()

/obj/effect/landmark/start/ai/secondary
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "ai_spawn"
	primary_ai = FALSE
	latejoin_active = FALSE

//Department Security spawns

/obj/effect/landmark/start/depsec
	name = "department_sec"
	icon_state = "Security Officer"
	/// What department this spawner is for
	var/department

/obj/effect/landmark/start/depsec/Initialize(mapload)
	. = ..()
	LAZYADDASSOCLIST(GLOB.department_security_spawns, department, src)

/obj/effect/landmark/start/depsec/Destroy()
	LAZYREMOVEASSOC(GLOB.department_security_spawns, department, src)
	return ..()

/obj/effect/landmark/start/depsec/supply
	name = "supply_sec"
	department = SEC_DEPT_SUPPLY

/obj/effect/landmark/start/depsec/medical
	name = "medical_sec"
	department = SEC_DEPT_MEDICAL

/obj/effect/landmark/start/depsec/engineering
	name = "engineering_sec"
	department = SEC_DEPT_ENGINEERING

/obj/effect/landmark/start/depsec/science
	name = "science_sec"
	department = SEC_DEPT_SCIENCE

//Antagonist spawns

/obj/effect/landmark/start/wizard
	name = "wizard"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "wiznerd_spawn"

/obj/effect/landmark/start/wizard/Initialize(mapload)
	..()
	GLOB.wizardstart += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/start/nukeop
	name = "nukeop"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "snukeop_spawn"

/obj/effect/landmark/start/nukeop/Initialize(mapload)
	..()
	GLOB.nukeop_start += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/start/nukeop_leader
	name = "nukeop leader"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "snukeop_leader_spawn"

/obj/effect/landmark/start/nukeop_leader/Initialize(mapload)
	..()
	GLOB.nukeop_leader_start += loc
	return INITIALIZE_HINT_QDEL

// Must be immediate because players will
// join before SSatom initializes everything.
INITIALIZE_IMMEDIATE(/obj/effect/landmark/start/new_player)

/obj/effect/landmark/start/new_player
	name = "New Player"

/obj/effect/landmark/start/new_player/Initialize(mapload)
	..()
	GLOB.newplayer_start += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/latejoin
	name = "JoinLate"

/obj/effect/landmark/latejoin/Initialize(mapload)
	..()
	SSjob.latejoin_trackers += loc
	return INITIALIZE_HINT_QDEL

//space carps, magicarps, lone ops, slaughter demons, possibly revenants spawn here
/obj/effect/landmark/carpspawn
	name = "carpspawn"
	icon_state = "carp_spawn"

//observer start
/obj/effect/landmark/observer_start
	name = "Observer-Start"
	icon_state = "observer_start"

//generic maintenance locations
/obj/effect/landmark/generic_maintenance_landmark
	name = "generic_maintenance_spawn"
	icon_state = "xeno_spawn"

/obj/effect/landmark/generic_maintenance_landmark/Initialize(mapload)
	..()
	GLOB.generic_maintenance_landmarks += loc
	return INITIALIZE_HINT_QDEL

//objects with the stationloving component (nuke disk) respawn here.
//also blobs that have their spawn forcemoved (running out of time when picking their spawn spot) and santa
/obj/effect/landmark/blobstart
	name = "blobstart"
	icon_state = "blob_start"

/obj/effect/landmark/blobstart/Initialize(mapload)
	..()
	GLOB.blobstart += loc
	return INITIALIZE_HINT_QDEL

//spawns sec equipment lockers depending on the number of sec officers
/obj/effect/landmark/secequipment
	name = "secequipment"
	icon_state = "secequipment"

/obj/effect/landmark/secequipment/Initialize(mapload)
	..()
	GLOB.secequipment += loc
	return INITIALIZE_HINT_QDEL

//players that get put in admin jail show up here
/obj/effect/landmark/prisonwarp
	name = "prisonwarp"
	icon_state = "prisonwarp"

/obj/effect/landmark/prisonwarp/Initialize(mapload)
	..()
	GLOB.prisonwarp += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/ert_spawn
	name = "Emergencyresponseteam"
	icon_state = "ert_spawn"

/obj/effect/landmark/ert_spawn/Initialize(mapload)
	..()
	GLOB.emergencyresponseteamspawn += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/ert_shuttle_spawn
	name = "ertshuttlespawn"
	icon_state = "ert_spawn"

/obj/effect/landmark/ert_shuttle_brief_spawn
	name = "ertshuttlebriefspawn"
	icon_state = "ert_brief_spawn"

//ninja energy nets teleport victims here
/obj/effect/landmark/holding_facility
	name = "Holding Facility"
	icon_state = "holding_facility"

/obj/effect/landmark/holding_facility/Initialize(mapload)
	..()
	GLOB.holdingfacility += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/thunderdome/observe
	name = "tdomeobserve"
	icon_state = "tdome_observer"

/obj/effect/landmark/thunderdome/observe/Initialize(mapload)
	..()
	GLOB.tdomeobserve += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/thunderdome/one
	name = "tdome1"
	icon_state = "tdome_t1"

/obj/effect/landmark/thunderdome/one/Initialize(mapload)
	..()
	GLOB.tdome1 += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/thunderdome/two
	name = "tdome2"
	icon_state = "tdome_t2"

/obj/effect/landmark/thunderdome/two/Initialize(mapload)
	..()
	GLOB.tdome2 += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/thunderdome/admin
	name = "tdomeadmin"
	icon_state = "tdome_admin"

/obj/effect/landmark/thunderdome/admin/Initialize(mapload)
	..()
	GLOB.tdomeadmin += loc
	return INITIALIZE_HINT_QDEL

/**
 * Generic event spawn points
 *
 * These are placed in locales where there are likely to be players, and places which are identifiable at a glance -
 * Such as public hallways, department rooms, head of staff offices, and non-generic maintenance locations
 *
 * Used in events to cause effects in locations where it is likely to effect players
 */
/obj/effect/landmark/event_spawn
	name = "generic event spawn"
	icon_state = "generic_event"

/obj/effect/landmark/event_spawn/Initialize(mapload)
	. = ..()
	GLOB.generic_event_spawns += src

/obj/effect/landmark/event_spawn/Destroy()
	GLOB.generic_event_spawns -= src
	return ..()

/obj/effect/landmark/ruin
	var/datum/map_template/ruin/ruin_template

/obj/effect/landmark/ruin/Initialize(mapload, my_ruin_template)
	. = ..()
	name = "ruin_[GLOB.ruin_landmarks.len + 1]"
	ruin_template = my_ruin_template
	GLOB.ruin_landmarks |= src

/obj/effect/landmark/ruin/Destroy()
	GLOB.ruin_landmarks -= src
	ruin_template = null
	. = ..()

// handled in portals.dm, id connected to one-way portal
/obj/effect/landmark/portal_exit
	name = "portal exit"
	icon_state = "portal_exit"
	var/id

/// Marks the bottom left of the testing zone.
/// In landmarks.dm and not unit_test.dm so it is always active in the mapping tools.
/obj/effect/landmark/unit_test_bottom_left
	name = "unit test zone bottom left"

/// Marks the top right of the testing zone.
/// In landmarks.dm and not unit_test.dm so it is always active in the mapping tools.
/obj/effect/landmark/unit_test_top_right
	name = "unit test zone top right"


/obj/effect/landmark/start/hangover
	name = "hangover spawn"
	icon_state = "hangover_spawn"

	/// A list of everything this hangover spawn created as part of the hangover station trait
	var/list/hangover_debris = list()

	/// A list of everything this hangover spawn created as part of the birthday station trait
	var/list/party_debris = list()

/obj/effect/landmark/start/hangover/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/landmark/start/hangover/Destroy()
	hangover_debris = null
	party_debris = null
	return ..()

/obj/effect/landmark/start/hangover/LateInitialize()
	. = ..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_BIRTHDAY))
		party_debris += new /obj/effect/decal/cleanable/confetti(get_turf(src)) //a birthday celebration can also be a hangover
		var/list/bonus_confetti = GLOB.alldirs
		for(var/confettis in bonus_confetti)
			var/party_turf_to_spawn_on = get_step(src, confettis)
			if(!isopenturf(party_turf_to_spawn_on))
				continue
			var/dense_object = FALSE
			for(var/atom/content in party_turf_to_spawn_on)
				if(content.density)
					dense_object = TRUE
					break
			if(dense_object)
				continue
			if(prob(50))
				party_debris += new /obj/effect/decal/cleanable/confetti(party_turf_to_spawn_on)
			if(prob(10))
				party_debris += new /obj/item/toy/balloon(party_turf_to_spawn_on)
	if(!HAS_TRAIT(SSstation, STATION_TRAIT_HANGOVER))
		return
	if(prob(60))
		hangover_debris += new /obj/effect/decal/cleanable/vomit(get_turf(src))
	if(prob(70))
		var/bottle_count = rand(1, 3)
		for(var/index in 1 to bottle_count)
			var/turf/turf_to_spawn_on = get_step(src, pick(GLOB.alldirs))
			if(!isopenturf(turf_to_spawn_on))
				continue
			var/dense_object = FALSE
			for(var/atom/content in turf_to_spawn_on.contents)
				if(content.density)
					dense_object = TRUE
					break
			if(dense_object)
				continue
			hangover_debris += new /obj/item/reagent_containers/cup/glass/bottle/beer/almost_empty(turf_to_spawn_on)

///Spawns the mob with some drugginess/drunkeness, and some disgust.
/obj/effect/landmark/start/hangover/proc/make_hungover(mob/hangover_mob)
	if(!iscarbon(hangover_mob))
		return
	var/mob/living/carbon/spawned_carbon = hangover_mob
	spawned_carbon.set_resting(TRUE, silent = TRUE)
	if(prob(50))
		spawned_carbon.adjust_drugginess(rand(30 SECONDS, 40 SECONDS))
	else
		spawned_carbon.adjust_drunk_effect(rand(15, 25))
	spawned_carbon.adjust_disgust(rand(5, 55)) //How hungover are you?
	if(spawned_carbon.head)
		return

/obj/effect/landmark/start/hangover/JoinPlayerHere(mob/joining_mob, buckle)
	. = ..()
	make_hungover(joining_mob)

/obj/effect/landmark/start/hangover/closet
	name = "hangover spawn closet"
	icon_state = "hangover_spawn_closet"

/obj/effect/landmark/start/hangover/closet/JoinPlayerHere(mob/joining_mob, buckle)
	make_hungover(joining_mob)
	for(var/obj/structure/closet/closet in contents)
		if(closet.opened)
			continue
		joining_mob.forceMove(closet)
		return
	return ..() //Call parent as fallback

//Landmark that creates destinations for the navigate verb to path to
/obj/effect/landmark/navigate_destination
	name = "navigate verb destination"
	icon_state = "navigate"
	var/location

/obj/effect/landmark/navigate_destination/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/landmark/navigate_destination/LateInitialize()
	. = ..()
	if(!location)
		var/obj/machinery/door/airlock/A = locate(/obj/machinery/door/airlock) in loc
		location = A ? format_text(A.name) : get_area_name(src, format_text = TRUE)

	GLOB.navigate_destinations[loc] = location

	qdel(src)

//Command
/obj/effect/landmark/navigate_destination/bridge
	location = "Bridge"

/obj/effect/landmark/navigate_destination/hop
	location = "Head of Personnel's Office"

/obj/effect/landmark/navigate_destination/vault
	location = "Vault"

/obj/effect/landmark/navigate_destination/teleporter
	location = "Teleporter"

/obj/effect/landmark/navigate_destination/gateway
	location = "Gateway"

/obj/effect/landmark/navigate_destination/eva
	location = "EVA Storage"

/obj/effect/landmark/navigate_destination/aiupload
	location = "AI Upload"

/obj/effect/landmark/navigate_destination/minisat_access_ai
	location = "AI MiniSat Access"

/obj/effect/landmark/navigate_destination/minisat_access_tcomms
	location = "Telecomms MiniSat Access"

/obj/effect/landmark/navigate_destination/minisat_access_tcomms_ai
	location = "AI and Telecomms MiniSat Access"

/obj/effect/landmark/navigate_destination/tcomms
	location = "Telecommunications"

//Departments
/obj/effect/landmark/navigate_destination/sec
	location = "Security"

/obj/effect/landmark/navigate_destination/det
	location = "Detective's Office"

/obj/effect/landmark/navigate_destination/research
	location = "Research"

/obj/effect/landmark/navigate_destination/engineering
	location = "Engineering"

/obj/effect/landmark/navigate_destination/techstorage
	location = "Technical Storage"

/obj/effect/landmark/navigate_destination/atmos
	location = "Atmospherics"

/obj/effect/landmark/navigate_destination/med
	location = "Medical"

/obj/effect/landmark/navigate_destination/chemfactory
	location = "Chemistry Factory"

/obj/effect/landmark/navigate_destination/cargo
	location = "Cargo"

//Common areas
/obj/effect/landmark/navigate_destination/bar
	location = "Bar"

/obj/effect/landmark/navigate_destination/dorms
	location = "Dormitories"

/obj/effect/landmark/navigate_destination/court
	location = "Courtroom"

/obj/effect/landmark/navigate_destination/tools
	location = "Tool Storage"

/obj/effect/landmark/navigate_destination/library
	location = "Library"

/obj/effect/landmark/navigate_destination/chapel
	location = "Chapel"

/obj/effect/landmark/navigate_destination/minisat_access_chapel_library
	location = "Chapel and Library MiniSat Access"

//Service
/obj/effect/landmark/navigate_destination/kitchen
	location = "Kitchen"

/obj/effect/landmark/navigate_destination/hydro
	location = "Hydroponics"

/obj/effect/landmark/navigate_destination/janitor
	location = "Janitor's Closet"

/obj/effect/landmark/navigate_destination/lawyer
	location = "Lawyer's Office"

//Shuttle docks
/obj/effect/landmark/navigate_destination/dockarrival
	location = "Arrival Shuttle Dock"

/obj/effect/landmark/navigate_destination/dockesc
	location = "Escape Shuttle Dock"

/obj/effect/landmark/navigate_destination/dockescpod
	location = "Escape Pod Dock"

/obj/effect/landmark/navigate_destination/dockescpod1
	location = "Escape Pod 1 Dock"

/obj/effect/landmark/navigate_destination/dockescpod2
	location = "Escape Pod 2 Dock"

/obj/effect/landmark/navigate_destination/dockescpod3
	location = "Escape Pod 3 Dock"

/obj/effect/landmark/navigate_destination/dockescpod4
	location = "Escape Pod 4 Dock"

/obj/effect/landmark/navigate_destination/dockaux
	location = "Auxiliary Dock"

//Maint
/obj/effect/landmark/navigate_destination/incinerator
	location = "Incinerator"

/obj/effect/landmark/navigate_destination/disposals
	location = "Disposals"
