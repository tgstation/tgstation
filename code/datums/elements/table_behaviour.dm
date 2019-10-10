///Very simplistic element. Basically only makes it so that if you mousedrop a held item onto parent, it gets moved to that location.
///Eventually, one could outsource all table behaviour to this. Be it tableing or CanPass().
/datum/element/tablebehaviour

/datum/element/tablebehaviour/Attach(datum/target)
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, list(COMSIG_MOUSEDROPPED_ONTO), .proc/on_MouseDrop_T)
	RegisterSignal(target, list(COMSIG_PARENT_ATTACKBY), .proc/on_AttackedBy)

/datum/element/tablebehaviour/proc/on_MouseDrop_T(atom/target, atom/movable/O, mob/user)
	if(user.get_active_held_item() != O)
		return
	if(iscyborg(user))
		return
	if(!user.dropItemToGround(O))
		return
	if(O.loc != target.loc)
		O.forceMove(target.loc) //feck it, let people move stuff into walls. They can do that with normal attack hand too.

/datum/element/tablebehaviour/proc/on_AttackedBy(atom/target, mob/user, obj/item/item)
	if(istype(I, /obj/item/storage/bag/tray))
		var/obj/item/storage/bag/tray/T = I
		if(T.contents.len > 0) // If the tray isn't empty
			SEND_SIGNAL(I, COMSIG_TRY_STORAGE_QUICK_EMPTY, target.drop_location())
			user.visible_message("<span class='notice'>[user] empties [I] on [target].</span>")
			return
		// If the tray IS empty, continue on (tray will be placed on the table like other items)

	if(user.a_intent != INTENT_HARM && !(I.item_flags & ABSTRACT))
		if(user.transferItemToLoc(I, target.drop_location(), silent = FALSE))
			var/list/click_params = params2list(params)
			//Center the icon where the user clicked.
			if(!click_params || !click_params["icon-x"] || !click_params["icon-y"])
				return
			//Clamp it so that the icon never moves more than 16 pixels in either direction (thus leaving the table turf)
			I.pixel_x = CLAMP(text2num(click_params["icon-x"]) - 16, -(world.icon_size/2), world.icon_size/2)
			I.pixel_y = CLAMP(text2num(click_params["icon-y"]) - 16, -(world.icon_size/2), world.icon_size/2)
			return COMPONENT_NO_AFTERATTACK 
