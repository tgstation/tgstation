/obj/item/clothing/neck/heretic_focus
	name = "Amber Focus"
	desc = "An amber focusing glass that provides a link to the world beyond. The necklace seems to twitch, but only when you look at it from the corner of your eye."
	icon_state = "eldritch_necklace"
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = FIRE_PROOF

/obj/item/clothing/neck/heretic_focus/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/heretic_focus)

/obj/item/clothing/neck/eldritch_amulet
	name = "Warm Eldritch Medallion"
	desc = "A strange medallion. Peering through the crystalline surface, the world around you melts away. You see your own beating heart, and the pulsing of a thousand others."
	icon = 'icons/obj/antags/eldritch.dmi'
	icon_state = "eye_medalion"
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	/// A secondary clothing trait only applied to heretics.
	var/heretic_only_trait = TRAIT_THERMAL_VISION

/obj/item/clothing/neck/eldritch_amulet/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/heretic_focus)

/obj/item/clothing/neck/eldritch_amulet/equipped(mob/user, slot)
	. = ..()
	if(!(slot & ITEM_SLOT_NECK))
		return
	if(!ishuman(user) || !IS_HERETIC_OR_MONSTER(user))
		return

	ADD_TRAIT(user, heretic_only_trait, "[CLOTHING_TRAIT]_[REF(src)]")
	user.update_sight()

/obj/item/clothing/neck/eldritch_amulet/dropped(mob/user)
	. = ..()
	REMOVE_TRAIT(user, heretic_only_trait, "[CLOTHING_TRAIT]_[REF(src)]")
	user.update_sight()

/obj/item/clothing/neck/eldritch_amulet/piercing
	name = "Piercing Eldritch Medallion"
	desc = "A strange medallion. Peering through the crystalline surface, the light refracts into new and terrifying spectrums of color. You see yourself, reflected off cascading mirrors, warped into impossible shapes."
	heretic_only_trait = TRAIT_XRAY_VISION

// Cosmetic-only version
/obj/item/clothing/neck/fake_heretic_amulet
	name = "religious icon"
	desc = "A strange medallion, which makes its wearer look like they're part of some cult."
	icon = 'icons/obj/antags/eldritch.dmi'
	icon_state = "eye_medalion"
	w_class = WEIGHT_CLASS_SMALL


// The amulet conversion tool used by moon heretics
/obj/item/clothing/neck/heretic_focus/moon_amulet
	name = "Moonlight Amulet"
	desc = "A piece of the mind, the soul and the moon. Gazing into it makes your head spin and hear whispers of laughter and joy."
	icon = 'icons/obj/antags/eldritch.dmi'
	icon_state = "moon_amulette"
	w_class = WEIGHT_CLASS_SMALL
	// How much damage does this item do to the targets sanity?
	var/sanity_damage = 20

/obj/item/clothing/neck/heretic_focus/moon_amulet/attack(mob/living/target, mob/living/user, params)
	var/mob/living/carbon/human/hit = target
	if(!IS_HERETIC_OR_MONSTER(user))
		user.balloon_alert(user, "you feel a presence watching you")
		user.add_mood_event("Moon Amulet Insanity", /datum/mood_event/amulet_insanity)
		user.mob_mood.set_sanity(user.mob_mood.sanity - 50)
		return
	if(hit.can_block_magic())
		return
	if(!hit.mob_mood)
		return
	if(hit.mob_mood.sanity_level < SANITY_LEVEL_UNSTABLE)
		user.balloon_alert(user, "their mind is too strong!")
		hit.add_mood_event("Moon Amulet Insanity", /datum/mood_event/amulet_insanity)
		hit.mob_mood.set_sanity(hit.mob_mood.sanity - sanity_damage)
	else
		user.balloon_alert(user, "their mind bends to see the truth!")
		hit.apply_status_effect(/datum/status_effect/moon_converted)
		user.log_message("made [target] insane.", LOG_GAME)
		hit.log_message("was driven insane by [user]")
	. = ..()
