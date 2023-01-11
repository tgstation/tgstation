/**
 * Attached to a basic mob.
 * Causes attacks on doors to attempt to open them.
 */
/datum/component/pry_open_door
	/// Odds the attack opens the door
	var/open_chance
	/// Time it takes to open a door with force
	var/force_wait

/datum/component/pry_open_door/Initialize(open_chance = 100, force_wait = 10 SECONDS)
	. = ..()

	if(!isbasicmob(parent))
		return COMPONENT_INCOMPATIBLE
	src.open_chance = open_chance
	src.force_wait = force_wait

/datum/component/pry_open_door/RegisterWithParent()
	RegisterSignal(parent, COMSIG_HOSTILE_POST_ATTACKINGTARGET, PROC_REF(hostile_attackingtarget))

/datum/component/pry_open_door/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_HOSTILE_POST_ATTACKINGTARGET)

/datum/component/pry_open_door/proc/hostile_attackingtarget(mob/living/basic/attacker, atom/target, success)
	SIGNAL_HANDLER

	if(!success)
		return
	if(istype(target, /obj/machinery/door/airlock) && prob(open_chance))
		var/obj/machinery/door/airlock/airlock_target = target
		INVOKE_ASYNC(src, PROC_REF(open_door), attacker, airlock_target)

/datum/component/pry_open_door/proc/open_door(mob/living/basic/attacker, obj/machinery/door/airlock/airlock_target)
	if(airlock_target.locked)
		to_chat(attacker, span_warning("The airlock's bolts prevent it from being forced!"))
		return
	else if(!airlock_target.allowed(attacker) && airlock_target.hasPower())
		attacker.visible_message(span_warning("We start forcing the [airlock_target] open."), \
		span_hear("You hear a metal screeching sound."))
		playsound(airlock_target, 'sound/machines/airlock_alien_prying.ogg', 100, TRUE)
		if(!do_after(attacker, force_wait, airlock_target))
			return
		if(airlock_target.locked)
			return
		attacker.visible_message(span_warning("We force the [airlock_target] to open."))
		airlock_target.open(2)
	else if(!airlock_target.hasPower())
		attacker.visible_message(span_warning("We force the [airlock_target] to open."))
		airlock_target.open(1)
	else
		airlock_target.open(0)
