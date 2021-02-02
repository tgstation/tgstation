//Because elements/unholy.dm only made it so they combust when the unholy person moved
/datum/element/holy_light
	element_flags = ELEMENT_DETACH

/datum/element/holy_light/Attach(datum/target)
	. = ..()
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE
	var/P
	if(iscarbon(target))
		P = .proc/divine_light

	RegisterSignal(target, COMSIG_MOVABLE_MOVED, P)

/datum/element/holy_light/Detach(mob/living/carbon/target)
	. = ..()
	UnregisterSignal(target, COMSIG_MOVABLE_MOVED)


/datum/element/holy_light/proc/divine_light(mob/living/carbon/target)
	SIGNAL_HANDLER

	for(var/mob/living/carbon/L in get_hearers_in_view(2, target))
		if(HAS_TRAIT(L, TRAIT_UNHOLY))
			if(prob(10))
				L.emote("cough")
			if(prob(75))
				L.visible_message("<span class='warning'>begins to seep blood!</span.?>", visible_message_flags = EMOTE_MESSAGE)
				L.bleed(rand(10, 40))
				L.adjustBruteLoss(2,0)
			else if(prob(75))
				L.visible_message("<span class='warning'>starts to emit a red steam.</span.?>", visible_message_flags = EMOTE_MESSAGE)
				L.adjustFireLoss(6, 0)
			else
				L.visible_message("<span class='warning'>bursts into darkened flames!</span.?>", visible_message_flags = EMOTE_MESSAGE)
				L.set_fire_stacks(min(5, L.fire_stacks + 3))
				L.IgniteMob()
	. = ..()

