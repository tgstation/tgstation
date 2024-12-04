/datum/reagent/consumable/orangejuice
	name = "Orange Juice"
	description = "Both delicious AND rich in Vitamin C, what more do you need?"
	color = "#E78108" // rgb: 231, 129, 8
	taste_description = "oranges"
	ph = 3.3
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/cup/glass/bottle/juice/orangejuice

/datum/reagent/consumable/orangejuice/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(affected_mob.getOxyLoss() && SPT_PROB(16, seconds_per_tick))
		if(affected_mob.adjustOxyLoss(-1 * REM * seconds_per_tick, FALSE, updating_health = FALSE, required_biotype = affected_biotype, required_respiration_type = affected_respiration_type))
			return UPDATE_MOB_HEALTH

/datum/reagent/consumable/tomatojuice
	name = "Tomato Juice"
	description = "Tomatoes made into juice. What a waste of big, juicy tomatoes, huh?"
	color = "#731008" // rgb: 115, 16, 8
	taste_description = "tomatoes"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/cup/glass/bottle/juice/tomatojuice

/datum/reagent/consumable/tomatojuice/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(affected_mob.getFireLoss() && SPT_PROB(10, seconds_per_tick))
		if(affected_mob.heal_bodypart_damage(brute = 0, burn = 1 * REM * seconds_per_tick, updating_health = FALSE))
			return UPDATE_MOB_HEALTH

/datum/reagent/consumable/limejuice
	name = "Lime Juice"
	description = "The sweet-sour juice of limes."
	color = "#a6f19a" // rgb: 166, 241, 154
	taste_description = "unbearable sourness"
	ph = 2.2
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/cup/glass/bottle/juice/limejuice

/datum/reagent/consumable/limejuice/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(affected_mob.getToxLoss() && SPT_PROB(10, seconds_per_tick))
		if(affected_mob.adjustToxLoss(-1 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype))
			return UPDATE_MOB_HEALTH

/datum/reagent/consumable/carrotjuice
	name = "Carrot Juice"
	description = "It is just like a carrot but without crunching."
	color = "#973800" // rgb: 151, 56, 0
	taste_description = "carrots"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/carrotjuice/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.adjust_eye_blur(-2 SECONDS * REM * seconds_per_tick)
	affected_mob.adjust_temp_blindness(-2 SECONDS * REM * seconds_per_tick)
	var/need_mob_update
	switch(current_cycle)
		if(21 to 110)
			if(SPT_PROB(100 * (1 - (sqrt(110 - current_cycle) / 10)), seconds_per_tick))
				need_mob_update = affected_mob.adjustOrganLoss(ORGAN_SLOT_EYES, -2 * REM * seconds_per_tick)
		if(110 to INFINITY)
			need_mob_update = affected_mob.adjustOrganLoss(ORGAN_SLOT_EYES, -2 * REM * seconds_per_tick)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/consumable/berryjuice
	name = "Berry Juice"
	description = "A delicious blend of several different kinds of berries."
	color = "#863333" // rgb: 134, 51, 51
	taste_description = "berries"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/applejuice
	name = "Apple Juice"
	description = "The sweet juice of an apple, fit for all ages."
	color = "#fff06b" // rgb: 255, 240, 107
	taste_description = "apples"
	ph = 3.2 // ~ 2.7 -> 3.7

/datum/reagent/consumable/poisonberryjuice
	name = "Poison Berry Juice"
	description = "A tasty juice blended from various kinds of very deadly and toxic berries."
	color = "#792b49" // rgb: 121, 43, 73
	taste_description = "berries"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/poisonberryjuice/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(affected_mob.adjustToxLoss(1 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype))
		return UPDATE_MOB_HEALTH

/datum/reagent/consumable/watermelonjuice
	name = "Watermelon Juice"
	description = "Delicious juice made from watermelon."
	color = "#af5e5e" // rgb: 175, 94, 94
	taste_description = "juicy watermelon"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/lemonjuice
	name = "Lemon Juice"
	description = "This juice is VERY sour."
	color = "#ebeb9e" // rgb: 235, 235, 158
	taste_description = "sourness"
	ph = 2
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/banana
	name = "Banana Juice"
	description = "The raw essence of a banana. HONK"
	color = "#FFFCB9" // rgb: 255, 252, 185
	taste_description = "banana"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/banana/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/obj/item/organ/liver/liver = affected_mob.get_organ_slot(ORGAN_SLOT_LIVER)
	if((liver && HAS_TRAIT(liver, TRAIT_COMEDY_METABOLISM)) || is_simian(affected_mob))
		if(affected_mob.heal_bodypart_damage(brute = 1 * REM * seconds_per_tick, burn = 1 * REM * seconds_per_tick, updating_health = FALSE))
			return UPDATE_MOB_HEALTH

/datum/reagent/consumable/nothing
	name = "Nothing"
	description = "Absolutely nothing."
	taste_description = "nothing"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/shot_glass/nothing
	required_drink_type = /datum/reagent/consumable/nothing
	icon_state = "shotglass"

/datum/reagent/consumable/nothing/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	. = ..()
	if(ishuman(drinker) && HAS_MIND_TRAIT(drinker, TRAIT_MIMING))
		drinker.set_silence_if_lower(MIMEDRINK_SILENCE_DURATION)
		if(drinker.heal_bodypart_damage(brute = 1 * REM * seconds_per_tick, burn = 1 * REM * seconds_per_tick, updating_health = FALSE))
			return UPDATE_MOB_HEALTH

/datum/reagent/consumable/laughter
	name = "Laughter"
	description = "Some say that this is the best medicine, but recent studies have proven that to be untrue."
	metabolization_rate = INFINITY
	color = "#FF4DD2"
	taste_description = "laughter"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/laughter/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.emote("laugh")
	affected_mob.add_mood_event("chemical_laughter", /datum/mood_event/chemical_laughter)

/datum/reagent/consumable/superlaughter
	name = "Super Laughter"
	description = "Funny until you're the one laughing."
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	color = "#FF4DD2"
	taste_description = "laughter"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/superlaughter/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(SPT_PROB(16, seconds_per_tick))
		affected_mob.visible_message(span_danger("[affected_mob] bursts out into a fit of uncontrollable laughter!"), span_userdanger("You burst out in a fit of uncontrollable laughter!"))
		affected_mob.Stun(5)
		affected_mob.add_mood_event("chemical_laughter", /datum/mood_event/chemical_superlaughter)

