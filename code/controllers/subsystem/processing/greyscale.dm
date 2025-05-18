/// Disable to use builtin DM-based generation.
/// IconForge is 250x times faster but requires storing the icons in tmp/ and may result in higher asset transport.
/// Note that the builtin GAGS editor still uses the 'legacy' generation to allow for debugging.
/// IconForge also does not support the color matrix layer type or the 'or' blend_mode, however both are currently unused.
#define USE_RUSTG_ICONFORGE_GAGS

/// If we are in unit tests OR if we are not using iconforge, then we should make sure the icons we are using are valid.
#if !defined(USE_RUSTG_ICONFORGE_GAGS) || defined(UNIT_TESTS)
	#define CHECK_SPRITESHEET_ICON_VALIDITY
#endif

PROCESSING_SUBSYSTEM_DEF(greyscale)
	name = "Greyscale"
	flags = SS_BACKGROUND
	wait = 3 SECONDS
	init_stage = INITSTAGE_EARLY
	var/list/datum/greyscale_config/configurations = list()
	var/list/datum/greyscale_layer/layer_types = list()
#ifdef USE_RUSTG_ICONFORGE_GAGS
	/// Cache containing a list of [UID (config path + colors)] -> [DMI file / RSC object] in the tmp directory from iconforge
	var/list/gags_cache = list()
#endif

/datum/controller/subsystem/processing/greyscale/Initialize()
	for(var/datum/greyscale_layer/greyscale_layer as anything in subtypesof(/datum/greyscale_layer))
		layer_types[initial(greyscale_layer.layer_type)] = greyscale_layer

	for(var/greyscale_type in subtypesof(/datum/greyscale_config))
		var/datum/greyscale_config/config = new greyscale_type()
		configurations["[greyscale_type]"] = config

	// We do this after all the types have been loaded into the listing so reference layers don't care about init order
	for(var/greyscale_type in configurations)
		CHECK_TICK
		var/datum/greyscale_config/config = configurations[greyscale_type]
		config.Refresh()

#ifdef USE_RUSTG_ICONFORGE_GAGS
	var/list/job_ids = list()
#endif

	// This final verification step is for things that need other greyscale configurations to be finished loading
	for(var/greyscale_type as anything in configurations)
		CHECK_TICK
		var/datum/greyscale_config/config = configurations[greyscale_type]
		config.CrossVerify()
#ifdef USE_RUSTG_ICONFORGE_GAGS
		job_ids += rustg_iconforge_load_gags_config_async(greyscale_type, config.raw_json_string, config.string_icon_file)

	UNTIL(jobs_completed(job_ids))
#endif

	return SS_INIT_SUCCESS

/datum/controller/subsystem/processing/greyscale/PostInit()
	. = ..()
#ifndef UNIT_TESTS // We want this to run during unit tests regardless of the config
	if(!CONFIG_GET(flag/generate_assets_in_init))
		return
#endif

	var/start_time = REALTIMEOFDAY
	ExportMapPreviews()
	var/message = "Finished GAGS map icon generation in [(REALTIMEOFDAY - start_time)/10]s!"
	to_chat(world, span_boldannounce("[message]"), MESSAGE_TYPE_DEBUG)
	log_world(message)

#ifdef USE_RUSTG_ICONFORGE_GAGS
/datum/controller/subsystem/processing/greyscale/proc/jobs_completed(list/job_ids)
	for(var/job in job_ids)
		var/result = rustg_iconforge_check(job)
		if(result == RUSTG_JOB_NO_RESULTS_YET)
			return FALSE
		if(result != "OK")
			stack_trace("Error during rustg_iconforge_load_gags_config job: [result]")
		job_ids -= job
	return TRUE
#endif

/datum/controller/subsystem/processing/greyscale/proc/RefreshConfigsFromFile()
	for(var/i in configurations)
		configurations[i].Refresh(TRUE)

/datum/controller/subsystem/processing/greyscale/proc/GetColoredIconByType(type, list/colors)
	if(!ispath(type, /datum/greyscale_config))
		CRASH("An invalid greyscale configuration was given to `GetColoredIconByType()`: [type]")
	if(!initialized)
		CRASH("GetColoredIconByType() called before greyscale subsystem initialized!")
	type = "[type]"
	if(istype(colors)) // It's the color list format
		colors = colors.Join()
	else if(!istext(colors))
		CRASH("Invalid colors were given to `GetColoredIconByType()`: [colors]")
#ifdef USE_RUSTG_ICONFORGE_GAGS
	var/uid = "[replacetext(replacetext(type, "/datum/greyscale_config/", ""), "/", "-")]-[colors]"
	var/cached_file = gags_cache[uid]
	if(cached_file)
		return cached_file
	var/output_path = "tmp/gags/gags-[uid].dmi"
	var/iconforge_output = rustg_iconforge_gags(type, colors, output_path)
	// Handle errors from IconForge
	if(iconforge_output != "OK")
		CRASH(iconforge_output)
	// We'll just explicitly do fcopy_rsc here, so the game doesn't have to do it again later from the cached file.
	var/rsc_gags_icon = fcopy_rsc(file(output_path))
	gags_cache[uid] = rsc_gags_icon
	return rsc_gags_icon
