/obj/item/food/egg
	name = "White Egg"
	///the amount the chicken is grown
	var/amount_grown = 0
	///the type of chicken that laid this egg
	var/mob/living/basic/chicken/layer_hen_type = /mob/living/basic/chicken
	///list of consumed food
	var/list/consumed_food
	///list of consumed reagents
	var/list/consumed_reagents
	///list of all possible mutations
	var/list/mutations = list()
	///eggs ore type
	var/obj/item/stack/ore/production_type = null
	///list of picked mutations should only ever be one
	var/list/possible_mutations = list()
	///was this just layed as a mutation if so don't let it grow via incubators
	var/fresh_mutation = FALSE
	///is this egg fertile? used when picked up / dropped
	var/is_fertile = FALSE
	///the holder of our factions used so that we keep faction friends through generations
	var/list/faction_holder = list()
	///our stored_glass_egg_reagents from the parent
	var/list/glass_egg_reagents = list()

	var/low_temp
	var/high_temp
	var/low_pressure
	var/high_pressure
	var/liquid_depth
	var/list/turf_requirements
	var/nearby_mob

/obj/item/food/egg/process(seconds_per_tick)
	amount_grown += rand(2,3) * seconds_per_tick
	if(amount_grown >= 100)
		pre_hatch()

/obj/item/food/egg/pickup(mob/user)
	. = ..()
	STOP_PROCESSING(SSobj, src)

/obj/item/food/egg/dropped(mob/user, silent)
	. = ..()
	if(is_fertile)
		START_PROCESSING(SSobj, src)

/obj/item/food/egg/proc/pre_hatch()
	var/list/final_mutations = list()
	var/failed_mutations = FALSE
	for(var/datum/mutation/ranching/chicken/mutation in possible_mutations)
		if(mutation.cycle_requirements(src, TRUE))
			final_mutations |= mutation
		else
			desc = "Huh it seems like nothing is coming out of this one, maybe it needed something else?"
			failed_mutations = TRUE
			animate(src, transform = matrix()) //stop animation

	hatch(final_mutations, failed_mutations)

/obj/item/food/egg/proc/hatch(list/possible_mutations, failed_mutations)
	STOP_PROCESSING(SSobj, src)
	if(failed_mutations || !src.loc)
		return
	var/mob/living/basic/chick/birthed = new /mob/living/basic/chick(src.loc)

	if(possible_mutations.len)
		var/datum/mutation/ranching/chicken/chosen_mutation = pick(possible_mutations)
		birthed.grown_type = chosen_mutation.chicken_type
		if(chosen_mutation.nearby_items.len)
			absorbed_required_items(chosen_mutation.nearby_items)
	else
		birthed.grown_type = layer_hen_type //if no possible mutations default to layer hen type

	if(birthed.grown_type == /mob/living/basic/chicken/glass)
		for(var/list_item in src.reagents.reagent_list)
			birthed.glass_egg_reagent.Add(list_item)

	if(birthed.grown_type == /mob/living/basic/chicken/stone)
		birthed.production_type = src.production_type

	birthed.absorb_eggstat(src)
	birthed.assign_chick_icon(birthed.grown_type)
	visible_message("[src] hatches with a quiet cracking sound.")
	qdel(src)

/obj/item/food/egg/proc/absorbed_required_items(list/required_items)
	for(var/item in required_items)
		var/obj/item/removal_item = item
		var/obj/item/temp = locate(removal_item) in view(3, src.loc)
		if(temp)
			visible_message("[src] absorbs the nearby [temp.name] into itself.")
			qdel(temp)
