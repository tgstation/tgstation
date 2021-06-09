/datum/buildmode_mode/delete
	key = "delete"

/datum/buildmode_mode/delete/show_help(client/c)
	to_chat(c, "<span class='notice'>***********************************************************\n\
		Left Mouse Button on anything to delete it. If you break it, you buy it.\n\
		Right Mouse Button on anything to delete everything of the type. Probably don\'t do this unless you know what you are doing.\n\
		***********************************************************</span>")

/datum/buildmode_mode/delete/handle_click(client/c, params, object)
	var/list/modifiers = params2list(params)

	if(LAZYACCESS(modifiers, LEFT_CLICK))
		if(isturf(object))
			var/turf/T = object
			T.ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
		else if(isatom(object))
			qdel(object)

	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		if(check_rights(R_DEBUG|R_SERVER)) //Prevents buildmoded non-admins from breaking everything.
			if(isturf(object))
				return
			var/atom/deleting = object
			var/action_type = tgui_alert(usr,"Strict type ([deleting.type]) or type and all subtypes?",,list("Strict type","Type and subtypes","Cancel"))
			if(action_type == "Cancel" || !action_type)
				return

			if(tgui_alert(usr,"Are you really sure you want to delete all instances of type [deleting.type]?",,list("Yes","No")) != "Yes")
				return

			if(tgui_alert(usr,"Second confirmation required. Delete?",,list("Yes","No")) != "Yes")
				return

			var/O_type = deleting.type
			switch(action_type)
				if("Strict type")
					var/i = 0
					for(var/atom/Obj in world)
						if(Obj.type == O_type)
							i++
							qdel(Obj)
						CHECK_TICK
					if(!i)
						to_chat(usr, "No instances of this type exist")
						return
					log_admin("[key_name(usr)] deleted all instances of type [O_type] ([i] instances deleted) ")
					message_admins("<span class='notice'>[key_name(usr)] deleted all instances of type [O_type] ([i] instances deleted) </span>")
				if("Type and subtypes")
					var/i = 0
					for(var/Obj in world)
						if(istype(Obj,O_type))
							i++
							qdel(Obj)
						CHECK_TICK
					if(!i)
						to_chat(usr, "No instances of this type exist")
						return
					log_admin("[key_name(usr)] deleted all instances of type or subtype of [O_type] ([i] instances deleted) ")
					message_admins("<span class='notice'>[key_name(usr)] deleted all instances of type or subtype of [O_type] ([i] instances deleted) </span>")
