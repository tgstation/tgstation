GLOBAL_LIST_INIT(VVlocked, list("vars", "datum_flags", "client", "virus", "viruses", "cuffed", "last_eaten", "unlock_content", "force_ending"))
GLOBAL_PROTECT(VVlocked)
GLOBAL_LIST_INIT(VVicon_edit_lock, list("icon", "icon_state", "overlays", "underlays", "resize"))
GLOBAL_PROTECT(VVicon_edit_lock)
GLOBAL_LIST_INIT(VVckey_edit, list("key", "ckey"))
GLOBAL_PROTECT(VVckey_edit)
GLOBAL_LIST_INIT(VVpixelmovement, list("step_x", "step_y", "bound_height", "bound_width", "bound_x", "bound_y"))
GLOBAL_PROTECT(VVpixelmovement)


/client/proc/vv_get_class(var/var_name, var/var_value)
	if(isnull(var_value))
		. = VV_NULL

	else if (isnum(var_value))
		if (var_name in GLOB.bitfields)
			. = VV_BITFIELD
		else
			. = VV_NUM

	else if (istext(var_value))
		if (findtext(var_value, "\n"))
			. = VV_MESSAGE
		else
			. = VV_TEXT

	else if (isicon(var_value))
		. = VV_ICON

	else if (ismob(var_value))
		. = VV_MOB_REFERENCE

	else if (isloc(var_value))
		. = VV_ATOM_REFERENCE

	else if (istype(var_value, /client))
		. = VV_CLIENT

	else if (istype(var_value, /datum))
		. = VV_DATUM_REFERENCE

	else if (ispath(var_value))
		if (ispath(var_value, /atom))
			. = VV_ATOM_TYPE
		else if (ispath(var_value, /datum))
			. = VV_DATUM_TYPE
		else
			. = VV_TYPE

	else if (islist(var_value))
		. = VV_LIST

	else if (isfile(var_value))
		. = VV_FILE
	else
		. = VV_NULL

