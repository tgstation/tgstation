/client/proc/cmd_mass_modify_object_variables(atom/A, var/var_name)
	set category = "Debug"
	set name = "Mass Edit Variables"
	set desc="(target) Edit all instances of a target item's variables"

	var/method = 0	//0 means strict type detection while 1 means this type and all subtypes (IE: /obj/item with this set to 1 will set it to ALL itms)

	if(A && A.type)
		if(typesof(A.type))
			switch(input("Strict object type detection?") as null|anything in list("Strictly this type","This type and subtypes", "Cancel"))
				if("Strictly this type")
					method = 0
				if("This type and subtypes")
					method = 1
				if("Cancel")
					return
				if(null)
					return

	src.massmodify_variables(A, var_name, method)
	feedback_add_details("admin_verb","MEV") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/massmodify_variables(var/atom/O, var/var_name = "", var/method = 0)
	var/list/locked = list("vars", "key", "ckey", "client")

	if(!src.holder)
		src << "Only administrators may use this command."
		return

	for(var/p in forbidden_varedit_object_types)
		if( istype(O,p) )
			usr << "\red It is forbidden to edit this object's variables."
			return

	var/list/names = list()
	for (var/V in O.vars)
		names += V

	names = sortList(names)

	var/variable = ""

	if(!var_name)
		variable = input("Which var?","Var") as null|anything in names
	else
		variable = var_name

	if(!variable)
		return
	var/default
	var/var_value = O.vars[variable]
	var/dir

	if (locked.Find(variable) && !(src.holder.rank in list("Game Master", "Game Admin")))
		return

	if (variable == "holder" && holder.rank != "Game Master") //Hotfix, a bit ugly but that exploit has been there for ages and now somebody just had to go and tell everyone of it bluh bluh - U
		return

	if(isnull(var_value))
		usr << "Unable to determine variable type."

	else if(isnum(var_value))
		usr << "Variable appears to be <b>NUM</b>."
		default = "num"
		dir = 1

	else if(istext(var_value))
		usr << "Variable appears to be <b>TEXT</b>."
		default = "text"

	else if(isloc(var_value))
		usr << "Variable appears to be <b>REFERENCE</b>."
		default = "reference"

	else if(isicon(var_value))
		usr << "Variable appears to be <b>ICON</b>."
		var_value = "\icon[var_value]"
		default = "icon"

	else if(istype(var_value,/atom) || istype(var_value,/datum))
		usr << "Variable appears to be <b>TYPE</b>."
		default = "type"

	else if(istype(var_value,/list))
		usr << "Variable appears to be <b>LIST</b>."
		default = "list"

	else if(istype(var_value,/client))
		usr << "Variable appears to be <b>CLIENT</b>."
		default = "cancel"

	else
		usr << "Variable appears to be <b>FILE</b>."
		default = "file"

	usr << "Variable contains: [var_value]"
	if(dir)
		switch(var_value)
			if(1)
				dir = "NORTH"
			if(2)
				dir = "SOUTH"
			if(4)
				dir = "EAST"
			if(8)
				dir = "WEST"
			if(5)
				dir = "NORTHEAST"
			if(6)
				dir = "SOUTHEAST"
			if(9)
				dir = "NORTHWEST"
			if(10)
				dir = "SOUTHWEST"
			else
				dir = null
		if(dir)
			usr << "If a direction, direction is: [dir]"

	var/class = input("What kind of variable?","Variable Type",default) as null|anything in list("text",
		"num","type","icon","file","edit referenced object","restore to default")

	if(!class)
		return

	var/original_name

	if (!istype(O, /atom))
		original_name = "\ref[O] ([O])"
	else
		original_name = O:name

	switch(class)

		if("restore to default")
			O.vars[variable] = initial(O.vars[variable])
			if(method)
				if(istype(O, /mob))
					for(var/mob/M in mob_list)
						if ( istype(M , O.type) )
							M.vars[variable] = O.vars[variable]

				else if(istype(O, /obj))
					for(var/obj/A in world)
						if ( istype(A , O.type) )
							A.vars[variable] = O.vars[variable]

				else if(istype(O, /turf))
					for(var/turf/A in world)
						if ( istype(A , O.type) )
							A.vars[variable] = O.vars[variable]

			else
				if(istype(O, /mob))
					for(var/mob/M in mob_list)
						if (M.type == O.type)
							M.vars[variable] = O.vars[variable]

				else if(istype(O, /obj))
					for(var/obj/A in world)
						if (A.type == O.type)
							A.vars[variable] = O.vars[variable]

				else if(istype(O, /turf))
					for(var/turf/A in world)
						if (A.type == O.type)
							A.vars[variable] = O.vars[variable]

		if("edit referenced object")
			return .(O.vars[variable])

		if("text")
			var/new_value = input("Enter new text:","Text",O.vars[variable]) as text|null
			if(new_value == null) return
			O.vars[variable] = new_value

			if(method)
				if(istype(O, /mob))
					for(var/mob/M in mob_list)
						if ( istype(M , O.type) )
							M.vars[variable] = O.vars[variable]

				else if(istype(O, /obj))
					for(var/obj/A in world)
						if ( istype(A , O.type) )
							A.vars[variable] = O.vars[variable]

				else if(istype(O, /turf))
					for(var/turf/A in world)
						if ( istype(A , O.type) )
							A.vars[variable] = O.vars[variable]
			else
				if(istype(O, /mob))
					for(var/mob/M in mob_list)
						if (M.type == O.type)
							M.vars[variable] = O.vars[variable]

				else if(istype(O, /obj))
					for(var/obj/A in world)
						if (A.type == O.type)
							A.vars[variable] = O.vars[variable]

				else if(istype(O, /turf))
					for(var/turf/A in world)
						if (A.type == O.type)
							A.vars[variable] = O.vars[variable]

		if("num")
			var/new_value = input("Enter new number:","Num",\
					O.vars[variable]) as num|null
			if(new_value == null) return

			if(variable=="luminosity")
				O.sd_SetLuminosity(new_value)
			else
				O.vars[variable] = new_value

			if(method)
				if(istype(O, /mob))
					for(var/mob/M in mob_list)
						if ( istype(M , O.type) )
							if(variable=="luminosity")
								M.sd_SetLuminosity(new_value)
							else
								M.vars[variable] = O.vars[variable]

				else if(istype(O, /obj))
					for(var/obj/A in world)
						if ( istype(A , O.type) )
							if(variable=="luminosity")
								A.sd_SetLuminosity(new_value)
							else
								A.vars[variable] = O.vars[variable]

				else if(istype(O, /turf))
					for(var/turf/A in world)
						if ( istype(A , O.type) )
							if(variable=="luminosity")
								A.sd_SetLuminosity(new_value)
							else
								A.vars[variable] = O.vars[variable]

			else
				if(istype(O, /mob))
					for(var/mob/M in mob_list)
						if (M.type == O.type)
							if(variable=="luminosity")
								M.sd_SetLuminosity(new_value)
							else
								M.vars[variable] = O.vars[variable]

				else if(istype(O, /obj))
					for(var/obj/A in world)
						if (A.type == O.type)
							if(variable=="luminosity")
								A.sd_SetLuminosity(new_value)
							else
								A.vars[variable] = O.vars[variable]

				else if(istype(O, /turf))
					for(var/turf/A in world)
						if (A.type == O.type)
							if(variable=="luminosity")
								A.sd_SetLuminosity(new_value)
							else
								A.vars[variable] = O.vars[variable]

		if("type")
			var/new_value
			new_value = input("Enter type:","Type",O.vars[variable]) as null|anything in typesof(/obj,/mob,/area,/turf)
			if(new_value == null) return
			O.vars[variable] = new_value
			if(method)
				if(istype(O, /mob))
					for(var/mob/M in mob_list)
						if ( istype(M , O.type) )
							M.vars[variable] = O.vars[variable]

				else if(istype(O, /obj))
					for(var/obj/A in world)
						if ( istype(A , O.type) )
							A.vars[variable] = O.vars[variable]

				else if(istype(O, /turf))
					for(var/turf/A in world)
						if ( istype(A , O.type) )
							A.vars[variable] = O.vars[variable]
			else
				if(istype(O, /mob))
					for(var/mob/M in mob_list)
						if (M.type == O.type)
							M.vars[variable] = O.vars[variable]

				else if(istype(O, /obj))
					for(var/obj/A in world)
						if (A.type == O.type)
							A.vars[variable] = O.vars[variable]

				else if(istype(O, /turf))
					for(var/turf/A in world)
						if (A.type == O.type)
							A.vars[variable] = O.vars[variable]

		if("file")
			var/new_value = input("Pick file:","File",O.vars[variable]) as null|file
			if(new_value == null) return
			O.vars[variable] = new_value

			if(method)
				if(istype(O, /mob))
					for(var/mob/M in mob_list)
						if ( istype(M , O.type) )
							M.vars[variable] = O.vars[variable]

				else if(istype(O.type, /obj))
					for(var/obj/A in world)
						if ( istype(A , O.type) )
							A.vars[variable] = O.vars[variable]

				else if(istype(O.type, /turf))
					for(var/turf/A in world)
						if ( istype(A , O.type) )
							A.vars[variable] = O.vars[variable]
			else
				if(istype(O, /mob))
					for(var/mob/M in mob_list)
						if (M.type == O.type)
							M.vars[variable] = O.vars[variable]

				else if(istype(O.type, /obj))
					for(var/obj/A in world)
						if (A.type == O.type)
							A.vars[variable] = O.vars[variable]

				else if(istype(O.type, /turf))
					for(var/turf/A in world)
						if (A.type == O.type)
							A.vars[variable] = O.vars[variable]

		if("icon")
			var/new_value = input("Pick icon:","Icon",O.vars[variable]) as null|icon
			if(new_value == null) return
			O.vars[variable] = new_value
			if(method)
				if(istype(O, /mob))
					for(var/mob/M in mob_list)
						if ( istype(M , O.type) )
							M.vars[variable] = O.vars[variable]

				else if(istype(O, /obj))
					for(var/obj/A in world)
						if ( istype(A , O.type) )
							A.vars[variable] = O.vars[variable]

				else if(istype(O, /turf))
					for(var/turf/A in world)
						if ( istype(A , O.type) )
							A.vars[variable] = O.vars[variable]

			else
				if(istype(O, /mob))
					for(var/mob/M in mob_list)
						if (M.type == O.type)
							M.vars[variable] = O.vars[variable]

				else if(istype(O, /obj))
					for(var/obj/A in world)
						if (A.type == O.type)
							A.vars[variable] = O.vars[variable]

				else if(istype(O, /turf))
					for(var/turf/A in world)
						if (A.type == O.type)
							A.vars[variable] = O.vars[variable]

	log_admin("[key_name(src)] mass modified [original_name]'s [variable] to [O.vars[variable]]")
	message_admins("[key_name_admin(src)] mass modified [original_name]'s [variable] to [O.vars[variable]]", 1)