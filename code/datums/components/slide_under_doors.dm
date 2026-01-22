// A component for basic mobs that makes them able to slide under doors by right-clicking on them.
// Sliding under doors has a configurable initial delay, and allows the mob to remain under the door indefinitely.
// If the door is opened while the mob is under it, then the mob will be ejected from their hiding spot.
// Instantly sliding under doors should be handled by giving the mob the PASSDOORS pass flag.

/datum/component/slide_under_doors
	can_transfer = TRUE

	/// The delay for sliding under a door in deciseconds.
	var/slide_in_delay = 0
	/// The delay for sliding out from under a door in deciseconds.
	var/slide_out_delay = 0

	/// The user that is currently under a door, if any.
	var/mob/living/current_user = null
	/// The door the user is currently under, if any.
	var/obj/machinery/door/current_door = null

/datum/component/slide_under_doors/Initialize(slide_in_delay = 5 SECONDS, slide_out_delay = 1 SECONDS)
	if (!isbasicmob(parent))
		return COMPONENT_INCOMPATIBLE

	src.slide_in_delay = slide_in_delay
	src.slide_out_delay = slide_out_delay

/datum/component/slide_under_doors/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOB_CLIENT_LOGIN, PROC_REF(on_user_login))
	RegisterSignal(parent, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(on_user_unarmed_attack))

	notify_user()

/datum/component/slide_under_doors/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOB_CLIENT_LOGIN, COMSIG_LIVING_UNARMED_ATTACK))

	if (!QDELETED(current_user) && !QDELETED(current_door))
		slide_out_from_under_door()
	else if (current_user || current_door)
		unregister_user_and_door()

/datum/component/slide_under_doors/proc/on_user_login(mob/living/user, client/user_client)
	SIGNAL_HANDLER
	notify_user()

/datum/component/slide_under_doors/proc/notify_user()
	to_chat(parent, span_notice("You can slide under doors! <b>Right-click on a door to slide under it.</b>"))

/datum/component/slide_under_doors/proc/on_user_unarmed_attack(mob/living/user, atom/target, is_adjacent, modifiers)
	SIGNAL_HANDLER
	if (!modifiers[RIGHT_CLICK])
		return
	if (!istype(target, /obj/machinery/door))
		return

	INVOKE_ASYNC(src, PROC_REF(try_slide_under_door), user, target)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/slide_under_doors/proc/try_slide_under_door(mob/living/user, obj/machinery/door/door)
	if (!can_slide_under_door(user, door))
		return

	user.visible_message(
		message = span_danger("\The [user] start[user.p_s()] sliding under \the [door]!"),
		self_message = span_notice("You start sliding under \the [door]."),
		blind_message = span_hear("You hear squeezing."),
	)

	playsound(user, 'sound/effects/footstep/gib_step.ogg', vol = 50, vary = TRUE, ignore_walls = FALSE)

	if (!do_after(user, slide_in_delay, door, extra_checks = CALLBACK(src, PROC_REF(can_slide_under_door), user, door)))
		return

	slide_under_door(user, door)

/datum/component/slide_under_doors/proc/can_slide_under_door(mob/living/user, obj/machinery/door/door)
	if (!user.Adjacent(door))
		return FALSE
	if (user.loc == door)
		return FALSE
	if (!isturf(user.loc))
		user.balloon_alert(user, "not on the ground!")
		return FALSE
	if (!door.IsReachableBy(user))
		user.balloon_alert(user, "can't reach!")
		return FALSE
	if (HAS_TRAIT(user, TRAIT_INCAPACITATED))
		user.balloon_alert(user, "incapacitated!")
		return FALSE
	if (!(door.pass_flags_self & PASSDOORS))
		door.balloon_alert(user, "impassable!")
		return FALSE
	if (!door.density)
		door.balloon_alert(user, "already open!")
		return FALSE
	return TRUE

