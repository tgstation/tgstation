/obj/machinery/infuser
	name = "Infuser"
	desc = "Infuses chemicals into seeds, potentially opening access to new mutations."

	icon_state = "splicer"
	icon = 'monkestation/icons/obj/machines/hydroponics.dmi'
	var/obj/item/seeds/seed

	var/obj/item/reagent_containers/cup/beaker/held_beaker

	var/working = FALSE

	var/work_timer = null

	var/potential_damage = 0

	var/list/stats = list()


/obj/machinery/infuser/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BotanyInfuser", name)
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/infuser/ui_data(mob/user)
	. = ..()
	if(!stats.len)
		calculate_stats_for_infusion()
	var/list/data = list()
	if(seed)
		data["seed"] = list(seed.return_all_data() + stats)
		data["has_seed"] = TRUE
	if(held_beaker)
		data["has_beaker"] = TRUE

	data["working"] = working

	data["potential_damage"] = potential_damage
	data["damage_taken"] = seed.infusion_damage
	data["combined_damage"] = (potential_damage + seed.infusion_damage)

	return data

/obj/machinery/infuser/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("eject_beaker")
			eject_beaker()
			return TRUE
		if("eject_seed")
			eject_seed()
			return TRUE
		if("infuse")
			infuse()
			return TRUE

/obj/machinery/infuser/proc/calculate_stats_for_infusion()
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

/obj/machinery/infuser/proc/eject_seed()
	if (seed)
		if(Adjacent(usr) && !issiliconoradminghost(usr))
			if (!usr.put_in_hands(seed))
				seed.forceMove(drop_location())
		else
			seed.forceMove(drop_location())
		seed = null
		. = TRUE

/obj/machinery/infuser/proc/eject_beaker()
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

/obj/machinery/infuser/attacked_by(obj/item/I, mob/living/user)
	. = ..()
	if(istype(I, /obj/item/seeds))
		if(!seed)
			if(!user.transferItemToLoc(I, src))
				return
			seed = I
			return
	if(istype(I, /obj/item/reagent_containers/cup/beaker))
		if(!held_beaker)
			if(!user.transferItemToLoc(I, src))
				return
			held_beaker = I
			return

/obj/machinery/infuser/proc/infuse()
	if(!held_beaker)
		return
	seed.infusion_damage += potential_damage
	if(seed.infusion_damage >= 100)
		qdel(seed)
		seed = null
		return

	seed.adjust_potency(stats["potency_change"])
	seed.adjust_yield(stats["yield_change"])
	seed.adjust_endurance(stats["endurance_change"])
	seed.adjust_lifespan(stats["lifespan_change"])
	seed.adjust_production(stats["production_change"])
	seed.adjust_weed_chance(stats["weed_chance_change"])
	seed.adjust_weed_rate(stats["weed_rate_change"])
	seed.adjust_maturation(stats["maturation_change"])

	seed.check_infusions(held_beaker.reagents.reagent_list)
	held_beaker.reagents.remove_any(held_beaker.reagents.total_volume)
	stats = list()
	potential_damage = 0
