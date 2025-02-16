
/obj/item/clothing/head/mob_holder/Initialize(mapload, mob/living/M, worn_state, head_icon, lh_icon, rh_icon, worn_slot_flags = NONE)
	. = ..()
	SEND_SIGNAL(M, COMSIG_ADDING_MOB_HOLDER_SPECIALS, M, src)


// CARP TONGUE WIRECUTTERS

/obj/item/organ/tongue/carp/on_mob_insert(mob/living/carbon/tongue_owner, special, movement_flags)
	. = ..()
	if(!ishuman(tongue_owner))
		return
	RegisterSignal(tongue_owner, COMSIG_ADDING_MOB_HOLDER_SPECIALS, PROC_REF(on_adding_mob_holder_specials))

/obj/item/organ/tongue/carp/on_mob_remove(mob/living/carbon/tongue_owner)
	. = ..()
	if(!ishuman(tongue_owner))
		return
	UnregisterSignal(tongue_owner, COMSIG_ADDING_MOB_HOLDER_SPECIALS)
	
/obj/item/organ/tongue/carp/proc/on_adding_mob_holder_specials(datum/source, mob/living/held_creature, obj/item/clothing/head/mob_holder/our_holder)
	SIGNAL_HANDLER
	if(!held_creature.has_quirk(/datum/quirk/undersized))
		return
	// Make our little carp an effective wirecutter <3
	our_holder.tool_behaviour = TOOL_WIRECUTTER
	our_holder.toolspeed = 1
	our_holder.attack_verb_continuous = list("pinches", "nips")
	our_holder.attack_verb_simple = list("pinch", "nip")
	our_holder.hitsound = 'sound/items/tools/wirecutter.ogg'
	our_holder.usesound = 'sound/items/tools/wirecutter.ogg'
	our_holder.operating_sound = 'sound/items/tools/wirecutter_cut.ogg'
	our_holder.drop_sound = 'sound/items/handling/tools/wirecutter_drop.ogg'
	our_holder.pickup_sound = 'sound/items/handling/tools/wirecutter_pickup.ogg'
	// And a decently effective weapon
	our_holder.force = 10
	our_holder.throw_speed = 3
	our_holder.throw_range = 7
