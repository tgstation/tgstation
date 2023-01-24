

/////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////// DRINKS BELOW, Beer is up there though, along with cola. Cap'n Pete's Cuban Spiced Rum////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/reagent/consumable/orangejuice
	name = "Orange Juice"
	description = "Both delicious AND rich in Vitamin C, what more do you need?"
	color = "#E78108" // rgb: 231, 129, 8
	taste_description = "oranges"
	ph = 3.3
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/cup/glass/bottle/juice/orangejuice

/datum/glass_style/drinking_glass/orangejuice
	required_drink_type = /datum/reagent/consumable/orangejuice
	name = "glass of orange juice"
	desc = "Vitamins! Yay!"
	icon_state = "glass_orange"

/datum/glass_style/juicebox/orangejuice
	required_drink_type = /datum/reagent/consumable/orangejuice
	name = "orange juice box"
	desc = "A great source of vitamins. Stay healthy!"
	icon_state = "orangebox"
	drink_type = FRUIT | BREAKFAST

/datum/reagent/consumable/orangejuice/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	if(affected_mob.getOxyLoss() && DT_PROB(16, delta_time))
		affected_mob.adjustOxyLoss(-1, FALSE, required_biotype = affected_biotype)
		. = TRUE
	..()

/datum/reagent/consumable/tomatojuice
	name = "Tomato Juice"
	description = "Tomatoes made into juice. What a waste of big, juicy tomatoes, huh?"
	color = "#731008" // rgb: 115, 16, 8
	taste_description = "tomatoes"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/cup/glass/bottle/juice/tomatojuice

/datum/glass_style/drinking_glass/tomatojuice
	required_drink_type = /datum/reagent/consumable/tomatojuice
	name = "glass of tomato juice"
	desc = "Are you sure this is tomato juice?"
	icon_state = "glass_red"

/datum/reagent/consumable/tomatojuice/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	if(affected_mob.getFireLoss() && DT_PROB(10, delta_time))
		affected_mob.heal_bodypart_damage(0, 1)
		. = TRUE
	..()

/datum/reagent/consumable/limejuice
	name = "Lime Juice"
	description = "The sweet-sour juice of limes."
	color = "#365E30" // rgb: 54, 94, 48
	taste_description = "unbearable sourness"
	ph = 2.2
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/cup/glass/bottle/juice/limejuice

/datum/glass_style/drinking_glass/limejuice
	required_drink_type = /datum/reagent/consumable/limejuice
	name = "glass of lime juice"
	desc = "A glass of sweet-sour lime juice."
	icon_state = "glass_green"

/datum/reagent/consumable/limejuice/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	if(affected_mob.getToxLoss() && DT_PROB(10, delta_time))
		affected_mob.adjustToxLoss(-1, FALSE, required_biotype = affected_biotype)
		. = TRUE
	..()

/datum/reagent/consumable/carrotjuice
	name = "Carrot Juice"
	description = "It is just like a carrot but without crunching."
	color = "#973800" // rgb: 151, 56, 0
	taste_description = "carrots"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/carrotjuice
	required_drink_type = /datum/reagent/consumable/carrotjuice
	name = "glass of  carrot juice"
	desc = "It's just like a carrot but without crunching."
	icon_state = "carrotjuice"

/datum/reagent/consumable/carrotjuice/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	affected_mob.adjust_eye_blur(-2 SECONDS * REM * delta_time)
	affected_mob.adjust_temp_blindness(-2 SECONDS * REM * delta_time)
	switch(current_cycle)
		if(1 to 20)
			//nothing
		if(21 to 110)
			if(DT_PROB(100 * (1 - (sqrt(110 - current_cycle) / 10)), delta_time))
				affected_mob.adjustOrganLoss(ORGAN_SLOT_EYES, -2)
		if(110 to INFINITY)
			affected_mob.adjustOrganLoss(ORGAN_SLOT_EYES, -2)
	return ..()

/datum/reagent/consumable/berryjuice
	name = "Berry Juice"
	description = "A delicious blend of several different kinds of berries."
	color = "#863333" // rgb: 134, 51, 51
	taste_description = "berries"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/berryjuice
	required_drink_type = /datum/reagent/consumable/berryjuice
	name = "glass of berry juice"
	desc = "Berry juice. Or maybe it's jam. Who cares?"
	icon_state = "berryjuice"

/datum/reagent/consumable/applejuice
	name = "Apple Juice"
	description = "The sweet juice of an apple, fit for all ages."
	color = "#ECFF56" // rgb: 236, 255, 86
	taste_description = "apples"
	ph = 3.2 // ~ 2.7 -> 3.7

/datum/glass_style/juicebox/applejuice
	required_drink_type = /datum/reagent/consumable/applejuice
	name = "apple juice box"
	desc = "Sweet apple juice. Don't be late for school!"
	icon_state = "juicebox"
	drink_type = FRUIT

/datum/reagent/consumable/poisonberryjuice
	name = "Poison Berry Juice"
	description = "A tasty juice blended from various kinds of very deadly and toxic berries."
	color = "#863353" // rgb: 134, 51, 83
	taste_description = "berries"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/poisonberryjuice
	required_drink_type = /datum/reagent/consumable/poisonberryjuice
	name = "glass of berry juice"
	desc = "Berry juice. Or maybe it's poison. Who cares?"
	icon_state = "poisonberryjuice"

/datum/reagent/consumable/poisonberryjuice/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	affected_mob.adjustToxLoss(1 * REM * delta_time, FALSE, required_biotype = affected_biotype)
	. = TRUE
	..()

/datum/reagent/consumable/watermelonjuice
	name = "Watermelon Juice"
	description = "Delicious juice made from watermelon."
	color = "#863333" // rgb: 134, 51, 51
	taste_description = "juicy watermelon"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/watermelonjuice
	required_drink_type = /datum/reagent/consumable/watermelonjuice
	name = "glass of watermelon juice"
	desc = "A glass of watermelon juice."
	icon_state = "glass_red"

/datum/reagent/consumable/lemonjuice
	name = "Lemon Juice"
	description = "This juice is VERY sour."
	color = "#863333" // rgb: 175, 175, 0
	taste_description = "sourness"
	ph = 2
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/lemonjuice
	required_drink_type = /datum/reagent/consumable/lemonjuice
	name = "glass of lemon juice"
	desc = "Sour..."
	icon_state = "lemonglass"

/datum/reagent/consumable/banana
	name = "Banana Juice"
	description = "The raw essence of a banana. HONK"
	color = "#863333" // rgb: 175, 175, 0
	taste_description = "banana"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/banana
	required_drink_type = /datum/reagent/consumable/banana
	name = "glass of banana juice"
	desc = "The raw essence of a banana. HONK."
	icon_state = "banana"

/datum/reagent/consumable/banana/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	var/obj/item/organ/internal/liver/liver = affected_mob.getorganslot(ORGAN_SLOT_LIVER)
	if((liver && HAS_TRAIT(liver, TRAIT_COMEDY_METABOLISM)) || ismonkey(affected_mob))
		affected_mob.heal_bodypart_damage(1 * REM * delta_time, 1 * REM * delta_time)
		. = TRUE
	..()

/datum/reagent/consumable/nothing
	name = "Nothing"
	description = "Absolutely nothing."
	taste_description = "nothing"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/shot_glass/nothing
	required_drink_type = /datum/reagent/consumable/nothing
	icon_state = "shotglass"

/datum/glass_style/drinking_glass/nothing
	required_drink_type = /datum/reagent/consumable/nothing
	name = "nothing"
	desc = "Absolutely nothing."
	icon_state = "nothing"

/datum/reagent/consumable/nothing/on_mob_life(mob/living/carbon/drinker, delta_time, times_fired)
	if(ishuman(drinker) && HAS_TRAIT(drinker, TRAIT_MIMING))
		drinker.set_silence_if_lower(MIMEDRINK_SILENCE_DURATION)
		drinker.heal_bodypart_damage(1 * REM * delta_time, 1 * REM * delta_time)
		. = TRUE
	..()

