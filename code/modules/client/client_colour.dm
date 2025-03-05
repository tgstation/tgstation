#define PRIORITY_ABSOLUTE 1
#define PRIORITY_HIGH 10
#define PRIORITY_NORMAL 100
#define PRIORITY_LOW 1000

/**
 * Client Colour Priority System By RemieRichards (then refactored by another contributor)
 * A System that gives finer control over which client.colour value to display on screen
 * so that the "highest priority" one is always displayed as opposed to the default of
 * "whichever was set last is displayed".
 *
 * Refactored to allow multiple overlapping client colours
 * (e.g. wearing blue glasses under a yellow visor, even though the result is a little unsatured.)
 * As well as some support for animated colour transitions.
 *
 * Define subtypes of this datum
 */
/datum/client_colour
	///The color we want to give to the client. This has to be either a hexadecimal color or a color matrix.
	var/colour
	///The mob that owns this client_colour.
	var/mob/owner
	/**
	  * We prioritize colours with higher priority (lower numbers), so they don't get overriden by less important ones:
	  * eg: "Bloody screen" > "goggles colour" as the former is much more important
	  */
	var/priority = PRIORITY_NORMAL
	///Will this client_colour prevent ones of lower priority from being applied?
	var/override = FALSE
	///IF non-zero, 'animate_client_colour(fade_in)' will be called instead of 'update_client_colour' when added.
	var/fade_in = 0
	///Same as above, but on removal.
	var/fade_out = 0

/datum/client_colour/New(mob/owner)
	src.owner = owner

/datum/client_colour/Destroy()
	if(!QDELETED(owner))
		owner.client_colours -= src
		owner.animate_client_colour(fade_out)
	owner = null
	return ..()

///Sets a new colour, then updates the owner's screen colour.
/datum/client_colour/proc/update_colour(new_colour, anim_time, easing = 0)
	colour = new_colour
	owner.animate_client_colour(anim_time, easing)

/**
 * Adds an instance of colour_type to the mob's client_colours list
 * colour_type - a typepath (subtyped from /datum/client_colour)
 */
/mob/proc/add_client_colour(colour_type_or_datum)
	if(QDELING(src))
		return
	var/datum/client_colour/colour
	if(istype(colour_type_or_datum, /datum/client_colour))
		colour = colour_type_or_datum
	else if(ispath(colour_type_or_datum, /datum/client_colour))
		colour = new colour_type_or_datum(src)
	else
		CRASH("Invalid colour type or datum for add_client_color: [colour_type_or_datum || "null"]")

	BINARY_INSERT(colour, client_colours, /datum/client_colour, colour, priority, COMPARE_KEY)
	animate_client_colour(colour.fade_in)
	return colour

/**
 * Removes an instance of colour_type from the mob's client_colours list
 * colour_type - a typepath (subtyped from /datum/client_colour)
 */
/mob/proc/remove_client_colour(colour_type)
	if(!ispath(colour_type, /datum/client_colour))
		return

	for(var/datum/client_colour/colour as anything in client_colours)
		if(colour.type == colour_type)
			qdel(colour)
			break

/**
 * Gets the resulting colour/tone from client_colours.
 * In the case of multiple colours, they'll be converted to RGBA matrices for compatibility,
 * summed together, and then each element divided by the number of matrices. (except we do this with lists because byond)
 * target is the target variable.
 */
#define MIX_CLIENT_COLOUR(target)\
	var/_our_colour;\
	var/_number_colours = 0;\
	var/_pool_closed = INFINITY;\
	for(var/_c in client_colours){\
		var/datum/client_colour/_colour = _c;\
		if(_pool_closed < _colour.priority){\
			break\
		};\
		_number_colours++;\
		if(_colour.override){\
			_pool_closed = _colour.priority\
		};\
		if(!_our_colour){\
			_our_colour = _colour.colour;\
			continue\
		};\
		if(_number_colours == 2){\
			_our_colour = color_to_full_rgba_matrix(_our_colour)\
		};\
		var/list/_colour_matrix = color_to_full_rgba_matrix(_colour.colour);\
		var/list/_L = _our_colour;\
		for(var/_i in 1 to 20){\
			_L[_i] += _colour_matrix[_i]\
		};\
	};\
	if(_number_colours > 1){\
		var/list/_L = _our_colour;\
		for(var/_i in 1 to 20){\
			_L[_i] /= _number_colours\
		};\
	};\
	target = _our_colour\

#define CLIENT_COLOR_FILTER_KEY "fake_client_color"

/**
 * Resets the mob's client.color to null, and then reapplies a new color based
 * on the client_colour datums it currently has.
 */
/mob/proc/update_client_colour()
	if(isnull(hud_used))
		return

	var/new_color = ""
	if(length(client_colours))
		MIX_CLIENT_COLOUR(new_color)

	for(var/atom/movable/screen/plane_master/game_plane as anything in hud_used.get_true_plane_masters(RENDER_PLANE_GAME))
		if(new_color)
			game_plane.add_filter(CLIENT_COLOR_FILTER_KEY, 2, color_matrix_filter(new_color))
		else
			game_plane.remove_filter(CLIENT_COLOR_FILTER_KEY)

