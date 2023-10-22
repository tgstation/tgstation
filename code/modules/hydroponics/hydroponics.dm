
/obj/machinery/hydroponics
	name = "hydroponics tray"
	desc = "A basin used to grow plants in."
	icon = 'icons/obj/service/hydroponics/equipment.dmi'
	icon_state = "hydrotray"
	density = TRUE
	pass_flags_self = PASSMACHINE | LETPASSTHROW
	pixel_z = 8
	obj_flags = CAN_BE_HIT | UNIQUE_RENAME
	circuit = /obj/item/circuitboard/machine/hydroponics
	use_power = NO_POWER_USE
	///The amount of water in the tray (max 100)
	var/waterlevel = 0
	///The maximum amount of water in the tray
	var/maxwater = 100
	///How many units of nutrients will be drained in the tray.
	var/nutridrain = 1
	///The maximum nutrient reagent container size of the tray.
	var/maxnutri = 20
	///The amount of pests in the tray (max 10)
	var/pestlevel = 0
	///The amount of weeds in the tray (max 10)
	var/weedlevel = 0
	///Nutriment's effect on yield
	var/yieldmod = 1
	///Nutriment's effect on mutations
	var/mutmod = 1
	///Toxicity in the tray?
	var/toxic = 0
	///Current age
	var/age = 0
	///The status of the plant in the tray. Whether it's harvestable, alive, missing or dead.
	var/plant_status = HYDROTRAY_NO_PLANT
	///Its health
	var/plant_health
	///Last time it was harvested
	var/lastproduce = 0
	///Used for timing of cycles.
	var/lastcycle = 0
	///About 10 seconds / cycle
	var/cycledelay = HYDROTRAY_CYCLE_DELAY
	///The currently planted seed
	var/obj/item/seeds/myseed
	///Obtained from the quality of the parts used in the tray, determines nutrient drain rate.
	var/rating = 1
	///Can it be unwrenched to move?
	var/unwrenchable = TRUE
	///Have we been visited by a bee recently, so bees dont overpollinate one plant
	var/recent_bee_visit = FALSE
	///The last user to add a reagent to the tray, mostly for logging purposes.
	var/datum/weakref/lastuser
	///If the tray generates nutrients and water on its own
	var/self_sustaining = FALSE
	///The icon state for the overlay used to represent that this tray is self-sustaining.
	var/self_sustaining_overlay_icon_state = "gaia_blessing"

/obj/machinery/hydroponics/Initialize(mapload)
	//ALRIGHT YOU DEGENERATES. YOU HAD REAGENT HOLDERS FOR AT LEAST 4 YEARS AND NONE OF YOU MADE HYDROPONICS TRAYS HOLD NUTRIENT CHEMS INSTEAD OF USING "Points".
	//SO HERE LIES THE "nutrilevel" VAR. IT'S DEAD AND I PUT IT OUT OF IT'S MISERY. USE "reagents" INSTEAD. ~ArcaneMusic, accept no substitutes.
	create_reagents(maxnutri, INJECTABLE)
	if(mapload)
		reagents.add_reagent(/datum/reagent/plantnutriment/eznutriment, 10) //Half filled nutrient trays for dirt trays to have more to grow with in prison/lavaland.
		waterlevel = 100
	. = ..()

	var/static/list/hovering_item_typechecks = list(
		/obj/item/plant_analyzer = list(
			SCREENTIP_CONTEXT_LMB = "Scan tray stats",
			SCREENTIP_CONTEXT_RMB = "Scan tray chemicals"
		),
		/obj/item/cultivator = list(
			SCREENTIP_CONTEXT_LMB = "Remove weeds",
		),
		/obj/item/shovel = list(
			SCREENTIP_CONTEXT_LMB = "Clear tray",
		),
	)

	AddElement(/datum/element/contextual_screentip_item_typechecks, hovering_item_typechecks)
	register_context()

/obj/machinery/hydroponics/add_context(
	atom/source,
	list/context,
	obj/item/held_item,
	mob/living/user,
)

	// If we don't have a seed, we can't do much.

	// The only option is to plant a new seed.
	if(!myseed)
		if(istype(held_item, /obj/item/seeds))
			context[SCREENTIP_CONTEXT_LMB] = "Plant seed"
			return CONTEXTUAL_SCREENTIP_SET
		return NONE

	// If we DO have a seed, we can do a few things!

	// With a hand we can harvest or remove dead plants
	// If the plant's not in either state, we can't do much else, so early return.
	if(isnull(held_item))
		// Silicons can't interact with trays :frown:
		if(issilicon(user))
			return NONE

		switch(plant_status)
			if(HYDROTRAY_PLANT_DEAD)
				context[SCREENTIP_CONTEXT_LMB] = "Remove dead plant"
				return CONTEXTUAL_SCREENTIP_SET

			if(HYDROTRAY_PLANT_HARVESTABLE)
				context[SCREENTIP_CONTEXT_LMB] = "Harvest plant"
				return CONTEXTUAL_SCREENTIP_SET

		return NONE

	// If the plant is harvestable, we can graft it with secateurs or harvest it with a plant bag.
	if(plant_status == HYDROTRAY_PLANT_HARVESTABLE)
		if(istype(held_item, /obj/item/secateurs))
			context[SCREENTIP_CONTEXT_LMB] = "Graft plant"
			return CONTEXTUAL_SCREENTIP_SET

		if(istype(held_item, /obj/item/storage/bag/plants))
			context[SCREENTIP_CONTEXT_LMB] = "Harvest plant"
			return CONTEXTUAL_SCREENTIP_SET

	// If the plant's in good health, we can shear it.
	if(istype(held_item, /obj/item/geneshears) && plant_health > GENE_SHEAR_MIN_HEALTH)
		context[SCREENTIP_CONTEXT_LMB] = "Remove plant gene"
		return CONTEXTUAL_SCREENTIP_SET

	// If we've got a charged somatoray, we can mutation lock it.
	if(istype(held_item, /obj/item/gun/energy/floragun) && myseed.endurance > FLORA_GUN_MIN_ENDURANCE && LAZYLEN(myseed.mutatelist))
		var/obj/item/gun/energy/floragun/flower_gun = held_item
		if(flower_gun.cell.charge >= flower_gun.cell.maxcharge)
			context[SCREENTIP_CONTEXT_LMB] = "Lock mutation"
			return CONTEXTUAL_SCREENTIP_SET

	// Edibles and pills can be composted.
	if(IS_EDIBLE(held_item) || istype(held_item, /obj/item/reagent_containers/pill))
		context[SCREENTIP_CONTEXT_LMB] = "Compost"
		return CONTEXTUAL_SCREENTIP_SET

	// And if a reagent container has water or plant fertilizer in it, we can use it on the plant.
	if(is_reagent_container(held_item) && length(held_item.reagents.reagent_list))
		var/datum/reagent/most_common_reagent = held_item.reagents.get_master_reagent()
		context[SCREENTIP_CONTEXT_LMB] = "[istype(most_common_reagent, /datum/reagent/water) ? "Water" : "Feed"] plant"
		return CONTEXTUAL_SCREENTIP_SET

	return NONE

/obj/machinery/hydroponics/constructable
	name = "hydroponics tray"
	icon = 'icons/obj/service/hydroponics/equipment.dmi'
	icon_state = "hydrotray3"

/obj/machinery/hydroponics/constructable/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/simple_rotation)
	AddComponent(/datum/component/plumbing/hydroponics)
	AddComponent(/datum/component/usb_port, list(/obj/item/circuit_component/hydroponics))

/obj/machinery/hydroponics/constructable/RefreshParts()
	. = ..()
	var/tmp_capacity = 0
	for (var/datum/stock_part/matter_bin/matter_bin in component_parts)
		tmp_capacity += matter_bin.tier
	for (var/datum/stock_part/servo/servo in component_parts)
		rating = servo.tier
	maxwater = tmp_capacity * 50 // Up to 300
	maxnutri = (tmp_capacity * 5) + STATIC_NUTRIENT_CAPACITY // Up to 50 Maximum
	reagents.maximum_volume = maxnutri
	nutridrain = 1/rating

