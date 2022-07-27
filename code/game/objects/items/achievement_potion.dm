/// Potions that can be toggled at roundstart to give a gold version of achievement items.

/datum/preference/toggle/achievement_potions
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "achievement_potions"

/datum/preference/toggle/achievement_potions/is_accessible(datum/preferences/achievement_preferences)
	if (!..(achievement_preferences))
		return FALSE

	return achievement_preferences.parent?.owns_potion()

/// Checks if they own any potion varient
/client/proc/owns_potion()
	if(get_award_status(CHEF_TOURISTS_SERVED) >= 5000 || get_award_status(BARTENDER_TOURISTS_SERVED) >= 5000 || get_award_status(HARDCORE_RANDOM_SCORE) >= 5000)
		return TRUE

/obj/item/achievement_potion
	name = "midas potion"
	desc = "A potion turning job equipment to gold!"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "achievement_potion"
	custom_materials = list(/datum/material/glass=500, /datum/material/gold=1200)
		///Achievement items.
	var/golden_knife = FALSE
	var/golden_shaker = FALSE
	var/golden_wheelchair = FALSE

/obj/item/achievement_potion/bartender
	name = "bartender's midas potion"
	desc = "A reward for Nanotrasen's most prolific batenders!"
	golden_shaker = TRUE

/obj/item/achievement_potion/cook
	name = "chef's midas potion"
	desc = "A reward for Nanotrasen's most prolific chefs!"
	golden_knife = TRUE

/obj/item/achievement_potion/hardcore
	name = "martyr's midas potion"
	desc = "You must've seen some shit to get a hold of this."
	golden_wheelchair = TRUE
