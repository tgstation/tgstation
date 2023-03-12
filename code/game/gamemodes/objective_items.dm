#define ADD_STEAL_ITEM(Source, Type) GLOB.steal_item_handler.objectives_by_path[Type] += Source

//Contains the target item datums for Steal objectives.
/datum/objective_item
	/// How the item is described in the objective
	var/name = "A silly bike horn! Honk!"
	/// Typepath of item
	var/targetitem = /obj/item/bikehorn
	/// Valid containers that the target item can be in.
	var/list/valid_containers = list()
	/// Who CARES if this item goes missing (no stealing unguarded items), often similar but not identical to the next list
	var/list/item_owner = list()
	/// Jobs which cannot generate this objective (no stealing your own stuff)
	var/list/excludefromjob = list()
	/// List of additional items which also count, for things like blueprints
	var/list/altitems = list()
	/// Items to provide to people in order to allow them to acquire the target
	var/list/special_equipment = list()
	/// Defines in which contexts the item can be given as an objective
	var/objective_type = OBJECTIVE_ITEM_TYPE_NORMAL
	/// Whether this item exists on the station map at the start of a round.
	var/exists_on_map = FALSE

/// For objectives with special checks (does that intellicard have an ai in it? etcetc)
/datum/objective_item/proc/check_special_completion()
	return TRUE

/// Takes a list of minds and returns true if this is a valid objective to give to a team of these minds
/datum/objective_item/proc/valid_objective_for(list/potential_thieves, require_owner = FALSE)
	if(!target_exists() || (require_owner && !owner_exists()))
		return FALSE
	for (var/datum/mind/possible_thief as anything in potential_thieves)
		var/datum/job/role = possible_thief.assigned_role
		if(role.title in excludefromjob)
			return FALSE
	return TRUE

/// Returns true if the target item exists
/datum/objective_item/proc/target_exists()
	return (exists_on_map) ? length(GLOB.steal_item_handler.objectives_by_path[targetitem]) : TRUE

/// Returns true if one of the item's owners exists somewhere
/datum/objective_item/proc/owner_exists()
	if (!length(item_owner))
		return TRUE
	for (var/mob/living/player as anything in GLOB.player_list)
		if ((player.mind?.assigned_role.title in item_owner) && player.stat != DEAD && !is_centcom_level(player.z))
			return TRUE
	return FALSE

/datum/objective_item/steal/New()
	. = ..()
	if(target_exists())
		GLOB.possible_items += src
	else
		qdel(src)

/datum/objective_item/steal/Destroy()
	GLOB.possible_items -= src
	return ..()

// Low risk steal objectives
/datum/objective_item/steal/low_risk
	objective_type = OBJECTIVE_ITEM_TYPE_TRAITOR

// Unique-ish low risk objectives
/datum/objective_item/steal/low_risk/bartender_shotgun
	name = "the bartender's shotgun"
	targetitem = /obj/item/gun/ballistic/shotgun/doublebarrel
	excludefromjob = list(JOB_BARTENDER)
	item_owner = list(JOB_BARTENDER)
	exists_on_map = TRUE

/obj/item/gun/ballistic/shotgun/doublebarrel/add_stealing_item_objective()
	ADD_STEAL_ITEM(src, /obj/item/gun/ballistic/shotgun/doublebarrel)

// No item owner, list would be so long as to be functionally useless and they're in two very disparate locations on most maps
/datum/objective_item/steal/low_risk/fireaxe
	name = "a fire axe"
	targetitem = /obj/item/fireaxe
	excludefromjob = list(
		JOB_ATMOSPHERIC_TECHNICIAN,
		JOB_CAPTAIN,
		JOB_CHIEF_ENGINEER,
		JOB_CHIEF_MEDICAL_OFFICER,
		JOB_HEAD_OF_PERSONNEL,
		JOB_HEAD_OF_SECURITY,
		JOB_QUARTERMASTER,
		JOB_RESEARCH_DIRECTOR,
		JOB_STATION_ENGINEER,
	)
	exists_on_map = TRUE