/obj/machinery/hydroponics/constructable/examine(mob/user)
	. = ..()
	. += span_notice("Use <b>Ctrl-Click</b> to activate autogrow. <b>RMB</b> to empty the tray's nutrients.")
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads: Tray efficiency at <b>[rating*100]%</b>.")

/obj/machinery/hydroponics/constructable/add_context(
	atom/source,
	list/context,
	obj/item/held_item,
	mob/living/user,
)

	// Constructible trays will always show that you can activate auto-grow with ctrl+click
	. = ..()
	context[SCREENTIP_CONTEXT_CTRL_LMB] = "Activate auto-grow"
	return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/hydroponics/Destroy()
	if(myseed)
		QDEL_NULL(myseed)
	return ..()

/obj/machinery/hydroponics/Exited(atom/movable/gone)
	. = ..()
	if(!QDELETED(src) && gone == myseed)
		set_seed(null, FALSE)

/obj/machinery/hydroponics/constructable/attackby(obj/item/I, mob/living/user, params)
	if (!user.combat_mode)
		// handle opening the panel
		if(default_deconstruction_screwdriver(user, icon_state, icon_state, I))
			return
		if(default_deconstruction_crowbar(I))
			return

	return ..()

/// Special demand connector that consumes as normal, but redirects water into the magical water space.
/datum/component/plumbing/hydroponics
	demand_connects = SOUTH
	/// Alternate reagents container to buffer incoming water
	var/datum/reagents/water_reagents
	/// Actual parent reagents that has nutrients
	var/datum/reagents/nutri_reagents

/datum/component/plumbing/hydroponics/Initialize(start=TRUE, _ducting_layer, _turn_connects=TRUE, datum/reagents/custom_receiver)
	. = ..()

	if(!istype(parent, /obj/machinery/hydroponics/constructable))
		return COMPONENT_INCOMPATIBLE

	var/obj/machinery/hydroponics/constructable/hydro_parent = parent

	water_reagents = new(hydro_parent.maxwater)
	water_reagents.my_atom = hydro_parent

	nutri_reagents = reagents

/datum/component/plumbing/hydroponics/Destroy()
	qdel(water_reagents)
	nutri_reagents = null
	return ..()

/datum/component/plumbing/hydroponics/send_request(dir)
	var/obj/machinery/hydroponics/constructable/hydro_parent = parent

	var/initial_nutri_amount = nutri_reagents.total_volume
	if(initial_nutri_amount < nutri_reagents.maximum_volume)
		// Well boy howdy, we have no way to tell a supply to not mix the water with everything else,
		// So we'll let it leak in, and move the water over.
		set_recipient_reagents_holder(nutri_reagents)
		reagents = nutri_reagents
		process_request(dir = dir)

		// Move the leaked water from nutrients to... water
		var/leaking_water_amount = nutri_reagents.get_reagent_amount(/datum/reagent/water)
		if(leaking_water_amount)
			nutri_reagents.trans_id_to(water_reagents, /datum/reagent/water, leaking_water_amount)

	// We should only take MACHINE_REAGENT_TRANSFER every tick; this is the remaining amount we can take
	var/remaining_transfer_amount = max(MACHINE_REAGENT_TRANSFER - (nutri_reagents.total_volume - initial_nutri_amount), 0)

	// How much extra water we should gather this tick to try to fill the water tray.
	var/extra_water_to_gather = clamp(hydro_parent.maxwater - hydro_parent.waterlevel - water_reagents.total_volume, 0, remaining_transfer_amount)
	if(extra_water_to_gather > 0)
		set_recipient_reagents_holder(water_reagents)
		reagents = water_reagents
		process_request(
			amount = extra_water_to_gather,
			reagent = /datum/reagent/water,
			dir = dir,
		)

	// Now transfer all remaining water in that buffer and clear it out.
	var/final_water_amount = water_reagents.total_volume
	if(final_water_amount)
		hydro_parent.adjust_waterlevel(round(final_water_amount))
		// Using a pipe doesn't afford you extra water storage and the baseline behavior for trays is that excess water goes into the shadow realm.
		water_reagents.del_reagent(/datum/reagent/water)

	// Plumbing pauses if reagents is full.. so let's cheat and make sure it ticks unless both trays are happy
	reagents = hydro_parent.waterlevel < hydro_parent.maxwater ? water_reagents : nutri_reagents

/obj/machinery/hydroponics/bullet_act(obj/projectile/Proj) //Works with the Somatoray to modify plant variables.
	if(!myseed)
		return ..()
	if(istype(Proj , /obj/projectile/energy/flora/mut))
		mutate()
	else if(istype(Proj , /obj/projectile/energy/flora/yield))
		return myseed.bullet_act(Proj)
	else if(istype(Proj , /obj/projectile/energy/flora/evolution))
		if(myseed)
			if(LAZYLEN(myseed.mutatelist))
				myseed.set_instability(myseed.instability/2)
		mutatespecie()
	else
		return ..()

/obj/machinery/hydroponics/power_change()
	. = ..()
	if((machine_stat & NOPOWER) && self_sustaining)
		set_self_sustaining(FALSE)

/obj/machinery/hydroponics/process(seconds_per_tick)
	var/needs_update = FALSE // Checks if the icon needs updating so we don't redraw empty trays every time

	if(self_sustaining)
		if(powered())
			adjust_waterlevel(rand(1,2) * seconds_per_tick * 0.5)
			adjust_weedlevel(-0.5 * seconds_per_tick)
			adjust_pestlevel(-0.5 * seconds_per_tick)
		else
			set_self_sustaining(FALSE)
			visible_message(span_warning("[name]'s auto-grow functionality shuts off!"))

	if(world.time > (lastcycle + cycledelay))
		lastcycle = world.time
		if(myseed && plant_status != HYDROTRAY_PLANT_DEAD)
			// Advance age
			age++
			if(age < myseed.maturation)
				lastproduce = age

			needs_update = TRUE


//Nutrients//////////////////////////////////////////////////////////////
			// Nutrients deplete at a constant rate, since new nutrients can boost stats far easier.
			apply_chemicals(lastuser?.resolve())
			if(self_sustaining)
				reagents.remove_any(min(0.5, nutridrain))
			else
				reagents.remove_any(nutridrain)

			// Lack of nutrients hurts non-weeds
			if(reagents.total_volume <= 0 && !myseed.get_gene(/datum/plant_gene/trait/plant_type/weed_hardy))
				adjust_plant_health(-rand(1,3))

//Photosynthesis/////////////////////////////////////////////////////////
			// Lack of light hurts non-mushrooms
			if(isturf(loc))
				var/turf/currentTurf = loc
				var/lightAmt = currentTurf.get_lumcount()
				var/is_fungus = myseed.get_gene(/datum/plant_gene/trait/plant_type/fungal_metabolism)
				if(lightAmt < (is_fungus ? 0.2 : 0.4))
					adjust_plant_health((is_fungus ? -1 : -2) / rating)

//Water//////////////////////////////////////////////////////////////////
			// Drink random amount of water
			adjust_waterlevel(-rand(1,6) / rating)

			// If the plant is dry, it loses health pretty fast, unless mushroom
			if(waterlevel <= 10 && !myseed.get_gene(/datum/plant_gene/trait/plant_type/fungal_metabolism))
				adjust_plant_health(-rand(0,1) / rating)
				if(waterlevel <= 0)
					adjust_plant_health(-rand(0,2) / rating)

			// Sufficient water level and nutrient level = plant healthy but also spawns weeds
			else if(waterlevel > 10 && reagents.total_volume > 0)
				adjust_plant_health(rand(1,2) / rating)
				if(myseed && prob(myseed.weed_chance))
					adjust_weedlevel(myseed.weed_rate)
				else if(prob(5))  //5 percent chance the weed population will increase
					adjust_weedlevel(1 / rating)

