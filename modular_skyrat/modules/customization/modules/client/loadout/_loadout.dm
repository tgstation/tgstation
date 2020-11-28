/datum/loadout_item
	var/name
	///Category in which the item belongs to LOADOUT_CATEGORY_UNIFORM, LOADOUT_CATEGORY_BACKPACK etc.
	var/category = LOADOUT_CATEGORY_NONE
	///Subcategory in which the item belongs to
	var/subcategory = LOADOUT_SUBCATEGORY_MISC
	///Description of the loadout item, automatically set by New() if null
	var/description
	///Typepath to the item being spawned
	var/path
	///How much loadout points does it cost?
	var/cost = 1
	///If set, it's a list containing ckeys which only can get the item
	var/list/ckeywhitelist
	///If set, is a list of job names of which can get the loadout item
	var/list/restricted_roles
	///Descriptive explanation of the restricted roles, if empty will automatically generate on New() if nessecary
	var/restricted_desc
	///Extra information which the user can set. (LOADOUT_INFO_NONE, LOADOUT_INFO_STYLE, LOADOUT_INFO_ONE_COLOR, LOADOUT_INFO_THREE_COLORS)
	var/extra_info
	///Whether the item is restricted to supporters
	var/donator_only

/datum/loadout_item/New()
	if(!description && path)
		var/obj/O = path
		description = initial(O.desc)
	if(restricted_roles && !restricted_desc)
		var/passed_first = FALSE
		restricted_desc = ""
		for(var/job_name in restricted_roles)
			if(!passed_first)
				passed_first = TRUE
			else
				restricted_desc += ", "
			restricted_desc += job_name

/datum/loadout_item/proc/get_spawned_item(customization) //Pass the value from the associative list
	var/obj/item/spawned = new path()
	if(customization != "None")
		customize(spawned, customization)
	return spawned

//Proc designed to be overwritten by invidivual loadout items. has support for a one color feed, and poly colors
/datum/loadout_item/proc/customize(var/obj/item/spawned, customization)
	switch(extra_info)
		if(LOADOUT_INFO_ONE_COLOR)
			spawned.color = "#[customization]"
		if(LOADOUT_INFO_THREE_COLORS)
			var/list/color_list = splittext(customization, "|")
			var/list/finished_list = list()
			finished_list += ReadRGB("[color_list[1]]0")
			finished_list += ReadRGB("[color_list[2]]0")
			finished_list += ReadRGB("[color_list[3]]0")
			finished_list += list(0,0,0,255)
			for(var/index in 1 to finished_list.len)
				finished_list[index] /= 255
			spawned.color = finished_list

/datum/loadout_item/proc/default_customization()
	switch(extra_info)
		if(LOADOUT_INFO_ONE_COLOR)
			return "FFF"
		if(LOADOUT_INFO_THREE_COLORS)
			return "FFF|FFF|FFF"
		else
			return "None"
