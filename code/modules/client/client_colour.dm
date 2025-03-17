#define CLIENT_COLOR_VALUE_INDEX 1
#define CLIENT_COLOR_PRIORITY_INDEX 2

/datum/client_colour
	/// Color given to the client, can be a hex color, color matrix or a filter
	var/color
	/// The mob that owns this client_colour
	var/mob/owner
	/// Priority of this color, higher values are rendered above lower ones
	var/priority = CLIENT_COLOR_FILTER_PRIORITY
	/// Will this client_colour prevent ones of lower priority from being applied?
	var/override = FALSE
	/// If set to TRUE, all colors below and above this one will be rendered in separate filters
	/// If color is a filter, forced to TRUE
	var/split_filters = FALSE
	/// If non-zero, 'animate_client_colour(fade_in)' will be called instead of 'update_client_colour' when added.
	var/fade_in = 0
	/// If non-zero, 'animate_client_colour(fade_out)' will be called instead of 'update_client_colour' when removed.
	var/fade_out = 0

/datum/client_colour/New(mob/owner)
	src.owner = owner

/datum/client_colour/Destroy()
	if(!QDELETED(owner))
		owner.client_colours -= src
		owner.animate_client_colour(fade_out)
	owner = null
	return ..()

///Sets a new color, then updates the owner's screen color.
/datum/client_colour/proc/update_color(new_color, anim_time, easing = 0)
	color = new_color
	owner.animate_client_colour(anim_time, easing)

/**
 * Add a color filter to the client
 * new_color - client_colour datum or typepath to be added
 * source - associated source for the client color
 * force - if TRUE, colors of the same source will be replaced even if it is of the same type
 */
/mob/proc/add_client_colour(datum/client_colour/new_color, source, force = FALSE)
	if (QDELING(src))
		return

	if (ispath(new_color))
		new_color = new new_color(src)

	if (!istype(new_color))
		CRASH("Invalid color type or datum for add_client_colour: [new_color ? "[new_color] ([new_color.type])" : "null"]")

	// Ensure that if a color with this source is already present, we either abort or get rid of it
	var/datum/client_colour/existing_color = get_client_colour(source)
	if (existing_color)
		if (existing_color.type == new_color.type && !force)
			return existing_color
		qdel(existing_color)
	client_colours[new_color] = source
	animate_client_colour(new_color.fade_in)
	return new_color

/**
 * Removes a color type from a specific source from mob's client_colours list
 * source - color source to remove
*/

/mob/proc/remove_client_colour(source)
	var/datum/client_colour/existing_color = get_client_colour(source)
	if (!existing_color)
		return FALSE
	qdel(existing_color)
	return TRUE

/mob/proc/get_client_colour(source)
	for(var/datum/client_colour/color as anything in client_colours)
		if (client_colours[color] == source)
			return color

/mob/proc/get_client_colour_filters()
	. = list()
	// sortTim sorts the passed list instead of making the copy, and so does reverse_range
	var/list/used_colors = reverse_range(sortTim(client_colours.Copy(), GLOBAL_PROC_REF(cmp_client_colours)))
	var/current_color = null
	var/color_num = 0
	var/color_prio = 1

	for (var/datum/client_colour/client_color as anything in used_colors)
		color_num += 1

		var/list/filter_color = null
		if (islist(client_color.color))
			filter_color = client_color.color
			// If our list has "type" in it then its a filter
			if (!filter_color["type"])
				filter_color = null

		if (client_color.split_filters || filter_color)
			if (current_color)
				. += list(list(color_matrix_filter(current_color), color_prio))
				color_prio += 1
				current_color = null

			. += list(list(filter_color || color_matrix_filter(client_color.color), color_prio))
			color_prio += 1
			continue

		if (!current_color)
			current_color = client_color.color
			if (client_color.override)
				break
			continue

		var/list/color_list = current_color
		if (!islist(color_list))
			color_list = color_to_full_rgba_matrix(color_list)
		var/list/cur_list = color_to_full_rgba_matrix(client_color.color)

		for (var/i in 1 to 20)
			color_list[i] = (color_list[i] * (color_num - 1) + cur_list[i]) / color_num
		current_color = color_list

		if (client_color.override)
			break

	if (current_color)
		. += list(list(color_matrix_filter(current_color), color_prio))

/mob/proc/update_client_colour()
	if (isnull(hud_used))
		return

	for (var/atom/movable/screen/plane_master/game_plane as anything in hud_used.get_true_plane_masters(RENDER_PLANE_GAME))
		for (var/filter_id in color_filter_store)
			game_plane.remove_filter(filter_id)

	color_filter_store.Cut()
	var/list/applied_filters = get_client_colour_filters()

	for (var/list/color_filter as anything in applied_filters)
		var/added_color = color_filter[CLIENT_COLOR_VALUE_INDEX]
		var/filter_priority = color_filter[CLIENT_COLOR_PRIORITY_INDEX]
		for (var/atom/movable/screen/plane_master/game_plane as anything in hud_used.get_true_plane_masters(RENDER_PLANE_GAME))
			var/filter_id = "client_colour_[filter_priority]"
			game_plane.add_filter(filter_id, filter_priority, added_color)
			color_filter_store |= filter_id

