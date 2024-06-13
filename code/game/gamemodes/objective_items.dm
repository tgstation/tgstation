/proc/add_item_to_steal(source, type)
	GLOB.steal_item_handler.objectives_by_path[type] += source
	return type

//Contains the target item datums for Steal objectives.
/datum/objective_item
	/// How the item is described in the objective
	var/name = "a silly bike horn! Honk!"
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
	/**
	 * How hard it is to steal this item given normal circumstances, ranked on a scale of 1 to 5.
	 *
	 * 1 - Probably found in a public area
	 * 2 - Likely on someone's person, or in a less-than-public but otherwise unguarded area
	 * 3 - Usually on someone's person, or in a locked locker or otherwise secure area
	 * 4 - Always on someone's person, or in a secure area
	 * 5 - You know it when you see it. Things like the Nuke Disc which have a pointer to it at all times.
	 *
	 * Also accepts 0 as "extremely easy to steal" and >5 as "almost impossible to steal"
	 */
	var/difficulty = 0
	/// A hint explaining how one may find the target item.
	var/steal_hint = "The clown might have one."

/// For objectives with special checks (does that intellicard have an ai in it? etcetc)
/datum/objective_item/proc/check_special_completion(obj/item/thing)
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
/datum/objective_item/steal/traitor
	objective_type = OBJECTIVE_ITEM_TYPE_TRAITOR

// Unique-ish low risk objectives
/datum/objective_item/steal/traitor/bartender_shotgun
	name = "the bartender's shotgun"
	targetitem = /obj/item/gun/ballistic/shotgun/doublebarrel
	excludefromjob = list(JOB_BARTENDER)
	item_owner = list(JOB_BARTENDER)
	exists_on_map = TRUE
	difficulty = 2
	steal_hint = "A double-barrel shotgun usually found on the bartender's person, or if none are around, in the bar's backroom."

/obj/item/gun/ballistic/shotgun/doublebarrel/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/gun/ballistic/shotgun/doublebarrel)

/datum/objective_item/steal/traitor/fireaxe
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
	difficulty = 3
	steal_hint = "Only two of these exist on the station - one in the bridge, and one in atmospherics. \
		You can use a multitool to hack open the case, or break it open the hard way."

/obj/item/fireaxe/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/fireaxe)

/datum/objective_item/steal/traitor/big_crowbar
	name = "a mech removal tool"
	targetitem = /obj/item/crowbar/mechremoval
	excludefromjob = list(
		JOB_RESEARCH_DIRECTOR,
		JOB_SCIENTIST,
		JOB_ROBOTICIST,
	)
	item_owner = list(JOB_ROBOTICIST)
	exists_on_map = TRUE
	difficulty = 2
	steal_hint = "A specialized tool found in the roboticist's lab. You can use a multitool to hack open the case, or break it open the hard way."

/obj/item/crowbar/mechremoval/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/crowbar/mechremoval)

/datum/objective_item/steal/traitor/nullrod
	name = "the chaplain's null rod"
	targetitem = /obj/item/nullrod
	excludefromjob = list(JOB_CHAPLAIN)
	item_owner = list(JOB_CHAPLAIN)
	exists_on_map = TRUE
	difficulty = 2
	steal_hint = "A holy artifact usually found on the chaplain's person, or if none are around, in the chapel's relic closet. \
		If there is a chaplain aboard, it is likely be to be transformed into some holy weapon - some of which are... difficult to remove from their person."

/obj/item/nullrod/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/nullrod)

/datum/objective_item/steal/traitor/clown_shoes
	name = "the clown's shoes"
	targetitem = /obj/item/clothing/shoes/clown_shoes
	excludefromjob = list(JOB_CLOWN, JOB_CARGO_TECHNICIAN, JOB_QUARTERMASTER)
	item_owner = list(JOB_CLOWN)
	exists_on_map = TRUE
	difficulty = 1
	steal_hint = "The clown's huge, bright shoes. They should always be on the clown's feet."

/obj/item/clothing/shoes/clown_shoes/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/clothing/shoes/clown_shoes)

/datum/objective_item/steal/traitor/mime_mask
	name = "the mime's mask"
	targetitem = /obj/item/clothing/mask/gas/mime
	excludefromjob = list(JOB_MIME, JOB_CARGO_TECHNICIAN, JOB_QUARTERMASTER)
	item_owner = list(JOB_MIME)
	exists_on_map = TRUE
	difficulty = 1
	steal_hint = "The mime's mask. It should always be on the mime's face."

