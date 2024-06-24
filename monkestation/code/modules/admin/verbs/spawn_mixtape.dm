/client/proc/spawn_mixtape()
	set category = "Admin.Game"
	set name = "Spawn Mixtape"
	set desc = "Select an approved mixtape to spawn at your location."

	var/datum/mixtape_spawner/tgui = new(usr)//create the datum
	tgui.ui_interact(usr)//datum has a tgui component, here we open the window

/datum/mixtape_spawner
	var/client/holder //client of whoever is using this datum

/datum/mixtape_spawner/New(user)//user can either be a client or a mob due to byondcode(tm)
	if (istype(user, /client))
		var/client/user_client = user
		holder = user_client //if its a client, assign it to holder
	else
		var/mob/user_mob = user
		holder = user_mob.client //if its a mob, assign the mob's client to holder

/datum/mixtape_spawner/ui_state(mob/user)
	return GLOB.admin_state

/datum/mixtape_spawner/ui_close()
	qdel(src)

/datum/mixtape_spawner/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MixtapeSpawner")
		ui.open()

/datum/mixtape_spawner/ui_data(mob/user)
	var/list/data = list()
	if(!length(SScassette_storage.cassette_datums))
		return
	for(var/datum/cassette_data/cassette in SScassette_storage.cassette_datums)
		data["approved_cassettes"] += list(list(
			"name" = cassette.cassette_name,
			"desc" = cassette.cassette_desc,
			"cassette_design_front" = cassette.cassette_design_front,
			"creator_ckey" = cassette.cassette_author_ckey,
			"creator_name" = cassette.cassette_author,
			"song_names" = cassette.song_names,
			"id" = cassette.cassette_id
		))
	return data

/datum/mixtape_spawner/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("spawn")
			if (params["id"])
				new/obj/item/device/cassette_tape(usr.loc, params["id"])
				SSblackbox.record_feedback("tally", "admin_verb", 1, "Spawn Mixtape")
				log_admin("[key_name(usr)] created mixtape [params["id"]] at [usr.loc].")
