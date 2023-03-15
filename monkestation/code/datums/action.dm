/datum/action/item_action/toggle_mask
	name = "Toggle Mask"

/datum/action/item_action/use_circuit_goggles
	name = "Activate Circuit Goggles"
	icon_icon = 'monkestation/icons/mob/actions/actions_items.dmi'
	//icon_icon = 'monkestation/icons/obj/wiremod.dmi'
	button_icon_state = "goggle_toggle"

/datum/action/item_action/use_circuit_goggles/Trigger()
	if(IsAvailable())
		owner.click_intercept = src
		to_chat(owner, "<span class='notice'>[target] circuit goggles activate. Click on a target!</span>")
		return TRUE

/datum/action/item_action/use_circuit_goggles/proc/InterceptClickOn(mob/living/carbon/caller, params, atom/target)
	caller.click_intercept = null
	SEND_SIGNAL(caller.glasses, COMSIG_CIRCUIT_GOGGLES_USED, target, caller)

/datum/action/item_action/use_circuit_goggles/Remove(mob/M)
	if(owner.click_intercept == src)
		owner.client.click_intercept = null
	..()