/obj/item/clothing/mask/gas/mime/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/clothing/mask/gas/mime)

/datum/objective_item/steal/traitor/pka
	name = "a protokinetic accelerator"
	targetitem = /obj/item/gun/energy/recharge/kinetic_accelerator
	excludefromjob = list(JOB_SHAFT_MINER, JOB_CARGO_TECHNICIAN, JOB_QUARTERMASTER)
	item_owner = list(JOB_SHAFT_MINER)
	exists_on_map = TRUE
	difficulty = 1
	steal_hint = "A tool primarily used by shaft miners to mine. Most carry one (or multiple) on their person, \
		but they can also be found in the Mining Station, Mining office, or Auxiliary Mining Base on the station."

/obj/item/gun/energy/recharge/kinetic_accelerator/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/gun/energy/recharge/kinetic_accelerator)

/datum/objective_item/steal/traitor/chef_moustache
	name = "a fancy fake moustache"
	targetitem = /obj/item/clothing/mask/fakemoustache/italian
	excludefromjob = list(JOB_COOK, JOB_HEAD_OF_PERSONNEL, JOB_CARGO_TECHNICIAN, JOB_QUARTERMASTER)
	item_owner = list(JOB_COOK)
	exists_on_map = TRUE
	difficulty = 1
	steal_hint = "The chef's fake Italian moustache, either found on their face or in the garbage, depending on who's on duty."

/obj/item/clothing/mask/fakemoustache/italian/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/clothing/mask/fakemoustache/italian)

/datum/objective_item/steal/traitor/det_revolver
	name = "detective's revolver"
	targetitem = /obj/item/gun/ballistic/revolver/c38/detective
	excludefromjob = list(JOB_DETECTIVE)
	exists_on_map = TRUE
	difficulty = 3
	steal_hint = "A .38 special revolver found in the Detective's holder. \
		Usually found on the Detective's person, or if none are around, in the detective's locker, in their office."

/obj/item/gun/ballistic/revolver/c38/detective/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/gun/ballistic/revolver/c38/detective)

/datum/objective_item/steal/traitor/lawyers_badge
	name = "the lawyer's badge"
	targetitem = /obj/item/clothing/accessory/lawyers_badge
	excludefromjob = list(JOB_LAWYER)
	item_owner = list(JOB_LAWYER)
	exists_on_map = TRUE
	difficulty = 1
	steal_hint = "The lawyer's badge. Usually pinned to their chest, but a spare can be obtained from their clothes vendor."

/obj/item/clothing/accessory/lawyers_badge/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/clothing/accessory/lawyers_badge)

/datum/objective_item/steal/traitor/chief_engineer_belt
	name = "the chief engineer's belt"
	targetitem = /obj/item/storage/belt/utility/chief
	excludefromjob = list(JOB_CHIEF_ENGINEER)
	exists_on_map = TRUE
	difficulty = 2
	steal_hint = "The chief engineer's toolbelt, strapped to their waist at all times."

/obj/item/storage/belt/utility/chief/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/storage/belt/utility/chief)

/datum/objective_item/steal/traitor/telebaton
	name = "a head of staff's telescopic baton"
	targetitem = /obj/item/melee/baton/telescopic
	excludefromjob = list(
		JOB_RESEARCH_DIRECTOR,
		JOB_CAPTAIN,
		JOB_HEAD_OF_SECURITY,
		JOB_HEAD_OF_PERSONNEL,
		JOB_CHIEF_ENGINEER,
		JOB_CHIEF_MEDICAL_OFFICER,
		JOB_QUARTERMASTER,
	)
	exists_on_map = TRUE
	difficulty = 3
	steal_hint = "A self-defense weapon standard-issue for all heads of staffs barring the Head of Security. Rarely found off of their person."

/datum/objective_item/steal/traitor/telebaton/check_special_completion(obj/item/thing)
	return thing.type == /obj/item/melee/baton/telescopic

/obj/item/melee/baton/telescopic/add_stealing_item_objective()
	if(type == /obj/item/melee/baton/telescopic)
		return add_item_to_steal(src, /obj/item/melee/baton/telescopic)

/datum/objective_item/steal/traitor/cargo_budget
	name = "cargo's departmental budget"
	targetitem = /obj/item/card/id/departmental_budget/car
	excludefromjob = list(JOB_QUARTERMASTER, JOB_CARGO_TECHNICIAN)
	item_owner = list(JOB_QUARTERMASTER)
	exists_on_map = TRUE
	difficulty = 2
	steal_hint = "A card that grants access to Cargo's funds. \
		Normally found in the locker of the Quartermaster, but a particularly keen one may have it on their person or in their wallet."

