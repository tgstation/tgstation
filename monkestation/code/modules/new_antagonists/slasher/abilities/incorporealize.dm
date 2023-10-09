/datum/action/cooldown/slasher/incorporealize
	name = "Incorporealize"
	desc = " Become incorporeal, capable of moving through walls and being completely invisible, but unable to interact with the world. Can only be used when corporeal and when not in view of any human being. "
	button_icon_state = "incorporealize"
	cooldown_time = 20 SECONDS

	var/flipped = FALSE

/datum/action/cooldown/slasher/incorporealize/PreActivate(atom/target)
	. = ..()
	var/datum/antagonist/slasher/slasherdatum = owner.mind.has_antag_datum(/datum/antagonist/slasher)
	if(slasherdatum && (slasherdatum.soul_punishment >= 2))
		return FALSE
	if(!flipped)
		for(var/mob/living/watchers in view(9, target) - target)
			target.balloon_alert(owner, "you can only vanish unseen.")
			return FALSE

	if(!do_after(target, 1.5 SECONDS, get_turf(target)))
		break_corp()
		return FALSE
	return TRUE

/datum/action/cooldown/slasher/incorporealize/Activate(atom/target)
	. = ..()
	var/datum/antagonist/slasher/slasherdatum = owner.mind.has_antag_datum(/datum/antagonist/slasher)
	if(!slasherdatum)
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
	else
		name = "Incorporealize"
		desc = " Become incorporeal, capable of moving through walls and being completely invisible, but unable to interact with the world. Can only be used when corporeal and when not in view of any human being. "
		button_icon_state = "incorporealize"
		if(isliving(owner))
			var/mob/living/owner_mob = owner
			slasherdatum.corporeal = TRUE
			owner_mob.movement_type &= ~PHASING
			owner_mob.status_flags &= ~GODMODE
			animate(owner_mob, alpha = 255, time = 1.5 SECONDS)
			REMOVE_TRAIT(owner_mob, TRAIT_PACIFISM, "slasher")

	build_all_button_icons(UPDATE_BUTTON_NAME|UPDATE_BUTTON_ICON)

/datum/action/cooldown/slasher/incorporealize/proc/break_corp()
	name = "Incorporealize"
	desc = " Become incorporeal, capable of moving through walls and being completely invisible, but unable to interact with the world. Can only be used when corporeal and when not in view of any human being. "
	button_icon_state = "incorporealize"
	flipped = FALSE
	if(isliving(owner))
		var/mob/living/owner_mob = owner
		slasherdatum.corporeal = TRUE
		owner_mob.movement_type &= ~PHASING
		owner_mob.status_flags &= ~GODMODE
		animate(owner_mob, alpha = 255, time = 1.5 SECONDS)
		REMOVE_TRAIT(owner_mob, TRAIT_PACIFISM, "slasher")
	build_all_button_icons(UPDATE_BUTTON_NAME|UPDATE_BUTTON_ICON)
