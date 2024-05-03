/obj/machinery/splicer
	name = "Splicer"
	desc = "Splices two seeds together."

	icon_state = "splicer"
	icon = 'monkestation/icons/obj/machines/hydroponics.dmi'
	var/obj/item/seeds/seed_1
	var/obj/item/seeds/seed_2
	var/obj/item/reagent_containers/cup/beaker/held_beaker

	var/working = FALSE

	var/work_timer = null

	var/potential_damage = 0

	var/list/stats = list()


/obj/machinery/splicer/attacked_by(obj/item/I, mob/living/user)
	. = ..()
	if(istype(I, /obj/item/seeds))
		if(!seed_1)
			if(!user.transferItemToLoc(I, src))
				return
			seed_1 = I

		else if(!seed_2)
			if(!user.transferItemToLoc(I, src))
				return
			seed_2 = I
	if(istype(I, /obj/item/reagent_containers/cup/beaker))
		if(!held_beaker)
			if(!user.transferItemToLoc(I, src))
				return
			held_beaker = I
			return

/obj/machinery/splicer/ui_data(mob/user)
	. = ..()
	if(!stats.len)
		calculate_stats_for_infusion()

	var/has_seed_one = FALSE
	var/has_seed_two = FALSE
	var/has_beaker = FALSE
	var/list/data = list()

	if(seed_1)
		data["seed_1"] = list(seed_1.return_all_data() + stats)
		has_seed_one = TRUE
		data["damage_taken"] = seed_1.infusion_damage
		data["potential_damage"] = potential_damage
		data["combined_damage"] = (potential_damage + seed_1.infusion_damage)
	if(seed_2)
		data["seed_2"] = list(seed_2.return_all_data())
		has_seed_two = TRUE
	if(held_beaker)
		data["held_beaker"] = held_beaker.reagents
		has_beaker = TRUE


	data["seedone"] = has_seed_one
	data["seedtwo"] = has_seed_two
	data["held_beaker"] = has_beaker

	data["working"] = working

	data["timeleft"] = work_timer ? timeleft(work_timer) : null

	return data

/obj/machinery/splicer/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BotanySplicer", name)
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/splicer/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("eject_seed_one")
			eject_seed(seed_1)
			seed_1 = null
			return TRUE
		if("eject_seed_two")
			eject_seed(seed_2)
			seed_2 = null
			return TRUE
		if("eject_beaker")
			eject_beaker(held_beaker)
			return TRUE
		if("splice")
			splice(seed_1, seed_2)
			return TRUE
		if("infuse")
			infuse()
			return TRUE

/obj/machinery/splicer/proc/eject_seed(obj/item/seeds/ejected_seed)
	if (ejected_seed)
		if(Adjacent(usr) && !issiliconoradminghost(usr))
			if (!usr.put_in_hands(ejected_seed))
				ejected_seed.forceMove(drop_location())
		else
			ejected_seed.forceMove(drop_location())
		. = TRUE

/obj/machinery/splicer/proc/eject_beaker()
	if (held_beaker)
		if(Adjacent(usr) && !issiliconoradminghost(usr))
			if (!usr.put_in_hands(held_beaker))
				held_beaker.forceMove(drop_location())
		else
			held_beaker.forceMove(drop_location())
		held_beaker = null
		stats = list()
		potential_damage = 0
		. = TRUE

