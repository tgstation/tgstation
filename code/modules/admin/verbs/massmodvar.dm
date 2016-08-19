/client/proc/cmd_mass_modify_object_variables(atom/A, var_name)
	set category = "Debug"
	set name = "Mass Edit Variables"
	set desc="(target) Edit all instances of a target item's variables"

	var/method = 0	//0 means strict type detection while 1 means this type and all subtypes (IE: /obj/item with this set to 1 will set it to ALL itms)

	if(!check_rights(R_VAREDIT))	return

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


/client/proc/massmodify_variables(atom/O, var_name = "", method = 0)
	if(!check_rights(R_VAREDIT))	return

	for(var/p in forbidden_varedit_object_types)
		if( istype(O,p) )
			usr << "<span class='danger'>It is forbidden to edit this object's variables.</span>"
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

	if(!variable)	return
	var/default
	var/var_value = O.vars[variable]
	var/dir

	if(variable in VVckey_edit)
		usr << "It's forbidden to mass-modify ckeys. I'll crash everyone's client you dummy."
		return
	if(variable in VVlocked)
		if(!check_rights(R_DEBUG))	return
	if(variable in VVicon_edit_lock)
		if(!check_rights(R_FUN|R_DEBUG)) return

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
			var/new_value = input("Enter new text:","Text",O.vars[variable]) as message|null
			if(new_value == null) return

			var/process_vars = 0
			var/unique = 0
			if(findtext(new_value,"\["))
				process_vars = alert(usr,"\[] detected in string, process as variables?","Process Variables?","Yes","No")
				if(process_vars == "Yes")
					process_vars = 1
					unique = alert(usr,"Process vars unique to each instance, or same for all?","Variable Association","Unique","Same")
					if(unique == "Unique")
						unique = 1
					else
						unique = 0
				else
					process_vars = 0

			var/pre_processing = new_value
			var/list/varsvars = list()

			if(process_vars)
				varsvars = string2listofvars(new_value, O)
				if(varsvars.len)
					for(var/V in varsvars)
						new_value = replacetext(new_value,"\[[V]]","[O.vars[V]]")

			O.vars[variable] = new_value

			//Convert the string vars for anything that's not O
			if(method)
				if(istype(O, /mob))
					for(var/mob/M in mob_list)
						if ( istype(M , O.type) )
							new_value = pre_processing //reset new_value, ready to convert it uniquely for the next iteration

							if(process_vars)
								if(unique)
									for(var/V in varsvars)
										new_value = replacetext(new_value,"\[[V]]","[M.vars[V]]")
								else
									new_value = O.vars[variable] //We already processed the non-unique form for O, reuse it

							M.vars[variable] = new_value

				else if(istype(O, /obj))
					for(var/obj/A in world)
						if ( istype(A , O.type) )
							new_value = pre_processing

							if(process_vars)
								if(unique)
									for(var/V in varsvars)
										new_value = replacetext(new_value,"\[[V]]","[A.vars[V]]")
								else
									new_value = O.vars[variable]

							A.vars[variable] = new_value

				else if(istype(O, /turf))
					for(var/turf/A in world)
						if ( istype(A , O.type) )
							new_value = pre_processing

							if(process_vars)
								if(unique)
									for(var/V in varsvars)
										new_value = replacetext(new_value,"\[[V]]","[A.vars[V]]")
								else
									new_value = O.vars[variable]

							A.vars[variable] = new_value
			else
				if(istype(O, /mob))
					for(var/mob/M in mob_list)
						if (M.type == O.type)
							new_value = pre_processing

							if(process_vars)
								if(unique)
									for(var/V in varsvars)
										new_value = replacetext(new_value,"\[[V]]","[M.vars[V]]")
								else
									new_value = O.vars[variable]

							M.vars[variable] = new_value

				else if(istype(O, /obj))
					for(var/obj/A in world)
						if (A.type == O.type)
							new_value = pre_processing

							if(process_vars)
								if(unique)
									for(var/V in varsvars)
										new_value = replacetext(new_value,"\[[V]]","[A.vars[V]]")
								else
									new_value = O.vars[variable]

							A.vars[variable] = new_value

				else if(istype(O, /turf))
					for(var/turf/A in world)
						if (A.type == O.type)
							new_value = pre_processing

							if(process_vars)
								if(unique)
									for(var/V in varsvars)
										new_value = replacetext(new_value,"\[[V]]","[A.vars[V]]")
								else
									new_value = O.vars[variable]

							A.vars[variable] = new_value

		if("num")
			var/new_value = input("Enter new number:","Num",\
					O.vars[variable]) as num|null
			if(new_value == null) return

			if(variable=="luminosity")
				O.SetLuminosity(new_value)
			else
				O.vars[variable] = new_value

			if(method)
				if(istype(O, /mob))
					for(var/mob/M in mob_list)
						if ( istype(M , O.type) )
							if(variable=="luminosity")
								M.SetLuminosity(new_value)
							else
								M.vars[variable] = O.vars[variable]

				else if(istype(O, /obj))
					for(var/obj/A in world)
						if ( istype(A , O.type) )
							if(variable=="luminosity")
								A.SetLuminosity(new_value)
							else
								A.vars[variable] = O.vars[variable]

				else if(istype(O, /turf))
					for(var/turf/A in world)
						if ( istype(A , O.type) )
							if(variable=="luminosity")
								A.SetLuminosity(new_value)
							else
								A.vars[variable] = O.vars[variable]

			else
				if(istype(O, /mob))
					for(var/mob/M in mob_list)
						if (M.type == O.type)
							if(variable=="luminosity")
								M.SetLuminosity(new_value)
							else
								M.vars[variable] = O.vars[variable]

				else if(istype(O, /obj))
					for(var/obj/A in world)
						if (A.type == O.type)
							if(variable=="luminosity")
								A.SetLuminosity(new_value)
							else
								A.vars[variable] = O.vars[variable]

				else if(istype(O, /turf))
					for(var/turf/A in world)
						if (A.type == O.type)
							if(variable=="luminosity")
								A.SetLuminosity(new_value)
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

	world.log << "### MassVarEdit by [src]: [O.type] [variable]=[html_encode("[O.vars[variable]]")]"
	log_admin("[key_name(src)] mass modified [original_name]'s [variable] to [O.vars[variable]]")
	message_admins("[key_name_admin(src)] mass modified [original_name]'s [variable] to [O.vars[variable]]")