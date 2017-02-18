/mob/living/brain/say(message)
	if(!(container && istype(container, /obj/item/device/mmi)))
		return //No MMI, can't speak, bucko./N
	else
		if(prob(emp_damage*4))
			if(prob(10))//10% chane to drop the message entirely
				return
			else
				message = Gibberish(message, (emp_damage*6))//scrambles the message, gets worse when emp_damage is higher
		..()

/mob/living/brain/radio(message, message_mode, list/spans)
	if(message_mode && istype(container, /obj/item/device/mmi))
		var/obj/item/device/mmi/R = container
		if(R.radio)
			R.radio.talk_into(src, message, , spans)
			return ITALICS | REDUCE_RANGE

/mob/living/brain/lingcheck()
	return 0

/mob/living/brain/treat_message(message)
	message = capitalize(message)
	return message