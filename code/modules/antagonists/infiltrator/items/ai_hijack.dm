/obj/item/ai_hijack_device
	name = "serial exploitation unit"
	desc = "A strange circuitboard, branded with a large red S, with several ports."
	icon = 'icons/obj/module.dmi'
	icon_state = "ai_hijack"

/obj/item/ai_hijack_device/afterattack(atom/O, mob/user, proximity)
	if(isAI(O))
		var/mob/living/silicon/ai/A = O
		user.visible_message("<span class='warning'>[user] begins attaching something to [A]...</span>")
		if(do_after(user,55,target = A))
			forceMove(A)
			A.hijacking = src
			A.hijack_start = world.time
			to_chat(src, "<span class='danger'>Unknown device connected to /dev/ttySL0</span>")
			notify_ghosts("[user] has begun to hijack [A]!", source = A, action = NOTIFY_ORBIT, ghost_sound = 'sound/machines/chime.ogg')
	else
		return ..()