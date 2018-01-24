/turf/open/floor/colorswitch
	name = "color switching floor"
	desc = "Seems to be multicolored!"
	icon = 'icons/turf/floors/colorcycle.dmi'
	var/list/possible_colors = list()
	var/base_state = ""
	var/seperator = "_"
	var/current_color = 1
	var/interact_modify_color = TRUE
	var/silicon_can_use = FALSE

/turf/open/floor/colorswitch/Initialize()
	. = ..()
	update_icon()

/turf/open/floor/colorswitch/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>There's a <b>small crack</b> on the edge of it.</span>")

/turf/open/floor/colorswitch/attack_ai(mob/user)
	if(silicon_can_use)
		attack_hand(user)

/turf/open/floor/colorswitch/update_icon()
	. = ..()
	if(!possible_colors.len)
		return
	current_color = CLAMP(current_color, 1, possible_colors.len)
	icon_state = "[base_state][seperator][possible_colors[current_color]]"

/turf/open/floor/colorswitch/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(!interact_modify_color)
		return
	if(!possible_colors.len)
		return
	increment()

/turf/open/floor/colorswitch/proc/increment(amount = 1)
	current_color += amount
	if(current_color < 1 || current_color > possible_colors.len)
		current_color = 1
	update_icon()

/turf/open/floor/colorswitch/break_tile()
	return

/turf/open/floor/colorswitch/light
	name = "light floor"
	desc = "A wired glass tile embedded into the floor."
	light_range = 5
	base_state = "light"
	floor_tile = /obj/item/stack/tile/light
	broken_states = list("light_broken")
	silicon_can_use = TRUE
	possible_colors = list("off", "red", "yellow", "green", "blue", "purple", "white", "cyan", "switch")

/turf/open/floor/colorswitch/light/update_icon()
	. = ..()
	if(current_color == 1)
		set_light(0)

/turf/open/floor/colorswitch/light/ChangeTurf(path, new_baseturf, flags)
	set_light(0)
	return ..()

//Cycles through all of the colours
/turf/open/floor/colorswitch/light/colour_cycle
	possible_colors = list("cycle_all")
	interact_modify_color = FALSE

/turf/open/floor/colorswitch/light/colour_cycle/rhythm
	name = "Rhythmic Floor"
	desc = "It makes you want to move your feet."

/turf/open/floor/colorswitch/light/colour_cycle/rhythm/a
	possible_colors = list("off", "purple")

/turf/open/floor/colorswitch/light/colour_cycle/rhythm/b
	possible_colors = list("green", "off")

//Two different "dancefloor" types so that you can have a checkered pattern
// (also has a longer delay than colour_cycle between cycling colours)
/turf/open/floor/colorswitch/light/colour_cycle/dancefloor_a
	name = "dancefloor"
	desc = "Funky floor."
	possible_colors = list("dancefloor_A")

/turf/open/floor/colorswitch/light/colour_cycle/dancefloor_b
	name = "dancefloor"
	desc = "Funky floor."
	possible_colors = list("dancefloor_B")
