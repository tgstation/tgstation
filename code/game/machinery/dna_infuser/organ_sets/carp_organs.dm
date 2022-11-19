///bonus of the carp: you can swim through space!
/datum/status_effect/organ_set_bonus/carp
	organs_needed = 1
	bonus_activate_text = "Carp DNA is deeply infused with you! You've learned how to propel yourself through space!"
	bonus_deactivate_text = "Your DNA is once again mostly yours, and so fades your ability to space-swim..."

/datum/status_effect/organ_set_bonus/carp/enable_bonus()
	. = ..()
	ADD_TRAIT(src, TRAIT_SPACEWALK, REF(src))

/datum/status_effect/organ_set_bonus/carp/disable_bonus()
	. = ..()
	REMOVE_TRAIT(src, TRAIT_SPACEWALK, REF(src))

///Carp lungs! You can breathe in space! Oh... you can't breathe on the station.
/obj/item/organ/internal/lungs/carp
	name = "mutated carp-lungs"
	desc = "Carp DNA infused into what was once some normal lungs."
	safe_oxygen_max = 16
	safe_oxygen_min = 0

/obj/item/organ/internal/lungs/carp/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/noticable_organ, "has gills poking out of their neck.", BODY_ZONE_HEAD)
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/carp)
