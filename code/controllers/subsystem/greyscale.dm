SUBSYSTEM_DEF(greyscale)
	name = "Greyscale"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_GREYSCALE

	var/list/datum/greyscale_config/configurations = list()
	var/list/datum/greyscale_layer/layer_types = list()

/datum/controller/subsystem/greyscale/Initialize(start_timeofday)
	for(var/datum/greyscale_layer/fake_type as anything in subtypesof(/datum/greyscale_layer))
		layer_types[initial(fake_type.layer_type)] = fake_type

	for(var/greyscale_type in subtypesof(/datum/greyscale_config))
		var/datum/greyscale_config/config = new greyscale_type()
		configurations["[greyscale_type]"] = config

	// We do this after all the types have been loaded into the listing so reference layers don't care about init order
	for(var/greyscale_type in configurations)
		CHECK_TICK
		var/datum/greyscale_config/config = configurations[greyscale_type]
		config.Refresh()

	ExportMapPreviews()

	return ..()

/datum/controller/subsystem/greyscale/proc/RefreshConfigsFromFile()
	for(var/i in configurations)
		configurations[i].Refresh(TRUE)

/datum/controller/subsystem/greyscale/proc/ExportMapPreviews()
	var/list/icons = list()
	for(var/atom/fake as anything in subtypesof(/atom))
		CHECK_TICK
		if(!initial(fake.greyscale_config) || !initial(fake.greyscale_colors))
			continue
		var/icon/map_icon = GetColoredIconByType(initial(fake.greyscale_config), initial(fake.greyscale_colors))
		map_icon = icon(map_icon, initial(fake.icon_state))
		icons["[fake]"] = map_icon

	var/icon/holder = icon('icons/testing/greyscale_error.dmi')
	for(var/state in icons)
		CHECK_TICK
		holder.Insert(icons[state], state)

	fcopy(holder, "icons/map_icons.dmi")

/datum/controller/subsystem/greyscale/proc/GetColoredIconByType(type, list/colors)
	if(!ispath(type, /datum/greyscale_config))
		CRASH("An invalid greyscale configuration was given to `GetColoredIconByType()`: [type]")
	type = "[type]"
	if(istype(colors)) // It's the color list format
		colors = colors.Join()
	else if(!istext(colors))
		CRASH("Invalid colors were given to `GetColoredIconByType()`: [colors]")
	return configurations[type].Generate(colors)

/datum/controller/subsystem/greyscale/proc/ParseColorString(color_string)
	. = list()
	var/list/split_colors = splittext(color_string, "#")
	for(var/color in 2 to length(split_colors))
		. += "#[split_colors[color]]"
