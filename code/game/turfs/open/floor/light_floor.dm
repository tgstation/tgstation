#define LIGHTFLOOR_FINE 0
#define LIGHTFLOOR_FLICKER 1
#define LIGHTFLOOR_BREAKING 2
#define LIGHTFLOOR_BROKEN 3

/turf/open/floor/light
	name = "light floor"
	desc = "A wired glass tile embedded into the floor. Modify the color with a Multitool."
	light_range = 5
	icon_state = "light_on-1"
	floor_tile = /obj/item/stack/tile/light
	///var to see if its on or off
	var/on = TRUE
	///defines on top
	var/state = LIGHTFLOOR_FINE
	///list of colours to choose
	var/static/list/coloredlights = list(LIGHT_COLOR_CYAN, COLOR_SOFT_RED, LIGHT_COLOR_ORANGE, LIGHT_COLOR_GREEN, LIGHT_COLOR_DIM_YELLOW, LIGHT_COLOR_DARK_BLUE, LIGHT_COLOR_LAVENDER, COLOR_WHITE,  LIGHT_COLOR_SLIME_LAMP, LIGHT_COLOR_FIRE)
	///current light color
	var/currentcolor = LIGHT_COLOR_CYAN
	///var to prevent changing color on certain admin spawn only tiles
	var/can_modify_colour = TRUE
	tiled_dirt = FALSE
	///icons for radial menu
	var/static/list/lighttile_designs
	///used for light floors that cycle colours
	var/cycle = FALSE

/turf/open/floor/light/broken_states()
	return list("light_broken")

/turf/open/floor/light/examine(mob/user)
	. = ..()
	. += span_notice("There's a <b>small crack</b> on the edge of it.")
	. += span_notice("Use a multitool on it to change colors.")
	. += span_notice("Use a screwdriver to turn it off or on.")
	if(state) ///check if broken
		. += span_danger("The light bulb seems fried!")

///create radial menu
/turf/open/floor/light/proc/populate_lighttile_designs()
	lighttile_designs = list(
		LIGHT_COLOR_CYAN = image(icon = src.icon, icon_state = "light_on-1"),
		COLOR_SOFT_RED = image(icon = src.icon, icon_state = "light_on-2"),
		LIGHT_COLOR_ORANGE = image(icon = src.icon, icon_state = "light_on-3"),
		LIGHT_COLOR_GREEN = image(icon = src.icon, icon_state = "light_on-4"),
		LIGHT_COLOR_DIM_YELLOW = image(icon = src.icon, icon_state = "light_on-5"),
		LIGHT_COLOR_DARK_BLUE = image(icon = src.icon, icon_state = "light_on-6"),
		LIGHT_COLOR_LAVENDER = image(icon = src.icon, icon_state = "light_on-7"),
		COLOR_WHITE = image(icon = src.icon, icon_state = "light_on-8"),
		LIGHT_COLOR_SLIME_LAMP = image(icon = src.icon, icon_state = "light_on-9"),
		LIGHT_COLOR_FIRE = image(icon = src.icon, icon_state = "light_on-10")
		)

/turf/open/floor/light/Initialize(mapload)
	. = ..()
	update_appearance()
	if(!length(lighttile_designs))
		populate_lighttile_designs()

/turf/open/floor/light/break_tile()
	..()
	state = pick(LIGHTFLOOR_FLICKER, LIGHTFLOOR_BREAKING, LIGHTFLOOR_BROKEN)/// pick a broken state
	update_appearance()

/turf/open/floor/light/update_appearance(updates)
	. = ..()
	if(!on)
		set_light(0)
		return

	switch(state)
		if(LIGHTFLOOR_FINE)
			set_light_color(currentcolor)
			set_light(5)
			light_range = 3
		if(LIGHTFLOOR_FLICKER)
			set_light_color(currentcolor)
			set_light(3)
			light_range = 2
		if(LIGHTFLOOR_BREAKING)
			set_light(1)
		if(LIGHTFLOOR_BROKEN)
			set_light(0)

