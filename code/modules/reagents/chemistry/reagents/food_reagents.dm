///////////////////////////////////////////////////////////////////
					//Food Reagents
//////////////////////////////////////////////////////////////////


// Part of the food code. Also is where all the food
// condiments, additives, and such go.


/datum/reagent/consumable
	name = "Consumable"
	taste_description = "generic food"
	taste_mult = 4
	inverse_chem_val = 0.1
	inverse_chem = null
	creation_purity = 0.5 // 50% pure by default. Below - synthetic food. Above - natural food.
	/// How much nutrition this reagent supplies
	var/nutriment_factor = 1
	/// affects mood, typically higher for mixed drinks with more complex recipes'
	var/quality = 0

/datum/reagent/consumable/New()
	. = ..()
	// All food reagents function at a fixed rate
	chemical_flags |= REAGENT_UNAFFECTED_BY_METABOLISM

/datum/reagent/consumable/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(!ishuman(affected_mob) || HAS_TRAIT(affected_mob, TRAIT_NOHUNGER))
		return

	var/mob/living/carbon/human/affected_human = affected_mob
	affected_human.adjust_nutrition(get_nutriment_factor(affected_mob) * REM * seconds_per_tick)

/datum/reagent/consumable/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume)
	. = ..()
	if(!(methods & INGEST) || !quality || HAS_TRAIT(exposed_mob, TRAIT_AGEUSIA))
		return
	switch(quality)
		if (DRINK_REVOLTING)
			exposed_mob.add_mood_event("quality_drink", /datum/mood_event/quality_revolting)
		if (DRINK_NICE)
			exposed_mob.add_mood_event("quality_drink", /datum/mood_event/quality_nice)
		if (DRINK_GOOD)
			exposed_mob.add_mood_event("quality_drink", /datum/mood_event/quality_good)
		if (DRINK_VERYGOOD)
			exposed_mob.add_mood_event("quality_drink", /datum/mood_event/quality_verygood)
		if (DRINK_FANTASTIC)
			exposed_mob.add_mood_event("quality_drink", /datum/mood_event/quality_fantastic)
			exposed_mob.add_mob_memory(/datum/memory/good_drink, drink = src)
		if (FOOD_AMAZING)
			exposed_mob.add_mood_event("quality_food", /datum/mood_event/amazingtaste)
			// The food this was in was really tasty, not the reagent itself
			var/obj/item/the_real_food = holder.my_atom
			if(isitem(the_real_food) && !is_reagent_container(the_real_food))
				exposed_mob.add_mob_memory(/datum/memory/good_food, food = the_real_food)

/// Gets just how much nutrition this reagent is worth for the passed mob
/datum/reagent/consumable/proc/get_nutriment_factor(mob/living/carbon/eater)
	return nutriment_factor * REAGENTS_METABOLISM * purity * 2

/datum/reagent/consumable/nutriment
	name = "Nutriment"
	description = "All the vitamins, minerals, and carbohydrates the body needs in pure form."
	reagent_state = SOLID
	nutriment_factor = 15
	color = "#664330" // rgb: 102, 67, 48
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_DEAD_PROCESS

	var/brute_heal = 1
	var/burn_heal = 0

/datum/reagent/consumable/nutriment/on_hydroponics_apply(obj/machinery/hydroponics/mytray, mob/user)
	mytray.adjust_plant_health(round(volume * 0.2))

/datum/reagent/consumable/nutriment/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(SPT_PROB(30, seconds_per_tick))
		if(affected_mob.heal_bodypart_damage(brute = brute_heal * REM * seconds_per_tick, burn = burn_heal * REM * seconds_per_tick, updating_health = FALSE, required_bodytype = BODYTYPE_ORGANIC))
			return UPDATE_MOB_HEALTH

/datum/reagent/consumable/nutriment/on_new(list/supplied_data)
	. = ..()
	if(!data)
		return
	// taste data can sometimes be ("salt" = 3, "chips" = 1)
	// and we want it to be in the form ("salt" = 0.75, "chips" = 0.25)
	// which is called "normalizing"
	if(!supplied_data)
		supplied_data = data

	// if data isn't an associative list, this has some WEIRD side effects
	// TODO probably check for assoc list?

	data = counterlist_normalise(supplied_data)

/datum/reagent/consumable/nutriment/on_merge(list/newdata, newvolume)
	. = ..()
	if(!islist(newdata) || !newdata.len)
		return

	// data for nutriment is one or more (flavour -> ratio)
	// where all the ratio values adds up to 1

	var/list/taste_amounts = list()
	if(data)
		taste_amounts = data.Copy()

	counterlist_scale(taste_amounts, volume)

	var/list/other_taste_amounts = newdata.Copy()
	counterlist_scale(other_taste_amounts, newvolume)

	counterlist_combine(taste_amounts, other_taste_amounts)

	counterlist_normalise(taste_amounts)

	data = taste_amounts

/datum/reagent/consumable/nutriment/get_taste_description(mob/living/taster)
	return data

/datum/reagent/consumable/nutriment/vitamin
	name = "Vitamin"
	description = "All the best vitamins, minerals, and carbohydrates the body needs in pure form."
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

	brute_heal = 1
	burn_heal = 1

/datum/reagent/consumable/nutriment/vitamin/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(affected_mob.satiety < MAX_SATIETY)
		affected_mob.satiety += 30 * REM * seconds_per_tick

/// The basic resource of vat growing.
/datum/reagent/consumable/nutriment/protein
	name = "Protein"
	description = "A natural polyamide made up of amino acids. An essential constituent of mosts known forms of life."
	brute_heal = 0.8 //Rewards the player for eating a balanced diet.
	nutriment_factor = 9 //45% as calorie dense as oil.
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/nutriment/fat
	name = "Fat"
	description = "Triglycerides found in vegetable oils and fatty animal tissue."
	color = "#f0eed7"
	taste_description = "lard"
	brute_heal = 0
	burn_heal = 1
	nutriment_factor = 18 // Twice as nutritious compared to protein and carbohydrates
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	var/fry_temperature = 450 //Around ~350 F (117 C) which deep fryers operate around in the real world

