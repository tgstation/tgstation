/datum/buildmode_mode/varedit
	key = "edit"
	// Varedit mode
	var/varholder = "name"
	var/valueholder = "value"

/datum/buildmode_mode/varedit/show_help(mob/user)
	to_chat(user, "<span class='notice'>***********************************************************</span>")
	to_chat(user, "<span class='notice'>Right Mouse Button on buildmode button = Select var(type) & value</span>")
	to_chat(user, "<span class='notice'>Left Mouse Button on turf/obj/mob      = Set var(type) & value</span>")
	to_chat(user, "<span class='notice'>Right Mouse Button on turf/obj/mob     = Reset var's value</span>")
	to_chat(user, "<span class='notice'>***********************************************************</span>")

// FIXME: This needs to use a standard var-editing interface instead of
// doing its own thing here
/datum/buildmode_mode/varedit/change_settings(mob/user)
	var/list/locked = list("vars", "key", "ckey", "client", "firemut", "ishulk", "telekinesis", "xray", "virus", "viruses", "cuffed", "ka", "last_eaten", "urine")

	varholder = input(user,"Enter variable name:" ,"Name", "name")
	if(varholder in locked && !check_rights(R_DEBUG,0))
		return 1

	var/thetype = input(user,"Select variable type:" ,"Type") in list("text","number","mob-reference","obj-reference","turf-reference")
	if(!thetype) return 1
	switch(thetype)
		if("text")
			valueholder = input(user,"Enter variable value:" ,"Value", "value") as text
		if("number")
			valueholder = input(user,"Enter variable value:" ,"Value", 123) as num
		if("mob-reference")
			valueholder = input(user,"Enter variable value:" ,"Value") as mob in GLOB.mob_list
		if("obj-reference")
			valueholder = input(user,"Enter variable value:" ,"Value") as obj in world
		if("turf-reference")
			valueholder = input(user,"Enter variable value:" ,"Value") as turf in world

/datum/buildmode_mode/varedit/handle_click(user, params, obj/object)
	var/list/pa = params2list(params)
	var/left_click = pa.Find("left")
	var/right_click = pa.Find("right")

	if(left_click)
		if(object.vars.Find(varholder))
			log_admin("Build Mode: [key_name(user)] modified [object.name]'s [varholder] to [valueholder]")
			object.vars[varholder] = valueholder
		else
			to_chat(user, "<span class='warning'>[initial(object.name)] does not have a var called '[varholder]'</span>")
	if(right_click)
		if(object.vars.Find(varholder))
			var/reset_value = initial(object.vars[varholder])
			log_admin("Build Mode: [key_name(user)] modified [object.name]'s [varholder] to [reset_value]")
			object.vars[varholder] = reset_value
		else
			to_chat(user, "<span class='warning'>[initial(object.name)] does not have a var called '[varholder]'</span>")

