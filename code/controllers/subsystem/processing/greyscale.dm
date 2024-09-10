PROCESSING_SUBSYSTEM_DEF(greyscale)
	name = "Greyscale"
	flags = SS_BACKGROUND
	init_order = INIT_ORDER_GREYSCALE
	wait = 3 SECONDS

	var/list/datum/greyscale_config/configurations = list()
	var/list/datum/greyscale_layer/layer_types = list()

/datum/controller/subsystem/processing/greyscale/Initialize()
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

	// This final verification step is for things that need other greyscale configurations to be finished loading
	for(var/greyscale_type as anything in configurations)
		CHECK_TICK
		var/datum/greyscale_config/config = configurations[greyscale_type]
		config.CrossVerify()

	if(CONFIG_GET(flag/generate_assets_in_init))
		ExportMapPreviews()

	return SS_INIT_SUCCESS

/datum/controller/subsystem/processing/greyscale/proc/RefreshConfigsFromFile()
	for(var/i in configurations)
		configurations[i].Refresh(TRUE)

/datum/controller/subsystem/processing/greyscale/proc/ExportMapPreviews()
	// Put subtypes before their parent or the parent file will take all the generated icons
	var/static/list/types_that_get_their_own_file = list(
		"turfs" = /turf, // None of these yet but it's harmless to be prepared
		"mobs" = /mob, // Ditto
		"clothing" = /obj/item/clothing,
		"items" = /obj/item,
		"objects" = /obj,
	)

	var/list/handled_types = list()
	for(var/filename in types_that_get_their_own_file)
		var/type_to_export = types_that_get_their_own_file[filename]
		handled_types += ExportMapPreviewsForType(filename, type_to_export, handled_types)

	ExportMapPreviewsForType("unsorted", /atom, handled_types)

/datum/controller/subsystem/processing/greyscale/proc/ExportMapPreviewsForType(filename, atom/atom_typepath, list/type_blacklist)
	var/list/handled_types = list()
	var/list/icons = list()
	for(var/atom/fake as anything in subtypesof(atom_typepath))
		if(type_blacklist && type_blacklist[fake])
			continue
		handled_types[fake] = TRUE
		var/greyscale_config = fake::greyscale_config
		var/greyscale_colors = fake::greyscale_colors
		if(!greyscale_config || !greyscale_colors)
			continue
		var/icon/map_icon = GetColoredIconByType(greyscale_config, greyscale_colors)
		if(!(fake::post_init_icon_state in map_icon.IconStates()))
			stack_trace("GAGS configuration missing icon state needed to generate mapping tool graphic for '[fake]'. Make sure the right greyscale_config is set up.")
			continue
		map_icon = icon(map_icon, fake::post_init_icon_state)
		icons["[fake]"] = map_icon

	var/icon/holder = icon('icons/testing/greyscale_error.dmi')
	for(var/state in icons)
		holder.Insert(icons[state], state)

	var/filepath = "icons/map_icons/[filename].dmi"
#ifdef UNIT_TESTS
	var/old_md5 = md5filepath(filepath)
#endif
	fcopy(holder, filepath)
#ifdef UNIT_TESTS
	var/new_md5 = md5filepath(filepath)
	if(old_md5 != new_md5)
		stack_trace("Generated map icons were different than what is currently saved. If you see this in a CI run it means you need to run the game once through initialization and commit the resulting files in 'icons/map_icons/'")
#endif
	return handled_types

/datum/controller/subsystem/processing/greyscale/proc/GetColoredIconByType(type, list/colors)
	if(!ispath(type, /datum/greyscale_config))
		CRASH("An invalid greyscale configuration was given to `GetColoredIconByType()`: [type]")
	type = "[type]"
	if(istype(colors)) // It's the color list format
		colors = colors.Join()
	else if(!istext(colors))
		CRASH("Invalid colors were given to `GetColoredIconByType()`: [colors]")
	return configurations[type].Generate(colors)

/datum/controller/subsystem/processing/greyscale/proc/ParseColorString(color_string)
	. = list()
	var/list/split_colors = splittext(color_string, "#")
	for(var/color in 2 to length(split_colors))
		. += "#[split_colors[color]]"
