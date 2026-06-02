// Generates an abandoned crate and acts as an interface to solve it.
// The amount of abandoned crates it can generate is limited.
// When a new crate is generated, the old one gets deleted.
/datum/gizmodes/moo
	guaranteed_active_gizmodes = list(
		/datum/gizpulse/make_crate,
		/datum/gizpulse/cycle_position,
		/datum/gizpulse/cycle_digit,
		/datum/gizpulse/send_code
	)

	mode_pulses = list(
		/datum/gizpulse/mode_controle/direct_activate,
	)
	// Maximum amount of crates that can be generated.
	var/max_crates = 3
	// How many crates were generated so far.
	var/crates_generated = 0
	// Reference to the crate currently being solved
	var/obj/structure/closet/crate/secure/loot/crate
	// Current input.
	var/list/current_code = list("0","0","0","0")
	// Which position is currently selected (0 - 3)
	var/position = 0
	// Which digit is currently selected (0 - 9)
	var/digit = 0

/datum/gizmodes/moo/Destroy()
	. = ..()
	current_code = null
	QDEL_NULL(crate)

// Create the crate
/datum/gizpulse/make_crate/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	var/datum/gizmodes/moo/moo = astype(master)
	if(!moo)
		return

	if(moo.crates_generated == moo.max_crates)
		playsound(holder, "sound/machines/uplink/uplinkerror.ogg", 100)
		return
	QDEL_NULL(moo.crate)
	moo.crate = new(holder)
	moo.crates_generated++
	playsound(holder, "sound/mobs/non-humanoids/cow/cow.ogg", 100)

// Cycle selected position
/datum/gizpulse/cycle_position/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	var/datum/gizmodes/moo/moo = astype(master)
	if(!moo)
		return
	moo.position = (moo.position + 1) % 4
	if(moo.position != 0)
		playsound(holder, "sound/machines/eject.ogg", 100)
		return
	for(var/i in 1 to 3)
		playsound(holder, "sound/machines/eject.ogg", 100)
		sleep(0.15 SECONDS)

// Cycle selected digit
/datum/gizpulse/cycle_digit/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	var/datum/gizmodes/moo/moo = astype(master)
	if(!moo)
		return
	moo.digit = (moo.digit + 1) % 10
	moo.current_code[moo.position + 1] = "[moo.digit]"
	if(moo.digit != 0)
		playsound(holder, "sound/machines/creak.ogg", 100)
		return
	for(var/i in 1 to 9)
		playsound(holder, "sound/machines/creak.ogg", 100)
		sleep(0.15 SECONDS)

/datum/gizpulse/send_code/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	var/datum/gizmodes/moo/moo = astype(master)
	if(!moo?.crate)
		return
	var/obj/structure/closet/crate/secure/loot/lootbox = moo.crate
	var/input = moo.current_code.Join("")
	switch(lootbox.try_code(input))
		if(LOOT_CRATE_SUCCESS)
			for(var/atom/movable/item in lootbox)
				playsound(holder,"sound/machines/machinevend.ogg", 100)
				sleep(0.5 SECONDS)
				item.forceMove(get_turf(holder))
		if(LOOT_CRATE_CANCEL)
			playsound(holder, "sound/machines/terminal/terminal_error.ogg", 100)
		if(LOOT_CRATE_INCORRECT)
			// Grab last attempt from list
			var/outcome = lootbox.previous_attempts[11 - lootbox.attempts]
			holder.visible_message("[moo] emits [outcome["bulls"]] high-pitched beeps and [outcome["cows"]] low-pitched ones.")
			for(var/i in 1 to outcome["bulls"])
				sleep(0.5 SECONDS)
				playsound(holder, "sound/machines/synth/synth_yes.ogg", 100)
			sleep(0.5 SECONDS)
			for(var/i in 1 to outcome["cows"])
				sleep(0.5 SECONDS)
				playsound(holder, "sound/machines/synth/synth_no.ogg", 100)
		if(LOOT_CRATE_FAIL)
			playsound(holder, "sound/machines/slowclap.ogg", 150)
			var/obj/item/grenade/clusterbuster/syndieminibomb/payback = new(get_turf(moo))
			payback.arm_grenade(delayoverride = 0.2 SECONDS)
	// The abandoned crate demands for the inputs to be reset after the cracking attempt
	sleep(0.5 SECONDS)
	moo.current_code = list("0", "0", "0", "0")
	moo.position = initial(moo.position)
	moo.digit = initial(moo.digit)
	playsound(holder, "sound/machines/terminal_eject.ogg", 100)
