/obj/effect/proc_holder/spell/pointed/blood_siphon
	name = "Blood Siphon"
	desc = "A touch spell that heals your wounds while damaging the enemy. It has a chance to transfer wounds between you and your enemy."
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "blood_siphon"
	action_background_icon_state = "bg_ecult"
	invocation = "FL'MS O'ET'RN'ITY"
	invocation_type = INVOCATION_WHISPER
	school = SCHOOL_EVOCATION
	charge_max = 150
	clothes_req = FALSE
	range = 9

/obj/effect/proc_holder/spell/pointed/blood_siphon/cast(list/targets, mob/user)
	if(!isliving(user))
		return

	var/mob/living/real_target = targets[1]
	var/mob/living/living_user = user
	playsound(user, 'sound/magic/demon_attack1.ogg', 75, TRUE)
	if(real_target.anti_magic_check())
		user.balloon_alert(user, "spell blocked!")
		target.visible_message(
			span_danger("The spell bounces off of [real_target]!"),
			span_danger("The spell bounces off of you!"),
		)
		return

	real_target.visible_message(
		span_danger("[real_target] turns pale as a red glow envelops [real_target.p_them()]"),
		span_danger("You pale as a red glow enevelops you!"),
	)

	real_target.adjustBruteLoss(20)
	living_user.adjustBruteLoss(-20)

	if(!living_user.blood_volume)
		return

	real_target.blood_volume -= 20
	if(living_user.blood_volume < BLOOD_VOLUME_MAXIMUM) // we dont want to explode from casting
		living_user.blood_volume += 20

	if(!iscarbon(target))
		return

	var/mob/living/carbon/carbon_target = real_target
	for(var/obj/item/bodypart/bodypart as anything in carbon_user.bodyparts)
		for(var/datum/wound/iter_wound as anything in bodypart.wounds)
			if(prob(50))
				continue
			var/obj/item/bodypart/target_bodypart = locate(bodypart.type) in carbon_target.bodyparts
			if(!target_bodypart)
				continue
			iter_wound.remove_wound()
			iter_wound.apply_wound(target_bodypart)

/obj/effect/proc_holder/spell/pointed/blood_siphon/can_target(atom/target, mob/user, silent)
	if(!isliving(target))
		if(!silent)
			target.balloon_alert(user, "invalid target!")
		return FALSE
	return TRUE
