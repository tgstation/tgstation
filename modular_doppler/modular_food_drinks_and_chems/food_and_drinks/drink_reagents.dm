/datum/reagent/consumable/pinkmilk
	name = "Strawberry Milk"
	description = "A drink of a bygone era of milk and artificial sweetener back on a rock."
	color = "#f76aeb"//rgb(247, 106, 235)
	quality = DRINK_VERYGOOD
	taste_description = "sweet strawberry and milk cream"

/datum/glass_style/drinking_glass/pinkmilk
	required_drink_type = /datum/reagent/consumable/pinkmilk
	icon = 'modular_doppler/modular_food_drinks_and_chems/icons/drinks.dmi'
	icon_state = "pinkmilk"
	name = "tall glass of strawberry milk"
	desc = "Delicious flavored strawberry syrup mixed with milk."

/datum/reagent/consumable/pinkmilk/on_mob_life(mob/living/carbon/M)
	if(prob(15))
		to_chat(M, span_notice("[pick("You cant help to smile.","You feel nostalgia all of sudden.","You remember to relax.")]"))
	..()
	. = 1

/datum/reagent/consumable/pinktea
	name = "Strawberry Tea"
	description = "A timeless classic!"
	color = "#f76aeb"//rgb(247, 106, 235)
	quality = DRINK_VERYGOOD
	taste_description = "sweet tea with a hint of strawberry"

/datum/glass_style/drinking_glass/pinktea
	required_drink_type = /datum/reagent/consumable/pinktea
	icon = 'modular_doppler/modular_food_drinks_and_chems/icons/drinks.dmi'
	icon_state = "pinktea"
	name = "mug of strawberry tea"
	desc = "Delicious traditional tea flavored with strawberries."

/datum/reagent/consumable/pinktea/on_mob_life(mob/living/carbon/M)
	if(prob(10))
		to_chat(M, span_notice("[pick("Diamond skies where white deer fly.","Sipping strawberry tea.","Silver raindrops drift through timeless, Neverending June.","Crystal ... pearls free, with love!","Beaming love into me.")]"))
	..()
	. = TRUE

/datum/reagent/consumable/catnip_tea
	name = "Catnip Tea"
	description = "A sleepy and tasty catnip tea!"
	color = "#101000" // rgb: 16, 16, 0
	taste_description = "sugar and catnip"

/datum/glass_style/drinking_glass/catnip_tea
	required_drink_type = /datum/reagent/consumable/catnip_tea
	icon = 'modular_doppler/modular_food_drinks_and_chems/icons/drinks.dmi'
	icon_state = "catnip_tea"
	name = "glass of catnip tea"
	desc = "A purrfect drink for a cat."

/datum/reagent/consumable/catnip_tea/on_mob_life(mob/living/carbon/M)
	M.adjustStaminaLoss(min(50 - M.getStaminaLoss(), 3))
	if(isfelinid(M))
		if(prob(20))
			M.emote("nya")
		if(prob(20))
			to_chat(M, span_notice("[pick("Headpats feel nice.", "Backrubs would be nice.", "Mew")]"))
	else
		to_chat(M, span_notice("[pick("I feel oddly calm.", "I feel relaxed.", "Mew?")]"))
	..()

/datum/reagent/consumable/ethanol/beerbatter
	name = "Beer Batter"
	description = "Probably not the greatest idea to drink...sludge."
	color = "#f5f4e9"
	nutriment_factor = 2 * REAGENTS_METABOLISM
	taste_description = "flour and cheap booze"
	boozepwr = 8 // beer diluted at about a 1:3 ratio
	ph = 6

/datum/glass_style/drinking_glass/beerbatter
	required_drink_type = /datum/reagent/consumable/ethanol/beerbatter
	icon = 'icons/obj/drinks/shakes.dmi'
	icon_state = "chocolatepudding"
	name = "glass of beer batter"
	desc = "Used in cooking, pure cholesterol, Scottish people eat it."
