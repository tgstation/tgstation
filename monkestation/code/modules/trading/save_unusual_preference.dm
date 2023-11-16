/datum/preferences/proc/save_new_unusual(obj/item/unusual)
	var/datum/component/unusual_handler/component = unusual.GetComponent(/datum/component/unusual_handler)
	if(!component)
		return

	var/list/data = list()
	// These MUST be strings if you don't make them a string whatever daemon lurks inside of byond will get you.
	data["name"] = unusual.name
	data["type"] = "[component.particle_path]"
	data["round"] = "[component.round_id]"
	data["original_owner"] = component.original_owner_ckey
	data["description"] = component.unusual_description
	data["equipslot"] = "[component.unusual_equip_slot]"
	data["item_overlay"] = component.unusal_overlay
	data["unusual_type"] = "[unusual.type]"
	data["unusual_number"] = "[component.unusual_number]"

	extra_stat_inventory["unusual"] += list(data)
	save_preferences()

/datum/preferences/proc/return_unusual_data(number)
	return extra_stat_inventory["unusual"][number]


/datum/preferences/proc/clear_unusuals()
	extra_stat_inventory["unusual"] = list()
	save_preferences()

/mob/proc/spawn_first_stored_unusual()
	if(!client?.prefs)
		return
	var/list/data = client.prefs.return_unusual_data(1)
	var/item_path = text2path(data["unusual_type"])
	var/obj/item/new_item = new item_path(get_turf(src))

	new_item.AddComponent(/datum/component/unusual_handler, data)

/mob/proc/create_unusual()
	if(!client?.prefs)
		return
	var/obj/item/clothing/head/costume/nightcap/red/created = new()

	created.AddComponent(/datum/component/unusual_handler, particle_path = /datum/component/particle_spewer/fire, fresh_unusual = TRUE, client_ckey = ckey)
	client.prefs.save_new_unusual(created)
