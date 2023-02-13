/datum/component/thermite
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	///Amoumt of thermite on parent
	var/amount
	///Amount of thermite required to burn through parent
	var/burn_require
	///The thermite overlay
	var/overlay
	///The timer for burning parent
	var/burn_timer
	///The thermite fire overlay
	var/obj/effect/overlay/thermite/fakefire

	///Blacklist of turfs that cannot have thermite on it
	var/static/list/blacklist = typecacheof(list(
		/turf/open/lava,
		/turf/open/space,
		/turf/open/water,
		/turf/open/chasm,
	))
	///List of turfs that are immune to thermite
	var/static/list/immunelist = typecacheof(list(
		/turf/closed/wall/mineral/diamond,
		/turf/closed/indestructible,
		/turf/open/indestructible,
	))
	///List of turfs that take extra thermite to burn through
	var/static/list/resistlist = typecacheof(list(
		/turf/closed/wall/r_wall,
	))

/datum/component/thermite/Initialize(_amount)
	if(!istype(parent, /turf) || blacklist[parent.type])
		return COMPONENT_INCOMPATIBLE

	if(immunelist[parent.type])
		amount = 0 //Yeah the overlay can still go on it and be cleaned but you arent burning down a diamond wall
	else
		amount = _amount
		if(resistlist[parent.type])
			burn_require = 50
		else
			burn_require = 30

	var/turf/master = parent
	overlay = mutable_appearance('icons/effects/effects.dmi', "thermite")
	master.add_overlay(overlay)

	RegisterSignal(parent, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(clean_react))
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, PROC_REF(attackby_react))
	RegisterSignal(parent, COMSIG_ATOM_FIRE_ACT, PROC_REF(flame_react))

/datum/component/thermite/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_COMPONENT_CLEAN_ACT)
	UnregisterSignal(parent, COMSIG_PARENT_ATTACKBY)
	UnregisterSignal(parent, COMSIG_ATOM_FIRE_ACT)
	UnregisterSignal(parent, COMSIG_PARENT_QDELETING)

/datum/component/thermite/Destroy()
	var/turf/master = parent
	master.cut_overlay(overlay)
	return ..()

/datum/component/thermite/InheritComponent(datum/component/thermite/newC, i_am_original, _amount)
	if(!i_am_original)
		return
	if(newC)
		amount += newC.amount
	else
		amount += _amount
	if (burn_timer) // prevent people from skipping a longer timer
		deltimer(burn_timer)
		burn_timer = addtimer(CALLBACK(src, PROC_REF(burn_parent), usr), min(amount * 0.35 SECONDS, 20 SECONDS), TIMER_STOPPABLE)

/**
 * Used to begin the thermite burning process
 *
 * Arguments:
 * * mob/user - The user igniting the thermite
 */
/datum/component/thermite/proc/thermite_melt(mob/user)
	var/turf/master = parent
	master.cut_overlay(overlay)
	playsound(master, 'sound/items/welder.ogg', 100, TRUE)
	fakefire = new(master)
	burn_timer = addtimer(CALLBACK(src, PROC_REF(burn_parent), user), min(amount * 0.35 SECONDS, 20 SECONDS), TIMER_STOPPABLE)
	UnregisterFromParent()
	RegisterSignal(parent, COMSIG_PARENT_QDELETING, PROC_REF(delete_fire)) //in case parent gets deleted, get ready to delete the fire

/**
 * Used to actually melt parent
 *
 * Arguments:
 * * mob/user - The user that ignited the thermite
 */
/datum/component/thermite/proc/burn_parent(mob/user)
	var/turf/master = parent
	delete_fire()
	if(user)
		master.add_hiddenprint(user)
	if(amount >= burn_require)
		master = master.Melt()
		master.burn_tile()
	qdel(src)

/**
 * Used to delete the fake fire overlay
 */
/datum/component/thermite/proc/delete_fire()
	SIGNAL_HANDLER

	if(!QDELETED(fakefire))
		qdel(fakefire)

/**
 * wash reaction, used to clean off thermite from parent
 */
/datum/component/thermite/proc/clean_react(datum/source, strength)
	SIGNAL_HANDLER

	//Thermite is just some loose powder, you could probably clean it with your hands. << todo?
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
/datum/component/thermite/proc/flame_react(datum/source, exposed_temperature, exposed_volume)
	SIGNAL_HANDLER

	if(exposed_temperature > 1922) // This is roughly the real life requirement to ignite thermite
		thermite_melt()

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

	if(thing.get_temperature())
		thermite_melt(user)
