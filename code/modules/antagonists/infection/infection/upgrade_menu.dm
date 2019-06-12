/datum/infection_menu
	var/name = "Evolution Menu"
	var/upgrading

/datum/infection_menu/New(upgrading)
	src.upgrading = upgrading
	if(istype(upgrading, /obj/structure/infection))
		return ..()
	if(istype(upgrading, /mob/living/simple_animal/hostile/infection/infectionspore/sentient))
		return ..()
	if(istype(upgrading, /mob/camera/commander))
		return ..()
	return INITIALIZE_HINT_QDEL

/datum/infection_menu/proc/get_evolution_list()
	if(istype(upgrading, /obj/structure/infection))
		var/obj/structure/infection/I = upgrading
		return I.upgrades
	if(istype(upgrading, /mob/living/simple_animal/hostile/infection/infectionspore/sentient))
		var/mob/living/simple_animal/hostile/infection/infectionspore/sentient/S = upgrading
		return S.upgrades
	if(istype(upgrading, /mob/camera/commander))
		var/mob/camera/commander/C = upgrading
		return C.unlockable_actions
	return

/datum/infection_menu/proc/get_points_left()
	if(istype(upgrading, /obj/structure/infection))
		var/obj/structure/infection/I = upgrading
		return I.overmind.infection_points
	if(istype(upgrading, /mob/living/simple_animal/hostile/infection/infectionspore/sentient))
		var/mob/living/simple_animal/hostile/infection/infectionspore/sentient/S = upgrading
		return S.upgrade_points
	if(istype(upgrading, /mob/camera/commander))
		var/mob/camera/commander/C = upgrading
		return C.upgrade_points
	return

/datum/infection_menu/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.always_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "infection", name, 900, 480, master_ui, state)
		ui.open()

/datum/infection_menu/ui_data(mob/user)
	var/list/data = list()

	var/points_remaining = get_points_left()
	data["evolution_points"] = points_remaining

	var/list/upgrades = list()

	for(var/datum/infection_upgrade/evolution in get_evolution_list())
		var/point_cost = evolution.cost
		if(point_cost <= 0)
			continue

		var/list/AL = list()
		AL["name"] = evolution.name
		AL["desc"] = evolution.description
		AL["owned"] = evolution.bought
		AL["upgrade_cost"] = point_cost
		AL["can_purchase"] = (points_remaining >= point_cost)

		upgrades += list(AL)

	data["upgrades"] = upgrades

	return data

/datum/infection_menu/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("evolve")
			var/upgrade_name = params["name"]