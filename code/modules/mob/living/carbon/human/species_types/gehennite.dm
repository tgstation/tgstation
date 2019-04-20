/datum/species/gehennite
	name = "Gehennite"
	id = "gehennite"
	inherent_traits = list(TRAIT_NOBREATH)
	mutantears = /obj/item/organ/ears/gehennite

/datum/species/gehennite/on_species_gain(mob/living/carbon/human/H, datum/species/old_species)
	. = ..()
	H.become_blind(ROUNDSTART_TRAIT)


/datum/action/innate/echo
	name = "Echolocate"
	check_flags = AB_CHECK_CONSCIOUS
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "meson"

/datum/action/innate/echo/Activate()
	SEND_SIGNAL(owner, COMSIG_ECHOLOCATION_PING)



