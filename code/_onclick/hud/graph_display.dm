INITIALIZE_IMMEDIATE(/atom/movable/screen/graph_display)
/atom/movable/screen/graph_display
	name = "graph"
	del_on_map_removal = FALSE
	clear_with_screen = FALSE
	screen_loc = "BOTTOM,LEFT"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	plane = CPU_DEBUG_PLANE
	layer = CPU_DISPLAY_LAYER
	var/atom/movable/screen/graph_part/span_screen/frame/frame_up
	var/atom/movable/screen/graph_part/span_screen/frame/frame_right
	var/list/atom/movable/screen/graph_part/span_screen/dash/dash_up = list()
	var/list/atom/movable/screen/graph_part/span_screen/dash/dash_right = list()
	/// How many pixels tall this graph is
	var/height = ICON_SIZE_Y
	/// How many pixels wide this graph is
	var/width = ICON_SIZE_X
	/// How often we should place up dashes
	var/up_dash_space = ICON_SIZE_Y
	var/right_dash_space = ICON_SIZE_X

/atom/movable/screen/graph_display/Destroy()
	QDEL_NULL(frame_up)
	QDEL_NULL(frame_right)
	QDEL_LIST(dash_up)
	QDEL_LIST(dash_right)
	return ..()

/// Run when a graph is prepared for display, places all the relevant visual elements
/atom/movable/screen/graph_display/proc/setup()
	SHOULD_CALL_PARENT(TRUE)
	frame_up = get_frame_up()
	frame_right = get_frame_right()
	var/total_dashes_up = ROUND_UP(width / up_dash_space)
	dash_up = new /list(total_dashes_up)
	for(var/i in 1 to total_dashes_up)
		dash_up[i] = get_dashline_up(i, total_dashes_up)
	var/total_dashes_right = ROUND_UP(height / right_dash_space)
	dash_right = new /list(total_dashes_right)
	for(var/i in 1 to total_dashes_right)
		dash_right[i] = get_dashline_right(i, total_dashes_right)

/// Returns a pixel height extracted from the passed in value
/atom/movable/screen/graph_display/proc/value_to_height(value)
	return value

/// Returns a bar color extracted from the passed in value
/atom/movable/screen/graph_display/proc/value_to_color(value)
	return "#FFFFFF"

/// Pixel width of our graph edges, used to place the start of the graph
#define GRAPH_EDGE_SIZE 18

/// Places an up (south to north) frame
/atom/movable/screen/graph_display/proc/get_frame_up()
	var/atom/movable/screen/graph_part/span_screen/frame/edge = new(null, null, src)
	vis_contents += edge
	edge.setDir(NORTH)
	return edge

/// Places a right (east to west) frame
/atom/movable/screen/graph_display/proc/get_frame_right()
	var/atom/movable/screen/graph_part/span_screen/frame/edge = new(null, null, src)
	vis_contents += edge
	edge.setDir(WEST)
	return edge

/// Places an up (south to north) dashline. It will stick itself some distance to the right, and then extend up
/atom/movable/screen/graph_display/proc/get_dashline_up(count, total)
	var/atom/movable/screen/graph_part/span_screen/dash/dash_line = new(null, null, src)
	vis_contents += dash_line
	dash_line.pixel_x = up_dash_space * count
	dash_line.pixel_y = GRAPH_EDGE_SIZE
	dash_line.setDir(NORTH)
	return dash_line

/// Places a right (east to west) dashline. It will stick itself some distance up, and then extend to the right
/atom/movable/screen/graph_display/proc/get_dashline_right(count, total)
	var/atom/movable/screen/graph_part/span_screen/dash/dash_line = new(null, null, src)
	vis_contents += dash_line
	dash_line.pixel_x = GRAPH_EDGE_SIZE
	dash_line.pixel_y = right_dash_space * count
	dash_line.setDir(WEST)
	return dash_line

/atom/movable/screen/graph_display/bars
	/// The "root atom" of each bar in our pool. ordered first to last
	var/list/atom/movable/screen/graph_part/bar/bars = list()
	/// Mask atom that is used to cut out our displayed bars
	var/atom/movable/screen/graph_part/bar_mask/global_mask
	/// The render source used to mask out the bars on this graph
	var/bar_mask_source
	/// How many bars to draw, -1 to autocalc
	var/bar_count = 0
	/// How far to space out each bar, -1 to autocalc
	var/bar_distance = 0
	/// How wide each bar should be, options depend on sprites (2, 6, 8)
	var/bar_resolution = 2
	/// Freeze the graph, preventing any changes to our bars
	var/freeze = FALSE

