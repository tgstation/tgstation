/datum/action/cooldown/bloodsucker/cloak
	name = "Плащ Тьмы"
	desc = "Сливайтесь с тенью и становитесь невидимыми для неподготовленного и глаз синтетического интелекта."
	button_icon_state = "power_cloak"
	power_explanation = "Плащ тьмы:\n\
		Активируйте эту способность, и вы постепенно станете прозрачными.\n\
		При использовании Плаща Тьмы попытка бежать свалит вас с ног.\n\
		Кроме того, пока 'Маскировка' активна, вы полностью невидимы для ИИ.\n\
		Большие уровни делают вас более прозрачным."
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
		owner.balloon_alert(owner, "ты можешь только исчезнуть только тогда, когда тебя не видят.")
		return FALSE
	return TRUE

/datum/action/cooldown/bloodsucker/cloak/ActivatePower(trigger_flags)
	. = ..()
	var/mob/living/user = owner
	was_running = (user.move_intent == MOVE_INTENT_RUN)
	if(was_running)
		user.toggle_move_intent()
	user.AddElement(/datum/element/digitalcamo)
	user.balloon_alert(user, "плащ активирован.")

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
		owner.balloon_alert(owner, "ты пытаешься бежать, сбивая себя с ног.")
		user.toggle_move_intent()
		user.adjustBruteLoss(rand(5,15))

/datum/action/cooldown/bloodsucker/cloak/ContinueActive(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	/// Must be CONSCIOUS
	if(user.stat != CONSCIOUS)
		to_chat(owner, span_warning("Твой плащ деактивирован из-за того, что ты потерял сознание!"))
		return FALSE
	return TRUE

/datum/action/cooldown/bloodsucker/cloak/DeactivatePower()
	var/mob/living/user = owner
	animate(user, alpha = 255, time = 1 SECONDS)
	user.RemoveElement(/datum/element/digitalcamo)
	if(was_running && user.move_intent == MOVE_INTENT_WALK)
		user.toggle_move_intent()
	user.balloon_alert(user, "плащ отключён.")
	return ..()
