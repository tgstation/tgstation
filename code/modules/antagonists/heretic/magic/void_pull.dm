/obj/effect/proc_holder/spell/targeted/void_pull
	name = "Void Pull"
	desc = "Call the void, this pulls all nearby people closer to you, damages people already around you. If they are 4 tiles or closer they are also knocked down and a micro-stun is applied."
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "voidpull"
	action_background_icon_state = "bg_ecult"
	invocation = "BR'NG F'RTH TH'M T' M'"
	invocation_type = INVOCATION_WHISPER
	school = SCHOOL_FORBIDDEN
	clothes_req = FALSE
	range = -1
	include_user = TRUE
	charge_max = 400

/obj/effect/proc_holder/spell/targeted/void_pull/cast(list/targets, mob/user)
	. = ..()
	for(var/mob/living/living_mob in range(1, user) - user)
		if(IS_HERETIC_OR_MONSTER(living_mob))
			continue
		living_mob.adjustBruteLoss(30)

	playsound(user,'sound/magic/voidblink.ogg',100)
	new /obj/effect/temp_visual/voidin(user.drop_location())
	for(var/mob/living/livies in view(7, user) - user)

		if(get_dist(user, livies) < 4)
			livies.AdjustKnockdown(3 SECONDS)
			livies.AdjustParalyzed(0.5 SECONDS)

		for(var/i in 1 to 3)
			livies.forceMove(get_step_towards(livies,user))