/datum/reagent/consumable/laughter
	name = "Laughter"
	description = "Some say that this is the best medicine, but recent studies have proven that to be untrue."
	metabolization_rate = INFINITY
	color = "#FF4DD2"
	taste_description = "laughter"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/laughter/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	affected_mob.emote("laugh")
	affected_mob.add_mood_event("chemical_laughter", /datum/mood_event/chemical_laughter)
	..()

/datum/reagent/consumable/superlaughter
	name = "Super Laughter"
	description = "Funny until you're the one laughing."
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	color = "#FF4DD2"
	taste_description = "laughter"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/superlaughter/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	if(DT_PROB(16, delta_time))
		affected_mob.visible_message(span_danger("[affected_mob] bursts out into a fit of uncontrollable laughter!"), span_userdanger("You burst out in a fit of uncontrollable laughter!"))
		affected_mob.Stun(5)
		affected_mob.add_mood_event("chemical_laughter", /datum/mood_event/chemical_superlaughter)
	..()

/datum/reagent/consumable/potato_juice
	name = "Potato Juice"
	description = "Juice of the potato. Bleh."
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#302000" // rgb: 48, 32, 0
	taste_description = "irish sadness"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/potato_juice
	required_drink_type = /datum/reagent/consumable/potato_juice
	name = "glass of potato juice"
	desc = "Bleh..."
	icon_state = "glass_brown"

/datum/reagent/consumable/grapejuice
	name = "Grape Juice"
	description = "The juice of a bunch of grapes. Guaranteed non-alcoholic."
	color = "#290029" // dark purple
	taste_description = "grape soda"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/juicebox/grapejuice
	required_drink_type = /datum/reagent/consumable/grapejuice
	name = "grape juice box"
	desc = "For enjoying the most wonderful time of the year."
	icon_state = "nog2"
	drink_type = MEAT

/datum/reagent/consumable/plumjuice
	name = "Plum Juice"
	description = "Refreshing and slightly acidic beverage."
	color = "#b6062c"
	taste_description = "plums"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/plumjuice
	required_drink_type = /datum/reagent/consumable/plumjuice
	name = "glass of plum juice"
	desc = "Noice."
	icon_state = "plumjuiceglass"

/datum/reagent/consumable/milk
	name = "Milk"
	description = "An opaque white liquid produced by the mammary glands of mammals."
	color = "#DFDFDF" // rgb: 223, 223, 223
	taste_description = "milk"
	ph = 6.5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/condiment/milk

/datum/glass_style/drinking_glass/milk
	required_drink_type = /datum/reagent/consumable/milk
	name = "glass of milk"
	desc = "White and nutritious goodness!"
	icon_state = "glass_white"

/datum/glass_style/juicebox/milk
	required_drink_type = /datum/reagent/consumable/milk
	name = "carton of milk"
	desc = "An excellent source of calcium for growing space explorers."
	icon_state = "milkbox"
	drink_type = DAIRY | BREAKFAST

	// Milk is good for humans, but bad for plants. The sugars cannot be used by plants, and the milk fat harms growth. Not shrooms though. I can't deal with this now...
/datum/reagent/consumable/milk/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray, mob/user)
	if(!check_tray(chems, mytray))
		return

	mytray.adjust_waterlevel(round(chems.get_reagent_amount(type) * 0.3))
	myseed?.adjust_potency(-chems.get_reagent_amount(type) * 0.5)

/datum/reagent/consumable/milk/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	if(affected_mob.getBruteLoss() && DT_PROB(10, delta_time))
		affected_mob.heal_bodypart_damage(1,0)
		. = TRUE
	if(holder.has_reagent(/datum/reagent/consumable/capsaicin))
		holder.remove_reagent(/datum/reagent/consumable/capsaicin, 1 * delta_time)
	..()

/datum/reagent/consumable/soymilk
	name = "Soy Milk"
	description = "An opaque white liquid made from soybeans."
	color = "#DFDFC7" // rgb: 223, 223, 199
	taste_description = "soy milk"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/condiment/soymilk

/datum/glass_style/drinking_glass/soymilk
	required_drink_type = /datum/reagent/consumable/soymilk
	name = "glass of soy milk"
	desc = "White and nutritious soy goodness!"
	icon_state = "glass_white"

/datum/reagent/consumable/soymilk/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	if(affected_mob.getBruteLoss() && DT_PROB(10, delta_time))
		affected_mob.heal_bodypart_damage(1, 0)
		. = TRUE
	..()

/datum/reagent/consumable/cream
	name = "Cream"
	description = "The fatty, still liquid part of milk. Why don't you mix this with sum scotch, eh?"
	color = "#DFD7AF" // rgb: 223, 215, 175
	taste_description = "creamy milk"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/cup/glass/bottle/juice/cream

/datum/glass_style/drinking_glass/cream
	required_drink_type = /datum/reagent/consumable/cream
	name = "glass of cream"
	desc = "Ewwww..."
	icon_state = "glass_white"

/datum/reagent/consumable/cream/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	if(affected_mob.getBruteLoss() && DT_PROB(10, delta_time))
		affected_mob.heal_bodypart_damage(1, 0)
		. = TRUE
	..()

/datum/reagent/consumable/coffee
	name = "Coffee"
	description = "Coffee is a brewed drink prepared from roasted seeds, commonly called coffee beans, of the coffee plant."
	color = "#482000" // rgb: 72, 32, 0
	nutriment_factor = 0
	overdose_threshold = 80
	taste_description = "bitterness"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	glass_price = DRINK_PRICE_STOCK

/datum/glass_style/drinking_glass/coffee
	required_drink_type = /datum/reagent/consumable/coffee
	name = "glass of coffee"
	desc = "Don't drop it, or you'll send scalding liquid and glass shards everywhere."
	icon_state = "glass_brown"

/datum/reagent/consumable/coffee/overdose_process(mob/living/affected_mob, delta_time, times_fired)
	affected_mob.set_jitter_if_lower(10 SECONDS * REM * delta_time)
	..()

/datum/reagent/consumable/coffee/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	affected_mob.adjust_dizzy(-10 SECONDS * REM * delta_time)
	affected_mob.adjust_drowsiness(-6 SECONDS * REM * delta_time)
	affected_mob.AdjustSleeping(-40 * REM * delta_time)
	//310.15 is the normal bodytemp.
	affected_mob.adjust_bodytemperature(25 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time, 0, affected_mob.get_body_temp_normal())
	if(holder.has_reagent(/datum/reagent/consumable/frostoil))
		holder.remove_reagent(/datum/reagent/consumable/frostoil, 5 * REM * delta_time)
	..()
	. = TRUE

/datum/reagent/consumable/tea
	name = "Tea"
	description = "Tasty black tea, it has antioxidants, it's good for you!"
	color = "#101000" // rgb: 16, 16, 0
	nutriment_factor = 0
	taste_description = "tart black tea"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	glass_price = DRINK_PRICE_STOCK
	default_container = /obj/item/reagent_containers/cup/glass/mug/tea

/datum/glass_style/drinking_glass/tea
	required_drink_type = /datum/reagent/consumable/tea
	name = "glass of tea"
	desc = "Drinking it from here would not seem right."
	icon_state = "teaglass"

/datum/reagent/consumable/tea/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	affected_mob.adjust_dizzy(-4 SECONDS * REM * delta_time)
	affected_mob.adjust_drowsiness(-2 SECONDS * REM * delta_time)
	affected_mob.adjust_jitter(-6 SECONDS * REM * delta_time)
	affected_mob.AdjustSleeping(-20 * REM * delta_time)
	if(affected_mob.getToxLoss() && DT_PROB(10, delta_time))
		affected_mob.adjustToxLoss(-1, FALSE, required_biotype = affected_biotype)
	affected_mob.adjust_bodytemperature(20 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time, 0, affected_mob.get_body_temp_normal())
	..()
	. = TRUE

/datum/reagent/consumable/lemonade
	name = "Lemonade"
	description = "Sweet, tangy lemonade. Good for the soul."
	color = "#FFE978"
	quality = DRINK_NICE
	taste_description = "sunshine and summertime"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	glass_price = DRINK_PRICE_EASY

/datum/glass_style/drinking_glass/lemonade
	required_drink_type = /datum/reagent/consumable/lemonade
	name = "pitcher of lemonade"
	desc = "This drink leaves you feeling nostalgic for some reason."
	icon = 'icons/obj/drinks/mixed_drinks.dmi'
	icon_state = "lemonpitcher"

