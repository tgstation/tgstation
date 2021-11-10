/*
 * Power refundee component.
 *
 * It marks the parent as being able to take refunds of power,
 * when a powernet didn't use all sent energy last power tick.
 *
 * This is important as eg. SMES units fully output power at
 * their configured rate, and rely on this behavior to avoid
 * wasting energy.
 */
/datum/component/power_refundee
	/// Callback to invoke on our parent when we try to return unused power to it
	var/datum/callback/refunding_callback

	/// If our input and output powernets are somehow cyclically reachable (or the same), this will prevent an infinite loop
	var/currently_refunding_excess = FALSE

/datum/component/power_refundee/Initialize(datum/callback/refund_callback)
	var/obj/machinery/power/machine = parent
	if (!istype(machine))
		return COMPONENT_INCOMPATIBLE
	if (machine.powernet)
		powernet_attached(machine, machine.powernet)
	refunding_callback = refund_callback

/datum/component/power_refundee/Destroy()
	refunding_callback = null
	. = ..()

/datum/component/power_refundee/RegisterWithParent(datum/target, datum/callback/handle_refund)
	. = ..()

	// Listen for changes in the parent's powernet
	RegisterSignal(parent, COMSIG_POWERNET_CABLE_ATTACHED, .proc/powernet_attached)
	RegisterSignal(parent, COMSIG_POWERNET_CABLE_DETACHED, .proc/powernet_detached)

/datum/component/power_refundee/UnregisterFromParent()
	var/obj/machinery/power/machine = parent
	UnregisterSignal(parent, list(COMSIG_POWERNET_CABLE_ATTACHED, COMSIG_POWERNET_CABLE_DETACHED))
	if (machine.powernet)
		powernet_detached(machine.powernet)

/datum/component/power_refundee/proc/powernet_attached(machine, new_powernet)
	SIGNAL_HANDLER
	// We're now on a new powernet, listen on it for all refund events.
	RegisterSignal(new_powernet, COMSIG_POWERNET_DO_REFUND, .proc/handle_refund)

/datum/component/power_refundee/proc/powernet_detached(machine, old_powernet)
	SIGNAL_HANDLER
	// We're not on this powernet anymore, stop listening to refund events.
	UnregisterSignal(old_powernet, COMSIG_POWERNET_DO_REFUND)

/datum/component/power_refundee/proc/handle_refund(powernet)
	SIGNAL_HANDLER
	// Prevent recursion/powernet graph loops
	if (currently_refunding_excess)
		return
	currently_refunding_excess = TRUE
	// Invoke the refunding callback
	call(parent, refunding_callback)(powernet)
	currently_refunding_excess = FALSE
