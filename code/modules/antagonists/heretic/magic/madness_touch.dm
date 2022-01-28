// Currently unused
/obj/effect/proc_holder/spell/pointed/touch/mad_touch
	name = "Touch of Madness"
	desc = "A touch spell that drains your enemy's sanity."
	school = SCHOOL_FORBIDDEN
	charge_max = 150
	clothes_req = FALSE
	invocation_type = "none"
	range = 2
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "mad_touch"
	action_background_icon_state = "bg_ecult"

/obj/effect/proc_holder/spell/pointed/touch/mad_touch/can_target(atom/target, mob/user, silent)
	. = ..()
	if(!.)
		return FALSE
	if(!istype(target,/mob/living/carbon/human))
		if(!silent)
			to_chat(user, span_warning("You are unable to touch [target]!"))
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
		if(target.mind && !target.mind.has_antag_datum(/datum/antagonist/heretic))
			to_chat(user,span_warning("[target.name] has been cursed!"))
			SEND_SIGNAL(target, COMSIG_ADD_MOOD_EVENT, "gates_of_mansus", /datum/mood_event/gates_of_mansus)
