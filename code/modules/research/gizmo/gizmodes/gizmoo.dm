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
	holder.say("make_crate")
	var/datum/gizmodes/moo/moo = astype(master)
	if(!moo)
		playsound(holder, "sound/machines/nuke/angry_beep.ogg", 50)
		return

	if(moo.crates_generated == moo.max_crates)
		playsound(holder, "sound/machines/nuke/angry_beep.ogg", 50)
		return
	QDEL_NULL(moo.crate)
	moo.crate = new(holder)
	moo.crates_generated++
	playsound(holder, "sound/mobs/non-humanoids/cow/cow.ogg", 50)

// Cycle selected position
/datum/gizpulse/cycle_position/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	holder.say("cycle_position")
	var/datum/gizmodes/moo/moo = astype(master)
	if(!moo)
		return
	moo.position = (moo.position + 1) % 4
	playsound(holder, "sound/machines/eject.ogg", 50)

// Cycle selected digit
/datum/gizpulse/cycle_digit/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	holder.say("cycle_digit")
	var/datum/gizmodes/moo/moo = astype(master)
	if(!moo)
		return
	moo.digit = (moo.digit + 1) % 10
	moo.current_code[moo.position + 1] = "[moo.digit]"
	playsound(holder, "sound/machines/creak.ogg", 50)

/datum/gizpulse/send_code/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	holder.say("send_code")
	var/datum/gizmodes/moo/moo = astype(master)
	if(!moo)
		return
	if(!moo.crate)
		return
	var/obj/structure/closet/crate/secure/loot/lootbox = moo.crate
	var/input = moo.current_code.Join("")
	switch(lootbox.try_code(input))
		if(LOOT_CRATE_SUCCESS)
			for(var/atom/movable/item in lootbox)
				playsound(holder,"sound/machines/machinevend.ogg", 50)
				item.forceMove(get_turf(holder))
				sleep(0.5 SECONDS)
		if(LOOT_CRATE_CANCEL)
			playsound(holder, "sound/machines/terminal/terminal_error.ogg", 50)
		if(LOOT_CRATE_INCORRECT)
			// Grab last attempt from list
			var/outcome = lootbox.previous_attempts[lootbox.attempts]
			holder.visible_message("[moo] emits [outcome["bulls"]] high-pitched beeps and [outcome["cows"]] low-pitched ones.")
			for(1 to outcome["bulls"])
				sleep(0.5 SECONDS)
				playsound(holder, "sound/machines/synth/synth_yes.ogg", 50)
			sleep(0.5 SECONDS)
			for(1 to outcome["cows"])
				sleep(0.5 SECONDS)
				playsound(holder, "sound/machines/synth/synth_no.ogg", 50)
		if(LOOT_CRATE_FAIL)
			playsound(holder, "sound/machines/slowclap.ogg", 50)
			var/obj/item/grenade/clusterbuster/syndieminibomb/payback = new(get_turf(moo))
			payback.arm_grenade(delayoverride = 0.2 SECONDS)

