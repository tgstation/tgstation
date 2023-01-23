#define ADD_STEAL_ITEM(Source, Type) GLOB.steal_item_handler.objectives_by_path[Type] += Source

//Contains the target item datums for Steal objectives.
/datum/objective_item
	var/name = "A silly bike horn! Honk!"
	var/targetitem = /obj/item/bikehorn
	var/list/valid_containers = list() // Valid containers that the target item can be in.
	var/difficulty = 9001 //vaguely how hard it is to do this objective
	var/list/excludefromjob = list() //If you don't want a job to get a certain objective (no captain stealing his own medal, etcetc)
	var/list/altitems = list() //Items which can serve as an alternative to the objective (darn you blueprints)
	var/list/special_equipment = list()
	var/objective_type = OBJECTIVE_ITEM_TYPE_NORMAL
	/// Whether this item exists on the station map at the start of a round.
	var/exists_on_map = FALSE

/datum/objective_item/proc/check_special_completion() //for objectives with special checks (is that slime extract unused? does that intellicard have an ai in it? etcetc)
	return 1

/datum/objective_item/proc/TargetExists()
	return TRUE

/datum/objective_item/steal/New()
	..()
	if(TargetExists())
		GLOB.possible_items += src
	else
		qdel(src)

/datum/objective_item/steal/Destroy()
	GLOB.possible_items -= src
	return ..()

// Low risk steal objectives
/datum/objective_item/steal/low_risk
	objective_type = OBJECTIVE_ITEM_TYPE_TRAITOR

/datum/objective_item/steal/low_risk/aicard
	targetitem = /obj/item/aicard
	name = "an intelliCard"
	excludefromjob = list(
		JOB_CAPTAIN,
		JOB_CHIEF_ENGINEER,
		JOB_RESEARCH_DIRECTOR,
		JOB_CHIEF_MEDICAL_OFFICER,
		JOB_HEAD_OF_SECURITY,
		JOB_STATION_ENGINEER,
		JOB_SCIENTIST,
		JOB_ATMOSPHERIC_TECHNICIAN,
	)
	exists_on_map = TRUE

/obj/item/aicard/add_stealing_item_objective()
	ADD_STEAL_ITEM(src, /obj/item/aicard)

// Unique-ish low risk objectives
/datum/objective_item/steal/low_risk/bartender_shotgun
	name = "the bartender's shotgun"
	targetitem = /obj/item/gun/ballistic/shotgun/doublebarrel
	excludefromjob = list(JOB_BARTENDER)
	exists_on_map = TRUE

/obj/item/gun/ballistic/shotgun/doublebarrel/add_stealing_item_objective()
	ADD_STEAL_ITEM(src, /obj/item/gun/ballistic/shotgun/doublebarrel)

/datum/objective_item/steal/low_risk/fireaxe
	name = "a fire axe"
	targetitem = /obj/item/fireaxe
	excludefromjob = list(JOB_CHIEF_ENGINEER,JOB_STATION_ENGINEER,JOB_ATMOSPHERIC_TECHNICIAN)
	exists_on_map = TRUE

/obj/item/fireaxe/add_stealing_item_objective()
	ADD_STEAL_ITEM(src, /obj/item/fireaxe)

/datum/objective_item/steal/low_risk/nullrod
	name = "the chaplain's null rod"
	targetitem = /obj/item/nullrod
	excludefromjob = list(JOB_CHAPLAIN)
	exists_on_map = TRUE

/obj/item/nullrod/add_stealing_item_objective()
	ADD_STEAL_ITEM(src, /obj/item/nullrod)

/datum/objective_item/steal/low_risk/clown_shoes
	name = "the clown's shoes"
	targetitem = /obj/item/clothing/shoes/clown_shoes
	excludefromjob = list(JOB_CLOWN, JOB_CARGO_TECHNICIAN, JOB_QUARTERMASTER)

/datum/objective_item/steal/low_risk/clown_shoes/TargetExists()
	for(var/mob/player as anything in GLOB.player_list)
		if(player.stat == DEAD)
			continue
		if(player.job != JOB_CLOWN)
			continue
		if(is_centcom_level(player.z))
			continue
		return TRUE
	return FALSE

/datum/objective_item/steal/low_risk/cargo_budget
	name = "cargo's departmental budget"
	targetitem = /obj/item/card/id/departmental_budget/car
	excludefromjob = list(JOB_QUARTERMASTER, JOB_CARGO_TECHNICIAN)
	exists_on_map = TRUE

/obj/item/card/id/departmental_budget/car/add_stealing_item_objective()
	ADD_STEAL_ITEM(src, /obj/item/card/id/departmental_budget/car)

// High risk steal objectives
/datum/objective_item/steal/caplaser
	name = "the captain's antique laser gun"
	targetitem = /obj/item/gun/energy/laser/captain
	difficulty = 5
	excludefromjob = list(JOB_CAPTAIN)
	exists_on_map = TRUE

/obj/item/gun/energy/laser/captain/add_stealing_item_objective()
	ADD_STEAL_ITEM(src, /obj/item/gun/energy/laser/captain)

