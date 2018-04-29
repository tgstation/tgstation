/obj/effect/proc_holder/spell/aoe_turf/twop
	name = "Tranquil Walk of Peace"
	desc = "An ancient spell that slows all walking within effect area."

	school = "transmutation"
	charge_max = 1800 //3 minutes cooldown, it's effect is strong
	clothes_req = 0
	invocation = "AULIE OXIN FIERA"
	invocation_type = "whisper"
	range = 7 //within sight
	cooldown_min = 20 //20 deciseconds reduction per rank

	action_icon_state = "knock"

/obj/effect/proc_holder/spell/aoe_turf/knock/cast(list/targets,mob/user = usr)
	SEND_SOUND(user, sound('sound/magic/knock.ogg'))
	for(var/mob/living/carbon/C in targets)
		C.apply_status_effect(STATUS_EFFECT_FLESHMEND)