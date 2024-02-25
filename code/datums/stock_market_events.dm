/datum/stock_market_event
	/// The name of the event, used to describe it in the news.
	var/name = "Stock Market Event!"
	/// A list of company names to use for the event and the circumstance.
	var/static/list/company_name = list(
		"Nakamura Engineering",
		"Robust Industries, LLC",
		"MODular Solutions",
		"SolGov",
		"Australicus Industrial Mining",
		"Vey-Medical",
		"Aussec Armory",
		"Dreamland Robotics"
	)
	/// A list of strings selected from the event that's used to describe the event in the news.
	var/list/circumstance = list()
	/// What material is affected by the event?
	var/datum/material/mat
	/// Constant to multiply the original material value by to get the new minimum value, unless the material has a minimum override.
	var/price_minimum = SHEET_MATERIAL_AMOUNT * 0.5
	/// Constant to multiply the original material value by to get the new maximum value.
	var/price_maximum = SHEET_MATERIAL_AMOUNT * 3

	/// When this event is ongoing, what direction will the price trend in?
	var/trend_value
	/// When this event is triggered, for how long will it's effects last?
	var/trend_duration

/**
 * Before attempting to create a new stock_market_event, this proc is called to filter the list of currently possible events.
 * @param _mat The material that the upcoming event will affect.
 */
/datum/stock_market_event/proc/can_start_event(datum/material/mat)
	return TRUE

/**
 * When a new stock_market_event is created, this proc is called to set up the event if there's anything that needs to happen upon it starting.
 * @param _mat The material that this event will affect.
 */
/datum/stock_market_event/proc/start_event(datum/material/mat)
	if(istype(mat, /datum/material))
		return FALSE
	src.mat = mat
	if(!isnull(trend_value))
		SSstock_market.materials_trends[mat] =	trend_value
		if(!isnull(trend_duration))
			SSstock_market.materials_trend_life[mat] = trend_duration
	return TRUE

/**
 * This proc is called every tick while the event is ongoing by SSstock_market.
 */
/datum/stock_market_event/proc/handle()
	trend_duration--
	if(trend_duration <= 0)
		end_event()
	return

/**
 * This proc is called whenever a materials market crate is filled by /datum/supply_pack/custom/minerals/fill,
 * as long as the event is still active.
 */
/datum/stock_market_event/proc/handle_crate(obj/structure/closet/crate/C)
	for(var/obj/item/stack/sheet/stack in C)
		if(!istype(stack))
			continue
		if(stack.has_material_type(mat))
			return TRUE
	return FALSE

/**
 * When a stock_market_event is ended, this proc is called to apply any final effects and clean up anything that needs to be cleaned up.
 */
/datum/stock_market_event/proc/end_event()
	SSstock_market.active_events -= src
	qdel(src)

/**
 * This proc is called to create a news string for the event, which is passed along to SSstock_market to be appended to the automatic newscaster messages.
 */
/datum/stock_market_event/proc/create_news()
	var/temp_company = pick(company_name)
	var/temp_circumstance = pick(circumstance)
	SSstock_market.news_string += "<b>[name] [temp_company]</b> [temp_circumstance]<b>[mat.name].</b><br>"


/datum/stock_market_event/market_reset
	name = "Market Reset!"
	trend_value = MARKET_TREND_STABLE
	trend_duration = 1
	circumstance = list(
		"was purchased by a private investment firm, resetting the price of ",
		"restructured, resetting the price of ",
		"has been rolled into a larger company, resetting the price of ",
	)

/datum/stock_market_event/market_reset/start_event()
	. = ..()
	SSstock_market.materials_prices[mat] = (initial(mat.value_per_unit)) * SHEET_MATERIAL_AMOUNT
	create_news()

/datum/stock_market_event/large_boost
	name = "Large Boost!"
	trend_value = MARKET_TREND_UPWARD
	trend_duration = 3
	circumstance = list(
		"has just released a new product that raised the price of ",
		"discovered a new valuable use for ",
		"has produced a report that raised the price of ",
	)

/datum/stock_market_event/large_boost/start_event()
	. = ..()
	var/price_units = SSstock_market.materials_prices[mat]
	SSstock_market.materials_prices[mat] += round(gaussian(price_units * 0.5, price_units * 0.1))
	SSstock_market.materials_prices[mat] = clamp(SSstock_market.materials_prices[mat], price_minimum * mat.value_per_unit, price_maximum * mat.value_per_unit)
	create_news()

/datum/stock_market_event/large_drop
	name = "Large Drop!"
	trend_value = MARKET_TREND_DOWNWARD
	trend_duration = 5
	circumstance = list(
		"'s latest product has seen major controversy, and resulted in a price drop for ",
		"has been hit with a major lawsuit, resulting in a price drop for ",
		"has produced a report that lowered the price of ",
	)

