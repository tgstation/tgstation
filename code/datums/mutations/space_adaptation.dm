//Cold Resistance gives your entire body an orange halo, and makes you immune to the effects of vacuum and cold.
/datum/mutation/human/space_adaptation
	name = "Space Adaptation"
<<<<<<< HEAD
	desc = "A strange mutation that renders the host immune to the vacuum of space. Will still need an oxygen supply."
=======
	desc = "A strange mutation that renders the host immune to the vacuum if space. Will still need an oxygen supply."
>>>>>>> Updated this old code to fork
	quality = POSITIVE
	difficulty = 16
	text_gain_indication = "<span class='notice'>Your body feels warm!</span>"
	time_coeff = 5
	instability = 30

<<<<<<< HEAD
/datum/mutation/human/space_adaptation/New(class_ = MUT_OTHER, timer, datum/mutation/human/copymut)
=======
/datum/mutation/human/space_adaptation/New()
>>>>>>> Updated this old code to fork
	..()
	if(!(type in visual_indicators))
		visual_indicators[type] = list(mutable_appearance('icons/effects/genetics.dmi', "fire", -MUTATIONS_LAYER))

/datum/mutation/human/space_adaptation/get_visual_indicator()
	return visual_indicators[type][1]

/datum/mutation/human/space_adaptation/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
<<<<<<< HEAD
	ADD_TRAIT(owner, TRAIT_RESISTCOLD, "space_adaptation")
	ADD_TRAIT(owner, TRAIT_RESISTLOWPRESSURE, "space_adaptation")
=======
	owner.add_trait(TRAIT_RESISTCOLD, "space_adaptation")
	owner.add_trait(TRAIT_RESISTLOWPRESSURE, "space_adaptation")
>>>>>>> Updated this old code to fork

/datum/mutation/human/space_adaptation/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
<<<<<<< HEAD
	REMOVE_TRAIT(owner, TRAIT_RESISTCOLD, "space_adaptation")
	REMOVE_TRAIT(owner, TRAIT_RESISTLOWPRESSURE, "space_adaptation")
=======
	owner.remove_trait(TRAIT_RESISTCOLD, "space_adaptation")
	owner.remove_trait(TRAIT_RESISTLOWPRESSURE, "space_adaptation")
>>>>>>> Updated this old code to fork

