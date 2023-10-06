/datum/action/cooldown/slasher/incorporealize
	name = "Incorporealize"
	desc = " Become incorporeal, capable of moving through walls and being completely invisible, but unable to interact with the world. Can only be used when corporeal and when not in view of any human being. "
	button_icon_state = "incorporealize"
	cooldown_time = 20 SECONDS

	var/flipped = FALSE

/datum/action/cooldown/slasher/incorporealize/PreActivate(atom/target)
	. = ..()
	if(!do_after(target, 1.5 SECONDS, get_turf(target)))
		return FALSE

	if(!flipped)
		for(var/mob/living/watchers in view(9, target) - target)
			target.balloon_alert(owner, "you can only vanish unseen.")
			return FALSE
	return TRUE

/datum/action/cooldown/slasher/incorporealize/Activate(atom/target)
	. = ..()

	flipped = !flipped

	if(flipped)
		name = "Corporealize"
		desc = "Manifest your being from your incorporeal state."
		button_icon_state = "corporealize"
	else
		name = "Incorporealize"
		desc = " Become incorporeal, capable of moving through walls and being completely invisible, but unable to interact with the world. Can only be used when corporeal and when not in view of any human being. "
		button_icon_state = "incorporealize"