/obj/item/fireaxe/add_stealing_item_objective()
	ADD_STEAL_ITEM(src, /obj/item/fireaxe)

/datum/objective_item/steal/low_risk/big_crowbar
	name = "a mech removal tool"
	targetitem = /obj/item/crowbar/mechremoval
	excludefromjob = list(
		JOB_RESEARCH_DIRECTOR,
		JOB_SCIENTIST,
		JOB_ROBOTICIST,
	)
	item_owner = list(JOB_ROBOTICIST)
	exists_on_map = TRUE

/obj/item/crowbar/mechremoval/add_stealing_item_objective()
	ADD_STEAL_ITEM(src, /obj/item/crowbar/mechremoval)

/datum/objective_item/steal/low_risk/nullrod
	name = "the chaplain's null rod"
	targetitem = /obj/item/nullrod
	excludefromjob = list(JOB_CHAPLAIN)
	item_owner = list(JOB_CHAPLAIN)
	exists_on_map = TRUE

/obj/item/nullrod/add_stealing_item_objective()
	ADD_STEAL_ITEM(src, /obj/item/nullrod)

/datum/objective_item/steal/low_risk/clown_shoes
	name = "the clown's shoes"
	targetitem = /obj/item/clothing/shoes/clown_shoes
	excludefromjob = list(JOB_CLOWN, JOB_CARGO_TECHNICIAN, JOB_QUARTERMASTER)
	item_owner = list(JOB_CLOWN)

/datum/objective_item/steal/low_risk/cargo_budget
	name = "cargo's departmental budget"
	targetitem = /obj/item/card/id/departmental_budget/car
	excludefromjob = list(JOB_QUARTERMASTER, JOB_CARGO_TECHNICIAN)
	item_owner = list(JOB_QUARTERMASTER)
	exists_on_map = TRUE

/obj/item/card/id/departmental_budget/car/add_stealing_item_objective()
	ADD_STEAL_ITEM(src, /obj/item/card/id/departmental_budget/car)

// High risk steal objectives

// Will always generate even with no Captain due to its security and temptation to use it
/datum/objective_item/steal/caplaser
	name = "the captain's antique laser gun"
	targetitem = /obj/item/gun/energy/laser/captain
	excludefromjob = list(JOB_CAPTAIN)
	exists_on_map = TRUE

/obj/item/gun/energy/laser/captain/add_stealing_item_objective()
	ADD_STEAL_ITEM(src, /obj/item/gun/energy/laser/captain)

/datum/objective_item/steal/hoslaser
	name = "the head of security's personal laser gun"
	targetitem = /obj/item/gun/energy/e_gun/hos
	excludefromjob = list(JOB_HEAD_OF_SECURITY)
	item_owner = list(JOB_HEAD_OF_SECURITY)
	exists_on_map = TRUE

/obj/item/gun/energy/e_gun/hos/add_stealing_item_objective()
	ADD_STEAL_ITEM(src, /obj/item/gun/energy/e_gun/hos)

/datum/objective_item/steal/handtele
	name = "a hand teleporter"
	targetitem = /obj/item/hand_tele
	excludefromjob = list(JOB_CAPTAIN, JOB_RESEARCH_DIRECTOR, JOB_HEAD_OF_PERSONNEL)
	item_owner = list(JOB_CAPTAIN, JOB_RESEARCH_DIRECTOR)
	exists_on_map = TRUE

/obj/item/hand_tele/add_stealing_item_objective()
	ADD_STEAL_ITEM(src, /obj/item/hand_tele)

/datum/objective_item/steal/jetpack
	name = "the Captain's jetpack"
	targetitem = /obj/item/tank/jetpack/oxygen/captain
	excludefromjob = list(JOB_CAPTAIN)
	item_owner = list(JOB_CAPTAIN)
	exists_on_map = TRUE

