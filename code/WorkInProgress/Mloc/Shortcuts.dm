/mob/verb/shortcut_changeintent(var/changeto as num)
	set name = "_changeintent"
	set hidden = 1
	if(istype(usr,/mob/living/carbon))
		if(changeto == 1)
			switch(usr.a_intent)
				if("help")
					usr.a_intent = "disarm"
					usr.hud_used.action_intent.icon_state = "disarm"
				if("disarm")
					usr.a_intent = "hurt"
					usr.hud_used.action_intent.icon_state = "harm"
				if("hurt")
					usr.a_intent = "grab"
					usr.hud_used.action_intent.icon_state = "grab"
				if("grab")
					usr.a_intent = "help"
					usr.hud_used.action_intent.icon_state = "help"
		else if(changeto == -1)
			switch(usr.a_intent)
				if("help")
					usr.a_intent = "grab"
					usr.hud_used.action_intent.icon_state = "grab"
				if("disarm")
					usr.a_intent = "help"
					usr.hud_used.action_intent.icon_state = "help"
				if("hurt")
					usr.a_intent = "disarm"
					usr.hud_used.action_intent.icon_state = "disarm"
				if("grab")
					usr.a_intent = "hurt"
					usr.hud_used.action_intent.icon_state = "harm"
	return