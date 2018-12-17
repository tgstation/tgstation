#define STAIR_TERMINATOR_AUTOMATIC 0
#define STAIR_TERMINATOR_NO 1
#define STAIR_TERMINATOR_YES 2

/obj/structure/stairs
	name = "stairs"
	icon = 'icons/obj/stairs.dmi'
	icon_state = "stairs"
	anchored = TRUE
	//dir = direction of travel to go upwards

	var/force_open_above = FALSE
	var/terminator_mode = STAIR_TERMINATOR_AUTOMATIC
	var/datum/component/redirect/multiz_signal_listener

/obj/structure/stairs/Initialize(mapload)
	if(force_open_above)
		force_open_above()
		build_signal_listener()
	update_surrounding()
	return ..()

/obj/structure/stairs/Destroy()
	QDEL_NULL(multiz_signal_listener)
	return ..()

/obj/structure/stairs/Move()			//Look this should never happen but...
	. = ..()
	if(force_open_above)
		build_signal_listener()
	update_surrounding()

/obj/structure/stairs/proc/update_surrounding()
	update_icon()
	for(var/i in GLOB.cardinals)
		var/turf/T = get_step(get_turf(src), i)
		var/obj/structure/stairs/S = locate() in T
		if(S)
			S.update_icon()

/obj/structure/stairs/Uncross(atom/movable/AM, turf/newloc)
	if(!newloc || !AM)
		return ..()
	if(isliving(AM) && isTerminator() && (get_dir(src, newloc) == dir))
		stair_ascend(AM)
		return FALSE
	return ..()

/obj/structure/stairs/Cross(atom/movable/AM)
	if(isTerminator() && (get_dir(src, AM) == dir))
		return FALSE
	return ..()

/obj/structure/stairs/update_icon()
	if(isTerminator())
		icon_state = "stairs_t"
	else
		icon_state = "stairs"

/obj/structure/stairs/proc/stair_ascend(atom/movable/AM)
	var/turf/checking = get_step_multiz(get_turf(src), UP)
	if(!istype(checking))
		return
	if(!checking.zPassIn(AM, UP, get_turf(src)))
		return
	var/turf/target = get_step_multiz(get_turf(src), (dir|UP))
	if(istype(target) && !target.can_zFall(AM, null, get_step_multiz(target, DOWN)))			//Don't throw them into a tile that will just dump them back down.
		AM.forceMove(target)

/obj/structure/stairs/vv_edit_var(var_name, var_value)
	. = ..()
	if(.)
		if(var_name == NAMEOF(src, force_open_above))
			if(!var_value)
				QDEL_NULL(multiz_signal_listener)
			else
				build_signal_listener()
				force_open_above()

/obj/structure/stairs/proc/build_signal_listener()
	QDEL_NULL(multiz_signal_listener)
	var/turf/open/openspace/T = get_step_multiz(get_turf(src), UP)
	multiz_signal_listener = T.AddComponent(/datum/component/redirect, list(COMSIG_TURF_MULTIZ_NEW = CALLBACK(src, .proc/on_multiz_new)))

/obj/structure/stairs/proc/force_open_above()
	var/turf/open/openspace/T = get_step_multiz(get_turf(src), UP)
	if(T && !istype(T))
		T.ChangeTurf(/turf/open/openspace)

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