/obj/item/card/id/departmental_budget/car/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/card/id/departmental_budget/car)

/datum/objective_item/steal/traitor/captain_modsuit
	name = "the captain's magnate MOD control unit"
	targetitem = /obj/item/mod/control/pre_equipped/magnate
	excludefromjob = list(JOB_CAPTAIN)
	exists_on_map = TRUE
	difficulty = 3
	steal_hint = "An expensive, hand-crafted MOD unit made for the station's Captain. \
		If not being worn by the Captain, you would find it in the Suit Storage Unit in their quarters."

/obj/item/mod/control/pre_equipped/magnate/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/mod/control/pre_equipped/magnate)

/datum/objective_item/steal/traitor/captain_spare
	name = "the captain's spare ID"
	targetitem = /obj/item/card/id/advanced/gold/captains_spare
	excludefromjob = list(
		JOB_RESEARCH_DIRECTOR,
		JOB_CAPTAIN,
		JOB_HEAD_OF_SECURITY,
		JOB_HEAD_OF_PERSONNEL,
		JOB_CHIEF_ENGINEER,
		JOB_CHIEF_MEDICAL_OFFICER,
		JOB_QUARTERMASTER,
	)
	exists_on_map = TRUE
	difficulty = 4
	steal_hint = "The spare ID of the High Lord himself. \
		If there's no official Captain around, you may find it pinned to the chest of the Acting Captain - one of the Heads of Staff. \
		Otherwise, you'll have to bust open the golden safe on the bridge with acid or explosives to get to it."

/obj/item/card/id/advanced/gold/captains_spare/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/card/id/advanced/gold/captains_spare)

// High risk steal objectives

// Will always generate even with no Captain due to its security and temptation to use it
/datum/objective_item/steal/caplaser
	name = "the captain's antique laser gun"
	targetitem = /obj/item/gun/energy/laser/captain
	excludefromjob = list(JOB_CAPTAIN)
	exists_on_map = TRUE
	difficulty = 4
	steal_hint = "A self-charging laser gun found in a display case in the Captain's Quarters. \
		Breaking it open may trigger a security alert, so be careful."

/obj/item/gun/energy/laser/captain/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/gun/energy/laser/captain)

/datum/objective_item/steal/hoslaser
	name = "the head of security's personal laser gun"
	targetitem = /obj/item/gun/energy/e_gun/hos
	excludefromjob = list(JOB_HEAD_OF_SECURITY)
	item_owner = list(JOB_HEAD_OF_SECURITY)
	exists_on_map = TRUE
	difficulty = 4
	steal_hint = "The Head of Security's unique three mode laser gun. \
		Always found on their person, if they are alive, but may otherwise be found in their locker."

/obj/item/gun/energy/e_gun/hos/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/gun/energy/e_gun/hos)

/datum/objective_item/steal/compactshotty
	name = "the head of security's personal compact shotgun"
	targetitem = /obj/item/gun/ballistic/shotgun/automatic/combat/compact
	excludefromjob = list(JOB_HEAD_OF_SECURITY)
	item_owner = list(JOB_HEAD_OF_SECURITY)
	exists_on_map = TRUE
	difficulty = 4
	steal_hint = "A miniaturized combat shotgun. May be found in Head of Security's locker or strapped to their back."

/obj/item/gun/ballistic/shotgun/automatic/combat/compact/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/gun/ballistic/shotgun/automatic/combat/compact)

/datum/objective_item/steal/handtele
	name = "a hand teleporter"
	targetitem = /obj/item/hand_tele
	excludefromjob = list(JOB_CAPTAIN, JOB_RESEARCH_DIRECTOR, JOB_HEAD_OF_PERSONNEL)
	item_owner = list(JOB_CAPTAIN, JOB_RESEARCH_DIRECTOR)
	exists_on_map = TRUE
	difficulty = 3
	steal_hint = "Only two of these devices exist on the station, with one sitting in the Teleporter Room \
		for emergencies, and the other in the Captain's Quarters for personal use."

/obj/item/hand_tele/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/hand_tele)

/datum/objective_item/steal/jetpack
	name = "the Captain's jetpack"
	targetitem = /obj/item/tank/jetpack/oxygen/captain
	excludefromjob = list(JOB_CAPTAIN)
	item_owner = list(JOB_CAPTAIN)
	exists_on_map = TRUE
	difficulty = 3
	steal_hint = "A special yellow jetpack found in the Suit Storage Unit in the Captain's Quarters."

