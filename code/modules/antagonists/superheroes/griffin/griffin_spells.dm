/obj/effect/proc_holder/spell/pointed/griffin_convert
	name = "Convert"
	desc = "Convert people into your henchmen."
	charge_max = 1 MINUTES
	clothes_req = FALSE
	invocation = "Join the Tide!"
	invocation_type = INVOCATION_SHOUT
	clear_invocation = TRUE
	range = 1
	action_icon_state = "convert_tider"
	action_background_icon_state = "bg_default"
	action_icon = 'icons/mob/actions/actions_minor_antag.dmi'

/obj/effect/proc_holder/spell/pointed/griffin_convert/cast(list/targets, mob/user)
	if(!targets.len)
		to_chat(user, "<span class='warning'>No target found in range!</span>")
		return FALSE

	if(!can_target(targets[1], user))
		return FALSE

	var/mob/living/targeted = targets[1]

	if(targeted == user)
		return FALSE

	if(!istype(targeted))
		to_chat(user, "<span class='warning'>No target found in range!</span>")
		return FALSE

	if(HAS_TRAIT(targeted, TRAIT_MINDSHIELD))
		to_chat(user, "<span class='warning'>You attempt to convert [targeted], but they are mindshielded!</span>")
		return TRUE //It counts!

	if(targeted.flash_act(1, 1)) //Basically headrev's flash, but with cooldown and an invocation.
		brainwash(targeted, "You are a tider now! Serve the tide and assist The Griffin no matter the cost!")
		targeted.adjustStaminaLoss(rand(80,120))
		targeted.Paralyze(rand(25,50))
	return TRUE