/datum/reagent/consumable/tea/arnold_palmer
	name = "Arnold Palmer"
	description = "Encourages the patient to go golfing."
	color = "#FFB766"
	quality = DRINK_NICE
	nutriment_factor = 10 * REAGENTS_METABOLISM
	taste_description = "bitter tea"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/arnold_palmer
	required_drink_type = /datum/reagent/consumable/tea/arnold_palmer
	name = "Arnold Palmer"
	desc = "You feel like taking a few golf swings after a few swigs of this."
	icon = 'icons/obj/drinks/mixed_drinks.dmi'
	icon_state = "arnold_palmer"

/datum/reagent/consumable/tea/arnold_palmer/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	if(DT_PROB(2.5, delta_time))
		to_chat(affected_mob, span_notice("[pick("You remember to square your shoulders.","You remember to keep your head down.","You can't decide between squaring your shoulders and keeping your head down.","You remember to relax.","You think about how someday you'll get two strokes off your golf game.")]"))
	..()
	. = TRUE

/datum/reagent/consumable/icecoffee
	name = "Iced Coffee"
	description = "Coffee and ice, refreshing and cool."
	color = "#102838" // rgb: 16, 40, 56
	nutriment_factor = 0
	taste_description = "bitter coldness"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/icecoffee
	required_drink_type = /datum/reagent/consumable/icecoffee
	name = "iced coffee"
	desc = "A drink to perk you up and refresh you!"
	icon = 'icons/obj/drinks/coffee.dmi'
	icon_state = "icedcoffeeglass"

/datum/reagent/consumable/icecoffee/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	affected_mob.adjust_dizzy(-10 SECONDS * REM * delta_time)
	affected_mob.adjust_drowsiness(-6 SECONDS * REM * delta_time)
	affected_mob.AdjustSleeping(-40 * REM * delta_time)
	affected_mob.adjust_bodytemperature(-5 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time, affected_mob.get_body_temp_normal())
	affected_mob.set_jitter_if_lower(10 SECONDS * REM * delta_time)
	..()
	. = TRUE

/datum/reagent/consumable/hot_ice_coffee
	name = "Hot Ice Coffee"
	description = "Coffee with pulsing ice shards"
	color = "#102838" // rgb: 16, 40, 56
	nutriment_factor = 0
	taste_description = "bitter coldness and a hint of smoke"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/hot_ice_coffee
	required_drink_type = /datum/reagent/consumable/hot_ice_coffee
	name = "hot ice coffee"
	desc = "A sharp drink - This can't have come cheap."
	icon = 'icons/obj/drinks/coffee.dmi'
	icon_state = "hoticecoffee"

/datum/reagent/consumable/hot_ice_coffee/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	affected_mob.adjust_dizzy(-10 SECONDS * REM * delta_time)
	affected_mob.adjust_drowsiness(-6 SECONDS * REM * delta_time)
	affected_mob.AdjustSleeping(-60 * REM * delta_time)
	affected_mob.adjust_bodytemperature(-7 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time, affected_mob.get_body_temp_normal())
	affected_mob.set_jitter_if_lower(10 SECONDS * REM * delta_time)
	affected_mob.adjustToxLoss(1 * REM * delta_time, FALSE, required_biotype = affected_biotype)
	..()
	. = TRUE

/datum/reagent/consumable/icetea
	name = "Iced Tea"
	description = "No relation to a certain rap artist/actor."
	color = "#104038" // rgb: 16, 64, 56
	nutriment_factor = 0
	taste_description = "sweet tea"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/icetea
	required_drink_type = /datum/reagent/consumable/icetea
	name = "iced tea"
	desc = "All natural, antioxidant-rich flavour sensation."
	icon = 'icons/obj/drinks/mixed_drinks.dmi'
	icon_state = "icedteaglass"

/datum/reagent/consumable/icetea/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	affected_mob.adjust_dizzy(-4 SECONDS * REM * delta_time)
	affected_mob.adjust_drowsiness(-2 SECONDS * REM * delta_time)
	affected_mob.AdjustSleeping(-40 * REM * delta_time)
	if(affected_mob.getToxLoss() && DT_PROB(10, delta_time))
		affected_mob.adjustToxLoss(-1, FALSE, required_biotype = affected_biotype)
	affected_mob.adjust_bodytemperature(-5 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time, affected_mob.get_body_temp_normal())
	..()
	. = TRUE

/datum/reagent/consumable/space_cola
	name = "Cola"
	description = "A refreshing beverage."
	color = "#100800" // rgb: 16, 8, 0
	taste_description = "cola"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/space_cola
	required_drink_type = /datum/reagent/consumable/space_cola
	name = "glass of Space Cola"
	desc = "A glass of refreshing Space Cola."
	icon_state = "spacecola"

/datum/reagent/consumable/space_cola/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	affected_mob.adjust_drowsiness(-10 SECONDS * REM * delta_time)
	affected_mob.adjust_bodytemperature(-5 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time, affected_mob.get_body_temp_normal())
	..()

/datum/reagent/consumable/roy_rogers
	name = "Roy Rogers"
	description = "A sweet fizzy drink."
	color = "#53090B"
	quality = DRINK_GOOD
	taste_description = "fruity overlysweet cola"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/roy_rogers
	required_drink_type = /datum/reagent/consumable/roy_rogers
	name = "Roy Rogers"
	desc = "90% sugar in a glass."
	icon_state = "royrogers"

/datum/reagent/consumable/roy_rogers/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	affected_mob.set_jitter_if_lower(12 SECONDS * REM * delta_time)
	affected_mob.adjust_drowsiness(-10 SECONDS * REM * delta_time)
	affected_mob.adjust_bodytemperature(-5 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time, affected_mob.get_body_temp_normal())
	return ..()

/datum/reagent/consumable/nuka_cola
	name = "Nuka Cola"
	description = "Cola, cola never changes."
	color = "#100800" // rgb: 16, 8, 0
	quality = DRINK_VERYGOOD
	taste_description = "the future"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/nuka_cola
	required_drink_type = /datum/reagent/consumable/nuka_cola
	name = "glass of Nuka Cola"
	desc = "Don't cry, Don't raise your eye, It's only nuclear wasteland."
	icon = 'icons/obj/drinks/soda.dmi'
	icon_state = "nuka_colaglass"

/datum/reagent/consumable/nuka_cola/on_mob_metabolize(mob/living/affected_mob)
	..()
	affected_mob.add_movespeed_modifier(/datum/movespeed_modifier/reagent/nuka_cola)

/datum/reagent/consumable/nuka_cola/on_mob_end_metabolize(mob/living/affected_mob)
	affected_mob.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/nuka_cola)
	..()

/datum/reagent/consumable/nuka_cola/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	affected_mob.set_jitter_if_lower(40 SECONDS * REM * delta_time)
	affected_mob.set_drugginess(1 MINUTES * REM * delta_time)
	affected_mob.adjust_dizzy(3 SECONDS * REM * delta_time)
	affected_mob.remove_status_effect(/datum/status_effect/drowsiness)
	affected_mob.AdjustSleeping(-40 * REM * delta_time)
	affected_mob.adjust_bodytemperature(-5 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time, affected_mob.get_body_temp_normal())
	..()
	. = TRUE

/datum/reagent/consumable/rootbeer
	name = "root beer"
	description = "A delightfully bubbly root beer, filled with so much sugar that it can actually speed up the user's trigger finger."
	color = "#181008" // rgb: 24, 16, 8
	quality = DRINK_VERYGOOD
	nutriment_factor = 10 * REAGENTS_METABOLISM
	metabolization_rate = 2 * REAGENTS_METABOLISM
	taste_description = "a monstrous sugar rush"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	/// If we activated the effect
	var/effect_enabled = FALSE

/datum/glass_style/drinking_glass/rootbeer
	required_drink_type = /datum/reagent/consumable/rootbeer
	name = "glass of root beer"
	desc = "A glass of highly potent, incredibly sugary root beer."
	icon_state = "spacecola"

