#define MAX_MUTANT_ROWS 4

/datum/preferences
	/// Loadout prefs. Assoc list of [typepaths] to [associated list of item info].
	var/list/loadout_list
	/// Associative list, keyed by language typepath, pointing to LANGUAGE_UNDERSTOOD, or LANGUAGE_SPOKEN, for whether we understand or speak the language
	var/list/languages = list()
	/// List of chosen augmentations. It's an associative list with key name of the slot, pointing to a typepath of an augment define
	var/augments = list()
	/// List of chosen preferred styles for limb replacements
	var/augment_limb_styles = list()
	/// Which augment slot we currently have chosen, this is for UI display
	var/chosen_augment_slot
	/// Has to include all information that extra organs from mutant bodyparts would need. (so far only genitals now)
	var/list/features = MANDATORY_FEATURE_LIST
	/// A list containing all of our mutant bodparts
	var/list/list/mutant_bodyparts = list()
	/// A list of all bodymarkings
	var/list/list/body_markings = list()

	/// Will the person see accessories not meant for their species to choose from
	var/mismatched_customization = FALSE

	/// Allows the user to freely color his body markings and mutant parts.
	var/allow_advanced_colors = FALSE

	/// Preference of how the preview should show the character.
	var/preview_pref = PREVIEW_PREF_JOB

	var/needs_update = TRUE

	var/arousal_preview = AROUSAL_NONE

	var/datum/species/pref_species

	//BACKGROUND STUFF
	var/general_record = ""
	var/security_record = ""
	var/medical_record = ""

	var/background_info = ""
	var/exploitable_info = ""

	///Whether the user wants to see body size being shown in the preview
	var/show_body_size = FALSE

	///Alternative job titles stored in preferences. Assoc list, ie. alt_job_titles["Scientist"] = "Cytologist"
	var/list/alt_job_titles = list()

	//Determines if the player has undergone TGUI preferences migration, if so, this will prevent constant loading.
	var/tgui_prefs_migration = TRUE

/datum/preferences/proc/species_updated(species_type)
	all_quirks = list()
	//Reset cultural stuff
	try_get_common_language()
	save_character()

/datum/preferences/proc/print_bodypart_change_line(key)
	var/acc_name = mutant_bodyparts[key][MUTANT_INDEX_NAME]
	var/shown_colors = 0
	var/datum/sprite_accessory/SA = GLOB.sprite_accessories[key][acc_name]
	var/dat = ""
	if(SA.color_src == USE_MATRIXED_COLORS)
		shown_colors = 3
	else if (SA.color_src == USE_ONE_COLOR)
		shown_colors = 1
	if((allow_advanced_colors || SA.always_color_customizable) && shown_colors)
		dat += "<a href='?src=[REF(src)];key=[key];preference=reset_color;task=change_bodypart'>R</a>"
	dat += "<a href='?src=[REF(src)];key=[key];preference=change_name;task=change_bodypart'>[acc_name]</a>"
	if(allow_advanced_colors || SA.always_color_customizable)
		if(shown_colors)
			dat += "<BR>"
			var/list/colorlist = mutant_bodyparts[key][MUTANT_INDEX_COLOR_LIST]
			for(var/i in 1 to shown_colors)
				dat += " <a href='?src=[REF(src)];key=[key];color_index=[i];preference=change_color;task=change_bodypart'><span class='color_holder_box' style='background-color:["#[colorlist[i]]"]'></span></a>"
	return dat

/datum/preferences/proc/reset_colors()
	for(var/key in mutant_bodyparts)
		var/datum/sprite_accessory/SA = GLOB.sprite_accessories[key][mutant_bodyparts[key][MUTANT_INDEX_NAME]]
		if(SA.always_color_customizable)
			continue
		mutant_bodyparts[key][MUTANT_INDEX_COLOR_LIST] = SA.get_default_color(features, pref_species)

	for(var/zone in body_markings)
		var/list/bml = body_markings[zone]
		for(var/key in bml)
			var/datum/body_marking/BM = GLOB.body_markings[key]
			bml[key] = BM.get_default_color(features, pref_species)

