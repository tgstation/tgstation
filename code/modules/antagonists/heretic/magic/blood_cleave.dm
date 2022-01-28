/obj/effect/proc_holder/spell/pointed/cleave
	name = "Cleave"
	desc = "Causes severe bleeding on a target and several targets around them."
	school = SCHOOL_FORBIDDEN
	charge_max = 350
	clothes_req = FALSE
	invocation = "CL'VE"
	invocation_type = INVOCATION_WHISPER
	range = 9
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "cleave"
	action_background_icon_state = "bg_ecult"

/obj/effect/proc_holder/spell/pointed/cleave/cast(list/targets, mob/user)
	if(!targets.len)
		to_chat(user, span_warning("No target found in range!"))
		return FALSE
	if(!can_target(targets[1], user))
		return FALSE

	for(var/mob/living/carbon/human/C in range(1,targets[1]))
		targets |= C

	for(var/X in targets)
		var/mob/living/carbon/human/target = X
		if(target == user)
			continue
		if(target.anti_magic_check())
			to_chat(user, span_warning("The spell had no effect!"))
			target.visible_message(span_danger("[target]'s veins flash with fire, but their magic protection repulses the blaze!"), \
							span_danger("Your veins flash with fire, but your magic protection repels the blaze!"))
			continue

		target.visible_message(span_danger("[target]'s veins are shredded from within as an unholy blaze erupts from their blood!"), \
							span_danger("Your veins burst from within and unholy flame erupts from your blood!"))
		var/obj/item/bodypart/bodypart = pick(target.bodyparts)
		var/datum/wound/slash/critical/crit_wound = new
		crit_wound.apply_wound(bodypart)
		target.adjustFireLoss(20)
		new /obj/effect/temp_visual/cleave(target.drop_location())

/obj/effect/proc_holder/spell/pointed/cleave/can_target(atom/target, mob/user, silent)
	. = ..()
	if(!.)
		return FALSE
	if(!istype(target,/mob/living/carbon/human))
		if(!silent)
			to_chat(user, span_warning("You are unable to cleave [target]!"))
		return FALSE
	return TRUE

/obj/effect/proc_holder/spell/pointed/cleave/long
	charge_max = 650

/obj/effect/temp_visual/cleave
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "cleave"
	duration = 6
