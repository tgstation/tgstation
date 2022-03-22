/datum/buildmode_mode/throwing
	key = "throw"

	var/atom/movable/throw_atom = null

/datum/buildmode_mode/throwing/Destroy()
	throw_atom = null
	return ..()

/datum/buildmode_mode/throwing/show_help(client/c)
	to_chat(c, span_notice("***********************************************************"))
	to_chat(c, span_notice("Left Mouse Button on turf/obj/mob      = Select"))
	to_chat(c, span_notice("Right Mouse Button on turf/obj/mob     = Throw"))
	to_chat(c, span_notice("***********************************************************"))

/datum/buildmode_mode/throwing/handle_click(client/c, params, obj/object)
	var/list/modifiers = params2list(params)

	if(LAZYACCESS(modifiers, LEFT_CLICK))
		if(isturf(object))
			return
		throw_atom = object
		to_chat(c, "Selected object '[throw_atom]'")
	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		if(throw_atom)
			throw_atom.throw_at(object, 10, 1, c.mob)
			log_admin("Build Mode: [key_name(c)] threw [throw_atom] at [object] ([AREACOORD(object)])")