/datum/preferences/proc/get_linguistic_points()
	var/points
	points = (QUIRK_LINGUIST in all_quirks) ? LINGUISTIC_POINTS_LINGUIST : LINGUISTIC_POINTS_DEFAULT
	for(var/langpath in languages)
		points -= languages[langpath]
	return points

/datum/preferences/proc/get_optional_languages()
	var/list/lang_list = list()
	for(var/lang in pref_species.learnable_languages)
		lang_list[lang] = TRUE
	return lang_list

/datum/preferences/proc/get_available_languages()
	var/list/lang_list = list()
	for(var/lang_key in get_optional_languages())
		lang_list[lang_key] = TRUE
	return lang_list

/datum/preferences/proc/can_buy_language(language_path, level)
	var/points = get_linguistic_points()
	if(languages[language_path])
		points += languages[language_path]
	if(points < level)
		return FALSE
	return TRUE

//Whenever we switch a species, we'll try to get common if we can to not confuse anyone
/datum/preferences/proc/try_get_common_language()
	var/list/langs = get_available_languages()
	if(langs[/datum/language/common])
		languages[/datum/language/common] = LANGUAGE_SPOKEN


/datum/preferences/proc/validate_species_parts()
	var/list/target_bodyparts = pref_species.default_mutant_bodyparts.Copy()

	//Remove all "extra" accessories
	for(var/key in mutant_bodyparts)
		if(!GLOB.sprite_accessories[key]) //That accessory no longer exists, remove it
			mutant_bodyparts -= key
			continue
		if(!pref_species.default_mutant_bodyparts[key])
			mutant_bodyparts -= key
			continue
		if(!GLOB.sprite_accessories[key][mutant_bodyparts[key][MUTANT_INDEX_NAME]]) //The individual accessory no longer exists
			mutant_bodyparts[key][MUTANT_INDEX_NAME] = pref_species.default_mutant_bodyparts[key]
		validate_color_keys_for_part(key) //Validate the color count of each accessory that wasnt removed

	//Add any missing accessories
	for(var/key in target_bodyparts)
		if(!mutant_bodyparts[key])
			var/datum/sprite_accessory/SA
			if(target_bodyparts[key] == ACC_RANDOM)
				SA = random_accessory_of_key_for_species(key, pref_species)
			else
				SA = GLOB.sprite_accessories[key][target_bodyparts[key]]
			var/final_list = list()
			final_list[MUTANT_INDEX_NAME] = SA.name
			final_list[MUTANT_INDEX_COLOR_LIST] = SA.get_default_color(features, pref_species)
			mutant_bodyparts[key] = final_list

	if(!allow_advanced_colors)
		reset_colors()

/datum/preferences/proc/validate_color_keys_for_part(key)
	var/datum/sprite_accessory/SA = GLOB.sprite_accessories[key][mutant_bodyparts[key][MUTANT_INDEX_NAME]]
	var/list/colorlist = mutant_bodyparts[key][MUTANT_INDEX_COLOR_LIST]
	if(SA.color_src == USE_MATRIXED_COLORS && colorlist.len != 3)
		mutant_bodyparts[key][MUTANT_INDEX_COLOR_LIST] = SA.get_default_color(features, pref_species)
	else if (SA.color_src == USE_ONE_COLOR && colorlist.len != 1)
		mutant_bodyparts[key][MUTANT_INDEX_COLOR_LIST] = SA.get_default_color(features, pref_species)

/datum/preferences/proc/CanBuyAugment(datum/augment_item/target_aug, datum/augment_item/current_aug)
	//Check biotypes
	if(!(pref_species.inherent_biotypes & target_aug.allowed_biotypes))
		return
	var/quirk_points = GetQuirkBalance()
	var/leverage = 0
	if(current_aug)
		leverage += current_aug.cost
	if((quirk_points+leverage)>= target_aug.cost)
		return TRUE
	else
		return FALSE

