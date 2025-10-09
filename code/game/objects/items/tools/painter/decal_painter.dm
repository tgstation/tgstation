/obj/item/airlock_painter/decal
	name = "decal painter"
	desc = "An airlock painter, reprogrammed to use a different style of paint in order to apply decals for floor tiles as well, in addition to repainting doors. Decals break when the floor tiles are removed."
	desc_controls = "Alt-Click to remove the ink cartridge."
	icon = 'icons/obj/devices/tool.dmi'
	icon_state = "decal_sprayer"
	inhand_icon_state = "decal_sprayer"
	custom_materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 0.5, /datum/material/glass = SMALL_MATERIAL_AMOUNT * 0.5)
	initial_ink_type = /obj/item/toner/large
	/// The current direction of the decal being printed
	VAR_PRIVATE/selected_dir = SOUTH
	/// The current color of the decal being printed.
	VAR_PRIVATE/selected_color = "yellow"
	/// The current base icon state of the decal being printed.
	VAR_PRIVATE/selected_decal_icon_state = "warningline"
	/// Current custom color
	VAR_PRIVATE/selected_custom_color

	/// Current active decal category. Reference to a global singleton
	VAR_PRIVATE/datum/paintable_decal_category/current_category

/obj/item/airlock_painter/decal/Initialize(mapload)
	. = ..()
	set_category(GLOB.paintable_decals[1])

/obj/item/airlock_painter/decal/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(isfloorturf(interacting_with) && use_paint(user))
		paint_floor(interacting_with)
		return ITEM_INTERACT_SUCCESS
	return NONE

/**
 * Actually add current decal to the floor.
 *
 * Responsible for actually adding the element to the turf for maximum flexibility.area
 * Can be overridden for different decal behaviors.
 * Arguments:
 * * target - The turf being painted to
*/
/obj/item/airlock_painter/decal/proc/paint_floor(turf/open/floor/target)
	var/list/decal_data = current_category.get_decal_info(
		state = selected_decal_icon_state,
		color = selected_color,
		dir = selected_dir,
	)

	target.AddElement( \
		/datum/element/decal, \
		_icon = 'icons/turf/decals.dmi', \
		_icon_state = decal_data[DECAL_INFO_ICON_STATE], \
		_dir = decal_data[DECAL_INFO_DIR], \
		_alpha = decal_data[DECAL_INFO_ALPHA], \
		_color = decal_data[DECAL_INFO_COLOR], \
		_cleanable = FALSE, \
	)

/obj/item/airlock_painter/decal/proc/set_category(datum/paintable_decal_category/category)
	current_category = category
	selected_color = category.possible_colors?[category.possible_colors[1]]
	selected_decal_icon_state = category.get_ui_data()["decal_list"][1]["icon_state"]
	return TRUE

/obj/item/airlock_painter/decal/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DecalPainter", name)
		ui.open()

/obj/item/airlock_painter/decal/ui_assets(mob/user)
	. = ..()
	. += get_asset_datum(/datum/asset/spritesheet_batched/decals)

/obj/item/airlock_painter/decal/ui_static_data(mob/user)
	var/list/data = list()

	data["categories"] = list()
	for(var/datum/paintable_decal_category/category as anything in GLOB.paintable_decals)
		var/list/category_data = category.get_ui_data()
		data["categories"] += list(list(
			"category" = category.category,
			"decal_list" = category_data["decal_list"],
			"color_list" = category_data["color_list"],
			"dir_list" = category_data["dir_list"],
		))

	var/datum/asset/spritesheet_batched/icon_assets = get_asset_datum(/datum/asset/spritesheet_batched/decals)
	data["icon_prefix"] = "[icon_assets.name]32x32"

	return data

/obj/item/airlock_painter/decal/ui_data(mob/user)
	var/list/data = list()
	data["current_decal"] = selected_decal_icon_state
	data["current_color"] = selected_color
	data["current_dir"] = selected_dir
	data["current_custom_color"] = selected_custom_color
	data["active_category"] = current_category.category
	return data

/obj/item/airlock_painter/decal/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("select_category")
			var/new_category = params["category"]
			for(var/datum/paintable_decal_category/category as anything in GLOB.paintable_decals)
				if(category.category != new_category)
					continue

				set_category(category)
				return TRUE

		if("select_decal")
			var/new_state = params["decal"]
			var/new_dir = text2num(params["dir"])
			if(current_category.is_state_valid(new_state))
				selected_decal_icon_state = new_state
			if(current_category.is_dir_valid(new_dir))
				selected_dir = new_dir
			return TRUE

		if("select_color")
			var/new_color = params["color"]
			if(current_category.is_color_valid(new_color))
				selected_color = new_color
			return TRUE

		if("pick_custom_color")
			if("Custom" in current_category.possible_colors)
				pick_painting_tool_color(usr, selected_custom_color)
			return TRUE

/obj/item/airlock_painter/decal/set_painting_tool_color(chosen_color)
	. = ..()
	selected_custom_color = chosen_color
	selected_color = chosen_color

/obj/item/airlock_painter/decal/debug
	name = "extreme decal painter"
	icon_state = "decal_sprayer_ex"
	initial_ink_type = /obj/item/toner/extreme

/obj/item/airlock_painter/decal/cyborg
	icon_state = "decal_sprayer_borg"
	initial_ink_type = /obj/item/toner/infinite

/obj/item/airlock_painter/decal/cyborg/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	. = ..()
	var/mob/living/silicon/robot/cyborg = user
	if(!iscyborg(user) || !cyborg.cell)
		return
	if(cyborg.cell && cyborg.cell.charge > 0)
		cyborg.cell.use(0.025 * STANDARD_CELL_CHARGE)
	else if(cyborg.cell.charge <= 0)
		balloon_alert(user, "not enough energy!")
		return

/obj/item/airlock_painter/decal/cyborg/click_alt(mob/user)
	return CLICK_ACTION_BLOCKING