/datum/reagent/consumable/nutriment/fat/expose_obj(obj/exposed_obj, reac_volume)
	. = ..()
	if(!holder || (holder.chem_temp <= fry_temperature))
		return
	if(!isitem(exposed_obj) || HAS_TRAIT(exposed_obj, TRAIT_FOOD_FRIED))
		return
	if(is_type_in_typecache(exposed_obj, GLOB.oilfry_blacklisted_items) || (exposed_obj.resistance_flags & INDESTRUCTIBLE))
		exposed_obj.visible_message(span_notice("The hot oil has no effect on [exposed_obj]!"))
		return
	if(exposed_obj.atom_storage)
		exposed_obj.visible_message(span_notice("The hot oil splatters about as [exposed_obj] touches it. It seems too full to cook properly!"))
		return

	exposed_obj.visible_message(span_warning("[exposed_obj] rapidly fries as it's splashed with hot oil! Somehow."))
	exposed_obj.AddElement(/datum/element/fried_item, volume)
	exposed_obj.reagents.add_reagent(src.type, reac_volume)

/datum/reagent/consumable/nutriment/fat/expose_mob(mob/living/exposed_mob, methods = TOUCH, reac_volume, show_message = TRUE, touch_protection = 0)
	. = ..()
	if(!(methods & (VAPOR|TOUCH)) || isnull(holder) || (holder.chem_temp < fry_temperature)) //Directly coats the mob, and doesn't go into their bloodstream
		return

	var/burn_damage = ((holder.chem_temp / fry_temperature) * 0.33) //Damage taken per unit
	if(methods & TOUCH)
		burn_damage *= max(1 - touch_protection, 0)
	var/FryLoss = round(min(38, burn_damage * reac_volume))
	if(!HAS_TRAIT(exposed_mob, TRAIT_OIL_FRIED))
		exposed_mob.visible_message(span_warning("The boiling oil sizzles as it covers [exposed_mob]!"), \
		span_userdanger("You're covered in boiling oil!"))
		if(FryLoss)
			exposed_mob.emote("scream")
		playsound(exposed_mob, 'sound/machines/fryer/deep_fryer_emerge.ogg', 25, TRUE)
		ADD_TRAIT(exposed_mob, TRAIT_OIL_FRIED, "cooking_oil_react")
		addtimer(CALLBACK(exposed_mob, TYPE_PROC_REF(/mob/living, unfry_mob)), 3)
	if(FryLoss)
		exposed_mob.adjustFireLoss(FryLoss)

/datum/reagent/consumable/nutriment/fat/expose_turf(turf/open/exposed_turf, reac_volume)
	. = ..()
	if(!istype(exposed_turf))
		return
	exposed_turf.MakeSlippery(TURF_WET_LUBE, min_wet_time = 10 SECONDS, wet_time_to_add = reac_volume*2 SECONDS)
	var/obj/effect/hotspot/hotspot = (locate(/obj/effect/hotspot) in exposed_turf)
	if(hotspot)
		var/datum/gas_mixture/lowertemp = exposed_turf.remove_air(exposed_turf.air.total_moles())
		lowertemp.temperature = max( min(lowertemp.temperature-2000,lowertemp.temperature / 2) ,0)
		lowertemp.react(src)
		exposed_turf.assume_air(lowertemp)
		qdel(hotspot)

/datum/reagent/consumable/nutriment/fat/oil
	name = "Vegetable Oil"
	description = "A variety of cooking oil derived from plant fats. Used in food preparation and frying."
	color = "#EADD6B" //RGB: 234, 221, 107 (based off of canola oil)
	taste_mult = 0.8
	taste_description = "oil"
	nutriment_factor = 7 //Not very healthy on its own
	metabolization_rate = 10 * REAGENTS_METABOLISM
	penetrates_skin = NONE
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/condiment/vegetable_oil

/datum/reagent/consumable/nutriment/fat/oil/olive
	name = "Olive Oil"
	description = "A high quality oil, suitable for dishes where the oil is a key flavour."
	taste_description = "olive oil"
	color = "#DBCF5C"
	nutriment_factor = 10
	default_container = /obj/item/reagent_containers/condiment/olive_oil

/datum/reagent/consumable/nutriment/organ_tissue
	name = "Organ Tissue"
	description = "Natural tissues that make up the bulk of organs, providing many vitamins and minerals."
	taste_description = "rich earthy pungent"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/nutriment/cloth_fibers
	name = "Cloth Fibers"
	description = "It's not actually a form of nutriment but it does keep Mothpeople going for a short while..."
	nutriment_factor = 30
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	brute_heal = 0
	burn_heal = 0
	///Amount of satiety that will be drained when the cloth_fibers is fully metabolized
	var/delayed_satiety_drain = 2 * CLOTHING_NUTRITION_GAIN

/datum/reagent/consumable/nutriment/cloth_fibers/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(affected_mob.satiety < MAX_SATIETY)
		affected_mob.adjust_nutrition(CLOTHING_NUTRITION_GAIN)
		delayed_satiety_drain += CLOTHING_NUTRITION_GAIN

/datum/reagent/consumable/nutriment/cloth_fibers/on_mob_delete(mob/living/carbon/affected_mob)
	. = ..()
	if(!iscarbon(affected_mob))
		return

	var/mob/living/carbon/carbon_mob = affected_mob
	carbon_mob.adjust_nutrition(-delayed_satiety_drain)

/datum/reagent/consumable/nutriment/mineral
	name = "Mineral Slurry"
	description = "Minerals pounded into a paste, nutritious only if you too are made of rocks."
	color = COLOR_WEBSAFE_DARK_GRAY
	chemical_flags = NONE
	brute_heal = 0
	burn_heal = 0

/datum/reagent/consumable/nutriment/mineral/get_nutriment_factor(mob/living/carbon/eater)
	if(HAS_TRAIT(eater, TRAIT_ROCK_EATER))
		return ..()

	// You cannot eat rocks, it gives no nutrition
	return 0

/datum/reagent/consumable/sugar
	name = "Sugar"
	description = "The organic compound commonly known as table sugar and sometimes called saccharose. This white, odorless, crystalline powder has a pleasing, sweet taste."
	reagent_state = SOLID
	color = "#FFFFFF" // rgb: 255, 255, 255
	taste_mult = 1.5 // stop sugar drowning out other flavours
	nutriment_factor = 2
	metabolization_rate = 5 * REAGENTS_METABOLISM
	creation_purity = 1 // impure base reagents are a big no-no
	overdose_threshold = 120 // Hyperglycaemic shock
	taste_description = "sweetness"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/condiment/sugar

// Plants should not have sugar, they can't use it and it prevents them getting water/ nutients, it is good for mold though...
/datum/reagent/consumable/sugar/on_hydroponics_apply(obj/machinery/hydroponics/mytray, mob/user)
	mytray.adjust_weedlevel(rand(1, 2))
	mytray.adjust_pestlevel(rand(1, 2))

