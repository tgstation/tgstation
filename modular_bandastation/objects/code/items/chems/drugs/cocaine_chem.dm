#define COCAINE_POWDER_FREEZE_TEMP 250
#define CRACK_SYNTHESIS_TEMP 480

/datum/chemical_reaction/powder_cocaine
	is_cold_recipe = TRUE
	required_reagents = list(/datum/reagent/drug/cocaine = 10)
	required_temp = COCAINE_POWDER_FREEZE_TEMP
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_CHEMICAL
	mix_message = "The solution freezes into a powder!"

/datum/chemical_reaction/powder_cocaine/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/reagent_containers/cocaine(location)

/datum/chemical_reaction/freebase_cocaine
	required_reagents = list(/datum/reagent/drug/cocaine = 10, /datum/reagent/water = 5, /datum/reagent/ash = 10)
	required_temp = CRACK_SYNTHESIS_TEMP
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_CHEMICAL

/datum/chemical_reaction/freebase_cocaine/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/reagent_containers/crack(location)

/datum/reagent/drug/cocaine
	name = "cocaine"
	description = "Мощный стимулятор, получаемый из листьев коки. Уменьшает время оглушения, но при передозировке вызывает сонливость и серьезные повреждения мозга."
	color = "#ffffff"
	overdose_threshold = 20
	ph = 9
	taste_description = "bitterness" //supposedly does taste bitter in real life
	addiction_types = list(/datum/addiction/stimulants = 14) //5.6 per 2 seconds
	var/unhealthy_multiplier = 1

/datum/reagent/drug/cocaine/on_mob_metabolize(mob/living/containing_mob)
	..()
	containing_mob.add_movespeed_modifier(/datum/movespeed_modifier/reagent/stimulants)
	ADD_TRAIT(containing_mob, TRAIT_BATON_RESISTANCE, type)

/datum/reagent/drug/cocaine/on_mob_end_metabolize(mob/living/containing_mob)
	containing_mob.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/stimulants)
	REMOVE_TRAIT(containing_mob, TRAIT_BATON_RESISTANCE, type)
	..()

/datum/reagent/drug/cocaine/on_mob_life(mob/living/carbon/carbon_mob, seconds_per_tick, times_fired, metabolization_ratio)
	if(SPT_PROB(2.5, seconds_per_tick))
		var/high_message = pick("Ты чувствуешь себя нервозным.", "Ты чувствуешь, что должен действовать быстро.", "Ты чувствуешь, что нужно сделать шаг вперед.")
		to_chat(carbon_mob, span_notice("[high_message]"))
	carbon_mob.add_mood_event("zoinked", /datum/mood_event/stimulant_heavy, name)
	carbon_mob.AdjustStun(-15 * metabolization_ratio * seconds_per_tick)
	carbon_mob.AdjustKnockdown(-15 * metabolization_ratio * seconds_per_tick)
	carbon_mob.AdjustUnconscious(-15 * metabolization_ratio * seconds_per_tick)
	carbon_mob.AdjustImmobilized(-15 * metabolization_ratio * seconds_per_tick)
	carbon_mob.AdjustParalyzed(-15 * metabolization_ratio * seconds_per_tick)
	if(SPT_PROB(2.5, seconds_per_tick))
		carbon_mob.emote("shiver")
		carbon_mob.adjust_organ_loss(ORGAN_SLOT_BRAIN, (rand(1, 2) * unhealthy_multiplier) * metabolization_ratio * seconds_per_tick)
	..()
	return TRUE

/datum/reagent/drug/cocaine/overdose_start(mob/living/carbon/carbon_mob)
	to_chat(carbon_mob, span_userdanger("Ваше сердце бьется слишком быстро, это причиняет вам боль!"))

/datum/reagent/drug/cocaine/overdose_process(mob/living/carbon/carbon_mob, seconds_per_tick, times_fired, metabolization_ratio)
	carbon_mob.adjust_tox_loss(1 * metabolization_ratio * seconds_per_tick * unhealthy_multiplier, 0)
	carbon_mob.adjust_organ_loss(ORGAN_SLOT_HEART, (rand(10, 20) / 10 * unhealthy_multiplier) * metabolization_ratio * seconds_per_tick)
	carbon_mob.set_jitter_if_lower(5 SECONDS * unhealthy_multiplier)
	if(SPT_PROB(2.5, seconds_per_tick))
		carbon_mob.emote(pick("twitch","drool"))

	if(!HAS_TRAIT(carbon_mob, TRAIT_FLOORED))
		if(SPT_PROB(1.5, seconds_per_tick))
			carbon_mob.visible_message(span_danger("[carbon_mob] падает на пол!"))
			carbon_mob.Paralyze(13.5 SECONDS * unhealthy_multiplier, TRUE)
			carbon_mob.drop_all_held_items()
	..()
	return TRUE

/datum/reagent/drug/cocaine/freebase_cocaine
	name = "freebase cocaine"
	description = "Разновидность кокаина, которую можно курить."
	color = "#f0e6bb"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	unhealthy_multiplier = 2

/datum/reagent/drug/cocaine/powder_cocaine
	name = "powder cocaine"
	description = "Порошкообразная форма кокаина."
	color = "#ffffff"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
