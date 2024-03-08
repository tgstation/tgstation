/**
 * A component that stores colors for use by painting-related items like spraycans or palettes
 * which can be accessed through a radial menu by right clicking the item while it's held by the user mob.
 * Right-clicking a color will open a color input prompt to edit it. Left clicking will instead select it
 * and call set_painting_tool_color() on the parent for more specific object behavior.
 */
/datum/component/palette
	/*
	 * A list that stores a selection of colors.
	 * The number of available spaces is defined by the available_space arg of Initialize()
	 */
	var/list/colors = list()
	/*
	 * The currently selected color. This should be synced with that of the parent item, so please
	 * use the item/proc/painting_tool_pick_color proc for color
	 */
	var/selected_color
	/// The persistent radial menu for this component.
	var/datum/radial_menu/persistent/color_picker_menu
	/// The radial menu choice datums are stored here as a microop to avoid generating new ones every time the menu is opened or updated.
	var/list/datum/radial_menu_choice/menu_choices

/datum/component/palette/Initialize(available_space, selected_color)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	if(!isnum(available_space) || available_space < 1) /// This component means nothing if there's no space for colors
		stack_trace("palette component initialized without a proper value for the available_space arg")
		return COMPONENT_INCOMPATIBLE

	for(var/index in 1 to available_space)
		colors += "#ffffff"

	src.colors = colors
	src.selected_color = selected_color || "#ffffff"

	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF_SECONDARY, PROC_REF(on_attack_self_secondary))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_PAINTING_TOOL_SET_COLOR, PROC_REF(on_painting_tool_set_color))
	RegisterSignal(parent, COMSIG_PAINTING_TOOL_GET_ADDITIONAL_DATA, PROC_REF(get_palette_data))
	RegisterSignal(parent, COMSIG_PAINTING_TOOL_PALETTE_COLOR_CHANGED, PROC_REF(palette_color_changed))

/datum/component/palette/Destroy()
	QDEL_NULL(color_picker_menu)
	QDEL_LIST(menu_choices)
	UnregisterSignal(parent, list(COMSIG_ITEM_ATTACK_SELF_SECONDARY, COMSIG_ATOM_EXAMINE,
		COMSIG_ITEM_DROPPED, COMSIG_PAINTING_TOOL_SET_COLOR, COMSIG_PAINTING_TOOL_GET_ADDITIONAL_DATA))
	return ..()

/datum/component/palette/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	examine_list += span_notice("<b>Right-Click</b> this item while it's in your active hand to open/close its color picker menu.")
	examine_list += span_notice("In the color picker, <b>Left-Click</b> a color button to pick it or <b>Right-Click</b> to edit it.")

/datum/component/palette/proc/on_attack_self_secondary(datum/source, mob/user)
	SIGNAL_HANDLER

	if(!color_picker_menu)
		INVOKE_ASYNC(src, PROC_REF(open_radial_menu), user)
	else
		close_radial_menu()

	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/palette/proc/open_radial_menu(mob/user)
	var/list/choices = build_radial_list()

	color_picker_menu = show_radial_menu_persistent(user, parent, choices, select_proc = CALLBACK(src, PROC_REF(choice_selected), user), tooltips = TRUE, radial_slice_icon = "palette_bg")

	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(close_radial_menu))

/datum/component/palette/proc/build_radial_list()
	var/radial_list = list()
	LAZYSETLEN(menu_choices, length(colors))
	for(var/index in 1 to length(colors))
		var/hexcolor = colors[index]
		var/datum/radial_menu_choice/option = menu_choices[index]
		if(!option)
			option = new
		var/icon_state_to_use = hexcolor == selected_color ? "palette_selected" : "palette_element"
		var/image/element = image(icon = 'icons/hud/radial.dmi', icon_state = icon_state_to_use)
		element.color = hexcolor
		option.image = element
		// We want only the name/tooltip to show the hexcolor to avoid having multiple choices with same ids (identical colors).
		option.name = hexcolor
		radial_list["[index]"] = option
	return radial_list

/datum/component/palette/proc/close_radial_menu()
	SIGNAL_HANDLER

	QDEL_NULL(color_picker_menu)
	UnregisterSignal(parent, COMSIG_ITEM_DROPPED)

/datum/component/palette/proc/update_radial_list()
	if(QDELETED(color_picker_menu))
		return
	var/list/choices = build_radial_list()
	color_picker_menu.change_choices(choices, tooltips = TRUE, keep_same_page = TRUE)

/datum/component/palette/proc/choice_selected(mob/user, choice, params)
	if(!choice || IS_DEAD_OR_INCAP(user)) // center button or incapacitated but still holding on the item.
		close_radial_menu()
		return
	var/is_right_clicking = LAZYACCESS(params2list(params), RIGHT_CLICK)
	var/index = text2num(choice)
	if(is_right_clicking)
		var/chosen_color = input(user, "Pick new color", "[parent]", colors[index]) as color|null
		if(chosen_color && !QDELETED(src) && !IS_DEAD_OR_INCAP(user) && user.is_holding(parent))
			colors[index] = chosen_color
		update_radial_list()
	else
		var/obj/item/parent_item = parent
		parent_item.set_painting_tool_color(colors[index]) // This will send a signal back to us. See below.

/datum/component/palette/proc/on_painting_tool_set_color(datum/source, chosen_color)
	SIGNAL_HANDLER

	selected_color = chosen_color
	update_radial_list()

/datum/component/palette/proc/get_palette_data(datum/source, data)
	SIGNAL_HANDLER
	var/list/painting_data = list()
	for(var/hexcolor in colors)
		painting_data += list(list(
			"color" = hexcolor,
			"is_selected" = hexcolor == selected_color
		))
	data["paint_tool_palette"] = painting_data

/datum/component/palette/proc/palette_color_changed(datum/source, chosen_color, index)
	SIGNAL_HANDLER

	var/was_selected_color = selected_color == colors[index]
	colors[index] = chosen_color
	if(was_selected_color)
		var/obj/item/parent_item = parent
		parent_item.set_painting_tool_color(chosen_color)
	else
		update_radial_list()
