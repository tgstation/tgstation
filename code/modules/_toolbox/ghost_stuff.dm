/*ghost role list is already in the new tg source.
GLOBAL_LIST_EMPTY(ghost_roles)
/mob/dead/observer/verb/check_ghost_roles()
	set name = "Check Ghost Roles"
	set category = "Ghost"
	if(!client)
		return
	if(!GLOB.ghost_roles.len)
		to_chat(src,"<font color='red'>There are no ghost roles.</font>")
		return
	var/list/roles = list()
	for(var/E in GLOB.ghost_roles)
		if(E == null)
			GLOB.ghost_roles -= E
			continue
		if(istype(E,/atom))
			var/atom/A = E
			if(!A.loc)
				continue
			var/nametext = "[A.name]"
			if(istype(A,/obj/effect/mob_spawn))
				var/obj/effect/mob_spawn/S = A
				if(S.uses == 0)
					continue
				if(S.assignedrole)
					nametext = "[S.assignedrole]"
			roles[A] = "[nametext]"
	var/dat = "<B>List of ghost roles:<B><BR>"
	for(var/atom/A in roles)
		dat += "[roles[A]] <a href='?src=\ref[src];role=\ref[A]'>Activate</a> - <a href='?src=\ref[src];jmptorole=\ref[A]'>Jump to</a><BR>"
	client << browse(dat,"window=ghost_roles;size=500x500")*/