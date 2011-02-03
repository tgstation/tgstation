/client/proc/cmd_mass_modify_object_variables(obj/O as obj|mob|turf|area in world)
	set category = "Debug"
	set name = "Mass Edit Variables"
	set desc="(target) Edit all instances of a target item's variables"
	src.massmodify_variables(O)


/client/proc/massmodify_variables(var/atom/O)
	var/list/locked = list("vars", "key", "ckey", "client")

	if(!src.authenticated || !src.holder)
		src << "Only administrators may use this command."
		return

	var/list/names = list()
	for (var/V in O.vars)
		names += V

	names = sortList(names)

	var/variable = input("Which var?","Var") as null|anything in names
	if(!variable)
		return
	var/default
	var/var_value = O.vars[variable]
	var/dir

	if (locked.Find(variable) && !(src.holder.rank in list("Host", "Coder")))
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

			if(istype(O, /mob))
				for(var/mob/M in world)
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
			O.vars[variable] = input("Enter new text:","Text",\
				O.vars[variable]) as text

			if(istype(O, /mob))
				for(var/mob/M in world)
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
			O.vars[variable] = input("Enter new number:","Num",\
				O.vars[variable]) as num

			if(istype(O, /mob))
				for(var/mob/M in world)
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

		if("type")
			O.vars[variable] = input("Enter type:","Type",O.vars[variable]) \
				in typesof(/obj,/mob,/area,/turf)

			if(istype(O, /mob))
				for(var/mob/M in world)
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
			O.vars[variable] = input("Pick file:","File",O.vars[variable]) \
				as file

			if(istype(O, /mob))
				for(var/mob/M in world)
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
			O.vars[variable] = input("Pick icon:","Icon",O.vars[variable]) \
				as icon
			if(istype(O, /mob))
				for(var/mob/M in world)
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