// Currently unused
/obj/effect/proc_holder/spell/pointed/touch/mad_touch
	name = "Touch of Madness"
	desc = "A touch spell that drains your enemy's sanity."
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "mad_touch"
	action_background_icon_state = "bg_ecult"
	school = SCHOOL_FORBIDDEN
	charge_max = 150
	clothes_req = FALSE
	invocation_type = INVOCATION_NONE
	range = 2

/obj/effect/proc_holder/spell/pointed/touch/mad_touch/can_target(atom/target, mob/user, silent)
	if(!ishuman(target))
		if(!silent)
			target.balloon_alert(user, "invalid target!")
		return FALSE
	return TRUE

/obj/effect/proc_holder/spell/pointed/touch/mad_touch/cast(list/targets, mob/user)
	. = ..()
	for(var/mob/living/carbon/target in targets)
		if(ishuman(targets))
			var/mob/living/carbon/human/tar = target
			if(tar.anti_magic_check())
				tar.visible_message(span_danger("The spell bounces off of [target]!"),span_danger("The spell bounces off of you!"))
				return
		if(target.mind && !IS_HERETIC(target))
			to_chat(user, span_warning("[target.name] has been cursed!"))
			SEND_SIGNAL(target, COMSIG_ADD_MOOD_EVENT, "gates_of_mansus", /datum/mood_event/gates_of_mansus)
