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
	///Any client.color-valid value. If not null, will update client.color when added and removed.
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
		if(!colour)
			return
		if(fade_out)
			owner.animate_client_colour(fade_out)
		else
			owner.update_client_colour()
	owner = null
	return ..()

///Sets a new colour, then updates the owner's screen colour.
/datum/client_colour/proc/update_colour(new_colour, anim_time, easing = NONE)
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

	var/datum/client_colour/new_colour = new colour_type(src)
	. = new_colour
	BINARY_INSERT(new_colour, client_colours, /datum/client_colour, new_colour, priority, COMPARE_KEY)
	if(!new_colour.colour) //No color to apply, no update.
		return
	if(new_colour.fade_in)
		animate_client_colour(new_colour.fade_in)
	else
		update_client_colour()

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
 * Gets the colour to apply to the client from a client_colours list.
 * In the case of multiple client_colour instances, their colours will be blended together with color_matrix_multiply().
 * target is the target variable.
 */
#define MIX_CLIENT_COLOUR(target)\
	var/_our_colour;\
	var/_pool_closed = INFINITY;\
	var/_not_blending_yet = TRUE;\
	for(var/_c in client_colours){\
		var/datum/client_colour/_colour = _c;\
		if(_pool_closed < _colour.priority){\
			break\
		};\
		if(!_colour.colour){\
			continue\
		};\
		if(_colour.override){\
			_pool_closed = _colour.priority\
		};\
		if(!_our_colour){\
			_our_colour = _colour.colour;\
			continue\
		};\
		if(_not_blending_yet){\
			_our_colour = color_to_full_rgba_matrix(_our_colour);\
			_not_blending_yet = FALSE\
		};\
		var/list/_colour_matrix = color_to_full_rgba_matrix(_colour.colour);\
		_our_colour = color_matrix_multiply(_our_colour, _colour_matrix)\
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
	colour = "#ff0000"

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
	update_colour(list(1,0,0,0.8,0.2,0, 0.8,0,0.2,0.1,0,0), 10, SINE_EASING|EASE_OUT)

/datum/client_colour/cursed_heart_blood
	priority = PRIORITY_ABSOLUTE //it's an indicator you're dying, so it's very high priority
	colour = "#ff0000" //pure, bloody red
	override = TRUE
	fade_in = 5
	fade_out = 5

//Exactly what it says on the tin.
/datum/client_colour/hue_rotation
	var/hue_angle = 0 //Keeps track of the current angle.

/datum/client_colour/hue_rotation/proc/rotate_hue(rotation, duration = 2 SECONDS, easing = NONE)
	hue_angle = SIMPLIFY_DEGREES(hue_angle + rotation)
	update_colour(color_matrix_rotate_hue(hue_angle), duration, easing)

/datum/client_colour/hue_rotation/tripping
	priority = PRIORITY_HIGH //It shouldn't mess up with monochromia that much.

/datum/client_colour/hue_rotation/tripping/rotate_hue(rotation, duration = 2 SECONDS)
	. = ..()
	fade_out = round(abs(sin(hue_angle))*4 SECONDS) //Maximum fade out duration of 4 seconds at 90° / 270°

/datum/client_colour/tripping_secondary //Used in combination with the above.
	priority = PRIORITY_HIGH


#undef PRIORITY_ABSOLUTE
#undef PRIORITY_HIGH
#undef PRIORITY_NORMAL
#undef PRIORITY_LOW