/datum/reagent/consumable/rootbeer/on_mob_end_metabolize(mob/living/affected_mob)
	REMOVE_TRAIT(affected_mob, TRAIT_DOUBLE_TAP, type)
	if(current_cycle > 10)
		to_chat(affected_mob, span_warning("You feel kinda tired as your sugar rush wears off..."))
		affected_mob.adjustStaminaLoss(min(80, current_cycle * 3), required_biotype = affected_biotype)
		affected_mob.adjust_drowsiness(current_cycle * 2 SECONDS)
	..()

/datum/reagent/consumable/rootbeer/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	if(current_cycle >= 3 && !effect_enabled) // takes a few seconds for the bonus to kick in to prevent microdosing
		to_chat(affected_mob, span_notice("You feel your trigger finger getting itchy..."))
		ADD_TRAIT(affected_mob, TRAIT_DOUBLE_TAP, type)
		effect_enabled = TRUE

	affected_mob.set_jitter_if_lower(4 SECONDS * REM * delta_time)
	if(prob(50))
		affected_mob.adjust_dizzy(2 SECONDS * REM * delta_time)
	if(current_cycle > 10)
		affected_mob.adjust_dizzy(3 SECONDS * REM * delta_time)

	..()
	. = TRUE

/datum/reagent/consumable/grey_bull
	name = "Grey Bull"
	description = "Grey Bull, it gives you gloves!"
	color = "#EEFF00" // rgb: 238, 255, 0
	quality = DRINK_VERYGOOD
	taste_description = "carbonated oil"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/grey_bull
	required_drink_type = /datum/reagent/consumable/grey_bull
	name = "glass of Grey Bull"
	desc = "Surprisingly it isn't grey."
	icon_state = "grey_bull_glass"

/datum/reagent/consumable/grey_bull/on_mob_metabolize(mob/living/affected_mob)
	..()
	ADD_TRAIT(affected_mob, TRAIT_SHOCKIMMUNE, type)

/datum/reagent/consumable/grey_bull/on_mob_end_metabolize(mob/living/affected_mob)
	REMOVE_TRAIT(affected_mob, TRAIT_SHOCKIMMUNE, type)
	..()

/datum/reagent/consumable/grey_bull/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	affected_mob.set_jitter_if_lower(40 SECONDS * REM * delta_time)
	affected_mob.adjust_dizzy(2 SECONDS * REM * delta_time)
	affected_mob.remove_status_effect(/datum/status_effect/drowsiness)
	affected_mob.AdjustSleeping(-40 * REM * delta_time)
	affected_mob.adjust_bodytemperature(-5 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time, affected_mob.get_body_temp_normal())
	..()

/datum/reagent/consumable/spacemountainwind
	name = "SM Wind"
	description = "Blows right through you like a space wind."
	color = "#102000" // rgb: 16, 32, 0
	taste_description = "sweet citrus soda"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/spacemountainwind
	required_drink_type = /datum/reagent/consumable/spacemountainwind
	name = "glass of Space Mountain Wind"
	desc = "Space Mountain Wind. As you know, there are no mountains in space, only wind."
	icon_state = "Space_mountain_wind_glass"

/datum/reagent/consumable/spacemountainwind/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	affected_mob.adjust_drowsiness(-14 SECONDS * REM * delta_time)
	affected_mob.AdjustSleeping(-20 * REM * delta_time)
	affected_mob.adjust_bodytemperature(-5 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time, affected_mob.get_body_temp_normal())
	affected_mob.set_jitter_if_lower(10 SECONDS * REM * delta_time)
	..()
	. = TRUE

/datum/reagent/consumable/dr_gibb
	name = "Dr. Gibb"
	description = "A delicious blend of 42 different flavours."
	color = "#102000" // rgb: 16, 32, 0
	taste_description = "cherry soda" // FALSE ADVERTISING
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/dr_gibb
	required_drink_type = /datum/reagent/consumable/dr_gibb
	name = "glass of Dr. Gibb"
	desc = "Dr. Gibb. Not as dangerous as the container_name might imply."
	icon_state = "dr_gibb_glass"

/datum/reagent/consumable/dr_gibb/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	affected_mob.adjust_drowsiness(-12 SECONDS * REM * delta_time)
	affected_mob.adjust_bodytemperature(-5 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time, affected_mob.get_body_temp_normal())
	..()

/datum/reagent/consumable/space_up
	name = "Space-Up"
	description = "Tastes like a hull breach in your mouth."
	color = "#00FF00" // rgb: 0, 255, 0
	taste_description = "cherry soda"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/space_up
	required_drink_type = /datum/reagent/consumable/space_up
	name = "glass of Space-Up"
	desc = "Space-up. It helps you keep your cool."
	icon_state = "space-up_glass"

/datum/reagent/consumable/space_up/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	affected_mob.adjust_bodytemperature(-8 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time, affected_mob.get_body_temp_normal())
	..()

/datum/reagent/consumable/lemon_lime
	name = "Lemon Lime"
	description = "A tangy substance made of 0.5% natural citrus!"
	color = "#8CFF00" // rgb: 135, 255, 0
	taste_description = "tangy lime and lemon soda"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/lemon_lime
	required_drink_type = /datum/reagent/consumable/lemon_lime
	name = "glass of lemon-lime"
	desc = "You're pretty certain a real fruit has never actually touched this."
	icon_state = "lemonlime"

/datum/reagent/consumable/lemon_lime/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	affected_mob.adjust_bodytemperature(-8 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time, affected_mob.get_body_temp_normal())
	..()

/datum/reagent/consumable/pwr_game
	name = "Pwr Game"
	description = "The only drink with the PWR that true gamers crave."
	color = "#9385bf" // rgb: 58, 52, 75
	taste_description = "sweet and salty tang"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/pwr_game
	required_drink_type = /datum/reagent/consumable/pwr_game
	name = "glass of Pwr Game"
	desc = "Goes well with a Vlad's salad."
	icon_state = "pwrgame"

/datum/reagent/consumable/pwr_game/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume)
	. = ..()
	if(exposed_mob?.mind?.get_skill_level(/datum/skill/gaming) >= SKILL_LEVEL_LEGENDARY && (methods & INGEST) && !HAS_TRAIT(exposed_mob, TRAIT_GAMERGOD))
		ADD_TRAIT(exposed_mob, TRAIT_GAMERGOD, "pwr_game")
		to_chat(exposed_mob, "<span class='nicegreen'>As you imbibe the Pwr Game, your gamer third eye opens... \
		You feel as though a great secret of the universe has been made known to you...</span>")

/datum/reagent/consumable/pwr_game/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	affected_mob.adjust_bodytemperature(-8 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time, affected_mob.get_body_temp_normal())
	if(DT_PROB(5, delta_time))
		affected_mob.mind?.adjust_experience(/datum/skill/gaming, 5)
	..()

/datum/reagent/consumable/shamblers
	name = "Shambler's Juice"
	description = "~Shake me up some of that Shambler's Juice!~"
	color = "#f00060" // rgb: 94, 0, 38
	taste_description = "carbonated metallic soda"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/shamblers
	required_drink_type = /datum/reagent/consumable/shamblers
	name = "glass of Shambler's juice"
	desc = "Mmm mm, shambly."
	icon_state = "shamblerjuice"

/datum/reagent/consumable/shamblers/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	affected_mob.adjust_bodytemperature(-8 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time, affected_mob.get_body_temp_normal())
	..()

/datum/reagent/consumable/sodawater
	name = "Soda Water"
	description = "A can of club soda. Why not make a scotch and soda?"
	color = "#619494" // rgb: 97, 148, 148
	taste_description = "carbonated water"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/sodawater
	required_drink_type = /datum/reagent/consumable/sodawater
	name = "glass of soda water"
	desc = "Soda water. Why not make a scotch and soda?"
	icon_state = "glass_clearcarb"

// A variety of nutrients are dissolved in club soda, without sugar.
// These nutrients include carbon, oxygen, hydrogen, phosphorous, potassium, sulfur and sodium, all of which are needed for healthy plant growth.
/datum/reagent/consumable/sodawater/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray, mob/user)
	if(!check_tray(chems, mytray))
		return

	mytray.adjust_waterlevel(round(chems.get_reagent_amount(type)))
	mytray.adjust_plant_health(round(chems.get_reagent_amount(type) * 0.1))