/obj/item/tank/jetpack/oxygen/captain/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/tank/jetpack/oxygen/captain)

/datum/objective_item/steal/magboots
	name = "the chief engineer's advanced magnetic boots"
	targetitem = /obj/item/clothing/shoes/magboots/advance
	excludefromjob = list(JOB_CHIEF_ENGINEER)
	item_owner = list(JOB_CHIEF_ENGINEER)
	exists_on_map = TRUE
	difficulty = 3
	steal_hint = "A pair of magnetic boots found in the Chief Engineer's Suit Storage Unit. \
		May also be found on their person, concealed beneath their MODsuit."

/obj/item/clothing/shoes/magboots/advance/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/clothing/shoes/magboots/advance)

/datum/objective_item/steal/capmedal
	name = "the medal of captaincy"
	targetitem = /obj/item/clothing/accessory/medal/gold/captain
	excludefromjob = list(JOB_CAPTAIN)
	item_owner = list(JOB_CAPTAIN)
	exists_on_map = TRUE
	difficulty = 3
	steal_hint = "A gold medal found in the medal box in the Captain's Quarters. \
		The Captain usually also has one pinned to their jumpsuit."

/obj/item/clothing/accessory/medal/gold/captain/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/clothing/accessory/medal/gold/captain)

/datum/objective_item/steal/hypo
	name = "the hypospray"
	targetitem = /obj/item/reagent_containers/hypospray/cmo
	excludefromjob = list(JOB_CHIEF_MEDICAL_OFFICER)
	item_owner = list(JOB_CHIEF_MEDICAL_OFFICER)
	exists_on_map = TRUE
	difficulty = 3
	steal_hint = "The Chief Medical Officer's personal medical injector. \
		Usually found amongst their medical supplies on their person, in their belt, or otherwise in their locker."

/obj/item/reagent_containers/hypospray/cmo/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/reagent_containers/hypospray/cmo)

/datum/objective_item/steal/nukedisc
	name = "the nuclear authentication disk"
	targetitem = /obj/item/disk/nuclear
	excludefromjob = list(JOB_CAPTAIN)
	difficulty = 5
	steal_hint = "THAT disk - you know the one. Carried by the Captain at all times (hopefully). \
		Difficult to miss, but if you can't find it, the Head of Security and Captain both have devices to track its precise location."

/obj/item/disk/nuclear/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/disk/nuclear)

/datum/objective_item/steal/nukedisc/check_special_completion(obj/item/disk/nuclear/N)
	return !N.fake

/datum/objective_item/steal/reflector
	name = "a reflector trenchcoat"
	targetitem = /obj/item/clothing/suit/hooded/ablative
	excludefromjob = list(JOB_HEAD_OF_SECURITY, JOB_WARDEN)
	item_owner = list(JOB_HEAD_OF_SECURITY)
	exists_on_map = TRUE
	difficulty = 4
	steal_hint = "An ablative trechcoat found on the shelves of the Armory."

/obj/item/clothing/suit/hooded/ablative/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/clothing/suit/hooded/ablative)

/datum/objective_item/steal/reactive
	name = "the reactive teleport armor"
	targetitem = /obj/item/clothing/suit/armor/reactive/teleport
	excludefromjob = list(JOB_RESEARCH_DIRECTOR)
	item_owner = list(JOB_RESEARCH_DIRECTOR)
	exists_on_map = TRUE
	difficulty = 3
	steal_hint = "A special suit of armor found in the possession of the Research Director. \
		You may otherwise find it in their locker."

/obj/item/clothing/suit/armor/reactive/teleport/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/clothing/suit/armor/reactive/teleport)

/datum/objective_item/steal/documents
	name = "any set of secret documents of any organization"
	valid_containers = list(/obj/item/folder)
	targetitem = /obj/item/documents
	exists_on_map = TRUE
	difficulty = 3
	steal_hint = "A set of papers belonging to a megaconglomerate. \
		Nanotrasen documents can easily be found in the station's vault. \
		For other corporations, you may find them in strange and distant places. \
		A photocopy may also suffice."

/obj/item/documents/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/documents) //Any set of secret documents. Doesn't have to be NT's

/datum/objective_item/steal/nuke_core
	name = "the heavily radioactive plutonium core from the onboard self-destruct"
	valid_containers = list(/obj/item/nuke_core_container)
	targetitem = /obj/item/nuke_core
	exists_on_map = TRUE
	difficulty = 4
	steal_hint = "The core of the station's self-destruct device, found in the vault."

