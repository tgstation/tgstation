/obj/effect/proc_holder/spell/aoe_turf/knock
	name = "Knock"
	desc = "This spell opens nearby doors and closets."

	school = SCHOOL_TRANSMUTATION
	charge_max = 100
	clothes_req = FALSE
	invocation = "AULIE OXIN FIERA"
	invocation_type = INVOCATION_WHISPER
	range = 3
	cooldown_min = 20 //20 deciseconds reduction per rank

	action_icon_state = "knock"

/obj/effect/proc_holder/spell/aoe_turf/knock/cast(list/targets,mob/user = usr)
	SEND_SOUND(user, sound('sound/magic/knock.ogg'))
	for(var/turf/nearby_turf in targets)
		SEND_SIGNAL(nearby_turf, COMSIG_ATOM_MAGICALLY_UNLOCKED, src, user)
