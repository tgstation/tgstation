GLOBAL_LIST_EMPTY(preferences_datums)

/datum/preferences
	var/client/parent
	//doohickeys for savefiles
	var/path
	var/default_slot = 1 //Holder so it doesn't default to slot 1, rather the last one used
	var/max_save_slots = 3

	//non-preference stuff
	var/muted = 0
	var/last_ip
	var/last_id

	//game-preferences
	var/lastchangelog = "" //Saved changlog filesize to detect if there was a change

	//Antag preferences
	var/list/be_special = list() //Special role selection

	var/buttons_locked = FALSE
	var/hotkeys = TRUE

	///Limit preference on the size of the message. Requires chat_on_map to have effect.
	var/max_chat_length = CHAT_MESSAGE_MAX_LENGTH
	///Whether non-mob messages will be displayed, such as machine vendor announcements. Requires chat_on_map to have effect. Boolean.
	var/see_chat_non_mob = TRUE

	/// Custom keybindings. Map of keybind names to keyboard inputs.
	/// For example, by default would have "swap_hands" -> list("X")
	var/list/key_bindings = list()

	/// Cached list of keybindings, mapping keys to actions.
	/// For example, by default would have "X" -> list("swap_hands")
	var/list/key_bindings_by_key = list()

	var/tgui_fancy = TRUE
	var/tgui_lock = FALSE
	var/toggles = TOGGLES_DEFAULT
	var/db_flags
	var/chat_toggles = TOGGLES_DEFAULT_CHAT
	var/ghost_form = "ghost"
	var/ghost_hud = 1
	var/inquisitive_ghost = 1
	var/pda_color = "#808000"

	//character preferences
	var/slot_randomized //keeps track of round-to-round randomization of the character slot, prevents overwriting
	var/underwear_color = "000" //underwear color
	var/skin_tone = "caucasian1" //Skin color
	var/list/features = list("mcolor" = "FFF", "ethcolor" = "9c3030", "tail_lizard" = "Smooth", "tail_human" = "None", "snout" = "Round", "horns" = "None", "ears" = "None", "wings" = "None", "frills" = "None", "spines" = "None", "body_markings" = "None", "legs" = "Normal Legs", "moth_wings" = "Plain", "moth_antennae" = "Plain", "moth_markings" = "None")
	var/list/randomise = list(
		RANDOM_UNDERWEAR = TRUE,
		RANDOM_UNDERWEAR_COLOR = TRUE,
		RANDOM_UNDERSHIRT = TRUE,
		RANDOM_SOCKS = TRUE,
		RANDOM_BACKPACK = TRUE,
		RANDOM_JUMPSUIT_STYLE = TRUE,
		RANDOM_HAIRSTYLE = TRUE,
		RANDOM_HAIR_COLOR = TRUE,
		RANDOM_FACIAL_HAIRSTYLE = TRUE,
		RANDOM_FACIAL_HAIR_COLOR = TRUE,
		RANDOM_SKIN_TONE = TRUE,
		RANDOM_EYE_COLOR = TRUE,
		)
	var/phobia = "spiders"

	var/list/custom_names = list()
	var/preferred_ai_core_display = "Blue"
	var/prefered_security_department = SEC_DEPT_NONE

	//Quirk list
	var/list/all_quirks = list()

	//Job preferences 2.0 - indexed by job title , no key or value implies never
	var/list/job_preferences = list()

		// Want randomjob if preferences already filled - Donkie
	var/joblessrole = BERANDOMJOB  //defaults to 1 for fewer assistants

	/// The current window, PREFERENCE_TAB_* in [`code/__DEFINES/preferences.dm`]
	var/current_window = PREFERENCE_TAB_CHARACTER_PREFERENCES

	var/unlock_content = 0

	var/list/ignoring = list()

	var/clientfps = -1

	///Do we show screentips, if so, how big?
	var/screentip_pref = TRUE
	///Do we show item hover outlines?
	var/itemoutline_pref = TRUE

	///Should we automatically fit the viewport?
	var/auto_fit_viewport = FALSE
	///Should we be in the widescreen mode set by the config?
	var/widescreenpref = TRUE
	///The playtime_reward_cloak variable can be set to TRUE from the prefs menu only once the user has gained over 5K playtime hours. If true, it allows the user to get a cool looking roundstart cloak.
	var/playtime_reward_cloak = FALSE

	var/list/exp = list()
	var/list/menuoptions

	var/action_buttons_screen_locs = list()

	///Someone thought we were nice! We get a little heart in OOC until we join the server past the below time (we can keep it until the end of the round otherwise)
	var/hearted
	///If we have a hearted commendations, we honor it every time the player loads preferences until this time has been passed
	var/hearted_until
	/// Agendered spessmen can choose whether to have a male or female bodytype
	var/body_type
	/// If we have persistent scars enabled
	var/persistent_scars = TRUE
	///What outfit typepaths we've favorited in the SelectEquipment menu
	var/list/favorite_outfits = list()

	/// A preview of the current character
	var/atom/movable/screen/character_preview_view/character_preview_view

	/// Cached list of generated preferences (return value of [`/datum/preference/get_choices`]).
	var/list/generated_preference_values = list()

	/// A list of instantiated middleware
	var/list/datum/preference_middleware/middleware = list()

	/// A cache of preference entries to values.
	/// Used to avoid expensive READ_FILE every time a preference is retrieved.
	var/value_cache = list()

