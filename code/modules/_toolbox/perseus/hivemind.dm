/mob/living/carbon/human/handle_inherent_channels(message, message_mode)
	if (stat)
		return ..()
	else if (message_mode == MODE_ALIEN && check_perseus(src))
		perseusHivemindSay(message)
		return 1
	else return ..()

/mob/living/proc/perseusHivemindSay(var/message)
	if (!message)
		return

	if(key) log_say("[key_name(src)] : [message]")
	message = trim(message)

	var/message_a = say_quote(message)
	var/rendered = "<i><span class='game say'>Hivemind, <span class='name'>[name]</span> <span class='message'>[message_a]</span></span></i>"
	for (var/mob/living/S in world)
		if(!S.stat)
			if(check_perseus(S))
				to_chat(S, rendered)

/proc/perseusAlert(var/name, var/alert, var/alert_sound = 0)
	if (!alert)
		return

	log_say("Perseus Alert : [alert]")
	var/rendered = "<i><span class='game say'>Hivemind Alert, <span class='name'>[name]</span> beeps, \"<span class='message'>[alert]</span>\"</span></i>"
	for (var/mob/living/S in GLOB.mob_list)
		if(!S.stat)
			if(check_perseus(S))
				to_chat(S, rendered)
				if (alert_sound)
					var/alert_sound_in
					switch (alert_sound)
						if (1)
							alert_sound_in = 'sound/items/timer.ogg'
						if (2)
							alert_sound_in = 'sound/effects/alert.ogg'
						if (3)
							alert_sound_in = 'sound/machines/twobeep.ogg'
						else
							return
					S << sound(alert_sound_in)
