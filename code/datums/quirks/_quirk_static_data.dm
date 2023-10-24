GLOBAL_LIST_INIT_TYPED(all_quirk_static_data, /datum/quirk_static_data, generate_quirk_static_data())

/// Constructs [GLOB.all_quirk_static_data] by iterating through a typecache of pregen data, ignoring abstract types, and instantiating the rest.
/proc/generate_quirk_static_data()
	RETURN_TYPE(/list/datum/quirk_static_data)

	var/list/datum/quirk_static_data/all_pregen_data = list()

	for (var/datum/quirk_static_data/iterated_path as anything in typecacheof(path = /datum/quirk_static_data, ignore_root_path = TRUE))
		if (initial(iterated_path.abstract_type) == iterated_path)
			continue

		if (!isnull(all_pregen_data[initial(iterated_path.associated_typepath)]))
			stack_trace("pre-existing pregen data for [initial(iterated_path.associated_typepath)] when [iterated_path] was being considered: [all_pregen_data[initial(iterated_path.associated_typepath)]]. \
						this is definitely a bug, and is probably because one of the two pregen data have the wrong quirk typepath defined. [iterated_path] will not be instantiated")

			continue

		var/datum/quirk_static_data/pregen_data = new iterated_path
		all_pregen_data[pregen_data.associated_typepath] = pregen_data

	return all_pregen_data

/datum/quirk_static_data
	var/abstract_type = /datum/quirk_static_data

	var/datum/quirk/associated_typepath

	/// A lazylist of preference datum typepaths.
	var/list/datum/preference/customization_options

/datum/quirk_static_data/New()
	. = ..()

	if (abstract_type != type)
		if (isnull(associated_typepath))
			stack_trace("associated_typepath null - please set it! occured on: [src.type]")

/datum/quirk_static_data/proc/get_customization_data(datum/preferences/prefs, mob/user)
	RETURN_TYPE(/list)

	var/list/customization_data = list()

	for (var/datum/preference/pref_type as anything in customization_options)
		var/datum/preference/pref_instance = GLOB.preference_entries[pref_type]
		if (isnull(pref_instance))
			stack_trace("get_customization_data was called before instantiation of [pref_type]!")
			continue // it might have been a fluke

		var/value = prefs.read_preference(pref_type.type)
		var/data = pref_instance.compile_ui_data(user, value)

		customization_data[pref_instance.savefile_key] = data

	return customization_data

/datum/quirk_static_data/Destroy(force, ...)
	var/error_message = "[src], a singleton wound static data instance, was destroyed! This should not happen!"
	if (force)
		error_message += " NOTE: This Destroy() was called with force == TRUE. This instance will be deleted and replaced with a new one."
	stack_trace(error_message)

	if (!force)
		return QDEL_HINT_LETMELIVE

	. = ..()

	GLOB.all_quirk_static_data[associated_typepath] = new src.type //recover
