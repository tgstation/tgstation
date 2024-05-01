/datum/element/door_squeeze_through

/datum/element/door_squeeze_through/Attach(datum/target)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_MOUSEDROP_ONTO, PROC_REF(on_mousedrop_onto))

/datum/element/door_squeeze_through/proc/on_mousedrop_onto(atom/source, atom/over, mob/user)
	SIGNAL_HANDLER
	if(source != user || (user.pass_flags & PASSDOORS))
		return
	if(!istype(over, /obj/machinery/door))
		return
	if(!user.Adjacent(over) || !over.Adjacent(user))
		return
	var/same_loc = user.loc == over.loc
	var/direction = same_loc ? over.dir : get_dir(user, over)
	if(over.flags_1 & ON_BORDER_1)
		if(!same_loc)
			user.balloon_alert(user, "move closer!")
			return
	else
		if(same_loc)
			user.balloon_alert(user, "move away!")
		if(!(direction in GLOB.cardinals))
			user.balloon_alert(user, "face the door correctly!")
			return
	INVOKE_ASYNC(src, PROC_REF(squeeze_through), user, over, direction)
	return COMPONENT_NO_MOUSEDROP

/datum/element/door_squeeze_through/proc/squeeze_through(mob/living/user, obj/machinery/door/door, direction)
	if(!do_after(user, 5 SECONDS, door, extra_checks = CALLBACK(src, PROC_REF(check_door), door)))
		return
	user.pass_flags ^= PASSDOORS
	var/old_loc = get_turf(user)
	var/middle_loc = get_step(user, direction)
	if(!user.Move(middle_loc, direction)) //move under the door.
		user.balloon_alert(user, "something blocked the way!")
	if(QDELETED(user))
		return
	user.pass_flags ^= PASSDOORS
	//you only take one step to be on the other side of a windoor.
	if(QDELETED(door) || door.flags_1 & ON_BORDER_1 || user.loc != middle_loc)
		finish_squeeze(user)
	if(!user.Move(get_step(user, direction), direction)) //move to the other side of the full-tile door.
		user.forceMove(old_loc)
		user.balloon_alert(user, "something blocked the way!")
		return
	finish_squeeze(user)

///Interrupt the action if the door's opened.
/datum/element/door_squeeze_through/proc/check_door(mob/living/user, obj/machinery/door/door, direction)
	if(!door.density)
		return FALSE
	return TRUE

///Send a balloon alert to everyone and play a little animation. TODO ADD GOOFY SOUND
/datum/element/door_squeeze_through/proc/finish_squeeze(mob/living/user)
	user.balloon_alert_to_viewers("squeezed through")
	var/squish_val = rand(11, 14) * 0.1
	var/squish_x = pick(squish_val, 2 - squish_val)
	var/squish_y = 2 - squish_x
	user.do_squish(squish_x, squish_y, 1.5 SECONDS)
