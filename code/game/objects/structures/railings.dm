/obj/structure/railing
	name = "railing"
	desc = "Basic railing meant to protect idiots like you from falling."
	icon = 'icons/obj/fluff.dmi'
	icon_state = "railing"
	density = TRUE
	anchored = TRUE
	climbable = TRUE
	///Initial direction of the railing.
	var/ini_dir

/obj/structure/railing/wooden
	name = "fence"
	desc = "Basic fencing meant to protect idiots like you from falling."
	icon_state = "fence"

/obj/structure/railing/corner //aesthetic corner sharp edges hurt oof ouch
	icon_state = "railing_corner"
	density = FALSE
	climbable = FALSE

/obj/structure/railing/corner/wooden
	icon_state = "fence_corner"

/obj/structure/railing/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/simple_rotation,ROTATION_ALTCLICK | ROTATION_CLOCKWISE | ROTATION_COUNTERCLOCKWISE | ROTATION_VERBS ,null,CALLBACK(src, .proc/can_be_rotated),CALLBACK(src,.proc/after_rotation))

/obj/structure/railing/Initialize()
	. = ..()
	ini_dir = dir

/obj/structure/railing/CanPass(atom/movable/mover, turf/target)
	. = ..()
	if(get_dir(loc, target) & dir)
		var/checking = FLYING | FLOATING
		return . || mover.movement_type & checking
	return TRUE

/obj/structure/railing/corner/CanPass()
	..()
	return TRUE

/obj/structure/railing/CheckExit(atom/movable/mover, turf/target)
	..()
	if(get_dir(loc, target) & dir)
		var/checking = UNSTOPPABLE | FLYING | FLOATING
		return !density || mover.movement_type & checking || mover.move_force >= MOVE_FORCE_EXTREMELY_STRONG
	return TRUE

/obj/structure/railing/corner/CheckExit()
	return TRUE

/obj/structure/railing/proc/can_be_rotated(mob/user,rotation_type)
	if(anchored)
		to_chat(user, "<span class='warning'>[src] cannot be rotated while it is fastened to the floor!</span>")
		return FALSE

	var/target_dir = turn(dir, rotation_type == ROTATION_CLOCKWISE ? -90 : 90)

	if(!valid_window_location(loc, target_dir)) //Expanded to include rails, as well!
		to_chat(user, "<span class='warning'>[src] cannot be rotated in that direction!</span>")
		return FALSE
	return TRUE

/obj/structure/railing/proc/check_anchored(checked_anchored)
	if(anchored == checked_anchored)
		return TRUE

/obj/structure/railing/proc/after_rotation(mob/user,rotation_type)
	air_update_turf(1)
	ini_dir = dir
	add_fingerprint(user)