/datum/preferences/Destroy(force, ...)
	QDEL_NULL(character_preview_view)
	QDEL_LIST(middleware)
	value_cache = null
	return ..()

/datum/preferences/New(client/C)
	parent = C

	for (var/middleware_type in subtypesof(/datum/preference_middleware))
		middleware += new middleware_type(src)

	for(var/custom_name_id in GLOB.preferences_custom_names)
		custom_names[custom_name_id] = get_default_name(custom_name_id)

	if(istype(C))
		if(!IsGuestKey(C.key))
			load_path(C.ckey)
			unlock_content = C.IsByondMember()
			if(unlock_content)
				max_save_slots = 8
	var/loaded_preferences_successfully = load_preferences()
	if(loaded_preferences_successfully)
		if(load_character())
			return
	//we couldn't load character data so just randomize the character appearance + name
	randomise_appearance_prefs() //let's create a random character then - rather than a fat, bald and naked man.

	// give them default keybinds and update their movement keys
	key_bindings = deepCopyList(GLOB.default_hotkeys)
	key_bindings_by_key = get_key_bindings_by_key(key_bindings)

	C?.set_macros()

	if(!loaded_preferences_successfully)
		save_preferences()
	save_character() //let's save this new random character so it doesn't keep generating new ones.
	menuoptions = list()

/datum/preferences/proc/ShowChoices(mob/user)
	if(!user || !user.client)
		return
	// MOTHBLOCKS TODO: ShowChoices
	CRASH("NYI: ShowChoices")

/datum/preferences/ui_interact(mob/user, datum/tgui/ui)
	// If you leave and come back, re-register the character preview
	if (!isnull(character_preview_view) && !(character_preview_view in user.client?.screen))
		user.client?.register_map_obj(character_preview_view)

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PreferencesMenu")
		ui.open()

/datum/preferences/ui_state(mob/user)
	return GLOB.always_state

// Without this, a hacker would be able to edit other people's preferences if
// they had the ref to Topic to.
/datum/preferences/ui_status(mob/user, datum/ui_state/state)
	return user.client == parent ? UI_INTERACTIVE : UI_CLOSE

