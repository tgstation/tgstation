// This file contains the proc we use for revenant harvesting because it is a very long and bulky proc that takes up a lot of space elsewhere

/// Container proc for `harvest()`, handles the pre-checks as well as potential early-exits for any reason.
/// Will return FALSE if we can't execute `harvest()`, or will otherwise the result of `harvest()`: a boolean value.
/mob/living/basic/revenant/proc/attempt_harvest(mob/living/carbon/human/target)
	if(LAZYFIND(drained_mobs, REF(target)))
		to_chat(src, span_revenwarning("[target]'s soul is dead and empty."))
		return FALSE

	if(!cast_check(0))
		return FALSE

	if(draining)
		to_chat(src, span_revenwarning("You are already siphoning the essence of a soul!"))
		return FALSE

	if(target.flags_1 & HOLOGRAM_1)
		target.balloon_alert(src, "doesn't possess a soul!") // it's a machine generated visual
		return

	draining = TRUE
	var/value_to_return = harvest_soul(target)
	if(!value_to_return)
		log_combat(src, target, "stopped the harvest of")
	draining = FALSE

	return value_to_return

/// Harvest; activated by clicking a target, will try to drain their essence. Handles all messages and handling of the target.
/// Returns FALSE if we exit out of the harvest, TRUE if it is fully done.
/mob/living/basic/revenant/proc/harvest_soul(mob/living/carbon/human/target) // this isn't in the main revenant code file because holyyyy shit it's long
	if(QDELETED(target)) // what
		return FALSE

	// cache pronouns in case they get deleted as well as be a nice micro-opt due to the multiple times we use them
	var/target_their = target.p_their()
	var/target_Their = target.p_Their()
	var/target_Theyre = target.p_Theyre()
	var/target_They_have = "[target.p_They()] [target.p_have()]"

	if(target.stat == CONSCIOUS)
		to_chat(src, span_revennotice("[target_Their] soul is too strong to harvest."))
		if(prob(10))
			to_chat(target, span_revennotice("You feel as if you are being watched."))
		return FALSE

	log_combat(src, target, "started to harvest")
	face_atom(target)
	var/essence_drained = rand(15, 20)

	to_chat(src, span_revennotice("You search for the soul of [target]."))

	if(!do_after(src, (rand(10, 20) DECISECONDS), target, timed_action_flags = IGNORE_HELD_ITEM)) //did they get deleted in that second?
		return FALSE

	var/target_has_client = !isnull(target.client)
	if(target_has_client || target.ckey) // any target that has been occupied with a ckey is considered "intelligent"
		to_chat(src, span_revennotice("[target_Their] soul burns with intelligence."))
		essence_drained += rand(20, 30)

	if(target.stat != DEAD && !HAS_TRAIT(target, TRAIT_WEAK_SOUL))
		to_chat(src, span_revennotice("[target_Their] soul blazes with life!"))
		essence_drained += rand(40, 50)

	if(!target_has_client && HAS_TRAIT(target, TRAIT_WEAK_SOUL))
		to_chat(src, span_revennotice("[target_Their] soul is weak and underdeveloped. They won't be worth very much."))
		essence_drained = 5

	to_chat(src, span_revennotice("[target_Their] soul is weak and faltering. It's time to harvest."))

	if(!do_after(src, (rand(15, 20) DECISECONDS), target, timed_action_flags = IGNORE_HELD_ITEM))
		to_chat(src, span_revennotice("The harvest is abandoned."))
		return FALSE

	switch(essence_drained)
		if(1 to 30)
			to_chat(src, span_revennotice("[target] will not yield much essence. Still, every bit counts."))
		if(30 to 70)
			to_chat(src, span_revennotice("[target] will yield an average amount of essence."))
		if(70 to 90)
			to_chat(src, span_revenboldnotice("Such a feast! [target] will yield much essence to you."))
		if(90 to INFINITY)
			to_chat(src, span_revenbignotice("Ah, the perfect soul. [target] will yield massive amounts of essence to you."))

	if(!do_after(src, (rand(15, 25) DECISECONDS), target, timed_action_flags = IGNORE_HELD_ITEM)) //how about now
		to_chat(src, span_revenwarning("You are not close enough to siphon [target ? "[target]'s" : "[target_their]"] soul. The link has been broken."))
		return FALSE

	if(target.stat == CONSCIOUS)
		to_chat(src, span_revenwarning("[target_Theyre] now powerful enough to fight off your draining!"))
		to_chat(target, span_bolddanger("You feel something tugging across your body before subsiding.")) //hey, wait a minute...
		return FALSE

	to_chat(src, span_revenminor("You begin siphoning essence from [target]'s soul."))
	if(target.stat != DEAD)
		to_chat(target, span_warning("You feel a horribly unpleasant draining sensation as your grip on life weakens..."))
	if(target.stat == SOFT_CRIT)
		target.Stun(46)

	apply_status_effect(/datum/status_effect/revenant/revealed, 5 SECONDS)
	apply_status_effect(/datum/status_effect/incapacitating/paralyzed/revenant, 5 SECONDS)

	target.visible_message(span_warning("[target] suddenly rises slightly into the air, [target_their] skin turning an ashy gray."))

	if(target.can_block_magic(MAGIC_RESISTANCE_HOLY))
		to_chat(src, span_revenminor("Something's wrong! [target] seems to be resisting the siphoning, leaving you vulnerable!"))
		target.visible_message(
			span_warning("[target] slumps onto the ground."),
			span_revenwarning("Violet lights, dancing in your vision, receding--"),
		)
		return FALSE

	var/datum/beam/draining_beam = Beam(target, icon_state = "drain_life")
	if(!do_after(src, 4.6 SECONDS, target, timed_action_flags = (IGNORE_HELD_ITEM | IGNORE_INCAPACITATED))) //As one cannot prove the existence of ghosts, ghosts cannot prove the existence of the target they were draining.
		to_chat(src, span_revenwarning("[target ? "[target]'s soul has" : "[target_They_have]"] been drawn out of your grasp. The link has been broken."))
		if(target)
			target.visible_message(
				span_warning("[target] slumps onto the ground."),
				span_revenwarning("Violet lights, dancing in your vision, receding--"),
			)
		qdel(draining_beam)
		return FALSE

	change_essence_amount(essence_drained, FALSE, target)

	if(essence_drained <= 90 && target.stat != DEAD && !HAS_TRAIT(target, TRAIT_WEAK_SOUL))
		max_essence += 5
		to_chat(src, span_revenboldnotice("The absorption of [target]'s living soul has increased your maximum essence level. Your new maximum essence is [max_essence]."))

	if(essence_drained > 90)
		max_essence += 15
		perfectsouls++
		to_chat(src, span_revenboldnotice("The perfection of [target]'s soul has increased your maximum essence level. Your new maximum essence is [max_essence]."))

	to_chat(src, span_revennotice("[target]'s soul has been considerably weakened and will yield no more essence for the time being."))
	target.visible_message(
		span_warning("[target] slumps onto the ground."),
		span_revenwarning("Violet lights, dancing in your vision, getting clo--"),
	)

	LAZYADD(drained_mobs, REF(target))
	if(target.stat != DEAD)
		target.investigate_log("has died from revenant harvest.", INVESTIGATE_DEATHS)
	target.death(FALSE)

	qdel(draining_beam)
	return TRUE
