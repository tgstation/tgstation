#define POWER_BAR_STATE_WAITING_LIFETIME 1
#define POWER_BAR_STATE_WAITING_RECHARGE_DELAY 2

/datum/delayed_power_bar
	VAR_PRIVATE
		gave_power_bars = FALSE
		state = POWER_BAR_STATE_WAITING_LIFETIME

		creation_time
		last_poke_time = 0
		last_inactive_time = INFINITY

		datum/power_bar_allocation/power_bar_allocation

		initial_delay
		lifetime
		recharge_delay
		power_bar_gain

/datum/delayed_power_bar/New(source, initial_delay, lifetime, recharge_delay, power_bar_gain = 1)
	creation_time = world.time

	src.initial_delay = initial_delay
	src.lifetime = lifetime
	src.recharge_delay = recharge_delay
	src.power_bar_gain = power_bar_gain

	power_bar_allocation = new(source, power_bar_gain)

	// This could be made into timers
	START_PROCESSING(SSobj, src)

/datum/delayed_power_bar/Destroy(force, ...)
	remove_power_bars()

	STOP_PROCESSING(SSobj, src)

	return ..()

/datum/delayed_power_bar/process(delta_time)
	if (world.time - creation_time < initial_delay)
		return

	var/delay_since_last_poke = world.time - last_poke_time

	if (state == POWER_BAR_STATE_WAITING_RECHARGE_DELAY)
		if (delay_since_last_poke > lifetime)
			return

		ASSERT(last_inactive_time != INFINITY)
		var/delay_since_last_inactive = world.time - last_inactive_time

		if (delay_since_last_inactive < recharge_delay)
			return

		state = POWER_BAR_STATE_WAITING_LIFETIME

	ASSERT(state == POWER_BAR_STATE_WAITING_LIFETIME)

	if (delay_since_last_poke < lifetime)
		try_give_power_bars()
	else
		remove_power_bars()
		state = POWER_BAR_STATE_WAITING_RECHARGE_DELAY
		last_inactive_time = INFINITY

/datum/delayed_power_bar/proc/bar_ui_data()
	var/fill
	var/time_to_fill

	switch (state)
		if (POWER_BAR_STATE_WAITING_RECHARGE_DELAY)
			var/delay_since_last_poke = world.time - last_poke_time
			var/delay_since_last_inactive = world.time - last_inactive_time

			if (delay_since_last_poke > lifetime)
				fill = 0
				time_to_fill = recharge_delay
			else
				fill = delay_since_last_inactive / recharge_delay
				time_to_fill = recharge_delay - delay_since_last_inactive
		if (POWER_BAR_STATE_WAITING_LIFETIME)
			if (world.time - creation_time < initial_delay)
				time_to_fill = (initial_delay - (world.time - creation_time))
				fill = 1 - (time_to_fill / initial_delay)
			else
				fill = 1
				time_to_fill = lifetime - (world.time - last_poke_time)

	return list(
		"fill" = CLAMP01(fill),
		"time_to_fill" = max(0, time_to_fill),
		"power_bar_gain" = power_bar_gain,
	)

/datum/delayed_power_bar/proc/poke()
	if (state == POWER_BAR_STATE_WAITING_RECHARGE_DELAY)
		last_inactive_time = min(last_inactive_time, world.time)

	last_poke_time = world.time

/datum/delayed_power_bar/proc/try_give_power_bars()
	PRIVATE_PROC(TRUE)

	if (gave_power_bars)
		return

	gave_power_bars = TRUE
	SSpower_bars.give_power_bars(power_bar_allocation)

/datum/delayed_power_bar/proc/remove_power_bars()
	if (!gave_power_bars)
		return

	gave_power_bars = FALSE
	SSpower_bars.remove_power_bars(power_bar_allocation)

/datum/delayed_power_bar/proc/display_text()
	if (world.time - creation_time < initial_delay)
		return "Waiting for initial delay"

	switch (state)
		if (POWER_BAR_STATE_WAITING_LIFETIME)
			return "Active: [DisplayTimeText(world.time - last_poke_time)]"
		if (POWER_BAR_STATE_WAITING_RECHARGE_DELAY)
			return "Inactive"

#if DM_VERSION >= 515
/datum/delayed_power_bar/proc/operator""()
	return display_text()
#endif

#undef POWER_BAR_STATE_WAITING_LIFETIME
#undef POWER_BAR_STATE_WAITING_RECHARGE_DELAY