/datum/reagent/consumable/sodawater/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	affected_mob.adjust_dizzy(-10 SECONDS * REM * delta_time)
	affected_mob.adjust_drowsiness(-6 SECONDS * REM * delta_time)
	affected_mob.adjust_bodytemperature(-5 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time, affected_mob.get_body_temp_normal())
	..()

/datum/reagent/consumable/tonic
	name = "Tonic Water"
	description = "It tastes strange but at least the quinine keeps the Space Malaria at bay."
	color = "#0064C8" // rgb: 0, 100, 200
	taste_description = "tart and fresh"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/tonic
	required_drink_type = /datum/reagent/consumable/tonic
	name = "glass of tonic water"
	desc = "Quinine tastes funny, but at least it'll keep that Space Malaria away."
	icon_state = "glass_clearcarb"

/datum/reagent/consumable/tonic/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	affected_mob.adjust_dizzy(-10 SECONDS * REM * delta_time)
	affected_mob.adjust_drowsiness(-6 SECONDS * REM * delta_time)
	affected_mob.AdjustSleeping(-40 * REM * delta_time)
	affected_mob.adjust_bodytemperature(-5 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time, affected_mob.get_body_temp_normal())
	..()
	. = TRUE

/datum/reagent/consumable/monkey_energy
	name = "Monkey Energy"
	description = "The only drink that will make you unleash the ape."
	color = "#f39b03" // rgb: 243, 155, 3
	overdose_threshold = 60
	taste_description = "barbecue and nostalgia"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/monkey_energy
	required_drink_type = /datum/reagent/consumable/monkey_energy
	name = "glass of Monkey Energy"
	desc = "You can unleash the ape, but without the pop of the can?"
	icon_state = "monkey_energy_glass"

/datum/reagent/consumable/monkey_energy/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	affected_mob.set_jitter_if_lower(80 SECONDS * REM * delta_time)
	affected_mob.adjust_dizzy(2 SECONDS * REM * delta_time)
	affected_mob.remove_status_effect(/datum/status_effect/drowsiness)
	affected_mob.AdjustSleeping(-40 * REM * delta_time)
	affected_mob.adjust_bodytemperature(-5 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time, affected_mob.get_body_temp_normal())
	..()

/datum/reagent/consumable/monkey_energy/on_mob_metabolize(mob/living/affected_mob)
	..()
	if(ismonkey(affected_mob))
		affected_mob.add_movespeed_modifier(/datum/movespeed_modifier/reagent/monkey_energy)

/datum/reagent/consumable/monkey_energy/on_mob_end_metabolize(mob/living/affected_mob)
	affected_mob.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/monkey_energy)
	..()

/datum/reagent/consumable/monkey_energy/overdose_process(mob/living/affected_mob, delta_time, times_fired)
	if(DT_PROB(7.5, delta_time))
		affected_mob.say(pick_list_replacements(BOOMER_FILE, "boomer"), forced = /datum/reagent/consumable/monkey_energy)
	..()

/datum/reagent/consumable/ice
	name = "Ice"
	description = "Frozen water, your dentist wouldn't like you chewing this."
	reagent_state = SOLID
	color = "#619494" // rgb: 97, 148, 148
	taste_description = "ice"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/cup/glass/ice

/datum/glass_style/drinking_glass/ice
	required_drink_type = /datum/reagent/consumable/ice
	name = "glass of ice"
	desc = "Generally, you're supposed to put something else in there too..."
	icon_state = "iceglass"

/datum/reagent/consumable/ice/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	affected_mob.adjust_bodytemperature(-5 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time, affected_mob.get_body_temp_normal())
	..()

/datum/reagent/consumable/soy_latte
	name = "Soy Latte"
	description = "A nice and tasty beverage while you are reading your hippie books."
	color = "#cc6404" // rgb: 204,100,4
	quality = DRINK_NICE
	taste_description = "creamy coffee"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	glass_price = DRINK_PRICE_EASY

/datum/glass_style/drinking_glass/soy_latte
	required_drink_type = /datum/reagent/consumable/soy_latte
	name = "soy latte"
	desc = "A nice and refreshing beverage while you're reading."
	icon = 'icons/obj/drinks/coffee.dmi'
	icon_state = "soy_latte"

/datum/reagent/consumable/soy_latte/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	affected_mob.adjust_dizzy(-10 SECONDS * REM * delta_time)
	affected_mob.adjust_drowsiness(-6 SECONDS * REM * delta_time)
	affected_mob.SetSleeping(0)
	affected_mob.adjust_bodytemperature(5 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time, 0, affected_mob.get_body_temp_normal())
	affected_mob.set_jitter_if_lower(10 SECONDS * REM * delta_time)
	if(affected_mob.getBruteLoss() && DT_PROB(10, delta_time))
		affected_mob.heal_bodypart_damage(1,0)
	..()
	. = TRUE

/datum/reagent/consumable/cafe_latte
	name = "Cafe Latte"
	description = "A nice, strong and tasty beverage while you are reading."
	color = "#cc6404" // rgb: 204,100,4
	quality = DRINK_NICE
	taste_description = "bitter cream"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	glass_price = DRINK_PRICE_EASY

/datum/glass_style/drinking_glass/cafe_latte
	required_drink_type = /datum/reagent/consumable/cafe_latte
	name = "cafe latte"
	desc = "A nice, strong and refreshing beverage while you're reading."
	icon = 'icons/obj/drinks/coffee.dmi'
	icon_state = "cafe_latte"

/datum/reagent/consumable/cafe_latte/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	affected_mob.adjust_dizzy(-10 SECONDS * REM * delta_time)
	affected_mob.adjust_drowsiness(-12 SECONDS * REM * delta_time)
	affected_mob.SetSleeping(0)
	affected_mob.adjust_bodytemperature(5 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time, 0, affected_mob.get_body_temp_normal())
	affected_mob.set_jitter_if_lower(10 SECONDS * REM * delta_time)
	if(affected_mob.getBruteLoss() && DT_PROB(10, delta_time))
		affected_mob.heal_bodypart_damage(1, 0)
	..()
	. = TRUE

/datum/reagent/consumable/doctor_delight
	name = "The Doctor's Delight"
	description = "A gulp a day keeps the Medibot away! A mixture of juices that heals most damage types fairly quickly at the cost of hunger."
	color = "#FF8CFF" // rgb: 255, 140, 255
	quality = DRINK_VERYGOOD
	taste_description = "homely fruit"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/doctor_delight
	required_drink_type = /datum/reagent/consumable/doctor_delight
	name = "Doctor's Delight"
	desc = "The space doctor's favorite. Guaranteed to restore bodily injury; side effects include cravings and hunger."
	icon = 'icons/obj/drinks/mixed_drinks.dmi'
	icon_state = "doctorsdelightglass"

/datum/reagent/consumable/doctor_delight/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	affected_mob.adjustBruteLoss(-0.5 * REM * delta_time, FALSE, required_bodytype = affected_bodytype)
	affected_mob.adjustFireLoss(-0.5 * REM * delta_time, FALSE, required_bodytype = affected_bodytype)
	affected_mob.adjustToxLoss(-0.5 * REM * delta_time, FALSE, required_biotype = affected_biotype)
	affected_mob.adjustOxyLoss(-0.5 * REM * delta_time, FALSE, required_biotype = affected_biotype)
	if(affected_mob.nutrition && (affected_mob.nutrition - 2 > 0))
		var/obj/item/organ/internal/liver/liver = affected_mob.getorganslot(ORGAN_SLOT_LIVER)
		if(!(HAS_TRAIT(liver, TRAIT_MEDICAL_METABOLISM)))
			// Drains the nutrition of the holder. Not medical doctors though, since it's the Doctor's Delight!
			affected_mob.adjust_nutrition(-2 * REM * delta_time)
	..()
	. = TRUE

/datum/reagent/consumable/cinderella
	name = "Cinderella"
	description = "Most definitely a fruity alcohol cocktail to have while partying with your friends."
	color = "#FF6A50"
	quality = DRINK_VERYGOOD
	taste_description = "sweet tangy fruit"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/cinderella
	required_drink_type = /datum/reagent/consumable/cinderella
	name = "Cinderella"
	desc = "There is not a single drop of alcohol in this thing."
	icon = 'icons/obj/drinks/mixed_drinks.dmi'
	icon_state = "cinderella"

