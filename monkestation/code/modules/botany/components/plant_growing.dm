//this is the source of the old hydrotray behaviours
/datum/component/plant_growing
	///this is our managed seeds
	var/list/managed_seeds = list()
	///this is the amount of seeds we can have at once in a tray
	var/maximum_seeds = 1

	///are we bioboosted
	var/bio_boosted = FALSE

	///our current water precent
	var/water_precent = 100
	///how much water we can have at max used to determine %
	var/max_water = 200

	///how many processes we need to work

	var/work_processes = 10 SECONDS
	///what work time we are at
	var/next_work = 0
	///what stage are we one
	var/work_cycle = 0

	///how toxic our tray currently is % wise
	var/toxicity_contents = 0

	///the icon we apply to our parent if we are self sustaining
	var/self_sustaining_overlay
	///the current precentage we are to self sustaining
	var/self_sustaining_precent = 0
	///does self sustaining also increase plant stats slowly
	var/self_growing = FALSE

	var/pest_level = 0
	var/weed_level = 0

	var/pollinated = FALSE

/datum/component/plant_growing/Initialize(max_reagents = 40, maximum_seeds = 1)
	. = ..()

	var/atom/movable/movable_parent = parent
	src.maximum_seeds = maximum_seeds
	for(var/i = 1 to maximum_seeds)
		managed_seeds["[i]"] = null

	///we create reagents using max_reagents, then make it visible and an open container
	movable_parent.create_reagents(max_reagents, (OPENCONTAINER | AMOUNT_VISIBLE))

	RegisterSignals(parent, list(COMSIG_TRY_PLANT_SEED, COMSIG_ATOM_ATTACKBY), PROC_REF(try_plant_seed))
	RegisterSignal(parent, COMSIG_TRY_POLLINATE, PROC_REF(try_pollinate))
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND_SECONDARY, PROC_REF(try_drain))

	RegisterSignals(parent, list(COMSIG_TRY_HARVEST_SEEDS, COMSIG_ATOM_ATTACK_HAND), PROC_REF(try_harvest))
	RegisterSignals(movable_parent.reagents, list(COMSIG_REAGENTS_NEW_REAGENT, COMSIG_REAGENTS_ADD_REAGENT, COMSIG_REAGENTS_DEL_REAGENT, COMSIG_REAGENTS_REM_REAGENT), PROC_REF(on_reagent_change))
	RegisterSignals(movable_parent.reagents, list(COMSIG_REAGENT_CACHE_ADD_ATTEMPT), PROC_REF(on_reagent_cache_pre))

	RegisterSignal(parent, COMSIG_GROWING_ADJUST_TOXIN, PROC_REF(adjust_toxin))
	RegisterSignal(parent, COMSIG_GROWING_ADJUST_PEST, PROC_REF(adjust_pests))
	RegisterSignal(parent, COMSIG_GROWING_ADJUST_WEED, PROC_REF(adjust_weeds))
	RegisterSignal(parent, COMSIG_GROWER_ADJUST_SELFGROW, PROC_REF(adjust_selfgrow))
	RegisterSignal(parent, COMSIG_GROWER_INCREASE_WORK_PROCESSES, PROC_REF(increase_work_processes))
	RegisterSignal(parent, COMSIG_REMOVE_PLANT, PROC_REF(remove_plant))
	RegisterSignal(parent, COMSIG_GROWER_CHECK_POLLINATED, PROC_REF(check_pollinated))
	RegisterSignal(parent, COMSIG_ATTEMPT_BIOBOOST, PROC_REF(try_bioboost))
	RegisterSignal(parent, COMSIG_PLANTER_REMOVE_PLANTS, PROC_REF(remove_all_plants))
	RegisterSignal(parent, COMSIG_TOGGLE_BIOBOOST, PROC_REF(toggle_bioboost))
	RegisterSignal(movable_parent.reagents, COMSIG_REAGENT_PRE_TRANS_TO, PROC_REF(pre_trans))
	RegisterSignal(parent, COMSIG_GROWING_TRY_SECATEUR, PROC_REF(try_secateur))
	RegisterSignal(parent, COMSIG_GROWER_TRY_GRAFT, PROC_REF(try_graft))

	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

	START_PROCESSING(SSplants, src)
	SEND_SIGNAL(parent, COMSIG_GROWING_WATER_UPDATE, water_precent)

