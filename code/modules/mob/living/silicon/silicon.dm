/mob/living/silicon
	gender = NEUTER
	voice_name = "synthesized voice"
	languages = ROBOT | HUMAN
	var/syndicate = 0
	var/datum/ai_laws/laws = null//Now... THEY ALL CAN ALL HAVE LAWS
	var/list/alarms_to_show = list()
	var/list/alarms_to_clear = list()
	var/designation = ""
	var/obj/item/device/radio/borg/radio = null //AIs dont use this but this is at the silicon level to advoid copypasta in say()

	var/list/alarm_types_show = list("Motion" = 0, "Fire" = 0, "Atmosphere" = 0, "Power" = 0, "Camera" = 0)
	var/list/alarm_types_clear = list("Motion" = 0, "Fire" = 0, "Atmosphere" = 0, "Power" = 0, "Camera" = 0)

	var/lawcheck[1]
	var/ioncheck[1]

	var/sensor_mode = 0 //Determines the current HUD.

/mob/living/silicon/proc/cancelAlarm()
	return

/mob/living/silicon/proc/triggerAlarm()
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
		spawn(3 * 10) // 3 seconds

			if(alarms_to_show.len < 5)
				for(var/msg in alarms_to_show)
					src << msg
			else if(alarms_to_show.len)

				var/msg = "--- "

				if(alarm_types_show["Burglar"])
					msg += "BURGLAR: [alarm_types_show["Burglar"]] alarms detected. - "

				if(alarm_types_show["Motion"])
					msg += "MOTION: [alarm_types_show["Motion"]] alarms detected. - "

				if(alarm_types_show["Fire"])
					msg += "FIRE: [alarm_types_show["Fire"]] alarms detected. - "

				if(alarm_types_show["Atmosphere"])
					msg += "ATMOSPHERE: [alarm_types_show["Atmosphere"]] alarms detected. - "

				if(alarm_types_show["Power"])
					msg += "POWER: [alarm_types_show["Power"]] alarms detected. - "

				if(alarm_types_show["Camera"])
					msg += "CAMERA: [alarm_types_show["Camera"]] alarms detected. - "

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
					msg += "CAMERA: [alarm_types_clear["Camera"]] alarms cleared. - "

				msg += "<A href=?src=\ref[src];showalerts=1'>\[Show Alerts\]</a>"
				src << msg


			alarms_to_show = list()
			alarms_to_clear = list()
			for(var/key in alarm_types_show)
				alarm_types_show[key] = 0
			for(var/key in alarm_types_clear)
				alarm_types_clear[key] = 0

/mob/living/silicon/drop_item()
	return

/mob/living/silicon/emp_act(severity)
	switch(severity)
		if(1)
			src.take_organ_damage(20)
			Stun(8)
		if(2)
			src.take_organ_damage(10)
			Stun(3)
	flick("noise", src:flash)
	src << "<span class='userdanger'>*BZZZT*</span>"
	src << "<span class='danger'>Warning: Electromagnetic pulse detected.</span>"
	..()

/mob/living/silicon/apply_damage(var/damage = 0,var/damagetype = BRUTE, var/def_zone = null, var/blocked = 0)
	blocked = (100-blocked)/100
	if(!damage || (blocked <= 0))	return 0
	switch(damagetype)
		if(BRUTE)
			adjustBruteLoss(damage * blocked)
		if(BURN)
			adjustFireLoss(damage * blocked)
		else
			return 1
	updatehealth()
	return 1

/mob/living/silicon/proc/damage_mob(var/brute = 0, var/fire = 0, var/tox = 0)
	return

/mob/living/silicon/can_inject(var/mob/user, var/error_msg)
	if(error_msg)
		user << "<span class='alert'>Their outer shell is too tough.</span>"
	return 0

/mob/living/silicon/IsAdvancedToolUser()
	return 1

/mob/living/silicon/bullet_act(var/obj/item/projectile/Proj)
	if((Proj.damage_type == BRUTE || Proj.damage_type == BURN))
		adjustBruteLoss(Proj.damage)
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

