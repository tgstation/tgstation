/mob/living/carbon/human
	/// Has our soul been sucked, this makes us pale white.
	var/soul_sucked = FALSE

/datum/action/cooldown/slasher/soul_steal
	name = "Soul Steal"
	desc = "You can use this ability to suck souls. You can only do this ability if you are not incorporeal"

	button_icon_state = "soul_steal"

	click_to_activate = TRUE

	cooldown_time = 20 SECONDS // maximum cooldown you can have for eating souls

	var/sucking_time = 4 SECONDS // how long should we suck for?

	var/quick_eater = FALSE // used in an activate() check to see if they recently ate a soul

/datum/action/cooldown/slasher/soul_steal/Activate(atom/target)

	var/mob/living/carbon/human/human_target = target
	var/mob/living/carbon/human/human_owner = owner
	var/datum/antagonist/slasher/slasherdatum = human_owner.mind.has_antag_datum(/datum/antagonist/slasher)

	/**
	 * Here we start our checks
	 * We cant do it in PreActivate() since that for some reason does not work
	 */

	if(!slasherdatum) // is this person even a slasher? mostly a safety check
		to_chat(owner, span_warning("You should not have this ability or your slasher antagonist datum was deleted, please contact coders"))
		return

	if(isopenturf(target) || isclosedturf(target)) // dont say anything, they probably mis-clicked
		return

	if(human_owner == human_target) // you cant suck yourself, no comment
		return

	if(slasherdatum.last_soul_sucked + slasherdatum.soul_digestion > world.time) // they are a speedrunner, mark them as such
		quick_eater = TRUE

	// After this point, give chat messages about failures

	if(!slasherdatum.corporeal)
		to_chat(owner, span_warning("You cannot suck souls whilst incorporeal!"))
		return

	if(!ishuman(target)) // are they trying to suck a corgi?
		to_chat(owner, span_warning("You can only suck the souls of humans"))
		return

	if(!human_target.mind) // are they trying to suck a monkey?
		to_chat(owner, span_warning("This target doesn't seem to have a soul to suck."))
		return

	if(human_target.soul_sucked) // are they trying to suck the person being revived 5 times?
		to_chat(owner, span_warning("Their soul has already been sucked."))
		return

	if(human_target.stat != DEAD) // are they trying to suck the person in anasthesia?
		to_chat(owner, span_notice("This human is not dead. You can't steal their soul."))
		return

	if(quick_eater) // you cant speedrun sucking, take it slow
		to_chat(owner, span_boldwarning("You feel as if you should slow down with eating their soul..."))
		sucking_time = 20 SECONDS // 5 times bigger

	/**
	 * If all the checks succeed, we begin our actual work
	 */

	. = ..()

	to_chat(owner, span_boldwarning("You remember that you need to stand perfectly still to consume their soul..."))

	if(!do_after(owner, sucking_time, target)) // you gotta stand perfectly still to consume da soul
		to_chat(owner, span_boldwarning("You got distracted and was unable to consume your victims soul!"))
		return FALSE

	if(quick_eater)
		to_chat(owner, span_boldwarning("You can feel your mind slipping, you feel as though bad things will happen if you absorb more souls so quickly!"))
	else
		to_chat(owner, span_boldwarning("You successfully consumed your victims soul!"))

	human_target.soul_sucked = TRUE

	if(human_target.dna.species.use_skintones) // make them deathly white, afterall they dont have a soul anymore
		human_target.skin_tone = "albino"
		human_target.dna.update_ui_block(DNA_SKIN_TONE_BLOCK)
	else // we dont discriminate, even skeletons can be white... (arent they already white?)
		human_target.dna.features["mcolor"] = "#FFFFFF"
		human_target.dna.update_uf_block(DNA_MUTANT_COLOR_BLOCK)

	human_target.update_body(is_creating = TRUE)

	slasherdatum.souls_sucked++
	slasherdatum.check_soul_punishment()
	slasherdatum.last_soul_sucked = world.time

	// lets make their machette stronger
	slasherdatum.linked_machette.force += 2.5
	slasherdatum.linked_machette.throwforce += 2.5
