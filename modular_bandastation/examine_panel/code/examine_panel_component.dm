/datum/component/examine_panel
	dupe_mode = COMPONENT_DUPE_UNIQUE
	/// Mob that the examine panel belongs to.
	var/mob/living/holder
	/// The screen containing the appearance of the mob
	var/atom/movable/screen/map_view/examine_panel_screen/examine_panel_screen
	/// Flavor text
	var/flavor_text

/datum/component/examine_panel/Initialize(use_prefs = FALSE)
	. = ..()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	holder = parent
	if(!use_prefs)
		return
	if(iscarbon(parent))
		flavor_text = holder.client?.prefs.read_preference(/datum/preference/text/flavor_text)
	if(issilicon(parent))
		flavor_text = holder.client?.prefs.read_preference(/datum/preference/text/silicon_flavor_text)

/datum/component/examine_panel/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

/datum/component/examine_panel/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_EXAMINE)

/datum/component/examine_panel/proc/on_examine(mob/living/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(iscarbon(source))
		examine_list += get_carbon_flavor_text(source)
	if(issilicon(source))
		examine_list += get_silicon_flavor_text(source)

/datum/component/examine_panel/proc/get_carbon_flavor_text(mob/living/carbon/source)
	var/flavor_text_link
	/// The first 1-FLAVOR_PREVIEW_LIMIT characters in the mob's "flavor_text" DNA feature. FLAVOR_PREVIEW_LIMIT is defined in flavor_defines.dm.
	var/preview_text = copytext_char(flavor_text, 1, FLAVOR_PREVIEW_LIMIT)
	// What examine_tgui.dm uses to determine if flavor text appears as "Obscured".
	var/face_obscured = (source.wear_mask && (source.wear_mask.flags_inv & HIDEFACE)) || (source.head && (source.head.flags_inv & HIDEFACE))

	if (!(face_obscured))
		flavor_text_link = span_notice("[preview_text]... <a href='?src=[REF(src)];lookup_info=open_examine_panel'>Look closer?</a>")
	else
		flavor_text_link = span_notice("<a href='?src=[REF(src)];lookup_info=open_examine_panel'>Examine closely...</a>")
	if (flavor_text_link)
		return flavor_text_link

/datum/component/examine_panel/proc/get_silicon_flavor_text(mob/living/silicon/source)
	var/flavor_text_link
	/// The first 1-FLAVOR_PREVIEW_LIMIT characters in the mob's client's silicon_flavor_text preference datum. FLAVOR_PREVIEW_LIMIT is defined in flavor_defines.dm.
	var/preview_text = copytext_char(flavor_text, 1, FLAVOR_PREVIEW_LIMIT)

	flavor_text_link = span_notice("[preview_text]... <a href='?src=[REF(src)];lookup_info=open_examine_panel'>Look closer?</a>")

	if (flavor_text_link)
		return flavor_text_link

/datum/component/examine_panel/Topic(href, list/href_list)
	. = ..()

	if(href_list["lookup_info"])
		switch(href_list["lookup_info"])
			if("open_examine_panel")
				ui_interact(usr)

/datum/component/examine_panel/ui_state(mob/user)
	return GLOB.always_state

/datum/component/examine_panel/ui_close(mob/user)
	user.client.clear_map(examine_panel_screen.assigned_map)

/atom/movable/screen/map_view/examine_panel_screen
	name = "examine panel screen"

/datum/component/examine_panel/ui_interact(mob/user, datum/tgui/ui)
	if(!examine_panel_screen)
		examine_panel_screen = new
		examine_panel_screen.name = "screen"
		examine_panel_screen.assigned_map = "examine_panel_[REF(holder)]_map"
		examine_panel_screen.del_on_map_removal = FALSE
		examine_panel_screen.screen_loc = "[examine_panel_screen.assigned_map]:1,1"

	var/mutable_appearance/current_mob_appearance = new(holder)
	current_mob_appearance.setDir(SOUTH)
	current_mob_appearance.transform = matrix() // We reset their rotation, in case they're lying down.

	// In case they're pixel-shifted, we bring 'em back!
	current_mob_appearance.pixel_x = 0
	current_mob_appearance.pixel_y = 0

	examine_panel_screen.cut_overlays()
	examine_panel_screen.add_overlay(current_mob_appearance)

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		examine_panel_screen.display_to(user)
		user.client.register_map_obj(examine_panel_screen)
		ui = new(user, src, "ExaminePanel")
		ui.open()


/datum/component/examine_panel/ui_data(mob/user)
	var/list/data = list()

	var/tgui_flavor_text = flavor_text
	var/obscured

	if(ishuman(parent))
		var/mob/living/carbon/human/holder_human = parent
		obscured = (holder_human.wear_mask && (holder_human.wear_mask.flags_inv & HIDEFACE)) || (holder_human.head && (holder_human.head.flags_inv & HIDEFACE))
		tgui_flavor_text = obscured ? "Obscured" : flavor_text

	var/name = obscured ? "Unknown" : holder

	data["obscured"] = obscured ? TRUE : FALSE
	data["character_name"] = name
	data["assigned_map"] = examine_panel_screen.assigned_map
	data["flavor_text"] = tgui_flavor_text
	return data
