/obj/effect/proc_holder/spell/pointed/blood_siphon
	name = "Blood Siphon"
	desc = "A touch spell that heals your wounds while damaging the enemy. It has a chance to transfer wounds between you and your enemy."
	school = SCHOOL_EVOCATION
	charge_max = 150
	clothes_req = FALSE
	invocation = "FL'MS O'ET'RN'ITY"
	invocation_type = INVOCATION_WHISPER
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "blood_siphon"
	action_background_icon_state = "bg_ecult"
	range = 9

/obj/effect/proc_holder/spell/pointed/blood_siphon/cast(list/targets, mob/user)
	. = ..()
	var/target = targets[1]
	playsound(user, 'sound/magic/demon_attack1.ogg', 75, TRUE)
	if(ishuman(target))
		var/mob/living/carbon/human/tar = target
		if(tar.anti_magic_check())
			tar.visible_message(span_danger("The spell bounces off of [target]!"),span_danger("The spell bounces off of you!"))
			return ..()
	var/mob/living/carbon/carbon_user = user
	if(isliving(target))
		var/mob/living/living_target = target
		living_target.adjustBruteLoss(20)
		carbon_user.adjustBruteLoss(-20)
	if(iscarbon(target))
		var/mob/living/carbon/carbon_target = target
		for(var/bp in carbon_user.bodyparts)
			var/obj/item/bodypart/bodypart = bp
			for(var/i in bodypart.wounds)
				var/datum/wound/iter_wound = i
				if(prob(50))
					continue
				var/obj/item/bodypart/target_bodypart = locate(bodypart.type) in carbon_target.bodyparts
				if(!target_bodypart)
					continue
				iter_wound.remove_wound()
				iter_wound.apply_wound(target_bodypart)

		carbon_target.blood_volume -= 20
		if(carbon_user.blood_volume < BLOOD_VOLUME_MAXIMUM) //we dont want to explode after all
			carbon_user.blood_volume += 20
		return

/obj/effect/proc_holder/spell/pointed/blood_siphon/can_target(atom/target, mob/user, silent)
	. = ..()
	if(!.)
		return FALSE
	if(!istype(target,/mob/living))
		if(!silent)
			to_chat(user, span_warning("You are unable to siphon [target]!"))
		return FALSE
	return TRUE
