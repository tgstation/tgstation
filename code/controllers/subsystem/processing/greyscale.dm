/// Disable to use builtin DM-based generation.
/// IconForge is 250x times faster but requires storing the icons in tmp/ and may result in higher asset transport.
/// Note that the builtin GAGS editor still uses the 'legacy' generation to allow for debugging.
/// IconForge also does not support the color matrix layer type or the 'or' blend_mode, however both are currently unused.
#define USE_RUSTG_ICONFORGE_GAGS

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

#undef USE_RUSTG_ICONFORGE_GAGS