/client/proc/vv_get_value(class, default_class, current_value, list/restricted_classes, list/extra_classes, list/classes, var_name)
	. = list("class" = class, "value" = null)
	if (!class)
		if (!classes)
			classes = list (
				VV_NUM,
				VV_TEXT,
				VV_MESSAGE,
				VV_ICON,
				VV_ATOM_REFERENCE,
				VV_DATUM_REFERENCE,
				VV_MOB_REFERENCE,
				VV_CLIENT,
				VV_ATOM_TYPE,
				VV_DATUM_TYPE,
				VV_TYPE,
				VV_FILE,
				VV_NEW_ATOM,
				VV_NEW_DATUM,
				VV_NEW_TYPE,
				VV_NEW_LIST,
				VV_NULL,
				VV_RESTORE_DEFAULT
				)

		if(holder && holder.marked_datum && !(VV_MARKED_DATUM in restricted_classes))
			classes += "[VV_MARKED_DATUM] ([holder.marked_datum.type])"
		if (restricted_classes)
			classes -= restricted_classes

		if (extra_classes)
			classes += extra_classes

		.["class"] = input(src, "What kind of data?", "Variable Type", default_class) as null|anything in classes
		if (holder && holder.marked_datum && .["class"] == "[VV_MARKED_DATUM] ([holder.marked_datum.type])")
			.["class"] = VV_MARKED_DATUM


	switch(.["class"])
		if (VV_TEXT)
			.["value"] = input("Enter new text:", "Text", current_value) as null|text
			if (.["value"] == null)
				.["class"] = null
				return
		if (VV_MESSAGE)
			.["value"] = input("Enter new text:", "Text", current_value) as null|message
			if (.["value"] == null)
				.["class"] = null
				return


		if (VV_NUM)
			.["value"] = input("Enter new number:", "Num", current_value) as null|num
			if (.["value"] == null)
				.["class"] = null
				return

		if (VV_BITFIELD)
			.["value"] = input_bitfield(usr, "Editing bitfield: [var_name]", var_name, current_value)
			if (.["value"] == null)
				.["class"] = null
				return

		if (VV_ATOM_TYPE)
			.["value"] = pick_closest_path(FALSE)
			if (.["value"] == null)
				.["class"] = null
				return

		if (VV_DATUM_TYPE)
			.["value"] = pick_closest_path(FALSE, get_fancy_list_of_datum_types())
			if (.["value"] == null)
				.["class"] = null
				return

		if (VV_TYPE)
			var/type = current_value
			var/error = ""
			do
				type = input("Enter type:[error]", "Type", type) as null|text
				if (!type)
					break
				type = text2path(type)
				error = "\nType not found, Please try again"
			while(!type)
			if (!type)
				.["class"] = null
				return
			.["value"] = type


		if (VV_ATOM_REFERENCE)
			var/type = pick_closest_path(FALSE)
			var/subtypes = vv_subtype_prompt(type)
			if (subtypes == null)
				.["class"] = null
				return
			var/list/things = vv_reference_list(type, subtypes)
			var/value = input("Select reference:", "Reference", current_value) as null|anything in things
			if (!value)
				.["class"] = null
				return
			.["value"] = things[value]

		if (VV_DATUM_REFERENCE)
			var/type = pick_closest_path(FALSE, get_fancy_list_of_datum_types())
			var/subtypes = vv_subtype_prompt(type)
			if (subtypes == null)
				.["class"] = null
				return
			var/list/things = vv_reference_list(type, subtypes)
			var/value = input("Select reference:", "Reference", current_value) as null|anything in things
			if (!value)
				.["class"] = null
				return
			.["value"] = things[value]

		if (VV_MOB_REFERENCE)
			var/type = pick_closest_path(FALSE, make_types_fancy(typesof(/mob)))
			var/subtypes = vv_subtype_prompt(type)
			if (subtypes == null)
				.["class"] = null
				return
			var/list/things = vv_reference_list(type, subtypes)
			var/value = input("Select reference:", "Reference", current_value) as null|anything in things
			if (!value)
				.["class"] = null
				return
			.["value"] = things[value]



		if (VV_CLIENT)
			.["value"] = input("Select reference:", "Reference", current_value) as null|anything in GLOB.clients
			if (.["value"] == null)
				.["class"] = null
				return


		if (VV_FILE)
			.["value"] = input("Pick file:", "File") as null|file
			if (.["value"] == null)
				.["class"] = null
				return


		if (VV_ICON)
			.["value"] = input("Pick icon:", "Icon") as null|icon
			if (.["value"] == null)
				.["class"] = null
				return


		if (VV_MARKED_DATUM)
			.["value"] = holder.marked_datum
			if (.["value"] == null)
				.["class"] = null
				return


		if (VV_NEW_ATOM)
			var/type = pick_closest_path(FALSE)
			if (!type)
				.["class"] = null
				return
			.["type"] = type
			var/atom/newguy = new type()
			newguy.datum_flags |= DF_VAR_EDITED
			.["value"] = newguy

		if (VV_NEW_DATUM)
			var/type = pick_closest_path(FALSE, get_fancy_list_of_datum_types())
			if (!type)
				.["class"] = null
				return
			.["type"] = type
			var/datum/newguy = new type()
			newguy.datum_flags |= DF_VAR_EDITED
			.["value"] = newguy

		if (VV_NEW_TYPE)
			var/type = current_value
			var/error = ""
			do
				type = input("Enter type:[error]", "Type", type) as null|text
				if (!type)
					break
				type = text2path(type)
				error = "\nType not found, Please try again"
			while(!type)
			if (!type)
				.["class"] = null
				return
			.["type"] = type
			var/datum/newguy = new type()
			if(istype(newguy))
				newguy.datum_flags |= DF_VAR_EDITED
			.["value"] = newguy


		if (VV_NEW_LIST)
			.["value"] = list()
			.["type"] = /list

/client/proc/vv_parse_text(O, new_var)
	if(O && findtext(new_var,"\["))
		var/process_vars = alert(usr,"\[] detected in string, process as variables?","Process Variables?","Yes","No")
		if(process_vars == "Yes")
			. = string2listofvars(new_var, O)

//do they want you to include subtypes?
//FALSE = no subtypes, strict exact type pathing (or the type doesn't have subtypes)
//TRUE = Yes subtypes
//NULL = User cancelled at the prompt or invalid type given
/client/proc/vv_subtype_prompt(var/type)
	if (!ispath(type))
		return
	var/list/subtypes = subtypesof(type)
	if (!subtypes || !subtypes.len)
		return FALSE
	if (subtypes && subtypes.len)
		switch(alert("Strict object type detection?", "Type detection", "Strictly this type","This type and subtypes", "Cancel"))
			if("Strictly this type")
				return FALSE
			if("This type and subtypes")
				return TRUE
			else
				return

