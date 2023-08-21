/// Status effect that gives the target miscellanous debuffs while throwing a status alert and causing them to smoke from the damage they're incurring.
/// Purposebuilt for cursed slot machines.
/datum/status_effect/grouped/cursed
	id = "cursed"
	alert_type = /atom/movable/screen/alert/status_effect/cursed
	/// Static list of signals that will update our count.
	var/static/list/updatable_signals = list(COMSIG_CURSED_SLOT_MACHINE_USE)
	/// The max number of curses a target can incur with this status effect.
	var/max_curse_count = 5
	/// The amount of times we have been "applied" to the target.
	var/curse_count = 0
	/// Probability we have to deal damage this tick.
	var/damage_chance = 10

/datum/status_effect/grouped/cursed/on_apply()
	RegisterSignal(SSdcs, COMSIG_GLOB_CURSED_SLOT_MACHINE_WON, PROC_REF(clear_curses))
	RegisterSignals(owner, updatable_signals, PROC_REF(update_curse_count))
	update_curse_count()
	return ..()

/// The master proc of this status effect. Tracks the number of curses the target has and applies the appropriate debuffs.
/datum/status_effect/grouped/cursed/proc/update_curse_count()
	SIGNAL_HANDLER
	curse_count++
	if(curse_count >= max_curse_count)
		qdel(src)
		return SLOT_MACHINE_USE_CANCEL // slot machine will handle the killing and all of that jazz

	linked_alert.update_description()

	update_particles()

/// Cleans ourselves up and removes our curses. Meant to be done in a "positive" way, when the curse is broken. Directly use qdel otherwise.
/datum/status_effect/grouped/cursed/proc/clear_curses()
	SIGNAL_HANDLER

	owner.visible_message(
		span_notice("The smoke slowly clears from [owner.name]..."),
		span_notice("Your skin finally settles down and your throat no longer feels as dry... The curse has been lifted."),
	)
	qdel(src)

/datum/status_effect/grouped/cursed/update_particles()
	var/particle_path = /particles/smoke/steam/mild
	switch(curse_count)
		if(2 to 3)
			particle_path = /particles/smoke/steam
		if(4)
			particle_path = /particles/smoke/steam/bad

	particle_effect = new(owner, particle_path)

/datum/status_effect/grouped/cursed/tick(seconds_between_ticks)
	if(curse_count >= max_curse_count)
		return // what

	if(curse_count == 1)
		return // you get one freebie before the house begins to win.

	// the house won.
	var/effective_percentile_chance = damage_chance * (curse_count == 2 ? 1 : curse_count) // 10 to 40 percent depending on how cursed we are

	if(SPT_PROB(effective_percentile_chance, seconds_between_ticks))
		owner.apply_damages(
			brute = curse_count,
			burn = curse_count,
			tox = curse_count,
			oxy = curse_count,
			stamina = curse_count,
			brain = curse_count * 2, // something about the dopamine reward system and the basal ganglia
		)

/atom/movable/screen/alert/status_effect/cursed
	name = "Cursed!"
	desc = "Your greed is catching up to you..."

/atom/movable/screen/alert/status_effect/update_description()
	var/datum/status_effect/grouped/cursed/linked_effect = attached_effect
	var/curses = linked_effect.curse_count
	switch(curses)
		if(1 to 2)
			desc = initial(desc)
		if(3)
			desc = "You really don't feel good right now... But why stop now?"
		if(4)
			desc = "Real winners quit before they reach the ultimate prize."
