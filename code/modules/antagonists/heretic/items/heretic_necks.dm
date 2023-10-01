/obj/item/clothing/neck/heretic_focus
	name = "Amber Focus"
	desc = "An amber focusing glass that provides a link to the world beyond. The necklace seems to twitch, but only when you look at it from the corner of your eye."
	icon_state = "eldritch_necklace"
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = FIRE_PROOF

/obj/item/clothing/neck/heretic_focus/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/heretic_focus)

/obj/item/clothing/neck/heretic_focus/crimson_focus
	name = "Crimson Focus"
	desc = "A blood-red focusing glass that provides a link to the world beyond, and worse. Its eye is constantly twitching and gazing in all directions. It almost seems to be silently screaming..."
	icon_state = "crimson_focus"

#define COMSIG_CULT_EMPOWER "gingus1"
//#define TRAIT_WEARING_FOCUS "gingus2"

#define COMSIG_ACTION_START_COOLDOWN "gingus3"

#define TRAIT_MANSUS_TOUCHED "gingus4"

/obj/item/clothing/neck/heretic_focus/crimson_focus/equipped(mob/living/user, slot)
	. = ..()
	if(!(slot & ITEM_SLOT_NECK))
		return
	ADD_TRAIT(user, list(TRAIT_MANSUS_TOUCHED, TRAIT_BLOODY_MESS), REF(src))
	to_chat(user, span_alert("Your heart takes on a strange yet soothing irregular rhythm, and your blood feels significantly less viscous than it used to be. You're not sure if that's a good thing."))
	AddComponent( \
		/datum/component/aura_healing, \
		range = 3, \
		brute_heal = 0.1, \
		burn_heal = 0.1, \
		blood_heal = 0.1, \
		suffocation_heal = 1, \ // blood gets to where it needs to be quicker
		simple_heal = 0.6, \
		requires_visibility = FALSE, \
		limit_to_trait = TRAIT_MANSUS_TOUCHED, \
		healing_color = COLOR_CULT_RED, \
		)
	if(IS_CULTIST(user))
		RegisterSignal(user, COMSIG_CULT_EMPOWER, PROC_REF(buff_empower))
	if(IS_HERETIC_OR_MONSTER(user))
		RegisterSignal(user, COMSIG_ACTION_START_COOLDOWN, PROC_REF(halve_cooldowns))

/obj/item/clothing/neck/heretic_focus/crimson_focus/dropped(mob/living/user)
	. = ..()
	UnregisterSignal(user, list(COMSIG_CULT_EMPOWER, COMSIG_ACTION_START_COOLDOWN))
	REMOVE_TRAIT(user, list(TRAIT_MANSUS_TOUCHED, TRAIT_BLOODY_MESS), REF(src))
	to_chat(user, span_notice("Your heart and blood return to their regular boring rhythm and flow."))

/obj/item/clothing/neck/heretic_focus/crimson_focus/proc/buff_empower(mob/user, signal_return_list)
	SIGNAL_HANDLER

	signal_return_list["limit_data"] += 1
	signal_return_list["speed_data"] *= 0.5

/obj/item/clothing/neck/heretic_focus/crimson_focus/proc/halve_cooldowns(mob/user, signal_return_list)
	SIGNAL_HANDLER

	signal_return_list["cd_data"] = signal_return_list["override_data"] ? signal_return_list["override_data"] * 0.5 : signal_return_list["cd_data"] * 0.5

/obj/item/clothing/neck/heretic_focus/crimson_focus/examine(mob/user)
	. = ..()

	if(IS_CULTIST(user))
		. += span_cultbold("This focus will allow you to store one extra spell and halve the empowering time, alongside providing a small regenerative effect.")
	if(IS_HERETIC_OR_MONSTER(user))
		. += span_notice("This focus will halve your spell cooldowns, alongside granting a small regenerative effect.")
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
