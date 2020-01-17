/obj/structure/railing
	name = "railing"
	desc = "Basic railing meant to protect idiots like you from falling."
	icon = 'icons/obj/fluff.dmi'
	icon_state = "railing"
	density = TRUE
	anchored = TRUE
	climbable = TRUE
	var/list/dir9 = list(NORTH, WEST) //ugly ass checks specific to the corner rails with intercardinal directions
	var/list/dir10 = list(SOUTH, WEST)
	var/list/dir5 = list(NORTH, EAST)
	var/list/dir6 = list(SOUTH, EAST)

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
	if(dir == 9 && get_dir(loc, target) in dir9)
		return !density
	if(dir == 10 && get_dir(loc, target) in dir10)
		return !density
	if(dir == 5 && get_dir(loc, target) in dir5)
		return !density
	if(dir == 6 && get_dir(loc, target) in dir6)
		return !density
	return 1

/obj/structure/railing/CheckExit(atom/movable/O, turf/target)
	if(get_dir(O.loc, target) == dir)
		return 0
	if(dir == 9 && get_dir(loc, target) in dir9)
		return 0
	if(dir == 10 && get_dir(loc, target) in dir10)
		return 0
	if(dir == 5 && get_dir(loc, target) in dir5)
		return 0
	if(dir == 6 && get_dir(loc, target) in dir6)
		return 0
	return 1
