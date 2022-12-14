/obj/structure/closet/crate/syndicrate
	name = "surplus syndicrate"
	desc = "A conspicuous crate with the Syndicate logo on it. You don't know how to open it."
	icon_state = "syndicrate"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	integrity_failure = 0 //prevents bust_open from activating
	/// variable that only lets the crate open if opened by a key from the uplink
	var/unlocked = FALSE

/obj/structure/closet/crate/syndicrate/attackby(obj/item/item, mob/user, params)
	if(!istype(item, /obj/item/syndicrate_key) || unlocked)
		return ..()
	unlocked = TRUE
	qdel(item)
	to_chat(user, span_notice("You twist the key into both locks at once, opening the crate."))

/obj/structure/closet/crate/syndicrate/can_open(mob/living/user, force = FALSE)
	if(!unlocked)
		balloon_alert(user, "Locked!")
		return FALSE
	return ..()

/obj/item/syndicrate_key
	name = "syndicrate key"
	desc = "A device similar to a key, capable of splitting itself into two. Can be used to open one syndicrate."
	icon = 'icons/obj/storage/crates.dmi'
	icon_state = "syndicrate_key"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/syndicrate_key/Initialize(mapload)
	. = ..()
	register_item_context()

/obj/item/add_item_context(obj/item/source, list/context, atom/target, mob/living/user,)
	. = ..()

	var/obj/structure/closet/crate/syndicrate/target_structure = target
	if(!istype(target_structure))
		return NONE
	if(target_structure.unlocked)
		return NONE
	context[SCREENTIP_CONTEXT_LMB] = "Unlock Syndicrate"
	return CONTEXTUAL_SCREENTIP_SET