/datum/preferences/ui_data(mob/user)
	var/list/data = list()

	if (isnull(character_preview_view))
		character_preview_view = create_character_preview_view(user)
	else if (character_preview_view.client != parent)
		// The client re-logged, and doing this when they log back in doesn't seem to properly
		// carry emissives.
		character_preview_view.register_to_client(parent)

	// MOTHBLOCKS TODO: Try to diff these as much as possible, and only send what is needed.
	// Some of these, like job preferences, can be pretty beefy.
	data["character_profiles"] = create_character_profiles()
	data["character_preferences"] = compile_character_preferences(user)

	// MOTHBLOCKS TODO: Job bans/yet to be unlocked jobs
	data["job_preferences"] = job_preferences

	data["active_name"] = read_preference(/datum/preference/name/real_name)

	data["name_to_use"] = "real_name" // MOTHBLOCKS TODO: Change to AI name, clown name, etc depending on circumstances

	for (var/datum/preference_middleware/preference_middleware as anything in middleware)
		data += preference_middleware.get_ui_data(user)

	return data

/datum/preferences/ui_static_data(mob/user)
	var/list/data = list()

	data["window"] = current_window

	data["character_preview_view"] = character_preview_view.assigned_map

	data["generated_preference_values"] = generated_preference_values
	data["overflow_role"] = SSjob.overflow_role

	var/list/selected_antags = list()

	for (var/antag in be_special)
		selected_antags += serialize_antag_name(antag)

	// MOTHBLOCKS TODO: Only send when needed, just like generated_preference_values
	// MOTHBLOCKS TODO: Send banned/not old enough antags
	data["selected_antags"] = selected_antags

	for (var/datum/preference_middleware/preference_middleware as anything in middleware)
		data += preference_middleware.get_ui_static_data(user)

	return data

/datum/preferences/ui_assets(mob/user)
	var/list/assets = list(
		get_asset_datum(/datum/asset/spritesheet/antagonists),
		get_asset_datum(/datum/asset/spritesheet/preferences),
		get_asset_datum(/datum/asset/json/preferences),
	)

	for (var/datum/preference_middleware/preference_middleware as anything in middleware)
		assets += preference_middleware.get_ui_assets()

	return assets

/datum/preferences/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return

	var/mob/user = usr

	switch (action)
		if ("change_slot")
			// SAFETY: `load_character` performs sanitization the slot number
			if (!load_character(params["slot"]))
				apply_character_randomization_prefs()
				save_character()

			character_preview_view.update_body()

			return TRUE
		if ("request_values")
			var/requested_preference_key = params["preference"]

			var/datum/preference/choiced/requested_preference = GLOB.preference_entries_by_key[requested_preference_key]
			if (!istype(requested_preference))
				return FALSE

			if (isnull(generated_preference_values[requested_preference_key]))
				generated_preference_values[requested_preference_key] = generate_preference_values(requested_preference)
				update_static_data(user, ui)

			return TRUE
		if ("rotate")
			character_preview_view.dir = turn(character_preview_view.dir, -90)

			return TRUE
		if ("set_preference")
			var/requested_preference_key = params["preference"]
			var/value = params["value"]

			var/datum/preference/requested_preference = GLOB.preference_entries_by_key[requested_preference_key]
			if (isnull(requested_preference))
				return FALSE

			// SAFETY: `write_preference` performs validation checks
			if (!write_preference(requested_preference, value))
				return FALSE

			// Preferences could theoretically perform granular updates rather than
			// recreating the whole thing, but this would complicate the preference
			// API while adding the potential for drift.
			character_preview_view.update_body()

			if (requested_preference.savefile_identifier == PREFERENCE_PLAYER)
				requested_preference.apply_to_client(parent, read_preference(requested_preference.type))

			return TRUE
		if ("set_color_preference")
			var/requested_preference_key = params["preference"]

			var/datum/preference/requested_preference = GLOB.preference_entries_by_key[requested_preference_key]
			if (isnull(requested_preference))
				return FALSE

			if (!istype(requested_preference, /datum/preference/color) \
				&& !istype(requested_preference, /datum/preference/color_legacy) \
			)
				return FALSE

			// Yielding
			var/new_color = input(
				usr,
				"Select new color",
				null,
				read_preference(requested_preference.type) || COLOR_WHITE,
			) as color | null

			if (new_color)
				if (!write_preference(requested_preference, new_color))
					return FALSE

				if (requested_preference.savefile_identifier == PREFERENCE_PLAYER)
					requested_preference.apply_to_client(parent, new_color)

				return TRUE
			else
				return FALSE
		if ("set_job_preference")
			var/job_title = params["job"]
			var/level = params["level"]

			if (level != null && level != JP_LOW && level != JP_MEDIUM && level != JP_HIGH)
				return FALSE

			var/datum/job/job = SSjob.GetJob(job_title)

			if (job.faction != FACTION_STATION)
				return FALSE

			return set_job_preference_level(job, level)
		if ("set_antags")
			var/sent_antags = params["antags"]
			var/toggled = params["toggled"]

			var/antags = list()

			var/serialized_antags = get_serialized_antags()

			for (var/sent_antag in sent_antags)
				var/special_role = serialized_antags[sent_antag]
				if (!special_role)
					continue

				antags += special_role

			// MOTHBLOCKS TODO: Check antag ban(?) and age requirement
			// Marked (?) because antag bans are handled in all ruleset code
			if (toggled)
				be_special |= antags
			else
				be_special -= antags

			return TRUE

	for (var/datum/preference_middleware/preference_middleware as anything in middleware)
		var/delegation = preference_middleware.action_delegations[action]
		if (!isnull(delegation))
			return call(preference_middleware, delegation)(params, usr)

	return FALSE