/obj/item/tank/jetpack/oxygen/captain/add_stealing_item_objective()
	ADD_STEAL_ITEM(src, /obj/item/tank/jetpack/oxygen/captain)

/datum/objective_item/steal/magboots
	name = "the chief engineer's advanced magnetic boots"
	targetitem = /obj/item/clothing/shoes/magboots/advance
	excludefromjob = list(JOB_CHIEF_ENGINEER)
	item_owner = list(JOB_CHIEF_ENGINEER)
	exists_on_map = TRUE

/obj/item/clothing/shoes/magboots/advance/add_stealing_item_objective()
	ADD_STEAL_ITEM(src, /obj/item/clothing/shoes/magboots/advance)

/datum/objective_item/steal/capmedal
	name = "the medal of captaincy"
	targetitem = /obj/item/clothing/accessory/medal/gold/captain
	excludefromjob = list(JOB_CAPTAIN)
	item_owner = list(JOB_CAPTAIN)
	exists_on_map = TRUE

/obj/item/clothing/accessory/medal/gold/captain/add_stealing_item_objective()
	ADD_STEAL_ITEM(src, /obj/item/clothing/accessory/medal/gold/captain)

/datum/objective_item/steal/hypo
	name = "the hypospray"
	targetitem = /obj/item/reagent_containers/hypospray/cmo
	excludefromjob = list(JOB_CHIEF_MEDICAL_OFFICER)
	item_owner = list(JOB_CHIEF_MEDICAL_OFFICER)
	exists_on_map = TRUE

/obj/item/reagent_containers/hypospray/cmo/add_stealing_item_objective()
	ADD_STEAL_ITEM(src, /obj/item/reagent_containers/hypospray/cmo)

/datum/objective_item/steal/nukedisc
	name = "the nuclear authentication disk"
	targetitem = /obj/item/disk/nuclear
	excludefromjob = list(JOB_CAPTAIN)

/datum/objective_item/steal/nukedisc/check_special_completion(obj/item/disk/nuclear/N)
	return !N.fake

/datum/objective_item/steal/reflector
	name = "a reflector trenchcoat"
	targetitem = /obj/item/clothing/suit/hooded/ablative
	excludefromjob = list(JOB_HEAD_OF_SECURITY, JOB_WARDEN)
	item_owner = list(JOB_HEAD_OF_SECURITY)
	exists_on_map = TRUE

/obj/item/clothing/suit/hooded/ablative/add_stealing_item_objective()
	ADD_STEAL_ITEM(src, /obj/item/clothing/suit/hooded/ablative)

/datum/objective_item/steal/reactive
	name = "the reactive teleport armor"
	targetitem = /obj/item/clothing/suit/armor/reactive/teleport
	excludefromjob = list(JOB_RESEARCH_DIRECTOR)
	item_owner = list(JOB_RESEARCH_DIRECTOR)
	exists_on_map = TRUE

/obj/item/clothing/suit/armor/reactive/teleport/add_stealing_item_objective()
	ADD_STEAL_ITEM(src, /obj/item/clothing/suit/armor/reactive/teleport)

/datum/objective_item/steal/documents
	name = "any set of secret documents of any organization"
	targetitem = /obj/item/documents
	exists_on_map = TRUE

/obj/item/documents/add_stealing_item_objective()
	ADD_STEAL_ITEM(src, /obj/item/documents) //Any set of secret documents. Doesn't have to be NT's

/datum/objective_item/steal/nuke_core
	name = "the heavily radioactive plutonium core from the onboard self-destruct"
	valid_containers = list(/obj/item/nuke_core_container)
	targetitem = /obj/item/nuke_core
	exists_on_map = TRUE

/obj/item/nuke_core/add_stealing_item_objective()
	ADD_STEAL_ITEM(src, /obj/item/nuke_core)

