/// Component that allows a user to control any object as if it were a mob. Does give the user incorporeal movement.
/datum/component/object_possession
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	/// Stores a reference to the obj that we are currently possessing.
	var/obj/possessed = null
	/// Ref to the screen object that is currently being displayed.
	var/datum/weakref/screen_alert_ref = null
	/**
	  * back up of the real name during user possession
	  *
	  * When a user possesses an object its real name is set to the user name and this
	  * stores whatever the real name was previously. When possession ends, the real name
	  * is reset to this value
	  */
	var/stashed_name = null

/datum/component/object_possession/Initialize(obj/target)
	. = ..()
	if(!isobj(target) || !ismob(parent))
		return COMPONENT_INCOMPATIBLE

	if(!bind_to_new_object(target))
		return COMPONENT_INCOMPATIBLE

	var/mob/user = parent
	screen_alert_ref = WEAKREF(user.throw_alert(ALERT_UNPOSSESS_OBJECT, /atom/movable/screen/alert/unpossess_object))

	// we can expect to be possessed by either a nonliving or a living mob
	RegisterSignals(parent, list(COMSIG_MOB_CLIENT_PRE_LIVING_MOVE, COMSIG_MOB_CLIENT_PRE_NON_LIVING_MOVE), PROC_REF(on_move))
	RegisterSignals(parent, list(COMSIG_MOB_GHOSTIZED, COMSIG_KB_ADMIN_AGHOST_DOWN), PROC_REF(end_possession))

/datum/component/object_possession/Destroy()
	cleanup_object_binding()
	UnregisterSignal(parent, list(
		COMSIG_KB_ADMIN_AGHOST_DOWN,
		COMSIG_MOB_CLIENT_PRE_LIVING_MOVE,
		COMSIG_MOB_CLIENT_PRE_NON_LIVING_MOVE,
		COMSIG_MOB_GHOSTIZED,
	))

	var/mob/user = parent
	var/atom/movable/screen/alert/alert_to_clear = screen_alert_ref?.resolve()
	if(!QDELETED(alert_to_clear))
		user.clear_alert(ALERT_UNPOSSESS_OBJECT)

	return ..()

/datum/component/object_possession/InheritComponent(datum/component/object_possession/old_component, i_am_original, obj/target)
	cleanup_object_binding()
	if(!bind_to_new_object(target))
		qdel(src)

	stashed_name = old_component.stashed_name

/// Binds the mob to the object and sets up the naming and everything.
/// Returns FALSE if we don't bind, TRUE if we succeed.
/datum/component/object_possession/proc/bind_to_new_object(obj/target)
	if((target.obj_flags & DANGEROUS_POSSESSION) && CONFIG_GET(flag/forbid_singulo_possession))
		to_chat(parent, "[target] is too powerful for you to possess.", confidential = TRUE)
		return FALSE

	var/mob/user = parent

	stashed_name = user.real_name
	possessed = target

	user.forceMove(target)
	user.real_name = target.name
	user.name = target.name
	user.reset_perspective(target)

	target.AddElement(/datum/element/weather_listener, /datum/weather/ash_storm, ZTRAIT_ASHSTORM, GLOB.ash_storm_sounds)
	target.AddElement(/datum/element/weather_listener, /datum/weather/snow_storm, ZTRAIT_SNOWSTORM, GLOB.snowstorm_sounds)
	target.AddElement(/datum/element/weather_listener, /datum/weather/rain_storm, ZTRAIT_RAINSTORM, GLOB.rain_storm_sounds)
	target.AddElement(/datum/element/weather_listener, /datum/weather/sand_storm, ZTRAIT_SANDSTORM, GLOB.sand_storm_sounds)

	RegisterSignal(target, COMSIG_QDELETING, PROC_REF(end_possession))
	return TRUE

/// Cleans up everything pertinent to the current possessed object.
/datum/component/object_possession/proc/cleanup_object_binding()
	if(QDELETED(possessed))
		return

	var/mob/poltergeist = parent

	possessed.RemoveElement(/datum/element/weather_listener, /datum/weather/ash_storm, ZTRAIT_ASHSTORM, GLOB.ash_storm_sounds)
	possessed.RemoveElement(/datum/element/weather_listener, /datum/weather/rain_storm, ZTRAIT_RAINSTORM, GLOB.rain_storm_sounds)
	possessed.RemoveElement(/datum/element/weather_listener, /datum/weather/sand_storm, ZTRAIT_SANDSTORM, GLOB.sand_storm_sounds)
	possessed.RemoveElement(/datum/element/weather_listener, /datum/weather/snow_storm, ZTRAIT_SNOWSTORM, GLOB.snowstorm_sounds)
	UnregisterSignal(possessed, COMSIG_QDELETING)

	if(!isnull(stashed_name))
		poltergeist.real_name = stashed_name
		poltergeist.name = stashed_name
		if(ishuman(poltergeist))
			var/mob/living/carbon/human/human_user = poltergeist
			human_user.name = human_user.get_visible_name()

	poltergeist.forceMove(get_turf(possessed))
	poltergeist.reset_perspective()

	possessed = null

/**
 * force move the parent object instead of the source mob.
 *
 * Has no sanity other than checking the possed obj's density. this means it effectively has incorporeal movement, making it only good for badminnery.
 *
 * We always want to return `COMPONENT_MOVABLE_BLOCK_PRE_MOVE` here regardless
 */
/datum/component/object_possession/proc/on_move(datum/source, new_loc, direct)
	SIGNAL_HANDLER
	. = COMPONENT_MOVABLE_BLOCK_PRE_MOVE // both signals that invoke this are explicitly tied to listen for this define as the return value

	if(QDELETED(possessed))
		return .

	if(!possessed.density)
		possessed.forceMove(get_step(possessed, direct))
	else
		step(possessed, direct)

	if(QDELETED(possessed))
		return .

	possessed.setDir(direct)
	return .

/// Just the overall "get me outta here" proc.
/datum/component/object_possession/proc/end_possession(datum/source)
	SIGNAL_HANDLER
	qdel(src)
