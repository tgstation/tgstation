#define DEFAULT_MAX_CURSE_COUNT 5

/// Status effect that gives the target miscellanous debuffs while throwing a status alert and causing them to smoke from the damage they're incurring.
/// Purposebuilt for cursed slot machines.
/datum/status_effect/grouped/cursed
	id = "cursed"
	alert_type = /atom/movable/screen/alert/status_effect/cursed
	/// The max number of curses a target can incur with this status effect.
	var/max_curse_count = DEFAULT_MAX_CURSE_COUNT
	/// The amount of times we have been "applied" to the target.
	var/curse_count = 0
	/// Raw probability we have to deal damage this tick.
	var/damage_chance = 10
	/// The hand we are branded to.
	var/obj/item/bodypart/branded_hand = null

/datum/status_effect/grouped/cursed/on_apply()
	RegisterSignal(owner, COMSIG_CURSED_SLOT_MACHINE_USE, PROC_REF(check_curses))
	RegisterSignal(owner, COMSIG_CURSED_SLOT_MACHINE_LOST, PROC_REF(update_curse_count))
	RegisterSignal(SSdcs, COMSIG_GLOB_CURSED_SLOT_MACHINE_WON, PROC_REF(clear_curses))
	return ..()

/datum/status_effect/grouped/cursed/Destroy()
	UnregisterSignal(owner, list(COMSIG_CURSED_SLOT_MACHINE_USE, COMSIG_CURSED_SLOT_MACHINE_LOST))
	UnregisterSignal(SSdcs, COMSIG_GLOB_CURSED_SLOT_MACHINE_WON)
	branded_hand = null
	return ..()

/// Checks the number of curses we have and returns information back to the slot machine.
/datum/status_effect/grouped/cursed/proc/check_curses()
	SIGNAL_HANDLER
	if(curse_count < max_curse_count)
		return

	return SLOT_MACHINE_USE_CANCEL

/// Handles the debuffs of this status effect and incrementing the number of curses we have.
/datum/status_effect/grouped/cursed/proc/update_curse_count()
	SIGNAL_HANDLER
	curse_count++

	if(!isnull(linked_alert))
		linked_alert.update_description()

	update_particles()
	addtimer(CALLBACK(src, PROC_REF(handle_after_effects), 1 SECONDS)) // give it a second to let the failure sink in before we exact our toll