/client/proc/vv_reference_list(type, subtypes)
	. = list()
	var/list/types = list(type)
	if (subtypes)
		types = typesof(type)

	var/list/fancytypes = make_types_fancy(types)

	for(var/fancytype in fancytypes) //swap the assoication
		types[fancytypes[fancytype]] = fancytype

	var/things = get_all_of_type(type, subtypes)

	var/i = 0
	for(var/thing in things)
		var/datum/D = thing
		i++
		//try one of 3 methods to shorten the type text:
		//	fancy type,
		//	fancy type with the base type removed from the begaining,
		//	the type with the base type removed from the begaining
		var/fancytype = types[D.type]
		if (findtext(fancytype, types[type]))
			fancytype = copytext(fancytype, lentext(types[type])+1)
		var/shorttype = copytext("[D.type]", lentext("[type]")+1)
		if (lentext(shorttype) > lentext(fancytype))
			shorttype = fancytype
		if (!lentext(shorttype))
			shorttype = "/"

		.["[D]([shorttype])[REF(D)]#[i]"] = D

/client/proc/mod_list_add_ass(atom/O) //hehe

	var/list/L = vv_get_value(restricted_classes = list(VV_RESTORE_DEFAULT))
	var/class = L["class"]
	if (!class)
		return
	var/var_value = L["value"]

	if(class == VV_TEXT || class == VV_MESSAGE)
		var/list/varsvars = vv_parse_text(O, var_value)
		for(var/V in varsvars)
			var_value = replacetext(var_value,"\[[V]]","[O.vars[V]]")

	return var_value


/client/proc/mod_list_add(list/L, atom/O, original_name, objectvar)
	var/list/LL = vv_get_value(restricted_classes = list(VV_RESTORE_DEFAULT))
	var/class = LL["class"]
	if (!class)
		return
	var/var_value = LL["value"]

	if(class == VV_TEXT || class == VV_MESSAGE)
		var/list/varsvars = vv_parse_text(O, var_value)
		for(var/V in varsvars)
			var_value = replacetext(var_value,"\[[V]]","[O.vars[V]]")

	if (O)
		L = L.Copy()

	L += var_value

	switch(alert("Would you like to associate a value with the list entry?",,"Yes","No"))
		if("Yes")
			L[var_value] = mod_list_add_ass(O) //hehe
	if (O)
		if (O.vv_edit_var(objectvar, L) == FALSE)
			to_chat(src, "Your edit was rejected by the object.")
			return
	log_world("### ListVarEdit by [src]: [(O ? O.type : "/list")] [objectvar]: ADDED=[var_value]")
	log_admin("[key_name(src)] modified [original_name]'s [objectvar]: ADDED=[var_value]")
	message_admins("[key_name_admin(src)] modified [original_name]'s [objectvar]: ADDED=[var_value]")

