/obj/machinery/plumbing/ooze_compressor
	var/image/hover_appearance
	var/datum/atom_hud/alternate_appearance/basic/ooze_compressor/hover_popup

/obj/machinery/plumbing/ooze_compressor/Destroy()
	QDEL_NULL(hover_popup)
	return ..()

/obj/machinery/plumbing/ooze_compressor/MouseEntered(location, control, params)
	. = ..()
	if(!QDELETED(usr) && anchored)
		manage_hud_as_needed()
		hover_popup?.show_to(usr)

/obj/machinery/plumbing/ooze_compressor/MouseExited(location, control, params)
	. = ..()
	if(!QDELETED(usr) && !QDELETED(hover_popup))
		hover_popup.hide_from(usr)
		manage_hud_as_needed(cleanup = TRUE)

/obj/machinery/plumbing/ooze_compressor/set_anchored(anchorvalue)
	. = ..()
	if(!anchored)
		manage_hud_as_needed()

/obj/machinery/plumbing/ooze_compressor/proc/manage_hud_as_needed(cleanup = FALSE)
	if(!anchored || (cleanup && !QDELETED(hover_popup) && !length(hover_popup.hud_users_all_z_levels)))
		// don't bother keeping the hud around if it isn't needed
		QDEL_NULL(hover_popup)
		return
	setup_hud()

/obj/machinery/plumbing/ooze_compressor/proc/setup_hud()
	// delete old hud if it exists and collect a list of its users
	var/list/mob/old_users
	if(!QDELETED(hover_popup))
		old_users = hover_popup.hud_users_all_z_levels.Copy()
		QDEL_NULL(hover_popup)

	if(!length(GLOB.compressor_recipe_previews)) // we can't initialize this normally bc it will shit itself if initialized early
		GLOB.compressor_recipe_previews = create_compressor_previews()

	// setup new hover appearance
	if(current_recipe)
		hover_appearance = image(GLOB.compressor_recipe_previews[current_recipe.type], loc = src, layer = CHAT_LAYER)
		hover_appearance.add_filter("extract_outline", 1, outline_filter(size = 1, color = COLOR_WHITE))
		hover_appearance.pixel_y = 10
	else
		hover_appearance = image(loc = src, layer = CHAT_LAYER)
		hover_appearance.pixel_y = 18
	SET_PLANE_EXPLICIT(hover_appearance, HUD_PLANE, src)
	hover_appearance.plane = HUD_PLANE
	hover_appearance.appearance_flags = RESET_COLOR

	// now setup the actual hud
	hover_popup = add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/ooze_compressor, "ooze_compressor", hover_appearance)
	// and the cooldown maptext
	refresh_info_maptext()

	for(var/mob/old_user as anything in old_users)
		if(QDELETED(old_user))
			continue
		hover_popup.show_to(old_user)

/obj/machinery/plumbing/ooze_compressor/proc/refresh_info_maptext()
	if(!hover_popup)
		return
	if(!hover_popup.info_maptext)
		hover_popup.info_maptext = image(loc = src, layer = CHAT_LAYER + 0.1)
		SET_PLANE_EXPLICIT(hover_popup.info_maptext, HUD_PLANE, src)
		hover_popup.info_maptext.plane = HUD_PLANE
		hover_popup.info_maptext.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA | KEEP_APART
		hover_popup.info_maptext.maptext_height = world.icon_size / 2
		hover_popup.info_maptext.maptext_y = 4
	var/maptext
	if(compressing)
		hover_popup.info_maptext.maptext_width = world.icon_size * 2
		hover_popup.info_maptext.maptext_x = -(world.icon_size / 2)
		maptext = "compressing..."
	else
		hover_popup.info_maptext.maptext_width = world.icon_size
		hover_popup.info_maptext.maptext_x = 0
		maptext = current_recipe ? "[get_progress()]%" : "inactive"
	hover_popup.info_maptext.maptext = MAPTEXT_TINY_UNICODE("<span style='text-align: center'>[maptext]</span>")
	hover_popup.give_info()

/obj/machinery/plumbing/ooze_compressor/proc/get_progress()
	if(!current_recipe || compressing)
		return 0
	var/current = 0
	var/needed = 0
	for(var/datum/reagent/reagent as anything in current_recipe.required_oozes)
		needed += current_recipe.required_oozes[reagent] || 0
		for(var/datum/reagent/listed_reagent as anything in reagents.reagent_list)
			if(listed_reagent.type != reagent)
				continue
			current += listed_reagent.volume
	return clamp(round((current / needed) * 100, 1), 0, 100)

/datum/atom_hud/alternate_appearance/basic/ooze_compressor
	var/image/info_maptext

/datum/atom_hud/alternate_appearance/basic/ooze_compressor/show_to(mob/new_viewer)
	. = ..()
	if(info_maptext && !QDELETED(new_viewer) && !QDELETED(new_viewer.client))
		new_viewer.client.images |= info_maptext

/datum/atom_hud/alternate_appearance/basic/ooze_compressor/hide_from(mob/former_viewer, absolute)
	. = ..()
	if(info_maptext && !QDELETED(former_viewer) && !QDELETED(former_viewer.client))
		former_viewer.client.images -= info_maptext

/datum/atom_hud/alternate_appearance/basic/ooze_compressor/proc/give_info()
	if(!info_maptext)
		return
	for(var/mob/user as anything in hud_users_all_z_levels)
		if(QDELETED(user) || QDELETED(user.client))
			continue
		user.client.images |= info_maptext

/datum/atom_hud/alternate_appearance/basic/ooze_compressor/proc/take_cooldowns()
	if(!info_maptext)
		return
	for(var/mob/user as anything in hud_users_all_z_levels)
		if(QDELETED(user) || QDELETED(user.client))
			continue
		user.client.images -= info_maptext
