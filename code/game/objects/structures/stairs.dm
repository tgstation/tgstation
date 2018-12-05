#define STAIR_TERMINATOR_AUTOMATIC 0
#define STAIR_TERMINATOR_NO 1
#define STAIR_TERMINATOR_YES 2

/obj/structure/stairs
	name = "stairs"
	icon = 'icons/obj/stairs.dmi'
	icon_state = ""
	//dir = direction of travel to go upwards

	var/force_open_above = FALSE
	var/terminator_mode = STAIR_TERMINATOR_AUTOMATIC
	var/datum/component/redirect/multiz_signal_listener

/obj/structure/stairs/Initialize(mapload)
	if(force_open_above)
		var/turf/open/openspace/T = get_step_multiz(get_turf(src), UP)
		if(T && !istype(T))
			T.ChangeTurf(/turf/open/openspace)
		build_signal_listener()
	return ..()

/obj/structure/stairs/Destroy()
	QDEL_NULL(multiz_signal_listener)
	return ..()

/obj/structure/stairs/vv_edit_var(var_name, var_value)
	. = ..()
	if(.)
		if(var_name == NAMEOF(src, force_open_above))
			if(!var_value)
				QDEL_NULL(multiz_signal_listener)
			else
				build_signal_listener()

/obj/structure/stairs/proc/build_signal_listener()
	QDEL_NULL(multiz_signal_listener)
	var/turf/open/openspace/T = get_step_multiz(get_turf(src), UP)
	multiz_signal_listener = T.AddComponent(/datum/component/redirect, list(COMSIG_TURF_MULTIZ_NEW = CALLBACK(src, .proc/on_multiz_new)))

/obj/structure/stairs/proc/on_multiz_new(turf/source, dir)
	if(dir == UP)
		var/turf/open/openspace/T = get_step_multiz(get_turf(src), UP)
		if(T && !istype(T))
			T.ChangeTurf(/turf/open/openspace)

/obj/structure/stairs/intercept_zImpact(atom/movable/AM, levels = 1)
	return isTerminator()

/obj/structure/stairs/proc/isTerminator()			//If this is the last stair in a chain and should move mobs up
	if(terminator_mode != STAIR_TERMINATOR_AUTOMATIC)
		return (terminator_mode == STAIR_TERMINATOR_YES)
	var/turf/T = get_turf(src)
	if(!T)
		return FALSE
	var/turf/them = get_step(T, dir)
	if(!them)
		return FALSE
	for(var/obj/structure/stairs/S in them)
		if(S.dir == dir)
			return FALSE
	return TRUE
