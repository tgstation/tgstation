/datum/quirk/friendly
	name = "Friendly"
	desc = "You give the best hugs, especially when you're in the right mood."
	icon = FA_ICON_HANDS_HELPING
	value = 2
	mob_trait = TRAIT_FRIENDLY
	gain_text = span_notice("You want to hug someone.")
	lose_text = span_danger("You no longer feel compelled to hug others.")
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_MOODLET_BASED
	medical_record_text = "Patient demonstrates low-inhibitions for physical contact and well-developed arms. Requesting another doctor take over this case."
	mail_goodies = list(/obj/item/storage/box/hug)

/datum/quirk/friendly/add_unique(client/client_source)
	var/mob/living/carbon/human/human_quirkholder = quirk_holder
	var/obj/item/organ/heart/holder_heart = human_quirkholder.get_organ_slot(ORGAN_SLOT_HEART)
	if(isnull(holder_heart) || isnull(holder_heart.reagents))
		return
	holder_heart.reagents.maximum_volume = 20
	// We have a bigger heart full of love!
	holder_heart.reagents.add_reagent(/datum/reagent/love, 2.5)
	// Like, physically bigger.
	holder_heart.reagents.add_reagent(/datum/reagent/consumable/nutriment/organ_tissue, 5)
	holder_heart.transform = holder_heart.transform.Scale(1.5)
