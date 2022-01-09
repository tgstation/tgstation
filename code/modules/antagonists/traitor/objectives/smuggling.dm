/datum/traitor_objective_category/smuggle
	name = "Smuggling"
	objectives = list(
		/datum/traitor_objective/smuggle = 1,
	)

///smuggle! bring a traitor item from its arrival area to the cargo shuttle, where the objective completes on selling the item
/datum/traitor_objective/smuggle
	name = "Smuggle %CONTRABAND% from %AREA% off the station via cargo shuttle"
	description = "Go to a designated area, pick up syndicate contraband, and get it off the station via the cargo shuttle. \
	You will instantly fail this objective if anyone else picks up your contraband. If you fail, you are liable for the costs \
	of the smuggling item."

	progression_reward = list(5 MINUTES, 9 MINUTES)
	telecrystal_reward = list(0, 1)

	///area type the objective owner must be in to recieve the contraband
	var/area/smuggle_spawn_type
	///the contraband that must be exported on the shuttle
	var/obj/item/contraband
	///type of contraband to spawn
	var/obj/item/contraband_type
	/// possible objective items. Mapped by item type = penalty cost for failing
	var/list/possible_contrabands = list(
		/obj/item/pen/edagger/prototype = 2,
		/obj/item/gun/syringe/syndicate/prototype = 4,
		/obj/item/reagent_containers/glass/bottle/ritual_wine = 6, //poison kit price
	)

/datum/traitor_objective/smuggle/is_duplicate(datum/traitor_objective/smuggle/objective_to_compare)
	if(objective_to_compare.contraband_type == contraband_type)
		return TRUE
	//it's too similar if its from the same area
	if(objective_to_compare.smuggle_spawn_type == smuggle_spawn_type)
		return TRUE
	return FALSE

/datum/traitor_objective/smuggle/generate_ui_buttons(mob/user)
	var/list/buttons = list()
	if(!contraband)
		buttons += add_ui_button("", "Pressing this will materialize the contraband you need to deliver. You must be in [initial(smuggle_spawn_type.name)] to receive it!", "box", "summon_contraband")
	return buttons

/datum/traitor_objective/smuggle/ui_perform_action(mob/living/user, action)
	. = ..()
	switch(action)
		if("summon_contraband")
			if(contraband)
				return
			var/area/player_area = get_area(user)
			if(!istype(player_area, smuggle_spawn_type))
				user.balloon_alert(user, "you can't materialize this here!")
				return
			contraband = new contraband_type(user.drop_location())
			user.put_in_hands(contraband)
			user.balloon_alert(user, "[contraband] materializes in your hand")
			RegisterSignal(contraband, COMSIG_ITEM_PICKUP, .proc/on_contraband_pickup)
			AddComponent(/datum/component/traitor_objective_register, contraband, \
				succeed_signals = COMSIG_ITEM_SOLD, \
				fail_signals = list(COMSIG_PARENT_QDELETING), \
				penalty = telecrystal_penalty \
			)
			if(contraband.reagents)
				AddComponent(/datum/component/traitor_objective_register, contraband.reagents, \
					fail_signals = list(COMSIG_REAGENTS_REM_REAGENT, COMSIG_REAGENTS_DEL_REAGENT), \
					penalty = telecrystal_penalty)

/datum/traitor_objective/smuggle/generate_objective(datum/mind/generating_for, list/possible_duplicates)
	//anyone working cargo should not get almost free objectives by having direct access to the cargo shuttle
	if(generating_for.assigned_role.departments_bitflags & DEPARTMENT_BITFLAG_CARGO)
		return FALSE

	//choose starting area to recieve contraband
	var/list/possible_areas = GLOB.the_station_areas.Copy()
	for(var/area/possible_area as anything in possible_areas)
		//remove areas too close to the destination, too obvious for our poor shmuck, or just unfair
		if(istype(possible_area, /area/cargo) || istype(possible_area, /area/hallway) || istype(possible_area, /area/security))
			possible_areas -= possible_area
	for(var/datum/traitor_objective/smuggle/smuggle_objective as anything in possible_duplicates)
		possible_areas -= smuggle_objective.smuggle_spawn_type
		possible_contrabands -= smuggle_objective.contraband_type
		if(smuggle_objective.objective_state == OBJECTIVE_STATE_INACTIVE || smuggle_objective.objective_state == OBJECTIVE_STATE_ACTIVE)
			return FALSE // You can only have 1 objective of this type active and inactive at a time.
	if(!length(possible_contrabands))
		return FALSE
	if(!length(possible_areas))
		return FALSE
	smuggle_spawn_type = pick(possible_areas)
	//choose contraband type to spawn when reaching starting area
	contraband_type = pick(possible_contrabands)
	telecrystal_penalty = possible_contrabands[contraband_type]
	replace_in_name("%CONTRABAND%", initial(contraband_type.name))
	replace_in_name("%AREA%", initial(smuggle_spawn_type.name))
	return TRUE

/datum/traitor_objective/smuggle/ungenerate_objective()
	. = ..()
	if(contraband)
		UnregisterSignal(contraband, COMSIG_ITEM_PICKUP)
		contraband = null

/datum/traitor_objective/smuggle/proc/on_contraband_pickup(datum/source, mob/taker)
	SIGNAL_HANDLER
	if(taker != handler.owner?.current)
		fail_objective(penalty_cost = telecrystal_penalty)

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
