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

	return ..()

/datum/controller/subsystem/greyscale/proc/RefreshConfigsFromFile()
	for(var/i in configurations)
		configurations[i].Refresh(TRUE)

/datum/controller/subsystem/greyscale/proc/GetColoredIconByType(type, list/colors)
	type = "[type]"
	if(istext(colors)) // It's the color string format for map edits/type values etc
		colors = ParseColorString(colors)
	return configurations[type].Generate(colors)

/datum/controller/subsystem/greyscale/proc/ParseColorString(colors)
	var/list/split_colors = splittext(colors, "#")
	var/list/output = list()
	for(var/i in 2 to length(split_colors))
		output += "#[split_colors[i]]"
	return output