/mob/living/silicon/Topic(href, href_list)
	if (href_list["lawc"]) // Toggling whether or not a law gets stated by the State Laws verb --NeoFite
		var/L = text2num(href_list["lawc"])
		switch(lawcheck[L+1])
			if ("Yes") lawcheck[L+1] = "No"
			if ("No") lawcheck[L+1] = "Yes"
//		src << text ("Switching Law [L]'s report status to []", lawcheck[L+1])
		checklaws()

	if (href_list["lawi"]) // Toggling whether or not a law gets stated by the State Laws verb --NeoFite
		var/L = text2num(href_list["lawi"])
		switch(ioncheck[L])
			if ("Yes") ioncheck[L] = "No"
			if ("No") ioncheck[L] = "Yes"
//		src << text ("Switching Law [L]'s report status to []", lawcheck[L+1])
		checklaws()

	if (href_list["laws"]) // With how my law selection code works, I changed statelaws from a verb to a proc, and call it through my law selection panel. --NeoFite
		statelaws()

	return


/mob/living/silicon/proc/statelaws()

	src.say("Current Active Laws:")
	//src.laws_sanity_check()
	//src.laws.show_laws(world)
	var/number = 1
	sleep(10)



	if (src.laws.zeroth)
		if (src.lawcheck[1] == "Yes")
			src.say("0. [src.laws.zeroth]")
			sleep(10)

	for (var/index = 1, index <= src.laws.ion.len, index++)
		var/law = src.laws.ion[index]
		var/num = ionnum()
		if (length(law) > 0)
			if (src.ioncheck[index] == "Yes")
				src.say("[num]. [law]")
				sleep(10)

	for (var/index = 1, index <= src.laws.inherent.len, index++)
		var/law = src.laws.inherent[index]

		if (length(law) > 0)
			if (src.lawcheck[index+1] == "Yes")
				src.say("[number]. [law]")
				sleep(10)
			number++


	for (var/index = 1, index <= src.laws.supplied.len, index++)
		var/law = src.laws.supplied[index]

		if (length(law) > 0)
			if(src.lawcheck.len >= number+1)
				if (src.lawcheck[number+1] == "Yes")
					src.say("[number]. [law]")
					sleep(10)
				number++


/mob/living/silicon/proc/checklaws() //Gives you a link-driven interface for deciding what laws the statelaws() proc will share with the crew. --NeoFite

	var/list = "<b>Which laws do you want to include when stating them for the crew?</b><br><br>"

	if (src.laws.zeroth)
		if (!src.lawcheck[1])
			src.lawcheck[1] = "No" //Given Law 0's usual nature, it defaults to NOT getting reported. --NeoFite
		list += {"<A href='byond://?src=\ref[src];lawc=0'>[src.lawcheck[1]] 0:</A> [src.laws.zeroth]<BR>"}

	for (var/index = 1, index <= src.laws.ion.len, index++)
		var/law = src.laws.ion[index]

		if (length(law) > 0)
			if (!src.ioncheck[index])
				src.ioncheck[index] = "Yes"
			list += {"<A href='byond://?src=\ref[src];lawi=[index]'>[src.ioncheck[index]] [ionnum()]:</A> [law]<BR>"}
			src.ioncheck.len += 1

	var/number = 1
	for (var/index = 1, index <= src.laws.inherent.len, index++)
		var/law = src.laws.inherent[index]

		if (length(law) > 0)
			src.lawcheck.len += 1

			if (!src.lawcheck[number+1])
				src.lawcheck[number+1] = "Yes"
			list += {"<A href='byond://?src=\ref[src];lawc=[number]'>[src.lawcheck[number+1]] [number]:</A> [law]<BR>"}
			number++

	for (var/index = 1, index <= src.laws.supplied.len, index++)
		var/law = src.laws.supplied[index]
		if (length(law) > 0)
			src.lawcheck.len += 1
			if (!src.lawcheck[number+1])
				src.lawcheck[number+1] = "Yes"
			list += {"<A href='byond://?src=\ref[src];lawc=[number]'>[src.lawcheck[number+1]] [number]:</A> [law]<BR>"}
			number++
	list += {"<br><br><A href='byond://?src=\ref[src];laws=1'>State Laws</A>"}

	usr << browse(list, "window=laws")

