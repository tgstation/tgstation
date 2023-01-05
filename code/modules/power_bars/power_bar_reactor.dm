/datum/component/power_bar_reactor
	var/department
	var/datum/callback/on_changed

/datum/component/power_bar_reactor/Initialize(department, datum/callback/on_changed)
	if (!(department in SSpower_bars.department_allocations))
		stack_trace("Invalid department for power bar reactor: [department]")
		return COMPONENT_INCOMPATIBLE

	src.department = department
	src.on_changed = on_changed

	if (MC_RUNNING(SSpower_bars.init_stage))
		attach()
	else
		RegisterSignal(SSpower_bars, COMSIG_SUBSYSTEM_POST_INITIALIZE, PROC_REF(attach))

/datum/component/power_bar_reactor/proc/attach()
	SIGNAL_HANDLER
	UnregisterSignal(SSpower_bars, COMSIG_SUBSYSTEM_POST_INITIALIZE)

	if (!SSpower_bars.enabled)
		return

	RegisterSignal(SSpower_bars, COMSIG_POWER_BARS_UPDATED, PROC_REF(on_power_bars_updated))

	on_changed.InvokeAsync(SSpower_bars.last_distributed_allocations[department])

/datum/component/power_bar_reactor/proc/on_power_bars_updated(datum/controller/subsystem/power_bars/power_bars_ss, list/departments)
	SIGNAL_HANDLER

	for (var/new_department in departments)
		if (new_department != department)
			continue

		var/old_power_bars = departments[new_department]
		var/new_power_bars = power_bars_ss.last_distributed_allocations[new_department]

		if (ismovable(parent))
			var/atom/movable/movable_parent = parent

			if (new_power_bars > old_power_bars)
				movable_parent.say("Power input increased!", forced = "power bars reactor")
				playsound(movable_parent, 'sound/machines/ping.ogg', 30, vary = TRUE)
			else if (old_power_bars > 0)
				movable_parent.say("Power input decreased...", forced = "power bars reactor")
				playsound(movable_parent, 'sound/machines/buzz-sigh.ogg', 30, vary = TRUE)
			else
				movable_parent.say("Power input depleted!", forced = "power bars reactor")
				playsound(movable_parent, 'sound/machines/buzz-two.ogg', 30, vary = TRUE)

		on_changed.InvokeAsync(new_power_bars)