/datum/reagent/consumable/sugar/overdose_start(mob/living/affected_mob)
	. = ..()
	to_chat(affected_mob, span_userdanger("You go into hyperglycemic shock! Lay off the twinkies!"))
	affected_mob.AdjustSleeping(20 SECONDS)

/datum/reagent/consumable/sugar/overdose_process(mob/living/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.adjust_drowsiness_up_to((5 SECONDS * REM * seconds_per_tick), 60 SECONDS)

/datum/reagent/consumable/virus_food
	name = "Virus Food"
	description = "A mixture of water and milk. Virus cells can use this mixture to reproduce."
	nutriment_factor = 2
	color = "#899613" // rgb: 137, 150, 19
	taste_description = "watery milk"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

// Compost for EVERYTHING
/datum/reagent/consumable/virus_food/on_hydroponics_apply(obj/machinery/hydroponics/mytray, mob/user)
	mytray.adjust_plant_health(-round(volume * 0.5))

/datum/reagent/consumable/soysauce
	name = "Soysauce"
	description = "A salty sauce made from the soy plant."
	nutriment_factor = 2
	color = "#792300" // rgb: 121, 35, 0
	taste_description = "umami"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/condiment/soysauce

/datum/reagent/consumable/ketchup
	name = "Ketchup"
	description = "Ketchup, catsup, whatever. It's tomato paste."
	nutriment_factor = 5
	color = "#731008" // rgb: 115, 16, 8
	taste_description = "ketchup"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/condiment/ketchup

/datum/reagent/consumable/capsaicin
	name = "Capsaicin Oil"
	description = "This is what makes chilis hot."
	color = "#B31008" // rgb: 179, 16, 8
	taste_description = "hot peppers"
	taste_mult = 1.5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/capsaicin/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	var/heating = 0
	switch(current_cycle)
		if(1 to 15)
			heating = 5
			if(holder.has_reagent(/datum/reagent/cryostylane))
				holder.remove_reagent(/datum/reagent/cryostylane, 5 * REM * seconds_per_tick)
			if(isslime(affected_mob))
				heating = rand(5, 20)
		if(15 to 25)
			heating = 10
			if(isslime(affected_mob))
				heating = rand(10, 20)
		if(25 to 35)
			heating = 15
			if(isslime(affected_mob))
				heating = rand(15, 20)
		if(35 to INFINITY)
			heating = 20
			if(isslime(affected_mob))
				heating = rand(20, 25)
	affected_mob.adjust_bodytemperature(heating * TEMPERATURE_DAMAGE_COEFFICIENT * REM * seconds_per_tick)
	return ..()

/datum/reagent/consumable/frostoil
	name = "Frost Oil"
	description = "A special oil that noticeably chills the body. Extracted from chilly peppers and slimes."
	color = "#8BA6E9" // rgb: 139, 166, 233
	taste_description = "mint"
	ph = 13 //HMM! I wonder
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	///40 joules per unit.
	specific_heat = 40
	default_container = /obj/item/reagent_containers/cup/bottle/frostoil

/datum/reagent/consumable/frostoil/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	var/cooling = 0
	switch(current_cycle)
		if(1 to 15)
			cooling = -10
			if(holder.has_reagent(/datum/reagent/consumable/capsaicin))
				holder.remove_reagent(/datum/reagent/consumable/capsaicin, 5 * REM * seconds_per_tick)
			if(isslime(affected_mob))
				cooling = -rand(5, 20)
		if(15 to 25)
			cooling = -20
			if(isslime(affected_mob))
				cooling = -rand(10, 20)
		if(25 to 35)
			cooling = -30
			if(prob(1))
				affected_mob.emote("shiver")
			if(isslime(affected_mob))
				cooling = -rand(15, 20)
		if(35 to INFINITY)
			cooling = -40
			if(prob(5))
				affected_mob.emote("shiver")
			if(isslime(affected_mob))
				cooling = -rand(20, 25)
	affected_mob.adjust_bodytemperature(cooling * TEMPERATURE_DAMAGE_COEFFICIENT * REM * seconds_per_tick, 50)
	return ..()

/datum/reagent/consumable/frostoil/expose_turf(turf/exposed_turf, reac_volume)
	. = ..()
	if(reac_volume < 1)
		return
	if(isopenturf(exposed_turf))
		var/turf/open/exposed_open_turf = exposed_turf
		exposed_open_turf.MakeSlippery(wet_setting=TURF_WET_ICE, min_wet_time=100, wet_time_to_add=reac_volume SECONDS) // Is less effective in high pressure/high heat capacity environments. More effective in low pressure.
		var/temperature = exposed_open_turf.air.temperature
		var/heat_capacity = exposed_open_turf.air.heat_capacity()
		exposed_open_turf.air.temperature = max(exposed_open_turf.air.temperature - ((temperature - TCMB) * (heat_capacity * reac_volume * specific_heat) / (heat_capacity + reac_volume * specific_heat)) / heat_capacity, TCMB) // Exchanges environment temperature with reagent. Reagent is at 2.7K with a heat capacity of 40J per unit.
	if(reac_volume < 5)
		return
	for(var/mob/living/simple_animal/slime/exposed_slime in exposed_turf)
		exposed_slime.adjustToxLoss(rand(15,30))

/datum/reagent/consumable/condensedcapsaicin
	name = "Condensed Capsaicin"
	description = "A chemical agent used for self-defense and in police work."
	color = "#B31008" // rgb: 179, 16, 8
	taste_description = "scorching agony"
	penetrates_skin = NONE
	ph = 7.4
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/cup/bottle/capsaicin

/datum/reagent/consumable/condensedcapsaicin/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume)
	if(!ishuman(exposed_mob))
		return

	var/mob/living/carbon/victim = exposed_mob
	if(methods & (TOUCH|VAPOR))
		//check for protection
		//actually handle the pepperspray effects
		if (!victim.is_pepper_proof()) // you need both eye and mouth protection
			if(prob(5))
				victim.emote("scream")
			victim.emote("cry")
			victim.set_eye_blur_if_lower(10 SECONDS)
			victim.adjust_temp_blindness(6 SECONDS)
			victim.set_confusion_if_lower(5 SECONDS)
			victim.Knockdown(3 SECONDS)
			victim.add_movespeed_modifier(/datum/movespeed_modifier/reagent/pepperspray)
			addtimer(CALLBACK(victim, TYPE_PROC_REF(/mob, remove_movespeed_modifier), /datum/movespeed_modifier/reagent/pepperspray), 10 SECONDS)
		victim.update_damage_hud()
	if(methods & INGEST)
		if(!holder.has_reagent(/datum/reagent/consumable/milk))
			if(prob(15))
				to_chat(exposed_mob, span_danger("[pick("Your head pounds.", "Your mouth feels like it's on fire.", "You feel dizzy.")]"))
			if(prob(10))
				victim.set_eye_blur_if_lower(2 SECONDS)
			if(prob(10))
				victim.set_dizzy_if_lower(2 SECONDS)
			if(prob(5))
				victim.vomit(VOMIT_CATEGORY_DEFAULT)
	return ..()

/datum/reagent/consumable/condensedcapsaicin/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	if(!holder.has_reagent(/datum/reagent/consumable/milk))
		if(SPT_PROB(5, seconds_per_tick))
			affected_mob.visible_message(span_warning("[affected_mob] [pick("dry heaves!","coughs!","splutters!")]"))
	return ..()

/datum/reagent/consumable/salt
	name = "Table Salt"
	description = "A salt made of sodium chloride. Commonly used to season food."
	reagent_state = SOLID
	color = "#FFFFFF" // rgb: 255,255,255
	taste_description = "salt"
	penetrates_skin = NONE
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/condiment/saltshaker

/datum/reagent/consumable/salt/expose_turf(turf/exposed_turf, reac_volume) //Creates an umbra-blocking salt pile
	. = ..()
	if(!istype(exposed_turf) || (reac_volume < 1))
		return
	exposed_turf.spawn_unique_cleanable(/obj/effect/decal/cleanable/food/salt)

/datum/reagent/consumable/salt/expose_mob(mob/living/exposed_mob, methods, reac_volume)
	. = ..()
	if(!iscarbon(exposed_mob))
		return
	var/mob/living/carbon/carbies = exposed_mob
	if(!(methods & (PATCH|TOUCH|VAPOR)))
		return
	for(var/datum/wound/iter_wound as anything in carbies.all_wounds)
		iter_wound.on_salt(reac_volume, carbies)

// Salt can help with wounds by soaking up fluid, but undiluted salt will also cause irritation from the loose crystals, and it might soak up the body's water as well!
// A saltwater mixture would be best, but we're making improvised chems here, not real ones.
/datum/wound/proc/on_salt(reac_volume, mob/living/carbon/carbies)
	return

/datum/wound/pierce/bleed/on_salt(reac_volume, mob/living/carbon/carbies)
	adjust_blood_flow(-0.06 * reac_volume, initial_flow * 0.6) // 20u of a salt shacker * 0.1 = -1.6~ blood flow, but is always clamped to, at best, third blood loss from that wound.
	// Crystal irritation worsening recovery.
	gauzed_clot_rate *= 0.65
	to_chat(carbies, span_notice("The salt bits seep in and stick to [lowertext(src)], painfully irritating the skin but soaking up most of the blood."))

/datum/wound/slash/flesh/on_salt(reac_volume, mob/living/carbon/carbies)
	adjust_blood_flow(-0.1 * reac_volume, initial_flow * 0.5) // 20u of a salt shacker * 0.1 = -2~ blood flow, but is always clamped to, at best, halve blood loss from that wound.
	// Crystal irritation worsening recovery.
	clot_rate *= 0.75
	to_chat(carbies, span_notice("The salt bits seep in and stick to [lowertext(src)], painfully irritating the skin but soaking up most of the blood."))

/datum/wound/burn/flesh/on_salt(reac_volume)
	// Slightly sanitizes and disinfects, but also increases infestation rate (some bacteria are aided by salt), and decreases flesh healing (can damage the skin from moisture absorption)
	sanitization += VALUE_PER(0.4, 30) * reac_volume
	infestation -= max(VALUE_PER(0.3, 30) * reac_volume, 0)
	infestation_rate += VALUE_PER(0.12, 30) * reac_volume
	flesh_healing -= max(VALUE_PER(5, 30) * reac_volume, 0)
	to_chat(victim, span_notice("The salt bits seep in and stick to [lowertext(src)], painfully irritating the skin! After a few moments, it feels marginally better."))

/datum/reagent/consumable/blackpepper
	name = "Black Pepper"
	description = "A powder ground from peppercorns. *AAAACHOOO*"
	reagent_state = SOLID
	// no color (ie, black)
	taste_description = "pepper"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/condiment/peppermill

/datum/reagent/consumable/coco
	name = "Coco Powder"
	description = "A fatty, bitter paste made from coco beans."
	reagent_state = SOLID
	nutriment_factor = 5
	color = "#302000" // rgb: 48, 32, 0
	taste_description = "bitterness"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/garlic //NOTE: having garlic in your blood stops vampires from biting you.
	name = "Garlic Juice"
	description = "Crushed garlic. Chefs love it, but it can make you smell bad."
	color = "#FEFEFE"
	taste_description = "garlic"
	metabolization_rate = 0.15 * REAGENTS_METABOLISM
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/garlic/on_mob_add(mob/living/affected_mob, amount)
	. = ..()
	ADD_TRAIT(affected_mob, TRAIT_GARLIC_BREATH, type)

/datum/reagent/consumable/garlic/on_mob_delete(mob/living/affected_mob)
	. = ..()
	REMOVE_TRAIT(affected_mob, TRAIT_GARLIC_BREATH, type)

/datum/reagent/consumable/garlic/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(isvampire(affected_mob)) //incapacitating but not lethal. Unfortunately, vampires cannot vomit.
		if(SPT_PROB(min((current_cycle-1)/2, 12.5), seconds_per_tick))
			to_chat(affected_mob, span_danger("You can't get the scent of garlic out of your nose! You can barely think..."))
			affected_mob.Paralyze(10)
			affected_mob.set_jitter_if_lower(20 SECONDS)
	else
		var/obj/item/organ/internal/liver/liver = affected_mob.get_organ_slot(ORGAN_SLOT_LIVER)
		if(liver && HAS_TRAIT(liver, TRAIT_CULINARY_METABOLISM))
			if(SPT_PROB(10, seconds_per_tick)) //stays in the system much longer than sprinkles/banana juice, so heals slower to partially compensate
				if(affected_mob.heal_bodypart_damage(brute = 1 * REM * seconds_per_tick, burn = 1 * REM * seconds_per_tick, updating_health = FALSE))
					return UPDATE_MOB_HEALTH

/datum/reagent/consumable/tearjuice
	name = "Tear Juice"
	description = "A blinding substance extracted from certain onions."
	color = "#c0c9a0"
	taste_description = "bitterness"
	ph = 5

/datum/reagent/consumable/tearjuice/expose_mob(mob/living/exposed_mob, methods = INGEST, reac_volume)
	. = ..()
	if(!ishuman(exposed_mob))
		return

	var/mob/living/carbon/victim = exposed_mob
	if(methods & (TOUCH | VAPOR))
		var/tear_proof = victim.is_eyes_covered()
		if (!tear_proof)
			to_chat(exposed_mob, span_warning("Your eyes sting!"))
			victim.emote("cry")
			victim.adjust_eye_blur(6 SECONDS)

/datum/reagent/consumable/sprinkles
	name = "Sprinkles"
	description = "Multi-colored little bits of sugar, commonly found on donuts. Loved by cops."
	color = "#FF00FF" // rgb: 255, 0, 255
	taste_description = "childhood whimsy"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/sprinkles/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/obj/item/organ/internal/liver/liver = affected_mob.get_organ_slot(ORGAN_SLOT_LIVER)
	if(liver && HAS_TRAIT(liver, TRAIT_LAW_ENFORCEMENT_METABOLISM))
		if(affected_mob.heal_bodypart_damage(brute = 1 * REM * seconds_per_tick, burn = 1 * REM * seconds_per_tick, updating_health = FALSE))
			return UPDATE_MOB_HEALTH

/datum/reagent/consumable/enzyme
	name = "Universal Enzyme"
	description = "A universal enzyme used in the preparation of certain chemicals and foods."
	color = "#365E30" // rgb: 54, 94, 48
	taste_description = "sweetness"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/condiment/enzyme

/datum/reagent/consumable/dry_ramen
	name = "Dry Ramen"
	description = "Space age food, since August 25, 1958. Contains dried noodles, vegetables, and chemicals that boil in contact with water."
	reagent_state = SOLID
	color = "#302000" // rgb: 48, 32, 0
	taste_description = "dry and cheap noodles"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/cup/glass/dry_ramen

/datum/reagent/consumable/hot_ramen
	name = "Hot Ramen"
	description = "The noodles are boiled, the flavors are artificial, just like being back in school."
	nutriment_factor = 5
	color = "#302000" // rgb: 48, 32, 0
	taste_description = "wet and cheap noodles"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/cup/glass/dry_ramen

/datum/reagent/consumable/nutraslop
	name = "Nutraslop"
	description = "Mixture of leftover prison foods served on previous days."
	nutriment_factor = 5
	color = "#3E4A00" // rgb: 62, 74, 0
	taste_description = "your imprisonment"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/hot_ramen/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.adjust_bodytemperature(10 * TEMPERATURE_DAMAGE_COEFFICIENT * REM * seconds_per_tick, 0, affected_mob.get_body_temp_normal())

/datum/reagent/consumable/hell_ramen
	name = "Hell Ramen"
	description = "The noodles are boiled, the flavors are artificial, just like being back in school."
	nutriment_factor = 5
	color = "#302000" // rgb: 48, 32, 0
	taste_description = "wet and cheap noodles on fire"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/hell_ramen/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.adjust_bodytemperature(10 * TEMPERATURE_DAMAGE_COEFFICIENT * REM * seconds_per_tick)

/datum/reagent/consumable/flour
	name = "Flour"
	description = "This is what you rub all over yourself to pretend to be a ghost."
	reagent_state = SOLID
	color = "#FFFFFF" // rgb: 0, 0, 0
	taste_description = "chalky wheat"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_AFFECTS_WOUNDS
	default_container = /obj/item/reagent_containers/condiment/flour

/datum/reagent/consumable/flour/expose_mob(mob/living/exposed_mob, methods, reac_volume)
	. = ..()
	if(!iscarbon(exposed_mob))
		return
	var/mob/living/carbon/carbies = exposed_mob
	if(!(methods & (PATCH|TOUCH|VAPOR)))
		return
	for(var/datum/wound/iter_wound as anything in carbies.all_wounds)
		iter_wound.on_flour(reac_volume, carbies)

/datum/wound/proc/on_flour(reac_volume, mob/living/carbon/carbies)
	return

/datum/wound/pierce/bleed/on_flour(reac_volume, mob/living/carbon/carbies)
	adjust_blood_flow(-0.015 * reac_volume) // 30u of a flour sack * 0.015 = -0.45~ blood flow, prettay good
	to_chat(carbies, span_notice("The flour seeps into [lowertext(src)], painfully drying it up and absorbing some of the blood."))
	// When some nerd adds infection for wounds, make this increase the infection

/datum/wound/slash/flesh/on_flour(reac_volume, mob/living/carbon/carbies)
	adjust_blood_flow(-0.04 * reac_volume) // 30u of a flour sack * 0.04 = -1.25~ blood flow, pretty good!
	to_chat(carbies, span_notice("The flour seeps into [lowertext(src)], painfully drying some of it up and absorbing a little blood."))
	// When some nerd adds infection for wounds, make this increase the infection

// Don't pour flour onto burn wounds, it increases infection risk! Very unwise. Backed up by REAL info from REAL professionals.
// https://www.reuters.com/article/uk-factcheck-flour-burn-idUSKCN26F2N3
/datum/wound/burn/flesh/on_flour(reac_volume)
	to_chat(victim, span_notice("The flour seeps into [lowertext(src)], spiking you with intense pain! That probably wasn't a good idea..."))
	sanitization -= min(0, 1)
	infestation += 0.2
	return

/datum/reagent/consumable/flour/expose_turf(turf/exposed_turf, reac_volume)
	. = ..()
	if(isspaceturf(exposed_turf))
		return

	var/obj/effect/decal/cleanable/food/flour/flour_decal = exposed_turf.spawn_unique_cleanable(/obj/effect/decal/cleanable/food/flour)
	if(flour_decal)
		flour_decal.reagents.add_reagent(/datum/reagent/consumable/flour, reac_volume)

/datum/reagent/consumable/cherryjelly
	name = "Cherry Jelly"
	description = "Totally the best. Only to be spread on foods with excellent lateral symmetry."
	nutriment_factor = 10
	color = "#801E28" // rgb: 128, 30, 40
	taste_description = "cherry"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/condiment/cherryjelly

/datum/reagent/consumable/bluecherryjelly
	name = "Blue Cherry Jelly"
	description = "Blue and tastier kind of cherry jelly."
	color = "#00F0FF"
	taste_description = "blue cherry"

/datum/reagent/consumable/rice
	name = "Rice"
	description = "tiny nutritious grains"
	reagent_state = SOLID
	nutriment_factor = 3
	color = "#FFFFFF" // rgb: 0, 0, 0
	taste_description = "rice"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/condiment/rice

/datum/reagent/consumable/rice_flour
	name = "Rice Flour"
	description = "Flour mixed with Rice"
	reagent_state = SOLID
	color = "#FFFFFF" // rgb: 0, 0, 0
	taste_description = "chalky wheat with rice"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/vanilla
	name = "Vanilla Powder"
	description = "A fatty, bitter paste made from vanilla pods."
	reagent_state = SOLID
	nutriment_factor = 5
	color = "#FFFACD"
	taste_description = "vanilla"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/eggyolk
	name = "Egg Yolk"
	description = "It's full of protein."
	nutriment_factor = 8
	color = "#FFB500"
	taste_description = "egg"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/eggwhite
	name = "Egg White"
	description = "It's full of even more protein."
	nutriment_factor = 4
	color = "#fffdf7"
	taste_description = "bland egg"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/corn_starch
	name = "Corn Starch"
	description = "A slippery solution."
	color = "#DBCE95"
	taste_description = "slime"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_AFFECTS_WOUNDS

// Starch has similar absorbing properties to flour (Stronger here because it's rarer)
/datum/reagent/consumable/corn_starch/expose_mob(mob/living/exposed_mob, methods, reac_volume)
	. = ..()
	if(!iscarbon(exposed_mob))
		return
	var/mob/living/carbon/carbies = exposed_mob
	if(!(methods & (PATCH|TOUCH|VAPOR)))
		return
	for(var/datum/wound/iter_wound as anything in carbies.all_wounds)
		iter_wound.on_starch(reac_volume, carbies)

/datum/wound/proc/on_starch(reac_volume, mob/living/carbon/carbies)
	return

/datum/wound/pierce/bleed/on_starch(reac_volume, mob/living/carbon/carbies)
	adjust_blood_flow(-0.03 * reac_volume)
	to_chat(carbies, span_notice("The slimey starch seeps into [lowertext(src)], painfully drying some of it up and absorbing a little blood."))
	// When some nerd adds infection for wounds, make this increase the infection
	return

/datum/wound/slash/flesh/on_starch(reac_volume, mob/living/carbon/carbies)
	adjust_blood_flow(-0.06 * reac_volume)
	to_chat(carbies, span_notice("The slimey starch seeps into [lowertext(src)], painfully drying it up and absorbing some of the blood."))
	// When some nerd adds infection for wounds, make this increase the infection
	return

/datum/wound/burn/flesh/on_starch(reac_volume, mob/living/carbon/carbies)
	to_chat(carbies, span_notice("The slimey starch seeps into [lowertext(src)], spiking you with intense pain! That probably wasn't a good idea..."))
	sanitization -= min(0, 0.5)
	infestation += 0.1
	return

/datum/reagent/consumable/corn_syrup
	name = "Corn Syrup"
	description = "Decays into sugar."
	color = "#DBCE95"
	metabolization_rate = 3 * REAGENTS_METABOLISM
	taste_description = "sweet slime"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/corn_syrup/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	holder.add_reagent(/datum/reagent/consumable/sugar, 3 * REM * seconds_per_tick)
	return ..()

/datum/reagent/consumable/honey
	name = "Honey"
	description = "Sweet sweet honey that decays into sugar. Has antibacterial and natural healing properties."
	color = "#d3a308"
	nutriment_factor = 15
	metabolization_rate = 1 * REAGENTS_METABOLISM
	taste_description = "sweetness"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/condiment/honey

// On the other hand, honey has been known to carry pollen with it rarely. Can be used to take in a lot of plant qualities all at once, or harm the plant.
/datum/reagent/consumable/honey/on_hydroponics_apply(obj/machinery/hydroponics/mytray, mob/user)
	if(!isnull(mytray.myseed) && prob(20))
		mytray.pollinate(range = 1)
		return

	mytray.adjust_weedlevel(rand(1, 2))
	mytray.adjust_pestlevel(rand(1, 2))

/datum/reagent/consumable/honey/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	holder.add_reagent(/datum/reagent/consumable/sugar, 3 * REM * seconds_per_tick)
	. = ..()
	var/need_mob_update
	if(SPT_PROB(33, seconds_per_tick))
		need_mob_update = affected_mob.adjustBruteLoss(-1, updating_health = FALSE, required_bodytype = affected_bodytype)
		need_mob_update += affected_mob.adjustFireLoss(-1, updating_health = FALSE, required_bodytype = affected_bodytype)
		need_mob_update += affected_mob.adjustOxyLoss(-1, updating_health = FALSE, required_biotype = affected_biotype)
		need_mob_update += affected_mob.adjustToxLoss(-1, updating_health = FALSE, required_biotype = affected_biotype)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/consumable/honey/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume)
	. = ..()
	if(!iscarbon(exposed_mob) || !(methods & (TOUCH|VAPOR|PATCH)))
		return

	var/mob/living/carbon/exposed_carbon = exposed_mob
	for(var/datum/surgery/surgery as anything in exposed_carbon.surgeries)
		surgery.speed_modifier = max(0.6, surgery.speed_modifier)

/datum/reagent/consumable/mayonnaise
	name = "Mayonnaise"
	description = "A white and oily mixture of mixed egg yolks."
	color = "#DFDFDF"
	taste_description = "mayonnaise"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/condiment/mayonnaise

/datum/reagent/consumable/mold // yeah, ok, togopal, I guess you could call that a condiment
	name = "Mold"
	description = "This condiment will make any food break the mold. Or your stomach."
	color ="#708a88"
	taste_description = "rancid fungus"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/eggrot
	name = "Rotten Eggyolk"
	description = "It smells absolutely dreadful."
	color ="#708a88"
	taste_description = "rotten eggs"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/nutriment/stabilized
	name = "Stabilized Nutriment"
	description = "A bioengineered protien-nutrient structure designed to decompose in high saturation. In layman's terms, it won't get you fat."
	reagent_state = SOLID
	nutriment_factor = 15
	color = "#664330" // rgb: 102, 67, 48
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/nutriment/stabilized/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(affected_mob.nutrition > NUTRITION_LEVEL_FULL - 25)
		affected_mob.adjust_nutrition(-3 * REM * get_nutriment_factor(affected_mob) * seconds_per_tick)

////Lavaland Flora Reagents////


/datum/reagent/consumable/entpoly
	name = "Entropic Polypnium"
	description = "An ichor, derived from a certain mushroom, makes for a bad time."
	color = "#1d043d"
	taste_description = "bitter mushroom"
	ph = 12
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/entpoly/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/need_mob_update
	if(current_cycle > 10)
		affected_mob.Unconscious(40 * REM * seconds_per_tick, FALSE)
	if(SPT_PROB(10, seconds_per_tick))
		affected_mob.losebreath += 4
		affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2*REM, 150, affected_biotype)
		affected_mob.adjustToxLoss(3*REM, updating_health = FALSE, required_biotype = affected_biotype)
		affected_mob.adjustStaminaLoss(10*REM, updating_stamina = FALSE, required_biotype = affected_biotype)
		affected_mob.set_eye_blur_if_lower(10 SECONDS)
		need_mob_update = TRUE
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/consumable/tinlux
	name = "Tinea Luxor"
	description = "A stimulating ichor which causes luminescent fungi to grow on the skin. "
	color = "#b5a213"
	taste_description = "tingling mushroom"
	ph = 11.2
	self_consuming = TRUE
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_DEAD_PROCESS

