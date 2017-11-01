/datum/component/turf_decal
	var/dir
	var/icon
	var/icon_state
	var/layer
	var/group

/datum/component/turf_decal/Initialize(_dir, _icon, _icon_state, _layer=TURF_DECAL_LAYER, _group=TURF_DECAL_PAINT)
	if(!isturf(parent) || !_icon || !_icon_state)
		WARNING("A turf decal was applied incorrectly to [parent]: icon:[_icon ? _icon : "none"] icon_state:[_icon_state ? _icon_state : "none"]")
		return COMPONENT_INCOMPATIBLE

	dir = _dir
	icon = _icon
	icon_state = _icon_state
	layer = _layer
	group = _group
	apply_decal()

	RegisterSignal(COMSIG_ATOM_ROTATE, .proc/rotate_react)
	RegisterSignal(COMSIG_COMPONENT_CLEAN_ACT, .proc/clean_react)

/datum/component/turf_decal/Destroy()
	remove_decal()
	return ..()

/datum/component/turf_decal/OnTransfer(turf/newT)
	remove_decal()
	remove_decal(newT)
	apply_decal(newT)

/datum/component/turf_decal/proc/get_decal()
	return image(icon, null, icon_state, layer, dir)

/datum/component/turf_decal/proc/apply_decal(turf/overT)
	var/turf/master = overT || parent
	master.add_decal(get_decal(), group)

/datum/component/turf_decal/proc/remove_decal(turf/overT)
	var/turf/master = overT || parent
	master.remove_decal(group)

/datum/component/turf_decal/proc/rotate_react(rotation, params)
	if(params & ROTATE_DIR)
		dir = angle2dir(rotation+dir2angle(dir))
		remove_decal()
		apply_decal()

/datum/component/turf_decal/proc/clean_react(strength)
	if(strength >= CLEAN_IMPRESSIVE)
		qdel(src)