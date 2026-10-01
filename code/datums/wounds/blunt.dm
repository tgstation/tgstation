/datum/wound/blunt
	name = "Blunt Wound"
	sound_effect = 'sound/effects/wounds/crack1.ogg'
	undiagnosed_name = "Painful Bruising"
	a_or_from = "some"

/datum/wound/blunt/wound_injury(datum/wound/old_wound, attack_direction)
	var/obj/item/stack/medical/wrap/current_gauze = LAZYACCESS(limb.applied_items, LIMB_ITEM_GAUZE)
	if(!old_wound && !isnull(current_gauze) && (wound_flags & ACCEPTS_GAUZE))
		// oops your bone injury knocked off your gauze, gotta re-apply it
		current_gauze.forceMove(limb.drop_location())

	return ..()
