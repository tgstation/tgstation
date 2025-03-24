/datum/wires/syndicatebomb
	holder_type = /obj/machinery/syndicatebomb
	proper_name = "Syndicate Explosive Device"
	randomize = TRUE

/datum/wires/syndicatebomb/New(atom/holder)
	setup_wires()
	return ..()

/**
 * Handles setting up the wires list.
 *
 * * num_booms: The number of boom wires to add.
 * * num_duds: The number of dud wires to add.
 */
/datum/wires/syndicatebomb/proc/setup_wires(num_booms = 2, num_duds = 0)
	wires = list(
		WIRE_ACTIVATE,
		WIRE_DELAY,
		WIRE_PROCEED,
		WIRE_UNBOLT,
	)
	add_booms(num_booms)
	add_duds(num_duds)
	shuffle_wires()

/// Adds a number of wires which will explode the bomb if pulse/cut
/datum/wires/syndicatebomb/proc/add_booms(booms = 2)
	for(var/i in 1 to booms)
		wires += "[WIRE_BOOM] [i]"

/datum/wires/syndicatebomb/interactable(mob/user)
	var/obj/machinery/syndicatebomb/bomb = holder
	return ..() && bomb.open_panel

/// Translates numbered boom wires into WIRE_BOOM.
/datum/wires/syndicatebomb/proc/parse_wire(wire)
	return findtext(wire, WIRE_BOOM) ? WIRE_BOOM : wire

/// Checks if the bomb, if detonated, is dangerous to the user.
/datum/wires/syndicatebomb/proc/is_dangerous()
	var/obj/machinery/syndicatebomb/bomb = holder
	if(isnull(bomb.payload))
		return FALSE
	if(istype(bomb.payload, /obj/item/bombcore/training))
		return FALSE
	return TRUE

/datum/wires/syndicatebomb/on_pulse(wire, mob/user)
	var/obj/machinery/syndicatebomb/bomb = holder
	switch(parse_wire(wire))
		if(WIRE_BOOM)
			if(!bomb.active)
				holder.visible_message(span_notice("[icon2html(bomb, viewers(holder))] Nothing happens."))
				return

			holder.visible_message(span_danger("[icon2html(bomb, viewers(holder))] An alarm sounds! It's go-"))
			bomb.explode_now = TRUE
			if(is_dangerous())
				tell_admins(bomb, user, "detonated via boom wire")
				if(isliving(user))
					add_memory_in_range(bomb, 7, /datum/memory/bomb_defuse_failure, protagonist = user, antagonist = bomb)

		if(WIRE_UNBOLT)
			holder.visible_message(span_notice("[icon2html(bomb, viewers(holder))] The bolts spin in place for a moment."))

		if(WIRE_DELAY)
			if(bomb.delayedbig)
				holder.visible_message(span_notice("[icon2html(bomb, viewers(holder))] Nothing happens."))
				return

			holder.visible_message(span_notice("[icon2html(bomb, viewers(holder))] The bomb chirps."))
			playsound(bomb, 'sound/machines/chime.ogg', 30, TRUE)
			bomb.detonation_timer += (30 SECONDS)
			if(bomb.active)
				bomb.delayedbig = TRUE

		if(WIRE_PROCEED)
			holder.visible_message(span_danger("[icon2html(bomb, viewers(holder))] The bomb buzzes ominously!"))
			playsound(bomb, 'sound/machines/buzz/buzz-sigh.ogg', 30, TRUE)
			var/seconds = bomb.seconds_remaining()
			if(seconds >= 61) // Long fuse bombs can suddenly become more dangerous if you tinker with them.
				bomb.detonation_timer = world.time + (60 SECONDS)
			else if(seconds >= 21)
				bomb.detonation_timer -= (10 SECONDS)
			else if(seconds >= 11) // Both to prevent negative timers and to have a little mercy.
				bomb.detonation_timer = world.time + (10 SECONDS)

		if(WIRE_ACTIVATE)
			if(!bomb.active)
				holder.visible_message(span_danger("[icon2html(bomb, viewers(holder))] You hear the bomb start ticking!"))
				bomb.activate()
				bomb.update_appearance()
			else if(bomb.delayedlittle)
				holder.visible_message(span_notice("[icon2html(bomb, viewers(holder))] Nothing happens."))
			else
				holder.visible_message(span_notice("[icon2html(bomb, viewers(holder))] The bomb seems to hesitate for a moment."))
				bomb.detonation_timer += 100
				bomb.delayedlittle = TRUE

/datum/wires/syndicatebomb/on_cut(wire, mend, source)
	var/obj/machinery/syndicatebomb/bomb = holder
	switch(parse_wire(wire))
		if(WIRE_BOOM)
			if(mend || !bomb.active)
				return
			holder.visible_message(span_danger("[icon2html(bomb, viewers(holder))] An alarm sounds! It's go-"))
			bomb.explode_now = TRUE
			if(is_dangerous())
				tell_admins(bomb, source, "detonated via boom wire")
				if(isliving(source))
					add_memory_in_range(bomb, 7, /datum/memory/bomb_defuse_failure, protagonist = source, antagonist = bomb)

		if(WIRE_UNBOLT)
			if(mend || !bomb.anchored)
				return
			holder.visible_message(span_notice("[icon2html(bomb, viewers(holder))] The bolts lift out of the ground!"))
			playsound(bomb, 'sound/effects/stealthoff.ogg', 30, TRUE)
			bomb.set_anchored(FALSE)

		if(WIRE_PROCEED)
			if(mend || !bomb.active)
				return
			holder.visible_message(span_danger("[icon2html(bomb, viewers(holder))] The digital display on the device deactivates."))
			bomb.examinable_countdown = FALSE

		if(WIRE_ACTIVATE)
			if(mend || !bomb.active)
				return
			var/bomb_time_left = bomb.seconds_remaining()
			holder.visible_message(span_notice("[icon2html(bomb, viewers(holder))] The timer stops! The bomb has been defused!"))
			bomb.defuse()
			if(is_dangerous())
				tell_admins(bomb, source, "defused")
				if(isliving(source))
					add_memory_in_range(bomb, 7, /datum/memory/bomb_defuse_success, protagonist = source, antagonist = bomb, bomb_time_left = bomb_time_left)

/datum/wires/syndicatebomb/proc/tell_admins(obj/machinery/syndicatebomb/bomb, atom/source, what_happened)
	var/turf/bombloc = get_turf(bomb)
	log_game("\A [bomb] was [what_happened] at [AREACOORD(bombloc)] by [source || "nothing(?)"].")
	message_admins("\A [bomb] was [what_happened] at [ADMIN_VERBOSEJMP(bombloc)] by [source ? ADMIN_LOOKUPFLW(source) : "nothing(?)"].")
	if(isliving(source))
		log_combat(source, bomb, what_happened)
