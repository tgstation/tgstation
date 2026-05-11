/datum/element/cult_of_suffering_crown
	// icon = 'icons/mob/effects/demonic_crown.dmi'
	// icon_state = "demonic_crown"


/datum/element/cult_of_suffering_crown/Attach(datum/target)
	. = ..()
	if (!isliving(target))
		return ELEMENT_INCOMPATIBLE

	var/mob/living/living_target = target
	var/mutable_appearance/crown = mutable_appearance('icons/mob/effects/demonic_crown.dmi', "demonic_crown", -HALO_LAYER)
	crown.pixel_z = 12
	crown.pixel_x = -1
	living_target.add_overlay(crown)


	var/mob/living/carbon/human/human_target = living_target
	human_target.set_hairstyle("Bald", update = TRUE)
	human_target.set_facial_hairstyle("Shaved", update = TRUE)

	// var/image/tattoo = image('icons/mob/human/human_markings.dmi', "tattoo_heart")
	// tattoo.layer = -BODY_LAYER
	// human_target.add_overlay(tattoo)

	// Чёрные штаны
	var/obj/item/clothing/under/color/black/pants = new(get_turf(human_target))
	human_target.equip_to_slot_if_possible(pants, ITEM_SLOT_ICLOTHING, FALSE, TRUE)

/datum/element/cult_of_suffering_crown/Detach(datum/target, ...)
	if(isliving(target))
		var/mob/living/living_target = target
		living_target.cut_overlay(HALO_LAYER)
	return ..()
