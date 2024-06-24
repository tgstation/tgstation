/obj/structure/wall_torch
	name = "mounted torch"
	desc = "A simple torch mounted to the wall, for lighting and such."
	icon = 'monkestation/code/modules/blueshift/icons/lighting.dmi'
	icon_state = "walltorch"
	base_icon_state = "walltorch"
	anchored = TRUE
	density = FALSE
	light_color = LIGHT_COLOR_FIRE
	/// is the bonfire lit?
	var/burning = FALSE
	/// Does this torch spawn pre-lit?
	var/spawns_lit = FALSE

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/wall_torch, 28)

/obj/structure/wall_torch/Initialize(mapload)
	. = ..()
	if(spawns_lit)
		light_it_up()
	find_and_hang_on_wall()

/obj/structure/wall_torch/attackby(obj/item/used_item, mob/living/user, params)
	if(used_item.get_temperature())
		light_it_up()
	else
		return ..()

/obj/structure/wall_torch/fire_act(exposed_temperature, exposed_volume)
	light_it_up()

/// Sets the torch's icon to burning and sets the light up
/obj/structure/wall_torch/proc/light_it_up()
	icon_state = "[base_icon_state]_on"
	burning = TRUE
	set_light(4)
	update_appearance(UPDATE_ICON)

/obj/structure/wall_torch/extinguish()
	. = ..()
	if(!burning)
		return
	icon_state = base_icon_state
	burning = FALSE
	set_light(0)
	update_appearance(UPDATE_ICON)

/obj/structure/wall_torch/spawns_lit
	spawns_lit = TRUE

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/wall_torch/spawns_lit, 28)