/// Makes a nice lorey message about the curse level we're at. I think it's nice
/datum/status_effect/grouped/cursed/proc/handle_after_effects()
	if(QDELETED(src))
		return

	var/list/messages = list()
	switch(curse_count)
		if(1) // basically your first is a "freebie" that will still require urgent medical attention and will leave you smoking forever but could be worse tbh
			if(ishuman(owner))
				var/mob/living/carbon/human/human_owner = owner
				playsound(human_owner, SFX_SEAR, 50, TRUE)
				var/obj/item/bodypart/affecting = human_owner.get_active_hand()
				branded_hand = affecting
				affecting.force_wound_upwards(/datum/wound/burn/severe/cursed_brand, wound_source = "curse of the slot machine")
				affecting.receive_damage(burn = 20)

			messages += span_boldwarning("Your hand burns, and you quickly let go of the lever! You feel a little sick as the nerves deaden in your hand...")
			messages += span_boldwarning("Some smoke appears to be coming out of your hand now, but it's not too bad...")
			messages += span_boldwarning("Fucking stupid machine.")

		if(2)
			messages += span_boldwarning("The machine didn't burn you this time, it must be some arcane work of the brand recognizing a source...")
			messages += span_boldwarning("Blisters and boils start to appear over your skin. Each one hissing searing hot steam out of its own pocket...")
			messages += span_boldwarning("You understand that the machine tortures you with its simplistic allure. It can kill you at any moment, but it derives a sick satisfaction at forcing you to keep going.")
			messages += span_boldwarning("If you could get away from here, you might be able to live with some medical supplies. Is it too late to stop now?")

		if(3)
			owner.emote("cough")
			messages += span_boldwarning("Your throat becomes to feel like it's slowly caking up with sand and dust. You eject the contents of the back of your throat onto your good hand.")
			messages += span_boldwarning("It is sand. Crimson red. You've never felt so thirsty in your life, yet you don't trust your own hand to carry the glass to your lips.")
			messages += span_boldwarning("You get the sneaking feeling that if someone else were to win, that it might clear your curse too. Saving your life is a noble cause.")
			messages += span_boldwarning("Of course, you might have to not speak on the nature of this machine, in case they scamper off to leave you to die.")
			messages += span_boldwarning("Is it truly worth it to condemn someone to this fate to cure the manifestation of your own hedonistic urges? You'll have to decide quickly.")

		if(4)
			messages += span_boldwarning("A migraine swells over your head as your thoughts become hazy. Your hand desperately inches closer towards the slot machine for one final pull...")
			messages += span_boldwarning("The ultimate test of mind over matter. You can jerk your own muscle back in order to prevent a terrible fate, but your life already is worth so little now.")
			messages += span_boldwarning("This is what they want, is it not? To witness your failure against itself? The compulsion carries you forward as a sinking feeling of dread fills your stomach.")
			messages += span_boldwarning("Paradoxically, where there is hopelessness, there is elation. Elation at the fact that there's still enough power in you for one more pull.")
			messages += span_boldwarning("Your legs desperate wish to jolt away on the thought of running away from this wretched machination, but your own arm remains complacent in the thought of seeing spinning wheels.")
			messages += span_userdanger("The toll has already been exacted. There is no longer death on 'your' terms. Is your dignity worth more than your life?")

		if(5 to INFINITY)
			if(max_curse_count != DEFAULT_MAX_CURSE_COUNT) // this probably will only happen through admin schenanigans letting people stack up infinite curses or something
				to_chat(owner, span_boldwarning("Do you <i>still</i> think you're in control?"))
				return

			to_chat(owner, span_userdanger("Why couldn't I get one more try?!"))
			owner.investigate_log("has been gibbed by the cursed status effect after accumulating [curse_count] curses.", INVESTIGATE_DEATHS)
			owner.gib()
			qdel(src)
			return

	for(var/message in messages)
		to_chat(owner, message)
		sleep(1.5 SECONDS) // yes yes a bit fast but it can be a lot of text and i want the whole thing to send before the cooldown on the slot machine might expire

/// Cleans ourselves up and removes our curses. Meant to be done in a "positive" way, when the curse is broken. Directly use qdel otherwise.
/datum/status_effect/grouped/cursed/proc/clear_curses()
	SIGNAL_HANDLER

	if(!isnull(branded_hand))
		var/datum/wound/brand = branded_hand.get_wound_type(/datum/wound/burn/severe/cursed_brand)
		brand.remove_wound()

	owner.visible_message(
		span_notice("The smoke slowly clears from [owner.name]..."),
		span_notice("Your skin finally settles down and your throat no longer feels as dry... The brand disappearing confirms that the curse has been lifted."),
	)
	QDEL_NULL(particle_effect)
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
	if(curse_count <= 1)
		return // you get one "freebie" (single damage) to nudge you into thinking this is a bad idea before the house begins to win.

	// the house won.
	var/ticked_coefficient = rand(0.15, 0.40)
	var/effective_percentile_chance = ((curse_count == 2 ? 1 : curse_count) * damage_chance * ticked_coefficient)

	if(SPT_PROB(effective_percentile_chance, seconds_between_ticks))
		owner.apply_damages(
			brute = (curse_count * ticked_coefficient),
			burn = (curse_count * ticked_coefficient),
			oxy = (curse_count * ticked_coefficient),
		)

/atom/movable/screen/alert/status_effect/cursed
	name = "Cursed!"
	desc = "The brand on your hand reminds you of your greed, yet you seem to be okay otherwise."

/atom/movable/screen/alert/status_effect/update_description()
	var/datum/status_effect/grouped/cursed/linked_effect = attached_effect
	var/curses = linked_effect.curse_count
	switch(curses)
		if(2)
			desc = "Your greed is catching up to you..."
		if(3)
			desc = "You really don't feel good right now... But why stop now?"
		if(4 to INFINITY)
			desc = "Real winners quit before they reach the ultimate prize."

#undef DEFAULT_MAX_CURSE_COUNT
