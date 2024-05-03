/obj/item/seeds/proc/return_all_data()
	var/obj/grown_food = product
	var/base64 = icon2base64(icon(initial(grown_food.icon), initial(grown_food.icon_state)))
	return list(
		"image" = base64,
		"name" = name,
		"desc" = desc,
		"potency" = potency,
		"weed_rate" = weed_rate,
		"weed_chance" = weed_chance,
		"yield" = yield,
		"ref" = REF(src),
		"production_speed" = production,
		"maturation_speed" = maturation,
		"endurance" = endurance,
		"lifespan" = lifespan,
	)

/obj/item/seeds/spliced
	name = "Spliced Seeds"
	desc = "A hybrid seed consisting of multiple plants."

	icon_state = "seed-x"

	///list of all produce types, when harvest will randomly cycle these
	var/list/produce_list = list()
	///list of all viable special mutations
	var/list/special_mutations = list()

/obj/item/seeds/spliced/on_planted()
	special_mutations = return_viable_mutations()

/obj/item/seeds/spliced/harvest(mob/user)
	var/atom/movable/parent = loc //for ease of access
	var/t_amount = 0
	var/list/result = list()
	var/output_loc = parent.Adjacent(user) ? user.loc : parent.loc //needed for TK
	var/product_name
	var/yield_amount = getYield()
	if(yield_amount >= 10)
		yield_amount = 10 + log(1.02) * (getYield() - 1)
	while(t_amount < yield_amount)
		var/picked_object = pick(produce_list)
		if(prob(10))
			var/obj/item/seeds/seed_prod
			if(prob(30) && special_mutations.len)
				var/datum/hydroponics/plant_mutation/spliced_mutation/picked_mutation =  pick(special_mutations)
				var/obj/item/seeds/created_seed = picked_mutation.created_seed
				seed_prod = new created_seed(output_loc)
			else
				seed_prod = src.Copy_drop(output_loc)
			result.Add(seed_prod) // User gets a consumable
			t_amount++
		else
			var/obj/item/food/grown/t_prod
			if(prob(10) && special_mutations.len)
				var/datum/hydroponics/plant_mutation/spliced_mutation/picked_mutation =  pick(special_mutations)
				var/obj/item/produced_item = picked_mutation.created_product
				t_prod = new produced_item(output_loc)
			else
				t_prod = new picked_object(output_loc, src)
			result.Add(t_prod) // User gets a consumable
			if(!t_prod)
				return
			t_amount++
			product_name = t_prod.seed.plantname
	if(getYield() >= 1)
		SSblackbox.record_feedback("tally", "food_harvested", getYield(), product_name)

	return result

/obj/item/seeds/proc/Copy_drop(output_loc)
	var/obj/item/seeds/S = new type(output_loc, 1)
	S.genes = list()
	for(var/g in genes)
		var/datum/plant_gene/G = g
		S.genes += G.Copy()

	for(var/datum/plant_gene/trait/traits in S.genes)
		traits.on_new_seed(S)
	// Copy all the stats
	S.set_lifespan(lifespan)
	S.set_endurance(endurance)
	S.set_maturation(maturation)
	S.set_production(production)
	S.set_yield(yield)
	S.set_potency(potency)
	S.set_weed_rate(weed_rate)
	S.set_weed_chance(weed_chance)
	S.name = name
	S.plantname = plantname
	S.desc = desc
	S.reagents_add = reagents_add.Copy() // Faster than grabbing the list from genes.

	S.harvest_age = harvest_age
	S.species = species
	S.icon_grow = icon_grow
	S.icon_harvest = icon_harvest
	S.icon_dead = icon_dead
	S.growthstages = growthstages
	S.growing_icon = growing_icon
	S.plant_icon_offset = plant_icon_offset
	S.traits_in_progress = traits_in_progress

	if(istype(src, /obj/item/seeds/spliced))
		var/obj/item/seeds/spliced/spliced_seed = src
		var/obj/item/seeds/spliced/new_spliced_seed = S
		new_spliced_seed.produce_list = spliced_seed.produce_list

/obj/item/seeds/proc/on_planted()
	return


/obj/item/seeds/proc/process_trait_gain(datum/plant_gene/trait/trait_to_check, increment)
	if(traits_in_progress[trait_to_check] == 100)
		return
	if(trait_to_check in traits_in_progress)
		var/old_value = traits_in_progress[trait_to_check]
		traits_in_progress[trait_to_check] = min(increment + old_value, 100)
	else
		traits_in_progress[trait_to_check] = min(increment, 100)

	if(traits_in_progress[trait_to_check] >= 100)
		var/datum/plant_gene/trait/created_trait = new trait_to_check
		if(!created_trait.can_add(src))
			qdel(created_trait)
			return
		genes += created_trait
		created_trait.process_stats(src)
		traits_in_progress[trait_to_check] = null

/datum/plant_gene/trait/proc/process_stats(obj/item/seeds/parent_seed)
	if(trait_flags & TRAIT_HALVES_YIELD)
		parent_seed.adjust_yield(parent_seed.yield * 0.5)
	if(trait_flags & TRAIT_HALVES_PRODUCTION)
		parent_seed.adjust_production(parent_seed.production * 0.5)
	if(trait_flags & TRAIT_HALVES_POTENCY)
		parent_seed.adjust_potency(parent_seed.potency * 0.5)
	if(trait_flags & TRAIT_HALVES_ENDURANCE)
		parent_seed.adjust_endurance(parent_seed.endurance * 0.5)
	if(trait_flags & TRAIT_HALVES_LIFESPAN)
		parent_seed.adjust_lifespan(parent_seed.lifespan * 0.5)