/datum/reagent/consumable/potato_juice
	name = "Potato Juice"
	description = "Juice of the potato. Bleh."
	nutriment_factor = 2
	color = "#E8A856" // rgb: 234, 157, 58
	taste_description = "irish sadness"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/pickle
	name = "Pickle Juice"
	description = "More accurately, this is the brine the pickle was floating in"
	nutriment_factor = 2
	color = "#cde65e" // rgb: 205, 230, 94
	taste_description = "vinegar brine"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/pickle/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/obj/item/organ/liver/liver = affected_mob.get_organ_slot(ORGAN_SLOT_LIVER)
	if((liver && HAS_TRAIT(liver, TRAIT_CORONER_METABOLISM)))
		if(affected_mob.adjustToxLoss(-1 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype))
			return UPDATE_MOB_HEALTH

/datum/reagent/consumable/grapejuice
	name = "Grape Juice"
	description = "The juice of a bunch of grapes. Guaranteed non-alcoholic."
	color = "#290029" // dark purple
	taste_description = "grape soda"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/plumjuice
	name = "Plum Juice"
	description = "Refreshing and slightly acidic beverage."
	color = "#b6062c"
	taste_description = "plums"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/milk
	name = "Milk"
	description = "An opaque white liquid produced by the mammary glands of mammals."
	color = "#DFDFDF" // rgb: 223, 223, 223
	taste_description = "milk"
	ph = 6.5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/condiment/milk

// Milk is good for humans, but bad for plants.
// The sugars cannot be used by plants, and the milk fat harms growth. Except shrooms.
/datum/reagent/consumable/milk/on_hydroponics_apply(obj/machinery/hydroponics/mytray, mob/user)
	mytray.adjust_waterlevel(round(volume * 0.3))
	var/obj/item/seeds/myseed = mytray.myseed
	if(isnull(myseed) || myseed.get_gene(/datum/plant_gene/trait/plant_type/fungal_metabolism))
		return
	myseed.adjust_potency(-round(volume * 0.5))

/datum/reagent/consumable/milk/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	if(affected_mob.getBruteLoss() && SPT_PROB(10, seconds_per_tick))
		if(affected_mob.heal_bodypart_damage(brute = 1 * REM * seconds_per_tick, burn = 0, updating_health = FALSE))
			. = UPDATE_MOB_HEALTH
	if(holder.has_reagent(/datum/reagent/consumable/capsaicin))
		holder.remove_reagent(/datum/reagent/consumable/capsaicin, seconds_per_tick)
	return ..() || .

/datum/reagent/milk/used_on_fish(obj/item/fish/fish)
	if(HAS_TRAIT(fish, TRAIT_FISH_MADE_OF_BONE))
		fish.adjust_health(fish.health + initial(fish.health) * max(fish.get_hunger() * 0.5, 0.12))
		fish.sate_hunger()
		return TRUE

/datum/reagent/consumable/soymilk
	name = "Soy Milk"
	description = "An opaque white liquid made from soybeans."
	color = "#DFDFC7" // rgb: 223, 223, 199
	taste_description = "soy milk"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/condiment/soymilk

/datum/reagent/consumable/soymilk/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(affected_mob.getBruteLoss() && SPT_PROB(10, seconds_per_tick))
		if(affected_mob.heal_bodypart_damage(1, 0))
			return UPDATE_MOB_HEALTH

/datum/reagent/consumable/cream
	name = "Cream"
	description = "The fatty, still liquid part of milk. Why don't you mix this with sum scotch, eh?"
	color = "#DFD7AF" // rgb: 223, 215, 175
	taste_description = "creamy milk"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/cup/glass/bottle/juice/cream

/datum/reagent/consumable/cream/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(SPT_PROB(10, seconds_per_tick) && affected_mob.heal_bodypart_damage(1, 0))
		return UPDATE_MOB_HEALTH

/datum/reagent/consumable/coffee
	name = "Coffee"
	description = "Coffee is a brewed drink prepared from roasted seeds, commonly called coffee beans, of the coffee plant."
	color = "#482000" // rgb: 72, 32, 0
	nutriment_factor = 0
	overdose_threshold = 80
	taste_description = "bitterness"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	glass_price = DRINK_PRICE_STOCK
	metabolized_traits = list(TRAIT_STIMULATED)