/datum/preferences/ui_close(mob/user)
	save_preferences()
	QDEL_NULL(character_preview_view)

/datum/preferences/proc/create_character_preview_view(mob/user)
	character_preview_view = new(null, src, user.client)
	character_preview_view.update_body()
	character_preview_view.register_to_client(user.client)

	return character_preview_view

// MOTHBLOCKS TODO: Asset file?
/datum/preferences/proc/generate_preference_values(datum/preference/choiced/preference)
	var/list/values
	var/list/choices = preference.get_choices_serialized()

	if (preference.should_generate_icons)
		values = list()
		for (var/value in choices)
			values[value] = preference.get_spritesheet_key(value)
	else
		values = choices

	return values

/datum/preferences/proc/get_serialized_antags()
	var/list/serialized_antags

	if (isnull(serialized_antags))
		serialized_antags = list()

		for (var/special_role in GLOB.special_roles)
			serialized_antags[serialize_antag_name(special_role)] = special_role

	return serialized_antags

/datum/preferences/proc/compile_character_preferences(mob/user)
	var/list/preferences = list()

	for (var/datum/preference/preference as anything in get_preferences_in_priority_order())
		LAZYINITLIST(preferences[preference.category])

		var/value = read_preference(preference.type)
		var/data = preference.compile_ui_data(user, value)

		preferences[preference.category][preference.savefile_key] = data

	return preferences

// This is necessary because you can open the set preferences menu before
// the atoms SS is done loading.
INITIALIZE_IMMEDIATE(/atom/movable/screen/character_preview_view)

/// A preview of a character for use in the preferences menu
/atom/movable/screen/character_preview_view
	name = "character_preview"
	del_on_map_removal = FALSE
	layer = GAME_PLANE
	plane = GAME_PLANE

	/// The body that is displayed
	var/mob/living/carbon/human/dummy/body

	/// The preferences this refers to
	var/datum/preferences/preferences

	var/list/plane_masters = list()

	/// The client that is watching this view
	var/client/client

/atom/movable/screen/character_preview_view/Initialize(mapload, datum/preferences/preferences, client/client)
	. = ..()

	assigned_map = "character_preview_[REF(src)]"
	set_position(1, 1)

	src.preferences = preferences

/atom/movable/screen/character_preview_view/Destroy()
	. = ..()

	QDEL_NULL(body)

	for (var/plane_master in plane_masters)
		client?.screen -= plane_master
		qdel(plane_master)

	client?.clear_map(assigned_map)

	client = null
	plane_masters = null
	preferences = null

