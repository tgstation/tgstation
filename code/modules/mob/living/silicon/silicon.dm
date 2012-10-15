/mob/living/silicon
	gender = NEUTER
	robot_talk_understand = 1
	voice_name = "synthesized voice"
	var/syndicate = 0
	var/datum/ai_laws/laws = null//Now... THEY ALL CAN ALL HAVE LAWS
	var/list/alarms_to_show = list()
	var/list/alarms_to_clear = list()


	var/list/alarm_types_show = list("Motion" = 0, "Fire" = 0, "Atmosphere" = 0, "Power" = 0, "Camera" = 0)
	var/list/alarm_types_clear = list("Motion" = 0, "Fire" = 0, "Atmosphere" = 0, "Power" = 0, "Camera" = 0)

/mob/living/silicon/proc/cancelAlarm()
	return

/mob/living/silicon/proc/triggerAlarm()
	return

/mob/living/silicon/proc/show_laws()
	return

/mob/living/silicon/proc/queueAlarm(var/message, var/type, var/incoming = 1)
	var/in_cooldown = (alarms_to_show.len > 0 || alarms_to_clear.len > 0)
	if(incoming)
		alarms_to_show += message
		alarm_types_show[type] += 1
	else
		alarms_to_clear += message
		alarm_types_clear[type] += 1

	if(!in_cooldown)
		spawn(10 * 10) // 10 seconds

			if(alarms_to_show.len < 5)
				for(var/msg in alarms_to_show)
					src << msg
			else if(alarms_to_show.len)

				var/msg = "--- "

				if(alarm_types_show["Motion"])
					msg += "MOTION: [alarm_types_show["Motion"]] alarms detected. - "

				if(alarm_types_show["Fire"])
					msg += "FIRE: [alarm_types_show["Fire"]] alarms detected. - "

				if(alarm_types_show["Atmosphere"])
					msg += "ATMOSPHERE: [alarm_types_show["Atmosphere"]] alarms detected. - "

				if(alarm_types_show["Power"])
					msg += "POWER: [alarm_types_show["Power"]] alarms detected. - "

				if(alarm_types_show["Camera"])
					msg += "CAMERA: [alarm_types_show["Power"]] alarms detected. - "

				msg += "<A href=?src=\ref[src];showalerts=1'>\[Show Alerts\]</a>"
				src << msg

			if(alarms_to_clear.len < 3)
				for(var/msg in alarms_to_clear)
					src << msg

			else if(alarms_to_clear.len)
				var/msg = "--- "

				if(alarm_types_clear["Motion"])
					msg += "MOTION: [alarm_types_clear["Motion"]] alarms cleared. - "

				if(alarm_types_clear["Fire"])
					msg += "FIRE: [alarm_types_clear["Fire"]] alarms cleared. - "

				if(alarm_types_clear["Atmosphere"])
					msg += "ATMOSPHERE: [alarm_types_clear["Atmosphere"]] alarms cleared. - "

				if(alarm_types_clear["Power"])
					msg += "POWER: [alarm_types_clear["Power"]] alarms cleared. - "

				if(alarm_types_show["Camera"])
					msg += "CAMERA: [alarm_types_show["Power"]] alarms detected. - "

				msg += "<A href=?src=\ref[src];showalerts=1'>\[Show Alerts\]</a>"
				src << msg


			alarms_to_show = list()
			alarms_to_clear = list()
			for(var/i = 1; i < alarm_types_show.len; i++)
				alarm_types_show[i] = 0
			for(var/i = 1; i < alarm_types_clear.len; i++)
				alarm_types_clear[i] = 0

/mob/living/silicon/drop_item()
	return

/mob/living/silicon/emp_act(severity)
	switch(severity)
		if(1)
			src.take_organ_damage(20)
			Stun(rand(5,10))
		if(2)
			src.take_organ_damage(10)
			Stun(rand(1,5))
	flick("noise", src:flash)
	src << "\red <B>*BZZZT*</B>"
	src << "\red Warning: Electromagnetic pulse detected."
	..()

/mob/living/silicon/proc/damage_mob(var/brute = 0, var/fire = 0, var/tox = 0)
	return

/mob/living/silicon/IsAdvancedToolUser()
	return 1

/mob/living/silicon/bullet_act(var/obj/item/projectile/Proj)
	if(!Proj.nodamage)	adjustBruteLoss(Proj.damage)
	Proj.on_hit(src,2)
	return 2

/mob/living/silicon/apply_effect(var/effect = 0,var/effecttype = STUN, var/blocked = 0)
	return 0//The only effect that can hit them atm is flashes and they still directly edit so this works for now
/*
	if(!effect || (blocked >= 2))	return 0
	switch(effecttype)
		if(STUN)
			stunned = max(stunned,(effect/(blocked+1)))
		if(WEAKEN)
			weakened = max(weakened,(effect/(blocked+1)))
		if(PARALYZE)
			paralysis = max(paralysis,(effect/(blocked+1)))
		if(IRRADIATE)
			radiation += min((effect - (effect*getarmor(null, "rad"))), 0)//Rads auto check armor
		if(STUTTER)
			stuttering = max(stuttering,(effect/(blocked+1)))
		if(EYE_BLUR)
			eye_blurry = max(eye_blurry,(effect/(blocked+1)))
		if(DROWSY)
			drowsyness = max(drowsyness,(effect/(blocked+1)))
	updatehealth()
	return 1*/

/proc/islinked(var/mob/living/silicon/robot/bot, var/mob/living/silicon/ai/ai)
	if(!istype(bot) || !istype(ai))
		return 0
	if (bot.connected_ai == ai)
		return 1
	return 0