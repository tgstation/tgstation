/datum/quirk/all_nighter
	name = "All Nighter"
	desc = "You didn't get any sleep last night, and people can tell! You'll constantly be in a bad mood and will have a tendency to sleep longer."
	icon = FA_ICON_BED
	value = -4
	mob_trait = list(TRAIT_ALL_NIGHTER, TRAIT_HEAVY_SLEEPER)
	gain_text = span_danger("You feel exhausted.")
	lose_text = span_notice("You feel well rested.")
	medical_record_text = "Patient appears to be suffering from sleep deprivation."
	hardcore_value = 4
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_CHANGES_APPEARANCE|QUIRK_MOODLET_BASED
	mail_goodies = list(
		/obj/item/clothing/glasses/blindfold,
		/obj/item/bedsheet/random,
		/obj/item/clothing/under/misc/pj/red,
		/obj/item/clothing/head/costume/nightcap/red,
		/obj/item/clothing/under/misc/pj/blue,
		/obj/item/clothing/head/costume/nightcap/blue,
		/obj/item/pillow/random,
	)

///adds the corresponding moodlet and visual effects
/datum/quirk/all_nighter/add(client/client_source)
	quirk_holder.add_mood_event("all_nighter", /datum/mood_event/all_nighter)
	// this stuff is for eye bags
	var/mob/living/carbon/human/sleepy_head = quirk_holder
	var/obj/item/bodypart/head/face = sleepy_head.get_bodypart(BODY_ZONE_HEAD)
	face.add_bodypart_overlay(new /datum/bodypart_overlay/simple/bags())
	sleepy_head.update_body_parts()

///removes the corresponding moodlet and visual effects
/datum/quirk/all_nighter/remove(client/client_source)
	quirk_holder.clear_mood_event("all_nighter", /datum/mood_event/all_nighter)
	// this stuff is for eye bags
	var/mob/living/carbon/human/sleepy_head = quirk_holder
	var/obj/item/bodypart/head/face = sleepy_head.get_bodypart(BODY_ZONE_HEAD)
	face.remove_bodypart_overlay(/datum/bodypart_overlay/simple/bags())
	sleepy_head.update_body_parts()
