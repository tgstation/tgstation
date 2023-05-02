/**
 * Spatial gridmap, cell tracking
 *
 * This datum exists to make the large, repeated "everything in some range" pattern faster
 * Rather then just refreshing against everything, we track all the cells in range of the passed in "window"
 * This lets us do entered/left logic, and make ordinarially quite expensive logic much cheaper
 *
 * Note: This system should not be used for things who have strict requirements about what is NOT in their processed entries
 * It should instead only be used for logic that only really cares about limiting how much gets "entered" in any one call
 * Because we apply this limitation, we can do things to make our code much less prone to unneeded work
 */
/datum/cell_tracker
	var/list/datum/spatial_grid_cell/member_cells = list()
	// Inner window
	// If a cell is inside this space, it will be entered into our membership list
	/// The height (y radius) of our inner window
	var/inner_window_x_radius
	/// The width (x radius) of our inner window
	var/inner_window_y_radius

	// Outer window
	// If a cell is outside this space, it will be removed from our memebership list
	// This effectively applies a grace window, to prevent moving back and forth across a border line causing issues
	/// The height (y radius) of our outer window
	var/outer_window_x_radius
	/// The width (x radius) of our outer window
	var/outer_window_y_radius

/// Accepts a width and height to use for this tracker
/// Also accepts the ratio to use between inner and outer window. Optional, defaults to 2
/datum/cell_tracker/New(width, height, inner_outer_ratio)
	set_bounds(width, height, inner_outer_ratio)
	return ..()

/datum/cell_tracker/Destroy(force)
	stack_trace("Attempted to delete a cell tracker. They don't hold any refs outside of cells, what are you doing")
	if(!force)
		return QDEL_HINT_LETMELIVE
	member_cells.Cut()
	return ..()

/// Takes a width and height, and uses them to set the inner window, and interpolate the outer window
/datum/cell_tracker/proc/set_bounds(width = 0, height = 0, ratio = 2)
	// We want to store these as radii, rather then width and height, since that's convineient for spatial grid code
	var/x_radius = CEILING(width, 2)
	var/y_radius = CEILING(height, 2)
	inner_window_x_radius = x_radius
	inner_window_y_radius = y_radius

	outer_window_x_radius = x_radius * ratio
	outer_window_y_radius = y_radius * ratio

/// Returns a list of newly and formerly joined spatial grid managed objects of type [type] in the form list(new, old)
/// Takes the center of our window as input
/datum/cell_tracker/proc/recalculate_type_members(turf/center, type)
	var/list/new_and_old = recalculate_cells(center)

	var/list/new_members = list()
	var/list/former_members = list()
	/// Pull out all the new and old memebers we want
	switch(type)
		if(SPATIAL_GRID_CONTENTS_TYPE_CLIENTS)
			for(var/datum/spatial_grid_cell/cell as anything in new_and_old[1])
				new_members += cell.client_contents
			for(var/datum/spatial_grid_cell/cell as anything in new_and_old[2])
				former_members += cell.client_contents
		if(SPATIAL_GRID_CONTENTS_TYPE_HEARING)
			for(var/datum/spatial_grid_cell/cell as anything in new_and_old[1])
				new_members += cell.hearing_contents
			for(var/datum/spatial_grid_cell/cell as anything in new_and_old[2])
				former_members += cell.hearing_contents
		if(SPATIAL_GRID_CONTENTS_TYPE_ATMOS)
			for(var/datum/spatial_grid_cell/cell as anything in new_and_old[1])
				new_members += cell.atmos_contents
			for(var/datum/spatial_grid_cell/cell as anything in new_and_old[2])
				former_members += cell.atmos_contents

	return list(new_members, former_members)

/// Recalculates our member list, returns a list in the form list(new members, old members) for reaction
/// Accepts the turf to use as our "center"
/datum/cell_tracker/proc/recalculate_cells(turf/center)
	if(!center)
		CRASH("/datum/cell_tracker had an invalid location on refresh, ya done fucked")
	// This is a mild waste of cpu time. Consider optimizing by adding a new helper function to get just the space between two bounds
	// Assuming it ever becomes a real problem
	var/list/datum/spatial_grid_cell/inner_window = SSspatial_grid.get_cells_in_bounds(center, inner_window_x_radius, inner_window_y_radius)
	var/list/datum/spatial_grid_cell/outer_window = SSspatial_grid.get_cells_in_bounds(center, outer_window_x_radius, outer_window_y_radius)

	var/list/datum/spatial_grid_cell/new_cells = inner_window - member_cells
	// The outer window may contain cells we don't actually have, so we do it like this
	var/list/datum/spatial_grid_cell/old_cells = member_cells - outer_window

	// This whole thing is a naive implementation,
	// if it turns out to be expensive because of all the list operations I'll look closer at it
	member_cells -= old_cells
	member_cells += new_cells

	return list(new_cells, old_cells)