//Toxins/////////////////////////////////////////////////////////////////

			// Too much toxins cause harm, but when the plant drinks the contaiminated water, the toxins disappear slowly
			if(toxic >= 40 && toxic < 80)
				adjust_plant_health(-1 / rating)
				adjust_toxic(-rating * 2)
			else if(toxic >= 80) // I don't think it ever gets here tbh unless above is commented out
				adjust_plant_health(-3)
				adjust_toxic(-rating * 3)

//Pests & Weeds//////////////////////////////////////////////////////////

			if(pestlevel >= 8)
				if(!myseed.get_gene(/datum/plant_gene/trait/carnivory))
					if(myseed.potency >= 30)
						myseed.adjust_potency(-rand(2,6)) //Pests eat leaves and nibble on fruit, lowering potency.
						myseed.set_potency(min((myseed.potency), CARNIVORY_POTENCY_MIN, MAX_PLANT_POTENCY))
				else
					adjust_plant_health(2 / rating)
					adjust_pestlevel(-1 / rating)

			else if(pestlevel >= 4)
				if(!myseed.get_gene(/datum/plant_gene/trait/carnivory))
					if(myseed.potency >= 30)
						myseed.adjust_potency(-rand(1,4))
						myseed.set_potency(min((myseed.potency), CARNIVORY_POTENCY_MIN, MAX_PLANT_POTENCY))

				else
					adjust_plant_health(1 / rating)
					if(prob(50))
						adjust_pestlevel(-1 / rating)

			else if(pestlevel < 4 && myseed.get_gene(/datum/plant_gene/trait/carnivory))
				if(prob(5))
					adjust_pestlevel(-1 / rating)

			// If it's a weed, it doesn't stunt the growth
			if(weedlevel >= 5 && !myseed.get_gene(/datum/plant_gene/trait/plant_type/weed_hardy))
				if(myseed.yield >= 3)
					myseed.adjust_yield(-rand(1,2)) //Weeds choke out the plant's ability to bear more fruit.
					myseed.set_yield(min((myseed.yield), WEED_HARDY_YIELD_MIN, MAX_PLANT_YIELD))

//This is the part with pollination
			pollinate()

//This is where stability mutations exist now.
			if(myseed.instability >= 80)
				var/mutation_chance = myseed.instability - 75
				mutate(0, 0, 0, 0, 0, 0, 0, mutation_chance, 0) //Scaling odds of a random trait or chemical
			if(myseed.instability >= 60)
				if(prob((myseed.instability)/2) && !self_sustaining && LAZYLEN(myseed.mutatelist) && !myseed.get_gene(/datum/plant_gene/trait/never_mutate)) //Minimum 30%, Maximum 50% chance of mutating every age tick when not on autogrow or having Prosophobic Inclination trait.
					mutatespecie()
					myseed.set_instability(myseed.instability/2)
			if(myseed.instability >= 40)
				if(prob(myseed.instability) && !myseed.get_gene(/datum/plant_gene/trait/stable_stats)) //No hardmutation if Symbiotic Resilience trait is present.
					hardmutate()
			if(myseed.instability >= 20 )
				if(prob(myseed.instability) && !myseed.get_gene(/datum/plant_gene/trait/stable_stats)) //No mutation if Symbiotic Resilience trait is present.
					mutate()

//Health & Age///////////////////////////////////////////////////////////

			// Plant dies if plant_health <= 0
			if(plant_health <= 0)
				plantdies()
				adjust_weedlevel(1 / rating) // Weeds flourish

			// If the plant is too old, lose health fast
			if(age > myseed.lifespan)
				adjust_plant_health(-rand(1,5) / rating)

			// Harvest code
			if(age > myseed.production && (age - lastproduce) > myseed.production && plant_status == HYDROTRAY_PLANT_GROWING)
				if(myseed && myseed.yield != -1) // Unharvestable shouldn't be harvested
					set_plant_status(HYDROTRAY_PLANT_HARVESTABLE)
				else
					lastproduce = age
			if(prob(5))  // On each tick, there's a 5 percent chance the pest population will increase
				adjust_pestlevel(1 / rating)
		else
			if(waterlevel > 10 && reagents.total_volume > 0 && prob(10))  // If there's no plant, the percentage chance is 10%
				adjust_weedlevel(1 / rating)

		// Weeeeeeeeeeeeeeedddssss
		if(weedlevel >= 10 && prob(50) && !self_sustaining) // At this point the plant is kind of fucked. Weeds can overtake the plant spot.
			if(myseed && myseed.yield >= 3)
				myseed.adjust_yield(-rand(1,2)) //Loses even more yield per tick, quickly dropping to 3 minimum.
				myseed.set_yield(min((myseed.yield), WEED_HARDY_YIELD_MIN, MAX_PLANT_YIELD))
			if(!myseed)
				weedinvasion()
			needs_update = 1
		if (needs_update)
			update_appearance()

		if(myseed)
			SEND_SIGNAL(myseed, COMSIG_SEED_ON_GROW, src)

	return

/obj/machinery/hydroponics/update_appearance(updates)
	. = ..()
	if(self_sustaining)
		set_light(3)
		return
	if(myseed?.get_gene(/datum/plant_gene/trait/glow)) // Hydroponics needs a refactor, badly.
		var/datum/plant_gene/trait/glow/G = myseed.get_gene(/datum/plant_gene/trait/glow)
		set_light(G.glow_range(myseed), G.glow_power(myseed), G.glow_color)
		return
	set_light(0)

/obj/machinery/hydroponics/update_name(updates)
	. = ..()
	if(myseed)
		name = "[initial(name)] ([myseed.plantname])"
	else
		name = initial(name)

/obj/machinery/hydroponics/update_overlays()
	. = ..()
	if(myseed)
		. += update_plant_overlay()
		. += update_status_light_overlays()

	if(self_sustaining && self_sustaining_overlay_icon_state)
		. += mutable_appearance(icon, self_sustaining_overlay_icon_state)

/obj/machinery/hydroponics/proc/update_plant_overlay()
	var/mutable_appearance/plant_overlay = mutable_appearance(myseed.growing_icon, layer = OBJ_LAYER + 0.01)
	switch(plant_status)
		if(HYDROTRAY_PLANT_DEAD)
			plant_overlay.icon_state = myseed.icon_dead
		if(HYDROTRAY_PLANT_HARVESTABLE)
			if(!myseed.icon_harvest)
				plant_overlay.icon_state = "[myseed.icon_grow][myseed.growthstages]"
			else
				plant_overlay.icon_state = myseed.icon_harvest
		else
			var/t_growthstate = clamp(round((age / myseed.maturation) * myseed.growthstages), 1, myseed.growthstages)
			plant_overlay.icon_state = "[myseed.icon_grow][t_growthstate]"
	plant_overlay.pixel_y = myseed.plant_icon_offset
	return plant_overlay

/obj/machinery/hydroponics/proc/update_status_light_overlays()
	. = list()
	if(waterlevel <= 10)
		. += mutable_appearance('icons/obj/service/hydroponics/equipment.dmi', "over_lowwater3")
	if(reagents.total_volume <= 2)
		. += mutable_appearance('icons/obj/service/hydroponics/equipment.dmi', "over_lownutri3")
	if(plant_health <= (myseed.endurance / 2))
		. += mutable_appearance('icons/obj/service/hydroponics/equipment.dmi', "over_lowhealth3")
	if(weedlevel >= 5 || pestlevel >= 5 || toxic >= 40)
		. += mutable_appearance('icons/obj/service/hydroponics/equipment.dmi', "over_alert3")
	if(plant_status == HYDROTRAY_PLANT_HARVESTABLE)
		. += mutable_appearance('icons/obj/service/hydroponics/equipment.dmi', "over_harvest3")

