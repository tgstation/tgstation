/datum/component/thermite
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	/// Amount of thermite on parent
	var/amount
	/// Amount of thermite required to burn through parent
	var/burn_require
	/// The thermite overlay
	var/thermite_overlay
	/// Default thermite overlay, do not touch
	var/static/mutable_appearance/default_thermite_overlay = mutable_appearance('icons/effects/effects.dmi', "thermite")
	/// Callback related to burning, stored so the timer can be easily reset without losing the user
	var/datum/callback/burn_callback
	/// The timer for burning parent, calls burn_callback when done
	var/burn_timer
	/// The thermite fire overlay
	var/obj/effect/overlay/thermite/fakefire

	/// Blacklist of turfs that cannot have thermite on it
	var/static/list/blacklist = typecacheof(list(
		/turf/open/lava,
		/turf/open/space,
		/turf/open/water,
		/turf/open/chasm,
	))
	/// List of turfs that are immune to thermite
	var/static/list/immunelist = typecacheof(list(
		/turf/closed/wall/mineral/diamond,
		/turf/closed/indestructible,
		/turf/open/indestructible,
	))
	/// List of turfs that take extra thermite to burn through
	var/static/list/resistlist = typecacheof(list(
		/turf/closed/wall/r_wall,
	))

/datum/component/thermite/Initialize(amount = 50, thermite_overlay = default_thermite_overlay)
	if(!isturf(parent))
		return COMPONENT_INCOMPATIBLE
	//not actually incompatible, but not valid
	if(blacklist[parent.type])
		qdel(src)
		return

	if(immunelist[parent.type])
		src.amount = 0 //Yeah the overlay can still go on it and be cleaned but you arent burning down a diamond wall
	else
		src.amount = amount
		if(resistlist[parent.type])
			burn_require = 50
		else
			burn_require = 30

	src.thermite_overlay = thermite_overlay

/datum/component/thermite/Destroy()
	thermite_overlay = null
	if(burn_timer)
		deltimer(burn_timer)
		burn_timer = null
	if(burn_callback)
		burn_callback = null
	if(fakefire)
		QDEL_NULL(fakefire)
	return ..()

/datum/component/thermite/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(attackby_react))
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_attack_hand))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_ATOM_FIRE_ACT, PROC_REF(on_fire_act))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_update_overlays))
	RegisterSignal(parent, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(clean_react))
	RegisterSignal(parent, COMSIG_QDELETING, PROC_REF(parent_qdeleting)) //probably necessary because turfs are wack
	var/turf/turf_parent = parent
	turf_parent.update_appearance()

/datum/component/thermite/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ATOM_ATTACKBY,
		COMSIG_ATOM_ATTACK_HAND,
		COMSIG_ATOM_EXAMINE,
		COMSIG_ATOM_FIRE_ACT,
		COMSIG_ATOM_UPDATE_OVERLAYS,
		COMSIG_COMPONENT_CLEAN_ACT,
		COMSIG_QDELETING,
	))
	var/turf/turf_parent = parent
	turf_parent.update_appearance()

/datum/component/thermite/InheritComponent(datum/component/thermite/new_comp, i_am_original, amount)
	if(!i_am_original)
		return
	src.amount += amount
	if(burn_timer) // prevent people from skipping a longer timer
		deltimer(burn_timer)
		burn_timer = addtimer(burn_callback, min(amount * 0.35 SECONDS, 20 SECONDS), TIMER_STOPPABLE)

/// Alerts the user that this turf is, in fact, covered with thermite.
/datum/component/thermite/proc/on_examine(turf/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	examine_list += span_warning("[source.p_Theyre()] covered in thermite.")

/// Used to maintain the thermite overlay on the parent [/turf].
/datum/component/thermite/proc/on_update_overlays(turf/parent_turf, list/overlays)
	SIGNAL_HANDLER

	if(thermite_overlay)
		overlays += thermite_overlay

/**
 * Used to begin the thermite burning process
 *
 * Arguments:
 * * mob/user - The user igniting the thermite
 */
/datum/component/thermite/proc/thermite_melt(mob/user)
	var/turf/parent_turf = parent
	playsound(parent_turf, 'sound/items/tools/welder.ogg', 100, TRUE)
	fakefire = new(parent_turf)
	burn_callback = CALLBACK(src, PROC_REF(burn_parent), user)
	burn_timer = addtimer(burn_callback, min(amount * 0.35 SECONDS, 20 SECONDS), TIMER_STOPPABLE)
	//unregister everything related to burning
	UnregisterSignal(parent, list(COMSIG_COMPONENT_CLEAN_ACT, COMSIG_ATOM_ATTACKBY, COMSIG_ATOM_FIRE_ACT))

/**
 * Used to actually melt parent
 *
 * Arguments:
 * * mob/user - The user that ignited the thermite
 */
/datum/component/thermite/proc/burn_parent(mob/user)
	var/turf/parent_turf = parent
	if(fakefire)
		QDEL_NULL(fakefire)
	if(user)
		parent_turf.add_hiddenprint(user)
	if(amount >= burn_require)
		parent_turf = parent_turf.Melt()
		parent_turf.burn_tile()
	burn_timer = null
	qdel(src)

/**
 * Wash reaction, used to clean off thermite from parent
 */
/datum/component/thermite/proc/clean_react(datum/source, strength)
	SIGNAL_HANDLER

	. = NONE

	//Thermite is just some loose powder, you could probably clean it with your hands
	qdel(src)

	return COMPONENT_CLEANED

/**
 * fire_act reaction, has to be the correct temperature
 *
 * Arguments:
 * * datum/source - The source of the flame
 * * exposed_temperature - The temperature of the flame hitting the thermite
 * * exposed_volume - The volume of the flame
 */
/datum/component/thermite/proc/on_fire_act(datum/source, exposed_temperature, exposed_volume)
	SIGNAL_HANDLER

	// This is roughly the real life requirement to ignite thermite
	// (honestly not really sure what the point of this is, considering a god damn lighter can ignite this)
	if(exposed_temperature >= 1922)
		thermite_melt()

/// Handles searing the hand of anyone who tries to touch parent without protection, while burning
/datum/component/thermite/proc/on_attack_hand(atom/source, mob/living/carbon/user)
	SIGNAL_HANDLER

	//not burning
	if(!fakefire)
		return NONE

	if(!iscarbon(user) || user.can_touch_burning(source))
		return NONE

	user.apply_damage(5, BURN, user.get_active_hand())
	to_chat(user, span_userdanger("The ignited thermite on \the [source] burns your hand!"))
	INVOKE_ASYNC(user, TYPE_PROC_REF(/mob, emote), "scream")
	playsound(source, SFX_SEAR, 50, TRUE)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/**
 * attackby reaction, ignites the thermite if its a flame creating object
 *
 * Arguments:
 * * datum/source - The source of the attack
 * * obj/item/thing - Item being attacked by
 * * mob/user - The user behind the attack
 * * params - params
 */
/datum/component/thermite/proc/attackby_react(datum/source, obj/item/thing, mob/user, params)
	SIGNAL_HANDLER

	if(thing.get_temperature() >= FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
		thermite_melt(user)

/// Signal handler for COMSIG_QDELETING, necessary because turfs can be weird with qdel()
/datum/component/thermite/proc/parent_qdeleting(datum/source)
	SIGNAL_HANDLER

	if(!QDELING(src))
		qdel(src)
