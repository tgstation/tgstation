/datum/quirk/evil
	name = "Fundamentally Evil"
	desc = "Where you would have a soul is but an ink-black void. While you are committed to maintaining your social standing, \
		anyone who stares too long into your cold, uncaring eyes will know the truth. You are truly evil. There is nothing \
		wrong with you. You chose to be evil, committed to it. Your ambitions come first above all."
	icon = FA_ICON_HAND_MIDDLE_FINGER
	value = 0
	mob_trait = TRAIT_EVIL
	gain_text = span_notice("You shed what little remains of your humanity. You have work to do.")
	lose_text = span_notice("You suddenly care more about others and their needs.")
	medical_record_text = "Patient has passed all our social fitness tests with flying colours, but had trouble on the empathy tests."
	mail_goodies = list(/obj/item/food/grown/citrus/lemon)

	/// Weak reference to the component handling our allergy to *love*
	var/datum/weakref/added_allergies

/datum/quirk/evil/add_unique(client/client_source)
	var/mob/living/carbon/human/human_quirkholder = quirk_holder
	var/obj/item/organ/heart/holder_heart = human_quirkholder.get_organ_slot(ORGAN_SLOT_HEART)
	if(isnull(holder_heart) || isnull(holder_heart.reagents))
		return
	// Our actions have evaporated all the love that was once in our heart
	holder_heart.reagents.del_reagent(/datum/reagent/love)

/datum/quirk/evil/post_add()
	var/evil_policy = get_policy("[type]") || "Please note that while you may be [LOWER_TEXT(name)], this does NOT give you any additional right to attack people or cause chaos."
	// We shouldn't need this, but it prevents people using it as a dumb excuse in ahelps.
	to_chat(quirk_holder, span_big(span_info(evil_policy)))
	// The power of love conquers all.
	added_allergies = WEAKREF(quirk_holder.AddComponent(/datum/component/reagent_allergies, allergy_types = list(/datum/reagent/love)))

/datum/quirk/item_quirk/allergic/remove()
	QDEL_NULL(added_allergies)