/turf/open/floor/light/update_icon_state()
	if(!on)
		icon_state = "light_off"
		return ..()

	switch(state)
		if(LIGHTFLOOR_FINE)
			if(cycle)
				if(istype(src, /turf/open/floor/light/colour_cycle/dancefloor_a))
					icon_state = "light_on-dancefloor_A"
				else if(istype(src, /turf/open/floor/light/colour_cycle/dancefloor_b))
					icon_state = "light_on-dancefloor_B"
				else
					icon_state = "light_on-cycle_all"
			else
				icon_state = "light_on-[LAZYFIND(coloredlights, currentcolor)]"
		if(LIGHTFLOOR_FLICKER)
			icon_state = "light_on_flicker-[LAZYFIND(coloredlights, currentcolor)]"
		if(LIGHTFLOOR_BREAKING)
			icon_state = "light_on_broken"
		if(LIGHTFLOOR_BROKEN)
			icon_state = "light_off"
	return ..()

/turf/open/floor/light/ChangeTurf(path, new_baseturfs, flags)
	set_light(0)
	return ..()

/turf/open/floor/light/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	if(!can_modify_colour && !cycle)
		return
	on = !on
	update_appearance()

/turf/open/floor/light/multitool_act(mob/living/user, obj/item/I)
	. = ..()
	if(.)
		return
	if(!can_modify_colour)
		return FALSE
	var/choice = show_radial_menu(user,src, lighttile_designs, custom_check = CALLBACK(src, PROC_REF(check_menu), user, I), radius = 36, require_near = TRUE)
	if(!choice)
		return FALSE
	currentcolor = choice
	update_appearance()

/turf/open/floor/light/attackby(obj/item/C, mob/user, params)
	if(..())
		return
	if(istype(C, /obj/item/light/bulb)) //only for light tiles
		var/obj/item/light/bulb/B = C
		if(B.status)/// check if broken
			to_chat(user, span_danger("The light bulb is broken!"))
			return
		if(state && user.temporarilyRemoveItemFromInventory(C))
			qdel(C)
			state = LIGHTFLOOR_FINE //fixing it by bashing it with a light bulb, fun eh?
			update_appearance()
			to_chat(user, span_notice("You replace the light bulb."))
		else
			to_chat(user, span_notice("The light bulb seems fine, no need to replace it."))

/turf/open/floor/light/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	currentcolor = pick(coloredlights)
	if(state == LIGHTFLOOR_BROKEN)  /// he's dead, jim
		return
	if(prob(50))
		state++
	currentcolor = pick(coloredlights)
	update_appearance()

//Cycles through all of the colours
/turf/open/floor/light/colour_cycle
	name = "dancefloor"
	desc = "Funky floor."
	icon_state = "light_on-cycle_all"
	light_color = LIGHT_COLOR_SLIME_LAMP
	can_modify_colour = FALSE
	cycle = TRUE

//Two different "dancefloor" types so that you can have a checkered pattern
// (also has a longer delay than colour_cycle between cycling colours)
/turf/open/floor/light/colour_cycle/dancefloor_a
	icon_state = "light_on-dancefloor_A"

/turf/open/floor/light/colour_cycle/dancefloor_b
	icon_state = "light_on-dancefloor_B"

/**
 * check_menu: Checks if we are allowed to interact with a radial menu
 *
 * Arguments:
 * * user The mob interacting with a menu
 * * multitool The multitool used to interact with a menu
 */
/turf/open/floor/light/proc/check_menu(mob/living/user, obj/item/multitool)
	if(!istype(user))
		return FALSE
	if(user.incapacitated())
		return FALSE
	if(!multitool || !user.is_holding(multitool))
		return FALSE
	return TRUE

#undef LIGHTFLOOR_FINE
#undef LIGHTFLOOR_FLICKER
#undef LIGHTFLOOR_BREAKING
#undef LIGHTFLOOR_BROKEN