/datum/reagent/consumable/coffee/overdose_process(mob/living/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.set_jitter_if_lower(10 SECONDS * REM * seconds_per_tick)

/datum/reagent/consumable/coffee/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.adjust_dizzy(-10 SECONDS * REM * seconds_per_tick)
	affected_mob.adjust_drowsiness(-6 SECONDS * REM * seconds_per_tick)
	affected_mob.AdjustSleeping(-4 SECONDS * REM * seconds_per_tick)
	//310.15 is the normal bodytemp.
	affected_mob.adjust_bodytemperature(25 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * seconds_per_tick, 0, affected_mob.get_body_temp_normal())
	if(holder.has_reagent(/datum/reagent/consumable/frostoil))
		holder.remove_reagent(/datum/reagent/consumable/frostoil, 5 * REM * seconds_per_tick)

/datum/reagent/consumable/tea
	name = "Tea"
	description = "Tasty black tea, it has antioxidants, it's good for you!"
	color = "#101000" // rgb: 16, 16, 0
	nutriment_factor = 0
	taste_description = "tart black tea"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	glass_price = DRINK_PRICE_STOCK
	default_container = /obj/item/reagent_containers/cup/glass/mug/tea
	metabolized_traits = list(TRAIT_STIMULATED)

/datum/reagent/consumable/tea/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.adjust_dizzy(-4 SECONDS * REM * seconds_per_tick)
	affected_mob.adjust_drowsiness(-2 SECONDS * REM * seconds_per_tick)
	affected_mob.adjust_jitter(-6 SECONDS * REM * seconds_per_tick)
	affected_mob.AdjustSleeping(-2 SECONDS * REM * seconds_per_tick)
	if(affected_mob.getToxLoss() && SPT_PROB(10, seconds_per_tick))
		if(affected_mob.adjustToxLoss(-1 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype))
			. = UPDATE_MOB_HEALTH
	affected_mob.adjust_bodytemperature(20 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * seconds_per_tick, 0, affected_mob.get_body_temp_normal())

	var/to_chatted = FALSE
	for(var/datum/wound/iter_wound as anything in affected_mob.all_wounds)
		if(SPT_PROB(10, seconds_per_tick))
			var/helped = iter_wound.tea_life_process()
			if(!to_chatted && helped)
				to_chat(affected_mob, span_notice("A calm, relaxed feeling suffuses you. Your wounds feel a little healthier."))
			to_chatted = TRUE

// Different handling, different name.
// Returns FALSE by default so broken bones and 'loss' wounds don't give a false message
/datum/wound/proc/tea_life_process()
	return FALSE

// Slowly increase (gauzed) clot rate
/datum/wound/pierce/bleed/tea_life_process()
	gauzed_clot_rate += 0.1
	return TRUE

// Slowly increase clot rate
/datum/wound/slash/flesh/tea_life_process()
	clot_rate += 0.2
	return TRUE

// There's a designated burn process, but I felt this would be better for consistency with the rest of the reagent's procs
/datum/wound/burn/flesh/tea_life_process()
	// Sanitizes and heals, but with a limit
	flesh_healing = (flesh_healing > 0.1) ? flesh_healing : flesh_healing + 0.02
	infestation_rate = max(infestation_rate - 0.005, 0)
	return TRUE

/datum/reagent/consumable/lemonade
	name = "Lemonade"
	description = "Sweet, tangy lemonade. Good for the soul."
	color = "#FFE978"
	quality = DRINK_NICE
	taste_description = "sunshine and summertime"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	glass_price = DRINK_PRICE_EASY

/datum/reagent/consumable/tea/arnold_palmer
	name = "Arnold Palmer"
	description = "Encourages the patient to go golfing."
	color = "#FFB766"
	quality = DRINK_NICE
	nutriment_factor = 10
	taste_description = "bitter tea"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/tea/arnold_palmer/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(SPT_PROB(2.5, seconds_per_tick))
		to_chat(affected_mob, span_notice("[pick("You remember to square your shoulders.","You remember to keep your head down.","You can't decide between squaring your shoulders and keeping your head down.","You remember to relax.","You think about how someday you'll get two strokes off your golf game.")]"))

/datum/reagent/consumable/icecoffee
	name = "Iced Coffee"
	description = "Coffee and ice, refreshing and cool."
	color = "#462b15" // rgb: 70, 43, 21
	nutriment_factor = 0
	overdose_threshold = 80
	taste_description = "bitter coldness"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	metabolized_traits = list(TRAIT_STIMULATED)

/datum/reagent/consumable/icecoffee/overdose_process(mob/living/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.set_jitter_if_lower(10 SECONDS * REM * seconds_per_tick)

/datum/reagent/consumable/icecoffee/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.adjust_dizzy(-10 SECONDS * REM * seconds_per_tick)
	affected_mob.adjust_drowsiness(-6 SECONDS * REM * seconds_per_tick)
	affected_mob.AdjustSleeping(-4 SECONDS * REM * seconds_per_tick)
	affected_mob.adjust_bodytemperature(-5 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * seconds_per_tick, affected_mob.get_body_temp_normal())

/datum/reagent/consumable/hot_ice_coffee
	name = "Hot Ice Coffee"
	description = "Coffee with pulsing ice shards"
	color = "#462b15" // rgb: 70, 43, 21
	nutriment_factor = 0
	overdose_threshold = 80
	taste_description = "bitter coldness and a hint of smoke"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	metabolized_traits = list(TRAIT_STIMULATED)

/datum/reagent/consumable/hot_ice_coffee/overdose_process(mob/living/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.set_jitter_if_lower(10 SECONDS * REM * seconds_per_tick)

/datum/reagent/consumable/hot_ice_coffee/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.adjust_dizzy(-10 SECONDS * REM * seconds_per_tick)
	affected_mob.adjust_drowsiness(-6 SECONDS * REM * seconds_per_tick)
	affected_mob.AdjustSleeping(-6 SECONDS * REM * seconds_per_tick)
	affected_mob.adjust_bodytemperature(-7 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * seconds_per_tick, affected_mob.get_body_temp_normal())
	if(affected_mob.adjustToxLoss(1 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype))
		return UPDATE_MOB_HEALTH

/datum/reagent/consumable/icetea
	name = "Iced Tea"
	description = "No relation to a certain rap artist/actor."
	color = "#104038" // rgb: 16, 64, 56
	nutriment_factor = 0
	taste_description = "sweet tea"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	metabolized_traits = list(TRAIT_STIMULATED)

/datum/reagent/consumable/icetea/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.adjust_dizzy(-4 SECONDS * REM * seconds_per_tick)
	affected_mob.adjust_drowsiness(-2 SECONDS * REM * seconds_per_tick)
	affected_mob.AdjustSleeping(-4 SECONDS * REM * seconds_per_tick)
	if(affected_mob.getToxLoss() && SPT_PROB(10, seconds_per_tick))
		if(affected_mob.adjustToxLoss(-1 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype))
			. = UPDATE_MOB_HEALTH
	affected_mob.adjust_bodytemperature(-5 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * seconds_per_tick, affected_mob.get_body_temp_normal())

/datum/reagent/consumable/space_cola
	name = "Cola"
	description = "A refreshing beverage."
	color = "#100800" // rgb: 16, 8, 0
	taste_description = "cola"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/space_cola/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.adjust_drowsiness(-10 SECONDS * REM * seconds_per_tick)
	affected_mob.adjust_bodytemperature(-5 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * seconds_per_tick, affected_mob.get_body_temp_normal())

/datum/reagent/consumable/roy_rogers
	name = "Roy Rogers"
	description = "A sweet fizzy drink."
	color = "#53090B"
	quality = DRINK_GOOD
	taste_description = "fruity overlysweet cola"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/roy_rogers/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	affected_mob.set_jitter_if_lower(12 SECONDS * REM * seconds_per_tick)
	affected_mob.adjust_drowsiness(-10 SECONDS * REM * seconds_per_tick)
	affected_mob.adjust_bodytemperature(-5 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * seconds_per_tick, affected_mob.get_body_temp_normal())
	return ..()

/datum/reagent/consumable/nuka_cola
	name = "Nuka Cola"
	description = "Cola, cola never changes."
	color = "#100800" // rgb: 16, 8, 0
	quality = DRINK_VERYGOOD
	taste_description = "the future"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/nuka_cola/on_mob_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob.add_movespeed_modifier(/datum/movespeed_modifier/reagent/nuka_cola)

/datum/reagent/consumable/nuka_cola/on_mob_end_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/nuka_cola)

/datum/reagent/consumable/nuka_cola/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.set_jitter_if_lower(40 SECONDS * REM * seconds_per_tick)
	affected_mob.set_drugginess(1 MINUTES * REM * seconds_per_tick)
	affected_mob.adjust_dizzy(3 SECONDS * REM * seconds_per_tick)
	affected_mob.remove_status_effect(/datum/status_effect/drowsiness)
	affected_mob.AdjustSleeping(-4 SECONDS * REM * seconds_per_tick)
	affected_mob.adjust_bodytemperature(-5 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * seconds_per_tick, affected_mob.get_body_temp_normal())
	if (SSradiation.can_irradiate_basic(affected_mob))
		affected_mob.AddComponent(/datum/component/irradiated)

/datum/reagent/consumable/rootbeer
	name = "Root Beer"
	description = "A delightfully bubbly root beer, filled with so much sugar that it can actually speed up the user's trigger finger."
	color = "#181008" // rgb: 24, 16, 8
	quality = DRINK_VERYGOOD
	nutriment_factor = 10
	metabolization_rate = 2 * REAGENTS_METABOLISM
	taste_description = "a monstrous sugar rush"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	/// If we activated the effect
	var/effect_enabled = FALSE

/datum/reagent/consumable/rootbeer/on_mob_end_metabolize(mob/living/affected_mob)
	. = ..()
	REMOVE_TRAIT(affected_mob, TRAIT_DOUBLE_TAP, type)
	if(current_cycle > 10)
		to_chat(affected_mob, span_warning("You feel kinda tired as your sugar rush wears off..."))
		affected_mob.adjustStaminaLoss(min(80, current_cycle * 3), required_biotype = affected_biotype)
		affected_mob.adjust_drowsiness((current_cycle-1) * 2 SECONDS)

/datum/reagent/consumable/rootbeer/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(current_cycle > 3 && !effect_enabled) // takes a few seconds for the bonus to kick in to prevent microdosing
		to_chat(affected_mob, span_notice("You feel your trigger finger getting itchy..."))
		ADD_TRAIT(affected_mob, TRAIT_DOUBLE_TAP, type)
		effect_enabled = TRUE

	affected_mob.set_jitter_if_lower(4 SECONDS * REM * seconds_per_tick)
	if(prob(50))
		affected_mob.adjust_dizzy(2 SECONDS * REM * seconds_per_tick)
	if(current_cycle > 10)
		affected_mob.adjust_dizzy(3 SECONDS * REM * seconds_per_tick)

/datum/reagent/consumable/grey_bull
	name = "Grey Bull"
	description = "Grey Bull, it gives you gloves!"
	color = "#EEFF00" // rgb: 238, 255, 0
	quality = DRINK_VERYGOOD
	taste_description = "carbonated oil"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	metabolized_traits = list(TRAIT_SHOCKIMMUNE)

/datum/reagent/consumable/grey_bull/on_mob_metabolize(mob/living/carbon/affected_atom)
	. = ..()
	var/obj/item/organ/liver/liver = affected_atom.get_organ_slot(ORGAN_SLOT_LIVER)
	if(HAS_TRAIT(liver, TRAIT_MAINTENANCE_METABOLISM))
		affected_atom.add_mood_event("maintenance_fun", /datum/mood_event/maintenance_high)
		metabolization_rate *= 0.8

/datum/reagent/consumable/grey_bull/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.set_jitter_if_lower(40 SECONDS * REM * seconds_per_tick)
	affected_mob.adjust_dizzy(2 SECONDS * REM * seconds_per_tick)
	affected_mob.remove_status_effect(/datum/status_effect/drowsiness)
	affected_mob.AdjustSleeping(-4 SECONDS * REM * seconds_per_tick)
	affected_mob.adjust_bodytemperature(-5 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * seconds_per_tick, affected_mob.get_body_temp_normal())

/datum/reagent/consumable/spacemountainwind
	name = "SM Wind"
	description = "Blows right through you like a space wind."
	color = "#102000" // rgb: 16, 32, 0
	taste_description = "sweet citrus soda"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	metabolized_traits = list(TRAIT_STIMULATED)

/datum/reagent/consumable/spacemountainwind/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.adjust_drowsiness(-14 SECONDS * REM * seconds_per_tick)
	affected_mob.AdjustSleeping(-2 SECONDS * REM * seconds_per_tick)
	affected_mob.adjust_bodytemperature(-5 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * seconds_per_tick, affected_mob.get_body_temp_normal())
	affected_mob.set_jitter_if_lower(10 SECONDS * REM * seconds_per_tick)

/datum/reagent/consumable/dr_gibb
	name = "Dr. Gibb"
	description = "A delicious blend of 42 different flavours."
	color = "#102000" // rgb: 16, 32, 0
	taste_description = "cherry soda" // FALSE ADVERTISING
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/dr_gibb/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.adjust_drowsiness(-12 SECONDS * REM * seconds_per_tick)
	affected_mob.adjust_bodytemperature(-5 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * seconds_per_tick, affected_mob.get_body_temp_normal())

/datum/reagent/consumable/space_up
	name = "Space-Up"
	description = "Tastes like a hull breach in your mouth."
	color = COLOR_VIBRANT_LIME // rgb: 0, 255, 0
	taste_description = "cherry soda"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/space_up/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.adjust_bodytemperature(-8 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * seconds_per_tick, affected_mob.get_body_temp_normal())

/datum/reagent/consumable/lemon_lime
	name = "Lemon Lime"
	description = "A tangy substance made of 0.5% natural citrus!"
	color = "#8CFF00" // rgb: 135, 255, 0
	taste_description = "tangy lime and lemon soda"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/lemon_lime/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.adjust_bodytemperature(-8 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * seconds_per_tick, affected_mob.get_body_temp_normal())

/datum/reagent/consumable/pwr_game
	name = "Pwr Game"
	description = "The only drink with the PWR that true gamers crave."
	color = "#9385bf" // rgb: 58, 52, 75
	taste_description = "sweet and salty tang"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/pwr_game/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume)
	. = ..()
	if(exposed_mob?.mind?.get_skill_level(/datum/skill/gaming) >= SKILL_LEVEL_LEGENDARY && (methods & INGEST) && !HAS_TRAIT(exposed_mob, TRAIT_GAMERGOD))
		ADD_TRAIT(exposed_mob, TRAIT_GAMERGOD, "pwr_game")
		to_chat(exposed_mob, span_nicegreen("As you imbibe the Pwr Game, your gamer third eye opens... \
		You feel as though a great secret of the universe has been made known to you..."))

/datum/reagent/consumable/pwr_game/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.adjust_bodytemperature(-8 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * seconds_per_tick, affected_mob.get_body_temp_normal())
	if(SPT_PROB(5, seconds_per_tick))
		affected_mob.mind?.adjust_experience(/datum/skill/gaming, 5)

/datum/reagent/consumable/shamblers
	name = "Shambler's Juice"
	description = "~Shake me up some of that Shambler's Juice!~"
	color = "#f00060" // rgb: 94, 0, 38
	taste_description = "carbonated metallic soda"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/shamblers/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.adjust_bodytemperature(-8 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * seconds_per_tick, affected_mob.get_body_temp_normal())

/datum/reagent/consumable/sodawater
	name = "Soda Water"
	description = "A can of club soda. Why not make a scotch and soda?"
	color = "#619494" // rgb: 97, 148, 148
	taste_description = "carbonated water"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

// A variety of nutrients are dissolved in club soda, without sugar.
// These nutrients include carbon, oxygen, hydrogen, phosphorous, potassium, sulfur and sodium, all of which are needed for healthy plant growth.
/datum/reagent/consumable/sodawater/on_hydroponics_apply(obj/machinery/hydroponics/mytray, mob/user)
	mytray.adjust_waterlevel(round(volume))
	mytray.adjust_plant_health(round(volume * 0.1))

/datum/reagent/consumable/sodawater/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.adjust_dizzy(-10 SECONDS * REM * seconds_per_tick)
	affected_mob.adjust_drowsiness(-6 SECONDS * REM * seconds_per_tick)
	affected_mob.adjust_bodytemperature(-5 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * seconds_per_tick, affected_mob.get_body_temp_normal())

/datum/reagent/consumable/tonic
	name = "Tonic Water"
	description = "It tastes strange but at least the quinine keeps the Space Malaria at bay."
	color = "#0064C8" // rgb: 0, 100, 200
	taste_description = "tart and fresh"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/tonic/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.adjust_dizzy(-10 SECONDS * REM * seconds_per_tick)
	affected_mob.adjust_drowsiness(-6 SECONDS * REM * seconds_per_tick)
	affected_mob.AdjustSleeping(-4 SECONDS * REM * seconds_per_tick)
	affected_mob.adjust_bodytemperature(-5 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * seconds_per_tick, affected_mob.get_body_temp_normal())

/datum/reagent/consumable/wellcheers
	name = "Wellcheers"
	description = "A strange purple drink, smelling of saltwater. Somewhere in the distance, you hear seagulls."
	color = "#762399" // rgb: 118, 35, 153
	taste_description = "grapes and the fresh open sea"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/wellcheers/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.adjust_drowsiness(3 SECONDS * REM * seconds_per_tick)
	var/need_mob_update
	switch(affected_mob.mob_mood.sanity_level)
		if (SANITY_LEVEL_GREAT to SANITY_LEVEL_NEUTRAL)
			need_mob_update = affected_mob.adjustBruteLoss(-1.5 * REM * seconds_per_tick, updating_health = FALSE)
		if (SANITY_LEVEL_DISTURBED to SANITY_LEVEL_UNSTABLE)
			affected_mob.add_mood_event("wellcheers", /datum/mood_event/wellcheers)
		if (SANITY_LEVEL_CRAZY to SANITY_LEVEL_INSANE)
			need_mob_update = affected_mob.adjustStaminaLoss(3 * REM * seconds_per_tick, updating_stamina = FALSE)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/consumable/monkey_energy
	name = "Monkey Energy"
	description = "The only drink that will make you unleash the ape."
	color = "#f39b03" // rgb: 243, 155, 3
	overdose_threshold = 60
	taste_description = "barbecue and nostalgia"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	metabolized_traits = list(TRAIT_STIMULATED)

/datum/reagent/consumable/monkey_energy/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.set_jitter_if_lower(80 SECONDS * REM * seconds_per_tick)
	affected_mob.adjust_dizzy(2 SECONDS * REM * seconds_per_tick)
	affected_mob.remove_status_effect(/datum/status_effect/drowsiness)
	affected_mob.AdjustSleeping(-4 SECONDS * REM * seconds_per_tick)
	affected_mob.adjust_bodytemperature(-5 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * seconds_per_tick, affected_mob.get_body_temp_normal())

/datum/reagent/consumable/monkey_energy/on_mob_metabolize(mob/living/affected_mob)
	. = ..()
	if(is_simian(affected_mob))
		affected_mob.add_movespeed_modifier(/datum/movespeed_modifier/reagent/monkey_energy)

/datum/reagent/consumable/monkey_energy/on_mob_end_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/monkey_energy)

