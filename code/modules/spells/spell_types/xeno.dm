/obj/effect/proc_holder/spell/aoe_turf/repulse/xeno //i fixed conflicts only to find out that this is in the WIZARD file instead of the xeno file?!
	name = "Tail Sweep"
	desc = "Throw back attackers with a sweep of your tail."
	sound = 'sound/magic/tail_swing.ogg'
	charge_max = 150
	clothes_req = FALSE
	range = 2
	cooldown_min = 150
	invocation_type = INVOCATION_NONE
	sparkle_path = /obj/effect/temp_visual/dir_setting/tailsweep
	action_icon = 'icons/mob/actions/actions_xeno.dmi'
	action_icon_state = "tailsweep"
	action_background_icon_state = "bg_alien"
	antimagic_flags = NONE

/obj/effect/proc_holder/spell/aoe_turf/repulse/xeno/cast(list/targets, mob/user = usr)
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		playsound(C.loc, 'sound/voice/hiss5.ogg', 80, TRUE, TRUE)
		C.spin(6,1)
	..(targets, user, 60)
