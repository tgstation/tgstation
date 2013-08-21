
/atom/MouseDrop(atom/over)
	if(!usr || !over) return
	if(!Adjacent(usr) || !over.Adjacent(usr)) return // should stop you from dragging through windows

	spawn(0)
		over.MouseDrop_T(src,usr)
	return

// recieve a mousedrop
/atom/proc/MouseDrop_T(atom/dropping, mob/user)
	return