/atom/movable/screen/graph_display/bars/setup()
	. = ..()
	bar_mask_source = "*graph_[REF(src)]_mask"
	if(bar_count == -1)
		bar_count = ROUND_UP(width / bar_distance)
	if(bar_distance == -1)
		bar_distance = ROUND_UP(width / bar_count)
	for(var/i in 1 to bar_count)
		var/atom/movable/screen/graph_part/bar/lad = generate_bar(i, bar_count)
		position_root_bar(lad, i, bar_count)
		bars += lad

	global_mask = new(null, null, src, height + 2)
	global_mask.render_target = bar_mask_source
	vis_contents += global_mask

/atom/movable/screen/graph_display/bars/Destroy()
	QDEL_LIST(bars)
	QDEL_NULL(global_mask)
	return ..()

/// Clears our values to nothing, resets the graph
/atom/movable/screen/graph_display/bars/proc/clear_values()
	if(freeze)
		return
	for(var/atom/movable/screen/graph_part/bar/root_bar as anything in bars)
		root_bar.refresh_bar(0)

/// Pushes a value onto the bar stack
/atom/movable/screen/graph_display/bars/proc/push_value(value)
	if(freeze)
		return
	var/atom/movable/screen/graph_part/bar/bring_forward = bars[length(bars)]
	bars.Remove(bring_forward)
	bars.Insert(1, bring_forward)

	for(var/i in 1 to length(bars))
		var/atom/movable/screen/graph_part/bar/redraw = bars[i]
		position_root_bar(redraw, i, length(bars))
	bring_forward.refresh_bar(value)

/atom/movable/screen/graph_display/bars/proc/position_root_bar(atom/movable/screen/graph_part/bar/place, count, total)
	place.pixel_x = bar_distance * count
	place.pixel_y = GRAPH_EDGE_SIZE

/atom/movable/screen/graph_display/bars/proc/generate_bar(count, total)
	var/atom/movable/screen/graph_part/bar/bar_up = new(null, null, src, bar_resolution, height, bar_mask_source)
	src.vis_contents += bar_up
	bar_up.setDir(NORTH)

	var/static/list/test_gradient = list(
		0.0, "#FF0000",
		0.2, "#FF8000",
		0.4, "#f0f000",
		0.6, "#00FF00",
		0.8, "#46daff",
		1.0, "#2A72AA",
	)
	var/new_color = gradient(test_gradient, clamp(count / total, 0, 1))
	bar_up.refresh_bar(LERP(10, height, count / total), new_color)
	return bar_up

/// Places a right (east to west) threshold. It will stick itself some distance up, and then extend to the right
/atom/movable/screen/graph_display/proc/place_threshold(height_value)
	var/atom/movable/screen/graph_part/span_screen/threshold/cutoff = new(null, null, src, height_value)
	vis_contents += cutoff
	cutoff.pixel_x = GRAPH_EDGE_SIZE
	cutoff.setDir(WEST)
	return cutoff

INITIALIZE_IMMEDIATE(/atom/movable/screen/graph_part)
/atom/movable/screen/graph_part
	icon = 'icons/ui/graph/graph_parts.dmi'
	plane = CPU_DEBUG_PLANE
	layer = CPU_DISPLAY_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	appearance_flags = KEEP_TOGETHER
	var/atom/movable/screen/graph_display/parent_graph

/atom/movable/screen/graph_part/Initialize(mapload, datum/hud/hud_owner, atom/movable/screen/graph_display/parent_graph)
	. = ..()
	src.parent_graph = parent_graph

/atom/movable/screen/graph_part/Destroy()
	parent_graph = null
	return ..()

/atom/movable/screen/graph_part/span_screen

/atom/movable/screen/graph_part/span_screen/Initialize(mapload, datum/hud/hud_owner, atom/movable/screen/graph_display/parent_graph)
	. = ..()
	update_appearance()

/atom/movable/screen/graph_part/span_screen/setDir(newdir)
	. = ..()
	update_appearance()

/atom/movable/screen/graph_part/span_screen/proc/get_height()
	return parent_graph.height

/atom/movable/screen/graph_part/span_screen/proc/get_width()
	return parent_graph.width

