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
