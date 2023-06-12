/client/proc/mark_datum(datum/D)
	if(!holder)
		return
	if(holder.marked_datum)
		holder.UnregisterSignal(holder.marked_datum, COMSIG_PARENT_QDELETING)
		vv_update_display(holder.marked_datum, "marked", "")
	holder.marked_datum = D
	holder.RegisterSignal(holder.marked_datum, COMSIG_PARENT_QDELETING, TYPE_PROC_REF(/datum/admins, handle_marked_del))
	vv_update_display(D, "marked", VV_MSG_MARKED)

/client/proc/mark_datum_mapview(datum/D as mob|obj|turf|area in view(view))
	set category = "Debug"
	set name = "Mark Object"
	mark_datum(D)

/datum/admins/proc/handle_marked_del(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(marked_datum, COMSIG_PARENT_QDELETING)
	marked_datum = null