/datum/reagent/consumable/tinlux/expose_mob(mob/living/exposed_mob, methods = TOUCH, reac_volume, show_message = TRUE, touch_protection = 0)
	. = ..()
	if(!exposed_mob.reagents) // they won't process the reagent, but still benefit from its effects for a duration.
		var/amount = round(reac_volume * clamp(1 - touch_protection, 0, 1))
		var/duration = (amount / metabolization_rate) * SSmobs.wait
		if(duration > 1 SECONDS)
			exposed_mob.adjust_timed_status_effect(duration, /datum/status_effect/tinlux_light)

/datum/reagent/consumable/tinlux/on_mob_add(mob/living/living_mob)
	. = ..()
	living_mob.apply_status_effect(/datum/status_effect/tinlux_light) //infinite duration

/datum/reagent/consumable/tinlux/on_mob_delete(mob/living/living_mob)
	. = ..()
	living_mob.remove_status_effect(/datum/status_effect/tinlux_light)

/datum/reagent/consumable/vitfro
	name = "Vitrium Froth"
	description = "A bubbly paste that heals wounds of the skin."
	color = "#d3a308"
	nutriment_factor = 3
	taste_description = "fruity mushroom"
	ph = 10.4
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/vitfro/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/need_mob_update
	if(SPT_PROB(55, seconds_per_tick))
		need_mob_update = affected_mob.adjustBruteLoss(-1 * REM * seconds_per_tick, updating_health = FALSE, required_bodytype = affected_bodytype)
		need_mob_update += affected_mob.adjustFireLoss(-1 * REM * seconds_per_tick, updating_health = FALSE, required_bodytype = affected_bodytype)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/consumable/liquidelectricity
	name = "Liquid Electricity"
	description = "The blood of Ethereals, and the stuff that keeps them going. Great for them, horrid for anyone else."
	nutriment_factor = 5
	color = "#97ee63"
	taste_description = "pure electricity"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/liquidelectricity/enriched
	name = "Enriched Liquid Electricity"

