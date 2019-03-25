/datum/spawners_menu
	var/mob/dead/observer/owner

/datum/spawners_menu/New(mob/dead/observer/new_owner)
	if(!istype(new_owner))
		qdel(src)
	owner = new_owner

/datum/spawners_menu/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.observer_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "spawners_menu", "Spawners Menu", 700, 600, master_ui, state)
		ui.open()

/datum/spawners_menu/ui_data(mob/user)
	var/list/data = list()
	data["spawners"] = list()
	for(var/spawner in GLOB.mob_spawners)
		var/list/this = list()
		this["name"] = spawner
		this["desc"] = ""
		this["refs"] = list()
		for(var/spawner_obj in GLOB.mob_spawners[spawner])
			this["refs"] += "[REF(spawner_obj)]"
			if(!this["desc"])
				if(istype(spawner_obj, /obj/effect/mob_spawn))
					var/obj/effect/mob_spawn/MS = spawner_obj
					this["desc"] = MS.flavour_text
				else
					var/obj/O = spawner_obj
					this["desc"] = O.desc
		this["amount_left"] = LAZYLEN(GLOB.mob_spawners[spawner])
		data["spawners"] += list(this)

	return data

/datum/spawners_menu/ui_act(action, params)
	if(..())
		return
	var/list/spawnerlist = list(GLOB.mob_spawners[params["name"]])
	if(!spawnerlist.len)
		return
	var/spawner_ref = pick(spawnerlist)
	var/obj/effect/mob_spawn/MS = locate(spawner_ref) in GLOB.poi_list
	if(!MS)
		return

	switch(action)
		if("jump")
			if(MS)
				owner.forceMove(get_turf(MS))
				. = TRUE
		if("spawn")
			if(MS)
				MS.attack_ghost(owner)
				. = TRUE