/obj/item/nuke_core/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/nuke_core)

/datum/objective_item/steal/nuke_core/New()
	special_equipment += /obj/item/storage/box/syndie_kit/nuke
	..()

/datum/objective_item/steal/hdd_extraction
	name = "the source code for Project Goon from the master R&D server mainframe"
	targetitem = /obj/item/computer_disk/hdd_theft
	excludefromjob = list(JOB_RESEARCH_DIRECTOR, JOB_SCIENTIST, JOB_ROBOTICIST, JOB_GENETICIST)
	item_owner = list(JOB_RESEARCH_DIRECTOR, JOB_SCIENTIST)
	exists_on_map = TRUE
	difficulty = 4
	steal_hint = "The hard drive of the master research server, found in R&D's server room."

/obj/item/computer_disk/hdd_theft/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/computer_disk/hdd_theft)

/datum/objective_item/steal/hdd_extraction/New()
	special_equipment += /obj/item/paper/guides/antag/hdd_extraction
	return ..()


/datum/objective_item/steal/supermatter
	name = "a sliver of a supermatter crystal"
	targetitem = /obj/item/nuke_core/supermatter_sliver
	valid_containers = list(/obj/item/nuke_core_container/supermatter)
	difficulty = 5
	steal_hint = "A small shard of the station's supermatter crystal engine."

/datum/objective_item/steal/supermatter/New()
	special_equipment += /obj/item/storage/box/syndie_kit/supermatter
	..()

/datum/objective_item/steal/supermatter/target_exists()
	return GLOB.main_supermatter_engine != null

// Doesn't need item_owner = (JOB_AI) because this handily functions as a murder objective if there isn't one
/datum/objective_item/steal/functionalai
	name = "a functional AI"
	targetitem = /obj/item/aicard
	difficulty = 5
	steal_hint = "An intellicard (or MODsuit) containing an active, functional AI."

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
		if(isAI(suit.ai_assistant))
			being = suit.ai_assistant
	else
		stack_trace("check_special_completion() called on [src] with [potential_storage] ([potential_storage.type])! That's not supposed to happen!")
		return FALSE

	if(isAI(being) && being.stat != DEAD)
		return TRUE

	return FALSE

/datum/objective_item/steal/blueprints
	name = "the station blueprints"
	targetitem = /obj/item/blueprints
	excludefromjob = list(JOB_CHIEF_ENGINEER)
	item_owner = list(JOB_CHIEF_ENGINEER)
	altitems = list(/obj/item/photo)
	exists_on_map = TRUE
	difficulty = 3
	steal_hint = "The blueprints of the station, found in the Chief Engineer's locker, or on their person. A picture may suffice."

/obj/item/blueprints/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/blueprints)

/datum/objective_item/steal/blueprints/check_special_completion(obj/item/I)
	if(istype(I, /obj/item/blueprints))
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
	difficulty = 4
	steal_hint = "The station's data Blackbox, found solely within Telecommunications."

/obj/item/blackbox/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/blackbox)


// A number of special early-game steal objectives intended to be used with the steal-and-destroy objective.
// They're basically items of utility or emotional value that may be found on many players or lying around the station.
/datum/objective_item/steal/traitor/insuls
	name = "some insulated gloves"
	targetitem = /obj/item/clothing/gloves/color/yellow
	excludefromjob = list(JOB_CARGO_TECHNICIAN, JOB_QUARTERMASTER, JOB_ATMOSPHERIC_TECHNICIAN, JOB_STATION_ENGINEER, JOB_CHIEF_ENGINEER)
	item_owner = list(JOB_STATION_ENGINEER, JOB_CHIEF_ENGINEER)
	exists_on_map = TRUE
	difficulty = 1
	steal_hint = "A basic pair of insulated gloves, usually worn by Assistants, Engineers, or Cargo Technicians."

/obj/item/clothing/gloves/color/yellow/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/clothing/gloves/color/yellow)

/datum/objective_item/steal/traitor/moth_plush
	name = "a cute moth plush toy"
	targetitem = /obj/item/toy/plush/moth
	excludefromjob = list(JOB_PSYCHOLOGIST, JOB_PARAMEDIC, JOB_CHEMIST, JOB_MEDICAL_DOCTOR, JOB_CHIEF_MEDICAL_OFFICER, JOB_CORONER)
	exists_on_map = TRUE
	difficulty = 1
	steal_hint = "A moth plush toy. The Psychologist has one to help console patients."

