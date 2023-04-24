/datum/buildmode_mode/basic
	key = "basic"

/datum/buildmode_mode/basic/show_help(client/c)
	to_chat(c, span_notice("***********************************************************"))
	to_chat(c, span_notice("Left Mouse Button        = Construct / Upgrade"))
	to_chat(c, span_notice("Right Mouse Button       = Deconstruct / Delete / Downgrade"))
	to_chat(c, span_notice("Left Mouse Button + ctrl = R-Window"))
	to_chat(c, span_notice("Left Mouse Button + alt  = Airlock"))
	to_chat(c, span_notice("\nUse the button in the upper left corner to"))
	to_chat(c, span_notice("change the direction of built objects."))
	to_chat(c, span_notice("***********************************************************"))

/datum/buildmode_mode/basic/handle_click(client/c, params, obj/object)
	var/list/modifiers = params2list(params)

	var/left_click = LAZYACCESS(modifiers, LEFT_CLICK)
	var/right_click = LAZYACCESS(modifiers, RIGHT_CLICK)
	var/alt_click = LAZYACCESS(modifiers, ALT_CLICK)
	var/ctrl_click = LAZYACCESS(modifiers, CTRL_CLICK)

	if(istype(object,/turf) && left_click && !alt_click && !ctrl_click)
		var/turf/clicked_turf = object
		if(isplatingturf(object))
			clicked_turf.PlaceOnTop(/turf/open/floor/iron, flags = CHANGETURF_INHERIT_AIR)
		else if(isfloorturf(object))
			clicked_turf.PlaceOnTop(/turf/closed/wall)
		else if(iswallturf(object))
			clicked_turf.PlaceOnTop(/turf/closed/wall/r_wall)
		else
			clicked_turf.PlaceOnTop(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR) // Gotta do something
		log_admin("Build Mode: [key_name(c)] built [clicked_turf] at [AREACOORD(clicked_turf)]")
		return
	else if(right_click)
		log_admin("Build Mode: [key_name(c)] deleted [object] at [AREACOORD(object)]")
		if(isturf(object))
			var/turf/T = object
			T.ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
		else if(isobj(object))
			qdel(object)
		return
	else if(istype(object,/turf) && alt_click && left_click)
		log_admin("Build Mode: [key_name(c)] built an airlock at [AREACOORD(object)]")
		new/obj/machinery/door/airlock(get_turf(object))
	else if(istype(object,/turf) && ctrl_click && left_click)
		var/obj/structure/window/reinforced/window
		if(BM.build_dir in GLOB.diagonals)
			window = new /obj/structure/window/reinforced/fulltile(get_turf(object))
		else
			window = new /obj/structure/window/reinforced(get_turf(object))
			window.setDir(BM.build_dir)
		log_admin("Build Mode: [key_name(c)] built a window at [AREACOORD(object)]")
