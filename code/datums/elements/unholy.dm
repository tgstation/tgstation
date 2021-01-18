/datum/element/unholy
	element_flags = ELEMENT_DETACH

/datum/element/unholy/Attach(datum/target)
	. = ..()
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE
	var/P
	if(iscarbon(target))
		P = .proc/burn_baby_burn

	RegisterSignal(target, COMSIG_MOVABLE_MOVED, P)

/datum/element/unholy/Detach(mob/living/carbon/target)
	. = ..()
	UnregisterSignal(target, COMSIG_MOVABLE_MOVED)


/datum/element/unholy/proc/burn_baby_burn(mob/living/carbon/target)
	SIGNAL_HANDLER
	var/mob/living/carbon/H = target
	for(var/mob/living/L in get_hearers_in_view(2, H))
		if(HAS_TRAIT(L, TRAIT_HOLY))
			if(prob(10))
				H.emote("cough")
			if(prob(75))
				H.visible_message("<span class='warning'>begins to seep blood!</span.?>", visible_message_flags = EMOTE_MESSAGE)
				H.bleed(rand(10, 40))
				H.adjustBruteLoss(2,0)
			else if(prob(75))
				H.visible_message("<span class='warning'>starts to emit a red steam.</span.?>", visible_message_flags = EMOTE_MESSAGE)
				H.adjustFireLoss(6, 0)
			else
				H.visible_message("<span class='warning'>bursts into darkened flames!</span.?>", visible_message_flags = EMOTE_MESSAGE)
				H.set_fire_stacks(min(5, H.fire_stacks + 3))
				H.IgniteMob()
	. = ..()

