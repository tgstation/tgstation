/obj/structure/railing
	name = "railing"
	desc = "Basic railing meant to protect idiots like you from falling."
	icon = 'icons/obj/fluff.dmi'
	icon_state = "railing"
	density = TRUE
	anchored = TRUE
	climbable = TRUE
	var/list/dir_NORTHWEST = list(NORTH, WEST) //ugly ass checks specific to the corner rails with intercardinal directions
	var/list/dir_SOUTHWEST = list(SOUTH, WEST)
	var/list/dir_NORTHEAST = list(NORTH, EAST)
	var/list/dir_SOUTHEAST = list(SOUTH, EAST)

/obj/structure/railing/corner //aesthetic corner sharp edges hurt oof ouch
	icon_state = "railing_corner"
	density = FALSE
	climbable = FALSE

/obj/structure/railing/attackby(obj/item/I, mob/living/user, params)
	add_fingerprint(user)

	if(I.tool_behaviour == TOOL_WELDER && user.a_intent == INTENT_HELP)
		if(obj_integrity < max_integrity)
			if(!I.tool_start_check(user, amount=0))
				return

			to_chat(user, "<span class='notice'>You begin repairing [src]...</span>")
			if(I.use_tool(src, user, 40, volume=50))
				obj_integrity = max_integrity
				to_chat(user, "<span class='notice'>You repair [src].</span>")
		else
			to_chat(user, "<span class='warning'>[src] is already in good condition!</span>")
		return

	if(!(flags_1&NODECONSTRUCT_1))
		if(I.tool_behaviour == TOOL_WRENCH)
			to_chat(user, "<span class='notice'>You begin to [anchored ? "unfasten the railing from":"fasten the railing to"] the floor...</span>")
			if(I.use_tool(src, user, volume = 75, extra_checks = CALLBACK(src, .proc/check_anchored, anchored)))
				setAnchored(!anchored)
				to_chat(user, "<span class='notice'>You [anchored ? "fasten the railing to":"unfasten the railing from"] the floor.</span>")
			return

/obj/structure/railing/proc/check_anchored(checked_anchored)
	if(anchored == checked_anchored)
		return TRUE

/obj/structure/railing/CanPass(atom/movable/mover, turf/target)
	if(get_dir(loc, target) == dir)
		return !density
	if(dir == NORTHWEST && get_dir(loc, target) in dir_NORTHWEST)
		return !density
	if(dir == SOUTHWEST && get_dir(loc, target) in dir_SOUTHWEST)
		return !density
	if(dir == NORTHEAST && get_dir(loc, target) in dir_NORTHEAST)
		return !density
	if(dir == SOUTHEAST && get_dir(loc, target) in dir_SOUTHEAST)
		return !density
	return TRUE

/obj/structure/railing/CheckExit(atom/movable/O, turf/target)
	if(get_dir(O.loc, target) == dir)
		return 0
	if(dir == NORTHWEST && get_dir(loc, target) in dir_NORTHWEST)
		return 0
	if(dir == SOUTHWEST && get_dir(loc, target) in dir_SOUTHWEST)
		return 0
	if(dir == NORTHEAST && get_dir(loc, target) in dir_NORTHEAST)
		return 0
	if(dir == SOUTHEAST && get_dir(loc, target) in dir_SOUTHEAST)
		return 0
	return 1
