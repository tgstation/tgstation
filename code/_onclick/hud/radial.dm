GLOBAL_LIST_EMPTY(radial_menus)

/atom/movable/screen/radial
	icon = 'icons/hud/radial.dmi'
	plane = ABOVE_HUD_PLANE
	vis_flags = VIS_INHERIT_PLANE
	var/click_on_hover = FALSE
	var/datum/radial_menu/parent

/atom/movable/screen/radial/proc/set_parent(new_value)
	if(parent)
		UnregisterSignal(parent, COMSIG_QDELETING)
	parent = new_value
	if(parent)
		RegisterSignal(parent, COMSIG_QDELETING, PROC_REF(handle_parent_del))

/atom/movable/screen/radial/proc/handle_parent_del()
	SIGNAL_HANDLER
	set_parent(null)

/atom/movable/screen/radial/slice
	icon_state = "radial_slice"
	var/choice
	var/next_page = FALSE
	var/tooltips = FALSE
	var/tooltip_theme

/atom/movable/screen/radial/slice/set_parent(new_value)
	. = ..()
	if(parent)
		icon_state = parent.radial_slice_icon

/atom/movable/screen/radial/slice/MouseEntered(location, control, params)
	. = ..()
	if(next_page || !parent)
		icon_state = "radial_slice_focus"
	else
		icon_state = "[parent.radial_slice_icon]_focus"
	if(tooltips)
		openToolTip(usr, src, params, title = name, theme = tooltip_theme)
	if (click_on_hover && !isnull(usr) && !isnull(parent))
		Click(location, control, params)

/atom/movable/screen/radial/slice/MouseExited(location, control, params)
	. = ..()
	if(next_page || !parent)
		icon_state = "radial_slice"
	else
		icon_state = parent.radial_slice_icon
	if(tooltips)
		closeToolTip(usr)

/atom/movable/screen/radial/slice/Click(location, control, params)
	if(usr.client == parent.current_user)
		if(next_page)
			parent.next_page()
		else
			parent.element_chosen(choice, usr, params)

/atom/movable/screen/radial/center
	name = "Close Menu"
	icon_state = "radial_center"

/atom/movable/screen/radial/center/MouseEntered(location, control, params)
	. = ..()
	icon_state = "radial_center_focus"

/atom/movable/screen/radial/center/MouseExited(location, control, params)
	. = ..()
	icon_state = "radial_center"

/atom/movable/screen/radial/center/Click(location, control, params)
	if(usr.client == parent.current_user)
		parent.finished = TRUE

/datum/radial_menu
	/// List of choice IDs
	var/list/choices = list()

	/// choice_id -> icon
	var/list/choices_icons = list()

	/// choice_id -> choice
	var/list/choices_values = list()

	/// choice_id -> /datum/radial_menu_choice
	var/list/choice_datums = list()

	var/list/page_data = list() //list of choices per page


	var/selected_choice
	var/list/atom/movable/screen/elements = list()
	var/atom/movable/screen/radial/center/close_button
	var/client/current_user
	var/atom/anchor
	var/image/menu_holder
	var/finished = FALSE
	var/datum/callback/custom_check_callback
	var/next_check = 0
	var/check_delay = DEFAULT_CHECK_DELAY

	var/radius = 32
	var/starting_angle = 0
	var/ending_angle = 360
	var/zone = 360
	var/min_angle = 45 //Defaults are setup for this value, if you want to make the menu more dense these will need changes.
	var/max_elements
	var/pages = 1
	var/current_page = 1

	var/hudfix_method = TRUE //TRUE to change anchor to user, FALSE to shift by py_shift
	var/py_shift = 0
	var/button_animation_flags = BUTTON_SLIDE_IN

	///A replacement icon state for the generic radial slice bg icon. Doesn't affect the next page nor the center buttons
	var/radial_slice_icon

//If we swap to vis_contens inventory these will need a redo
/datum/radial_menu/proc/check_screen_border(mob/user)
	var/atom/movable/AM = anchor
	if(!istype(AM) || !AM.screen_loc)
		return
	if(AM in user.client.screen)
		if(hudfix_method)
			anchor = user
		else
			py_shift = 32
			restrict_to_dir(NORTH) //I was going to parse screen loc here but that's more effort than it's worth.
	else if(hudfix_method && AM.loc)
		anchor = get_atom_on_turf(anchor)

//Sets defaults
//These assume 45 deg min_angle
/datum/radial_menu/proc/restrict_to_dir(dir)
	switch(dir)
		if(NORTH)
			starting_angle = 270
			ending_angle = 135
		if(SOUTH)
			starting_angle = 90
			ending_angle = 315
		if(EAST)
			starting_angle = 0
			ending_angle = 225
		if(WEST)
			starting_angle = 180
			ending_angle = 45

/datum/radial_menu/proc/setup_menu(use_tooltips, set_page = 1, click_on_hover = FALSE)
	if(ending_angle > starting_angle)
		zone = ending_angle - starting_angle
	else
		zone = 360 - starting_angle + ending_angle

	max_elements = round(zone / min_angle)
	var/paged = max_elements < choices.len
	if(elements.len < max_elements)
		var/elements_to_add = max_elements - elements.len
		for(var/i in 1 to elements_to_add) //Create all elements
			var/atom/movable/screen/radial/slice/new_element = new /atom/movable/screen/radial/slice
			new_element.tooltips = use_tooltips
			new_element.set_parent(src)
			if(button_animation_flags & BUTTON_FADE_IN)
				new_element.alpha = 0
			elements += new_element

	var/page = 1
	page_data = list(null)
	var/list/current = list()
	var/list/choices_left = choices.Copy()
	while(choices_left.len)
		if(current.len == max_elements)
			page_data[page] = current
			page++
			page_data.len++
			current = list()
		if(paged && current.len == max_elements - 1)
			current += NEXT_PAGE_ID
			continue
		else
			current += popleft(choices_left)
	if(paged && current.len < max_elements)
		current += NEXT_PAGE_ID

	page_data[page] = current
	pages = page
	current_page = clamp(set_page, 1, pages)
	update_screen_objects(button_animation_flags, click_on_hover)

/datum/radial_menu/proc/update_screen_objects(anim_flag = NONE, click_on_hover = FALSE)
	var/list/page_choices = page_data[current_page]
	var/angle_per_element = round(zone / page_choices.len)
	for(var/i in 1 to elements.len)
		var/atom/movable/screen/radial/element = elements[i]
		var/angle = WRAP(starting_angle + (i - 1) * angle_per_element,0,360)
		if(i > page_choices.len)
			HideElement(element)
			element.click_on_hover = FALSE
		else
			SetElement(element,page_choices[i],angle,anim_flag = anim_flag,anim_order = i)
			// Only activate click on hover after the animation plays
			if (!click_on_hover)
				continue
			if (anim_flag)
				addtimer(VARSET_CALLBACK(element, click_on_hover, TRUE), i * 0.5)
			else
				element.click_on_hover = TRUE

/datum/radial_menu/proc/HideElement(atom/movable/screen/radial/slice/E)
	E.cut_overlays()
	E.vis_contents.Cut()
	E.alpha = 0
	E.name = "None"
	E.maptext = null
	E.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	E.choice = null
	E.next_page = FALSE

/datum/radial_menu/proc/SetElement(atom/movable/screen/radial/slice/E, choice_id, angle, anim_flag, anim_order)
	//Position
	var/py = round(cos(angle) * radius) + py_shift
	var/px = round(sin(angle) * radius)
	if(anim_flag & BUTTON_SLIDE_IN)
		var/timing = anim_order * 0.5
		var/matrix/starting = matrix()
		starting.Scale(0.1,0.1)
		E.transform = starting
		var/matrix/TM = matrix()
		animate(E,pixel_x = px,pixel_y = py, transform = TM, time = timing)
	else
		E.pixel_y = py
		E.pixel_x = px

	if(anim_flag & BUTTON_FADE_IN)
		animate(E, alpha = 255, time = 0.15 SECONDS, easing = CUBIC_EASING|EASE_OUT)
	else
		E.alpha = 255

	E.mouse_opacity = MOUSE_OPACITY_ICON
	E.cut_overlays()
	E.vis_contents.Cut()
	if(choice_id == NEXT_PAGE_ID)
		E.name = "Next Page"
		E.next_page = TRUE
		E.icon_state = "radial_slice" // Resets the bg icon state to the default for next page buttons.
		E.add_overlay("radial_next")
	else
		//This isn't granted to exist, so use the ?. operator for conditionals that use it.
		var/datum/radial_menu_choice/choice_datum = choice_datums[choice_id]
		if(choice_datum?.name)
			E.name = choice_datum.name
		else if(istext(choices_values[choice_id]))
			E.name = choices_values[choice_id]
		else if(ispath(choices_values[choice_id],/atom))
			var/atom/A = choices_values[choice_id]
			E.name = initial(A.name)
		else
			var/atom/movable/AM = choices_values[choice_id] //Movables only
			E.name = AM.name
		E.choice = choice_id
		E.tooltip_theme = choice_datum?.tooltip_theme
		E.maptext = null
		E.next_page = FALSE
		if(choices_icons[choice_id])
			E.add_overlay(choices_icons[choice_id])
		if (choice_datum?.info)
			var/obj/effect/abstract/info/info_button = new(E, choice_datum.info)
			info_button.name = "Info: [E.name]"
			info_button.tooltip_theme = choice_datum.tooltip_theme
			SET_PLANE_EXPLICIT(info_button, ABOVE_HUD_PLANE, anchor)
			info_button.layer = RADIAL_CONTENT_LAYER
			E.vis_contents += info_button

/datum/radial_menu/New(display_close_button)
	if(!display_close_button)
		return
	close_button = new
	close_button.set_parent(src)

/datum/radial_menu/proc/Reset()
	choices.Cut()
	choices_icons.Cut()
	choices_values.Cut()
	choice_datums.Cut()
	current_page = 1

/datum/radial_menu/proc/element_chosen(choice_id,mob/user)
	selected_choice = choices_values[choice_id]

/datum/radial_menu/proc/get_next_id()
	return "c_[choices.len]"

/datum/radial_menu/proc/set_choices(list/new_choices, use_tooltips, click_on_hover = FALSE, set_page = 1)
	if(choices.len)
		Reset()
	for(var/E in new_choices)
		var/id = get_next_id()
		choices += id
		choices_values[id] = E
		if(new_choices[E])
			var/I = extract_image(new_choices[E])
			if(I)
				choices_icons[id] = I

			if (istype(new_choices[E], /datum/radial_menu_choice))
				choice_datums[id] = new_choices[E]
	setup_menu(use_tooltips, set_page, click_on_hover)

/datum/radial_menu/proc/extract_image(to_extract_from)
	if (istype(to_extract_from, /datum/radial_menu_choice))
		var/datum/radial_menu_choice/choice = to_extract_from
		to_extract_from = choice.image

	var/mutable_appearance/MA = new /mutable_appearance(to_extract_from)
	if(MA)
		SET_PLANE_EXPLICIT(MA, ABOVE_HUD_PLANE, anchor)
		MA.layer = RADIAL_CONTENT_LAYER
		MA.appearance_flags |= RESET_TRANSFORM
	return MA


/datum/radial_menu/proc/next_page()
	if(pages > 1)
		current_page = WRAP(current_page + 1,1,pages+1)
		update_screen_objects()

/datum/radial_menu/proc/show_to(mob/M, offset_x = 0, offset_y = 0)
	if(current_user)
		hide()
	if(!M.client || !anchor)
		return
	current_user = M.client
	//Blank
	menu_holder = image(icon='icons/effects/effects.dmi',loc=anchor,icon_state="nothing", layer = RADIAL_BACKGROUND_LAYER)
	menu_holder.pixel_w = offset_x
	menu_holder.pixel_z = offset_y

	SET_PLANE_EXPLICIT(menu_holder, ABOVE_HUD_PLANE, M)
	menu_holder.appearance_flags |= KEEP_APART|RESET_ALPHA|RESET_COLOR|RESET_TRANSFORM
	menu_holder.vis_contents += elements
	if(!isnull(close_button))
		menu_holder.vis_contents += close_button
	current_user.images += menu_holder

/datum/radial_menu/proc/hide()
	if(current_user)
		current_user.images -= menu_holder

/datum/radial_menu/proc/wait(atom/user, atom/anchor, require_near = FALSE)
	while (current_user && !finished && !selected_choice)
		if(require_near && !in_range(anchor, user))
			return
		if(custom_check_callback && next_check < world.time)
			if(!custom_check_callback.Invoke())
				return
			else
				next_check = world.time + check_delay
		stoplag(1)

/datum/radial_menu/proc/remove_menu()
	if(!(button_animation_flags & BUTTON_FADE_OUT))
		qdel(src)
		return
	for(var/atom/movable/element as anything in elements)
		animate(element, alpha = 0, time = 0.15 SECONDS)
	QDEL_IN(src, 0.5 SECONDS)

/datum/radial_menu/Destroy()
	Reset()
	hide()
	custom_check_callback = null
	. = ..()

/*
	Presents radial menu to user anchored to anchor (or user if the anchor is currently in users screen)
	Choices should be a list where list keys are movables or text used for element names and return value
	and list values are movables/icons/images used for element icons
*/
/proc/show_radial_menu(mob/user, atom/anchor, list/choices, uniqueid, radius, datum/callback/custom_check, require_near = FALSE, tooltips = FALSE, no_repeat_close = FALSE, radial_slice_icon = "radial_slice", autopick_single_option = TRUE, button_animation_flags = BUTTON_SLIDE_IN, click_on_hover = FALSE, user_space = FALSE, check_delay = DEFAULT_CHECK_DELAY, display_close_button = TRUE, radial_menu_offset = list(0, 0))
	if(!user || !anchor || !length(choices))
		return

	if(length(choices) == 1 && autopick_single_option)
		return choices[1]

	if(!uniqueid)
		uniqueid = "defmenu_[REF(user)]_[REF(anchor)]"

	if(GLOB.radial_menus[uniqueid])
		if(!no_repeat_close)
			var/datum/radial_menu/menu = GLOB.radial_menus[uniqueid]
			menu.finished = TRUE
		return

	var/datum/radial_menu/menu = new(display_close_button)
	menu.button_animation_flags = button_animation_flags
	menu.check_delay = check_delay
	GLOB.radial_menus[uniqueid] = menu
	if(radius)
		menu.radius = radius
	if(istype(custom_check))
		menu.custom_check_callback = custom_check
	menu.anchor = user_space ? user : anchor
	menu.radial_slice_icon = radial_slice_icon
	menu.check_screen_border(user) //Do what's needed to make it look good near borders or on hud
	menu.set_choices(choices, tooltips, click_on_hover)
	var/offset_x = 0
	var/offset_y = 0
	if (user_space)
		var/turf/user_turf = get_turf(user)
		var/turf/anchor_turf = get_turf(anchor)
		offset_x = (anchor_turf.x - user_turf.x) * ICON_SIZE_X + anchor.pixel_x - user.pixel_x
		offset_y = (anchor_turf.y - user_turf.y) * ICON_SIZE_Y + anchor.pixel_y - user.pixel_y
	offset_x += radial_menu_offset[1]
	offset_y += radial_menu_offset[2]
	menu.show_to(user, offset_x, offset_y)
	menu.wait(user, anchor, require_near)
	var/answer = menu.selected_choice
	menu.remove_menu()
	GLOB.radial_menus -= uniqueid
	if(require_near && !in_range(anchor, user))
		return
	if(istype(custom_check))
		if(!custom_check.Invoke())
			return
	return answer

/// Can be provided to choices in radial menus if you want to provide more information
/datum/radial_menu_choice
	/// Required -- what to display for this button
	var/image

	/// If provided, this will be the name the radial slice hud button. This has priority over everything else.
	var/name

	/// If provided, will display an info button that will put this text in your chat
	var/info

	/// If provided, changes the tooltip theme for this choice
	var/tooltip_theme

/datum/radial_menu_choice/Destroy(force)
	. = ..()
	QDEL_NULL(image)

#undef NEXT_PAGE_ID
#undef DEFAULT_CHECK_DELAY