/datum/component/plant_growing/process(seconds_per_tick)
	if(!length(managed_seeds))
		return
	var/atom/movable/movable_parent = parent
	movable_parent.update_appearance()
	if((world.time < next_work) && !bio_boosted)
		return
	next_work = world.time + work_processes
	work_cycle++

	for(var/datum/reagent/reagent as anything in movable_parent.reagents.reagent_list)
		reagent.on_plant_grower_apply(parent)

	for(var/item as anything in managed_seeds)
		var/obj/item/seeds/seed = managed_seeds[item]
		if(!seed)
			continue

		if(seed.get_gene(/datum/plant_gene/trait/glow))
			var/datum/plant_gene/trait/glow/G = seed.get_gene(/datum/plant_gene/trait/glow)
			movable_parent.set_light(l_outer_range = G.glow_range(seed), l_power = G.glow_power(seed), l_color = G.glow_color)

		if(!bio_boosted)
			if(work_cycle >= 2)
				adjust_water(-rand(1, 6))
				if(water_precent <= 0 || weed_level >= 10)
					SEND_SIGNAL(seed, COMSIG_ADJUST_PLANT_HEALTH, -rand(0, 2))
					continue
				if(movable_parent.reagents.total_volume <= 5)
					SEND_SIGNAL(seed, COMSIG_ADJUST_PLANT_HEALTH, -rand(0, 2))

		if(pollinated)
			seed.adjust_potency(rand(1,2))
			seed.adjust_yield(rand(1,2))
			seed.adjust_endurance(rand(1,2))
			seed.adjust_lifespan(rand(1,2))

		if(water_precent >= 10)
			SEND_SIGNAL(seed, COMSIG_ADJUST_PLANT_HEALTH, rand(1, 2))
		SEND_SIGNAL(seed, COMSIG_PLANT_GROWTH_PROCESS, movable_parent.reagents, bio_boosted)
		if((self_sustaining_precent >= 100) || bio_boosted)
			continue

		if(work_cycle >= 2 && !bio_boosted)
			if(prob(seed.weed_chance))
				SEND_SIGNAL(seed, COMSIG_GROWING_ADJUST_WEED, seed.weed_rate)

	if(work_cycle >= 2)
		work_cycle = 0

	if(movable_parent.reagents.total_volume > 5)
		if(bio_boosted)
			movable_parent.reagents.remove_all(max(1,round(movable_parent.reagents.total_volume * 0.01, CHEMICAL_QUANTISATION_LEVEL)))
		else
			movable_parent.reagents.remove_all(max(1,round(movable_parent.reagents.total_volume * 0.025, CHEMICAL_QUANTISATION_LEVEL)))

	SEND_SIGNAL(movable_parent, COMSIG_NUTRIENT_UPDATE, movable_parent.reagents.total_volume / movable_parent.reagents.maximum_volume)


/datum/component/plant_growing/proc/try_plant_seed(datum/source, obj/item/seeds/seed, mob/living/user)
	SIGNAL_HANDLER
	if(istype(seed, /obj/item/storage/bag/plants))
		for(var/id as anything in managed_seeds)
			var/obj/item/seeds/harvest = managed_seeds[id]
			if(!harvest)
				continue
			SEND_SIGNAL(harvest, COMSIG_PLANT_TRY_HARVEST, user)

		for(var/obj/item/food/grown/G in locate(user.x,user.y,user.z))
			seed.atom_storage?.attempt_insert(G, user, TRUE)
		return COMPONENT_NO_AFTERATTACK

	var/atom/movable/movable_parent = parent
	if(!istype(seed))
		return FALSE

	var/slot_number = 0
	var/free_slot = FALSE
	for(var/item as anything in managed_seeds)
		slot_number++
		if(isnull(managed_seeds[item]))
			free_slot = TRUE
			break

	if(!free_slot)
		return FALSE

	managed_seeds["[slot_number]"] = seed
	seed.forceMove(parent)
	if(seed.GetComponent(/datum/component/growth_information))
		SEND_SIGNAL(seed, COMSIG_PLANT_BUILD_IMAGE)
		SEND_SIGNAL(seed, COMSIG_PLANT_CHANGE_PLANTER, parent, "[slot_number]")
		return COMPONENT_NO_AFTERATTACK

	seed.AddComponent(/datum/component/growth_information, parent, "[slot_number]")
	SEND_SIGNAL(seed, COMSIG_PLANT_BUILD_IMAGE)
	movable_parent.update_appearance()
	return COMPONENT_NO_AFTERATTACK