/obj/item/toy/plush/moth/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/toy/plush/moth)

/datum/objective_item/steal/traitor/lizard_plush
	name = "a cute lizard plush toy"
	targetitem = /obj/item/toy/plush/lizard_plushie
	exists_on_map = TRUE
	difficulty = 1
	steal_hint = "A lizard plush toy. Often found hidden in maintenance."

/obj/item/toy/plush/lizard_plushie/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/toy/plush/lizard_plushie)

/datum/objective_item/steal/traitor/denied_stamp
	name = "cargo's denied stamp"
	targetitem = /obj/item/stamp/denied
	excludefromjob = list(JOB_CARGO_TECHNICIAN, JOB_QUARTERMASTER, JOB_SHAFT_MINER)
	exists_on_map = TRUE
	difficulty = 1
	steal_hint = "Cargo often has multiple of these red stamps lying around to process paperwork."

/obj/item/stamp/denied/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/stamp/denied)

/datum/objective_item/steal/traitor/granted_stamp
	name = "cargo's granted stamp"
	targetitem = /obj/item/stamp/granted
	excludefromjob = list(JOB_CARGO_TECHNICIAN, JOB_QUARTERMASTER, JOB_SHAFT_MINER)
	exists_on_map = TRUE
	difficulty = 1
	steal_hint = "Cargo often has multiple of these green stamps lying around to process paperwork."

/obj/item/stamp/granted/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/stamp/granted)

/datum/objective_item/steal/traitor/space_law
	name = "a book on space law"
	targetitem = /obj/item/book/manual/wiki/security_space_law
	excludefromjob = list(JOB_SECURITY_OFFICER, JOB_WARDEN, JOB_HEAD_OF_SECURITY, JOB_LAWYER, JOB_DETECTIVE)
	exists_on_map = TRUE
	difficulty = 1
	steal_hint = "Sometimes found in the possession of members of Security and Lawyers. \
		The courtroom and the library are also good places to look."

/obj/item/book/manual/wiki/security_space_law/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/book/manual/wiki/security_space_law)

/datum/objective_item/steal/traitor/rpd
	name = "a rapid pipe dispenser"
	targetitem = /obj/item/pipe_dispenser
	excludefromjob = list(
		JOB_ATMOSPHERIC_TECHNICIAN,
		JOB_STATION_ENGINEER,
		JOB_CHIEF_ENGINEER,
		JOB_SCIENTIST,
		JOB_RESEARCH_DIRECTOR,
		JOB_GENETICIST,
		JOB_ROBOTICIST,
	)
	item_owner = list(JOB_CHIEF_ENGINEER)
	exists_on_map = TRUE
	difficulty = 1
	steal_hint = "A tool often used by Engineers, Atmospherics Technicians, and Ordnance Technicians."

/obj/item/pipe_dispenser/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/pipe_dispenser)

/datum/objective_item/steal/traitor/donut_box
	name = "a box of prized donuts"
	targetitem = /obj/item/storage/fancy/donut_box
	excludefromjob = list(
		JOB_CAPTAIN,
		JOB_CHIEF_ENGINEER,
		JOB_HEAD_OF_PERSONNEL,
		JOB_HEAD_OF_SECURITY,
		JOB_QUARTERMASTER,
		JOB_CHIEF_MEDICAL_OFFICER,
		JOB_RESEARCH_DIRECTOR,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
		JOB_LAWYER,
		JOB_DETECTIVE,
	)
	exists_on_map = TRUE
	difficulty = 1
	steal_hint = "Everyone has a box of donuts - you may most commonly find them on the Bridge, within Security, or in any department's break room."

/obj/item/storage/fancy/donut_box/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/storage/fancy/donut_box)

/datum/objective_item/steal/spy
	objective_type = OBJECTIVE_ITEM_TYPE_SPY

/datum/objective_item/steal/spy/lamarr
	name = "the Research Director's pet headcrab"
	targetitem = /obj/item/clothing/mask/facehugger/lamarr
	excludefromjob = list(JOB_RESEARCH_DIRECTOR)
	exists_on_map = TRUE
	difficulty = 3
	steal_hint = "The Research Director's pet headcrab, Lamarr, found in a secure cage in their office."

/obj/item/clothing/mask/facehugger/lamarr/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/clothing/mask/facehugger/lamarr)