/client/proc/mod_list(list/L, atom/O, original_name, objectvar, index, autodetect_class = FALSE)
	if(!check_rights(R_VAREDIT))
		return
	if(!istype(L, /list))
		to_chat(src, "Not a List.")
		return

	if(L.len > 1000)
		var/confirm = alert(src, "The list you're trying to edit is very long, continuing may crash the server.", "Warning", "Continue", "Abort")
		if(confirm != "Continue")
			return



	var/list/names = list()
	for (var/i in 1 to L.len)
		var/key = L[i]
		var/value
		if (IS_NORMAL_LIST(L) && !isnum(key))
			value = L[key]
		if (value == null)
			value = "null"
		names["#[i] [key] = [value]"] = i
	if (!index)
		var/variable = input("Which var?","Var") as null|anything in names + "(ADD VAR)" + "(CLEAR NULLS)" + "(CLEAR DUPES)" + "(SHUFFLE)"

		if(variable == null)
			return

		if(variable == "(ADD VAR)")
			mod_list_add(L, O, original_name, objectvar)
			return

		if(variable == "(CLEAR NULLS)")
			L = L.Copy()
			listclearnulls(L)
			if (!O.vv_edit_var(objectvar, L))
				to_chat(src, "Your edit was rejected by the object.")
				return
			log_world("### ListVarEdit by [src]: [O.type] [objectvar]: CLEAR NULLS")
			log_admin("[key_name(src)] modified [original_name]'s [objectvar]: CLEAR NULLS")
			message_admins("[key_name_admin(src)] modified [original_name]'s list [objectvar]: CLEAR NULLS")
			return

		if(variable == "(CLEAR DUPES)")
			L = uniqueList(L)
			if (!O.vv_edit_var(objectvar, L))
				to_chat(src, "Your edit was rejected by the object.")
				return
			log_world("### ListVarEdit by [src]: [O.type] [objectvar]: CLEAR DUPES")
			log_admin("[key_name(src)] modified [original_name]'s [objectvar]: CLEAR DUPES")
			message_admins("[key_name_admin(src)] modified [original_name]'s list [objectvar]: CLEAR DUPES")
			return

		if(variable == "(SHUFFLE)")
			L = shuffle(L)
			if (!O.vv_edit_var(objectvar, L))
				to_chat(src, "Your edit was rejected by the object.")
				return
			log_world("### ListVarEdit by [src]: [O.type] [objectvar]: SHUFFLE")
			log_admin("[key_name(src)] modified [original_name]'s [objectvar]: SHUFFLE")
			message_admins("[key_name_admin(src)] modified [original_name]'s list [objectvar]: SHUFFLE")
			return

		index = names[variable]


	var/assoc_key
	if (index == null)
		return
	var/assoc = 0
	var/prompt = alert(src, "Do you want to edit the key or its assigned value?", "Associated List", "Key", "Assigned Value", "Cancel")
	if (prompt == "Cancel")
		return
	if (prompt == "Assigned Value")
		assoc = 1
		assoc_key = L[index]
	var/default
	var/variable
	if (assoc)
		variable = L[assoc_key]
	else
		variable = L[index]

	default = vv_get_class(objectvar, variable)

	to_chat(src, "Variable appears to be <b>[uppertext(default)]</b>.")

	to_chat(src, "Variable contains: [variable]")

	if(default == VV_NUM)
		var/dir_text = ""
		var/tdir = variable
		if(tdir > 0 && tdir < 16)
			if(tdir & 1)
				dir_text += "NORTH"
			if(tdir & 2)
				dir_text += "SOUTH"
			if(tdir & 4)
				dir_text += "EAST"
			if(tdir & 8)
				dir_text += "WEST"

		if(dir_text)
			to_chat(usr, "If a direction, direction is: [dir_text]")

	var/original_var = variable

	if (O)
		L = L.Copy()
	var/class
	if(autodetect_class)
		if (default == VV_TEXT)
			default = VV_MESSAGE
		class = default
	var/list/LL = vv_get_value(default_class = default, current_value = original_var, restricted_classes = list(VV_RESTORE_DEFAULT), extra_classes = list(VV_LIST, "DELETE FROM LIST"))
	class = LL["class"]
	if (!class)
		return
	var/new_var = LL["value"]

	if(class == VV_MESSAGE)
		class = VV_TEXT

	switch(class) //Spits a runtime error if you try to modify an entry in the contents list. Dunno how to fix it, yet.
		if(VV_LIST)
			mod_list(variable, O, original_name, objectvar)

		if("DELETE FROM LIST")
			L.Cut(index, index+1)
			if (O)
				if (O.vv_edit_var(objectvar, L))
					to_chat(src, "Your edit was rejected by the object.")
					return
			log_world("### ListVarEdit by [src]: [O.type] [objectvar]: REMOVED=[html_encode("[original_var]")]")
			log_admin("[key_name(src)] modified [original_name]'s [objectvar]: REMOVED=[original_var]")
			message_admins("[key_name_admin(src)] modified [original_name]'s [objectvar]: REMOVED=[original_var]")
			return

		if(VV_TEXT)
			var/list/varsvars = vv_parse_text(O, new_var)
			for(var/V in varsvars)
				new_var = replacetext(new_var,"\[[V]]","[O.vars[V]]")


	if(assoc)
		L[assoc_key] = new_var
	else
		L[index] = new_var
	if (O)
		if (O.vv_edit_var(objectvar, L) == FALSE)
			to_chat(src, "Your edit was rejected by the object.")
			return
	log_world("### ListVarEdit by [src]: [(O ? O.type : "/list")] [objectvar]: [original_var]=[new_var]")
	log_admin("[key_name(src)] modified [original_name]'s [objectvar]: [original_var]=[new_var]")
	message_admins("[key_name_admin(src)] modified [original_name]'s varlist [objectvar]: [original_var]=[new_var]")

