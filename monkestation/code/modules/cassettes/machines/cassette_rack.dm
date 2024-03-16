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
	for(var/i in 1 to spawn_blanks)
		new /obj/item/device/cassette_tape/blank(src)
	for(var/id in unique_random_tapes(spawn_random))
		new /obj/item/device/cassette_tape(src, id)
	update_appearance()

#undef DEFAULT_BLANKS_TO_SPAWN
#undef DEFAULT_CASSETTES_TO_SPAWN
#undef MAX_STORED_CASSETTES
