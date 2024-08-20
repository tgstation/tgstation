#define MAX_STORED_CASSETTES 		28
#define DEFAULT_CASSETTES_TO_SPAWN 	5
#define DEFAULT_BLANKS_TO_SPAWN 	10

/obj/structure/cassette_rack
	name = "cassette pouch"
	desc = "Safely holds cassettes for storage."
	icon = 'monkestation/code/modules/cassettes/icons/radio_station.dmi'
	icon_state = "cassette_pouch"
	anchored = FALSE
	density = FALSE

/obj/structure/cassette_rack/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/cassette_rack)
	if(mapload)
		set_anchored(TRUE)

/obj/structure/cassette_rack/update_overlays()
	. = ..()
	var/number = length(contents) ? min(length(contents), 7) : 0
	. += mutable_appearance(icon, "[icon_state]_[number]")

/datum/storage/cassette_rack
	max_slots = MAX_STORED_CASSETTES
	max_specific_storage = WEIGHT_CLASS_SMALL
	max_total_storage = WEIGHT_CLASS_SMALL * MAX_STORED_CASSETTES
	numerical_stacking = TRUE

/datum/storage/cassette_rack/New()
	. = ..()
	set_holdable(/obj/item/device/cassette_tape)

// Allow opening on a normal left click
/datum/storage/cassette_rack/on_attack(datum/source, mob/user)
	var/obj/structure/cassette_rack/resolve_parent = parent?.resolve()
	if(!resolve_parent)
		return
	if(QDELETED(user) || !user.Adjacent(resolve_parent) || user.incapacitated() || !user.canUseStorage())
		return ..()
	INVOKE_ASYNC(src, PROC_REF(open_storage), user)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/structure/cassette_rack/prefilled
	var/spawn_random = DEFAULT_CASSETTES_TO_SPAWN
	var/spawn_blanks = DEFAULT_BLANKS_TO_SPAWN

/obj/structure/cassette_rack/prefilled/Initialize(mapload)
	. = ..()
	REGISTER_REQUIRED_MAP_ITEM(1, INFINITY)
	RegisterSignal(SSdcs, COMSIG_GLOB_CREWMEMBER_JOINED, PROC_REF(spawn_curator_tapes))
	for(var/i in 1 to spawn_blanks)
		new /obj/item/device/cassette_tape/blank(src)
	for(var/id in unique_random_tapes(spawn_random))
		new /obj/item/device/cassette_tape(src, id)
	update_appearance()

/obj/structure/cassette_rack/prefilled/Destroy()
	UnregisterSignal(SSdcs, COMSIG_GLOB_CREWMEMBER_JOINED)
	return ..()

/obj/structure/cassette_rack/prefilled/proc/spawn_curator_tapes(datum/source, mob/living/new_crewmember, rank)
	SIGNAL_HANDLER
	if(QDELETED(new_crewmember) || new_crewmember.stat == DEAD || !new_crewmember.ckey)
		return
	if(!istype(new_crewmember.mind?.assigned_role, /datum/job/curator))
		return
	add_user_tapes(new_crewmember.ckey)

/obj/structure/cassette_rack/prefilled/proc/add_user_tapes(user_ckey, max_amt = 3, expand_max_size = TRUE)
	var/list/user_tapes = SScassette_storage.get_cassettes_by_ckey(user_ckey)
	if(!length(user_tapes))
		return FALSE
	var/list/existing_tapes = list()
	for(var/obj/item/device/cassette_tape/tape in src)
		if(tape.id)
			existing_tapes[tape.id] = TRUE
	for(var/iter in 1 to max_amt)
		if(!length(user_tapes))
			break
		var/datum/cassette_data/tape = pick_n_take(user_tapes)
		if(existing_tapes[tape.cassette_id])
			continue
		new /obj/item/device/cassette_tape(src, tape.cassette_id)
	if(expand_max_size && !QDELETED(atom_storage))
		atom_storage.max_slots += max_amt
		atom_storage.max_total_storage += max_amt * WEIGHT_CLASS_SMALL
	return TRUE

#undef DEFAULT_BLANKS_TO_SPAWN
#undef DEFAULT_CASSETTES_TO_SPAWN
#undef MAX_STORED_CASSETTES
