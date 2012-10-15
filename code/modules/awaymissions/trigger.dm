/obj/effect/step_trigger/message
	var/message	//the message to give to the mob

/obj/effect/step_trigger/message/Trigger(mob/M as mob)
	if(M.client)
		M << "<span class='info'>[message]</span>"
		del(src)