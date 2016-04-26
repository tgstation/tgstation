/*/////////////////////
CONTEXT CLICKING:
The datum is a contextual click handler for on-item behaviour
It allows you to assign IDs and click locations to various parts of an item
IDs can then be used to cause certain behaviour using the action() proc
*//////////////////////

/datum/context_click
	var/obj/holder

/datum/context_click/New(to_hold)
	..()
	holder = to_hold

//Gives the id clicked in this particular handler
/datum/context_click/proc/return_clicked_id(var/x_pos, var/y_pos)
	return

//Helper for using params
/datum/context_click/proc/return_clicked_id_by_params(params)
	if(!params)
		return

	var/list/params_list = params2list(params)
	var/x_pos_clicked = Clamp(text2num(params_list["icon-x"]), 1, 32)
	var/y_pos_clicked = Clamp(text2num(params_list["icon-y"]), 1, 32)

	return return_clicked_id(x_pos_clicked, y_pos_clicked)

////ACTIONS////
//This is what you call when you want to hook into the handler
//Combine params with return_clicked_id_by_params
/datum/context_click/proc/action(obj/item/used_item, mob/user, params)
	return