/client/proc/modify_variables(atom/O, param_var_name = null, autodetect_class = 0)
	if(!check_rights(R_VAREDIT))
		return

	var/class
	var/variable
	var/var_value

	if(param_var_name)
		if(!param_var_name in O.vars)
			to_chat(src, "A variable with this name ([param_var_name]) doesn't exist in this datum ([O])")
			return
		variable = param_var_name

	else
		var/list/names = list()
		for (var/V in O.vars)
			names += V

		names = sortList(names)

		variable = input("Which var?","Var") as null|anything in names
		if(!variable)
			return

	if(!O.can_vv_get(variable))
		return

	var_value = O.vars[variable]

	if(variable in GLOB.VVlocked)
		if(!check_rights(R_DEBUG))
			return
	if(variable in GLOB.VVckey_edit)
		if(!check_rights(R_SPAWN|R_DEBUG))
			return
	if(variable in GLOB.VVicon_edit_lock)
		if(!check_rights(R_FUN|R_DEBUG))
			return
	if(istype(O, /datum/armor))
		var/prompt = alert(src, "Editing this var changes this value on potentially thousands of items that share the same combination of armor values. If you want to edit the armor of just one item, use the \"Modify armor values\" dropdown item", "DANGER", "ABORT ", "Continue", " ABORT")
		if (prompt != "Continue")
			return
	if(variable in GLOB.VVpixelmovement)
		if(!check_rights(R_DEBUG))
			return
		var/prompt = alert(src, "Editing this var may irreparably break tile gliding for the rest of the round. THIS CAN'T BE UNDONE", "DANGER", "ABORT ", "Continue", " ABORT")
		if (prompt != "Continue")
			return


	var/default = vv_get_class(variable, var_value)

	if(isnull(default))
		to_chat(src, "Unable to determine variable type.")
	else
		to_chat(src, "Variable appears to be <b>[uppertext(default)]</b>.")

	to_chat(src, "Variable contains: [var_value]")

	if(default == VV_NUM)
		var/dir_text = ""
		if(var_value > 0 && var_value < 16)
			if(var_value & 1)
				dir_text += "NORTH"
			if(var_value & 2)
				dir_text += "SOUTH"
			if(var_value & 4)
				dir_text += "EAST"
			if(var_value & 8)
				dir_text += "WEST"

		if(dir_text)
			to_chat(src, "If a direction, direction is: [dir_text]")

	if(autodetect_class && default != VV_NULL)
		if (default == VV_TEXT)
			default = VV_MESSAGE
		class = default

	var/list/value = vv_get_value(class, default, var_value, extra_classes = list(VV_LIST), var_name = variable)
	class = value["class"]

	if (!class)
		return
	var/var_new = value["value"]

	if(class == VV_MESSAGE)
		class = VV_TEXT

	var/original_name = "[O]"

	switch(class)
		if(VV_LIST)
			if(!islist(var_value))
				mod_list(list(), O, original_name, variable)

			mod_list(var_value, O, original_name, variable)
			return

		if(VV_RESTORE_DEFAULT)
			var_new = initial(O.vars[variable])

		if(VV_TEXT)
			var/list/varsvars = vv_parse_text(O, var_new)
			for(var/V in varsvars)
				var_new = replacetext(var_new,"\[[V]]","[O.vars[V]]")


	if (O.vv_edit_var(variable, var_new) == FALSE)
		to_chat(src, "Your edit was rejected by the object.")
		return
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_VAR_EDIT, args)
	log_world("### VarEdit by [key_name(src)]: [O.type] [variable]=[var_value] => [var_new]")
	log_admin("[key_name(src)] modified [original_name]'s [variable] from [html_encode("[var_value]")] to [html_encode("[var_new]")]")
	var/msg = "[key_name_admin(src)] modified [original_name]'s [variable] from [var_value] to [var_new]"
	message_admins(msg)
	admin_ticket_log(O, msg)