///Sets a new value for the myseed variable, which is the seed of the plant that's growing inside the tray.
/obj/machinery/hydroponics/proc/set_seed(obj/item/seeds/new_seed, delete_old_seed = TRUE)
	var/old_seed = myseed
	myseed = new_seed
	if(old_seed && delete_old_seed)
		qdel(old_seed)
	set_plant_status(new_seed ? HYDROTRAY_PLANT_GROWING : HYDROTRAY_NO_PLANT) //To make sure they can't just put in another seed and insta-harvest it
	if(myseed && myseed.loc != src)
		myseed.forceMove(src)
	SEND_SIGNAL(src, COMSIG_HYDROTRAY_SET_SEED, new_seed)
	update_appearance()
	if(isnull(myseed))
		particles = null

/*
 * Setter proc to set a tray to a new self_sustaining state and update all values associated with it.
 *
 * new_value - true / false value that self_sustaining is being set to
 */
/obj/machinery/hydroponics/proc/set_self_sustaining(new_value)
	if(self_sustaining == new_value)
		return

	self_sustaining = new_value

	update_use_power(self_sustaining ? ACTIVE_POWER_USE : NO_POWER_USE)
	update_appearance()

	SEND_SIGNAL(src, COMSIG_HYDROTRAY_SET_SELFSUSTAINING, new_value)

/obj/machinery/hydroponics/proc/set_weedlevel(new_weedlevel, update_icon = TRUE)
	if(weedlevel == new_weedlevel)
		return
	SEND_SIGNAL(src, COMSIG_HYDROTRAY_SET_WEEDLEVEL, new_weedlevel)
	weedlevel = new_weedlevel
	if(update_icon)
		update_appearance()

/obj/machinery/hydroponics/proc/set_pestlevel(new_pestlevel, update_icon = TRUE)
	if(pestlevel == new_pestlevel)
		return
	SEND_SIGNAL(src, COMSIG_HYDROTRAY_SET_PESTLEVEL, new_pestlevel)
	pestlevel = new_pestlevel
	if(update_icon)
		update_appearance()

/obj/machinery/hydroponics/proc/set_waterlevel(new_waterlevel, update_icon = TRUE)
	if(waterlevel == new_waterlevel)
		return
	SEND_SIGNAL(src, COMSIG_HYDROTRAY_SET_WATERLEVEL, new_waterlevel)
	waterlevel = new_waterlevel
	if(update_icon)
		update_appearance()

	var/difference = new_waterlevel - waterlevel
	if(difference > 0)
		adjust_toxic(-round(difference/4))//Toxicity dilutation code. The more water you put in, the lesser the toxin concentration.

/obj/machinery/hydroponics/proc/set_plant_health(new_plant_health, update_icon = TRUE, forced = FALSE)
	if(plant_health == new_plant_health || ((!myseed || plant_status == HYDROTRAY_PLANT_DEAD) && !forced))
		return
	SEND_SIGNAL(src, COMSIG_HYDROTRAY_SET_PLANT_HEALTH, new_plant_health)
	plant_health = new_plant_health
	if(update_icon)
		update_appearance()

/obj/machinery/hydroponics/proc/set_toxic(new_toxic, update_icon = TRUE)
	if(toxic == new_toxic)
		return
	SEND_SIGNAL(src, COMSIG_HYDROTRAY_SET_TOXIC, new_toxic)
	toxic = new_toxic
	if(update_icon)
		update_appearance()

/obj/machinery/hydroponics/proc/set_plant_status(new_plant_status)
	if(plant_status == new_plant_status)
		return
	SEND_SIGNAL(src, COMSIG_HYDROTRAY_SET_PLANT_STATUS, new_plant_status)
	plant_status = new_plant_status

// The following procs adjust the hydroponics tray variables, and make sure that the stat doesn't go out of bounds.

/**
 * Adjust water.
 * Raises or lowers tray water values by a set value. Adding water will dillute toxicity from the tray.
 * Returns the amount of water actually added/taken
 * * adjustamt - determines how much water the tray will be adjusted upwards or downwards.
 */
/obj/machinery/hydroponics/proc/adjust_waterlevel(amt)
	var/initial_waterlevel = waterlevel
	set_waterlevel(clamp(waterlevel+amt, 0, maxwater), FALSE)
	return waterlevel-initial_waterlevel

/**
 * Adjust Health.
 * Raises the tray's plant_health stat by a given amount, with total health determined by the seed's endurance.
 * * adjustamt - Determines how much the plant_health will be adjusted upwards or downwards.
 */
/obj/machinery/hydroponics/proc/adjust_plant_health(amt)
	set_plant_health(clamp(plant_health + amt, 0, myseed?.endurance), FALSE)

/**
 * Adjust toxicity.
 * Raises the plant's toxic stat by a given amount.
 * * adjustamt - Determines how much the toxic will be adjusted upwards or downwards.
 */
/obj/machinery/hydroponics/proc/adjust_toxic(amt)
	set_toxic(clamp(toxic + amt, 0, MAX_TRAY_TOXINS), FALSE)

/**
 * Adjust Pests.
 * Raises the tray's pest level stat by a given amount.
 * * adjustamt - Determines how much the pest level will be adjusted upwards or downwards.
 */
/obj/machinery/hydroponics/proc/adjust_pestlevel(amt)
	set_pestlevel(clamp(pestlevel + amt, 0, MAX_TRAY_PESTS), FALSE)


/**
 * Adjust Weeds.
 * Raises the plant's weed level stat by a given amount.
 * * adjustamt - Determines how much the weed level will be adjusted upwards or downwards.
 */
/obj/machinery/hydroponics/proc/adjust_weedlevel (amt)
	set_weedlevel(clamp(weedlevel + amt, 0, MAX_TRAY_WEEDS), FALSE)

/obj/machinery/hydroponics/examine(user)
	. = ..()
	if(myseed)
		. += span_info("It has [span_name("[myseed.plantname]")] planted.")
		if (plant_status == HYDROTRAY_PLANT_DEAD)
			. += span_warning("It's dead!")
		else if (plant_status == HYDROTRAY_PLANT_HARVESTABLE)
			. += span_info("It's ready to harvest.")
		else if (plant_health <= (myseed.endurance / 2))
			. += span_warning("It looks unhealthy.")
	else
		. += span_info("It's empty.")

	. += span_info("Water: [waterlevel]/[maxwater].")
	. += span_info("Nutrient: [reagents.total_volume]/[maxnutri].")
	if(self_sustaining)
		. += span_info("The tray's autogrow is active, protecting it from species mutations, weeds, and pests.")

	if(weedlevel >= 5)
		. += span_warning("It's filled with weeds!")
	if(pestlevel >= 5)
		. += span_warning("It's filled with tiny worms!")

/**
 * What happens when a tray's weeds grow too large.
 * Plants a new weed in an empty tray, then resets the tray.
 */
/obj/machinery/hydroponics/proc/weedinvasion()
	var/oldPlantName
	if(myseed) // In case there's nothing in the tray beforehand
		oldPlantName = myseed.plantname
	else
		oldPlantName = "empty tray"
	var/obj/item/seeds/new_seed
	switch(rand(1,18)) // randomly pick predominative weed
		if(16 to 18)
			new_seed = new /obj/item/seeds/reishi(src)
		if(14 to 15)
			new_seed = new /obj/item/seeds/nettle(src)
		if(12 to 13)
			new_seed = new /obj/item/seeds/harebell(src)
		if(10 to 11)
			new_seed = new /obj/item/seeds/amanita(src)
		if(8 to 9)
			new_seed = new /obj/item/seeds/chanter(src)
		if(6 to 7)
			new_seed = new /obj/item/seeds/tower(src)
		if(4 to 5)
			new_seed = new /obj/item/seeds/plump(src)
		else
			new_seed = new /obj/item/seeds/starthistle(src)
	set_seed(new_seed)
	age = 0
	lastcycle = world.time
	set_plant_health(myseed.endurance, update_icon = FALSE)
	set_weedlevel(0, update_icon = FALSE) // Reset
	set_pestlevel(0) // Reset
	visible_message(span_warning("The [oldPlantName] is overtaken by some [myseed.plantname]!"))

