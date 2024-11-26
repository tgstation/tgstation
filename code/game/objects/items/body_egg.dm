/obj/item/organ/body_egg
	name = "body egg"
	desc = "All slimy and yuck."
	icon_state = "innards"
	visual = TRUE
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_PARASITE_EGG

/obj/item/organ/body_egg/on_find(mob/living/finder)
	..()
	to_chat(finder, span_warning("You found an unknown alien organism in [owner]'s [zone]!"))

/obj/item/organ/body_egg/Initialize(mapload)
	. = ..()
	if(iscarbon(loc))
		Insert(loc)

/obj/item/organ/body_egg/on_mob_insert(mob/living/carbon/egg_owner, special = FALSE, movement_flags)
	. = ..()

	egg_owner.add_traits(list(TRAIT_XENO_HOST, TRAIT_XENO_IMMUNE), ORGAN_TRAIT)
	egg_owner.med_hud_set_status()
	INVOKE_ASYNC(src, PROC_REF(AddInfectionImages), egg_owner)

/obj/item/organ/body_egg/on_mob_remove(mob/living/carbon/egg_owner, special, movement_flags)
	. = ..()
	egg_owner.remove_traits(list(TRAIT_XENO_HOST, TRAIT_XENO_IMMUNE), ORGAN_TRAIT)
	egg_owner.med_hud_set_status()
	INVOKE_ASYNC(src, PROC_REF(RemoveInfectionImages), egg_owner)

/obj/item/organ/body_egg/on_death(seconds_per_tick, times_fired)
	. = ..()
	if(!owner)
		return
	egg_process(seconds_per_tick, times_fired)

/obj/item/organ/body_egg/on_life(seconds_per_tick, times_fired)
	. = ..()
	egg_process(seconds_per_tick, times_fired)

/obj/item/organ/body_egg/proc/egg_process(seconds_per_tick, times_fired)
	return

/obj/item/organ/body_egg/proc/RefreshInfectionImage()
	RemoveInfectionImages()
	AddInfectionImages()

/obj/item/organ/body_egg/proc/AddInfectionImages()
	return

/obj/item/organ/body_egg/proc/RemoveInfectionImages()
	return
