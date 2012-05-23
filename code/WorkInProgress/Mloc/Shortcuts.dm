/mob/verb/shortcut_changeintent(var/changeto as num)
	set name = "_changeintent"
	set hidden = 1
	if(istype(usr,/mob/living/carbon))
		if(changeto == 1)
			switch(usr.a_intent)
				if("help")
					usr.a_intent = "disarm"
					usr.hud_used.action_intent.icon_state = "disarm"
					usr.hud_used.hurt_intent.icon_state = "harm_small"
					usr.hud_used.help_intent.icon_state = "help_small"
					usr.hud_used.grab_intent.icon_state = "grab_small"
					usr.hud_used.disarm_intent.icon_state = "disarm_small_active"
				if("disarm")
					usr.a_intent = "hurt"
					usr.hud_used.action_intent.icon_state = "harm"
					usr.hud_used.hurt_intent.icon_state = "harm_small_active"
					usr.hud_used.help_intent.icon_state = "help_small"
					usr.hud_used.grab_intent.icon_state = "grab_small"
					usr.hud_used.disarm_intent.icon_state = "disarm_small"
				if("hurt")
					usr.a_intent = "grab"
					usr.hud_used.action_intent.icon_state = "grab"
					usr.hud_used.hurt_intent.icon_state = "harm_small"
					usr.hud_used.help_intent.icon_state = "help_small"
					usr.hud_used.grab_intent.icon_state = "grab_small_active"
					usr.hud_used.disarm_intent.icon_state = "disarm_small"
				if("grab")
					usr.a_intent = "help"
					usr.hud_used.action_intent.icon_state = "help"
					usr.hud_used.hurt_intent.icon_state = "harm_small"
					usr.hud_used.help_intent.icon_state = "help_small_active"
					usr.hud_used.grab_intent.icon_state = "grab_small"
					usr.hud_used.disarm_intent.icon_state = "disarm_small"
		else if(changeto == -1)
			switch(usr.a_intent)
				if("help")
					usr.a_intent = "grab"
					usr.hud_used.action_intent.icon_state = "grab"
					usr.hud_used.hurt_intent.icon_state = "harm_small"
					usr.hud_used.help_intent.icon_state = "help_small"
					usr.hud_used.grab_intent.icon_state = "grab_small_active"
					usr.hud_used.disarm_intent.icon_state = "disarm_small"
				if("disarm")
					usr.a_intent = "help"
					usr.hud_used.action_intent.icon_state = "help"
					usr.hud_used.hurt_intent.icon_state = "harm_small"
					usr.hud_used.help_intent.icon_state = "help_small_active"
					usr.hud_used.grab_intent.icon_state = "grab_small"
					usr.hud_used.disarm_intent.icon_state = "disarm_small"
				if("hurt")
					usr.a_intent = "disarm"
					usr.hud_used.action_intent.icon_state = "disarm"
					usr.hud_used.hurt_intent.icon_state = "harm_small"
					usr.hud_used.help_intent.icon_state = "help_small"
					usr.hud_used.grab_intent.icon_state = "grab_small"
					usr.hud_used.disarm_intent.icon_state = "disarm_small_active"
				if("grab")
					usr.a_intent = "hurt"
					usr.hud_used.action_intent.icon_state = "harm"
					usr.hud_used.hurt_intent.icon_state = "harm_small_active"
					usr.hud_used.help_intent.icon_state = "help_small"
					usr.hud_used.grab_intent.icon_state = "grab_small"
					usr.hud_used.disarm_intent.icon_state = "disarm_small"
	return