///Very simplistic element. Basically only makes it so that if you mousedrop a held item onto parent, it gets moved to that location.
///Eventually, one could outsource all table behaviour to this. Be it tableing or CanPass().
/datum/element/tablebehaviour

/datum/element/tablebehaviour/Attach(datum/target)
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, list(COMSIG_MOUSEDROPPED_ONTO), .proc/on_MouseDrop_T)

/datum/element/tablebehaviour/proc/on_MouseDrop_T(atom/target, atom/movable/O, mob/user)
	if(user.get_active_held_item() != O)
		return
	if(iscyborg(user))
		return
	if(!user.dropItemToGround(O))
		return
	if(O.loc != target.loc)
		O.forceMove(target.loc) //feck it, let people move stuff into walls. They can do that with normal attack hand too.
