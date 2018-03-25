/*
	MouseDrop:

	Called on the atom you're dragging.  In a lot of circumstances we want to use the
	recieving object instead, so that's the default action.  This allows you to drag
	almost anything into a trash can.
*/
/atom/MouseDrop(atom/over, src_location, over_location, src_control, over_control, params)
	if(!usr || !over)
		return
	if(SendSignal(COMSIG_MOUSEDROP_ONTO, over, usr) & COMPONENT_NO_MOUSEDROP)	//Whatever is recieving will verify themselves for adjacency.
		return
	if(over == src)
		return usr.client.Click(src, src_location, src_control, params)
	if(!Adjacent(usr) || !over.Adjacent(usr))
		return // should stop you from dragging through windows

	over.MouseDrop_T(src,usr)
	return

// recieve a mousedrop
/atom/proc/MouseDrop_T(atom/dropping, mob/user)
	SendSignal(COMSIG_MOUSEDROPPED_ONTO, dropping, user)
	return
