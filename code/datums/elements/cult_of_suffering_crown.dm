/datum/element/cult_of_suffering_crown
	icon = 'icons/mob/effects/demonic_crown.dmi'
	icon_state = "demonic_crown"


/datum/element/cult_of_suffering_crown/Attach()
	. = ..()
	if (!isliving(target))
		return ELEMENT_INCOMPATIBLE

	var/mob/living/living_target = target
	var/mutable_appearance/crown = mutable_appearance(icon, icon_state, -HALO_LAYER)
	crown.pixel_z = 24
	living_target.add_overlay(crown)

/datum/element/cult_of_suffering_crown/Detach()
	target.cut_overlay(HALO_LAYER)
	return ..()