/// Works similarly to 'update_client_colour', but animated.
/mob/proc/animate_client_colour(anim_time = 1 SECONDS, anim_easing = NONE)
	if (isnull(hud_used))
		return

	if(anim_time <= -1)
		return update_client_colour()

	for (var/atom/movable/screen/plane_master/game_plane as anything in hud_used.get_true_plane_masters(RENDER_PLANE_GAME))
		for (var/filter_id in color_filter_store)
			game_plane.remove_filter(filter_id)

	color_filter_store.Cut()
	var/list/applied_filters = get_client_colour_filters()

	for (var/list/color_filter as anything in applied_filters)
		var/added_color = color_filter[CLIENT_COLOR_VALUE_INDEX]
		var/filter_priority = color_filter[CLIENT_COLOR_PRIORITY_INDEX]
		for (var/atom/movable/screen/plane_master/game_plane as anything in hud_used.get_true_plane_masters(RENDER_PLANE_GAME))
			var/filter_id = "client_colour_[filter_priority]"
			game_plane.add_filter(filter_id, filter_priority, color_matrix_filter())
			game_plane.transition_filter(filter_id, added_color, anim_time, anim_easing)
			color_filter_store |= filter_id

// Color types

///A client color that makes the screen look a bit more grungy, halloweenesque even.
/datum/client_colour/halloween_helmet
	priority = CLIENT_COLOR_HELMET_PRIORITY
	color = list(/*R*/ 0.75,0.13,0.13,0, /*G*/ 0.13,0.7,0.13,0, /*B*/ 0.13,0.13,0.75,0, /*A*/ -0.06,-0.09,-0.08,1, /*C*/ 0,0,0,0)

/datum/client_colour/flash_hood
	priority = CLIENT_COLOR_HELMET_PRIORITY
	color = COLOR_MATRIX_POLAROID

/datum/client_colour/perceptomatrix
	priority = CLIENT_COLOR_HELMET_PRIORITY
	color = list(/*R*/ 1,0,0,0, /*G*/ 0,1,0,0, /*B*/ 0,0,1,0, /*A*/ 0,0,0,1, /*C*/ 0,-0.02,-0.02,0) // veeery slightly pink

/datum/client_colour/rave
	priority = CLIENT_COLOR_HELMET_PRIORITY

/datum/client_colour/malfunction
	priority = CLIENT_COLOR_ORGAN_PRIORITY
	color = list(/*R*/ 0,0,0,0, /*G*/ 0,175,0,0, /*B*/ 0,0,0,0, /*A*/ 0,0,0,1, /*C*/ 0,-130,0,0) // Matrix colors

/datum/client_colour/monochrome
	color = COLOR_MATRIX_GRAYSCALE
	priority = CLIENT_COLOR_FILTER_PRIORITY
	split_filters = TRUE
	fade_in = 2 SECONDS
	fade_out = 2 SECONDS

/datum/client_colour/monochrome/glasses
	priority = CLIENT_COLOR_GLASSES_PRIORITY

/datum/client_colour/bloodlust
	priority = CLIENT_COLOR_IMPORTANT_PRIORITY
	color = list(0,0,0,0,0,0,0,0,0,1,0,0) // pure red
	fade_out = 1 SECONDS

/datum/client_colour/bloodlust/New(mob/owner)
	..()
	if(owner)
		addtimer(CALLBACK(src, PROC_REF(update_color), list(/*R*/ 1,0,0, /*G*/ 0.8,0.2,0, /*B*/ 0.8,0,0.2, /*C*/ 0.1,0,0), 10, SINE_EASING|EASE_OUT), 0.1 SECONDS)

/datum/client_colour/manual_heart_blood
	priority = CLIENT_COLOR_IMPORTANT_PRIORITY
	color = COLOR_RED

/datum/client_colour/psyker
	priority = CLIENT_COLOR_OVERRIDE_PRIORITY
	color = list(0.8,0,0,0, 0,0,0,0, 0,0,1,0, 0,0,0,1, 0,0,0,0)
	override = TRUE

/datum/client_colour/temp
	priority = CLIENT_COLOR_TEMPORARY_PRIORITY

/datum/client_colour/glass_colour
	priority = CLIENT_COLOR_GLASSES_PRIORITY

/datum/client_colour/glass_colour/green
	color = "#aaffaa"

/datum/client_colour/glass_colour/lightgreen
	color = "#ccffcc"

/datum/client_colour/glass_colour/blue
	color = "#aaaaff"

/datum/client_colour/glass_colour/lightblue
	color = "#ccccff"

/datum/client_colour/glass_colour/yellow
	color = "#ffff66"

/datum/client_colour/glass_colour/lightyellow
	color = "#ffffaa"

/datum/client_colour/glass_colour/red
	color = "#ffaaaa"

/datum/client_colour/glass_colour/lightred
	color = "#ffcccc"

/datum/client_colour/glass_colour/darkred
	color = "#bb5555"

/datum/client_colour/glass_colour/orange
	color = "#ffbb99"

/datum/client_colour/glass_colour/lightorange
	color = "#ffddaa"

/datum/client_colour/glass_colour/purple
	color = "#ff99ff"

/datum/client_colour/glass_colour/lightpurple
	color = "#ffccff"

/datum/client_colour/glass_colour/gray
	color = "#cccccc"

/datum/client_colour/glass_colour/nightmare
	color = list(/*R*/ 255,0,0,0, /*G*/ 0,0,0,0, /*B*/ 0,0,0,0, /*A*/ 0,0,0,1, /*C*/ -130,0,0,0) //every color is either red or black
	split_filters = TRUE

#undef CLIENT_COLOR_VALUE_INDEX
#undef CLIENT_COLOR_PRIORITY_INDEX
