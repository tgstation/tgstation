/datum/action/cooldown/slasher/incorporealize
	name = "Incorporealize"
	desc = "Become incorporeal, capable of moving through walls and being completely invisible, but unable to interact with the world. Can only be used when corporeal and when not in view of any human being."
	button_icon_state = "incorporealize"
	cooldown_time = 20 SECONDS

	var/flipped = FALSE

/datum/action/cooldown/slasher/incorporealize/Activate(atom/target)
	. = ..()
	var/datum/antagonist/slasher/slasherdatum = owner.mind.has_antag_datum(/datum/antagonist/slasher)

	/**
	 * Here we start our checks
	 * We cant do it in PreActivate() since that for some reason does not work
	 */

	if(!slasherdatum)
		to_chat(owner, span_warning("You should not have this ability or your slasher antagonist datum was deleted, please contact coders"))
		return

	if(slasherdatum.soul_punishment >= 2)
		to_chat(owner, span_boldwarning("The souls you have stolen are preventing you from going incorporeal!"))
		return

	if(!flipped)
		for(var/mob/living/watchers in view(9, target) - target)
			target.balloon_alert(owner, "you can only vanish unseen.")
			return

	/**
	 * All good? then lets continue
	 */

	if(!do_after(target, 1.5 SECONDS, get_turf(target)))
		break_corp()
		return

	flipped = !flipped

	if(flipped)
		name = "Corporealize"
		desc = "Manifest your being from your incorporeal state."
		button_icon_state = "corporealize"
		if(isliving(owner))
			var/mob/living/owner_mob = owner
			slasherdatum.corporeal = FALSE
			owner_mob.movement_type |= PHASING
			owner_mob.status_flags |= GODMODE
			animate(owner_mob, alpha = 0, time = 1.5 SECONDS)
			ADD_TRAIT(owner_mob, TRAIT_PACIFISM, "slasher")
			ADD_TRAIT(owner_mob, TRAIT_HANDS_BLOCKED, "slasher")
	else
		name = "Incorporealize"
		desc = "Become incorporeal, capable of moving through walls and being completely invisible, but unable to interact with the world. Can only be used when corporeal and when not in view of any human being. "
		button_icon_state = "incorporealize"
		if(isliving(owner))
			var/mob/living/owner_mob = owner
			slasherdatum.corporeal = TRUE
			owner_mob.movement_type &= ~PHASING
			owner_mob.status_flags &= ~GODMODE
			animate(owner_mob, alpha = 255, time = 1.5 SECONDS)
			REMOVE_TRAIT(owner_mob, TRAIT_PACIFISM, "slasher")
			REMOVE_TRAIT(owner_mob, TRAIT_HANDS_BLOCKED, "slasher")

	build_all_button_icons(UPDATE_BUTTON_NAME|UPDATE_BUTTON_ICON)

/datum/action/cooldown/slasher/incorporealize/proc/break_corp()
	name = "Incorporealize"
	desc = " Become incorporeal, capable of moving through walls and being completely invisible, but unable to interact with the world. Can only be used when corporeal and when not in view of any human being. "
	button_icon_state = "incorporealize"
	flipped = FALSE
	if(isliving(owner))
		var/mob/living/owner_mob = owner
		var/datum/antagonist/slasher/slasherdatum = owner.mind.has_antag_datum(/datum/antagonist/slasher)
		if(slasherdatum)
			slasherdatum.corporeal = TRUE
		owner_mob.movement_type &= ~PHASING
		owner_mob.status_flags &= ~GODMODE
		animate(owner_mob, alpha = 255, time = 1.5 SECONDS)
		REMOVE_TRAIT(owner_mob, TRAIT_PACIFISM, "slasher")
		REMOVE_TRAIT(owner_mob, TRAIT_HANDS_BLOCKED, "slasher")
	build_all_button_icons(UPDATE_BUTTON_NAME|UPDATE_BUTTON_ICON)
