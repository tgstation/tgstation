/turf/open/floor/light
	name = "light floor"
	desc = "A wired glass tile embedded into the floor. Modify the color with a Multitool."
	light_range = 5
	icon_state = "light_on"
	floor_tile = /obj/item/stack/tile/light
	broken_states = list("light_broken")
	var/on = TRUE
	var/state = 0//0 = fine, 1 = flickering, 2 = breaking, 3 = broken
	var/static/list/coloredlights = list("r", "o", "y", "g", "b", "i", "v", "w", "s", "z")
	var/currentcolor = "b"
	var/can_modify_colour = TRUE
	tiled_dirt = FALSE
	var/static/list/lighttile_designs

/turf/open/floor/light/examine(mob/user)
	. = ..()
	. += "<span class='notice'>There's a <b>small crack</b> on the edge of it.</span>"

/turf/open/floor/light/proc/populate_lighttile_designs()
	lighttile_designs = list(
		"r" = image(icon = src.icon, icon_state = "light_on-r"),
		"o" = image(icon = src.icon, icon_state = "light_on-o"),
		"y" = image(icon = src.icon, icon_state = "light_on-y"),
		"g" = image(icon = src.icon, icon_state = "light_on-g"),
		"b" = image(icon = src.icon, icon_state = "light_on-b"),
		"i" = image(icon = src.icon, icon_state = "light_on-i"),
		"v" = image(icon = src.icon, icon_state = "light_on-v"),
		"w" = image(icon = src.icon, icon_state = "light_on-w"),
		"blk" = image(icon = src.icon, icon_state = "light_on-blk"),
		"s" = image(icon = src.icon, icon_state = "light_on-s"),
		"z" = image(icon = src.icon, icon_state = "light_on-z")
		)

/turf/open/floor/light/Initialize()
	. = ..()
	update_icon()
	if(!length(lighttile_designs))
		populate_lighttile_designs()

/turf/open/floor/light/break_tile()
	..()
	light_range = 0
	update_light()

/turf/open/floor/light/update_icon()
	..()
	if(on)
		switch(state)
			if(0)
				icon_state = "light_on-[currentcolor]"
				set_light(1)
			if(1)
				var/num = pick("1","2","3","4")
				icon_state = "light_on_flicker[num]"
				set_light(1)
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

/turf/open/floor/light/multitool_act(mob/living/user, obj/item/I)
	. = ..()
	if(.)
		return
	if(!can_modify_colour)
		return
	var/choice = show_radial_menu(user,src, lighttile_designs, custom_check = CALLBACK(src, .proc/check_menu, user, I), radius = 36, require_near = TRUE)
	if(!choice)
		return FALSE
	currentcolor = choice
	update_icon()

/turf/open/floor/light/attack_ai(mob/user)
	return attack_hand(user)

/turf/open/floor/light/attackby(obj/item/C, mob/user, params)
	if(..())
		return
	if(istype(C, /obj/item/light/bulb)) //only for light tiles
		if(state && user.temporarilyRemoveItemFromInventory(C))
			qdel(C)
			state = 0 //fixing it by bashing it with a light bulb, fun eh?
			update_icon()
			to_chat(user, "<span class='notice'>You replace the light bulb.</span>")
		else
			to_chat(user, "<span class='notice'>The light bulb seems fine, no need to replace it.</span>")


//Cycles through all of the colours
/turf/open/floor/light/colour_cycle
	currentcolor = "cycle_all"
	can_modify_colour = FALSE



//Two different "dancefloor" types so that you can have a checkered pattern
// (also has a longer delay than colour_cycle between cycling colours)
/turf/open/floor/light/colour_cycle/dancefloor_a
	name = "dancefloor"
	desc = "Funky floor."
	currentcolor = "dancefloor_A"

/turf/open/floor/light/colour_cycle/dancefloor_b
	name = "dancefloor"
	desc = "Funky floor."
	currentcolor = "dancefloor_A"

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
