/datum/buildmode_mode/throwing
	key = "throw"
	
	var/atom/movable/throw_atom = null
	
/datum/buildmode_mode/throwing/show_help(mob/user)
	to_chat(user, "<span class='notice'>***********************************************************</span>")
	to_chat(user, "<span class='notice'>Left Mouse Button on turf/obj/mob      = Select</span>")
	to_chat(user, "<span class='notice'>Right Mouse Button on turf/obj/mob     = Throw</span>")
	to_chat(user, "<span class='notice'>***********************************************************</span>")

/datum/buildmode_mode/throwing/handle_click(user, params, obj/object)
	var/list/pa = params2list(params)
	var/left_click = pa.Find("left")
	var/right_click = pa.Find("right")

	if(left_click)
		if(isturf(object))
			return
		throw_atom = object
		to_chat(user, "Selected object '[throw_atom]'")
	if(right_click)
		if(throw_atom)
			throw_atom.throw_at(object, 10, 1, user)
			log_admin("Build Mode: [key_name(user)] threw [throw_atom] at [object] ([object.x],[object.y],[object.z])")
