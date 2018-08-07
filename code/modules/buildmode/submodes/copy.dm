/datum/buildmode_mode/copy
	key = "copy"
	var/atom/movable/stored = null

/datum/buildmode_mode/copy/exit_mode()
	stored = null
	return ..()

/datum/buildmode_mode/copy/show_help(mob/user)
	to_chat(user, "<span class='notice'>***********************************************************</span>")
	to_chat(user, "<span class='notice'>Left Mouse Button on obj/turf/mob   = Spawn a Copy of selected target</span>")
	to_chat(user, "<span class='notice'>Right Mouse Button on obj/mob = Select target to copy</span>")
	to_chat(user, "<span class='notice'>***********************************************************</span>")

/datum/buildmode_mode/copy/handle_click(user, params, obj/object)
	var/list/pa = params2list(params)
	var/left_click = pa.Find("left")
	var/right_click = pa.Find("right")

	if(left_click)
		var/turf/T = get_turf(object)
		if(stored)
			DuplicateObject(stored, perfectcopy=1, sameloc=0,newloc=T)
	else if(right_click)
		if(ismovableatom(object)) // No copying turfs for now.
			to_chat(user, "<span class='notice'>[object] set as template.</span>")
			stored = object
