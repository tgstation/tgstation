/obj/item/pipe_planner
	name = "pipe planner"
	desc = "A lightweight frame for placing and aligning piping before it is fixed down."

	icon = 'icons/obj/pipe-item.dmi'
	icon_state = "pipe-planner"

	w_class = 4

	var/datum/context_click/pipe_planner/planner

	layer = OBJ_LAYER + (PIPING_LAYER_MIN - (PIPING_LAYER_DEFAULT + PIPING_LAYER_INCREMENT)) * PIPING_LAYER_LCHANGE

/obj/item/pipe_planner/New()
	..()
	planner = new(src)

/obj/item/pipe_planner/attackby(var/obj/item/I, mob/user, params)
	if(get_turf(src) == src.loc)
		return planner.action(I, user, params)
	return ..()

/obj/item/pipe_planner/attack_self(mob/user)
	dir = turn(dir, 90)
	..()

/datum/context_click/pipe_planner/return_clicked_id(var/x_pos, var/y_pos)
	var/found_id = 0

	var/temp_dis = 0
	var/temp_mod = 0
	if(holder.dir & (EAST|WEST))
		temp_dis = x_pos
		temp_mod = PIPING_LAYER_P_X
	else
		temp_dis = y_pos
		temp_mod = PIPING_LAYER_P_Y

	if(temp_dis - 16 == 0)
		return 0

	found_id = Floor(abs(temp_dis - 16), abs(temp_mod)) / (temp_mod * sign(temp_dis - 16))

	return found_id

/datum/context_click/pipe_planner/action(obj/item/used_item, mob/user, params)
	if(istype(used_item, /obj/item/pipe))
		var/obj/item/pipe/pipe = used_item
		if(user.drop_item(pipe, get_turf(holder)))
			var/dis = PIPING_LAYER_DEFAULT + (PIPING_LAYER_INCREMENT * return_clicked_id_by_params(params))
			pipe.setPipingLayer(dis)
			return 1
	return 0