/datum/component/plant_growing/proc/try_harvest(datum/source, mob/living/user)
	if(!length(managed_seeds))
		return

	for(var/item as anything in managed_seeds)
		var/obj/item/seeds/seed = managed_seeds[item]
		if(!seed)
			continue
		SEND_SIGNAL(seed, COMSIG_PLANT_TRY_HARVEST, user)


/datum/component/plant_growing/proc/try_pollinate(datum/source)
	if(!length(managed_seeds))
		return

	pollinated = TRUE
	var/set_time =  rand(600, 900)
	for(var/item as anything in managed_seeds)
		var/obj/item/seeds/seed = managed_seeds[item]
		if(!seed)
			continue
		SEND_SIGNAL(seed, COMSIG_PLANT_TRY_POLLINATE, parent, set_time)

	addtimer(VARSET_CALLBACK(src, pollinated, FALSE), set_time)

///here we just remove any water added and increase the water precent, add other things you want done once.
/datum/component/plant_growing/proc/on_reagent_cache_pre(datum/reagents/holder, datum/reagent/reagent, datum/reagents/coming_from, amount)
	///restocks water
	var/atom/movable/movable_parent = parent
	if(reagent.type == /datum/reagent/water)
		var/water_pre_precent = max_water / 100
		var/water_needed = round(water_pre_precent * (100 - water_precent))
		var/water_volume = min(reagent.volume, amount)


		var/water_transfer = min(water_volume, water_needed)
		adjust_water(water_transfer)
		var/image/splash_animation = image('icons/effects/effects.dmi', movable_parent, "splash_hydroponics")
		splash_animation.color = mix_color_from_reagents(coming_from.reagent_list)
		splash_animation.layer += 5
		flick_overlay_global(splash_animation, GLOB.clients, 1.1 SECONDS)
		playsound(movable_parent, 'sound/effects/slosh.ogg', 25, TRUE)
		coming_from.remove_reagent(/datum/reagent/water, water_transfer)
		return TRUE

/datum/component/plant_growing/proc/pre_trans(datum/reagents/main, datum/reagents/incoming)
	var/atom/movable/movable_parent = parent
	var/image/splash_animation = image('icons/effects/effects.dmi', movable_parent, "splash_hydroponics")
	splash_animation.color = mix_color_from_reagents(incoming.reagent_list)
	splash_animation.layer += 5
	flick_overlay_global(splash_animation, GLOB.clients, 1.1 SECONDS)
	playsound(movable_parent, 'sound/effects/slosh.ogg', 25, TRUE)

/datum/component/plant_growing/proc/on_reagent_change(datum/reagents/holder, ...)
	SEND_SIGNAL(parent, COMSIG_NUTRIENT_UPDATE, holder.total_volume / holder.maximum_volume)

/datum/component/plant_growing/proc/adjust_water(amount)
	var/water_precent_filled = (amount / max_water) * 100
	water_precent = clamp(water_precent + water_precent_filled, 0, 100)
	SEND_SIGNAL(parent, COMSIG_GROWING_WATER_UPDATE, water_precent)

/datum/component/plant_growing/proc/adjust_toxin(datum/source, amount)
	toxicity_contents = max(0, toxicity_contents + amount)
	SEND_SIGNAL(parent, COMSIG_TOXICITY_UPDATE, toxicity_contents)

/datum/component/plant_growing/proc/adjust_pests(datum/source, amount)
	pest_level = clamp(pest_level + amount, 0, 10)
	SEND_SIGNAL(parent, COMSIG_PEST_UPDATE, pest_level)

/datum/component/plant_growing/proc/adjust_weeds(datum/source, amount)
	weed_level = clamp(weed_level + amount, 0, 10)
	SEND_SIGNAL(parent, COMSIG_WEEDS_UPDATE, weed_level)
	return TRUE

