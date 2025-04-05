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

/datum/reagent/consumable/yogurt_soda
	name = "Yogurt Soda"
	description = "A refreshing beverage of carbonated yogurt drink"
	color = "#dddada"
	taste_description = "bubbly sweet yogurt."

/datum/reagent/consumable/gakster_energy
	name = "Gakster energy drink"
	description = "An ungodly concotion of carbonated water, caffeine, taurine, and dozens of other additives. Contains approximately \
	4000% of the recommended daily value of vitamin B12."
	color = "#f7e6af"
	taste_description = "battery acid and carbonation"
	overdose_threshold = 50
	metabolized_traits = list(TRAIT_STIMULATED)

/datum/movespeed_modifier/reagent/gakster_energy
	multiplicative_slowdown = -0.1

/datum/reagent/consumable/gakster_energy/on_mob_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob.add_movespeed_modifier(/datum/movespeed_modifier/reagent/gakster_energy)

/datum/reagent/consumable/gakster_energy/on_mob_end_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/gakster_energy)

/datum/reagent/consumable/gakster_energy/overdose_start(mob/living/affected_mob)
	. = ..()
	to_chat(affected_mob, span_userdanger("Your heart flutters and skips!"))
	affected_mob.add_mood_event("[type]_overdose", /datum/mood_event/overdose, name)

/datum/reagent/consumable/gakster_energy/overdose_process(mob/living/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/need_mob_update
	need_mob_update = affected_mob.adjustOrganLoss(ORGAN_SLOT_HEART, 1 * REM * seconds_per_tick, required_organ_flag = affected_organ_flags)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH
