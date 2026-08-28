/datum/action_group
	/// The hud we're owned by
	var/datum/hud/owner
	/// The actions we're managing
	var/list/atom/movable/screen/movable/action_button/actions
	/// The initial vertical offset of our action buttons
	var/north_offset = 0
	/// The pixel vertical offset of our action buttons
	var/pixel_north_offset = 0
	/// Max amount of buttons we can have per row
	/// Indexes at 1
	var/column_max = 0
	/// How far "ahead" of the first row we start. Lets us "scroll" our rows
	/// Indexes at 1
	var/row_offset = 0
	/// How many rows of actions we can have at max before we just stop hiding
	/// Indexes at 1
	var/max_rows = INFINITY
	/// The screen location we go by
	var/location
	/// Our landing screen object
	var/atom/movable/screen/action_landing/landing

/datum/action_group/New(datum/hud/owner)
	..()
	actions = list()
	src.owner = owner

/datum/action_group/Destroy()
	owner = null
	QDEL_NULL(landing)
	QDEL_LIST(actions)
	return ..()

/datum/action_group/proc/insert_action(atom/movable/screen/action, index)
	if(action in actions)
		if(actions[index] == action)
			return
		actions -= action // Don't dupe, come on
	if(!index)
		index = length(actions) + 1
	index = min(length(actions) + 1, index)
	actions.Insert(index, action)
	refresh_actions()

/datum/action_group/proc/remove_action(atom/movable/screen/action)
	actions -= action
	refresh_actions()

/datum/action_group/proc/refresh_actions()

	// We don't use size() here because landings are not canon
	var/total_rows = ROUND_UP(length(actions) / column_max)
	total_rows -= max_rows // Lets get the amount of rows we're off from our max
	row_offset = clamp(row_offset, 0, total_rows) // You're not allowed to offset so far that we have a row of blank space

	var/button_number = 0
	for(var/atom/movable/screen/button as anything in actions)
		var/postion = ButtonNumberToScreenCoords(button_number )
		button.screen_loc = postion
		button_number++

	if(landing)
		var/postion = ButtonNumberToScreenCoords(button_number, landing = TRUE) // Need a good way to count buttons off screen, but allow this to display in the right place if it's being placed with no concern for dropdown
		landing.screen_loc = postion
		button_number++

/// Accepts a number represeting our position in the group, indexes at 0 to make the math nicer
/datum/action_group/proc/ButtonNumberToScreenCoords(number, landing = FALSE)
	var/row = round(number / column_max)
	row -= row_offset // If you're less then 0, you don't get to render, this lets us "scroll" rows ya feel?
	if(row < 0)
		return null

	// Could use >= here, but I think it's worth noting that the two start at different places, since row is based on number here
	if(row > max_rows - 1)
		if(!landing) // If you're not a landing, go away please. thx
			return null
		// We always want to render landings, even if their action button can't be displayed.
		// So we set a row equal to the max amount of rows + 1. Willing to overrun that max slightly to properly display the landing spot
		row = max_rows // Remembering that max_rows indexes at 1, and row indexes at 0

		// We're going to need to set our column to match the first item in the last row, so let's set number properly now
		number = row * column_max

	var/visual_row = row + north_offset
	var/coord_row = visual_row ? "-[visual_row]" : "+0"

	var/visual_column = number % column_max
	var/coord_col = "+[visual_column]"
	var/coord_col_offset = 4 + 2 * (visual_column + 1)
	return "WEST[coord_col]:[coord_col_offset],NORTH[coord_row]:-[pixel_north_offset]"

/datum/action_group/proc/check_against_view()
	var/owner_view = owner?.mymob?.canon_client?.view
	if(!owner_view)
		return
	// Unlikey as it is, we may have been changed. Want to start from our target position and fail down
	column_max = initial(column_max)
	// Convert our viewer's view var into a workable offset
	var/list/view_size = view_to_pixels(owner_view)

	// We're primarially concerned about width here, if someone makes us 1x2000 I wish them a swift and watery death
	var/furthest_screen_loc = ButtonNumberToScreenCoords(column_max - 1)
	var/list/offsets = screen_loc_to_offset(furthest_screen_loc, owner_view)
	if(offsets[1] > ICON_SIZE_X && offsets[1] < view_size[1] && offsets[2] > ICON_SIZE_Y && offsets[2] < view_size[2]) // We're all good
		return

	for(column_max in column_max - 1 to 1 step -1) // Yes I could do this by unwrapping ButtonNumberToScreenCoords, but I don't feel like it
		var/tested_screen_loc = ButtonNumberToScreenCoords(column_max)
		offsets = screen_loc_to_offset(tested_screen_loc, owner_view)
		// We've found a valid max length, pack it in
		if(offsets[1] > ICON_SIZE_X && offsets[1] < view_size[1] && offsets[2] > ICON_SIZE_Y && offsets[2] < view_size[2])
			break
	// Use our newly resized column max
	refresh_actions()

/// Returns the amount of objects we're storing at the moment
/datum/action_group/proc/size()
	var/amount = length(actions)
	if(landing)
		amount += 1
	return amount

/datum/action_group/proc/index_of(atom/movable/screen/get_location)
	return actions.Find(get_location)

/// Generates a landing object that can be dropped on to join this group
/datum/action_group/proc/generate_landing()
	if(landing)
		return
	landing = new()
	landing.set_owner(src)
	refresh_actions()

/// Clears any landing objects we may currently have
/datum/action_group/proc/clear_landing()
	QDEL_NULL(landing)

/datum/action_group/proc/update_landing()
	if(!landing)
		return
	landing.refresh_owner()

/datum/action_group/proc/scroll(amount)
	row_offset += amount
	refresh_actions()

/datum/action_group/palette
	north_offset = 2
	column_max = 3
	max_rows = 3
	location = SCRN_OBJ_IN_PALETTE

/datum/action_group/palette/insert_action(atom/movable/screen/action, index)
	. = ..()
	var/atom/movable/screen/button_palette/palette = owner.screen_objects[HUD_MOB_TOGGLE_PALETTE]
	palette.play_item_added()

/datum/action_group/palette/remove_action(atom/movable/screen/action)
	. = ..()
	var/atom/movable/screen/button_palette/palette = owner.screen_objects[HUD_MOB_TOGGLE_PALETTE]
	palette.play_item_removed()
	if(!length(actions))
		palette.set_expanded(FALSE)

/datum/action_group/palette/refresh_actions()
	var/atom/movable/screen/button_palette/palette = owner.screen_objects[HUD_MOB_TOGGLE_PALETTE]
	var/atom/movable/screen/palette_scroll/scroll_down = owner.screen_objects[HUD_MOB_PALETTE_DOWN]
	var/atom/movable/screen/palette_scroll/scroll_up = owner.screen_objects[HUD_MOB_PALETTE_UP]

	var/actions_above = round((owner.listed_actions.size() - 1) / owner.listed_actions.column_max)
	north_offset = initial(north_offset) + actions_above

	palette.screen_loc = ui_action_palette_offset(actions_above)
	var/action_count = length(owner?.mymob?.actions)
	var/our_row_count = round((length(actions) - 1) / column_max)
	if(!action_count)
		palette.screen_loc = null

	if(palette.expanded && action_count && our_row_count >= max_rows)
		scroll_down.screen_loc = ui_palette_scroll_offset(actions_above)
		scroll_up.screen_loc = ui_palette_scroll_offset(actions_above)
	else
		scroll_down.screen_loc = null
		scroll_up.screen_loc = null

	return ..()

/datum/action_group/palette/ButtonNumberToScreenCoords(number, landing)
	var/atom/movable/screen/button_palette/palette = owner.screen_objects[HUD_MOB_TOGGLE_PALETTE]
	if(palette.expanded)
		return ..()

	if(!landing)
		return null

	// We only render the landing in this case, so we force it to be the second item displayed (Second rather then first since it looks nicer)
	// Remember the number var indexes at 0
	return ..(1 + (row_offset * column_max), landing)

/datum/action_group/listed
	pixel_north_offset = 6
	column_max = 10
	location = SCRN_OBJ_IN_LIST

/datum/action_group/listed/refresh_actions()
	. = ..()
	owner?.palette_actions.refresh_actions() // We effect them, so we gotta refresh em
