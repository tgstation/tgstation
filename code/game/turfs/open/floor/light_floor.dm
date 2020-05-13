/turf/open/floor/light
	name = "light floor"
	desc = "A wired glass tile embedded into the floor. Modify the color with a Multitool."
	light_range = 5
	icon_state = "light_on-1"
	floor_tile = /obj/item/stack/tile/light
	broken_states = list("light_broken")
	///var to see if its on or off
	var/on = TRUE
	///0 = fine, 1 = flickering, 2 = breaking, 3 = broken
	var/state = 0
	///list of colours to choose
	var/static/list/coloredlights = list(LIGHT_COLOR_CYAN, LIGHT_COLOR_RED, LIGHT_COLOR_ORANGE, LIGHT_COLOR_GREEN, LIGHT_COLOR_YELLOW, LIGHT_COLOR_DARK_BLUE, LIGHT_COLOR_LAVENDER, LIGHT_COLOR_WHITE,  LIGHT_COLOR_SLIME_LAMP)
	///current light color
	var/currentcolor = LIGHT_COLOR_CYAN
	///var to prevent changing color on certain admin spawn only tiles
	var/can_modify_colour = TRUE
	tiled_dirt = FALSE
	///icons for radial menu
	var/static/list/lighttile_designs

/turf/open/floor/light/examine(mob/user)
	. = ..()
	. += "<span class='notice'>There's a <b>small crack</b> on the edge of it.</span>"
	. += "<span class='notice'>Use a multitool on it to change colors.</span>"
	if(state) ///check if broken
		. += "<span class='danger'>The light bulb seems fried!</span>"

///create radial menu
/turf/open/floor/light/proc/populate_lighttile_designs()
	lighttile_designs = list(
		LIGHT_COLOR_CYAN = image(icon = src.icon, icon_state = "light_on-1"),
		LIGHT_COLOR_RED = image(icon = src.icon, icon_state = "light_on-2"),
		LIGHT_COLOR_ORANGE = image(icon = src.icon, icon_state = "light_on-3"),
		LIGHT_COLOR_GREEN = image(icon = src.icon, icon_state = "light_on-4"),
		LIGHT_COLOR_YELLOW = image(icon = src.icon, icon_state = "light_on-5"),
		LIGHT_COLOR_DARK_BLUE = image(icon = src.icon, icon_state = "light_on-6"),
		LIGHT_COLOR_LAVENDER = image(icon = src.icon, icon_state = "light_on-7"),
		LIGHT_COLOR_WHITE = image(icon = src.icon, icon_state = "light_on-8"),
		LIGHT_COLOR_SLIME_LAMP = image(icon = src.icon, icon_state = "light_on-9"),
		)

/turf/open/floor/light/Initialize()
	. = ..()
	update_icon()
	if(!length(lighttile_designs))
		populate_lighttile_designs()

/turf/open/floor/light/break_tile()
	..()
	state = pick(1,2,3)/// pick a broken state
	update_icon()

/turf/open/floor/light/update_icon()
	..()
	if(on)
		switch(state)
			if(0)
				icon_state = "light_on-[LAZYFIND(coloredlights, currentcolor)]"
				light_color = currentcolor
				set_light(5)
				light_range = 3
			if(1)
				icon_state = "light_on_flicker-[LAZYFIND(coloredlights, currentcolor)]"
				light_color = currentcolor
				set_light(3)
				light_range = 2
			if(2)
				icon_state = "light_on_broken"
				set_light(1)
			if(3)
				icon_state = "light_off"
				set_light(0)
	else
		set_light(0)
		icon_state = "light_off"

/turf/open/floor/light/ChangeTurf(path, new_baseturf, flags)
	set_light(0)
	return ..()

/turf/open/floor/light/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(!can_modify_colour)
		return
	on = !on
	update_icon()

/turf/open/floor/light/attack_ai(mob/user)
	return attack_hand(user)

/turf/open/floor/light/multitool_act(mob/living/user, obj/item/I)
	. = ..()
	if(.)
		return
	if(!can_modify_colour)
		return FALSE
	var/choice = show_radial_menu(user,src, lighttile_designs, custom_check = CALLBACK(src, .proc/check_menu, user, I), radius = 36, require_near = TRUE)
	if(!choice)
		return FALSE
	currentcolor = choice
	update_icon()

/turf/open/floor/light/attackby(obj/item/C, mob/user, params)
	if(..())
		return
	if(istype(C, /obj/item/light/bulb)) //only for light tiles
		var/obj/item/light/bulb/B = C
		if(B.status)/// check if broken
			to_chat(user, "<span class='danger'>The light bulb is broken!</span>")
			return
		if(state && user.temporarilyRemoveItemFromInventory(C))
			qdel(C)
			state = 0 //fixing it by bashing it with a light bulb, fun eh?
			update_icon()
			to_chat(user, "<span class='notice'>You replace the light bulb.</span>")
		else
			to_chat(user, "<span class='notice'>The light bulb seems fine, no need to replace it.</span>")

/turf/open/floor/light/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	currentcolor = pick(coloredlights)
	state = pick(0,0,0,1,2,3)/// 50% chance of not breaking
	update_icon()

//Cycles through all of the colours
/turf/open/floor/light/colour_cycle
	icon_state = "cycle_all"
	light_color = LIGHT_COLOR_SLIME_LAMP
	can_modify_colour = FALSE

//Two different "dancefloor" types so that you can have a checkered pattern
// (also has a longer delay than colour_cycle between cycling colours)
/turf/open/floor/light/colour_cycle/dancefloor_a
	name = "dancefloor"
	desc = "Funky floor."
	icon_state = "light_on-dancefloor_A"
	light_color =LIGHT_COLOR_SLIME_LAMP
	can_modify_colour = FALSE

/turf/open/floor/light/colour_cycle/dancefloor_b
	name = "dancefloor"
	desc = "Funky floor."
	icon_state = "light_on-dancefloor_B"
	light_color = LIGHT_COLOR_SLIME_LAMP
	can_modify_colour = FALSE

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
