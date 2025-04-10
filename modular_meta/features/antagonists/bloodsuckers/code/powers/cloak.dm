/datum/action/cooldown/bloodsucker/cloak
	name = "Cloak of Darkness"
	desc = "Blend into shadow and become invisible to the untrained and artificial eye."
	button_icon_state = "power_cloak"
	power_explanation = "Cloak of Darkness:\n\
		Activate this power and you will slowly become transparent.\n\
		While using Cloak of Darkness, attempting to run will crush you.\n\
		Additionally, while Cloak is active, you are completely invisible to AIs.\n\
		Higher levels will increase your transparency."
	power_flags = BP_AM_TOGGLE
	check_flags = BP_CANT_USE_IN_TORPOR|BP_CANT_USE_IN_FRENZY|BP_CANT_USE_WHILE_UNCONSCIOUS
	purchase_flags = BLOODSUCKER_CAN_BUY|VASSAL_CAN_BUY
	bloodcost = 5
	constant_bloodcost = 0.2
	cooldown_time = 5 SECONDS
	var/was_running

/// Must have nobody around to see the cloak
/datum/action/cooldown/bloodsucker/cloak/can_use(mob/living/carbon/user, trigger_flags)
	. = ..()
	if(!.)
		return FALSE
	for(var/mob/living/watchers in view(9, owner) - owner)
		owner.balloon_alert(owner, "you can only vanish unseen.")
		return FALSE
	return TRUE

/datum/action/cooldown/bloodsucker/cloak/ActivatePower(trigger_flags)
	. = ..()
	var/mob/living/user = owner
	was_running = (user.move_intent == MOVE_INTENT_RUN)
	if(was_running)
		user.toggle_move_intent()
	user.AddElement(/datum/element/digitalcamo)
	user.balloon_alert(user, "cloak turned on.")

/datum/action/cooldown/bloodsucker/cloak/process(seconds_per_tick)
	// Checks that we can keep using this.
	. = ..()
	if(!.)
		return
	if(!active)
		return
	var/mob/living/user = owner
	animate(user, alpha = max(25, owner.alpha - min(75, 10 + 5 * level_current)), time = 1.5 SECONDS)
	// Prevents running while on Cloak of Darkness
	if(user.move_intent != MOVE_INTENT_WALK)
		owner.balloon_alert(owner, "you attempt to run, crushing yourself.")
		user.toggle_move_intent()
		user.adjustBruteLoss(rand(5,15))

/datum/action/cooldown/bloodsucker/cloak/ContinueActive(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	/// Must be CONSCIOUS
	if(user.stat != CONSCIOUS)
		to_chat(owner, span_warning("Your cloak failed due to you falling unconcious!"))
		return FALSE
	return TRUE

/datum/action/cooldown/bloodsucker/cloak/DeactivatePower()
	var/mob/living/user = owner
	animate(user, alpha = 255, time = 1 SECONDS)
	user.RemoveElement(/datum/element/digitalcamo)
	if(was_running && user.move_intent == MOVE_INTENT_WALK)
		user.toggle_move_intent()
	user.balloon_alert(user, "cloak turned off.")
	return ..()