/atom/movable/screen/graph_part/span_screen/update_overlays()
	. = ..()
	var/iterate_count = 0
	var/list/offsets = list(0, 0)
	if(dir & (EAST|WEST))
		offsets[1] = ICON_SIZE_X
		iterate_count = ROUND_UP(get_height() / ICON_SIZE_Y) - 1
	else
		offsets[2] = ICON_SIZE_Y
		iterate_count = ROUND_UP(get_width() / ICON_SIZE_X) - 1
	for(var/i in 1 to iterate_count)
		var/mutable_appearance/extended_line = mutable_appearance(icon, icon_state)
		extended_line.pixel_x = offsets[1] * i
		extended_line.pixel_y = offsets[2] * i
		. += extended_line

/atom/movable/screen/graph_part/span_screen/frame
	icon_state = "edge"
	layer = CPU_GRAPH_FRAME_LAYER

/atom/movable/screen/graph_part/span_screen/frame/get_height()
	return ..() + 1

/atom/movable/screen/graph_part/span_screen/frame/get_width()
	return ..() + 1

/atom/movable/screen/graph_part/span_screen/dash
	icon_state = "dash"
	color = "#333333"

/atom/movable/screen/graph_part/span_screen/threshold
	icon_state = "dash"
	color = "#5BDC9C"
	var/height_value = 0

/atom/movable/screen/graph_part/span_screen/threshold/Initialize(mapload, datum/hud/hud_owner, atom/movable/screen/graph_display/parent_graph, height_value)
	. = ..()
	set_height(height_value)

/atom/movable/screen/graph_part/span_screen/threshold/proc/set_height(height_value)
	src.height_value = height_value
	recalculate_position()

/atom/movable/screen/graph_part/span_screen/threshold/proc/recalculate_position()
	pixel_y = parent_graph.value_to_height(height_value) + 3 // I can't explain why this works but it does seem to

/atom/movable/screen/graph_part/bar
	icon_state = null
	appearance_flags = KEEP_TOGETHER
	/// Cached MA holding all the bars in our display, please don't copy this pattern
	var/mutable_appearance/bar_chain
	/// Cached MA holding all the borders in our display, please don't copy this pattern
	var/mutable_appearance/border_chain

	/// Resolution of the bar to display (Current options: 2, 6, 8)
	var/resolution = 2
	/// The value this bar is currently holding
	var/bar_value
	/// What render source are we alpha masking against?
	var/filter_source

/atom/movable/screen/graph_part/bar/Initialize(mapload, datum/hud/hud_owner, atom/movable/screen/graph_display/parent_graph, resolution, graph_height, filter_source)
	. = ..()
	if(resolution)
		src.resolution = resolution
	src.filter_source = filter_source
	add_filter("top_mask", 1, alpha_mask_filter(y = graph_height, render_source = filter_source, flags = MASK_INVERSE))
	build_chains(graph_height)
	update_appearance()

/atom/movable/screen/graph_part/bar/proc/build_chains(graph_height)
	bar_chain = mutable_appearance(icon, "bar_[resolution]px", appearance_flags = KEEP_TOGETHER)
	for(var/i in 1 to (ROUND_UP(graph_height / ICON_SIZE_Y) - 1))
		var/mutable_appearance/gooey_core = mutable_appearance(icon, "bar_[resolution]px")
		gooey_core.pixel_y = i * ICON_SIZE_Y
		bar_chain.overlays += gooey_core
	border_chain = mutable_appearance(icon, "border_[resolution]px", appearance_flags = KEEP_TOGETHER)
	for(var/i in 1 to (ROUND_UP(graph_height / ICON_SIZE_Y) - 1))
		var/mutable_appearance/outer_nut = mutable_appearance(icon, "border_[resolution]px")
		outer_nut.pixel_y = i * ICON_SIZE_Y
		border_chain.overlays += outer_nut

/atom/movable/screen/graph_part/bar/proc/refresh_bar(bar_value)
	src.bar_value = bar_value
	update_appearance()

/atom/movable/screen/graph_part/bar/update_icon(updates)
	. = ..()
	modify_filter("top_mask", alpha_mask_filter(y = parent_graph.value_to_height(bar_value)))

/atom/movable/screen/graph_part/bar/update_overlays()
	. = ..()
	bar_chain.color = parent_graph.value_to_color(bar_value)
	. += bar_chain
	. += border_chain

/atom/movable/screen/graph_part/bar_mask
	icon_state = "bar_mask"
	appearance_flags = KEEP_TOGETHER|PIXEL_SCALE
	var/mask_height

/atom/movable/screen/graph_part/bar_mask/Initialize(mapload, datum/hud/hud_owner, atom/movable/screen/graph_display/parent_graph, mask_height)
	. = ..()
	src.mask_height = mask_height
	update_appearance()

