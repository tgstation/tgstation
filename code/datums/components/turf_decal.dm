/datum/component/turf_decal
	var/dir
	var/icon
	var/icon_state
	var/layer
	var/group

/datum/component/turf_decal/Initialize(_dir, _icon, _icon_state, _layer=TURF_DECAL_LAYER, _group=TURF_DECAL_PAINT)
	. = ..()
	if(!istype(parent, /turf) || !_icon || !_icon_state)
		WARNING("A turf decal was applied without the necesary args in initialize: [parent]")
		qdel(src)

	dir = _dir
	apply_decal()

	RegisterSignal(COMSIG_ATOM_ROTATE, .proc/rotate_react)

/datum/component/turf_decal/proc/get_decal()
	return image(icon=icon, icon_state=icon_state, dir=dir, layer=layer)

/datum/component/turf_decal/proc/apply_decal()
	var/turf/master = parent
	addtimer(CALLBACK(master, /turf/.proc/add_decal, get_decal(), group), 0)

/datum/component/turf_decal/proc/remove_decal()
	var/turf/master = parent
	addtimer(CALLBACK(master, .proc/remove_decal, group), 0, TIMER_UNIQUE)

/datum/component/turf_decal/proc/rotate_react(rotation, params)
	if(params & ROTATE_DIR)
		dir = angle2dir(rotation+dir2angle(dir))
		remove_decal()
		apply_decal()