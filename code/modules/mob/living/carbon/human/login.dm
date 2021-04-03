/mob/living/carbon/human/Login()
	. = ..()
	if(!LAZYLEN(afk_thefts))
		return

	var/list/print_msg = list()
	print_msg += "<span class='info'>*---------*</span>"
	print_msg += "<span class='userdanger'>As you snap back to consciousness, you recall people messing with your stuff...</span>"

	for(var/i in afk_thefts)
		var/list/iter_theft = i
		if(!islist(iter_theft) || LAZYLEN(iter_theft) != 2)
			continue
		var/theft_message = iter_theft[AFK_THEFT_MESSAGE]
		var/time_since = world.time - iter_theft[AFK_THEFT_TIME]
		print_msg += "\t</span class='danger'><b>[theft_message] [DisplayTimeText(time_since)] ago.</b></span>"

	if(LAZYLEN(afk_thefts) >= AFK_THEFT_MAX_MESSAGES)
		print_msg += "<span class='warning'>There may have been more, but that's all you can remember...</span>"
	print_msg += "<span class='info'>*---------*</span>"

	to_chat(src, print_msg.Join("\n"))
	LAZYNULL(afk_thefts)
