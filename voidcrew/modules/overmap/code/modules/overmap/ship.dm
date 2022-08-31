/obj/structure/overmap/ship
	///Assoc list of remaining open job slots (job = remaining slots)
	var/list/job_slots = list()


	///Shipwide bank account
	var/datum/bank_account/ship/ship_account
	///Manifest list of people on the ship
	var/list/manifest = list()
	///List of weakrefs of all the crewmembers
	var/list/crewmembers = list()


	///Short memo of the ship shown to new joins
	var/memo = ""
	///The docking port of the linked shuttle
	var/obj/docking_port/mobile/shuttle
	///The map template the shuttle was spawned from, if it was indeed created from a template. CAN BE NULL (ex. custom-built ships).
	var/datum/map_template/shuttle/voidcrew/source_template

/**
  * Bastardized version of GLOB.manifest.manifest_inject, but used per ship
  *
  */
/obj/structure/overmap/ship/proc/manifest_inject(mob/living/carbon/human/H, datum/job/human_job)
	set waitfor = FALSE
	if(H.mind && (H.mind.assigned_role != H.mind.special_role))
		manifest[H.real_name] = human_job
	register_crewmember(H)

/obj/structure/overmap/ship/proc/register_crewmember(mob/living/carbon/human/crewmate)
	var/datum/weakref/new_cremate = WEAKREF(crewmate)
	crewmembers.Add(new_cremate)
//	RegisterSignal(crewmate, COMSIG_MOB_DEATH, .proc/handle_inactive_ship)
	//Adds a faction hud to a newplayer documentation in _HELPERS/game.dm
//	add_faction_hud(FACTION_HUD_GENERAL, faction_prefix, crewmate)
