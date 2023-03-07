/datum/action/bloodsucker/cloak
	name = "Cloak of Darkness"
	desc = "Blend into the shadows and become invisible to the untrained and Artificial eye."
	button_icon_state = "power_cloak"
	power_explanation = "Cloak of Darkness:\n\
		Activate this Power in the shadows and you will slowly turn nearly invisible.\n\
		While using Cloak of Darkness, attempting to run will crush you.\n\
		Additionally, while Cloak is active, you are completely invisible to the AI.\n\
		Higher levels will increase how invisible you are."
	power_flags = BP_AM_TOGGLE
	check_flags = BP_CANT_USE_IN_TORPOR|BP_CANT_USE_IN_FRENZY|BP_CANT_USE_WHILE_UNCONSCIOUS
	purchase_flags = BLOODSUCKER_CAN_BUY|VASSAL_CAN_BUY
	bloodcost = 5
	constant_bloodcost = 0.2
	cooldown = 5 SECONDS
	var/was_running

/// Must have nobody around to see the cloak
/datum/action/bloodsucker/cloak/CheckCanUse(mob/living/carbon/user, trigger_flags)
	. = ..()
	if(!.)
		return FALSE
	for(var/mob/living/watchers in view(9, owner) - owner)
		owner.balloon_alert(owner, "you can only vanish unseen.")
		return FALSE
	return TRUE

/datum/action/bloodsucker/cloak/ActivatePower(trigger_flags)
	. = ..()
	var/mob/living/user = owner
	was_running = (user.m_intent == MOVE_INTENT_RUN)
	if(was_running)
		user.toggle_move_intent()
	user.AddElement(/datum/element/digitalcamo)
	user.balloon_alert(user, "cloak turned on.")

/datum/action/bloodsucker/cloak/process(delta_time)
	// Checks that we can keep using this.
	. = ..()
	if(!.)
		return
	var/mob/living/user = owner
	animate(user, alpha = max(25, owner.alpha - min(75, 10 + 5 * level_current)), time = 1.5 SECONDS)
	// Prevents running while on Cloak of Darkness
	if(user.m_intent != MOVE_INTENT_WALK)
		owner.balloon_alert(owner, "you attempt to run, crushing yourself.")
		user.toggle_move_intent()
		user.adjustBruteLoss(rand(5,15))

/datum/action/bloodsucker/cloak/ContinueActive(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	/// Must be CONSCIOUS
	if(user.stat != CONSCIOUS)
		to_chat(owner, span_warning("Your cloak failed due to you falling unconcious!"))
		return FALSE
	return TRUE

/datum/action/bloodsucker/cloak/DeactivatePower()
	var/mob/living/user = owner
	animate(user, alpha = 255, time = 1 SECONDS)
	user.RemoveElement(/datum/element/digitalcamo)
	if(was_running && user.m_intent == MOVE_INTENT_WALK)
		user.toggle_move_intent()
	user.balloon_alert(user, "cloak turned off.")
	return ..()
