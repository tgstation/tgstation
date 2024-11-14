/// The message displayed in the hemophage's chat when they enter their dormant state.
#define DORMANT_STATE_START_MESSAGE "You feel your tumor's pulse slowing down, as it enters a dormant state. You suddenly feel incredibly weak and vulnerable to everything, and exercise has become even more difficult, as only your most vital bodily functions remain."
/// The message displayed in the hemophage's chat when they leave their dormant state.
#define DORMANT_STATE_END_MESSAGE "You feel a rush through your veins, as you can tell your tumor is pulsating at a regular pace once again. You no longer feel incredibly vulnerable, and exercise isn't as difficult anymore."


/datum/action/cooldown/hemophage
	cooldown_time = 3 SECONDS
	button_icon_state = null


/datum/action/cooldown/hemophage/New(Target)
	. = ..()

	if(target && isnull(button_icon_state))
		AddComponent(/datum/component/action_item_overlay, target)


/datum/action/cooldown/hemophage/toggle_dormant_state
	name = "Enter Dormant State"
	desc = "Causes the tumor inside of you to enter a dormant state, causing it to need just a minimum amount of blood to survive. However, as the tumor living in your body is the only thing keeping you still alive, rendering it latent cuts both it and you to just the essential functions to keep standing. It will no longer mend your body even in the darkness nor allow you to taste anything, and the lack of blood pumping through you will have you the weakest you've ever felt; and leave you hardly able to run. It is not on a switch, and it will take some time for it to awaken."
	cooldown_time = 2 MINUTES


/datum/action/cooldown/hemophage/toggle_dormant_state/Activate(atom/action_target)
	if(!owner || !ishuman(owner) || !target)
		return

	var/obj/item/organ/heart/hemophage/tumor = target
	if(!tumor || !istype(tumor)) // This shouldn't happen, but you can never be too careful.
		return

	owner.balloon_alert(owner, "[tumor.is_dormant ? "leaving" : "entering"] dormant state")

	if(!do_after(owner, 3 SECONDS))
		owner.balloon_alert(owner, "cancelled state change")
		return

	to_chat(owner, span_notice("[tumor.is_dormant ? DORMANT_STATE_END_MESSAGE : DORMANT_STATE_START_MESSAGE]"))

	StartCooldown()

	tumor.toggle_dormant_state()
	tumor.toggle_dormant_tumor_vulnerabilities(owner)

	if(tumor.is_dormant)
		name = "Exit Dormant State"
		desc = "Causes the pitch-black mass living inside of you to awaken, allowing your circulation to return and blood to pump freely once again. It fills your legs to let you run again, and longs for the darkness as it did before. You start to feel strength rather than the weakness you felt before. However, the tumor giving you life is not on a switch, and it will take some time to subdue it again."
	else
		name = initial(name)
		desc = initial(desc)

	build_all_button_icons(UPDATE_BUTTON_NAME)


#undef DORMANT_STATE_START_MESSAGE
#undef DORMANT_STATE_END_MESSAGE
