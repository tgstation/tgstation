/obj/structure/destructible/clockwork/gear_base/powered
	/// If the structure has its "on" switch flipped. Does not mean it's on, necessarily (needs power and anchoring, too)
	var/enabled = FALSE
	/// If the structure is "on" and working.
	var/processing = FALSE
	/// If this ran out of power during process()
	var/insufficient_power = FALSE
	/// How much power this structure uses passively
	var/passive_consumption = 0
	/// Makes sure the depowered proc is only called when it transitions from powered -> depowered, NOT every process() while already depowered
	var/depowered = FALSE
	/// Minimum power to work
	var/minimum_power = 0
	/// Lazylist of nearby transmission signals
	var/list/transmission_sigils
	/// Has an "_inactive" icon state
	var/has_off_icon = TRUE
	/// Has an "_active" icon state
	var/has_on_icon = TRUE
	/// Has the ability to toggle power by using an empty hand on it
	var/has_power_toggle = TRUE


/obj/structure/destructible/clockwork/gear_base/powered/Initialize(mapload)
	. = ..()
	update_icon_state()
	LAZYINITLIST(transmission_sigils)
	for(var/obj/structure/destructible/clockwork/sigil/transmission/trans_sigil in range(src, SIGIL_TRANSMISSION_RANGE))
		link_to_sigil(trans_sigil)


/obj/structure/destructible/clockwork/gear_base/powered/Destroy()
	for(var/obj/structure/destructible/clockwork/sigil/transmission/trans_sigil as anything in transmission_sigils)
		trans_sigil.linked_structures -= src
	return ..()


/obj/structure/destructible/clockwork/gear_base/powered/attack_hand(mob/user)
	if(!IS_CLOCK(user))
		return ..()

	if(!anchored)
		balloon_alert(user, "not fastened!")
		return

	if(!has_power_toggle)
		return

	if(!update_power() && !enabled)
		balloon_alert(user, "not enough power!")
		return

	enabled = !enabled
	balloon_alert(user, "turned [enabled ? "on" : "off"]")

	if(enabled)
		turn_on()

	else
		turn_off()


/obj/structure/destructible/clockwork/gear_base/powered/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	if(!.)
		return

	if(anchored)
		return

	enabled = FALSE
	depowered()

	if(processing)
		processing = FALSE
		STOP_PROCESSING(SSobj, src)


/obj/structure/destructible/clockwork/gear_base/powered/update_icon_state()
	. = ..()
	icon_state = base_icon_state || initial(icon_state)

	if(!anchored)
		icon_state = base_icon_state + unwrenched_suffix
		return

	if(has_off_icon && (depowered || !enabled))
		icon_state = base_icon_state + "_inactive"
		return

	if(has_on_icon && !depowered)
		icon_state = base_icon_state + "_active"


/obj/structure/destructible/clockwork/gear_base/powered/process(delta_time)
	if(!use_power(passive_consumption))
		depowered()
		insufficient_power = TRUE
		return FALSE

	if(insufficient_power)
		insufficient_power = FALSE
		repowered()
		return TRUE

	if(!anchored)
		turn_off()
		update_icon_state()
		visible_message("[src] powers down as it becomes unanchored from the ground.")
		return FALSE

	return TRUE


/// Turn on the structure, letting it consume power and process again
/obj/structure/destructible/clockwork/gear_base/powered/proc/turn_on()
	repowered()
	processing = TRUE
	START_PROCESSING(SSobj, src)


/// Turn off the structure, ceasing its processing
/obj/structure/destructible/clockwork/gear_base/powered/proc/turn_off()
	depowered()
	processing = FALSE
	STOP_PROCESSING(SSobj, src)


/// Checks if there's enough power to power it, calls repower() if changed from depowered to powered, vice versa
/obj/structure/destructible/clockwork/gear_base/powered/proc/update_power()
	if(depowered)

		if((GLOB.clock_power > minimum_power && LAZYLEN(transmission_sigils)) || !minimum_power)
			repowered()

			return TRUE

		return FALSE

	else

		if(GLOB.clock_power <= minimum_power || !LAZYLEN(transmission_sigils))
			depowered()

			return FALSE

		return TRUE


/// Checks if there's equal or greater power to the amount arg, TRUE if so, FALSE otherwise
/obj/structure/destructible/clockwork/gear_base/powered/proc/check_power(amount)
	if(!amount)
		return TRUE

	if(!LAZYLEN(transmission_sigils))
		return FALSE

	if(depowered)
		return FALSE

	if(GLOB.clock_power < amount)
		return FALSE

	return TRUE


/// Uses power if there's enough to do so
/obj/structure/destructible/clockwork/gear_base/powered/proc/use_power(amount)
	update_power()

	if(!check_power(amount))
		return FALSE

	GLOB.clock_power -= amount
	update_power()
	return TRUE


/// Triggers when the structure runs out of power to use
/obj/structure/destructible/clockwork/gear_base/powered/proc/depowered()
	SHOULD_CALL_PARENT(TRUE)
	depowered = TRUE
	update_icon_state()


/// Triggers when the structure regains power to use
/obj/structure/destructible/clockwork/gear_base/powered/proc/repowered()
	SHOULD_CALL_PARENT(TRUE)
	depowered = FALSE
	update_icon_state()


/// Adds a sigil to the linked structure list
/obj/structure/destructible/clockwork/gear_base/powered/proc/link_to_sigil(obj/structure/destructible/clockwork/sigil/transmission/sigil)
	LAZYOR(transmission_sigils, sigil)
	sigil.linked_structures |= src


/// Removes a sigil from the linked structure list
/obj/structure/destructible/clockwork/gear_base/powered/proc/unlink_to_sigil(obj/structure/destructible/clockwork/sigil/transmission/sigil)
	if(!LAZYFIND(transmission_sigils, sigil))
		return

	LAZYREMOVE(transmission_sigils, sigil)
	sigil.linked_structures -= src

	check_power()