/obj/machinery/hydroponics/proc/mutate(lifemut = 2, endmut = 5, productmut = 1, yieldmut = 2, potmut = 25, wrmut = 2, wcmut = 5, traitmut = 0, stabmut = 3) // Mutates the current seed
	if(!myseed)
		return
	myseed.mutate(lifemut, endmut, productmut, yieldmut, potmut, wrmut, wcmut, traitmut, stabmut)

/obj/machinery/hydroponics/proc/hardmutate(lifemut = 4, endmut = 10, productmut = 2, yieldmut = 4, potmut = 50, wrmut = 4, wcmut = 10, traitmut = 0, stabmut = 4)
	mutate(lifemut, endmut, productmut, yieldmut, potmut, wrmut, wcmut, traitmut, stabmut)

/obj/machinery/hydroponics/proc/mutatespecie() // Mutagent produced a new plant!
	if(!myseed || plant_status == HYDROTRAY_PLANT_DEAD || !LAZYLEN(myseed.mutatelist))
		return

	var/oldPlantName = myseed.plantname
	var/mutantseed = pick(myseed.mutatelist)
	set_seed(new mutantseed(src))

	hardmutate()
	age = 0
	set_plant_health(myseed.endurance, update_icon = FALSE)
	lastcycle = world.time
	set_weedlevel(0, update_icon = FALSE)

	var/message = span_warning("[oldPlantName] suddenly mutates into [myseed.plantname]!")
	addtimer(CALLBACK(src, PROC_REF(after_mutation), message), 0.5 SECONDS)

/obj/machinery/hydroponics/proc/polymorph() // Polymorph a plant into another plant
	if(!myseed || plant_status == HYDROTRAY_PLANT_DEAD)
		return

	var/oldPlantName = myseed.plantname
	var/polymorph_seed = pick(subtypesof(/obj/item/seeds))
	set_seed(new polymorph_seed(src))

	hardmutate()
	age = 0
	set_plant_health(myseed.endurance, update_icon = FALSE)
	lastcycle = world.time
	set_weedlevel(0, update_icon = FALSE)

	var/message = span_warning("[oldPlantName] suddenly polymorphs into [myseed.plantname]!")
	addtimer(CALLBACK(src, PROC_REF(after_mutation), message), 0.5 SECONDS)

/obj/machinery/hydroponics/proc/mutateweed() // If the weeds gets the mutagent instead. Mind you, this pretty much destroys the old plant
	if( weedlevel > 5 )
		set_seed(null)
		var/newWeed = pick(/obj/item/seeds/liberty, /obj/item/seeds/angel, /obj/item/seeds/nettle/death, /obj/item/seeds/kudzu)
		set_seed(new newWeed(src))
		hardmutate()
		age = 0
		set_plant_health(myseed.endurance, update_icon = FALSE)
		lastcycle = world.time
		set_weedlevel(0, update_icon = FALSE) // Reset

		var/message = span_warning("The mutated weeds in [src] spawn some [myseed.plantname]!")
		addtimer(CALLBACK(src, PROC_REF(after_mutation), message), 0.5 SECONDS)
	else
		to_chat(usr, span_warning("The few weeds in [src] seem to react, but only for a moment..."))
/**
 * Called after plant mutation, update the appearance of the tray content and send a visible_message()
 */
/obj/machinery/hydroponics/proc/after_mutation(message)
	visible_message(message)
	update_appearance()

/**
 * Plant Death Proc.
 * Cleans up various stats for the plant upon death, including pests, harvestability, and plant health.
 */
/obj/machinery/hydroponics/proc/plantdies()
	set_plant_health(0, update_icon = FALSE, forced = TRUE)
	set_plant_status(HYDROTRAY_PLANT_DEAD)
	set_pestlevel(0, update_icon = FALSE) // Pests die
	lastproduce = 0
	update_appearance()
	SEND_SIGNAL(src, COMSIG_HYDROTRAY_PLANT_DEATH)

/**
 * Plant Cross-Pollination.
 * Checks all plants in the tray's oview range, then averages out the seed's potency, instability, and yield values.
 * If the seed's instability is >= 20, the seed donates one of it's reagents to that nearby plant.
 * * Range - The Oview range of trays to which to look for plants to donate reagents.
 */
/obj/machinery/hydroponics/proc/pollinate(range = 1)
	var/any_adjacent = FALSE
	for(var/obj/machinery/hydroponics/T in oview(src, range))
		//Here is where we check for window blocking.
		if(!Adjacent(T) && range <= 1)
			continue
		if(T.myseed && T.plant_status != HYDROTRAY_PLANT_DEAD)
			T.myseed.set_potency(round((T.myseed.potency+(1/10)*(myseed.potency-T.myseed.potency))))
			T.myseed.set_instability(round((T.myseed.instability+(1/10)*(myseed.instability-T.myseed.instability))))
			T.myseed.set_yield(round((T.myseed.yield+(1/2)*(myseed.yield-T.myseed.yield))))
			any_adjacent = TRUE
			if(isnull(particles))
				particles = new /particles/pollen()
			if(myseed.instability >= 20 && prob(70) && length(T.myseed.reagents_add))
				var/list/datum/plant_gene/reagent/possible_reagents = list()
				for(var/datum/plant_gene/reagent/reag in T.myseed.genes)
					possible_reagents += reag
				var/datum/plant_gene/reagent/reagent_gene = pick(possible_reagents) //Let this serve as a lession to delete your WIP comments before merge.
				if(reagent_gene.can_add(myseed))
					if(!reagent_gene.try_upgrade_gene(myseed))
						myseed.genes += reagent_gene.Copy()
					myseed.reagents_from_genes()
					continue
	if(!any_adjacent)
		particles = null

/**
 * Bee pollinate proc.
 * Checks if the bee can pollinate the plant
 */
/obj/machinery/hydroponics/proc/can_bee_pollinate()
	if(isnull(myseed))
		return FALSE
	if(plant_status == HYDROTRAY_PLANT_DEAD || recent_bee_visit)
		return FALSE
	return TRUE

/**
 * Pest Mutation Proc.
 * When a tray is mutated with high pest values, it will spawn spiders.
 * * User - Person who last added chemicals to the tray for logging purposes.
 */
/obj/machinery/hydroponics/proc/mutatepest(mob/user)
	if(pestlevel > 5)
		message_admins("[ADMIN_LOOKUPFLW(user)] last altered a hydro tray's contents which spawned spiderlings.")
		user.log_message("last altered a hydro tray, which spiderlings spawned from.", LOG_GAME)
		visible_message(span_warning("The pests seem to behave oddly..."))
		spawn_atom_to_turf(/mob/living/basic/spider/growing/spiderling/hunter, src, 3, FALSE)
	else if(myseed)
		visible_message(span_warning("The pests seem to behave oddly in [myseed.name] tray, but quickly settle down..."))