/datum/reagent/consumable/liquidelectricity/enriched/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume) //can't be on life because of the way blood works.
	. = ..()
	if(!(methods & (INGEST|INJECT|PATCH)) || !iscarbon(exposed_mob))
		return

	var/mob/living/carbon/exposed_carbon = exposed_mob
	var/obj/item/organ/internal/stomach/ethereal/stomach = exposed_carbon.get_organ_slot(ORGAN_SLOT_STOMACH)
	if(istype(stomach))
		stomach.adjust_charge(reac_volume * 30)

/datum/reagent/consumable/liquidelectricity/enriched/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(isethereal(affected_mob))
		affected_mob.blood_volume += 1 * seconds_per_tick
	else if(SPT_PROB(10, seconds_per_tick)) //lmao at the newbs who eat energy bars
		affected_mob.electrocute_act(rand(5,10), "Liquid Electricity in their body", 1, SHOCK_NOGLOVES) //the shock is coming from inside the house
		playsound(affected_mob, SFX_SPARKS, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)

/datum/reagent/consumable/astrotame
	name = "Astrotame"
	description = "A space age artifical sweetener."
	nutriment_factor = 0
	metabolization_rate = 2 * REAGENTS_METABOLISM
	reagent_state = SOLID
	color = "#FFFFFF" // rgb: 255, 255, 255
	taste_mult = 8
	taste_description = "sweetness"
	overdose_threshold = 17
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/astrotame/overdose_process(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(affected_mob.disgust < 80)
		affected_mob.adjust_disgust(10 * REM * seconds_per_tick)

/datum/reagent/consumable/secretsauce
	name = "Secret Sauce"
	description = "What could it be?"
	nutriment_factor = 2
	color = "#792300"
	taste_description = "indescribable"
	quality = FOOD_AMAZING
	taste_mult = 100
	ph = 6.1

/datum/reagent/consumable/nutriment/peptides
	name = "Peptides"
	color = "#BBD4D9"
	taste_description = "mint frosting"
	description = "These restorative peptides not only speed up wound healing, but are nutritious as well!"
	nutriment_factor = 10 // 33% less than nutriment to reduce weight gain
	brute_heal = 3
	burn_heal = 1
	inverse_chem = /datum/reagent/peptides_failed//should be impossible, but it's so it appears in the chemical lookup gui
	inverse_chem_val = 0.2
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/caramel
	name = "Caramel"
	description = "Who would have guessed that heated sugar could be so delicious?"
	nutriment_factor = 10
	color = "#D98736"
	taste_mult = 2
	taste_description = "caramel"
	reagent_state = SOLID
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/char
	name = "Char"
	description = "Essence of the grill. Has strange properties when overdosed."
	reagent_state = LIQUID
	nutriment_factor = 5
	color = "#C8C8C8"
	taste_mult = 6
	taste_description = "smoke"
	overdose_threshold = 15
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/char/overdose_process(mob/living/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(SPT_PROB(13, seconds_per_tick))
		affected_mob.say(pick_list_replacements(BOOMER_FILE, "boomer"), forced = /datum/reagent/consumable/char)

/datum/reagent/consumable/bbqsauce
	name = "BBQ Sauce"
	description = "Sweet, smoky, savory, and gets everywhere. Perfect for grilling."
	nutriment_factor = 5
	color = "#78280A" // rgb: 120 40, 10
	taste_mult = 2.5 //sugar's 1.5, capsacin's 1.5, so a good middle ground.
	taste_description = "smokey sweetness"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/condiment/bbqsauce

/datum/reagent/consumable/chocolatepudding
	name = "Chocolate Pudding"
	description = "A great dessert for chocolate lovers."
	color = "#800000"
	quality = DRINK_VERYGOOD
	nutriment_factor = 4
	taste_description = "sweet chocolate"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	glass_price = DRINK_PRICE_EASY

/datum/glass_style/drinking_glass/chocolatepudding
	required_drink_type = /datum/reagent/consumable/chocolatepudding
	name = "chocolate pudding"
	desc = "Tasty."
	icon = 'icons/obj/drinks/shakes.dmi'
	icon_state = "chocolatepudding"

/datum/reagent/consumable/vanillapudding
	name = "Vanilla Pudding"
	description = "A great dessert for vanilla lovers."
	color = "#FAFAD2"
	quality = DRINK_VERYGOOD
	nutriment_factor = 4
	taste_description = "sweet vanilla"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/vanillapudding
	required_drink_type = /datum/reagent/consumable/vanillapudding
	name = "vanilla pudding"
	desc = "Tasty."
	icon = 'icons/obj/drinks/shakes.dmi'
	icon_state = "vanillapudding"

/datum/reagent/consumable/laughsyrup
	name = "Laughin' Syrup"
	description = "The product of juicing Laughin' Peas. Fizzy, and seems to change flavour based on what it's used with!"
	color = "#803280"
	nutriment_factor = 5
	taste_mult = 2
	taste_description = "fizzy sweetness"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/gravy
	name = "Gravy"
	description = "A mixture of flour, water, and the juices of cooked meat."
	taste_description = "gravy"
	color = "#623301"
	taste_mult = 1.2
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/pancakebatter
	name = "Pancake Batter"
	description = "A very milky batter. 5 units of this on the griddle makes a mean pancake."
	taste_description = "milky batter"
	color = "#fccc98"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/korta_flour
	name = "Korta Flour"
	description = "A coarsely ground, peppery flour made from korta nut shells."
	taste_description = "earthy heat"
	color = "#EEC39A"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/korta_milk
	name = "Korta Milk"
	description = "A milky liquid made by crushing the centre of a korta nut."
	taste_description = "sugary milk"
	color = "#FFFFFF"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/korta_nectar
	name = "Korta Nectar"
	description = "A sweet, sugary syrup made from crushed sweet korta nuts."
	color = "#d3a308"
	nutriment_factor = 5
	metabolization_rate = 1 * REAGENTS_METABOLISM
	taste_description = "peppery sweetness"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/whipped_cream
	name = "Whipped Cream"
	description = "A white fluffy cream made from whipping cream at intense speed."
	color = "#efeff0"
	nutriment_factor = 4
	taste_description = "fluffy sweet cream"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/peanut_butter
	name = "Peanut Butter"
	description = "A rich, creamy spread produced by grinding peanuts."
	taste_description = "peanuts"
	reagent_state = SOLID
	color = "#D9A066"
	nutriment_factor = 15
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/condiment/peanut_butter

/datum/reagent/consumable/peanut_butter/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired) //ET loves peanut butter
	. = ..()
	if(isabductor(affected_mob))
		affected_mob.add_mood_event("ET_pieces", /datum/mood_event/et_pieces, name)
		affected_mob.set_drugginess(30 SECONDS * REM * seconds_per_tick)

/datum/reagent/consumable/vinegar
	name = "Vinegar"
	description = "Useful for pickling, or putting on chips."
	taste_description = "acid"
	color = "#661F1E"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/condiment/vinegar

/datum/reagent/consumable/cornmeal
	name = "Cornmeal"
	description = "Ground cornmeal, for making corn related things."
	taste_description = "raw cornmeal"
	color = "#ebca85"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/condiment/cornmeal

/datum/reagent/consumable/yoghurt
	name = "Yoghurt"
	description = "Creamy natural yoghurt, with applications in both food and drinks."
	taste_description = "yoghurt"
	color = "#efeff0"
	nutriment_factor = 2
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/condiment/yoghurt

/datum/reagent/consumable/cornmeal_batter
	name = "Cornmeal Batter"
	description = "An eggy, milky, corny mixture that's not very good raw."
	taste_description = "raw batter"
	color = "#ebca85"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/olivepaste
	name = "Olive Paste"
	description = "A mushy pile of finely ground olives."
	taste_description = "mushy olives"
	color = "#adcf77"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/creamer
	name = "Coffee Creamer"
	description = "Powdered milk for cheap coffee. How delightful."
	taste_description = "milk"
	color = "#efeff0"
	nutriment_factor = 1.5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/condiment/creamer

/datum/reagent/consumable/mintextract
	name = "Mint Extract"
	description = "Useful for dealing with undesirable customers."
	color = "#CF3600" // rgb: 207, 54, 0
	taste_description = "mint"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/mintextract/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(HAS_TRAIT(affected_mob, TRAIT_FAT))
		affected_mob.investigate_log("has been gibbed by consuming [src] while fat.", INVESTIGATE_DEATHS)
		affected_mob.inflate_gib()

/datum/reagent/consumable/worcestershire
	name = "Worcestershire Sauce"
	description = "That's \"Woostershire\" sauce, by the way."
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#572b26"
	taste_description = "sweet fish"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/condiment/worcestershire

/datum/reagent/consumable/red_bay
	name = "Red Bay Seasoning"
	description = "A secret blend of herbs and spices that goes well with anything- according to Martians, at least."
	color = "#8E4C00"
	taste_description = "spice"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/condiment/red_bay

/datum/reagent/consumable/curry_powder
	name = "Curry Powder"
	description = "One of humanity's most common spices. Typically used to make curry."
	color = "#F6C800"
	taste_description = "dry curry"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/condiment/curry_powder

/datum/reagent/consumable/dashi_concentrate
	name = "Dashi Concentrate"
	description = "A concentrated form of dashi. Simmer with water in a 1:8 ratio to produce a tasty dashi broth."
	color = "#372926"
	taste_description = "extreme umami"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/condiment/dashi_concentrate

/datum/reagent/consumable/martian_batter
	name = "Martian Batter"
	description = "A thick batter made with dashi and flour, used for making dishes such as okonomiyaki and takoyaki."
	color = "#D49D26"
	taste_description = "umami dough"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/grounding_solution
	name = "Grounding Solution"
	description = "A food-safe ionic solution designed to neutralise the enigmatic \"liquid electricity\" that is common to food from Sprout, forming harmless salt on contact."
	color = "#efeff0"
	taste_description = "metallic salt"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