/datum/reagent/consumable/monkey_energy/overdose_process(mob/living/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(SPT_PROB(7.5, seconds_per_tick))
		affected_mob.say(pick_list_replacements(BOOMER_FILE, "boomer"), forced = /datum/reagent/consumable/monkey_energy)

/datum/reagent/consumable/ice
	name = "Ice"
	description = "Frozen water, your dentist wouldn't like you chewing this."
	reagent_state = SOLID
	color = "#619494" // rgb: 97, 148, 148
	taste_description = "ice"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/cup/glass/ice

/datum/reagent/consumable/ice/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(affected_mob.adjust_bodytemperature(-5 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * seconds_per_tick, FALSE, affected_mob.get_body_temp_normal()))
		return UPDATE_MOB_HEALTH

/datum/reagent/consumable/soy_latte
	name = "Soy Latte"
	description = "A nice and tasty beverage while you are reading your hippie books."
	color = "#cc6404" // rgb: 204,100,4
	overdose_threshold = 80
	quality = DRINK_NICE
	taste_description = "creamy coffee"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	glass_price = DRINK_PRICE_EASY
	metabolized_traits = list(TRAIT_STIMULATED)

/datum/reagent/consumable/soy_latte/overdose_process(mob/living/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.set_jitter_if_lower(10 SECONDS * REM * seconds_per_tick)

/datum/reagent/consumable/soy_latte/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.adjust_dizzy(-10 SECONDS * REM * seconds_per_tick)
	affected_mob.adjust_drowsiness(-6 SECONDS * REM * seconds_per_tick)
	var/need_mob_update
	need_mob_update = affected_mob.SetSleeping(0)
	affected_mob.adjust_bodytemperature(5 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * seconds_per_tick, 0, affected_mob.get_body_temp_normal())
	if(affected_mob.getBruteLoss() && SPT_PROB(10, seconds_per_tick))
		need_mob_update += affected_mob.heal_bodypart_damage(brute = 1 * REM * seconds_per_tick, burn = 0, updating_health = FALSE)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/consumable/cafe_latte
	name = "Cafe Latte"
	description = "A nice, strong and tasty beverage while you are reading."
	color = "#cc6404" // rgb: 204,100,4
	overdose_threshold = 80
	quality = DRINK_NICE
	taste_description = "bitter cream"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	glass_price = DRINK_PRICE_EASY
	metabolized_traits = list(TRAIT_STIMULATED)

/datum/reagent/consumable/cafe_latte/overdose_process(mob/living/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.set_jitter_if_lower(10 SECONDS * REM * seconds_per_tick)

/datum/reagent/consumable/cafe_latte/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.adjust_dizzy(-10 SECONDS * REM * seconds_per_tick)
	affected_mob.adjust_drowsiness(-12 SECONDS * REM * seconds_per_tick)
	var/need_mob_update
	need_mob_update = affected_mob.SetSleeping(0)
	affected_mob.adjust_bodytemperature(5 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * seconds_per_tick, 0, affected_mob.get_body_temp_normal())
	if(affected_mob.getBruteLoss() && SPT_PROB(10, seconds_per_tick))
		need_mob_update += affected_mob.heal_bodypart_damage(brute = 1 * REM * seconds_per_tick, burn = 0, updating_health = FALSE)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/consumable/doctor_delight
	name = "The Doctor's Delight"
	description = "A gulp a day keeps the Medibot away! A mixture of juices that heals most damage types fairly quickly at the cost of hunger."
	color = "#FF8CFF" // rgb: 255, 140, 255
	quality = DRINK_VERYGOOD
	taste_description = "homely fruit"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/doctor_delight/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/need_mob_update
	need_mob_update = affected_mob.adjustBruteLoss(-0.5 * REM * seconds_per_tick, updating_health = FALSE, required_bodytype = affected_bodytype)
	need_mob_update += affected_mob.adjustFireLoss(-0.5 * REM * seconds_per_tick, updating_health = FALSE, required_bodytype = affected_bodytype)
	need_mob_update += affected_mob.adjustToxLoss(-0.5 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype)
	need_mob_update += affected_mob.adjustOxyLoss(-0.5 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype, required_respiration_type = affected_respiration_type)
	if(affected_mob.nutrition && (affected_mob.nutrition - 2 > 0))
		var/obj/item/organ/liver/liver = affected_mob.get_organ_slot(ORGAN_SLOT_LIVER)
		if(!(HAS_TRAIT(liver, TRAIT_MEDICAL_METABOLISM)))
			// Drains the nutrition of the holder. Not medical doctors though, since it's the Doctor's Delight!
			affected_mob.adjust_nutrition(-2 * REM * seconds_per_tick)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/consumable/cinderella
	name = "Cinderella"
	description = "Most definitely a fruity alcohol cocktail to have while partying with your friends."
	color = "#FF6A50"
	quality = DRINK_VERYGOOD
	taste_description = "sweet tangy fruit"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/cinderella/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.adjust_disgust(-5 * REM * seconds_per_tick)

/datum/reagent/consumable/cherryshake
	name = "Cherry Shake"
	description = "A cherry flavored milkshake."
	color = "#FFB6C1"
	quality = DRINK_VERYGOOD
	nutriment_factor = 8
	taste_description = "creamy tart cherry"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	glass_price = DRINK_PRICE_MEDIUM

/datum/reagent/consumable/bluecherryshake
	name = "Blue Cherry Shake"
	description = "An exotic milkshake."
	color = "#00F1FF"
	quality = DRINK_VERYGOOD
	nutriment_factor = 8
	taste_description = "creamy blue cherry"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/vanillashake
	name = "Vanilla Shake"
	description = "A vanilla flavored milkshake. The basics are still good."
	color = "#E9D2B2"
	quality = DRINK_VERYGOOD
	nutriment_factor = 8
	taste_description = "sweet creamy vanilla"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	glass_price = DRINK_PRICE_MEDIUM

/datum/reagent/consumable/caramelshake
	name = "Caramel Shake"
	description = "A caramel flavored milkshake. Your teeth hurt looking at it."
	color = "#E17C00"
	quality = DRINK_GOOD
	nutriment_factor = 10
	taste_description = "sweet rich creamy caramel"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	glass_price = DRINK_PRICE_MEDIUM

/datum/reagent/consumable/choccyshake
	name = "Chocolate Shake"
	description = "A frosty chocolate milkshake."
	color = "#541B00"
	quality = DRINK_VERYGOOD
	nutriment_factor = 8
	taste_description = "sweet creamy chocolate"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	glass_price = DRINK_PRICE_MEDIUM

/datum/reagent/consumable/strawberryshake
	name = "Strawberry Shake"
	description = "A strawberry milkshake."
	color = "#ff7b7b"
	quality = DRINK_VERYGOOD
	nutriment_factor = 8
	taste_description = "sweet strawberries and milk"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	glass_price = DRINK_PRICE_MEDIUM

/datum/reagent/consumable/bananashake
	name = "Banana Shake"
	description = "A banana milkshake. Stuff that clowns drink at their honkday parties."
	color = "#f2d554"
	quality = DRINK_VERYGOOD
	nutriment_factor = 8
	taste_description = "thick banana"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	glass_price = DRINK_PRICE_MEDIUM

/datum/reagent/consumable/pumpkin_latte
	name = "Pumpkin Latte"
	description = "A mix of pumpkin juice and coffee."
	color = "#F4A460"
	overdose_threshold = 80
	quality = DRINK_VERYGOOD
	nutriment_factor = 3
	taste_description = "creamy pumpkin"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	metabolized_traits = list(TRAIT_STIMULATED)

/datum/reagent/consumable/pumpkin_latte/overdose_process(mob/living/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.set_jitter_if_lower(10 SECONDS * REM * seconds_per_tick)

/datum/reagent/consumable/pumpkin_latte/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.adjust_dizzy(-10 SECONDS * REM * seconds_per_tick)
	affected_mob.adjust_drowsiness(-6 SECONDS * REM * seconds_per_tick)
	var/need_mob_update
	need_mob_update = affected_mob.SetSleeping(0)
	affected_mob.adjust_bodytemperature(5 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * seconds_per_tick, 0, affected_mob.get_body_temp_normal())
	if(affected_mob.getBruteLoss() && SPT_PROB(10, seconds_per_tick))
		need_mob_update += affected_mob.heal_bodypart_damage(brute = 1 * REM * seconds_per_tick, burn = 0, updating_health = FALSE)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/consumable/gibbfloats
	name = "Gibb Floats"
	description = "Ice cream on top of a Dr. Gibb glass."
	color = "#B22222"
	quality = DRINK_NICE
	nutriment_factor = 3
	taste_description = "creamy cherry"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/pumpkinjuice
	name = "Pumpkin Juice"
	description = "Juiced from real pumpkin."
	color = "#FFA500"
	taste_description = "pumpkin"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/blumpkinjuice
	name = "Blumpkin Juice"
	description = "Juiced from real blumpkin."
	color = "#00BFFF"
	taste_description = "a mouthful of pool water"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/triple_citrus
	name = "Triple Citrus"
	description = "A solution."
	color = "#EEFF00"
	quality = DRINK_NICE
	taste_description = "extreme bitterness"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/grape_soda
	name = "Grape Soda"
	description = "Beloved by children and teetotalers."
	color = "#E6CDFF"
	taste_description = "grape soda"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/grape_soda/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.adjust_bodytemperature(-5 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * seconds_per_tick, affected_mob.get_body_temp_normal())

/datum/reagent/consumable/milk/chocolate_milk
	name = "Chocolate Milk"
	description = "Milk for cool kids."
	color = "#7D4E29"
	quality = DRINK_NICE
	taste_description = "chocolate milk"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/hot_coco
	name = "Hot Coco"
	description = "Made with love! And coco beans."
	nutriment_factor = 4
	color = "#3b240e" // rgb: 59, 36, 14
	taste_description = "creamy chocolate"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/hot_coco/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	affected_mob.adjust_bodytemperature(5 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * seconds_per_tick, 0, affected_mob.get_body_temp_normal())
	if(affected_mob.getBruteLoss() && SPT_PROB(10, seconds_per_tick))
		if(affected_mob.heal_bodypart_damage(brute = 1 * REM * seconds_per_tick, burn = 0, updating_health = FALSE))
			. = UPDATE_MOB_HEALTH
	if(holder.has_reagent(/datum/reagent/consumable/capsaicin))
		holder.remove_reagent(/datum/reagent/consumable/capsaicin, 2 * REM * seconds_per_tick)
	return ..() || .

/datum/reagent/consumable/italian_coco
	name = "Italian Hot Chocolate"
	description = "Made with love! You can just imagine a happy Nonna from the smell."
	nutriment_factor = 8
	color = "#57372A"
	quality = DRINK_VERYGOOD
	taste_description = "thick creamy chocolate"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/italian_coco/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.adjust_bodytemperature(5 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * seconds_per_tick, 0, affected_mob.get_body_temp_normal())

/datum/reagent/consumable/menthol
	name = "Menthol"
	description = "Alleviates coughing symptoms one might have."
	color = "#80AF9C"
	taste_description = "mint"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/cup/glass/bottle/juice/menthol

/datum/reagent/consumable/menthol/on_mob_life(mob/living/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.apply_status_effect(/datum/status_effect/throat_soothed)

/datum/reagent/consumable/grenadine
	name = "Grenadine"
	description = "Not cherry flavored!"
	color = "#EA1D26"
	taste_description = "sweet pomegranates"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/parsnipjuice
	name = "Parsnip Juice"
	description = "Why..."
	color = "#FFA500"
	taste_description = "parsnip"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/pineapplejuice
	name = "Pineapple Juice"
	description = "Tart, tropical, and hotly debated."
	color = "#F7D435"
	taste_description = "pineapple"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/cup/glass/bottle/juice/pineapplejuice

/datum/reagent/consumable/peachjuice //Intended to be extremely rare due to being the limiting ingredients in the blazaam drink
	name = "Peach Juice"
	description = "Just peachy."
	color = "#E78108"
	taste_description = "peaches"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/cream_soda
	name = "Cream Soda"
	description = "A classic space-American vanilla flavored soft drink."
	color = "#dcb137"
	quality = DRINK_VERYGOOD
	taste_description = "fizzy vanilla"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/cream_soda/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.adjust_bodytemperature(-5 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * seconds_per_tick, affected_mob.get_body_temp_normal())

/datum/reagent/consumable/sol_dry
	name = "Sol Dry"
	description = "A soothing, mellow drink made from ginger."
	color = "#f7d26a"
	quality = DRINK_NICE
	taste_description = "sweet ginger spice"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/sol_dry/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.adjust_disgust(-5 * REM * seconds_per_tick)

/datum/reagent/consumable/shirley_temple
	name = "Shirley Temple"
	description = "Here you go little girl, now you can drink like the adults."
	color = "#F43724"
	quality = DRINK_GOOD
	taste_description = "sweet cherry syrup and ginger spice"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/shirley_temple/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	affected_mob.adjust_disgust(-3 * REM * seconds_per_tick)
	return ..()

/datum/reagent/consumable/red_queen
	name = "Red Queen"
	description = "DRINK ME."
	color = "#e6ddc3"
	quality = DRINK_GOOD
	taste_description = "wonder"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	var/current_size = RESIZE_DEFAULT_SIZE

/datum/reagent/consumable/red_queen/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(SPT_PROB(50, seconds_per_tick))
		return

	var/newsize = pick(0.5, 0.75, 1, 1.50, 2)
	newsize *= RESIZE_DEFAULT_SIZE
	affected_mob.update_transform(newsize/current_size)
	current_size = newsize
	if(SPT_PROB(23, seconds_per_tick))
		affected_mob.sneeze()

/datum/reagent/consumable/red_queen/on_mob_end_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob.update_transform(RESIZE_DEFAULT_SIZE/current_size)
	current_size = RESIZE_DEFAULT_SIZE

/datum/reagent/consumable/bungojuice
	name = "Bungo Juice"
	color = "#F9E43D"
	description = "Exotic! You feel like you are on vacation already."
	taste_description = "succulent bungo"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/prunomix
	name = "Pruno Mixture"
	color = "#E78108"
	description = "Fruit, sugar, yeast, and water pulped together into a pungent slurry."
	taste_description = "garbage"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/aloejuice
	name = "Aloe Juice"
	color = "#b3c5a7" // rgb: 179, 197, 167
	description = "A healthy and refreshing juice."
	taste_description = "vegetable"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/aloejuice/on_mob_life(mob/living/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(affected_mob.getToxLoss() && SPT_PROB(16, seconds_per_tick))
		if(affected_mob.adjustToxLoss(-1 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype))
			return UPDATE_MOB_HEALTH

/datum/reagent/consumable/agua_fresca
	name = "Agua Fresca"
	description = "A refreshing watermelon agua fresca. Perfect on a day at the holodeck."
	color = "#D25B66"
	quality = DRINK_VERYGOOD
	taste_description = "cool refreshing watermelon"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/agua_fresca/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.adjust_bodytemperature(-8 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * seconds_per_tick, affected_mob.get_body_temp_normal())
	if(affected_mob.getToxLoss() && SPT_PROB(10, seconds_per_tick))
		if(affected_mob.adjustToxLoss(-0.5, updating_health = FALSE, required_biotype = affected_biotype))
			return UPDATE_MOB_HEALTH

/datum/reagent/consumable/mushroom_tea
	name = "Mushroom Tea"
	description = "A savoury glass of tea made from polypore mushroom shavings, originally native to Tizira."
	color = "#674945" // rgb: 16, 16, 0
	nutriment_factor = 0
	taste_description = "mushrooms"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/mushroom_tea/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(islizard(affected_mob))
		if(affected_mob.adjustOxyLoss(-0.5 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype, required_respiration_type = affected_respiration_type))
			return UPDATE_MOB_HEALTH

//Moth Stuff
/datum/reagent/consumable/toechtauese_juice
	name = "Töchtaüse Juice"
	description = "An unpleasant juice made from töchtaüse berries. Best made into a syrup, unless you enjoy pain."
	color = "#554862" // rgb: 85, 72, 98
	nutriment_factor = 0
	taste_description = "fiery itchy pain"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/toechtauese_syrup
	name = "Töchtaüse Syrup"
	description = "A harsh spicy and bitter syrup, made from töchtaüse berries. Useful as an ingredient, both for food and cocktails."
	color = "#554862" // rgb: 85, 72, 98
	nutriment_factor = 0
	taste_description = "sugar, spice, and nothing nice"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/strawberry_banana
	name = "strawberry banana smoothie"
	description = "A classic smoothie made from strawberries and bananas."
	color = "#FF9999"
	nutriment_factor = 0
	taste_description = "strawberry and banana"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/berry_blast
	name = "berry blast smoothie"
	description = "A classic smoothie made from mixed berries."
	color = "#A76DC5"
	nutriment_factor = 0
	taste_description = "mixed berry"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/funky_monkey
	name = "funky monkey smoothie"
	description = "A classic smoothie made from chocolate and bananas."
	color = COLOR_BROWNER_BROWN
	nutriment_factor = 0
	taste_description = "chocolate and banana"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/green_giant
	name = "green giant smoothie"
	description = "A green vegetable smoothie, made without vegetables."
	color = COLOR_VERY_DARK_LIME_GREEN
	nutriment_factor = 0
	taste_description = "green, just green"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/melon_baller
	name = "melon baller smoothie"
	description = "A classic smoothie made from melons."
	color = "#D22F55"
	nutriment_factor = 0
	taste_description = "fresh melon"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/vanilla_dream
	name = "vanilla dream smoothie"
	description = "A classic smoothie made from vanilla and fresh cream."
	color = "#FFF3DD"
	nutriment_factor = 0
	taste_description = "creamy vanilla"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/cucumberjuice
	name = "Cucumber Juice"
	description = "Ordinary cucumber juice, nothing from the fantasy world."
	color = "#B1D861" // rgb: 177, 216, 97
	taste_description = "light cucumber"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/cucumberlemonade
	name = "Cucumber Lemonade"
	description = "Cucumber juice, sugar, and soda; what else do I need?"
	color = "#cbe248" // rgb: 203, 226, 72
	quality = DRINK_GOOD
	taste_description = "citrus soda with cucumber"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	glass_price = DRINK_PRICE_HIGH

/datum/reagent/consumable/cucumberlemonade/on_mob_life(mob/living/carbon/doll, seconds_per_tick, times_fired)
	. = ..()
	doll.adjust_bodytemperature(-8 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * seconds_per_tick, doll.get_body_temp_normal())
	if(doll.getToxLoss() && SPT_PROB(10, seconds_per_tick))
		if(doll.adjustToxLoss(-0.5, updating_health = FALSE, required_biotype = affected_biotype))
			return UPDATE_MOB_HEALTH

/datum/reagent/consumable/mississippi_queen
	name = "Mississippi Queen"
	description = "If you think you're so hot, how about a victory drink?"
	color = "#d4422f" // rgb: 212,66,47
	taste_description = "sludge seeping down your throat"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/mississippi_queen/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	. = ..()
	switch(current_cycle)
		if(11 to 21)
			drinker.adjust_dizzy(4 SECONDS * REM * seconds_per_tick)
		if(21 to 31)
			if(SPT_PROB(15, seconds_per_tick))
				drinker.adjust_confusion(4 SECONDS * REM * seconds_per_tick)
		if(31 to 201)
			drinker.adjust_hallucinations(60 SECONDS * REM * seconds_per_tick)

/datum/reagent/consumable/t_letter
	name = "T"
	description = "You expected to find this in a soup, but this is fine too."
	color = "#583d09" // rgb: 88, 61, 9
	taste_description = "one of your 26 favorite letters"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	metabolized_traits = list(TRAIT_STIMULATED)

/datum/reagent/consumable/t_letter/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(!HAS_MIND_TRAIT(affected_mob, TRAIT_MIMING))
		return
	affected_mob.set_silence_if_lower(MIMEDRINK_SILENCE_DURATION)
	affected_mob.adjust_drowsiness(-6 SECONDS * REM * seconds_per_tick)
	affected_mob.AdjustSleeping(-4 SECONDS * REM * seconds_per_tick)
	if(affected_mob.getToxLoss() && SPT_PROB(25, seconds_per_tick))
		if(affected_mob.adjustToxLoss(-2 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype))
			return UPDATE_MOB_HEALTH

/datum/reagent/consumable/hakka_mate
	name = "Hakka-Mate"
	description = "A Martian-made yerba mate soda, dragged straight out of the pits of a hacking convention."
	color = "#c4b000"
	taste_description = "bubbly yerba mate"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/coconut_milk
	name = "Coconut Milk"
	description = "A versatile milk substitute that's perfect for everything from cooking to making cocktails."
	color = "#DFDFDF"
	taste_description = "milky coconut"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/melon_soda
	name = "Melon Soda"
	description = "A neon green hit of nostalgia."
	color = "#6FEB48"
	taste_description = "fizzy melon"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/volt_energy
	name = "24-Volt Energy"
	description = "An artificially coloured and flavoured electric energy drink, in lanternfruit flavour. Made for ethereals, by ethereals."
	color = "#99E550"
	taste_description = "sour pear"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	metabolized_traits = list(TRAIT_STIMULATED)

/datum/reagent/consumable/volt_energy/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume)
	. = ..()
	if(!(methods & (INGEST|INJECT|PATCH)) || !iscarbon(exposed_mob))
		return

	var/mob/living/carbon/exposed_carbon = exposed_mob
	var/obj/item/organ/stomach/ethereal/stomach = exposed_carbon.get_organ_slot(ORGAN_SLOT_STOMACH)
	if(istype(stomach))
		stomach.adjust_charge(reac_volume * 0.02 * ETHEREAL_CHARGE_NORMAL)
