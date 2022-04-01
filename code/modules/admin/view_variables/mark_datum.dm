/client/proc/mark_datum(datum/D)
	if(!holder)
		return
	if(holder.marked_datum)
		holder.unregister_signal(holder.marked_datum, COMSIG_PARENT_QDELETING)
		vv_update_display(holder.marked_datum, "marked", "")
	holder.marked_datum = D
	holder.register_signal(holder.marked_datum, COMSIG_PARENT_QDELETING, /datum/admins/proc/handle_marked_del)
	vv_update_display(D, "marked", VV_MSG_MARKED)

/client/proc/mark_datum_mapview(datum/D as mob|obj|turf|area in view(view))
	set category = "Debug"
	set name = "Mark Object"
	mark_datum(D)

/datum/admins/proc/handle_marked_del(datum/source)
	SIGNAL_HANDLER
	unregister_signal(marked_datum, COMSIG_PARENT_QDELETING)
	marked_datum = null
