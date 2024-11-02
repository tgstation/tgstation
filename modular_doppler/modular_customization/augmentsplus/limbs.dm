/mob/living/carbon/human/dummy/wipe_state()
	. = ..()
	// Gets rid of prosthetics and stuff that may have been added
	for(var/obj/item/bodypart/whatever as anything in bodyparts)
		whatever.change_exempt_flags &= ~BP_BLOCK_CHANGE_SPECIES
	dna?.species?.replace_body(src)

/atom/movable/screen/map_view/char_preview/limb_viewer

/atom/movable/screen/map_view/char_preview/limb_viewer/update_body()
	if (isnull(body))
		create_body()
	else
		body.wipe_state()

	preferences.apply_prefs_to(body, TRUE) // no clothes, no quirks, no nothing.
	appearance = body.appearance

/atom/movable/screen/map_view/char_preview/limb_viewer/Destroy()
	/// See [/atom/movable/screen/map_view/char_preview/loadout] for why this is needed.
	preferences = null
	return ..()

/datum/preference_middleware/limbs
	action_delegations = list(
		"select_path" = PROC_REF(action_select),
		"deselect_path" = PROC_REF(action_deselect),
	)

	/// The preview dummy
	VAR_FINAL/atom/movable/screen/map_view/char_preview/limb_viewer/character_preview_view
	/// Records all paths that were selected the last time we updated the preview icon
	/// This is done because we have to use getflat icon (very laggy) rather than byondui
	/// as byondUI doesn't really allow layering other UI elements such as SVGs above it
	VAR_FINAL/list/paths_on_last_ui_update
	/// Caches the last icon we generated, see above
	VAR_FINAL/cached_icon

/datum/preference_middleware/limbs/Destroy(force, ...)
	QDEL_NULL(character_preview_view)
	return ..()

/datum/preference_middleware/limbs/on_new_character(mob/user)
	paths_on_last_ui_update = null
	cached_icon = null
	character_preview_view?.update_body()

/// Initialize our character dummy.
/datum/preference_middleware/limbs/proc/create_character_preview_view(mob/user)
	character_preview_view = new(null, preferences)
	character_preview_view.update_body()
	return character_preview_view

/datum/preference_middleware/limbs/proc/action_select(list/params, mob/user)
	var/obj/item/path_selecting = text2path(params["path_to_use"])
	var/datum/limb_option_datum/selecting_datum = GLOB.limb_loadout_options[path_selecting]
	if(isnull(selecting_datum))
		return TRUE

	var/list/selected_paths = preferences.read_preference(/datum/preference/limbs)
	LAZYSET(selected_paths, selecting_datum.pref_list_slot, path_selecting)
	preferences.update_preference(GLOB.preference_entries[/datum/preference/limbs], selected_paths)
	character_preview_view.update_body()
	return TRUE

/datum/preference_middleware/limbs/proc/action_deselect(list/params, mob/user)
	var/obj/item/path_deselecting = text2path(params["path_to_use"])
	var/datum/limb_option_datum/deselecting_datum = GLOB.limb_loadout_options[path_deselecting]
	if(isnull(deselecting_datum))
		return TRUE

	var/list/selected_paths = preferences.read_preference(/datum/preference/limbs)
	LAZYREMOVE(selected_paths, deselecting_datum.pref_list_slot)
	preferences.update_preference(GLOB.preference_entries[/datum/preference/limbs], selected_paths)
	character_preview_view.update_body()
	return TRUE

/datum/preference_middleware/limbs/get_ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/body_zones),
	)

/datum/preference_middleware/limbs/get_ui_data(mob/user)
	var/list/data = list()
	var/list/selected_paths = preferences.read_preference(/datum/preference/limbs)
	data["selected_limbs"] = flatten_list(selected_paths)

	if(isnull(character_preview_view))
		character_preview_view = create_character_preview_view(user)
	if(isnull(cached_icon) || length(selected_paths ^ paths_on_last_ui_update) >= 1)
		paths_on_last_ui_update = LAZYLISTDUPLICATE(selected_paths)
		cached_icon = icon2base64(getFlatIcon(character_preview_view.body, no_anim = TRUE))

	data["preview_flat_icon"] = cached_icon
	return data

/datum/preference_middleware/limbs/get_ui_static_data(mob/user)
	var/list/data = list()

	// This should all be moved to constant data when I figure out how tee hee
	var/static/list/limbs_data
	if(isnull(limbs_data))
		var/list/raw_data = list(
			BODY_ZONE_HEAD = list(),
			BODY_ZONE_CHEST = list(),
			BODY_ZONE_L_ARM = list(),
			BODY_ZONE_R_ARM = list(),
			BODY_ZONE_L_LEG = list(),
			BODY_ZONE_R_LEG = list(),
		)

		for(var/limb_type in GLOB.limb_loadout_options)
			var/datum/limb_option_datum/limb_datum = GLOB.limb_loadout_options[limb_type]
			var/limb_zone = limb_datum.ui_zone

			if(isnull(limb_zone) || !islist(raw_data[limb_zone]))
				stack_trace("Invalid limb zone found in limb datums: [limb_zone || "null"]. (From: [limb_type])")
				continue

			var/list/limb_data = list(
				"name" = limb_datum.name,
				"tooltip" = limb_datum.desc,
				"path" = limb_type,
			)

			UNTYPED_LIST_ADD(raw_data[limb_zone], limb_data)

		limbs_data = list()
		for(var/raw_list_key in raw_data)
			var/list/ui_formatted_raw_list = list(
				"category_name" = raw_list_key,
				"category_data" = raw_data[raw_list_key],
			)
			UNTYPED_LIST_ADD(limbs_data, ui_formatted_raw_list)


	data["limbs"] = limbs_data
	return data
