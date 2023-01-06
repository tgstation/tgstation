
/mob/living/silicon/pai/blob_act(obj/structure/blob/B)
	return FALSE

/mob/living/silicon/pai/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	take_holo_damage(50 / severity)
	Stun(400 / severity)
	if(holoform)
		fold_in(force = TRUE)
	//Need more effects that aren't instadeath or permanent law corruption.
	//Ask and you shall receive
	switch(rand(1, 3))
		if(1)
			adjust_stutter(1 MINUTES / severity)
			to_chat(src, span_danger("Warning: Feedback loop detected in speech module."))
		if(2)
			adjust_slurring(INFINITY)
			to_chat(src, span_danger("Warning: Audio synthesizer CPU stuck."))
		if(3)
			set_derpspeech(INFINITY)
			to_chat(src, span_danger("Warning: Vocabulary databank corrupted."))
	if(prob(40))
		mind.language_holder.selected_language = get_random_spoken_language()


/mob/living/silicon/pai/ex_act(severity, target)
	take_holo_damage(50 * severity)
	switch(severity)
		if(EXPLODE_DEVASTATE) //RIP
			qdel(card)
			qdel(src)
		if(EXPLODE_HEAVY)
			fold_in(force = 1)
			Paralyze(400)
		if(EXPLODE_LIGHT)
			fold_in(force = 1)
			Paralyze(200)

/mob/living/silicon/pai/attack_hand(mob/living/carbon/human/user, list/modifiers)
	if(!user.combat_mode)
		visible_message(span_notice("[user] gently pats [src] on the head, eliciting an off-putting buzzing from its holographic field."))
		return
	user.do_attack_animation(src)
	if(user.name != master_name)
		visible_message(span_danger("[user] stomps on [src]!."))
		take_holo_damage(2)
		return
	visible_message(span_notice("Responding to its master's touch, [src] disengages its holochassis emitter, rapidly losing coherence."))
	if(!do_after(user, 1 SECONDS, src))
		return
	fold_in()
	if(user.put_in_hands(card))
		user.visible_message(span_notice("[user] promptly scoops up [user.p_their()] pAI's card."))

/mob/living/silicon/pai/bullet_act(obj/projectile/Proj)
	if(Proj.stun)
		fold_in(force = TRUE)
		src.visible_message(span_warning("The electrically-charged projectile disrupts [src]'s holomatrix, forcing [src] to fold in!"))
	. = ..(Proj)

/mob/living/silicon/pai/ignite_mob()
	return FALSE

/mob/living/silicon/pai/proc/take_holo_damage(amount)
	holochassis_health = clamp((holochassis_health - amount), -50, HOLOCHASSIS_MAX_HEALTH)
	if(holochassis_health < 0)
		fold_in(force = TRUE)
	if(amount > 0)
		to_chat(src, span_userdanger("The impact degrades your holochassis!"))
	return amount

/mob/living/silicon/pai/adjustBruteLoss(amount, updating_health = TRUE, forced = FALSE, required_bodytype)
	return take_holo_damage(amount)

/mob/living/silicon/pai/adjustFireLoss(amount, updating_health = TRUE, forced = FALSE, required_bodytype)
	return take_holo_damage(amount)

/mob/living/silicon/pai/adjustStaminaLoss(amount, updating_stamina, forced = FALSE, required_biotype)
	if(forced)
		take_holo_damage(amount)
	else
		take_holo_damage(amount * 0.25)

/mob/living/silicon/pai/getBruteLoss()
	return HOLOCHASSIS_MAX_HEALTH - holochassis_health

/mob/living/silicon/pai/getFireLoss()
	return HOLOCHASSIS_MAX_HEALTH - holochassis_health
