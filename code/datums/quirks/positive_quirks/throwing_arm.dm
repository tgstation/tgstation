/datum/quirk/throwingarm
	name = "Throwing Arm"
	desc = "Your arms have a lot of heft to them! Objects that you throw just always seem to fly further than everyone elses, and you never miss a toss."
	icon = FA_ICON_BASEBALL
	value = 7
	mob_trait = TRAIT_THROWINGARM
	gain_text = span_notice("Your arms are full of energy!")
	lose_text = span_danger("Your arms ache a bit.")
	medical_record_text = "Patient displays mastery over throwing balls."
	mail_goodies = list(/obj/item/toy/beach_ball/baseball, /obj/item/toy/basketball, /obj/item/toy/dodgeball)