/datum/stock_market_event/large_drop/start_event()
	. = ..()
	var/price_units = SSstock_market.materials_prices[mat]
	SSstock_market.materials_prices[mat] -= round(gaussian(price_units * 1.5, price_units * 0.1))
	SSstock_market.materials_prices[mat] = clamp(SSstock_market.materials_prices[mat], price_minimum * mat.value_per_unit, price_maximum * mat.value_per_unit)
	create_news()

/datum/stock_market_event/hostile_takeover
	name = "Hostile Takeover!"
	trend_value = MARKET_TREND_DOWNWARD
	trend_duration = 10
	circumstance = list(
		"has recently cut their safety budget, enabling possibly dangerous interference in the supply line for ",
		"has had pirates take root in their facilities for supplying ",
		"has sold off some of their facilities to a hostile third party, whom might interfere with the supply of ",
	)
	/// Possible outcomes for hostile parties adding to crates.
	var/spawnables = list(
		"none" = 25, // Rolled a dud
		"corpse_cargotech" = 25, // Gibbed cargotech, blows up on arrival
		"corpse_assistant" = 20, // Gibbed assistant, blows up on arrival
		"agent_cat" = 15, // Feral cat, teargas grenade, pictures of supply crew
		"pipebomb" = 5, // Potassium-water bomb and IED
		"clown_event" = 4, // Gibbed clown and glitterbomb
		"fakediskie" = 1, // Fake diskie and captain's hat
	)
	/// Which ID trims records should have for us to give agent cat a picture.
	var/targets = list(
		JOB_QUARTERMASTER,
		JOB_CARGO_TECHNICIAN,
		JOB_CARGO_GORILLA, // The gorilla too.
		JOB_SHAFT_MINER,
		JOB_BITRUNNER,
	)

/datum/stock_market_event/hostile_takeover/can_start_event()
	. = ..()
	if(.)
		// Chance of hostile takeover being available to pick is based on the cargo budget.
		// Every 10k is 1%, always being available at a million and above.
		var/datum/bank_account/department/cargo = SSeconomy.get_dep_account(ACCOUNT_CAR)
		var/cur_balance = cargo.account_balance
		var/takeover_prob = min(max(1, cur_balance / 10000), 100)
		message_admins("can_start_event - takeover_prob = [takeover_prob]")
		if(!prob(takeover_prob))
			return FALSE

/datum/stock_market_event/hostile_takeover/start_event()
	. = ..()
	create_news()

/datum/stock_market_event/hostile_takeover/handle_crate(obj/structure/closet/crate/C)
	. = ..()
	if(!.)
		return

	var/obj/item/grenade/chem_grenade/spawned_grenade
	var/obj/effect/mob_spawn/corpse/corpse_spawner

	switch(pick_weight(spawnables))
		if("corpse_cargotech")
			corpse_spawner = new /obj/effect/mob_spawn/corpse/human/cargo_tech(null, TRUE)
			spawned_grenade = new /obj/item/grenade/chem_grenade/stockmarketbomb(C)
		if("corpse_assistant")
			corpse_spawner = new /obj/effect/mob_spawn/corpse/human/assistant(null, TRUE)
			spawned_grenade = new /obj/item/grenade/chem_grenade/stockmarketbomb(C)
		if("agent_cat")
			spawned_grenade = new /obj/item/grenade/chem_grenade/teargas(C)
			var/mob/living/basic/pet/cat/agent_cat = new /mob/living/basic/pet/cat/feral(C)
			agent_cat.name = "agent cat"
			// Assemble agent cat targets
			for(var/datum/record/crew/target in GLOB.manifest.general)
				message_admins("cat agent - target: [target] target.trim: [target.trim] JOB_CARGO_TECHNICIAN: [JOB_CARGO_TECHNICIAN]")
				if(target.trim in targets)
					var/obj/item/photo/photo = target.get_front_photo()
					if(!isnull(photo) && istype(photo))
						message_admins("cat agent - target: [target] PHOTO NOT NULL")
						photo.forceMove(C)
		if("pipebomb")
			spawned_grenade = new /obj/item/grenade/chem_grenade/stockmarketbomb(C)
			new /obj/item/grenade/iedcasing/spawned(C)
		if("clown_event")
			corpse_spawner = new /obj/effect/mob_spawn/corpse/human/clown(null, TRUE)
			spawned_grenade = new /obj/item/grenade/chem_grenade/glitter/pink(C)
		if("fakediskie")
			new /obj/item/disk/nuclear/fake(C)
			new /obj/item/clothing/head/hats/caphat(C)

	// If there's a corpse to be spawned, make it so
	if(!isnull(corpse_spawner))
		var/mob/living/spawned_corpse = corpse_spawner.create()
		spawned_corpse.forceMove(C)
		spawned_corpse.gib(DROP_ALL_REMAINS)

	// If there's a grenade, make it explode when the crate is opened.
	if(!isnull(spawned_grenade))
		var/obj/item/grenade/chem_grenade/main_grenade = spawned_grenade
		var/obj/item/assembly/prox_sensor/prox_sensor = new(C)
		prox_sensor.scanning = TRUE
		main_grenade.wires.attach_assembly(main_grenade.wires.get_wire(1), prox_sensor)
