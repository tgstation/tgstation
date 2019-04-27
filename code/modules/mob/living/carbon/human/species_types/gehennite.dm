/datum/species/gehennite
	name = "Gehennite"
	sexes = 0
	id = "gehennite"
	inherent_traits = list(TRAIT_NOBREATH)
	mutantears = /obj/item/organ/ears/gehennite
	alternative_body_icon = 'icons/mob/gehennite_parts.dmi'

/datum/species/gehennite/on_species_gain(mob/living/carbon/human/H, datum/species/old_species)
	. = ..()
	H.become_blind(ROUNDSTART_TRAIT)
	H.overlay_fullscreen("total", /obj/screen/fullscreen/color_vision/black)

/datum/species/gehennite/on_species_loss(mob/living/carbon/human/H)
	.=..()
	H.clear_fullscreen("total")

/datum/action/innate/echo
	name = "Echolocate"
	check_flags = AB_CHECK_CONSCIOUS
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "meson"

/datum/action/innate/echo/Activate()
	SEND_SIGNAL(owner, COMSIG_ECHOLOCATION_PING)