/obj/machinery/hydroponics/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/hydroponics/attackby(obj/item/O, mob/user, params)
	//Called when mob user "attacks" it with object O
	if(IS_EDIBLE(O) || is_reagent_container(O))  // Syringe stuff (and other reagent containers now too)
		var/obj/item/reagent_containers/reagent_source = O

		if(!reagent_source.reagents.total_volume)
			to_chat(user, span_warning("[reagent_source] is empty!"))
			return 1

		if(reagents.total_volume >= reagents.maximum_volume && !reagent_source.reagents.has_reagent(/datum/reagent/water, 1))
			to_chat(user, span_notice("[src] is full."))
			return

		var/list/trays = list(src)//makes the list just this in cases of syringes and compost etc
		var/target = myseed ? myseed.plantname : src
		var/visi_msg = ""
		var/transfer_amount

		if(IS_EDIBLE(reagent_source) || istype(reagent_source, /obj/item/reagent_containers/pill))
			visi_msg="[user] composts [reagent_source], spreading it through [target]"
			transfer_amount = reagent_source.reagents.total_volume
			SEND_SIGNAL(reagent_source, COMSIG_ITEM_ON_COMPOSTED, user)
		else
			transfer_amount = min(reagent_source.amount_per_transfer_from_this, reagent_source.reagents.total_volume)
			if(istype(reagent_source, /obj/item/reagent_containers/syringe/))
				var/obj/item/reagent_containers/syringe/syr = reagent_source
				visi_msg="[user] injects [target] with [syr]"
			// Beakers, bottles, buckets, etc.
			if(reagent_source.is_drainable())
				playsound(loc, 'sound/effects/slosh.ogg', 25, TRUE)
				var/mutable_appearance/splash_animation = mutable_appearance('icons/effects/effects.dmi', "splash_hydroponics")
				splash_animation.color = mix_color_from_reagents(reagent_source.reagents.reagent_list)
				flick_overlay_view(splash_animation, 1.1 SECONDS)

		if(visi_msg)
			visible_message(span_notice("[visi_msg]."))

		for(var/obj/machinery/hydroponics/H in trays)
		//cause I don't want to feel like im juggling 15 tamagotchis and I can get to my real work of ripping flooring apart in hopes of validating my life choices of becoming a space-gardener
			//This was originally in apply_chemicals, but due to apply_chemicals only holding nutrients, we handle it here now.
			if(reagent_source.reagents.has_reagent(/datum/reagent/water))
				var/water_amt = reagent_source.reagents.get_reagent_amount(/datum/reagent/water) * transfer_amount / reagent_source.reagents.total_volume
				var/water_amt_adjusted = H.adjust_waterlevel(round(water_amt))
				reagent_source.reagents.remove_reagent(/datum/reagent/water, water_amt_adjusted)
				for(var/datum/reagent/not_water_reagent as anything in reagent_source.reagents.reagent_list)
					if(istype(not_water_reagent,/datum/reagent/water))
						continue
					var/transfer_me_to_tray = reagent_source.reagents.get_reagent_amount(not_water_reagent.type) * transfer_amount / reagent_source.reagents.total_volume
					reagent_source.reagents.trans_id_to(H.reagents, not_water_reagent.type, transfer_me_to_tray)
			else
				reagent_source.reagents.trans_to(H.reagents, transfer_amount, transferred_by = user)
			lastuser = WEAKREF(user)
			if(IS_EDIBLE(reagent_source) || istype(reagent_source, /obj/item/reagent_containers/pill))
				qdel(reagent_source)
				H.update_appearance()
				return 1
			H.update_appearance()
		if(reagent_source) // If the source wasn't composted and destroyed
			reagent_source.update_appearance()
		return 1

	else if(istype(O, /obj/item/seeds) && !istype(O, /obj/item/seeds/sample))
		if(!myseed)
			if(istype(O, /obj/item/seeds/kudzu))
				investigate_log("had Kudzu planted in it by [key_name(user)] at [AREACOORD(src)].", INVESTIGATE_BOTANY)
			if(!user.transferItemToLoc(O, src))
				return
			SEND_SIGNAL(O, COMSIG_SEED_ON_PLANTED, src)
			to_chat(user, span_notice("You plant [O]."))
			set_seed(O)
			age = 1
			set_plant_health(myseed.endurance)
			lastcycle = world.time
			return
		else
			to_chat(user, span_warning("[src] already has seeds in it!"))
			return

	else if(istype(O, /obj/item/cultivator))
		if(weedlevel > 0)
			user.visible_message(span_notice("[user] uproots the weeds."), span_notice("You remove the weeds from [src]."))
			set_weedlevel(0)
			return
		else
			to_chat(user, span_warning("This plot is completely devoid of weeds! It doesn't need uprooting."))
			return

	else if(istype(O, /obj/item/secateurs))
		if(!myseed)
			to_chat(user, span_notice("This plot is empty."))
			return
		else if(plant_status != HYDROTRAY_PLANT_HARVESTABLE)
			to_chat(user, span_notice("This plant must be harvestable in order to be grafted."))
			return
		else if(myseed.grafted)
			to_chat(user, span_notice("This plant has already been grafted."))
			return
		else
			user.visible_message(span_notice("[user] grafts off a limb from [src]."), span_notice("You carefully graft off a portion of [src]."))
			var/obj/item/graft/snip = myseed.create_graft()
			if(!snip)
				return // The plant did not return a graft.

			snip.forceMove(drop_location())
			myseed.grafted = TRUE
			adjust_plant_health(-5)
			return

	else if(istype(O, /obj/item/geneshears))
		if(!myseed)
			to_chat(user, span_notice("The tray is empty."))
			return
		if(plant_health <= GENE_SHEAR_MIN_HEALTH)
			to_chat(user, span_notice("This plant looks too unhealty to be sheared right now."))
			return

		var/list/current_traits = list()
		for(var/datum/plant_gene/gene in myseed.genes)
			if(islist(gene))
				continue
			if(!(gene.mutability_flags & PLANT_GENE_REMOVABLE))
				continue // Don't show genes that can't be removed.
			current_traits[gene.name] = gene
		var/removed_trait = tgui_input_list(user, "Trait to remove from the [myseed.plantname]", "Plant Trait Removal", sort_list(current_traits))
		if(isnull(removed_trait))
			return
		if(!user.can_perform_action(src))
			return
		if(!myseed)
			return
		if(plant_health <= GENE_SHEAR_MIN_HEALTH) //Check health again to make sure they're not keeping inputs open to get free shears.
			return
		for(var/datum/plant_gene/gene in myseed.genes)
			if(gene.name == removed_trait)
				if(myseed.genes.Remove(gene))
					gene.on_removed(myseed)
					qdel(gene)
					break
		myseed.reagents_from_genes()
		adjust_plant_health(-15)
		to_chat(user, span_notice("You carefully shear the genes off of the [myseed.plantname], leaving the plant looking weaker."))
		update_appearance()
		return

	else if(istype(O, /obj/item/graft))
		var/obj/item/graft/snip = O
		if(!myseed)
			to_chat(user, span_notice("The tray is empty."))
			return
		if(myseed.apply_graft(snip))
			to_chat(user, span_notice("You carefully integrate the grafted plant limb onto [myseed.plantname], granting it [snip.stored_trait.get_name()]."))
		else
			to_chat(user, span_notice("You integrate the grafted plant limb onto [myseed.plantname], but it does not accept the [snip.stored_trait.get_name()] trait from the [snip]."))
		qdel(snip)
		return

	else if(istype(O, /obj/item/storage/bag/plants))
		if(plant_status == HYDROTRAY_PLANT_HARVESTABLE)
			var/list/harvest = myseed.harvest(user)
			for(var/obj/item/food/grown/G in harvest)
				O.atom_storage?.attempt_insert(G, user, TRUE)
		else if(plant_status == HYDROTRAY_PLANT_DEAD)
			to_chat(user, span_notice("You remove the dead plant from [src]."))
			set_seed(null)
		return

	else if(O.tool_behaviour == TOOL_SHOVEL)
		if(!myseed && !weedlevel)
			to_chat(user, span_warning("[src] doesn't have any plants or weeds!"))
			return
		user.visible_message(span_notice("[user] starts digging out [src]'s plants..."),
			span_notice("You start digging out [src]'s plants..."))
		if(O.use_tool(src, user, 50, volume=50) || (!myseed && !weedlevel))
			user.visible_message(span_notice("[user] digs out the plants in [src]!"), span_notice("You dig out all of [src]'s plants!"))
			if(myseed) //Could be that they're just using it as a de-weeder
				age = 0
				set_plant_health(0, update_icon = FALSE, forced = TRUE)
				lastproduce = 0
				set_seed(null)
			set_weedlevel(0) //Has a side effect of cleaning up those nasty weeds
			return
	else if(istype(O, /obj/item/storage/part_replacer))
		RefreshParts()
		return
	else if(istype(O, /obj/item/gun/energy/floragun))
		var/obj/item/gun/energy/floragun/flowergun = O
		if(flowergun.cell.charge < flowergun.cell.maxcharge)
			to_chat(user, span_notice("[flowergun] must be fully charged to lock in a mutation!"))
			return
		if(!myseed)
			to_chat(user, span_warning("[src] is empty!"))
			return
		if(myseed.endurance <= FLORA_GUN_MIN_ENDURANCE)
			to_chat(user, span_warning("[myseed.plantname] isn't hardy enough to sequence it's mutation!"))
			return
		if(!LAZYLEN(myseed.mutatelist))
			to_chat(user, span_warning("[myseed.plantname] has nothing else to mutate into!"))
			return
		else
			var/list/fresh_mut_list = list()
			for(var/muties in myseed.mutatelist)
				var/obj/item/seeds/another_mut = new muties
				fresh_mut_list[another_mut.plantname] = muties
			var/locked_mutation = tgui_input_list(user, "Mutation to lock", "Plant Mutation Locks", sort_list(fresh_mut_list))
			if(isnull(locked_mutation))
				return
			if(isnull(fresh_mut_list[locked_mutation]))
				return
			if(!user.can_perform_action(src))
				return
			myseed.mutatelist = list(fresh_mut_list[locked_mutation])
			myseed.set_endurance(myseed.endurance/2)
			flowergun.cell.use(flowergun.cell.charge)
			flowergun.update_appearance()
			to_chat(user, span_notice("[myseed.plantname]'s mutation was set to [locked_mutation], depleting [flowergun]'s cell!"))
			return
	else
		return ..()