/// Updates the currently displayed body
/atom/movable/screen/character_preview_view/proc/update_body()
	create_body()
	preferences.update_preview_icon(body)
	appearance = body.appearance

/atom/movable/screen/character_preview_view/proc/create_body()
	QDEL_NULL(body)

	body = new

	// Without this, it doesn't show up in the menu
	body.appearance_flags &= ~KEEP_TOGETHER

/// Registers the relevant map objects to a client
/atom/movable/screen/character_preview_view/proc/register_to_client(client/client)
	QDEL_LIST(plane_masters)

	src.client = client

	if (!client)
		return

	for (var/plane_master_type in subtypesof(/atom/movable/screen/plane_master))
		var/atom/movable/screen/plane_master/plane_master = new plane_master_type
		plane_master.screen_loc = "[assigned_map]:CENTER"
		client?.screen |= plane_master

		plane_masters += plane_master

	client?.register_map_obj(src)

/datum/preferences/proc/create_character_profiles()
	var/list/profiles = list()

	var/savefile/savefile = new(path)
	for (var/index in 1 to max_save_slots)
		savefile.cd = "/character[index]"

		var/name
		READ_FILE(savefile["real_name"], name)

		if (isnull(name))
			profiles += null
			continue

		profiles += list(list(
			"name" = name,
		))

	return profiles

/datum/preferences/proc/set_job_preference_level(datum/job/job, level)
	if (!job)
		return FALSE

	if (level == JP_HIGH) // to high
		//Set all other high to medium
		for(var/j in job_preferences)
			if(job_preferences[j] == JP_HIGH)
				job_preferences[j] = JP_MEDIUM
				//technically break here

	if (isnull(job_preferences[job.title]))
		job_preferences[job.title] = level
	else
		job_preferences -= job.title

	return TRUE

/datum/preferences/proc/GetQuirkBalance()
	var/bal = 0
	for(var/V in all_quirks)
		var/datum/quirk/T = SSquirks.quirks[V]
		bal -= initial(T.value)
	return bal

/datum/preferences/proc/GetPositiveQuirkCount()
	. = 0
	for(var/q in all_quirks)
		if(SSquirks.quirk_points[q] > 0)
			.++

/datum/preferences/proc/validate_quirks()
	if(GetQuirkBalance() < 0)
		all_quirks = list()

/// Sanitization checks to be performed before using these preferences.
/datum/preferences/proc/sanitize_chosen_prefs()
	// MOTHBLOCKS TODO: sanitize_chosen_prefs
	// Most likely remove this in favor of prefs themselves sanitizing

	// if(!(pref_species.id in GLOB.roundstart_races) && !(pref_species.id in (CONFIG_GET(keyed_list/roundstart_no_hard_check))))
	// 	pref_species = new /datum/species/human
	// 	save_character()

	// if(CONFIG_GET(flag/humans_need_surnames) && (pref_species.id == SPECIES_HUMAN))
	// 	var/firstspace = findtext(real_name, " ")
	// 	var/name_length = length(real_name)
	// 	if(!firstspace) //we need a surname
	// 		real_name += " [pick(GLOB.last_names)]"
	// 	else if(firstspace == name_length)
	// 		real_name += "[pick(GLOB.last_names)]"

/// Sanitizes the preferences, applies the randomization prefs, and then applies the preference to the human mob.
/datum/preferences/proc/safe_transfer_prefs_to(mob/living/carbon/human/character, icon_updates = TRUE, is_antag = FALSE)
	apply_character_randomization_prefs(is_antag)
	sanitize_chosen_prefs()
	apply_prefs_to(character, icon_updates)