/datum/component/slide_under_doors/proc/slide_under_door(mob/living/user, obj/machinery/door/door)
	user.visible_message(
		message = span_danger("\The [user] slide[user.p_s()] under \the [door] with a pop!"),
		self_message = span_notice("You slide under \the [door] with a pop!"),
		blind_message = span_hear("You hear a pop."),
	)

	playsound(user, 'sound/effects/meatslap.ogg', vol = 50, vary = TRUE, ignore_walls = FALSE)

	user.forceMove(door)

	register_user_and_door(user, door)

/datum/component/slide_under_doors/proc/try_slide_out_from_under_door(move_dir)
	if (DOING_INTERACTION_WITH_TARGET(current_user, current_door))
		return

	var/turf/visible_turf = get_step(current_user, move_dir)

	if (visible_turf)
		visible_turf.visible_message(
			message = span_danger("Something starts sliding out from under \the [current_door]!"),
			blind_message = span_hear("You hear squeezing."),
			ignored_mobs = current_user,
		)

		playsound(visible_turf, 'sound/effects/footstep/gib_step.ogg', vol = 50, vary = TRUE, ignore_walls = FALSE)

	to_chat(current_user, span_notice("You start sliding out from under \the [current_door]."))

	if (!do_after(current_user, slide_out_delay, current_door, timed_action_flags = IGNORE_INCAPACITATED))
		return

	slide_out_from_under_door(move_dir)

/datum/component/slide_under_doors/proc/slide_out_from_under_door(move_dir)
	// We need to store local references to the user and the door before unregistering them.
	var/mob/living/user = current_user
	var/obj/machinery/door/door = current_door

	unregister_user_and_door()

	user.forceMove(door.drop_location())

	if (move_dir)
		user.Move(get_step(user, move_dir), move_dir)

	user.visible_message(
		message = span_danger("\The [user] slide[user.p_s()] out from under \the [door] with a pop!"),
		self_message = span_notice("You slide out from under \the [door] with a pop!"),
		blind_message = span_hear("You hear a pop."),
	)

	playsound(user, 'sound/effects/meatslap.ogg', vol = 50, vary = TRUE, ignore_walls = FALSE)

/datum/component/slide_under_doors/proc/register_user_and_door(mob/living/user, obj/machinery/door/door)
	ADD_TRAIT(user, TRAIT_INCAPACITATED, UNDER_DOOR_TRAIT)
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_user_moved))
	current_user = user

	RegisterSignal(door, COMSIG_QDELETING, PROC_REF(on_door_qdeleting))
	RegisterSignal(door, COMSIG_ATOM_DENSITY_CHANGED, PROC_REF(on_door_density_changed))
	RegisterSignal(door, COMSIG_ATOM_RELAYMOVE, PROC_REF(on_door_relaymove))
	current_door = door

/datum/component/slide_under_doors/proc/unregister_user_and_door()
	if (current_user)
		REMOVE_TRAITS_IN(current_user, UNDER_DOOR_TRAIT)
		UnregisterSignal(current_user, COMSIG_MOVABLE_MOVED)
		current_user = null

	if (current_door)
		UnregisterSignal(current_door, list(COMSIG_QDELETING, COMSIG_ATOM_DENSITY_CHANGED, COMSIG_ATOM_RELAYMOVE))
		current_door = null

/datum/component/slide_under_doors/proc/on_user_moved(mob/living/user, obj/machinery/door/door, dir, forced, list/old_locs)
	SIGNAL_HANDLER
	if (user.loc != door)
		unregister_user_and_door()

/datum/component/slide_under_doors/proc/on_door_qdeleting(obj/machinery/door/door, force)
	SIGNAL_HANDLER
	unregister_user_and_door()

/datum/component/slide_under_doors/proc/on_door_density_changed(obj/machinery/door/door)
	SIGNAL_HANDLER
	if (!door.density)
		slide_out_from_under_door()

/datum/component/slide_under_doors/proc/on_door_relaymove(obj/machinery/door/door, mob/living/user, move_dir)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(try_slide_out_from_under_door), move_dir)
	return COMSIG_BLOCK_RELAYMOVE