#else
	return configurations[type].Generate(colors)
#endif

/datum/controller/subsystem/processing/greyscale/proc/GetColoredIconByTypeUniversalIcon(type, list/colors, target_icon_state)
	if(!ispath(type, /datum/greyscale_config))
		CRASH("An invalid greyscale configuration was given to `GetColoredIconByTypeUniversalIcon()`: [type]")
	type = "[type]"
	if(istype(colors)) // It's the color list format
		colors = colors.Join()
	else if(!istext(colors))
		CRASH("Invalid colors were given to `GetColoredIconByTypeUniversalIcon()`: [colors]")
	return configurations[type].GenerateUniversalIcon(colors, target_icon_state)

/datum/controller/subsystem/processing/greyscale/proc/ParseColorString(color_string)
	. = list()
	var/list/split_colors = splittext(color_string, "#")
	for(var/color in 2 to length(split_colors))
		. += "#[split_colors[color]]"

/datum/controller/subsystem/processing/greyscale/proc/ExportMapPreviews()
	// Put subtypes before their parent or the parent file will take all the generated icons
	var/static/list/types_that_get_their_own_file = list(
		"turfs" = /turf, // None of these yet but it's harmless to be prepared
		"mobs" = /mob, // Ditto
		"clothing/accessory" = /obj/item/clothing/accessory,
		"clothing/head/beret" = /obj/item/clothing/head/beret,
		"clothing/head/_head" = /obj/item/clothing/head,
		"clothing/mask" = /obj/item/clothing/mask,
		"clothing/neck" = /obj/item/clothing/neck,
		"clothing/shoes" = /obj/item/clothing/shoes,
		"clothing/suit/costume" = /obj/item/clothing/suit/costume,
		"clothing/suit/_suit" = /obj/item/clothing/suit,
		"clothing/under/color" = /obj/item/clothing/under/color,
		"clothing/under/costume" = /obj/item/clothing/under/costume,
		"clothing/under/dress" = /obj/item/clothing/under/dress,
		"clothing/under/_under" = /obj/item/clothing/under,
		"clothing/_clothing" = /obj/item/clothing,
		"items/encryptionkey" = /obj/item/encryptionkey,
		"items/pda" = /obj/item/modular_computer/pda,
		"items/_item" = /obj/item,
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
	for(var/atom/atom_type as anything in typesof(atom_typepath))
		if(type_blacklist && type_blacklist[atom_type])
			continue
		handled_types[atom_type] = TRUE
		var/greyscale_config = atom_type::greyscale_config
		var/greyscale_colors = atom_type::greyscale_colors
		if(!greyscale_config || !greyscale_colors || atom_type::flags_1 & NO_NEW_GAGS_PREVIEW_1)
			continue
	#ifdef CHECK_SPRITESHEET_ICON_VALIDITY
		var/icon/map_icon = icon(GetColoredIconByType(greyscale_config, greyscale_colors))
		if((map_icon.Height() > 32) || (map_icon.Width() > 32)) // No large icons, use icon_preview and icon_preview_state instead.
			stack_trace("GAGS configuration is trying to generate a map preview graphic for '[atom_type]', which has a large icon. This is not suppoorted; implement icon_preview instead.")
			continue
		if(!(atom_type::post_init_icon_state in map_icon.IconStates()))
			stack_trace("GAGS configuration missing icon state needed to generate map preview graphic for '[atom_type]'. Make sure the right greyscale_config is set up.")
			continue
		map_icon = icon(map_icon, atom_type::post_init_icon_state)
		icons["[atom_type]"] = map_icon
	#else // will be updated to use iconforge's new .dmi spritesheet generation instead
		var/icon/map_icon = icon(GetColoredIconByType(greyscale_config, greyscale_colors))
		map_icon = icon(map_icon, atom_type::post_init_icon_state)
		icons["[atom_type]"] = map_icon
	#endif

	var/icon/holder = icon('icons/testing/greyscale_error.dmi')
	for(var/state in icons)
		holder.Insert(icons[state], state)

	var/filepath = "icons/map_icons/[filename].dmi"
#ifdef UNIT_TESTS
	var/old_md5 = rustg_hash_file(RUSTG_HASH_MD5, filepath)
#endif
	fcopy(holder, filepath)
#ifdef UNIT_TESTS
	var/new_md5 = rustg_hash_file(RUSTG_HASH_MD5, filepath)
	if(old_md5 != new_md5)
		stack_trace("Generated map icons were different than what is currently saved. If you see this in a CI run it means you need to run the game once through initialization and commit the resulting files in 'icons/map_icons/'")
#endif
	return handled_types

#undef USE_RUSTG_ICONFORGE_GAGS
#ifdef CHECK_SPRITESHEET_ICON_VALIDITY
	#undef CHECK_SPRITESHEET_ICON_VALIDITY
#endif