/// Applies the given preferences to a human mob.
/datum/preferences/proc/apply_prefs_to(mob/living/carbon/human/character, icon_updates = TRUE)
	// MOTHBLOCKS TODO: Body type
	// if(gender == MALE || gender == FEMALE)
	// 	character.body_type = gender
	// else
	// 	character.body_type = body_type

	character.skin_tone = skin_tone
	character.underwear_color = underwear_color

	// MOTHBLOCKS TODO: Put this on name/real_name/apply
	// if(roundstart_checks)
	// 	if(CONFIG_GET(flag/humans_need_surnames) && (read_preference(/datum/preference/choiced/species) == /datum/species/human))
	// 		var/firstspace = findtext(real_name, " ")
	// 		var/name_length = length(real_name)
	// 		if(!firstspace) //we need a surname
	// 			real_name += " [pick(GLOB.last_names)]"
	// 		else if(firstspace == name_length)
	// 			real_name += "[pick(GLOB.last_names)]"

	character.dna.features = features.Copy()

	for (var/datum/preference/preference in get_preferences_in_priority_order())
		if (preference.savefile_identifier != PREFERENCE_CHARACTER)
			continue

		preference.apply_to_human(character, read_preference(preference.type))

	character.dna.real_name = character.real_name

	// MOTHBLOCKS TODO: What is all this for? If it doesn't include moth wings, then what is it?
	// Is it the same problem with cloning moths not giving wings? Oversight?

	// if(species.mutant_bodyparts["tail_lizard"])
	// 	character.dna.species.mutant_bodyparts["tail_lizard"] = species.mutant_bodyparts["tail_lizard"]
	// if(species.mutant_bodyparts["spines"])
	// 	character.dna.species.mutant_bodyparts["spines"] = species.mutant_bodyparts["spines"]

	if(icon_updates)
		character.update_body()
		character.update_hair()
		character.update_body_parts()


/// Returns whether the parent mob should have the random hardcore settings enabled. Assumes it has a mind.
/datum/preferences/proc/should_be_random_hardcore(datum/job/job, datum/mind/mind)
	if(!randomise[RANDOM_HARDCORE])
		return FALSE
	if(job.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND) //No command staff
		return FALSE
	for(var/datum/antagonist/antag as anything in mind.antag_datums)
		if(antag.get_team()) //No team antags
			return FALSE
	return TRUE


/datum/preferences/proc/get_default_name(name_id)
	switch(name_id)
		if("human")
			return random_unique_name()
		if("ai")
			return pick(GLOB.ai_names)
		if("cyborg")
			return DEFAULT_CYBORG_NAME
		if("clown")
			return pick(GLOB.clown_names)
		if("mime")
			return pick(GLOB.mime_names)
		if("religion")
			return pick(GLOB.religion_names)
		if("deity")
			return DEFAULT_DEITY
		if("bible")
			return DEFAULT_BIBLE
	return random_unique_name()

/datum/preferences/proc/ask_for_custom_name(mob/user,name_id)
	var/namedata = GLOB.preferences_custom_names[name_id]
	if(!namedata)
		return

	var/raw_name = input(user, "Choose your character's [namedata["qdesc"]]:","Character Preference") as text|null
	if(!raw_name)
		if(namedata["allow_null"])
			custom_names[name_id] = get_default_name(name_id)
		else
			return
	else
		var/sanitized_name = reject_bad_name(raw_name,namedata["allow_numbers"])
		if(!sanitized_name)
			to_chat(user, "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, [namedata["allow_numbers"] ? "0-9, " : ""]-, ' and . It must not contain any words restricted by IC chat and name filters.</font>")
			return
		else
			custom_names[name_id] = sanitized_name

/// Inverts the key_bindings list such that it can be used for key_bindings_by_key
/datum/preferences/proc/get_key_bindings_by_key(list/key_bindings)
	var/list/output = list()

	for (var/action in key_bindings)
		for (var/key in key_bindings[action])
			LAZYADD(output[key], action)

	return output

/// Serializes an antag name to be used for preferences UI
/proc/serialize_antag_name(antag_name)
	// These are sent through CSS, so they need to be safe to use as class names.
	return lowertext(sanitize_css_class_name(antag_name))
