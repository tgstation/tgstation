#define POWER_BAR_STATE_WAITING_LIFETIME 1
#define POWER_BAR_STATE_WAITING_RECHARGE_DELAY 2

/datum/delayed_power_bar
	var/gave_power_bars = FALSE

	VAR_PRIVATE
		state = POWER_BAR_STATE_WAITING_LIFETIME

		creation_time
		last_poke_time = 0
		last_inactive_time = 0

		initial_delay
		lifetime
		recharge_delay
		power_bar_gain

/datum/delayed_power_bar/New(initial_delay, lifetime, recharge_delay, power_bar_gain = 1)
	creation_time = world.time

	src.initial_delay = initial_delay
	src.lifetime = lifetime
	src.recharge_delay = recharge_delay
	src.power_bar_gain = power_bar_gain

	// This could be made into timers
	START_PROCESSING(SSobj, src)

/datum/delayed_power_bar/Destroy(force, ...)
	remove_power_bars()

	STOP_PROCESSING(SSobj, src)

	return ..()

/datum/delayed_power_bar/process(delta_time)
	if (world.time - creation_time < initial_delay)
		return

	if (state == POWER_BAR_STATE_WAITING_RECHARGE_DELAY)
		var/delay_since_last_inactive = world.time - last_inactive_time

		if (delay_since_last_inactive < recharge_delay)
			return

		state = POWER_BAR_STATE_WAITING_LIFETIME

	ASSERT(state == POWER_BAR_STATE_WAITING_LIFETIME)

	var/delay_since_last_poke = world.time - last_poke_time

	if (delay_since_last_poke < lifetime)
		try_give_power_bars()
	else
		remove_power_bars()
		state = POWER_BAR_STATE_WAITING_RECHARGE_DELAY
		last_inactive_time = world.time

/datum/delayed_power_bar/proc/poke()
	last_poke_time = world.time

/datum/delayed_power_bar/proc/try_give_power_bars()
	PRIVATE_PROC(TRUE)

	if (gave_power_bars)
		return

	gave_power_bars = TRUE
	SSpower_bars.available_power_bars += power_bar_gain

/datum/delayed_power_bar/proc/remove_power_bars()
	if (!gave_power_bars)
		return

	SSpower_bars.remove_power_bars(power_bar_gain)

#if DM_VERSION >= 515
/datum/delayed_power_bar/proc/operator""()
	if (world.time - creation_time < initial_delay)
		return "Waiting for initial delay"

	switch (state)
		if (POWER_BAR_STATE_WAITING_LIFETIME)
			return "Active: [DisplayTimeText(world.time - last_poke_time)]"
		if (POWER_BAR_STATE_WAITING_RECHARGE_DELAY)
			return "Inactive: [DisplayTimeText(world.time - last_inactive_time)]"
#endif

#undef POWER_BAR_STATE_WAITING_LIFETIME
#undef POWER_BAR_STATE_WAITING_RECHARGE_DELAY