/obj/machinery/hydroponics/attackby_secondary(obj/item/weapon, mob/user, params)
	if (istype(weapon, /obj/item/reagent_containers/syringe))
		to_chat(user, span_warning("You can't get any extract out of this plant."))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	return SECONDARY_ATTACK_CALL_NORMAL

/obj/machinery/hydroponics/can_be_unfasten_wrench(mob/user, silent)
	if (!unwrenchable)  // case also covered by NODECONSTRUCT checks in default_unfasten_wrench
		return CANT_UNFASTEN

	return ..()

/obj/machinery/hydroponics/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(issilicon(user)) //How does AI know what plant is?
		return
	if(plant_status == HYDROTRAY_PLANT_HARVESTABLE)
		return myseed.harvest(user)

	else if(plant_status == HYDROTRAY_PLANT_DEAD)
		to_chat(user, span_notice("You remove the dead plant from [src]."))
		set_seed(null)
	else
		if(user)
			user.examinate(src)

/obj/machinery/hydroponics/CtrlClick(mob/user)
	. = ..()
	if(!user.can_perform_action(src, FORBID_TELEKINESIS_REACH))
		return
	if(!powered())
		to_chat(user, span_warning("[name] has no power."))
		update_use_power(NO_POWER_USE)
		return
	if(!anchored)
		return
	set_self_sustaining(!self_sustaining)
	to_chat(user, span_notice("You [self_sustaining ? "activate" : "deactivated"] [src]'s autogrow function[self_sustaining ? ", maintaining the tray's health while using high amounts of power" : ""]."))

/obj/machinery/hydroponics/AltClick(mob/user)
	return ..() // This hotkey is BLACKLISTED since it's used by /datum/component/simple_rotation

/obj/machinery/hydroponics/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(!anchored)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	var/warning = tgui_alert(user, "Are you sure you wish to empty the tray's nutrient beaker?","Empty Tray Nutrients?", list("Yes", "No"))
	if(warning == "Yes" && user.can_perform_action(src, FORBID_TELEKINESIS_REACH))
		reagents.clear_reagents()
		to_chat(user, span_warning("You empty [src]'s nutrient tank."))
	update_appearance()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/**
 * Update Tray Proc
 * Handles plant harvesting on the tray side, by clearing the seed, names, description, and dead stat.
 * Shuts off autogrow if enabled.
 * Sends messages to the cleaer about plants harvested, or if nothing was harvested at all.
 * * User - The mob who clears the tray.
 */
/obj/machinery/hydroponics/proc/update_tray(mob/user, product_count)
	lastproduce = age
	if(istype(myseed, /obj/item/seeds/replicapod))
		to_chat(user, span_notice("You harvest from the [myseed.plantname]."))
	else if(product_count <= 0)
		to_chat(user, span_warning("You fail to harvest anything useful!"))
	else
		to_chat(user, span_notice("You harvest [product_count] items from the [myseed.plantname]."))
	if(!myseed.get_gene(/datum/plant_gene/trait/repeated_harvest))
		set_seed(null)
		if(self_sustaining) //No reason to pay for an empty tray.
			set_self_sustaining(FALSE)
	else
		set_plant_status(HYDROTRAY_PLANT_GROWING)
	update_appearance()
	SEND_SIGNAL(src, COMSIG_HYDROTRAY_ON_HARVEST, user, product_count)

/**
 * Spawn Plant.
 * Upon using strange reagent on a tray, it will spawn a killer tomato or killer tree at random.
 */
/obj/machinery/hydroponics/proc/spawnplant() // why would you put strange reagent in a hydro tray you monster I bet you also feed them blood
	var/list/livingplants = list(/mob/living/basic/tree, /mob/living/basic/killer_tomato)
	var/chosen = pick(livingplants)
	var/mob/living/C = new chosen(get_turf(src))
	C.faction = list(FACTION_PLANTS)

///////////////////////////////////////////////////////////////////////////////
/obj/machinery/hydroponics/soil //Not actually hydroponics at all! Honk!
	name = "soil"
	desc = "A patch of dirt."
	icon = 'icons/obj/service/hydroponics/equipment.dmi'
	icon_state = "soil"
	gender = PLURAL
	circuit = null
	density = FALSE
	use_power = NO_POWER_USE
	flags_1 = NODECONSTRUCT_1
	unwrenchable = FALSE
	self_sustaining_overlay_icon_state = null
	maxnutri = 15

/obj/machinery/hydroponics/soil/update_icon(updates=ALL)
	. = ..()
	if(self_sustaining)
		add_atom_colour(rgb(255, 175, 0), FIXED_COLOUR_PRIORITY)

/obj/machinery/hydroponics/soil/update_status_light_overlays()
	return // Has no lights

/obj/machinery/hydroponics/soil/attackby_secondary(obj/item/weapon, mob/user, params)
	if(weapon.tool_behaviour != TOOL_SHOVEL) //Spades can still uproot plants on left click
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	balloon_alert(user, "clearing up soil...")
	if(weapon.use_tool(src, user, 1 SECONDS, volume=50))
		balloon_alert(user, "cleared")
		deconstruct(disassembled = TRUE)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/hydroponics/soil/CtrlClick(mob/user)
	return //Soil has no electricity.

/obj/machinery/hydroponics/soil/deconstruct(disassembled)
	new /obj/item/stack/ore/glass(drop_location(), 3)
	return ..()

///The usb port circuit

/obj/item/circuit_component/hydroponics
	display_name = "Hydropnics Tray"
	desc = "Automate the means of botanical production. Trigger to toggle auto-grow."
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL

	var/obj/machinery/hydroponics/attached_tray
	///If self-sustaining (also called auto-grow) should be turned on or off when the trigger is triggered.
	var/datum/port/input/selfsustaining_setting
	///Whether the plant in the tray is harvestable, alive, missing or dead.
	var/datum/port/output/plant_status
	///Whether the self sustaining mode is on
	var/datum/port/output/is_self_sustaining
	///Triggered when the plant is harvested
	var/datum/port/output/plant_harvested
	///The product amount of the last harvest
	var/datum/port/output/last_harvest
	///Triggered when the plant dies
	var/datum/port/output/plant_died
	///Triggered when a seed is either planted by someone or takes over the tray.
	var/datum/port/output/seeds_planted
	///The amount of water in the tray.
	var/datum/port/output/water_level
	///The amount of toxins in the tray.
	var/datum/port/output/toxic_level
	///The amount of pests in the tray.
	var/datum/port/output/pests_level
	///The amount of weeds in the tray.
	var/datum/port/output/weeds_level
	///The health of the plant in the tray.
	var/datum/port/output/plant_health
	///The amount of reagents in the tray
	var/datum/port/output/reagents_level

/obj/item/circuit_component/hydroponics/populate_ports()
	selfsustaining_setting = add_input_port("Auto-Grow Setting", PORT_TYPE_NUMBER)

	plant_status = add_output_port("Plant Status", PORT_TYPE_NUMBER)
	is_self_sustaining = add_output_port("Auto-Grow Status", PORT_TYPE_NUMBER)
	plant_harvested = add_output_port("Plant Harvested", PORT_TYPE_SIGNAL)
	last_harvest = add_output_port("Last Harvest Amount", PORT_TYPE_NUMBER)
	plant_died = add_output_port("Plant Died", PORT_TYPE_SIGNAL)
	seeds_planted = add_output_port("Seeds Planted", PORT_TYPE_SIGNAL)
	water_level = add_output_port("Water Level", PORT_TYPE_NUMBER)
	toxic_level = add_output_port("Toxins Level", PORT_TYPE_NUMBER)
	pests_level = add_output_port("Pests Level", PORT_TYPE_NUMBER)
	weeds_level = add_output_port("Weeds Level", PORT_TYPE_NUMBER)
	plant_health = add_output_port("Plant Health", PORT_TYPE_NUMBER)
	reagents_level = add_output_port("Reagents Level", PORT_TYPE_NUMBER)

/obj/item/circuit_component/hydroponics/register_usb_parent(atom/movable/parent)
	. = ..()
	if(istype(parent, /obj/machinery/hydroponics))
		attached_tray = parent
		RegisterSignal(attached_tray, COMSIG_HYDROTRAY_SET_SEED, PROC_REF(on_set_seed))
		RegisterSignal(attached_tray, COMSIG_HYDROTRAY_SET_SELFSUSTAINING, PROC_REF(on_set_selfsustaining))
		RegisterSignal(attached_tray, COMSIG_HYDROTRAY_SET_WEEDLEVEL, PROC_REF(on_set_weedlevel))
		RegisterSignal(attached_tray, COMSIG_HYDROTRAY_SET_PESTLEVEL, PROC_REF(on_set_pestlevel))
		RegisterSignal(attached_tray, COMSIG_HYDROTRAY_SET_WATERLEVEL, PROC_REF(on_set_waterlevel))
		RegisterSignal(attached_tray, COMSIG_HYDROTRAY_SET_PLANT_HEALTH, PROC_REF(on_set_plant_health))
		RegisterSignal(attached_tray, COMSIG_HYDROTRAY_SET_TOXIC, PROC_REF(on_set_toxic_level))
		RegisterSignal(attached_tray, COMSIG_HYDROTRAY_SET_PLANT_STATUS, PROC_REF(on_set_plant_status))
		RegisterSignal(attached_tray, COMSIG_HYDROTRAY_ON_HARVEST, PROC_REF(on_harvest))
		RegisterSignal(attached_tray, COMSIG_HYDROTRAY_PLANT_DEATH, PROC_REF(on_plant_death))
		var/list/reagents_holder_signals = list(
			COMSIG_REAGENTS_ADD_REAGENT,
			COMSIG_REAGENTS_REM_REAGENT,
			COMSIG_REAGENTS_NEW_REAGENT,
			COMSIG_REAGENTS_DEL_REAGENT,
		)
		RegisterSignal(attached_tray, reagents_holder_signals, PROC_REF(update_reagents_level))

/obj/item/circuit_component/hydroponics/unregister_usb_parent(atom/movable/parent)
	attached_tray = null
	UnregisterSignal(parent, list(COMSIG_HYDROTRAY_SET_SEED, COMSIG_HYDROTRAY_SET_SELFSUSTAINING,
		COMSIG_HYDROTRAY_SET_WEEDLEVEL, COMSIG_HYDROTRAY_SET_PESTLEVEL, COMSIG_HYDROTRAY_SET_WATERLEVEL,
		COMSIG_HYDROTRAY_SET_PLANT_HEALTH, COMSIG_HYDROTRAY_SET_TOXIC, COMSIG_HYDROTRAY_SET_PLANT_STATUS,
		COMSIG_HYDROTRAY_ON_HARVEST, COMSIG_HYDROTRAY_PLANT_DEATH))
	if(parent.reagents)
		UnregisterSignal(parent.reagents, list(COMSIG_REAGENTS_ADD_REAGENT, COMSIG_REAGENTS_REM_REAGENT,
			COMSIG_REAGENTS_NEW_REAGENT, COMSIG_REAGENTS_DEL_REAGENT))
	return ..()

/obj/item/circuit_component/hydroponics/get_ui_notices()
	. = ..()
	. += create_ui_notice("Plant Status Index: \"[HYDROTRAY_NO_PLANT]\", \"[HYDROTRAY_PLANT_GROWING]\", \"[HYDROTRAY_PLANT_DEAD]\", \"[HYDROTRAY_PLANT_HARVESTABLE]\"", "orange", "info")

/obj/item/circuit_component/hydroponics/proc/on_set_seed(datum/source, obj/item/seeds/new_seed)
	SIGNAL_HANDLER
	seeds_planted.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/hydroponics/proc/on_set_selfsustaining(datum/source, new_value)
	SIGNAL_HANDLER
	is_self_sustaining.set_output(new_value)

/obj/item/circuit_component/hydroponics/proc/on_set_weedlevel(datum/source, new_value)
	SIGNAL_HANDLER
	weeds_level.set_output(new_value)

/obj/item/circuit_component/hydroponics/proc/on_set_pestlevel(datum/source, new_value)
	SIGNAL_HANDLER
	pests_level.set_output(new_value)

/obj/item/circuit_component/hydroponics/proc/on_set_waterlevel(datum/source, new_value)
	SIGNAL_HANDLER
	water_level.set_output(new_value)

/obj/item/circuit_component/hydroponics/proc/on_set_plant_health(datum/source, new_value)
	SIGNAL_HANDLER
	plant_health.set_output(new_value)

/obj/item/circuit_component/hydroponics/proc/on_set_toxic_level(datum/source, new_value)
	SIGNAL_HANDLER
	toxic_level.set_output(new_value)

/obj/item/circuit_component/hydroponics/proc/on_set_plant_status(datum/source, new_value)
	SIGNAL_HANDLER
	plant_status.set_output(new_value)

/obj/item/circuit_component/hydroponics/proc/on_harvest(datum/source, product_amount)
	SIGNAL_HANDLER
	last_harvest.set_output(product_amount)
	plant_harvested.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/hydroponics/proc/on_plant_death(datum/source)
	SIGNAL_HANDLER
	plant_died.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/hydroponics/proc/update_reagents_level(datum/source)
	SIGNAL_HANDLER
	reagents_level.set_output(attached_tray.reagents.total_volume)

/obj/item/circuit_component/hydroponics/input_received(datum/port/input/port)
	if(attached_tray.anchored && attached_tray.powered())
		attached_tray.set_self_sustaining(!!selfsustaining_setting.value)
