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

	extra_stat_inventory["unusual"] += data
