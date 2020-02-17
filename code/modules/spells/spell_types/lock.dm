/obj/effect/proc_holder/spell/aoe_turf/lock
	name = "Lock"
	desc = "This spell locks nearby doors and closets."

	school = "transmutation"
	charge_max = 100
	clothes_req = FALSE
	invocation = " D'orst Uk"
	invocation_type = "whisper"
	range = 3
	cooldown_min = 20 //20 deciseconds reduction per rank

	action_icon_state = "lock"

/obj/effect/proc_holder/spell/aoe_turf/lock/cast(list/targets,mob/user = usr)
	SEND_SOUND(user, sound('sound/magic/lock.ogg'))
	for(var/turf/T in targets)
		for(var/obj/machinery/door/door in T.contents)
			INVOKE_ASYNC(src, .proc/lock_door, door)
		for(var/obj/structure/closet/C in T.contents)
			INVOKE_ASYNC(src, .proc/lock_closet, C)

/obj/effect/proc_holder/spell/aoe_turf/lock/proc/lock_door(var/obj/machinery/door/door)
	door.close()
	if(istype(door, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/A = door
		A.locked = TRUE
	door.update_icon()

/obj/effect/proc_holder/spell/aoe_turf/lock/proc/lock_closet(var/obj/structure/closet/C)
	C.close()
	C.locked = TRUE
	C.update_icon()
