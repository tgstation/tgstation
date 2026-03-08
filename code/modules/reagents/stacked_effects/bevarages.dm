/datum/stacked_metabolization_effect/sweet_coffee
	requirements = list(
		/datum/reagent/consumable/coffee = 1,
		/datum/reagent/consumable/sugar = 1,
	)

/datum/stacked_metabolization_effect/sweet_coffee/apply(list/reagents_metabolized, mob/living/carbon/owner, seconds_per_tick)
	if(!owner.mob_mood.mood_events["sweet_coffee"])
		owner.add_mood_event("sweet_coffee", /datum/mood_event/sweetcoffee)

/datum/stacked_metabolization_effect/sweet_tea
	requirements = list(
		/datum/reagent/consumable/tea = 1,
		/datum/reagent/consumable/sugar = 1,
	)

/datum/stacked_metabolization_effect/sweet_tea/apply(list/reagents_metabolized, mob/living/carbon/owner, seconds_per_tick)
	if(!owner.mob_mood.mood_events["sweet_tea"])
		owner.add_mood_event("sweet_tea", /datum/mood_event/sweettea)

/datum/stacked_metabolization_effect/coffee_oxidise
	requirements = list(
		/datum/reagent/consumable/coffee = 1,
		/datum/reagent/consumable/icecoffee = 1,
	)

/datum/stacked_metabolization_effect/coffee_oxidise/apply(list/reagents_metabolized, mob/living/carbon/owner, seconds_per_tick)
	if(SPT_PROB(30, seconds_per_tick))
		return owner.adjust_oxy_loss(-1 * average(reagents_metabolized) * seconds_per_tick, updating_health = FALSE)

/datum/stacked_metabolization_effect/coffee_oxidise_triple
	requirements = list(
		/datum/reagent/consumable/coffee = 1,
		/datum/reagent/consumable/icecoffee = 1,
		/datum/reagent/consumable/hot_ice_coffee = 1,
	)

/datum/stacked_metabolization_effect/coffee_oxidise_triple/apply(list/reagents_metabolized, mob/living/carbon/owner, seconds_per_tick)
	if(SPT_PROB(70, seconds_per_tick))
		return owner.adjust_oxy_loss(-1.5 * average(reagents_metabolized) * seconds_per_tick, updating_health = FALSE)