/mob/living/silicon/Bump(atom/movable/AM as mob|obj, yes)  //Allows the AI to bump into mobs if it's itself pushed
	if ((!( yes ) || now_pushing))
		return
	now_pushing = 1
	if(ismob(AM))
		var/mob/tmob = AM
		if(!(tmob.status_flags & CANPUSH))
			now_pushing = 0
			return
	now_pushing = 0
	..()
	if (!istype(AM, /atom/movable))
		return
	if (!now_pushing)
		now_pushing = 1
		if (!AM.anchored)
			var/t = get_dir(src, AM)
			if (istype(AM, /obj/structure/window))
				if(AM:ini_dir == NORTHWEST || AM:ini_dir == NORTHEAST || AM:ini_dir == SOUTHWEST || AM:ini_dir == SOUTHEAST)
					for(var/obj/structure/window/win in get_step(AM,t))
						now_pushing = 0
						return
			step(AM, t)
		now_pushing = null

/mob/living/silicon/put_in_hand_check() // This check is for borgs being able to receive items, not put them in others' hands.
	return 0

// The src mob is trying to place an item on someone
// But the src mob is a silicon!!  Disable.
/mob/living/silicon/stripPanelEquip(obj/item/what, mob/who, slot)
	return 0


/mob/living/silicon/assess_threat() //Secbots won't hunt silicon units
	return -10

/mob/living/silicon/verb/sensor_mode()
	set name = "Set Sensor Augmentation"
	var/sensor_type = input("Please select sensor type.", "Sensor Integration", null) in list("Security", "Medical","Disable")
	switch(sensor_type)
		if ("Security")
			sensor_mode = DATA_HUD_SECURITY
			src << "<span class='notice'>Security records overlay enabled.</span>"
		if ("Medical")
			sensor_mode = DATA_HUD_MEDICAL
			src << "<span class='notice'>Life signs monitor overlay enabled.</span>"
		if ("Disable")
			sensor_mode = 0
			src << "Sensor augmentations disabled."


/mob/living/silicon/attack_alien(mob/living/carbon/alien/humanoid/M as mob)
	if(..())
		var/damage = rand(10, 20)
		if (prob(90))
			add_logs(M, src, "attacked", admin=0)
			playsound(loc, 'sound/weapons/slash.ogg', 25, 1, -1)
			visible_message("<span class='danger'>[M] has slashed at [src]!</span>", \
							"<span class='userdanger'>[M] has slashed at [src]!</span>")
			if(prob(8))
				flick("noise", flash)
			add_logs(M, src, "attacked", admin=0)
			adjustBruteLoss(damage)
			updatehealth()
		else
			playsound(loc, 'sound/weapons/slashmiss.ogg', 25, 1, -1)
			visible_message("<span class='danger'>[M] took a swipe at [src]!</span>", \
							"<span class='userdanger'>[M] took a swipe at [src]!</span>")
	return

/mob/living/silicon/attack_animal(mob/living/simple_animal/M as mob)
	if(..())
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		adjustBruteLoss(damage)
		updatehealth()

/mob/living/silicon/attack_paw(mob/living/user)
	return attack_hand(user)

/mob/living/silicon/attack_larva(mob/living/carbon/alien/larva/L)
	if(L.a_intent == "help")
		visible_message("<span class='notice'>[L] rubs its head against [src].</span>")
	return

/mob/living/silicon/attack_hand(mob/living/carbon/human/M)
	if(..())
		switch(M.a_intent)
			if ("help")
				M.visible_message("<span class='notice'>[M] pets [src]!</span>", \
								"<span class='notice'>You pet [src]!</span>")
			if("grab")
				grabbedby(M)
			else
				playsound(src.loc, 'sound/effects/bang.ogg', 10, 1)
				if (HULK in M.mutations)
					var/damage = rand(10,15)
					adjustBruteLoss(damage)
					add_logs(M, src, "attacked", admin=0)
					playsound(loc, "punch", 25, 1, -1)
					visible_message("<span class='danger'>[M] has punched [src]!</span>", \
							"<span class='userdanger'>[M] has punched [src]!</span>")
					return 1
				else
					visible_message("<span class='danger'>[M] punches [src], but doesn't leave a dent.</span>", \
							"<span class='userdanger'>[M] punches [src], but doesn't leave a dent.!</span>")
	return 0