/datum/objective_item/steal/hoslaser
	name = "the head of security's personal laser gun"
	targetitem = /obj/item/gun/energy/e_gun/hos
	difficulty = 10
	excludefromjob = list(JOB_HEAD_OF_SECURITY)
	exists_on_map = TRUE

/obj/item/gun/energy/e_gun/hos/add_stealing_item_objective()
	ADD_STEAL_ITEM(src, /obj/item/gun/energy/e_gun/hos)

/datum/objective_item/steal/handtele
	name = "a hand teleporter"
	targetitem = /obj/item/hand_tele
	difficulty = 5
	excludefromjob = list(JOB_CAPTAIN, JOB_RESEARCH_DIRECTOR, JOB_HEAD_OF_PERSONNEL)
	exists_on_map = TRUE

/obj/item/hand_tele/add_stealing_item_objective()
	ADD_STEAL_ITEM(src, /obj/item/hand_tele)

/datum/objective_item/steal/jetpack
	name = "the Captain's jetpack"
	targetitem = /obj/item/tank/jetpack/oxygen/captain
	difficulty = 5
	excludefromjob = list(JOB_CAPTAIN)
	exists_on_map = TRUE

/obj/item/tank/jetpack/oxygen/captain/add_stealing_item_objective()
	ADD_STEAL_ITEM(src, /obj/item/tank/jetpack/oxygen/captain)

/datum/objective_item/steal/magboots
	name = "the chief engineer's advanced magnetic boots"
	targetitem = /obj/item/clothing/shoes/magboots/advance
	difficulty = 5
	excludefromjob = list(JOB_CHIEF_ENGINEER)
	exists_on_map = TRUE

/obj/item/clothing/shoes/magboots/advance/add_stealing_item_objective()
	ADD_STEAL_ITEM(src, /obj/item/clothing/shoes/magboots/advance)

/datum/objective_item/steal/capmedal
	name = "the medal of captaincy"
	targetitem = /obj/item/clothing/accessory/medal/gold/captain
	difficulty = 5
	excludefromjob = list(JOB_CAPTAIN)
	exists_on_map = TRUE

/obj/item/clothing/accessory/medal/gold/captain/add_stealing_item_objective()
	ADD_STEAL_ITEM(src, /obj/item/clothing/accessory/medal/gold/captain)

/datum/objective_item/steal/hypo
	name = "the hypospray"
	targetitem = /obj/item/reagent_containers/hypospray/cmo
	difficulty = 5
	excludefromjob = list(JOB_CHIEF_MEDICAL_OFFICER)
	exists_on_map = TRUE

/obj/item/reagent_containers/hypospray/cmo/add_stealing_item_objective()
	ADD_STEAL_ITEM(src, /obj/item/reagent_containers/hypospray/cmo)

/datum/objective_item/steal/nukedisc
	name = "the nuclear authentication disk"
	targetitem = /obj/item/disk/nuclear
	difficulty = 5
	excludefromjob = list(JOB_CAPTAIN)

/datum/objective_item/steal/nukedisc/check_special_completion(obj/item/disk/nuclear/N)
	return !N.fake

/datum/objective_item/steal/reflector
	name = "a reflector trenchcoat"
	targetitem = /obj/item/clothing/suit/hooded/ablative
	difficulty = 3
	excludefromjob = list(JOB_HEAD_OF_SECURITY, JOB_WARDEN)
	exists_on_map = TRUE

/obj/item/clothing/suit/hooded/ablative/add_stealing_item_objective()
	ADD_STEAL_ITEM(src, /obj/item/clothing/suit/hooded/ablative)

/datum/objective_item/steal/reactive
	name = "the reactive teleport armor"
	targetitem = /obj/item/clothing/suit/armor/reactive/teleport
	difficulty = 5
	excludefromjob = list(JOB_RESEARCH_DIRECTOR)
	exists_on_map = TRUE

/obj/item/clothing/suit/armor/reactive/teleport/add_stealing_item_objective()
	ADD_STEAL_ITEM(src, /obj/item/clothing/suit/armor/reactive/teleport)

/datum/objective_item/steal/documents
	name = "any set of secret documents of any organization"
	targetitem = /obj/item/documents
	difficulty = 5
	exists_on_map = TRUE

/obj/item/documents/add_stealing_item_objective()
	ADD_STEAL_ITEM(src, /obj/item/documents) //Any set of secret documents. Doesn't have to be NT's

/datum/objective_item/steal/nuke_core
	name = "the heavily radioactive plutonium core from the onboard self-destruct"
	valid_containers = list(/obj/item/nuke_core_container)
	targetitem = /obj/item/nuke_core
	difficulty = 15
	exists_on_map = TRUE

/obj/item/nuke_core/add_stealing_item_objective()
	ADD_STEAL_ITEM(src, /obj/item/nuke_core)

/datum/objective_item/steal/nuke_core/New()
	special_equipment += /obj/item/storage/box/syndie_kit/nuke
	..()

/datum/objective_item/steal/hdd_extraction
	name = "the source code for Project Goon from the master R&D server mainframe"
	targetitem = /obj/item/computer_disk/hdd_theft
	difficulty = 10
	excludefromjob = list(JOB_RESEARCH_DIRECTOR, JOB_SCIENTIST, JOB_ROBOTICIST, JOB_GENETICIST)
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
	difficulty = 15