/datum/objective_item/steal/spy/disabler
	name = "a disabler"
	targetitem = /obj/item/gun/energy/disabler
	excludefromjob = list(
		JOB_CAPTAIN,
		JOB_DETECTIVE,
		JOB_HEAD_OF_PERSONNEL,
		JOB_HEAD_OF_SECURITY,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
	)
	difficulty = 2
	steal_hint = "A hand-held disabler, often found in the possession of Security Officers."

/datum/objective_item/steal/spy/energy_gun
	name = "an energy gun"
	targetitem = /obj/item/gun/energy/e_gun
	excludefromjob = list(
		JOB_CAPTAIN,
		JOB_CHIEF_ENGINEER,
		JOB_CHIEF_MEDICAL_OFFICER,
		JOB_DETECTIVE,
		JOB_HEAD_OF_PERSONNEL,
		JOB_HEAD_OF_SECURITY,
		JOB_QUARTERMASTER,
		JOB_RESEARCH_DIRECTOR,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
	)
	exists_on_map = TRUE
	difficulty = 2
	steal_hint = "A two-mode energy gun, found in the station's Armory, as well as in the hands of some heads of staff for personal defense."

/datum/objective_item/steal/spy/energy_gun/check_special_completion(obj/item/thing)
	return thing.type == /obj/item/gun/energy/e_gun

/obj/item/gun/energy/e_gun/add_stealing_item_objective()
	if(type == /obj/item/gun/energy/e_gun)
		return add_item_to_steal(src, /obj/item/gun/energy/e_gun)

/datum/objective_item/steal/spy/laser_gun
	name = "a laser gun"
	targetitem = /obj/item/gun/energy/laser
	excludefromjob = list(
		JOB_CAPTAIN,
		JOB_CHIEF_ENGINEER,
		JOB_CHIEF_MEDICAL_OFFICER,
		JOB_DETECTIVE,
		JOB_HEAD_OF_PERSONNEL,
		JOB_HEAD_OF_SECURITY,
		JOB_QUARTERMASTER,
		JOB_RESEARCH_DIRECTOR,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
	)
	exists_on_map = TRUE
	difficulty = 3
	steal_hint = "A simple laser gun, found in the station's Armory."

/datum/objective_item/steal/spy/laser_gun/check_special_completion(obj/item/thing)
	return thing.type == /obj/item/gun/energy/laser

/obj/item/gun/energy/laser/add_stealing_item_objective()
	if(type == /obj/item/gun/energy/laser)
		return add_item_to_steal(src, /obj/item/gun/energy/laser)

/datum/objective_item/steal/spy/shotgun
	name = "a riot shotgun"
	targetitem = /obj/item/gun/ballistic/shotgun/riot
	excludefromjob = list(
		JOB_DETECTIVE,
		JOB_HEAD_OF_PERSONNEL,
		JOB_HEAD_OF_SECURITY,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
	)
	exists_on_map = TRUE
	difficulty = 3
	steal_hint = "A shotgun found in the station's Armory for riot suppression. Doesn't miss."

/obj/item/gun/ballistic/shotgun/riot/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/gun/ballistic/shotgun/riot)

/datum/objective_item/steal/spy/temp_gun
	name = "security's temperature gun"
	targetitem = /obj/item/gun/energy/temperature/security
	excludefromjob = list(
		JOB_DETECTIVE,
		JOB_HEAD_OF_PERSONNEL,
		JOB_HEAD_OF_SECURITY,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
	)
	exists_on_map = TRUE
	difficulty = 2 // lowered for the meme
	steal_hint = "Security's TRUSTY temperature gun, found in the station's Armory."

/obj/item/gun/energy/temperature/security/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/gun/energy/temperature/security)

/datum/objective_item/steal/spy/stamp
	name = "a head of staff's stamp"
	targetitem = /obj/item/stamp/head
	excludefromjob = list(
		JOB_CAPTAIN,
		JOB_CHIEF_ENGINEER,
		JOB_CHIEF_MEDICAL_OFFICER,
		JOB_HEAD_OF_PERSONNEL,
		JOB_HEAD_OF_SECURITY,
		JOB_QUARTERMASTER,
		JOB_RESEARCH_DIRECTOR,
	)
	exists_on_map = TRUE
	difficulty = 1
	steal_hint = "A stamp owned by a head of staff, from their offices."

/obj/item/stamp/head/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/stamp/head)

