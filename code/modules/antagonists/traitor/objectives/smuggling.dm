/datum/traitor_objective_category/smuggle
	name = "Smuggling"
	objectives = list(
		/datum/traitor_objective/smuggle = 1,
	)

///smuggle! bring a traitor item from its arrival area to the cargo shuttle, where the objective completes on selling the item
/datum/traitor_objective/smuggle
	name = "Smuggle \[CONTRABAND] from \[AREA], off the station via cargo shuttle."
	description = "Go to a designated area, pick up syndicate contraband, and get it off the station via the cargo shuttle. \
	You will instantly fail this objective if anyone else picks up your contraband. If you fail, you are liable for the costs \
	of the smuggling item."
	///the only person who should be allowed to pickup the contraband without failing the objective
	var/mob/living/smuggler
	///area type the objective owner must be in to recieve the contraband
	var/area/smuggle_spawn_type
	///the contraband that must be exported on the shuttle
	var/obj/item/contraband
	///type of contraband to spawn
	var/obj/item/contraband_type

/datum/traitor_objective/smuggle/is_duplicate(datum/traitor_objective/objective_to_compare)
	. = ..()
	//it's too similar if its from the same area, who cares about the contraband in question
	if(objective_to_compare.smuggle_spawn_type == smuggle_spawn_type)
		return TRUE
	return FALSE

/datum/traitor_objective/smuggle/generate_ui_buttons(mob/user)
	var/list/buttons = list()
	if(!contraband)
		buttons += add_ui_button("", "Pressing this will materialize the contraband you need to deliver. You must be in [initial(smuggle_spawn_type.name)] to recieve it!", "box", "summon_contraband")
	return buttons

/datum/traitor_objective/smuggle/ui_perform_action(mob/living/user, action)
	. = ..()
	switch(action)
		if("summon_contraband")
			if(contraband)
				return
			contraband = new contraband_type(user.drop_location())
			user.put_in_hands(contraband)
			user.balloon_alert(user, "[contraband] materializes in your hand")
			RegisterSignal(contraband, COMSIG_ITEM_PICKUP, .proc/on_contraband_pickup)
			//DEL_REAGENT signal is for removing ritual wine from the bottle
			AddComponent(/datum/component/traitor_objective_register, contraband, \
				succeed_signals = COMSIG_ITEM_SOLD, \
				fail_signals = list(COMSIG_REAGENTS_DEL_REAGENT, COMSIG_PARENT_QDELETING), \
				penalty = TRUE \
			)

/datum/traitor_objective/smuggle/generate_objective(datum/mind/generating_for, list/possible_duplicates)
	. = ..()
	//anyone working cargo should not get almost free objectives by having direct access to the cargo shuttle
	if(generating_for.assigned_role.departments_bitflags & DEPARTMENT_BITFLAG_CARGO)
		return FALSE

	//our smuggler
	smuggler = generating_for.current
	//choose starting area to recieve contraband
	var/list/possible_areas = GLOB.the_station_areas.Copy()
	for(var/area/possible_area as anything in possible_areas)
		//remove areas too close to the destination, too obvious for our poor shmuck, or just unfair
		if(istype(possible_area, /area/cargo) || istype(possible_area, /area/hallway) || istype(possible_area, /area/security))
			possible_areas -= possible_area
	smuggle_spawn_type = pick(possible_areas)
	//choose contraband type to spawn when reaching starting area
	contraband_type = pick(
		/obj/item/pen/edagger/prototype,
		/obj/item/gun/syringe/syndicate/prototype,
		/obj/item/reagent_containers/glass/bottle/ritual_wine,
	)
	replace_in_name("\[CONTRABAND]", initial(contraband_type.name))
	replace_in_name("\[AREA]", initial(smuggle_spawn_type.name))
	return TRUE

/datum/traitor_objective/smuggle/ungenerate_objective()
	. = ..()
	smuggler = null
	smuggle_spawn_type = null
	contraband_type = null
	if(contraband)
		UnregisterSignal(contraband, COMSIG_ITEM_PICKUP)
		contraband = null

/datum/traitor_objective/smuggle/fail_objective(punish)
	if(punish)
		to_chat(smuggler, span_boldwarning("For failing to deliver the contraband, you have been deducted the telecrystal price of the item."))
		var/static/list/punishment_costs = list(
			/obj/item/pen/edagger/prototype = 2,
			/obj/item/gun/syringe/syndicate/prototype = 4,
			/obj/item/reagent_containers/glass/bottle/ritual_wine = 6, //poison kit price
		)
		var/cost_of_failure = punishment_costs[contraband_type]
		//technically you can get a discount on the item if you have less tc than the price of the item, but honestly at that point you need the help
		handler.telecrystals = max(handler.telecrystals - cost_of_failure, 0)
	. = ..()

/datum/traitor_objective/smuggle/proc/on_contraband_pickup(datum/source, mob/taker)
	SIGNAL_HANDLER
	if(taker != smuggler)
		fail_objective(TRUE)

//smuggling container
/obj/item/reagent_containers/glass/bottle/ritual_wine
	name = "ritual wine bottle"
	desc = "Contains an incredibly potent mix of various hallucinogenics, herbal extracts, and hard drugs. \
	the Tiger Cooperative praises it as a link to higher powers, but for all intents and purposes this should \
	not be consumed."
	list_reagents = list(
		//changeling adrenals part
		/datum/reagent/drug/methamphetamine = 5,
		//hallucinations part
		/datum/reagent/drug/mushroomhallucinogen = 35,
		//alcoholic part, plus more hallucinations lel
		/datum/reagent/consumable/ethanol/ritual_wine = 10,
	)
