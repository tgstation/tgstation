/// Called when alt clicked and the item has unique reskin options
/obj/item/proc/on_click_alt_reskin(datum/source, mob/user)
	SIGNAL_HANDLER

	if(!user.can_perform_action(src, NEED_DEXTERITY))
		return NONE

	if(!(obj_flags & INFINITE_RESKIN) && current_skin)
		return NONE

	INVOKE_ASYNC(src, PROC_REF(reskin_obj), user)
	return CLICK_ACTION_SUCCESS


/**
 * Reskins object based on a user's choice
 *
 * Arguments:
 * * M The mob choosing a reskin option
 */
/obj/item/proc/reskin_obj(mob/user)
	if(!LAZYLEN(unique_reskin))
		return

	var/list/items = list()
	for(var/reskin_option in unique_reskin)
		var/image/item_image = image(icon = src.icon, icon_state = unique_reskin[reskin_option])
		items += list("[reskin_option]" = item_image)
	sort_list(items)

	var/pick = show_radial_menu(user, src, items, custom_check = CALLBACK(src, PROC_REF(check_reskin_menu), user), radius = 38, require_near = TRUE)
	if(!pick)
		return
	if(!unique_reskin[pick])
		return
	current_skin = pick
	icon_state = unique_reskin[pick]
	to_chat(user, "[src] is now skinned as '[pick].'")
	SEND_SIGNAL(src, COMSIG_OBJ_RESKIN, user, pick)


/**
 * Checks if we are allowed to interact with a radial menu for reskins
 *
 * Arguments:
 * * user The mob interacting with the menu
 */
/obj/item/proc/check_reskin_menu(mob/user)
	if(QDELETED(src))
		return FALSE
	if(!(obj_flags & INFINITE_RESKIN) && current_skin)
		return FALSE
	if(!istype(user))
		return FALSE
	if(user.incapacitated())
		return FALSE
	return TRUE