/obj/machinery/splicer/proc/splice(obj/item/seeds/first_seed, obj/item/seeds/second_seed)

	if(!first_seed || !second_seed)
		return

	var/obj/item/seeds/spliced/new_seed = new
	new_seed.set_potency((first_seed.potency + second_seed.potency) * 0.5)
	new_seed.set_yield((first_seed.yield + second_seed.yield) * 0.5)
	new_seed.set_production((first_seed.production + second_seed.production) * 0.5)
	new_seed.maturation = ((first_seed.maturation + second_seed.maturation) * 0.5)
	new_seed.set_lifespan((first_seed.lifespan + second_seed.lifespan) * 0.5)
	new_seed.set_endurance((first_seed.endurance + second_seed.endurance) * 0.5)
	new_seed.set_weed_chance((first_seed.weed_chance + second_seed.weed_chance) * 0.5)
	new_seed.set_weed_rate((first_seed.weed_rate + second_seed.weed_rate) * 0.5)
	new_seed.set_maturation((first_seed.maturation + second_seed.maturation) * 0.5)
	new_seed.species = first_seed.species
	new_seed.icon_grow = first_seed.icon_grow
	new_seed.icon_harvest = first_seed.icon_harvest
	new_seed.icon_dead = first_seed.icon_dead
	new_seed.growthstages = first_seed.growthstages
	new_seed.growing_icon = first_seed.growing_icon
	new_seed.plant_icon_offset = first_seed.plant_icon_offset

	new_seed.reagents_add = first_seed.reagents_add.Copy()

	for(var/datum/reagent/reag as anything in second_seed.reagents_add)
		if(reag in new_seed.reagents_add)
			if(first_seed.plantname != second_seed.plantname)
				new_seed.reagents_add[reag] += second_seed.reagents_add[reag]
		else
			new_seed.reagents_add += reag
			new_seed.reagents_add[reag] = second_seed.reagents_add[reag]

	if(!istype(first_seed, /obj/item/seeds/spliced))
		var/obj/first_produced = first_seed.product
		new_seed.produce_list += first_produced
	else
		var/obj/item/seeds/spliced/spliced_seed = first_seed
		new_seed.produce_list |= spliced_seed.produce_list

	if(!istype(second_seed, /obj/item/seeds/spliced))
		var/obj/second_produced = second_seed.product
		new_seed.produce_list += second_produced
	else
		var/obj/item/seeds/spliced/spliced_seed = second_seed
		new_seed.produce_list |= spliced_seed.produce_list

	var/part1 = copytext(copytext(first_seed.plantname, 1, round(length(first_seed.plantname) * 0.70 + 2)), 1, 50)
	var/part2 = copytext(copytext(second_seed.plantname, round(length(second_seed.plantname) * 0.40 + 1), 0), -50)

	new_seed.name = "pack of [part1][part2] seeds"
	new_seed.plantname = "[part1][part2]"

	for(var/datum/plant_gene/trait/traits in first_seed.genes)
		if(istype(traits, /datum/plant_gene/trait))
			var/datum/plant_gene/trait/new_trait = new traits.type
			if(new_trait.can_add(new_seed))
				new_seed.genes += new_trait
			else
				qdel(new_trait)


	for(var/reag_id in new_seed.reagents_add)
		new_seed.genes += new /datum/plant_gene/reagent(reag_id, new_seed.reagents_add[reag_id])

	if(Adjacent(usr) && !issiliconoradminghost(usr))
		if (!usr.put_in_hands(new_seed))
			new_seed.forceMove(drop_location())
	else
		new_seed.forceMove(drop_location())

	seed_1 = null
	seed_2 = null

	qdel(first_seed)
	qdel(second_seed)

/obj/machinery/splicer/proc/calculate_stats_for_infusion()
	if(!held_beaker)
		return
	var/list/total_stats = list(
		"potency_change" = 0,
		"yield_change" = 0,
		"endurance_change" = 0,
		"lifespan_change" = 0,
		"weed_chance_change" = 0,
		"weed_rate_change" = 0,
		"production_change" = 0,
		"maturation_change" = 0,
		"damage" = 0,
	)
	for(var/reagent in held_beaker.reagents.reagent_list)
		var/datum/reagent/listed_reagent = reagent
		total_stats += listed_reagent.generate_infusion_values(held_beaker.reagents)
	stats = total_stats
	potential_damage = stats["damage"]

/obj/machinery/splicer/proc/infuse()
	if(!held_beaker)
		return
	seed_1.infusion_damage += potential_damage
	if(seed_1.infusion_damage >= 100)
		qdel(seed_1)
		seed_1 = null
		return

	seed_1.adjust_potency(stats["potency_change"])
	seed_1.adjust_yield(stats["yield_change"])
	seed_1.adjust_endurance(stats["endurance_change"])
	seed_1.adjust_lifespan(stats["lifespan_change"])
	seed_1.adjust_production(stats["production_change"])
	seed_1.adjust_weed_chance(stats["weed_chance_change"])
	seed_1.adjust_weed_rate(stats["weed_rate_change"])
	seed_1.adjust_maturation(stats["maturation_change"])

	seed_1.check_infusions(held_beaker.reagents.reagent_list)
	held_beaker.reagents.remove_any(held_beaker.reagents.total_volume)
	stats = list()
	potential_damage = 0
