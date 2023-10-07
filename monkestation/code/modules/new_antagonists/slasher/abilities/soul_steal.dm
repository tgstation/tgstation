/mob/living/carbon/human
	/// Has our soul been sucked, this makes us pale white.
	var/soul_sucked = FALSE
	///sucked precent
	var/sucked_precent = 0

/datum/action/cooldown/slasher/soul_steal
	name = "Soul Steal"
	desc = " Use on a corpse who has a full soul to steal theirs. Stealing a soul gives your current machete an extra 2.5 BRUTE on hit, and on throw."

	button_icon_state = "soul_steal"

	click_to_activate = TRUE

	cooldown_time = 15 SECONDS

/datum/action/cooldown/slasher/soul_steal/PreActivate(atom/target)
	. = ..()
	if(!ishuman(target))
		to_chat(owner, span_warning("This is only usable on humans."))
		return
	var/mob/living/carbon/human/human_target = target
	if(human_target.stat != DEAD)
		to_chat(owner, span_notice("This target is not dead. You can't steal their soul."))
		return
	if(human_target.soul_sucked)
		to_chat(owner, span_warning("Their soul has already been sucked."))
		return
	if(!human_target.mind)
		to_chat(owner, span_warning("This target doesn't seem to have a soul to suck."))
		return

/datum/action/cooldown/slasher/soul_steal/Activate(atom/target)
	. = ..()
	if(!ishuman(target))
		return
	var/mob/living/carbon/human/human_owner = owner
	var/mob/living/carbon/human/human_target = target
	while(do_after(owner, 1 SECONDS, target) && !human_target.soul_sucked)
		human_target.sucked_precent += 20
		if(human_target.sucked_precent >= 100)
			human_target.soul_sucked = TRUE
			if(human_target.dna.species.use_skintones)
				human_target.skin_tone = "albino"
				human_target.dna.update_ui_block(DNA_SKIN_TONE_BLOCK)
			else
				human_target.dna.features["mcolor"] = "#FFFFFF"
				human_target.dna.update_uf_block(DNA_MUTANT_COLOR_BLOCK)

			human_target.update_body(is_creating = TRUE)

			var/datum/antagonist/slasher/slasherdatum = human_owner.mind.has_antag_datum(/datum/antagonist/slasher)
			if(!slasherdatum)
				return
			slasherdatum.linked_machette.force += 2.5
			slasherdatum.linked_machette.throwforce += 2.5
