/datum/beaker_panel

/datum/beaker_panel/ui_state(mob/user)
	return ADMIN_STATE(R_ADMIN)

/datum/beaker_panel/ui_close()
	qdel(src)

/datum/beaker_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BeakerPanel")
		ui.open()

/datum/beaker_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/user = ui.user
	switch(action)
		if("spawn")
			var/obj/created = spawn_container_from_data(user, params["spawn_info"])
			user.log_message("spawned a [created] containing [pretty_string_from_reagent_list(created.reagents.reagent_list)]", LOG_ADMIN)
			return TRUE
		if("spawngrenade")
			var/obj/item/grenade/chem_grenade/grenade = spawn_grenade_from_data(user, params["spawn_info"], params["grenade_info"])
			var/log_string = list()
			for(var/obj/beaker as anything in grenade.beakers)
				log_string += pretty_string_from_reagent_list(beaker.reagents.reagent_list)
			user.log_message("spawned a [grenade] containing [english_list(log_string)]", LOG_ADMIN)
			return TRUE

/datum/beaker_panel/ui_static_data(mob/user)
	var/list/data = list()

	data["reagents"] = list()
	data["containers"] = list()

	for(var/datum/reagent/reagent_type as anything in subtypesof(/datum/reagent))
		if(!reagent_type::name)
			continue
		data["reagents"] += list(list("id" = reagent_type, "text" = reagent_type::name))

	for(var/obj/item/reagent_containers/container_type as anything in subtypesof(/obj/item/reagent_containers))
		if(!container_type::name)
			continue
		data["containers"] += list(list("id" = container_type, "text" = container_type::name, "volume" = container_type::volume))

	return data

/datum/beaker_panel/proc/spawn_container_from_data(mob/user, list/spawn_info)
	var/container_type = text2path(spawn_info["container"])
	var/list/container_reagents = list()
	for(var/reagent_string, reagent_amount in spawn_info["reagents"])
		container_reagents[text2path(reagent_string)] = text2num(reagent_amount)

	return spawn_container(user, container_type, container_reagents)

/datum/beaker_panel/proc/spawn_container(mob/user, container_type, list/container_reagents)
	var/obj/item/reagent_containers/container = new container_type(user.drop_location())
	container.reagents.maximum_volume = INFINITY
	container.reagents.clear_reagents()
	container.reagents.add_reagent_list(container_reagents)
	container.reagents.maximum_volume = max(container.reagents.total_volume, initial(container.volume))
	return container

/datum/beaker_panel/proc/spawn_grenade_from_data(mob/user, list/all_spawn_info, list/grenade_info)
	var/list/containers = list()
	for(var/list/container_info as anything in all_spawn_info)
		containers += spawn_container_from_data(user, container_info)

	return spawn_grenade(user, containers, grenade_info)

/datum/beaker_panel/proc/spawn_grenade(mob/user, list/beakers, list/grenade_info)
	var/obj/item/grenade/chem_grenade/grenade = new(user.drop_location())
	grenade.beakers = beakers
	grenade.stage_change(GRENADE_READY)

	for(var/obj/beaker as anything in grenade.beakers)
		beaker.forceMove(grenade)

	switch(grenade_info["detonation_type"])
		if("normal")
			var/det_time = text2num(grenade_info["detonation_timer"]) * 1 SECONDS
			if(det_time)
				grenade.det_time = det_time

	return grenade

ADMIN_VERB(beaker_panel, R_SPAWN, "Spawn Reagent Container", "Spawn a reagent container.", ADMIN_CATEGORY_EVENTS)
	var/datum/beaker_panel/panel = new
	panel.ui_interact(user.mob)
