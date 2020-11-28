/datum/augment_item
	var/name
	///Category in which the augment belongs to. check "_DEFINES/augment.dm"
	var/category = AUGMENT_CATEGORY_NONE
	///Slot in which the augment belongs to, MAKE SURE THE SAME SLOT IS ONLY IN ONE CATEGORY
	var/slot = AUGMENT_SLOT_NONE
	///Description of the loadout augment, automatically set by New() if null
	var/description
	///Typepath to the augment being used
	var/path
	///How much quirky points does it cost?
	var/cost = 0
	///Which biotypes are allowed to recieve the augment
	var/allowed_biotypes = MOB_ORGANIC

/datum/augment_item/New()
	if(!description && path)
		var/obj/O = path
		description = initial(O.desc)

/datum/augment_item/proc/apply(mob/living/carbon/human/H, character_setup = FALSE, datum/preferences/prefs)
	return
