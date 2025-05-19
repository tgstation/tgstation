/datum/action/innate/cult/master/cultmark
	name = "Mark Target"
	desc = "Marks a target for the cult."
	button_icon_state = "cult_mark"
	click_action = TRUE
	enable_text = span_cult("You prepare to mark a target for your cult. <b>Click a target to mark them!</b>")
	disable_text = span_cult("You cease the marking ritual.")
	/// The duration of the mark itself
	var/cult_mark_duration = 90 SECONDS
	/// The duration of the cooldown for cult marks
	var/cult_mark_cooldown_duration = 2 MINUTES
	/// The actual cooldown tracked of the action
	COOLDOWN_DECLARE(cult_mark_cooldown)

/datum/action/innate/cult/master/cultmark/IsAvailable(feedback = FALSE)
	return ..() && COOLDOWN_FINISHED(src, cult_mark_cooldown)

/datum/action/innate/cult/master/cultmark/InterceptClickOn(mob/clicker, params, atom/clicked_on)
	var/turf/clicker_turf = get_turf(clicker)
	if(!isturf(clicker_turf))
		return FALSE

	if(!(clicked_on in view(7, clicker_turf)))
		return FALSE

	return ..()

/datum/action/innate/cult/master/cultmark/do_ability(mob/living/clicker, atom/clicked_on)
	var/datum/antagonist/cult/cultist = clicker.mind.has_antag_datum(/datum/antagonist/cult, TRUE)
	if(!cultist)
		CRASH("[type] was casted by someone without a cult antag datum.")

	var/datum/team/cult/cult_team = cultist.get_team()
	if(!cult_team)
		CRASH("[type] was casted by a cultist without a cult team datum.")

	if(cult_team.blood_target)
		to_chat(clicker, span_cult("The cult has already designated a target!"))
		return FALSE

	if(cult_team.set_blood_target(clicked_on, clicker, cult_mark_duration))
		unset_ranged_ability(clicker, span_cult("The marking rite is complete! It will last for [DisplayTimeText(cult_mark_duration)] seconds."))
		COOLDOWN_START(src, cult_mark_cooldown, cult_mark_cooldown_duration)
		build_all_button_icons()
		addtimer(CALLBACK(src, PROC_REF(build_all_button_icons)), cult_mark_cooldown_duration + 1)
		return TRUE

	unset_ranged_ability(clicker, span_cult("The marking rite failed!"))
	return TRUE

/datum/action/innate/cult/ghostmark //Ghost version
	name = "Blood Mark your Target"
	desc = "Marks whatever you are orbiting for the entire cult to track."
	button_icon_state = "cult_mark"
	check_flags = NONE
	/// The duration of the mark on the target
	var/cult_mark_duration = 60 SECONDS
	/// The cooldown between marks - the ability can be used in between cooldowns, but can't mark (only clear)
	var/cult_mark_cooldown_duration = 60 SECONDS
	/// The actual cooldown tracked of the action
	COOLDOWN_DECLARE(cult_mark_cooldown)

/datum/action/innate/cult/ghostmark/IsAvailable(feedback = FALSE)
	return ..() && isobserver(owner)

/datum/action/innate/cult/ghostmark/Activate()
	var/datum/antagonist/cult/cultist = owner.mind?.has_antag_datum(/datum/antagonist/cult, TRUE)
	if(!cultist)
		CRASH("[type] was casted by someone without a cult antag datum.")

	var/datum/team/cult/cult_team = cultist.get_team()
	if(!cult_team)
		CRASH("[type] was casted by a cultist without a cult team datum.")

	if(cult_team.blood_target)
		if(!COOLDOWN_FINISHED(src, cult_mark_cooldown))
			cult_team.unset_blood_target_and_timer()
			to_chat(owner, span_cult_bold("You have cleared the cult's blood target!"))
			return TRUE

		to_chat(owner, span_cult_bold("The cult has already designated a target!"))
		return FALSE

	if(!COOLDOWN_FINISHED(src, cult_mark_cooldown))
		to_chat(owner, span_cult_bold("You aren't ready to place another blood mark yet!"))
		return FALSE

	var/atom/mark_target = owner.orbiting?.parent || get_turf(owner)
	if(!mark_target)
		return FALSE

	if(cult_team.set_blood_target(mark_target, owner, 60 SECONDS))
		to_chat(owner, span_cult_bold("You have marked [mark_target] for the cult! It will last for [DisplayTimeText(cult_mark_duration)]."))
		COOLDOWN_START(src, cult_mark_cooldown, cult_mark_cooldown_duration)
		build_all_button_icons(UPDATE_BUTTON_NAME|UPDATE_BUTTON_ICON)
		addtimer(CALLBACK(src, PROC_REF(reset_button)), cult_mark_cooldown_duration + 1)
		return TRUE

	to_chat(owner, span_cult("The marking failed!"))
	return FALSE

/datum/action/innate/cult/ghostmark/update_button_name(atom/movable/screen/movable/action_button/current_button, force = FALSE)
	if(COOLDOWN_FINISHED(src, cult_mark_duration))
		name = initial(name)
		desc = initial(desc)
	else
		name = "Clear the Blood Mark"
		desc = "Remove the Blood Mark you previously set."

	return ..()

/datum/action/innate/cult/ghostmark/apply_button_icon(atom/movable/screen/movable/action_button/current_button, force = FALSE)
	if(COOLDOWN_FINISHED(src, cult_mark_duration))
		button_icon_state = initial(button_icon_state)
	else
		button_icon_state = "emp"

	return ..()

/datum/action/innate/cult/ghostmark/proc/reset_button()
	if(QDELETED(owner) || QDELETED(src))
		return

	SEND_SOUND(owner, 'sound/effects/magic/enter_blood.ogg')
	to_chat(owner, span_cult_bold("Your previous mark is gone - you are now ready to create a new blood mark."))
	build_all_button_icons(UPDATE_BUTTON_NAME|UPDATE_BUTTON_ICON)
