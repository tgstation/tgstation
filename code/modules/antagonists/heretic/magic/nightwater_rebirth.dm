/obj/effect/proc_holder/spell/targeted/fiery_rebirth
	name = "Nightwatcher's Rebirth"
	desc = "A spell that extinguishes you drains nearby heathens engulfed in flames of their life force, \
		healing you for each victim drained. Those in critical condition will have the last of their vitality drained, killing them."
	invocation = "GL'RY T' TH' N'GHT'W'TCH'ER"
	invocation_type = INVOCATION_WHISPER
	school = SCHOOL_FORBIDDEN
	clothes_req = FALSE
	action_background_icon_state = "bg_ecult"
	range = -1
	include_user = TRUE
	charge_max = 600
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "smoke"

/obj/effect/proc_holder/spell/targeted/fiery_rebirth/cast(list/targets, mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/human_user = user
	human_user.extinguish_mob()

	for(var/mob/living/carbon/target in view(7, user))
		if(!target.mind || !target.client || target.stat == DEAD || !target.on_fire || IS_HERETIC_OR_MONSTER(target))
			continue
		//This is essentially a death mark, use this to finish your opponent quicker.
		if(HAS_TRAIT(target, TRAIT_CRITICAL_CONDITION) && !HAS_TRAIT(target, TRAIT_NODEATH))
			target.death()

		target.adjustFireLoss(20)
		new /obj/effect/temp_visual/eldritch_smoke(target.drop_location())
		human_user.adjustBruteLoss(-10, FALSE)
		human_user.adjustFireLoss(-10, FALSE)
		human_user.adjustToxLoss(-10, FALSE)
		human_user.adjustOxyLoss(-10, FALSE)
		human_user.adjustStaminaLoss(-10)

/obj/effect/temp_visual/eldritch_smoke
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "smoke"
	duration = 10
