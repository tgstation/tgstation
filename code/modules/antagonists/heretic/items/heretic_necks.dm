/obj/item/clothing/neck/heretic_focus
	name = "Amber Focus"
	desc = "A amber focusing glass that provides a link to the world beyond. The necklace seems to twitch, but only when you look at it from the corner of your eye."
	icon_state = "eldritch_necklace"
	w_class = WEIGHT_CLASS_SMALL
	clothing_traits = list(TRAIT_ALLOW_HERETIC_CASTING)

/obj/item/clothing/neck/heretic_focus/examine(mob/user)
	. = ..()
	if(!IS_HERETIC(user))
		return

	. += span_notice("Allows you to cast advanced heretic spells when worn.")

/obj/item/clothing/neck/eldritch_amulet
	name = "Warm Eldritch Medallion"
	desc = "A strange medallion. Peering through the crystalline surface, the world around you melts away. You see your own beating heart, and the pulsing of a thousand others."
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "eye_medalion"
	w_class = WEIGHT_CLASS_SMALL
	/// Clothing trait only applied to heretics.
	var/heretic_only_trait = TRAIT_THERMAL_VISION

/obj/item/clothing/neck/eldritch_amulet/equipped(mob/user, slot)
	. = ..()
	if(slot != ITEM_SLOT_NECK)
		return
	if(!ishuman(user) || !IS_HERETIC_OR_MONSTER(user))
		return

	ADD_TRAIT(user, heretic_only_trait, "[CLOTHING_TRAIT] [REF(src)]")
	user.update_sight()

/obj/item/clothing/neck/eldritch_amulet/dropped(mob/user)
	. = ..()
	REMOVE_TRAIT(user, heretic_only_trait, "[CLOTHING_TRAIT] [REF(src)]")
	user.update_sight()

/obj/item/clothing/neck/eldritch_amulet/piercing
	name = "Piercing Eldritch Medallion"
	desc = "A strange medallion. Peering through the crystalline surface, the light refracts into new and terrifying spectrums of color. You see yourself, reflected off cascading mirrors, warped into impossible shapes."
	heretic_only_trait = TRAIT_XRAY_VISION
