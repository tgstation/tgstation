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
	///Any client.color-valid value
	var/colour = ""
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

/datum/client_colour/New(mob/_owner)
	owner = _owner

/datum/client_colour/Destroy()
	if(!QDELETED(owner))
		owner.client_colours -= src
		if(fade_out)
			owner.animate_client_colour(fade_out)
		else
			owner.update_client_colour()
	owner = null
	return ..()

///Sets a new colour, then updates the owner's screen colour.
/datum/client_colour/proc/update_colour(new_colour, anim_time, easing = 0)
	colour = new_colour
	if(anim_time)
		owner.animate_client_colour(anim_time, easing)
	else
		owner.update_client_colour()

/**
 * Adds an instance of colour_type to the mob's client_colours list
 * colour_type - a typepath (subtyped from /datum/client_colour)
 */
/mob/proc/add_client_colour(colour_type)
	if(!ispath(colour_type, /datum/client_colour) || QDELING(src))
		return

	var/datum/client_colour/colour = new colour_type(src)
	BINARY_INSERT(colour, client_colours, /datum/client_colour, colour, priority, COMPARE_KEY)
	if(colour.fade_in)
		animate_client_colour(colour.fade_in)
	else
		update_client_colour()
	return colour

/**
 * Removes an instance of colour_type from the mob's client_colours list
 * colour_type - a typepath (subtyped from /datum/client_colour)
 */
/mob/proc/remove_client_colour(colour_type)
	if(!ispath(colour_type, /datum/client_colour))
		return

	for(var/cc in client_colours)
		var/datum/client_colour/colour = cc
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


/**
 * Resets the mob's client.color to null, and then reapplies a new color based
 * on the client_colour datums it currently has.
 */
/mob/proc/update_client_colour()
	if(!client)
		return
	client.color = ""
	if(!client_colours.len)
		return
	MIX_CLIENT_COLOUR(client.color)

///Works similarly to 'update_client_colour', but animated.
/mob/proc/animate_client_colour(anim_time = 20, anim_easing = 0)
	if(!client)
		return
	if(!client_colours.len)
		animate(client, color = "", time = anim_time, easing = anim_easing)
		return
	MIX_CLIENT_COLOUR(var/anim_colour)
	animate(client, color = anim_colour, time = anim_time, easing = anim_easing)

#undef MIX_CLIENT_COLOUR

/datum/client_colour/glass_colour
	priority = PRIORITY_LOW
	colour = "red"

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

/datum/client_colour/glass_colour/red
	colour = "#ffaaaa"

/datum/client_colour/glass_colour/darkred
	colour = "#bb5555"

/datum/client_colour/glass_colour/orange
	colour = "#ffbb99"

/datum/client_colour/glass_colour/lightorange
	colour = "#ffddaa"

/datum/client_colour/glass_colour/purple
	colour = "#ff99ff"

/datum/client_colour/glass_colour/gray
	colour = "#cccccc"

/datum/client_colour/monochrome
	colour = list(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(0,0,0))
	priority = PRIORITY_HIGH //we can't see colors anyway!
	override = TRUE
	fade_in = 20
	fade_out = 20

/datum/client_colour/monochrome/trance
	priority = PRIORITY_NORMAL

/datum/client_colour/monochrome/blind
	priority = PRIORITY_NORMAL

/datum/client_colour/bloodlust
	priority = PRIORITY_ABSOLUTE // Only anger.
	colour = list(0,0,0,0,0,0,0,0,0,1,0,0) //pure red.
	fade_out = 10

/datum/client_colour/bloodlust/New(mob/_owner)
	..()
	addtimer(CALLBACK(src, .proc/update_colour, list(1,0,0,0.8,0.2,0, 0.8,0,0.2,0.1,0,0), 10, SINE_EASING|EASE_OUT), 1)

#undef PRIORITY_ABSOLUTE
#undef PRIORITY_HIGH
#undef PRIORITY_NORMAL
#undef PRIORITY_LOW
