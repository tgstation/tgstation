SUBSYSTEM_DEF(greyscale)
	name = "Greyscale"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_GREYSCALE

	var/list/datum/greyscale_config/greyscale_cache = list()

/datum/controller/subsystem/greyscale/Initialize(start_timeofday)
	for(var/greyscale_type in subtypesof(/datum/greyscale_config))
		var/datum/greyscale_config/config = new greyscale_type()
		greyscale_cache["[greyscale_type]"] = config
	return ..()

/datum/controller/subsystem/greyscale/proc/GetColoredIconByType(type, list/colors)
	// We use the stringified types instead of the types directly for compat with the json configs
	type = "[type]"
	if(istext(colors)) // It's the color string format for map edits/type values etc
		colors = ParseColorString(colors)
	return greyscale_cache[type].Generate(colors)

/datum/controller/subsystem/greyscale/proc/ParseColorString(colors)
	var/list/split_colors = splittext(colors, "#")
	var/list/output = list()
	for(var/i in 2 to length(split_colors))
		output += "#[split_colors[i]]"
	return output