/datum/reagent/consumable/cinderella/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	affected_mob.adjust_disgust(-5 * REM * delta_time)
	return ..()

/datum/reagent/consumable/cherryshake
	name = "Cherry Shake"
	description = "A cherry flavored milkshake."
	color = "#FFB6C1"
	quality = DRINK_VERYGOOD
	nutriment_factor = 8 * REAGENTS_METABOLISM
	taste_description = "creamy tart cherry"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	glass_price = DRINK_PRICE_MEDIUM

/datum/glass_style/drinking_glass/cherryshake
	required_drink_type = /datum/reagent/consumable/cherryshake
	name = "cherry shake"
	desc = "A cherry flavored milkshake."
	icon = 'icons/obj/drinks/shakes.dmi'
	icon_state = "cherryshake"

/datum/reagent/consumable/bluecherryshake
	name = "Blue Cherry Shake"
	description = "An exotic milkshake."
	color = "#00F1FF"
	quality = DRINK_VERYGOOD
	nutriment_factor = 8 * REAGENTS_METABOLISM
	taste_description = "creamy blue cherry"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/bluecherryshake
	required_drink_type = /datum/reagent/consumable/bluecherryshake
	name = "blue cherry shake"
	desc = "An exotic blue milkshake."
	icon = 'icons/obj/drinks/shakes.dmi'
	icon_state = "bluecherryshake"

/datum/reagent/consumable/vanillashake
	name = "Vanilla Shake"
	description = "A vanilla flavored milkshake. The basics are still good."
	color = "#E9D2B2"
	quality = DRINK_VERYGOOD
	nutriment_factor = 8 * REAGENTS_METABOLISM
	taste_description = "sweet creamy vanilla"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	glass_price = DRINK_PRICE_MEDIUM

/datum/glass_style/drinking_glass/vanillashake
	required_drink_type = /datum/reagent/consumable/vanillashake
	name = "vanilla shake"
	desc = "A vanilla flavored milkshake."
	icon = 'icons/obj/drinks/shakes.dmi'
	icon_state = "vanillashake"

/datum/reagent/consumable/caramelshake
	name = "Caramel Shake"
	description = "A caramel flavored milkshake. Your teeth hurt looking at it."
	color = "#E17C00"
	quality = DRINK_GOOD
	nutriment_factor = 10 * REAGENTS_METABOLISM
	taste_description = "sweet rich creamy caramel"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	glass_price = DRINK_PRICE_MEDIUM

/datum/glass_style/drinking_glass/caramelshake
	required_drink_type = /datum/reagent/consumable/caramelshake
	name = "caramel shake"
	desc = "A caramel flavored milkshake."
	icon = 'icons/obj/drinks/shakes.dmi'
	icon_state = "caramelshake"

/datum/reagent/consumable/choccyshake
	name = "Chocolate Shake"
	description = "A frosty chocolate milkshake."
	color = "#541B00"
	quality = DRINK_VERYGOOD
	nutriment_factor = 8 * REAGENTS_METABOLISM
	taste_description = "sweet creamy chocolate"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	glass_price = DRINK_PRICE_MEDIUM

/datum/glass_style/drinking_glass/choccyshake
	required_drink_type = /datum/reagent/consumable/choccyshake
	name = "chocolate shake"
	desc = "A chocolate flavored milkshake."
	icon = 'icons/obj/drinks/shakes.dmi'
	icon_state = "choccyshake"

/datum/reagent/consumable/strawberryshake
	name = "Strawberry Shake"
	description = "A strawberry milkshake."
	color = "#ff7b7b"
	quality = DRINK_VERYGOOD
	nutriment_factor = 8 * REAGENTS_METABOLISM
	taste_description = "sweet strawberries and milk"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	glass_price = DRINK_PRICE_MEDIUM

/datum/glass_style/drinking_glass/strawberryshake
	required_drink_type = /datum/reagent/consumable/strawberryshake
	name = "strawberry shake"
	desc = "A strawberry flavored milkshake."
	icon = 'icons/obj/drinks/shakes.dmi'
	icon_state = "strawberryshake"

/datum/reagent/consumable/bananashake
	name = "Banana Shake"
	description = "A banana milkshake. Stuff that clowns drink at their honkday parties."
	color = "#f2d554"
	quality = DRINK_VERYGOOD
	nutriment_factor = 8 * REAGENTS_METABOLISM
	taste_description = "thick banana"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	glass_price = DRINK_PRICE_MEDIUM

/datum/glass_style/drinking_glass/bananashake
	required_drink_type = /datum/reagent/consumable/bananashake
	name = "banana shake"
	desc = "A banana flavored milkshake."
	icon = 'icons/obj/drinks/shakes.dmi'
	icon_state = "bananashake"

/datum/reagent/consumable/pumpkin_latte
	name = "Pumpkin Latte"
	description = "A mix of pumpkin juice and coffee."
	color = "#F4A460"
	quality = DRINK_VERYGOOD
	nutriment_factor = 3 * REAGENTS_METABOLISM
	taste_description = "creamy pumpkin"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/pumpkin_latte
	required_drink_type = /datum/reagent/consumable/pumpkin_latte
	name = "pumpkin latte"
	desc = "A mix of coffee and pumpkin juice."
	icon = 'icons/obj/drinks/mixed_drinks.dmi'
	icon_state = "pumpkin_latte"

/datum/reagent/consumable/gibbfloats
	name = "Gibb Floats"
	description = "Ice cream on top of a Dr. Gibb glass."
	color = "#B22222"
	quality = DRINK_NICE
	nutriment_factor = 3 * REAGENTS_METABOLISM
	taste_description = "creamy cherry"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/gibbfloats
	required_drink_type = /datum/reagent/consumable/gibbfloats
	name = "Gibbfloat"
	desc = "Dr. Gibb with ice cream on top."
	icon = 'icons/obj/drinks/mixed_drinks.dmi'
	icon_state = "gibbfloats"

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

/datum/glass_style/drinking_glass/triple_citrus
	required_drink_type = /datum/reagent/consumable/triple_citrus
	name = "glass of triple citrus"
	desc = "A mixture of citrus juices. Tangy, yet smooth."
	icon = 'icons/obj/drinks/mixed_drinks.dmi'
	icon_state = "triplecitrus" //needs own sprite mine are trash //your sprite is great tho

/datum/reagent/consumable/grape_soda
	name = "Grape Soda"
	description = "Beloved by children and teetotalers."
	color = "#E6CDFF"
	taste_description = "grape soda"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/grape_soda
	required_drink_type = /datum/reagent/consumable/grape_soda
	name = "glass of grape juice"

/datum/reagent/consumable/grape_soda/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	affected_mob.adjust_bodytemperature(-5 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time, affected_mob.get_body_temp_normal())
	..()

/datum/reagent/consumable/milk/chocolate_milk
	name = "Chocolate Milk"
	description = "Milk for cool kids."
	color = "#7D4E29"
	quality = DRINK_NICE
	taste_description = "chocolate milk"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/juicebox/chocolate_milk
	required_drink_type = /datum/reagent/consumable/milk/chocolate_milk
	name = "carton of chocolate milk"
	desc = "Milk for cool kids!"
	icon_state = "chocolatebox"
	drink_type = SUGAR | DAIRY

/datum/reagent/consumable/hot_coco
	name = "Hot Coco"
	description = "Made with love! And coco beans."
	nutriment_factor = 4 * REAGENTS_METABOLISM
	color = "#403010" // rgb: 64, 48, 16
	taste_description = "creamy chocolate"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/hot_coco
	required_drink_type = /datum/reagent/consumable/hot_coco
	name = "glass of hot coco"
	desc = "A favorite winter drink to warm you up."
	icon_state = "chocolateglass"

/datum/reagent/consumable/hot_coco/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	affected_mob.adjust_bodytemperature(5 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time, 0, affected_mob.get_body_temp_normal())
	if(affected_mob.getBruteLoss() && DT_PROB(10, delta_time))
		affected_mob.heal_bodypart_damage(1, 0)
		. = TRUE
	if(holder.has_reagent(/datum/reagent/consumable/capsaicin))
		holder.remove_reagent(/datum/reagent/consumable/capsaicin, 2 * REM * delta_time)
	..()