/datum/component/plant_growing/proc/adjust_selfgrow(datum/source, amount)
	self_sustaining_precent = clamp(self_sustaining_precent + amount, 0, 10)

/datum/component/plant_growing/proc/increase_work_processes(datum/source, amount)
	next_work -= amount

/datum/component/plant_growing/proc/on_examine(atom/A, mob/user, list/examine_list)
	SIGNAL_HANDLER
	var/atom/movable/movable_parent = parent

	examine_list += span_info("Water: [water_precent]%")
	examine_list += span_info("Nutrients: [movable_parent.reagents.total_volume] units")

	if(bio_boosted)
		examine_list += span_boldnotice("It's currently being bio boosted, plants will grow incredibly quickly.")

	if(self_sustaining_precent >= 100)
		examine_list += span_info("The tray's self-sustenance is active, protecting it from species mutations, weeds, and pests.")
	if(self_growing)
		examine_list += span_info("The tray's self sustaining growth dampeners are off.")
	if(weed_level >= 5)
		examine_list += span_warning("It's filled with weeds!")
	if(pest_level >= 5)
		examine_list += span_warning("It's filled with tiny worms!")

/datum/component/plant_growing/proc/remove_plant(datum/source, id)
	var/obj/item/seeds/seed = managed_seeds[id]
	managed_seeds[id] = null
	qdel(seed)
	SEND_SIGNAL(parent, REMOVE_PLANT_VISUALS, id)

/datum/component/plant_growing/proc/check_pollinated(datum/source)
	return pollinated

/datum/component/plant_growing/proc/try_bioboost(datum/source, duration)
	if(bio_boosted)
		return FALSE
	bio_boosted = TRUE
	addtimer(VARSET_CALLBACK(src, bio_boosted, FALSE), duration)
	return TRUE

/datum/component/plant_growing/proc/remove_all_plants(datum/source)
	for(var/item as anything in managed_seeds)
		var/obj/item/seeds/seed = managed_seeds[item]
		managed_seeds[item] = null
		qdel(seed)
		SEND_SIGNAL(parent, REMOVE_PLANT_VISUALS, item)

/datum/component/plant_growing/proc/toggle_bioboost(datum/source)
	bio_boosted = !bio_boosted

/datum/component/plant_growing/proc/try_secateur(datum/source, mob/user)
	for(var/item as anything in managed_seeds)
		var/obj/item/seeds/seed = managed_seeds[item]
		if(!seed)
			continue
		SEND_SIGNAL(seed, COMSIG_PLANT_TRY_SECATEUR, user)
	return TRUE

/datum/component/plant_growing/proc/try_graft(datum/source, mob/user, obj/item/graft/snip)
	for(var/item as anything in managed_seeds)
		var/obj/item/seeds/seed = managed_seeds[item]
		if(!seed)
			continue
		if(seed.apply_graft(snip))
			to_chat(user, span_notice("You carefully integrate the grafted plant limb onto [seed.plantname], granting it [snip.stored_trait.get_name()]."))
		else
			to_chat(user, span_notice("You integrate the grafted plant limb onto [seed.plantname], but it does not accept the [snip.stored_trait.get_name()] trait from the [snip]."))
		qdel(snip)
		return TRUE

/datum/component/plant_growing/proc/try_drain(datum/source, mob/user)
	INVOKE_ASYNC(src, PROC_REF(start_drain), user)

/datum/component/plant_growing/proc/start_drain(mob/user)
	var/atom/movable/movable = parent
	if(movable.reagents.total_volume)
		to_chat(user, span_notice("You begin to dump out the tray's nutrient mix."))
		if(do_after(user, 4 SECONDS, target = movable))
			playsound(user.loc, 'sound/effects/slosh.ogg', 50, TRUE, -1)
			//dump everything on the floor
			var/turf/user_loc = user.loc
			if(istype(user_loc, /turf/open))
				user_loc.add_liquid_from_reagents(movable.reagents)
			else
				user_loc = get_step_towards(user_loc, movable)
				user_loc.add_liquid_from_reagents(movable.reagents)
			movable.reagents.remove_all(movable.reagents.total_volume)
	else
		to_chat(user, span_warning("The tray's nutrient mix is already empty!"))

