/datum/antagonist/voidwalker/ui_data(mob/user)
	var/list/data = list()

	data["upgrades_charges"] = points
	var/list/upgrades_list = list()
	data["upgrades_list"] = list()
	var/list/sort_by_unlocked_and_not = list()
	for(var/datum/voidwalker_upgrades_tree/box_with_upgrades in all_upgrades)
		if(box_with_upgrades.unlocked)
			sort_by_unlocked_and_not += box_with_upgrades
	sort_by_unlocked_and_not += all_upgrades - sort_by_unlocked_and_not
	for(var/datum/voidwalker_upgrades_tree/box_with_upgrades in sort_by_unlocked_and_not)
		var/list/upgrade_box_data = list()
		upgrade_box_data["name"] = box_with_upgrades.name
		upgrade_box_data["desc"] = box_with_upgrades.desc
		upgrade_box_data["icon"] = initial(box_with_upgrades.icon)
		upgrade_box_data["icon_state"] = initial(box_with_upgrades.icon_state)
		upgrade_box_data["is_unlocked"] = box_with_upgrades.unlocked
		upgrade_box_data["branches_tier_1"] = list()
		upgrade_box_data["branches_tier_2"] = list()
		upgrade_box_data["branches_tier_3"] = list()
		var/list/sorted_list = sort_list(box_with_upgrades.all_branches)
		for(var/tier_number in 1 to 3)
			for(var/datum/voidwalker_upgrade_branch/upgrade in sorted_list)
				if(upgrade.tier != tier_number)
					continue
				upgrade_box_data["branches_tier_[tier_number]"] += list(list(
					"name" = upgrade.name,
					"desc" = upgrade.desc,
					"type" = upgrade.type,
					"discaunt" = upgrade.for_free,
					"available" = upgrade.can_research()
				))
		upgrades_list += list(upgrade_box_data)
	data["upgrades_list"] = upgrades_list

	return data

/datum/antagonist/voidwalker/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("research")
			var/upgrade_param = params["what_upgrade"]
			if(!upgrade_param)
				return
			var/upgrade_type = text2path(upgrade_param)
			if(!upgrade_type)
				return
			for(var/datum/voidwalker_upgrades_tree/tree in all_upgrades)
				var/datum/voidwalker_upgrade_branch/new_upgrade = locate(upgrade_type) in tree.all_branches
				if(isnull(new_upgrade))
					continue
				new_upgrade.try_research()
				break
			return TRUE
		if("unlock")
			var/unlock_name = params["what_unlock"]
			if(!unlock_name)
				return
			for(var/datum/voidwalker_upgrades_tree/tree_by_name in all_upgrades)
				if(tree_by_name.name == unlock_name)
					tree_by_name.try_unlock()
					break
			return TRUE