/datum/reagent/consumable/italian_coco
	name = "Italian Hot Chocolate"
	description = "Made with love! You can just imagine a happy Nonna from the smell."
	nutriment_factor = 8 * REAGENTS_METABOLISM
	color = "#57372A"
	quality = DRINK_VERYGOOD
	taste_description = "thick creamy chocolate"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/italian_coco
	required_drink_type = /datum/reagent/consumable/italian_coco
	name = "glass of italian coco"
	desc = "A spin on a winter favourite, made to please."
	icon = 'icons/obj/drinks/mixed_drinks.dmi'
	icon_state = "italiancoco"

/datum/reagent/consumable/italian_coco/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	affected_mob.adjust_bodytemperature(5 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time, 0, affected_mob.get_body_temp_normal())
	return ..()

/datum/reagent/consumable/menthol
	name = "Menthol"
	description = "Alleviates coughing symptoms one might have."
	color = "#80AF9C"
	taste_description = "mint"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/cup/glass/bottle/juice/menthol

/datum/glass_style/drinking_glass/menthol
	required_drink_type = /datum/reagent/consumable/menthol
	name = "glass of menthol"
	desc = "Tastes naturally minty, and imparts a very mild numbing sensation."
	icon_state = "glass_green"

/datum/reagent/consumable/menthol/on_mob_life(mob/living/affected_mob, delta_time, times_fired)
	affected_mob.apply_status_effect(/datum/status_effect/throat_soothed)
	..()

/datum/reagent/consumable/grenadine
	name = "Grenadine"
	description = "Not cherry flavored!"
	color = "#EA1D26"
	taste_description = "sweet pomegranates"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/grenadine
	required_drink_type = /datum/reagent/consumable/grenadine
	name = "glass of grenadine"
	desc = "Delicious flavored syrup."

/datum/reagent/consumable/parsnipjuice
	name = "Parsnip Juice"
	description = "Why..."
	color = "#FFA500"
	taste_description = "parsnip"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/parsnipjuice
	required_drink_type = /datum/reagent/consumable/parsnipjuice
	name = "glass of parsnip juice"

/datum/reagent/consumable/pineapplejuice
	name = "Pineapple Juice"
	description = "Tart, tropical, and hotly debated."
	color = "#F7D435"
	taste_description = "pineapple"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/cup/glass/bottle/juice/pineapplejuice

/datum/glass_style/drinking_glass/pineapplejuice
	required_drink_type = /datum/reagent/consumable/pineapplejuice
	name = "glass of pineapple juice"
	desc = "Tart, tropical, and hotly debated."

/datum/glass_style/juicebox/pineapplejuice
	required_drink_type = /datum/reagent/consumable/pineapplejuice
	name = "pineapple juice box"
	desc = "Why would you even want this?"
	icon_state = "pineapplebox"
	drink_type = FRUIT | PINEAPPLE

/datum/reagent/consumable/peachjuice //Intended to be extremely rare due to being the limiting ingredients in the blazaam drink
	name = "Peach Juice"
	description = "Just peachy."
	color = "#E78108"
	taste_description = "peaches"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/peachjuice
	required_drink_type = /datum/reagent/consumable/peachjuice
	name = "glass of peach juice"

/datum/reagent/consumable/cream_soda
	name = "Cream Soda"
	description = "A classic space-American vanilla flavored soft drink."
	color = "#dcb137"
	quality = DRINK_VERYGOOD
	taste_description = "fizzy vanilla"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/cream_soda
	required_drink_type = /datum/reagent/consumable/cream_soda
	name = "Cream Soda"
	desc = "A classic space-American vanilla flavored soft drink."
	icon = 'icons/obj/drinks/mixed_drinks.dmi'
	icon_state = "cream_soda"

/datum/reagent/consumable/cream_soda/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	affected_mob.adjust_bodytemperature(-5 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time, affected_mob.get_body_temp_normal())
	..()

/datum/reagent/consumable/sol_dry
	name = "Sol Dry"
	description = "A soothing, mellow drink made from ginger."
	color = "#f7d26a"
	quality = DRINK_NICE
	taste_description = "sweet ginger spice"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/sol_dry
	required_drink_type = /datum/reagent/consumable/sol_dry
	name = "Sol Dry"
	desc = "A soothing, mellow drink made from ginger."
	icon_state = "soldry"

/datum/reagent/consumable/sol_dry/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	affected_mob.adjust_disgust(-5 * REM * delta_time)
	..()

/datum/reagent/consumable/shirley_temple
	name = "Shirley Temple"
	description = "Here you go little girl, now you can drink like the adults."
	color = "#F43724"
	quality = DRINK_GOOD
	taste_description = "sweet cherry syrup and ginger spice"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/shirley_temple
	required_drink_type = /datum/reagent/consumable/shirley_temple
	name = "Shirley Temple"
	desc = "Ginger ale with processed grenadine. "
	icon = 'icons/obj/drinks/mixed_drinks.dmi'
	icon_state = "shirleytemple"

/datum/reagent/consumable/shirley_temple/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	affected_mob.adjust_disgust(-3 * REM * delta_time)
	return ..()

/datum/reagent/consumable/red_queen
	name = "Red Queen"
	description = "DRINK ME."
	color = "#e6ddc3"
	quality = DRINK_GOOD
	taste_description = "wonder"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	var/current_size = RESIZE_DEFAULT_SIZE

/datum/glass_style/drinking_glass/red_queen
	required_drink_type = /datum/reagent/consumable/red_queen
	name = "Red Queen"
	desc = "DRINK ME."
	icon = 'icons/obj/drinks/mixed_drinks.dmi'
	icon_state = "red_queen"

/datum/reagent/consumable/red_queen/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	if(DT_PROB(50, delta_time))
		return ..()

	var/newsize = pick(0.5, 0.75, 1, 1.50, 2)
	newsize *= RESIZE_DEFAULT_SIZE
	affected_mob.resize = newsize/current_size
	current_size = newsize
	affected_mob.update_transform()
	if(DT_PROB(23, delta_time))
		affected_mob.emote("sneeze")
	..()

/datum/reagent/consumable/red_queen/on_mob_end_metabolize(mob/living/affected_mob)
	affected_mob.resize = RESIZE_DEFAULT_SIZE/current_size
	current_size = RESIZE_DEFAULT_SIZE
	affected_mob.update_transform()
	..()

/datum/reagent/consumable/bungojuice
	name = "Bungo Juice"
	color = "#F9E43D"
	description = "Exotic! You feel like you are on vacation already."
	taste_description = "succulent bungo"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/bungojuice
	required_drink_type = /datum/reagent/consumable/bungojuice
	name = "glass of bungo juice"
	desc = "Exotic! You feel like you are on vacation already."
	icon_state = "glass_yellow"

/datum/reagent/consumable/prunomix
	name = "Pruno Mixture"
	color = "#E78108"
	description = "Fruit, sugar, yeast, and water pulped together into a pungent slurry."
	taste_description = "garbage"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/prunomix
	required_drink_type = /datum/reagent/consumable/prunomix
	name = "glass of pruno mixture"
	desc = "Fruit, sugar, yeast, and water pulped together into a pungent slurry."
	icon_state = "glass_orange"

/datum/reagent/consumable/aloejuice
	name = "Aloe Juice"
	color = "#A3C48B"
	description = "A healthy and refreshing juice."
	taste_description = "vegetable"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/aloejuice
	required_drink_type = /datum/reagent/consumable/aloejuice
	name = "glass of aloe juice"
	desc = "A healthy and refreshing juice."
	icon_state = "glass_yellow"

/datum/reagent/consumable/aloejuice/on_mob_life(mob/living/affected_mob, delta_time, times_fired)
	if(affected_mob.getToxLoss() && DT_PROB(16, delta_time))
		affected_mob.adjustToxLoss(-1, FALSE, required_biotype = affected_biotype)
	..()
	. = TRUE