/datum/objective_item/steal/supermatter/New()
	special_equipment += /obj/item/storage/box/syndie_kit/supermatter
	..()

/datum/objective_item/steal/supermatter/TargetExists()
	return GLOB.main_supermatter_engine != null

//Items with special checks!
/datum/objective_item/steal/plasma
	name = "28 moles of plasma (full tank)"
	targetitem = /obj/item/tank
	difficulty = 3
	excludefromjob = list(
		JOB_CHIEF_ENGINEER, JOB_STATION_ENGINEER, JOB_ATMOSPHERIC_TECHNICIAN,
		JOB_RESEARCH_DIRECTOR, JOB_SCIENTIST, JOB_ROBOTICIST,
	)

/datum/objective_item/steal/plasma/check_special_completion(obj/item/tank/T)
	var/target_amount = text2num(name)
	var/found_amount = 0
	var/datum/gas_mixture/mix = T.return_air()
	found_amount += mix.gases[/datum/gas/plasma] ? mix.gases[/datum/gas/plasma][MOLES] : 0
	return found_amount >= target_amount


/datum/objective_item/steal/functionalai
	name = "a functional AI"
	targetitem = /obj/item/aicard
	difficulty = 20 //beyond the impossible

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
	difficulty = 10
	excludefromjob = list(JOB_CHIEF_ENGINEER)
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

/datum/objective_item/steal/slime
	name = "an unused sample of slime extract"
	targetitem = /obj/item/slime_extract
	difficulty = 3
	excludefromjob = list(JOB_RESEARCH_DIRECTOR, JOB_SCIENTIST)

/datum/objective_item/steal/slime/check_special_completion(obj/item/slime_extract/E)
	if(E.Uses > 0)
		return 1
	return 0

/datum/objective_item/steal/blackbox
	name = "the Blackbox"
	targetitem = /obj/item/blackbox
	difficulty = 10
	excludefromjob = list(JOB_CHIEF_ENGINEER, JOB_STATION_ENGINEER, JOB_ATMOSPHERIC_TECHNICIAN)
	exists_on_map = TRUE

/obj/item/blackbox/add_stealing_item_objective()
	ADD_STEAL_ITEM(src, /obj/item/blackbox)

//Unique Objectives
/datum/objective_item/special/New()
	..()
	if(TargetExists())
		GLOB.possible_items_special += src
	else
		qdel(src)

/datum/objective_item/special/Destroy()
	GLOB.possible_items_special -= src
	return ..()

//Old ninja objectives.
/datum/objective_item/special/pinpointer
	name = "the captain's pinpointer"
	targetitem = /obj/item/pinpointer/nuke
	difficulty = 10
	exists_on_map = TRUE

/obj/item/pinpointer/nuke/add_stealing_item_objective()
	ADD_STEAL_ITEM(src, /obj/item/pinpointer/nuke)

/datum/objective_item/special/aegun
	name = "an advanced energy gun"
	targetitem = /obj/item/gun/energy/e_gun/nuclear
	difficulty = 10

/datum/objective_item/special/ddrill
	name = "a diamond drill"
	targetitem = /obj/item/pickaxe/drill/diamonddrill
	difficulty = 10

/datum/objective_item/special/boh
	name = "a bag of holding"
	targetitem = /obj/item/storage/backpack/holding
	difficulty = 10

/datum/objective_item/special/hypercell
	name = "a hyper-capacity power cell"
	targetitem = /obj/item/stock_parts/cell/hyper
	difficulty = 5

/datum/objective_item/special/laserpointer
	name = "a laser pointer"
	targetitem = /obj/item/laser_pointer
	difficulty = 5

/datum/objective_item/special/corgimeat
	name = "a piece of corgi meat"
	targetitem = /obj/item/food/meat/slab/corgi
	difficulty = 5

/datum/objective_item/stack/New()
	..()
	if(TargetExists())
		GLOB.possible_items_special += src
	else
		qdel(src)

/datum/objective_item/stack/Destroy()
	GLOB.possible_items_special -= src
	return ..()

//Stack objectives get their own subtype
/datum/objective_item/stack
	name = "5 cardboard"
	targetitem = /obj/item/stack/sheet/cardboard
	difficulty = 9001


/datum/objective_item/stack/check_special_completion(obj/item/stack/S)
	var/target_amount = text2num(name)
	var/found_amount = 0

	if(istype(S, targetitem))
		found_amount = S.amount
	return found_amount >= target_amount

/datum/objective_item/stack/diamond
	name = "10 diamonds"
	targetitem = /obj/item/stack/sheet/mineral/diamond
	difficulty = 10

/datum/objective_item/stack/gold
	name = "50 gold bars"
	targetitem = /obj/item/stack/sheet/mineral/gold
	difficulty = 15

/datum/objective_item/stack/uranium
	name = "25 refined uranium bars"
	targetitem = /obj/item/stack/sheet/mineral/uranium
	difficulty = 10

#undef ADD_STEAL_ITEM