/datum/objective_item/steal/nuke_core/New()
	special_equipment += /obj/item/storage/box/syndie_kit/nuke
	..()

/datum/objective_item/steal/hdd_extraction
	name = "the source code for Project Goon from the master R&D server mainframe"
	targetitem = /obj/item/computer_disk/hdd_theft
	excludefromjob = list(JOB_RESEARCH_DIRECTOR, JOB_SCIENTIST, JOB_ROBOTICIST, JOB_GENETICIST)
	item_owner = list(JOB_RESEARCH_DIRECTOR, JOB_SCIENTIST)
	exists_on_map = TRUE

/obj/item/computer_disk/hdd_theft/add_stealing_item_objective()
	ADD_STEAL_ITEM(src, /obj/item/computer_disk/hdd_theft)

/datum/objective_item/steal/hdd_extraction/New()
	special_equipment += /obj/item/paper/guides/antag/hdd_extraction
	return ..()


/datum/objective_item/steal/supermatter
	name = "a sliver of a supermatter crystal"
	targetitem = /obj/item/nuke_core/supermatter_sliver
	valid_containers = list(/obj/item/nuke_core_container/supermatter)

/datum/objective_item/steal/supermatter/New()
	special_equipment += /obj/item/storage/box/syndie_kit/supermatter
	..()

/datum/objective_item/steal/supermatter/target_exists()
	return GLOB.main_supermatter_engine != null

// Doesn't need item_owner = (JOB_AI) because this handily functions as a murder objective if there isn't one
/datum/objective_item/steal/functionalai
	name = "a functional AI"
	targetitem = /obj/item/aicard

/datum/objective_item/steal/functionalai/New()
	. = ..()
	altitems += typesof(/obj/item/mod/control) // only here so we can account for AIs tucked away in a MODsuit.

/datum/objective_item/steal/functionalai/check_special_completion(obj/item/potential_storage)
	var/mob/living/silicon/ai/being

	if(istype(potential_storage, /obj/item/aicard))
		var/obj/item/aicard/card = potential_storage
		being = card.AI // why is this one capitalized and the other one not? i wish i knew.
	else if(istype(potential_storage, /obj/item/mod/control))
		var/obj/item/mod/control/suit = potential_storage
		being = suit.ai
	else
		stack_trace("check_special_completion() called on [src] with [potential_storage] ([potential_storage.type])! That's not supposed to happen!")
		return FALSE

	if(isAI(being) && being.stat != DEAD)
		return TRUE

	return FALSE

/datum/objective_item/steal/blueprints
	name = "the station blueprints"
	targetitem = /obj/item/areaeditor/blueprints
	excludefromjob = list(JOB_CHIEF_ENGINEER)
	item_owner = list(JOB_CHIEF_ENGINEER)
	altitems = list(/obj/item/photo)
	exists_on_map = TRUE

/obj/item/areaeditor/blueprints/add_stealing_item_objective()
	ADD_STEAL_ITEM(src, /obj/item/areaeditor/blueprints)

/datum/objective_item/steal/blueprints/check_special_completion(obj/item/I)
	if(istype(I, /obj/item/areaeditor/blueprints))
		return TRUE
	if(istype(I, /obj/item/photo))
		var/obj/item/photo/P = I
		if(P.picture.has_blueprints) //if the blueprints are in frame
			return TRUE
	return FALSE

/datum/objective_item/steal/blackbox
	name = "the Blackbox"
	targetitem = /obj/item/blackbox
	excludefromjob = list(JOB_CHIEF_ENGINEER, JOB_STATION_ENGINEER, JOB_ATMOSPHERIC_TECHNICIAN)
	exists_on_map = TRUE

/obj/item/blackbox/add_stealing_item_objective()
	ADD_STEAL_ITEM(src, /obj/item/blackbox)

#undef ADD_STEAL_ITEM