/atom/movable/screen/graph_part/bar_mask/update_overlays()
	. = ..()
	for(var/i in 1 to ROUND_UP(mask_height / ICON_SIZE_Y))
		var/mutable_appearance/mask_block = mutable_appearance(icon, icon_state)
		mask_block.pixel_y += i * ICON_SIZE_Y
		. += mask_block

/atom/movable/screen/graph_display/empty
	height = ICON_SIZE_Y * 10
	width = ICON_SIZE_X * 15
	up_dash_space = 10
	screen_loc = "BOTTOM:24,LEFT+3:16"

/atom/movable/screen/graph_display/bars/cpu_display
	height = ICON_SIZE_Y * 11
	width = ICON_SIZE_X * 11
	screen_loc = "BOTTOM:24,LEFT+4"
	bar_count = 40
	bar_distance = -1
	bar_resolution = 6
	// How much cpu do we want to be able to display discretely
	var/max_displayable_cpu = 130
	// What is the graph currently displaying?
	var/display_mode
	var/atom/movable/screen/graph_part/span_screen/threshold/overtime_line
	var/atom/movable/screen/graph_part/span_screen/threshold/mc_overtime_line
	var/atom/movable/screen/graph_part/span_screen/threshold/consumption_limit_line

/atom/movable/screen/graph_display/bars/cpu_display/setup()
	. = ..()
	overtime_line = place_threshold(100)
	mc_overtime_line = place_threshold(100)
	mc_overtime_line.color = "#0035c7"
	consumption_limit_line = place_threshold(100)
	consumption_limit_line.color = "#b600c7"

/atom/movable/screen/graph_display/bars/cpu_display/Destroy()
	. = ..()
	QDEL_NULL(overtime_line)
	QDEL_NULL(mc_overtime_line)
	QDEL_NULL(consumption_limit_line)

/atom/movable/screen/graph_display/bars/cpu_display/proc/set_display_mode(new_display_mode)
	if(display_mode == new_display_mode)
		return
	display_mode = new_display_mode
	mc_overtime_line.alpha = 0
	consumption_limit_line.alpha = 0
	switch(display_mode)
		if(USAGE_DISPLAY_CPU)
			consumption_limit_line.alpha = 255
		if(USAGE_DISPLAY_MC)
			mc_overtime_line.alpha = 255
	clear_values()

/atom/movable/screen/graph_display/bars/cpu_display/proc/refresh_thresholds()
	if(freeze)
		return
	var/datum/tick_holder/tick_info = GLOB.tick_info
	var/list/cpu_values = tick_info.cpu_values
	var/list/pre_tick_cpu_usage = tick_info.pre_tick_cpu_usage
	var/list/tick_cpu_usage = tick_info.tick_cpu_usage
	var/last_index = tick_info.cpu_index
	switch(display_mode)
		if(USAGE_DISPLAY_CPU)
			push_value(cpu_values[last_index])
			consumption_limit_line.set_height(GLOB.corrective_cpu_threshold)
		if(USAGE_DISPLAY_MC)
			push_value(pre_tick_cpu_usage[last_index])
			mc_overtime_line.set_height(TICK_LIMIT_RUNNING)
		if(USAGE_DISPLAY_POST_TICK)
			push_value(cpu_values[last_index] - tick_cpu_usage[last_index])

/atom/movable/screen/graph_display/bars/cpu_display/proc/set_max_display(max_displayable_cpu)
	src.max_displayable_cpu = max_displayable_cpu
	overtime_line.recalculate_position()
	mc_overtime_line.recalculate_position()
	consumption_limit_line.recalculate_position()
	for(var/atom/movable/screen/graph_part/bar/displayed_bar as anything in bars)
		displayed_bar.update_appearance()

/atom/movable/screen/graph_display/bars/cpu_display/value_to_height(value)
	return LERP(0, height, clamp(value / max_displayable_cpu, 0, 1))

/atom/movable/screen/graph_display/bars/cpu_display/value_to_color(value)
	var/static/list/cpu_gradient = list(
		0, "#2a37aa",
		0.2, "#2A72AA",
		0.4, "#46daff",
		0.6, "#00FF00",
		0.8, "#f0f000",
		1, "#FF8000"
	)
	var/static/list/overtime_gradient = list(
		1, "#FF0000",
		1.3, "#000000",
	)
	var/scaled = value / 100
	if(scaled > 1)
		var/max_value = max_displayable_cpu / 100
		overtime_gradient[3] = max_value
		return gradient(overtime_gradient, clamp(scaled, 0, max_value))
	return gradient(cpu_gradient, clamp(scaled, 0, 1))
