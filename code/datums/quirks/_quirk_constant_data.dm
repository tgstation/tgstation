GLOBAL_LIST_INIT_TYPED(all_quirk_constant_data, /datum/quirk_constant_data, generate_quirk_constant_data())

/// Constructs [GLOB.all_quirk_constant_data] by iterating through a typecache of pregen data, ignoring abstract types, and instantiating the rest.
/proc/generate_quirk_constant_data()
	RETURN_TYPE(/list/datum/quirk_constant_data)

	var/list/datum/quirk_constant_data/all_constant_data = list()

	for (var/datum/quirk_constant_data/iterated_path as anything in typecacheof(path = /datum/quirk_constant_data, ignore_root_path = TRUE))
		if (initial(iterated_path.abstract_type) == iterated_path)
			continue

		if (!isnull(all_constant_data[initial(iterated_path.associated_typepath)]))
			stack_trace("pre-existing pregen data for [initial(iterated_path.associated_typepath)] when [iterated_path] was being considered: [all_constant_data[initial(iterated_path.associated_typepath)]]. \
				this is definitely a bug, and is probably because one of the two pregen data have the wrong quirk typepath defined. [iterated_path] will not be instantiated")

			continue

		var/datum/quirk_constant_data/pregen_data = new iterated_path
		all_constant_data[pregen_data.associated_typepath] = pregen_data

	return all_constant_data

/// A singleton datum representing constant data and procs used by quirks.
/datum/quirk_constant_data
	/// Abstract in OOP terms. If this is our type, we will not be instantiated.
	abstract_type = /datum/quirk_constant_data

	/// The typepath of the quirk we will be associated with in the global list. This is what we represent.
	var/datum/quirk/associated_typepath

	/// A lazylist of preference datum typepaths. Any character pref put in here will be rendered in the quirks page under a dropdown.
	var/list/datum/preference/customization_options

/datum/quirk_constant_data/New()
	. = ..()

	ASSERT(abstract_type != type && !isnull(associated_typepath), "associated_typepath null - please set it! occurred on: [src.type]")

/// Returns a list of savefile_keys derived from the preference typepaths in [customization_options]. Used in quirks middleware to supply the preferences to render.
/datum/quirk_constant_data/proc/get_customization_data()
	RETURN_TYPE(/list)

	var/list/customization_data = list()

	for (var/datum/preference/pref_type as anything in customization_options)
		var/datum/preference/pref_instance = GLOB.preference_entries[pref_type]
		if (isnull(pref_instance))
			stack_trace("get_customization_data was called before instantiation of [pref_type]!")
			continue // just in case its a fluke and its only this one that's not instantiated, we'll check the other pref entries

		customization_data += pref_instance.savefile_key

	return customization_data

/// Is this quirk customizable? If true, a button will appear within the quirk's description box in the quirks page, and upon clicking it,
/// will open a customization menu for the quirk.
/datum/quirk_constant_data/proc/is_customizable()
	return LAZYLEN(customization_options) > 0

/datum/quirk_constant_data/Destroy(force)
	var/error_message = "[src], a singleton quirk constant data instance, was destroyed! This should not happen!"
	if (force)
		error_message += " NOTE: This Destroy() was called with force == TRUE. This instance will be deleted and replaced with a new one."
	stack_trace(error_message)

	if (!force)
		return QDEL_HINT_LETMELIVE

	. = ..()

	GLOB.all_quirk_constant_data[associated_typepath] = new src.type //recover
