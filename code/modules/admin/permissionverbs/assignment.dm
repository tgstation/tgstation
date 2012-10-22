


//Before this proc is called, the holder variable must already be set, with the proper rank, level and permissions set.
//This proc also DOES NOT CLEAR EXISTING ADMIN VERBS

/client/proc/handle_permission_verbs()
	if(!holder || !holder.rank || !holder.sql_permissions)
		return

	if(holder.sql_permissions & PERMISSIONS)
		verbs += /client/proc/edit_admin_permissions