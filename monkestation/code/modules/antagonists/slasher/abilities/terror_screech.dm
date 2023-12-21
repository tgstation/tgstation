/datum/action/cooldown/slasher/terror
	name = "Screech of Terror"
	desc = "Inflict near paralyzing fear to those around you."
	button_icon_state = "stagger_group"

	cooldown_time = 45 SECONDS


/datum/action/cooldown/slasher/terror/Activate(atom/target)
	. = ..()
	var/datum/antagonist/slasher/slasherdatum = owner.mind.has_antag_datum(/datum/antagonist/slasher)

	if(!slasherdatum)
		to_chat(owner, span_warning("You should not have this ability or your slasher antagonist datum was deleted, please contact coders"))
		return

	if(!slasherdatum.corporeal) // if he is incorporeal, dont stun people
		playsound(owner, 'monkestation/sound/voice/terror.ogg', 20, falloff_exponent = 0, use_reverb = FALSE)
		for(var/mob/living/carbon/human/human in view(7, owner))
			if(human == owner)
				continue
			to_chat(human, span_warning("You hear a distant screech... this cant possibly be good"))
			human.Shake(duration = 1 SECONDS)
		return

	playsound(owner, 'monkestation/sound/voice/terror.ogg', 100, falloff_exponent = 0, use_reverb = FALSE)
	for(var/mob/living/carbon/human/human in view(7, owner))
		if(human == owner)
			continue
		human.overlay_fullscreen("terror", /atom/movable/screen/fullscreen/curse, 1)
		human.Shake(duration = 5 SECONDS)
		human.stamina.adjust(-60)
		human.emote("scream")
		human.SetParalyzed(1.5 SECONDS)
		addtimer(CALLBACK(src, PROC_REF(remove_overlay), human), 5 SECONDS)

/datum/action/cooldown/slasher/terror/proc/remove_overlay(mob/living/carbon/human/remover)
	remover.clear_fullscreen("terror", 10)
