/// Component that allows admins to control any object as if it were a mob.
/datum/component/object_possession
	/// Stores a reference to the mob that is currently possessing the object.
	var/mob/poltergeist = null
	/// Ref to the screen object that is currently being displayed.
	var/datum/weakref/screen_alert_ref = null
	/**
	  * back up of the real name during admin possession
	  *
	  * If an admin possesses an object it's real name is set to the admin name and this
	  * stores whatever the real name was previously. When possession ends, the real name
	  * is reset to this value
	  */
	var/stashed_name = null
	/// List of signals we register to in order to know when to end possession.
	var/static/list/signals_to_delete_on = list(
		COMSIG_END_OBJECT_POSSESSION_VIA_COMPONENT_CHAIN,
		COMSIG_END_OBJECT_POSSESSION_VIA_SCREEN_ALERT,
		COMSIG_END_OBJECT_POSSESSION_VIA_VERB,
		COMSIG_QDELETING,
	)

/datum/component/object_possession/Initialize(mob/user)
	. = ..()
	if(!isobj(parent) || !ismob(user))
		return COMPONENT_INCOMPATIBLE

	if(HAS_TRAIT(user, TRAIT_CURRENTLY_CONTROLLING_OBJECT))
		SEND_SIGNAL(user, COMSIG_END_OBJECT_POSSESSION_VIA_COMPONENT_CHAIN) // end the previous possession before we start the next one

	var/obj/obj_parent = parent

	if((obj_parent.obj_flags & DANGEROUS_POSSESSION) && CONFIG_GET(flag/forbid_singulo_possession))
		to_chat(user, "[obj_parent] is too powerful for you to possess.", confidential = TRUE)
		return COMPONENT_INCOMPATIBLE

	ADD_TRAIT(user, TRAIT_CURRENTLY_CONTROLLING_OBJECT, REF(parent))

	stashed_name = user.real_name
	poltergeist = user

	user.forceMove(obj_parent)
	user.real_name = obj_parent.name
	user.name = obj_parent.name
	user.reset_perspective(obj_parent)

	obj_parent.AddElement(/datum/element/weather_listener, /datum/weather/ash_storm, ZTRAIT_ASHSTORM, GLOB.ash_storm_sounds)

	RegisterSignals(user, signals_to_delete_on, PROC_REF(end_possession))
	RegisterSignal(user, COMSIG_MOB_CLIENT_PRE_NON_LIVING_MOVE, PROC_REF(on_move))

	screen_alert_ref = WEAKREF(user.throw_alert(ALERT_UNPOSSESS_OBJECT, /atom/movable/screen/alert/unpossess_object))

/datum/component/object_possession/Destroy()
	cleanup_ourselves()
	poltergeist = null
	return ..()

/// Cleans up everything when the admin wants out.
/datum/component/object_possession/proc/cleanup_ourselves()
	parent.RemoveElement(/datum/element/weather_listener, /datum/weather/ash_storm, ZTRAIT_ASHSTORM, GLOB.ash_storm_sounds)

	REMOVE_TRAIT(poltergeist, TRAIT_CURRENTLY_CONTROLLING_OBJECT, REF(parent))

	if(!isnull(stashed_name))
		poltergeist.real_name = stashed_name
		poltergeist.name = stashed_name
		if(ishuman(poltergeist))
			var/mob/living/carbon/human/human_user = poltergeist
			human_user.name = human_user.get_visible_name()

	poltergeist.forceMove(get_turf(parent))
	poltergeist.reset_perspective()

	UnregisterSignal(poltergeist, list(COMSIG_MOB_CLIENT_MOVE_POSSESSED_OBJECT) + signals_to_delete_on)

	var/atom/movable/screen/alert/alert_to_clear = screen_alert_ref?.resolve()
	if(isnull(alert_to_clear))
		return

	poltergeist.clear_alert(ALERT_UNPOSSESS_OBJECT)

/**
 * force move the parent object instead of the source mob.
 *
 * Has no sanity other than checking density
 */
/datum/component/object_possession/proc/on_move(datum/source, new_loc, direct)
	SIGNAL_HANDLER
	var/obj/obj_parent = parent
	if(QDELETED(obj_parent))
		qdel(src)
		return COMSIG_MOB_CLIENT_BLOCK_PRE_NON_LIVING_MOVE

	if(!obj_parent.density)
		obj_parent.forceMove(get_step(obj_parent, direct))
	else
		step(obj_parent, direct)

	if(QDELETED(obj_parent))
		qdel(src)
		return COMSIG_MOB_CLIENT_BLOCK_PRE_NON_LIVING_MOVE

	obj_parent.setDir(direct)
	return COMSIG_MOB_CLIENT_BLOCK_PRE_NON_LIVING_MOVE

/datum/component/object_possession/proc/end_possession(datum/source)
	SIGNAL_HANDLER
	qdel(src)