/datum/reagent/consumable/agua_fresca
	name = "Agua Fresca"
	description = "A refreshing watermelon agua fresca. Perfect on a day at the holodeck."
	color = "#D25B66"
	quality = DRINK_VERYGOOD
	taste_description = "cool refreshing watermelon"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/agua_fresca
	required_drink_type = /datum/reagent/consumable/agua_fresca
	name = "Agua Fresca"
	desc = "90% water, but still refreshing."
	icon = 'icons/obj/drinks/mixed_drinks.dmi'
	icon_state = "aguafresca"

/datum/reagent/consumable/agua_fresca/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	affected_mob.adjust_bodytemperature(-8 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time, affected_mob.get_body_temp_normal())
	if(affected_mob.getToxLoss() && DT_PROB(10, delta_time))
		affected_mob.adjustToxLoss(-0.5, FALSE, required_biotype = affected_biotype)
	return ..()

/datum/reagent/consumable/mushroom_tea
	name = "Mushroom Tea"
	description = "A savoury glass of tea made from polypore mushroom shavings, originally native to Tizira."
	color = "#674945" // rgb: 16, 16, 0
	nutriment_factor = 0
	taste_description = "mushrooms"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/mushroom_tea
	required_drink_type = /datum/reagent/consumable/mushroom_tea
	name = "glass of mushroom tea"
	desc = "Oddly savoury for a drink."
	icon_state = "mushroom_tea_glass"

/datum/reagent/consumable/mushroom_tea/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	if(islizard(affected_mob))
		affected_mob.adjustOxyLoss(-0.5 * REM * delta_time, FALSE, required_biotype = affected_biotype)
	..()
	. = TRUE

//Moth Stuff
/datum/reagent/consumable/toechtauese_juice
	name = "Töchtaüse Juice"
	description = "An unpleasant juice made from töchtaüse berries. Best made into a syrup, unless you enjoy pain."
	color = "#554862"
	nutriment_factor = 0
	taste_description = "fiery itchy pain"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/toechtauese_juice
	required_drink_type = /datum/reagent/consumable/toechtauese_juice
	name = "glass of töchtaüse juice"
	desc = "Raw, unadulterated töchtaüse juice. One swig will fill you with regrets."
	icon_state = "toechtauese_syrup"

/datum/reagent/consumable/toechtauese_syrup
	name = "Töchtaüse Syrup"
	description = "A harsh spicy and bitter syrup, made from töchtaüse berries. Useful as an ingredient, both for food and cocktails."
	color = "#554862"
	nutriment_factor = 0
	taste_description = "sugar, spice, and nothing nice"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/toechtauese_syrup
	required_drink_type = /datum/reagent/consumable/toechtauese_syrup
	name = "glass of töchtaüse syrup"
	desc = "Not for drinking on its own."
	icon_state = "toechtauese_syrup"

/datum/reagent/consumable/strawberry_banana
	name = "strawberry banana smoothie"
	description = "A classic smoothie made from strawberries and bananas."
	color = "#FF9999"
	nutriment_factor = 0
	taste_description = "strawberry and banana"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/strawberry_banana
	required_drink_type = /datum/reagent/consumable/strawberry_banana
	name = "strawberry banana smoothie"
	desc = "A classic drink which countless souls have bonded over..."
	icon = 'icons/obj/drinks/shakes.dmi'
	icon_state = "strawberry_banana"

/datum/reagent/consumable/berry_blast
	name = "berry blast smoothie"
	description = "A classic smoothie made from mixed berries."
	color = "#A76DC5"
	nutriment_factor = 0
	taste_description = "mixed berry"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/berry_blast
	required_drink_type = /datum/reagent/consumable/berry_blast
	name = "berry blast smoothie"
	desc = "A classic drink, freshly made with hand picked berries. Or, maybe not."
	icon = 'icons/obj/drinks/shakes.dmi'
	icon_state = "berry_blast"

/datum/reagent/consumable/funky_monkey
	name = "funky monkey smoothie"
	description = "A classic smoothie made from chocolate and bananas."
	color = "#663300"
	nutriment_factor = 0
	taste_description = "chocolate and banana"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/funky_monkey
	required_drink_type = /datum/reagent/consumable/funky_monkey
	name = "funky monkey smoothie"
	desc = "A classic drink made with chocolate and banana. No monkeys were harmed, officially."
	icon = 'icons/obj/drinks/shakes.dmi'
	icon_state = "funky_monkey"

/datum/reagent/consumable/green_giant
	name = "green giant smoothie"
	description = "A green vegetable smoothie, made without vegetables."
	color = "#003300"
	nutriment_factor = 0
	taste_description = "green, just green"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/green_giant
	required_drink_type = /datum/reagent/consumable/green_giant
	name = "green giant smoothie"
	desc = "A classic drink, if you enjoy juiced wheatgrass and chia seeds."
	icon = 'icons/obj/drinks/shakes.dmi'
	icon_state = "green_giant"

/datum/reagent/consumable/melon_baller
	name = "melon baller smoothie"
	description = "A classic smoothie made from melons."
	color = "#D22F55"
	nutriment_factor = 0
	taste_description = "fresh melon"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/melon_baller
	required_drink_type = /datum/reagent/consumable/melon_baller
	name = "melon baller smoothie"
	desc = "A wonderfully fresh melon smoothie. Guaranteed to brighten your day."
	icon = 'icons/obj/drinks/shakes.dmi'
	icon_state = "melon_baller"

/datum/reagent/consumable/vanilla_dream
	name = "vanilla dream smoothie"
	description = "A classic smoothie made from vanilla and fresh cream."
	color = "#FFF3DD"
	nutriment_factor = 0
	taste_description = "creamy vanilla"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/vanilla_dream
	required_drink_type = /datum/reagent/consumable/vanilla_dream
	name = "vanilla dream smoothie"
	desc = "A classic drink made with vanilla and fresh cream."
	icon = 'icons/obj/drinks/shakes.dmi'
	icon_state = "vanilla_dream"

/datum/reagent/consumable/cucumberjuice
	name = "Cucumber Juice"
	description = "Ordinary cucumber juice, nothing from the fantasy world."
	color = "#6cd87a"
	taste_description = "light cucumber"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/cucumberjuice
	required_drink_type = /datum/reagent/consumable/cucumberjuice
	name = "glass of cucumber juice"
	desc = "A glass of cucumber juice."
	icon_state = "glass_cucumber"

/datum/reagent/consumable/cucumberlemonade
	name = "Cucumber Lemonade"
	description = "Cucumber juice, sugar and soda, what else is needed for happiness?"
	color = "#6cd87a"
	quality = DRINK_GOOD
	taste_description = "citrus soda with cucumber"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/cucumberlemonade
	required_drink_type = /datum/reagent/consumable/cucumberlemonade
	name = "cucumber lemonade"
	desc = "The smell of cucumber from lemonade, I'm sure I won't get poisoned?."
	icon = 'icons/obj/drinks/mixed_drinks.dmi'
	icon_state = "cucumber_lemonade"

/datum/reagent/consumable/cucumberlemonade/on_mob_life(mob/living/carbon/doll, delta_time, times_fired)
	doll.adjust_bodytemperature(-8 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time, doll.get_body_temp_normal())
	if(doll.getToxLoss() && DT_PROB(10, delta_time))
		doll.adjustToxLoss(-0.5, FALSE, required_biotype = affected_biotype)
	return ..()

/datum/reagent/consumable/mississippi_queen
	name = "Mississippi Queen"
	description = "If you think you're so hot, how about a victory drink?"
	color = "#d4422f" // rgb: 212,66,47
	taste_description = "sludge seeping down your throat"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/mississippi_queen
	required_drink_type = /datum/reagent/consumable/mississippi_queen
	name = "Mississippi Queen"
	desc = "Mullets and cut-up jorts not included."
	icon = 'icons/obj/drinks/mixed_drinks.dmi'
	icon_state = "mississippiglass"

/datum/reagent/consumable/mississippi_queen/on_mob_life(mob/living/carbon/drinker, delta_time, times_fired)
	switch(current_cycle)
		if(10 to 20)
			drinker.adjust_dizzy(4 SECONDS * REM * delta_time)
		if(20 to 30)
			if(DT_PROB(15, delta_time))
				drinker.adjust_confusion(4 SECONDS * REM * delta_time)
		if(30 to 200)
			drinker.adjust_hallucinations(60 SECONDS * REM * delta_time)

	return ..()