/datum/objective_item/steal/spy/sunglasses
	name = "some sunglasses"
	targetitem = /obj/item/clothing/glasses/sunglasses
	excludefromjob = list(
		JOB_CAPTAIN,
		JOB_CHIEF_ENGINEER,
		JOB_CHIEF_MEDICAL_OFFICER,
		JOB_HEAD_OF_PERSONNEL,
		JOB_HEAD_OF_SECURITY,
		JOB_LAWYER,
		JOB_QUARTERMASTER,
		JOB_RESEARCH_DIRECTOR,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
	)
	difficulty = 1
	steal_hint = "A pair of sunglasses. Lawyers often have a few pairs, as do some heads of staff. \
		You can also obtain a pair from dissassembling hudglasses."

/datum/objective_item/steal/spy/ce_modsuit
	name = "the chief engineer's advanced MOD control unit"
	targetitem = /obj/item/mod/control/pre_equipped/advanced
	excludefromjob = list(JOB_CHIEF_ENGINEER)
	exists_on_map = TRUE
	difficulty = 2
	steal_hint = "An advanced version of the standard Engineering MODsuit commonly worn by the Chief Engineer."

/obj/item/mod/control/pre_equipped/advanced/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/mod/control/pre_equipped/advanced)

/datum/objective_item/steal/spy/rd_modsuit
	name = "the research director's research MOD control unit"
	targetitem = /obj/item/mod/control/pre_equipped/research
	excludefromjob = list(JOB_RESEARCH_DIRECTOR)
	exists_on_map = TRUE
	difficulty = 2
	steal_hint = "A bulky MODsuit commonly worn by the Research Director to protect themselves from the hazards of their work."

/obj/item/mod/control/pre_equipped/research/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/mod/control/pre_equipped/research)

/datum/objective_item/steal/spy/cmo_modsuit
	name = "the chief medical officer's rescure MOD control unit"
	targetitem = /obj/item/mod/control/pre_equipped/rescue
	excludefromjob = list(JOB_CHIEF_MEDICAL_OFFICER)
	exists_on_map = TRUE
	difficulty = 2
	steal_hint = "A MODsuit sometimes equipped by the Chief Medical Officer to perform rescue opperations in hazardous environments."

/obj/item/mod/control/pre_equipped/rescue/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/mod/control/pre_equipped/rescue)

/datum/objective_item/steal/spy/hos_modsuit
	name = "the head of security's safeguard MOD control unit"
	targetitem = /obj/item/mod/control/pre_equipped/safeguard
	excludefromjob = list(JOB_HEAD_OF_SECURITY)
	exists_on_map = TRUE
	difficulty = 2
	steal_hint = "An advanced MODsuit sometimes worn by the Head of Security when needing to detain hostiles invading the station."

/obj/item/mod/control/pre_equipped/safeguard/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/mod/control/pre_equipped/safeguard)

/datum/objective_item/steal/spy/stun_baton
	name = "a stun baton"
	targetitem = /obj/item/melee/baton/security
	excludefromjob = list(
		JOB_CAPTAIN,
		JOB_DETECTIVE,
		JOB_HEAD_OF_PERSONNEL,
		JOB_HEAD_OF_SECURITY,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
	)
	difficulty = 2
	steal_hint = "Steal any stun baton from Security."

/datum/objective_item/steal/spy/stun_baton/check_special_completion(obj/item/thing)
	return !istype(thing, /obj/item/melee/baton/security/cattleprod)

/datum/objective_item/steal/spy/det_baton
	name = "the detective's baton"
	targetitem = /obj/item/melee/baton
	excludefromjob = list(
		JOB_CAPTAIN,
		JOB_DETECTIVE,
		JOB_HEAD_OF_PERSONNEL,
		JOB_HEAD_OF_SECURITY,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
	)
	exists_on_map = TRUE
	difficulty = 2
	steal_hint = "The detective's old wooden truncheon, commonly found on their person for self defense."

/datum/objective_item/steal/spy/det_baton/check_special_completion(obj/item/thing)
	return thing.type == /obj/item/melee/baton

/obj/item/melee/baton/add_stealing_item_objective()
	if(type == /obj/item/melee/baton)
		return add_item_to_steal(src, /obj/item/melee/baton)

/datum/objective_item/steal/spy/captain_sabre_sheathe
	name = "the captain's sabre sheathe"
	targetitem = /obj/item/storage/belt/sabre
	excludefromjob = list(JOB_CAPTAIN)
	exists_on_map = TRUE
	difficulty = 3
	steal_hint = "The sheathe for the captain's sabre, found in their closet or strapped to their waist at all times."

/obj/item/storage/belt/sabre/add_stealing_item_objective()
	return add_item_to_steal(src, /obj/item/storage/belt/sabre)