///Works similarly to 'update_client_colour', but animated.
/mob/proc/animate_client_colour(anim_time = 2 SECONDS, anim_easing = NONE)
	if(anim_time <= 0)
		return update_client_colour()
	if(isnull(hud_used))
		return

	var/anim_color = ""
	if(length(client_colours))
		MIX_CLIENT_COLOUR(anim_color)

	for(var/atom/movable/screen/plane_master/game_plane as anything in hud_used.get_true_plane_masters(RENDER_PLANE_GAME))
		if(anim_color)
			game_plane.add_filter(CLIENT_COLOR_FILTER_KEY, 2, color_matrix_filter())
			game_plane.transition_filter(CLIENT_COLOR_FILTER_KEY, color_matrix_filter(anim_color), anim_time, anim_easing)
		else
			game_plane.transition_filter(CLIENT_COLOR_FILTER_KEY, color_matrix_filter(), anim_time, anim_easing)
			// This leaves a blank color filter on the hud which is, fine I guess?

#undef MIX_CLIENT_COLOUR

#undef CLIENT_COLOR_FILTER_KEY

/datum/client_colour/glass_colour
	priority = PRIORITY_LOW

/datum/client_colour/glass_colour/green
	colour = "#aaffaa"

/datum/client_colour/glass_colour/lightgreen
	colour = "#ccffcc"

/datum/client_colour/glass_colour/blue
	colour = "#aaaaff"

/datum/client_colour/glass_colour/lightblue
	colour = "#ccccff"

/datum/client_colour/glass_colour/yellow
	colour = "#ffff66"

/datum/client_colour/glass_colour/lightyellow
	colour = "#ffffaa"

/datum/client_colour/glass_colour/red
	colour = "#ffaaaa"

/datum/client_colour/glass_colour/lightred
	colour = "#ffcccc"

/datum/client_colour/glass_colour/darkred
	colour = "#bb5555"

/datum/client_colour/glass_colour/orange
	colour = "#ffbb99"

/datum/client_colour/glass_colour/lightorange
	colour = "#ffddaa"

/datum/client_colour/glass_colour/purple
	colour = "#ff99ff"

/datum/client_colour/glass_colour/lightpurple
	colour = "#ffccff"

/datum/client_colour/glass_colour/gray
	colour = "#cccccc"

///A client colour that makes the screen look a bit more grungy, halloweenesque even.
/datum/client_colour/halloween_helmet
	colour = list(0.75,0.13,0.13,0, 0.13,0.7,0.13,0, 0.13,0.13,0.75,0, -0.06,-0.09,-0.08,1, 0,0,0,0)

/datum/client_colour/flash_hood
	colour = COLOR_MATRIX_POLAROID

/datum/client_colour/glass_colour/nightmare
	colour = list(255,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,1, -130,0,0,0) //every color is either red or black

/datum/client_colour/malfunction
	colour = list(/*R*/ 0,0,0,0, /*G*/ 0,175,0,0, /*B*/ 0,0,0,0, /*A*/ 0,0,0,1, /*C*/0,-130,0,0) // Matrix colors

/datum/client_colour/perceptomatrix
	colour = list(/*R*/ 1,0,0,0, /*G*/ 0,1,0,0, /*B*/ 0,0,1,0, /*A*/ 0,0,0,1, /*C*/0,-0.02,-0.02,0) // veeery slightly pink

/datum/client_colour/monochrome
	colour = COLOR_MATRIX_GRAYSCALE
	priority = PRIORITY_HIGH //we can't see colors anyway!
	override = TRUE
	fade_in = 20
	fade_out = 20

/datum/client_colour/monochrome/colorblind
	priority = PRIORITY_HIGH

/datum/client_colour/monochrome/trance
	priority = PRIORITY_NORMAL

/datum/client_colour/monochrome/blind
	priority = PRIORITY_NORMAL

/datum/client_colour/bloodlust
	priority = PRIORITY_ABSOLUTE // Only anger.
	colour = list(0,0,0,0,0,0,0,0,0,1,0,0) //pure red.
	fade_out = 10

/datum/client_colour/bloodlust/New(mob/owner)
	..()
	if(owner)
		addtimer(CALLBACK(src, PROC_REF(update_colour), list(1,0,0,0.8,0.2,0, 0.8,0,0.2,0.1,0,0), 10, SINE_EASING|EASE_OUT), 0.1 SECONDS)

/datum/client_colour/rave
	priority = PRIORITY_LOW

/datum/client_colour/psyker
	priority = PRIORITY_ABSOLUTE
	override = TRUE
	colour = list(0.8,0,0,0, 0,0,0,0, 0,0,1,0, 0,0,0,1, 0,0,0,0)

/datum/client_colour/manual_heart_blood
	priority = PRIORITY_ABSOLUTE
	colour = COLOR_RED

/datum/client_colour/temp
	priority = PRIORITY_HIGH

#undef PRIORITY_ABSOLUTE
#undef PRIORITY_HIGH
#undef PRIORITY_NORMAL
#undef PRIORITY_LOW
