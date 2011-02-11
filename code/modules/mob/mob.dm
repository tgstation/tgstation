/mob/proc/Cell()
	set category = "Admin"
	set hidden = 1

	if(!loc) return 0

	var/datum/gas_mixture/environment = loc.return_air()

	var/t = "\blue Coordinates: [x],[y] \n"
	t+= "\red Temperature: [environment.temperature] \n"
	t+= "\blue Nitrogen: [environment.nitrogen] \n"
	t+= "\blue Oxygen: [environment.oxygen] \n"
	t+= "\blue Plasma : [environment.toxins] \n"
	t+= "\blue Carbon Dioxide: [environment.carbon_dioxide] \n"
	for(var/datum/gas/trace_gas in environment.trace_gases)
		usr << "\blue [trace_gas.type]: [trace_gas.moles] \n"

	usr.show_message(t, 1)

// fun if you want to typecast humans/monkeys/etc without writing long path-filled lines.
/proc/ishuman(A)
	if(A && istype(A, /mob/living/carbon/human))
		return 1
	return 0

/proc/isalien(A)
	if(A && istype(A, /mob/living/carbon/alien))
		return 1
	return 0

/proc/ismonkey(A)
	if(A && istype(A, /mob/living/carbon/monkey))
		return 1
	return 0

/proc/isrobot(A)
	if(A && istype(A, /mob/living/silicon/robot))
		return 1
	return 0

/proc/ishivebot(A)
	if(A && istype(A, /mob/living/silicon/hivebot))
		return 1
	return 0

/proc/isAI(A)
	if(A && istype(A, /mob/living/silicon/ai))
		return 1
	return 0

/proc/iscarbon(A)
	if(A && istype(A, /mob/living/carbon))
		return 1
	return 0

/proc/issilicon(A)
	if(A && istype(A, /mob/living/silicon))
		return 1
	return 0

/proc/hsl2rgb(h, s, l)
	return

/proc/ran_zone(zone, probability)

	if (probability == null)
		probability = 90
	if (probability == 100)
		return zone
	switch(zone)
		if("chest")
			if (prob(probability))
				return "chest"
			else
				var/t = rand(1, 15)
				if (t < 3)
					return "head"
				else if (t < 6)
					return "l_arm"
				else if (t < 9)
					return "r_arm"
				else if (t < 13)
					return "groin"
				else if (t < 14)
					return "l_hand"
				else if (t < 15)
					return "r_hand"
				else
					return "chest"

		if("groin")
			if (prob(probability * 0.9))
				return "groin"
			else
				var/t = rand(1, 8)
				if (t < 4)
					return "chest"
				else if (t < 5)
					return "r_leg"
				else if (t < 6)
					return "l_leg"
				else if (t < 7)
					return "l_hand"
				else if (t < 8)
					return "r_hand"
				else
					return "groin"
		if("head")
			if (prob(probability * 0.75))
				return "head"
			else
				if (prob(60))
					return "chest"
				else
					return "head"
		if("l_arm")
			if (prob(probability * 0.75))
				return "l_arm"
			else
				if (prob(60))
					return "chest"
				else
					return "l_arm"
		if("r_arm")
			if (prob(probability * 0.75))
				return "r_arm"
			else
				if (prob(60))
					return "chest"
				else
					return "r_arm"
		if("r_leg")
			if (prob(probability * 0.75))
				return "r_leg"
			else
				if (prob(60))
					return "groin"
				else
					return "r_leg"
		if("l_leg")
			if (prob(probability * 0.75))
				return "l_leg"
			else
				if (prob(60))
					return "groin"
				else
					return "l_leg"
		if("l_hand")
			if (prob(probability * 0.5))
				return "l_hand"
			else
				var/t = rand(1, 8)
				if (t < 2)
					return "l_arm"
				else if (t < 3)
					return "chest"
				else if (t < 4)
					return "groin"
				else if (t < 6)
					return "l_leg"
				else
					return "l_hand"

		if("r_hand")
			if (prob(probability * 0.5))
				return "r_hand"
			else
				var/t = rand(1, 8)
				if (t < 2)
					return "r_arm"
				else if (t < 3)
					return "chest"
				else if (t < 4)
					return "groin"
				else if (t < 6)
					return "r_leg"
				else
					return "r_hand"

		if("l_foot")
			if (prob(probability * 0.25))
				return "l_foot"
			else
				var/t = rand(1, 5)
				if (t < 2)
					return "l_leg"
				else
					if (t < 3)
						return "r_foot"
					else
						return "l_foot"
		if("r_foot")
			if (prob(probability * 0.25))
				return "r_foot"
			else
				var/t = rand(1, 5)
				if (t < 2)
					return "r_leg"
				else
					if (t < 3)
						return "l_foot"
					else
						return "r_foot"
		else
	return

/proc/stars(n, pr)

	if (pr == null)
		pr = 25
	if (pr <= 0)
		return null
	else
		if (pr >= 100)
			return n
	var/te = n
	var/t = ""
	n = length(n)
	var/p = null
	p = 1
	while(p <= n)
		if ((copytext(te, p, p + 1) == " " || prob(pr)))
			t = text("[][]", t, copytext(te, p, p + 1))
		else
			t = text("[]*", t)
		p++
	return t

/proc/stutter(n)
	var/te = html_decode(n)
	var/t = ""
	n = length(n)
	var/p = null
	p = 1
	while(p <= n)
		var/n_letter = copytext(te, p, p + 1)
		if (prob(80))
			if (prob(10))
				n_letter = text("[n_letter][n_letter][n_letter][n_letter]")
			else
				if (prob(20))
					n_letter = text("[n_letter][n_letter][n_letter]")
				else
					if (prob(5))
						n_letter = null
					else
						n_letter = text("[n_letter][n_letter]")
		t = text("[t][n_letter]")
		p++
	return copytext(sanitize(t),1,MAX_MESSAGE_LEN)

/proc/shake_camera(mob/M, duration, strength=1)
	if(!M || !M.client || M.shakecamera)
		return
	spawn(1)
		var/oldeye=M.client.eye
		var/x
		M.shakecamera = 1
		for(x=0; x<duration, x++)
			M.client.eye = locate(dd_range(1,M.loc.x+rand(-strength,strength),world.maxx),dd_range(1,M.loc.y+rand(-strength,strength),world.maxy),M.loc.z)
			sleep(1)
		M.shakecamera = 0
		M.client.eye=oldeye

/proc/findname(msg)
	for(var/mob/M in world)
		if (M.real_name == text("[msg]"))
			return 1
	return 0

/obj/proc/alter_health()
	return 1

/atom/proc/relaymove()
	return

/obj/proc/hide(h)
	return

/obj/item/weapon/grab/proc/throw()
	if(src.affecting)
		var/grabee = src.affecting
		spawn(0)
			del(src)
		return grabee
	return null

/obj/item/weapon/grab/proc/synch()
	if (src.assailant.r_hand == src)
		src.hud1.screen_loc = ui_rhand
	else
		src.hud1.screen_loc = ui_lhand
	return

/obj/item/weapon/grab/process()
	if(!src.assailant || !src.affecting)
		del(src)
		return
	if ((!( isturf(src.assailant.loc) ) || (!( isturf(src.affecting.loc) ) || (src.assailant.loc != src.affecting.loc && get_dist(src.assailant, src.affecting) > 1))))
		//SN src = null
		del(src)
		return
	if (src.assailant.client)
		src.assailant.client.screen -= src.hud1
		src.assailant.client.screen += src.hud1
	if (src.assailant.pulling == src.affecting)
		src.assailant.pulling = null
	if (src.state <= 2)
		src.allow_upgrade = 1
		if ((src.assailant.l_hand && src.assailant.l_hand != src && istype(src.assailant.l_hand, /obj/item/weapon/grab)))
			var/obj/item/weapon/grab/G = src.assailant.l_hand
			if (G.affecting != src.affecting)
				src.allow_upgrade = 0
		if ((src.assailant.r_hand && src.assailant.r_hand != src && istype(src.assailant.r_hand, /obj/item/weapon/grab)))
			var/obj/item/weapon/grab/G = src.assailant.r_hand
			if (G.affecting != src.affecting)
				src.allow_upgrade = 0
		if (src.state == 2)
			var/h = src.affecting.hand
			src.affecting.hand = 0
			src.affecting.drop_item()
			src.affecting.hand = 1
			src.affecting.drop_item()
			src.affecting.hand = h
			for(var/obj/item/weapon/grab/G in src.affecting.grabbed_by)
				if (G.state == 2)
					src.allow_upgrade = 0
				//Foreach goto(341)
		if (src.allow_upgrade)
			src.hud1.icon_state = "reinforce"
		else
			src.hud1.icon_state = "!reinforce"
	else
		if (!( src.affecting.buckled ))
			src.affecting.loc = src.assailant.loc
	if ((src.killing && src.state == 3))
		src.affecting.stunned = max(5, src.affecting.stunned)
		src.affecting.paralysis = max(3, src.affecting.paralysis)
		src.affecting.losebreath = min(src.affecting.losebreath + 2, 3)
	return

/obj/item/weapon/grab/proc/s_click(obj/screen/S as obj)
	if (src.assailant.next_move > world.time)
		return
	if ((!( src.assailant.canmove ) || src.assailant.lying))
		//SN src = null
		del(src)
		return
	switch(S.id)
		if(1.0)
			if (src.state >= 3)
				if (!( src.killing ))
					for(var/mob/O in viewers(src.assailant, null))
						O.show_message(text("\red [] has temporarily tightened his grip on []!", src.assailant, src.affecting), 1)
						//Foreach goto(97)
					src.assailant.next_move = world.time + 10
					src.affecting.stunned = max(2, src.affecting.stunned)
					src.affecting.paralysis = max(1, src.affecting.paralysis)
					src.affecting.losebreath = min(src.affecting.losebreath + 1, 3)
					src.last_suffocate = world.time
					flick("disarm/killf", S)
		else
	return

/obj/item/weapon/grab/proc/s_dbclick(obj/screen/S as obj)
	//if ((src.assailant.next_move > world.time && !( src.last_suffocate < world.time + 2 )))
	//	return
	if ((!( src.assailant.canmove ) || src.assailant.lying))
		del(src)
		return
	switch(S.id)
		if(1.0)
			if (src.state < 2)
				if (!( src.allow_upgrade ))
					return
				if (prob(75))
					for(var/mob/O in viewers(src.assailant, null))
						O.show_message(text("\red [] has grabbed [] aggressively (now hands)!", src.assailant, src.affecting), 1)
					src.state = 2
					src.icon_state = "grabbed1"
				else
					for(var/mob/O in viewers(src.assailant, null))
						O.show_message(text("\red [] has failed to grab [] aggressively!", src.assailant, src.affecting), 1)
					del(src)
					return
			else
				if (src.state < 3)
					if(istype(src.affecting, /mob/living/carbon/human))
						var/mob/living/carbon/human/H = src.affecting
						if(H.mutations & 32)
							src.assailant << "\blue You can't strangle [src.affecting] through all that fat!"
							return

						/*
						//we should be able to strangle the Captain if he is wearing a hat
						for(var/obj/item/clothing/C in list(H.head, H.wear_suit, H.wear_mask, H.w_uniform))
							if(C.body_parts_covered & HEAD)
								src.assailant << "\blue You have to take off [src.affecting]'s [C.name] first!"
								return

						if(istype(H.wear_suit, /obj/item/clothing/suit/space) || istype(H.wear_suit, /obj/item/clothing/suit/armor) || istype(H.wear_suit, /obj/item/clothing/suit/bio_suit) || istype(H.wear_suit, /obj/item/clothing/suit/swat_suit))
							src.assailant << "\blue You can't strangle [src.affecting] through their suit collar!"
							return
						*/
					for(var/mob/O in viewers(src.assailant, null))
						O.show_message(text("\red [] has reinforced his grip on [] (now neck)!", src.assailant, src.affecting), 1)

					src.state = 3
					src.icon_state = "grabbed+1"
					if (!( src.affecting.buckled ))
						src.affecting.loc = src.assailant.loc
					src.hud1.icon_state = "disarm/kill"
					src.hud1.name = "disarm/kill"
				else
					if (src.state >= 3)
						src.killing = !( src.killing )
						if (src.killing)
							for(var/mob/O in viewers(src.assailant, null))
								O.show_message(text("\red [] has tightened his grip on []'s neck!", src.assailant, src.affecting), 1)
							src.assailant.next_move = world.time + 10
							src.affecting.stunned = max(2, src.affecting.stunned)
							src.affecting.paralysis = max(1, src.affecting.paralysis)
							src.affecting.losebreath += 1
							src.hud1.icon_state = "disarm/kill1"
						else
							src.hud1.icon_state = "disarm/kill"
							for(var/mob/O in viewers(src.assailant, null))
								O.show_message(text("\red [] has loosened the grip on []'s neck!", src.assailant, src.affecting), 1)
		else
	return

/obj/item/weapon/grab/New()
	..()
	src.hud1 = new /obj/screen/grab( src )
	src.hud1.icon_state = "reinforce"
	src.hud1.name = "Reinforce Grab"
	src.hud1.id = 1
	src.hud1.master = src
	return

/obj/item/weapon/grab/attack(mob/M as mob, mob/user as mob)
	if (M == src.affecting)
		if (src.state < 3)
			s_dbclick(src.hud1)
		else
			s_click(src.hud1)
		return
	if(M == src.assailant && src.state >= 2)
		if( ( ishuman(user) && (user.mutations & 32) && ismonkey(src.affecting) ) || ( isalien(user) && iscarbon(src.affecting) ) )
			var/mob/living/carbon/attacker = user
			for(var/mob/N in viewers(user, null))
				if(N.client)
					N.show_message(text("\red <B>[user] is attempting to devour [src.affecting]!</B>"), 1)
			if(istype(user, /mob/living/carbon/alien/humanoid/hunter))
				if(!do_mob(user, src.affecting)||!do_after(user, 30)) return
			else
				if(!do_mob(user, src.affecting)||!do_after(user, 100)) return
			for(var/mob/N in viewers(user, null))
				if(N.client)
					N.show_message(text("\red <B>[user] devours [src.affecting]!</B>"), 1)
			src.affecting.loc = user
			attacker.stomach_contents.Add(src.affecting)
			del(src)

/obj/item/weapon/grab/dropped()
	del(src)
	return

/obj/item/weapon/grab/Del()
	del(src.hud1)
	..()
	return

/obj/screen/zone_sel/MouseDown(location, control,params)		//(location, icon_x, icon_y)
	// Changes because of 4.0


	var/list/PL = params2list(params)
	var/icon_x = text2num(PL["icon-x"])
	var/icon_y = text2num(PL["icon-y"])

	if (icon_y < 2)
		return
	else if (icon_y < 5)
		if ((icon_x > 9 && icon_x < 23))
			if (icon_x < 16)
				src.selecting = "r_foot"
			else
				src.selecting = "l_foot"
	else if (icon_y < 11)
		if ((icon_x > 11 && icon_x < 21))
			if (icon_x < 16)
				src.selecting = "r_leg"
			else
				src.selecting = "l_leg"
	else if (icon_y < 12)
		if ((icon_x > 11 && icon_x < 21))
			if (icon_x < 14)
				src.selecting = "r_leg"
			else if (icon_x < 19)
				src.selecting = "groin"
			else
				src.selecting = "l_leg"
		else
			return
	else if (icon_y < 13)
		if ((icon_x > 7 && icon_x < 25))
			if (icon_x < 12)
				src.selecting = "r_hand"
			else if (icon_x < 13)
				src.selecting = "r_leg"
			else if (icon_x < 20)
				src.selecting = "groin"
			else if (icon_x < 21)
				src.selecting = "l_leg"
			else
				src.selecting = "l_hand"
		else
			return
	else if (icon_y < 14)
		if ((icon_x > 7 && icon_x < 25))
			if (icon_x < 12)
				src.selecting = "r_hand"
			else if (icon_x < 21)
				src.selecting = "groin"
			else
				src.selecting = "l_hand"
		else
			return
	else if (icon_y < 16)
		if ((icon_x > 7 && icon_x < 25))
			if (icon_x < 13)
				src.selecting = "r_hand"
			else if (icon_x < 20)
				src.selecting = "chest"
			else
				src.selecting = "l_hand"
		else
			return
	else if (icon_y < 23)
		if ((icon_x > 7 && icon_x < 25))
			if (icon_x < 12)
				src.selecting = "r_arm"
			else if (icon_x < 21)
				src.selecting = "chest"
			else
				src.selecting = "l_arm"
		else
			return
	else if (icon_y < 24)
		if ((icon_x > 11 && icon_x < 21))
			src.selecting = "chest"
		else
			return
	else if (icon_y < 25)
		if ((icon_x > 11 && icon_x < 21))
			if (icon_x < 16)
				src.selecting = "head"
			else if (icon_x < 17)
				src.selecting = "mouth"
			else
				src.selecting = "head"
		else
			return
	else if (icon_y < 26)
		if ((icon_x > 11 && icon_x < 21))
			if (icon_x < 15)
				src.selecting = "head"
			else if (icon_x < 18)
				src.selecting = "mouth"
			else
				src.selecting = "head"
		else
			return
	else if (icon_y < 27)
		if ((icon_x > 11 && icon_x < 21))
			if (icon_x < 15)
				src.selecting = "head"
			else if (icon_x < 16)
				src.selecting = "eyes"
			else if (icon_x < 17)
				src.selecting = "mouth"
			else if (icon_x < 18)
				src.selecting = "eyes"
			else
				src.selecting = "head"
		else
			return
	else if (icon_y < 28)
		if ((icon_x > 11 && icon_x < 21))
			if (icon_x < 14)
				src.selecting = "head"
			else if (icon_x < 19)
				src.selecting = "eyes"
			else
				src.selecting = "head"
		else
			return
	else if (icon_y < 29)
		if ((icon_x > 11 && icon_x < 21))
			if (icon_x < 15)
				src.selecting = "head"
			else if (icon_x < 16)
				src.selecting = "eyes"
			else if (icon_x < 17)
				src.selecting = "head"
			else if (icon_x < 18)
				src.selecting = "eyes"
			else
				src.selecting = "head"
		else
			return
	else if (icon_y < 31)
		if ((icon_x > 11 && icon_x < 21))
			src.selecting = "head"
		else
			return
	else
		return

	overlays = null
	overlays += image("icon" = 'zone_sel.dmi', "icon_state" = text("[]", selecting))

	return

/obj/screen/grab/Click()
	src.master:s_click(src)
	return

/obj/screen/grab/DblClick()
	src.master:s_dbclick(src)
	return

/obj/screen/grab/attack_hand()
	return

/obj/screen/grab/attackby()
	return

/obj/screen/Click(location, control, params)

	var/list/pa = params2list(params)

	switch(src.name)
		if("map")

			usr.clearmap()
		if("maprefresh")
			var/obj/machinery/computer/security/seccomp = usr.machine

			if(seccomp!=null)
				seccomp.drawmap(usr)
			else
				usr.clearmap()

		if("other")
			if (usr.hud_used.show_otherinventory)
				usr.hud_used.show_otherinventory = 0
				usr.client.screen -= usr.hud_used.other
			else
				usr.hud_used.show_otherinventory = 1
				usr.client.screen += usr.hud_used.other

			usr.hud_used.other_update()


		if("act_intent")
			if(pa.Find("left"))
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
			else
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

		if("arrowleft")
			switch(usr.a_intent)
				if("help")
					if(issilicon(usr))
						usr.a_intent = "hurt"
						usr.hud_used.action_intent.icon_state = "harm"
					else
						usr.a_intent = "grab"
						usr.hud_used.action_intent.icon_state = "grab"

				if("disarm")
					usr.a_intent = "help"
					usr.hud_used.action_intent.icon_state = "help"

				if("hurt")
					if(issilicon(usr))
						usr.a_intent = "help"
						usr.hud_used.action_intent.icon_state = "help"
					else
						usr.a_intent = "disarm"
						usr.hud_used.action_intent.icon_state = "disarm"

				if("grab")
					usr.a_intent = "hurt"
					usr.hud_used.action_intent.icon_state = "harm"

		if("arrowright")
			switch(usr.a_intent)
				if("help")
					if(issilicon(usr))
						usr.a_intent = "hurt"
						usr.hud_used.action_intent.icon_state = "harm"
					else
						usr.a_intent = "disarm"
						usr.hud_used.action_intent.icon_state = "disarm"

				if("disarm")
					usr.a_intent = "hurt"
					usr.hud_used.action_intent.icon_state = "harm"

				if("hurt")
					if(issilicon(usr))
						usr.a_intent = "help"
						usr.hud_used.action_intent.icon_state = "help"
					else
						usr.a_intent = "grab"
						usr.hud_used.action_intent.icon_state = "grab"

				if("grab")
					usr.a_intent = "help"
					usr.hud_used.action_intent.icon_state = "help"

		if("mov_intent")
			switch(usr.m_intent)
				if("run")
					usr.m_intent = "walk"
					usr.hud_used.move_intent.icon_state = "walking"
				if("walk")
					usr.m_intent = "run"
					usr.hud_used.move_intent.icon_state = "running"

		if("intent")
			if (!( usr.intent ))
				switch(usr.a_intent)
					if("help")
						usr.intent = "13,15"
					if("disarm")
						usr.intent = "14,15"
					if("hurt")
						usr.intent = "15,15"
					if("grab")
						usr.intent = "12,15"
			else
				usr.intent = null
		if("m_intent")
			if (!( usr.m_int ))
				switch(usr.m_intent)
					if("run")
						usr.m_int = "13,14"
					if("walk")
						usr.m_int = "14,14"
					if("face")
						usr.m_int = "15,14"
			else
				usr.m_int = null
		if("walk")
			usr.m_intent = "walk"
			usr.m_int = "14,14"
		if("face")
			usr.m_intent = "face"
			usr.m_int = "15,14"
		if("run")
			usr.m_intent = "run"
			usr.m_int = "13,14"
		if("hurt")
			usr.a_intent = "hurt"
			usr.intent = "15,15"
		if("grab")
			usr.a_intent = "grab"
			usr.intent = "12,15"
		if("disarm")
			if (istype(usr, /mob/living/carbon/human))
				var/mob/M = usr
				M.a_intent = "disarm"
				M.intent = "14,15"
		if("help")
			usr.a_intent = "help"
			usr.intent = "13,15"
		if("Reset Machine")
			usr.machine = null
		if("internal")
			if ((!( usr.stat ) && usr.canmove && !( usr.restrained() )))
				if (usr.internal)
					usr.internal = null
					if (usr.internals)
						usr.internals.icon_state = "internal0"
				else
					if (!( istype(usr.wear_mask, /obj/item/clothing/mask) ))
						return
					else
						if (istype(usr.back, /obj/item/weapon/tank))
							usr.internal = usr.back
						else if (ishuman(usr) && istype(usr:s_store, /obj/item/weapon/tank))
							usr.internal = usr:s_store
						else if (ishuman(usr) && istype(usr:belt, /obj/item/weapon/tank))
							usr.internal = usr:belt
						else if (istype(usr.l_hand, /obj/item/weapon/tank))
							usr.internal = usr.l_hand
						else if (istype(usr.r_hand, /obj/item/weapon/tank))
							usr.internal = usr.r_hand
						if (usr.internal)
							//for(var/mob/M in viewers(usr, 1))
							//	M.show_message(text("[] is now running on internals.", usr), 1)
							usr << "You are now running on internals."
							if (usr.internals)
								usr.internals.icon_state = "internal1"
		if("pull")
			usr.pulling = null
		if("sleep")
			usr.sleeping = !( usr.sleeping )
		if("rest")
			usr.resting = !( usr.resting )
		if("throw")
			if (!usr.stat && isturf(usr.loc) && !usr.restrained())
				usr:toggle_throw_mode()
		if("drop")
			usr.drop_item_v()
		if("swap")
			usr:swap_hand()
		if("hand")
			usr:swap_hand()
		if("resist")
			if (usr.next_move < world.time)
				return
			usr.next_move = world.time + 20
			if ((!( usr.stat ) && usr.canmove && !( usr.restrained() )))
				for(var/obj/O in usr.requests)
					del(O)
				for(var/obj/item/weapon/grab/G in usr.grabbed_by)
					if (G.state == 1)
						del(G)
					else
						if (G.state == 2)
							if (prob(25))
								for(var/mob/O in viewers(usr, null))
									O.show_message(text("\red [] has broken free of []'s grip!", usr, G.assailant), 1)
								del(G)
						else
							if (G.state == 3)
								if (prob(5))
									for(var/mob/O in viewers(usr, null))
										O.show_message(text("\red [] has broken free of []'s headlock!", usr, G.assailant), 1)
									del(G)
				for(var/mob/O in viewers(usr, null))
					O.show_message(text("\red <B>[] resists!</B>", usr), 1)

			if(usr:handcuffed && usr:canmove && (usr.last_special <= world.time))
				usr.next_move = world.time + 100
				usr.last_special = world.time + 100
				usr << "\red You attempt to remove your handcuffs. (This will take around 2 minutes and you need to stand still)"
				for(var/mob/O in viewers(usr))
					O.show_message(text("\red <B>[] attempts to remove the handcuffs!</B>", usr), 1)
				spawn(0)
					if(do_after(usr, 1200))
						if(!usr:handcuffed) return
						for(var/mob/O in viewers(usr))
							O.show_message(text("\red <B>[] manages to remove the handcuffs!</B>", usr), 1)
						usr << "\blue You successfully remove your handcuffs."
						usr:handcuffed:loc = usr:loc
						usr:handcuffed = null
		if("module")
			if(istype(usr, /mob/living/silicon/robot)||istype(usr, /mob/living/silicon/hivebot))
				if(usr:module)
					return
				usr:pick_module()

		if("radio")
			if(istype(usr, /mob/living/silicon/robot)||istype(usr, /mob/living/silicon/hivebot))
				usr:radio_menu()
		if("panel")
			if(istype(usr, /mob/living/silicon/robot)||istype(usr, /mob/living/silicon/hivebot))
				usr:installed_modules()

		if("store")
			if(istype(usr, /mob/living/silicon/robot)||istype(usr, /mob/living/silicon/hivebot))
				usr:uneq_active()

		if("module1")
			if(usr:module_state_1)
				if(usr:module_active != usr:module_state_1)
					usr:inv1.icon_state = "inv1 +a"
					usr:inv2.icon_state = "inv2"
					usr:inv3.icon_state = "inv3"
					usr:module_active = usr:module_state_1
				else
					usr:inv1.icon_state = "inv1"
					usr:module_active = null

		if("module2")
			if(usr:module_state_2)
				if(usr:module_active != usr:module_state_2)
					usr:inv1.icon_state = "inv1"
					usr:inv2.icon_state = "inv2 +a"
					usr:inv3.icon_state = "inv3"
					usr:module_active = usr:module_state_2
				else
					usr:inv2.icon_state = "inv2"
					usr:module_active = null

		if("module3")
			if(usr:module_state_3)
				if(usr:module_active != usr:module_state_3)
					usr:inv1.icon_state = "inv1"
					usr:inv2.icon_state = "inv2"
					usr:inv3.icon_state = "inv3 +a"
					usr:module_active = usr:module_state_3
				else
					usr:inv3.icon_state = "inv3"
					usr:module_active = null

		else
			src.DblClick()
	return

/obj/screen/attack_hand(mob/user as mob, using)
	user.db_click(src.name, using)
	return

/obj/screen/attack_paw(mob/user as mob, using)
	user.db_click(src.name, using)
	return

/obj/equip_e/proc/process()
	return

/obj/equip_e/proc/done()
	return

/obj/equip_e/New()
	if (!ticker)
		del(src)
		return
	spawn(100)
		del(src)
		return
	..()
	return

/mob/living/carbon/human/Topic(href, href_list)
	if (href_list["mach_close"])
		var/t1 = text("window=[]", href_list["mach_close"])
		src.machine = null
		src << browse(null, t1)
	if ((href_list["item"] && !( usr.stat ) && usr.canmove && !( usr.restrained() ) && in_range(src, usr) && ticker)) //if game hasn't started, can't make an equip_e
		var/obj/equip_e/human/O = new /obj/equip_e/human(  )
		O.source = usr
		O.target = src
		O.item = usr.equipped()
		O.s_loc = usr.loc
		O.t_loc = src.loc
		O.place = href_list["item"]
		src.requests += O
		spawn( 0 )
			O.process()
			return
	..()
	return

/mob/proc/show_message(msg, type, alt, alt_type)
	if(!src.client)	return
	if (type)
		if ((type & 1 && (src.sdisabilities & 1 || (src.blinded || src.paralysis))))
			if (!( alt ))
				return
			else
				msg = alt
				type = alt_type
		if ((type & 2 && (src.sdisabilities & 4 || src.ear_deaf)))
			if (!( alt ))
				return
			else
				msg = alt
				type = alt_type
				if ((type & 1 && src.sdisabilities & 1))
					return
	// Added voice muffling for Issue 41.
	if (src.stat == 1 || src.sleeping > 0)
		src << "<I>... You can almost hear someone talking ...</I>"
	else
		src << msg
	return

// Show a message to all mobs in sight of this one
// This would be for visible actions by the src mob
// message is the message output to anyone who can see e.g. "[src] does something!"
// self_message (optional) is what the src mob sees  e.g. "You do something!"
// blind_message (optional) is what blind people will hear e.g. "You hear something!"

/mob/visible_message(var/message, var/self_message, var/blind_message)
	for(var/mob/M in viewers(src))
		var/msg = message
		if(self_message && M==src)
			msg = self_message
		M.show_message( msg, 1, blind_message, 2)

// Show a message to all mobs in sight of this atom
// Use for objects performing visible actions
// message is output to anyone who can see, e.g. "The [src] does something!"
// blind_message (optional) is what blind people will hear e.g. "You hear something!"
/atom/proc/visible_message(var/message, var/blind_message)
	for(var/mob/M in viewers(src))
		M.show_message( message, 1, blind_message, 2)


/mob/proc/findname(msg)
	for(var/mob/M in world)
		if (M.real_name == text("[]", msg))
			return M
	return 0

/mob/proc/movement_delay()
	return 0

/mob/proc/Life()
	return

/mob/proc/update_clothing()
	return

/mob/proc/death(gibbed)
	src.timeofdeath = world.time
	return ..(gibbed)

/mob/proc/restrained()
	if (src.handcuffed)
		return 1
	return

/mob/proc/db_click(text, t1)
	var/obj/item/weapon/W = src.equipped()
	switch(text)
		if("mask")
			if (src.wear_mask)
				return
			if (!( istype(W, /obj/item/clothing/mask) ))
				return
			src.u_equip(W)
			src.wear_mask = W
			W.equipped(src, text)
		if("back")
			if ((src.back || !( istype(W, /obj/item/weapon) )))
				return
			if (!( W.flags & 1 ))
				return
			src.u_equip(W)
			src.back = W
			W.equipped(src, text)
		else
	return


/mob/living/carbon/proc/swap_hand()
	src.hand = !( src.hand )
	if (!( src.hand ))
		src.hands.dir = NORTH
	else
		src.hands.dir = SOUTH
	return

/mob/proc/drop_item_v()
	if (src.stat == 0)
		drop_item()
	return

/mob/proc/drop_from_slot(var/obj/item/item)
	if(!item)
		return
	if(!(item in src.contents))
		return
	u_equip(item)
	if (src.client)
		src.client.screen -= item
	if (item)
		item.loc = src.loc
		item.dropped(src)
		if (item)
			item.layer = initial(item.layer)
	var/turf/T = get_turf(src.loc)
	T.Entered(item)
	return

/mob/proc/drop_item()
	var/obj/item/W = src.equipped()
	if (W)
		u_equip(W)
		if (src.client)
			src.client.screen -= W
		if (W)
			W.loc = src.loc
			W.dropped(src)
			if (W)
				W.layer = initial(W.layer)
		var/turf/T = get_turf(src.loc)
		if (T)
			T.Entered(W)
	return

/mob/proc/before_take_item(var/obj/item/item)
	u_equip(item)
	if (src.client)
		src.client.screen -= item
	src.update_clothing()
	return

/mob/proc/get_active_hand()
	if (src.hand)
		return src.l_hand
	else
		return src.r_hand

/mob/proc/get_inactive_hand()
	if ( ! src.hand)
		return src.l_hand
	else
		return src.r_hand

/mob/proc/put_in_hand(var/obj/item/I)
	if(!I) return
	I.loc = src
	if (src.hand)
		src.l_hand = I
	else
		src.r_hand = I
	I.layer = 20
	src.update_clothing()

/mob/proc/put_in_inactive_hand(var/obj/item/I)
	I.loc = src
	if (!src.hand)
		src.l_hand = I
	else
		src.r_hand = I
	I.layer = 20
	src.update_clothing()

/mob/proc/reset_view(atom/A)
	if (src.client)
		if (istype(A, /atom/movable))
			src.client.perspective = EYE_PERSPECTIVE
			src.client.eye = A
		else
			if (isturf(src.loc))
				src.client.eye = src.client.mob
				src.client.perspective = MOB_PERSPECTIVE
			else
				src.client.perspective = EYE_PERSPECTIVE
				src.client.eye = src.loc
	return

/mob/proc/equipped()
	if(issilicon(src))
		if(ishivebot(src)||isrobot(src))
			if(src:module_active)
				return src:module_active
	else
		if (src.hand)
			return src.l_hand
		else
			return src.r_hand
		return

/mob/proc/show_inv(mob/user as mob)
	user.machine = src
	var/dat = text("<TT>\n<B><FONT size=3>[]</FONT></B><BR>\n\t<B>Head(Mask):</B> <A href='?src=\ref[];item=mask'>[]</A><BR>\n\t<B>Left Hand:</B> <A href='?src=\ref[];item=l_hand'>[]</A><BR>\n\t<B>Right Hand:</B> <A href='?src=\ref[];item=r_hand'>[]</A><BR>\n\t<B>Back:</B> <A href='?src=\ref[];item=back'>[]</A><BR>\n\t[]<BR>\n\t[]<BR>\n\t[]<BR>\n\t<A href='?src=\ref[];item=pockets'>Empty Pockets</A><BR>\n<A href='?src=\ref[];mach_close=mob[]'>Close</A><BR>\n</TT>", src.name, src, (src.wear_mask ? text("[]", src.wear_mask) : "Nothing"), src, (src.l_hand ? text("[]", src.l_hand) : "Nothing"), src, (src.r_hand ? text("[]", src.r_hand) : "Nothing"), src, (src.back ? text("[]", src.back) : "Nothing"), ((istype(src.wear_mask, /obj/item/clothing/mask) && istype(src.back, /obj/item/weapon/tank) && !( src.internal )) ? text(" <A href='?src=\ref[];item=internal'>Set Internal</A>", src) : ""), (src.internal ? text("<A href='?src=\ref[];item=internal'>Remove Internal</A>", src) : ""), (src.handcuffed ? text("<A href='?src=\ref[];item=handcuff'>Handcuffed</A>", src) : text("<A href='?src=\ref[];item=handcuff'>Not Handcuffed</A>", src)), src, user, src.name)
	user << browse(dat, text("window=mob[];size=325x500", src.name))
	onclose(user, "mob[src.name]")
	return

/mob/proc/u_equip(W as obj)
	if (W == src.r_hand)
		src.r_hand = null
	else if (W == src.l_hand)
		src.l_hand = null
	else if (W == src.handcuffed)
		src.handcuffed = null
	else if (W == src.back)
		src.back = null
	else if (W == src.wear_mask)
		src.wear_mask = null

	update_clothing()

/mob/proc/ret_grab(obj/list_container/mobl/L as obj, flag)
	if ((!( istype(src.l_hand, /obj/item/weapon/grab) ) && !( istype(src.r_hand, /obj/item/weapon/grab) )))
		if (!( L ))
			return null
		else
			return L.container
	else
		if (!( L ))
			L = new /obj/list_container/mobl( null )
			L.container += src
			L.master = src
		if (istype(src.l_hand, /obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = src.l_hand
			if (!( L.container.Find(G.affecting) ))
				L.container += G.affecting
				G.affecting.ret_grab(L, 1)
		if (istype(src.r_hand, /obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = src.r_hand
			if (!( L.container.Find(G.affecting) ))
				L.container += G.affecting
				if (G.affecting)
					G.affecting.ret_grab(L, 1)
		if (!( flag ))
			if (L.master == src)
				var/list/temp = list(  )
				temp += L.container
				//L = null
				del(L)
				return temp
			else
				return L.container
	return

/mob/verb/mode()
	set name = "Equipment Mode"

	set src = usr

	var/obj/item/W = src.equipped()
	if (W)
		W.attack_self(src)
	return

/*
/mob/verb/dump_source()

	var/master = "<PRE>"
	for(var/t in typesof(/area))
		master += text("[]\n", t)
		//Foreach goto(26)
	src << browse(master)
	return
*/

/mob/verb/memory()
	set name = "Notes"
	if(mind)
		mind.show_memory(src)
	else
		src << "The game appears to have misplaced your mind datum, so we can't show you your notes."

/mob/verb/add_memory(msg as message)
	set name = "Add Note"

	msg = copytext(msg, 1, MAX_MESSAGE_LEN)
	msg = sanitize(msg)

	mind.store_memory(msg)

/mob/proc/store_memory(msg as message, popup, sane = 1)
	msg = copytext(msg, 1, MAX_MESSAGE_LEN)

	if (sane)
		msg = sanitize(msg)

	if (length(src.memory) == 0)
		src.memory += msg
	else
		src.memory += "<BR>[msg]"

	if (popup)
		src.memory()

/mob/verb/help()
	set name = "Help"
	src << browse('help.html', "window=help")
	return

/mob/verb/abandon_mob()
	set name = "Respawn"

	if (!( abandon_allowed ))
		return
	if ((src.stat != 2 || !( ticker )))
		usr << "\blue <B>You must be dead to use this!</B>"
		return

	log_game("[usr.name]/[usr.key] used abandon mob.")

	usr << "\blue <B>Please roleplay correctly!</B>"

	if(!src.client)
		log_game("[usr.key] AM failed due to disconnect.")
		return
	for(var/obj/screen/t in usr.client.screen)
		if (t.loc == null)
			//t = null
			del(t)
	if(!src.client)
		log_game("[usr.key] AM failed due to disconnect.")
		return

	var/mob/new_player/M = new /mob/new_player()
	if(!src.client)
		log_game("[usr.key] AM failed due to disconnect.")
		del(M)
		return



	if(src.client && src.client.holder && (src.client.holder.state == 2))
		src.client.admin_play()
		return

	M.key = src.client.key
	M.Login()
	return

/mob/verb/cmd_rules()
	set name = "Rules"
	src << browse(rules, "window=rules;size=480x320")

/mob/verb/changes()
	set name = "Changelog"
	if (src.client)
		src << browse_rsc('postcardsmall.jpg')
		src << browse_rsc('somerights20.png')
		src << browse_rsc('88x31.png')
		src << browse('changelog.html', "window=changes;size=400x650")
		src.client.changes = 1

/mob/verb/succumb()
	set hidden = 1

	if ((src.health < 0 && src.health > -95.0))
		src.oxyloss += src.health + 200
		src.health = 100 - src.oxyloss - src.toxloss - src.fireloss - src.bruteloss
		src << "\blue You have given up life and succumbed to death."

/mob/verb/observe()
	set name = "Observe"
	var/is_admin = 0

	if (src.client.holder && src.client.holder.level >= 1 && ( src.client.holder.state == 2 || src.client.holder.level > 3 ))
		is_admin = 1
	else if (istype(src, /mob/new_player) || src.stat != 2)
		usr << "\blue You must be observing to use this!"
		return

	if (is_admin && src.stat == 2)
		is_admin = 0

	var/list/names = list()
	var/list/namecounts = list()
	var/list/creatures = list()

	for (var/obj/item/weapon/disk/nuclear/D in world)
		var/name = "Nuclear Disk"
		if (name in names)
			namecounts[name]++
			name = "[name] ([namecounts[name]])"
		else
			names.Add(name)
			namecounts[name] = 1
		creatures[name] = D

	for (var/obj/machinery/singularity/S in world)
		var/name = "Singularity"
		if (name in names)
			namecounts[name]++
			name = "[name] ([namecounts[name]])"
		else
			names.Add(name)
			namecounts[name] = 1
		creatures[name] = S

	for (var/obj/machinery/bot/B in world)
		var/name = "BOT: [B.name]"
		if (name in names)
			namecounts[name]++
			name = "[name] ([namecounts[name]])"
		else
			names.Add(name)
			namecounts[name] = 1
		creatures[name] = B
/*
	for (var/mob/living/silicon/decoy/D in world)
		var/name = "[D.name]"
		if (name in names)
			namecounts[name]++
			name = "[name] ([namecounts[name]])"
		else
			names.Add(name)
			namecounts[name] = 1
		creatures[name] = D
*/



//THIS IS HOW YOU ADD OBJECTS TO BE OBSERVED

	creatures += getmobs()
//THIS IS THE MOBS PART: LOOK IN HELPERS.DM

	src.client.perspective = EYE_PERSPECTIVE

	var/eye_name = null

	if (is_admin)
		eye_name = input("Please, select a player!", "Admin Observe", null, null) as null|anything in creatures
	else
		eye_name = input("Please, select a player!", "Observe", null, null) as null|anything in creatures

	if (!eye_name)
		return

	var/mob/eye = creatures[eye_name]
	if (is_admin)
		if (eye)
			src.reset_view(eye)
			client.adminobs = 1
			if(eye == src.client.mob)
				client.adminobs = 0
		else
			src.reset_view(null)
			client.adminobs = 0
	else
		if(ticker)
//		 world << "there's a ticker"
			if(ticker.mode.name == "AI malfunction")
//				world << "ticker says its malf"
				var/datum/game_mode/malfunction/malf = ticker.mode
				for (var/datum/mind/B in malf.malf_ai)
//					world << "comparing [B.current] to [eye]"
					if (B.current == eye)
						for (var/mob/living/silicon/decoy/D in world)
							if (eye)
								eye = D
		if (eye)
			src.client.eye = eye
		else
			src.client.eye = src.client.mob

/mob/verb/cancel_camera()
	set name = "Cancel Camera View"
	src.reset_view(null)
	src.machine = null
	if(istype(src, /mob/living))
		if(src:cameraFollow)
			src:cameraFollow = null

/mob/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group || (height==0)) return 1

	if(ismob(mover))
		var/mob/moving_mob = mover
		if ((src.other_mobs && moving_mob.other_mobs))
			return 1
		return (!mover.density || !src.density || src.lying)
	else
		return (!mover.density || !src.density || src.lying)
	return

/mob/dead/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	return 1

/mob/Topic(href, href_list)
	if(href_list["mach_close"])
		var/t1 = text("window=[href_list["mach_close"]]")
		src.machine = null
		src << browse(null, t1)

	if(href_list["priv_msg"])
		var/mob/M = locate(href_list["priv_msg"])
		if(M)
			if(src.muted)
				src << "You are muted have a nice day"
				return
			if (!( ismob(M) ))
				return
			var/t = input("Message:", text("Private message to [M.key]"))  as text
			if (!( t ))
				return
			if (!usr) return
			if (usr.client && usr.client.holder)
				M << "\red Admin PM from-<b>[key_name(usr, M, 0)]</b>: [t]"
				usr << "\blue Admin PM to-<b>[key_name(M, usr, 1)]</b>: [t]"
			else
				if (M)
					if (M.client && M.client.holder)
						M << "\blue Reply PM from-<b>[key_name(usr, M, 1)]</b>: [t]"
					else
						M << "\red Reply PM from-<b>[key_name(usr, M, 0)]</b>: [t]"
					usr << "\blue Reply PM to-<b>[key_name(M, usr, 0)]</b>: [t]"

			log_admin("PM: [key_name(usr)]->[key_name(M)] : [t]")

			//we don't use message_admins here because the sender/receiver might get it too
			for (var/mob/K in world)
				if(K && usr)
					if(K.client && K.client.holder && K.key != usr.key && K.key != M.key)
						K << "<b><font color='blue'>PM: [key_name(usr, K)]->[key_name(M, K)]:</b> \blue [t]</font>"
	..()
	return

/mob/proc/get_damage()
	return src.health

/mob/MouseDrop(mob/M as mob)
	..()
	if(M != usr) return
	if(usr == src) return
	if(get_dist(usr,src) > 1) return
	if(istype(M,/mob/living/silicon/ai)) return
	if(LinkBlocked(usr.loc,src.loc)) return
	src.show_inv(usr)

/mob/bullet_act(flag)
	if (flag == PROJECTILE_BULLET)
		if (istype(src, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = src
			var/dam_zone = pick("chest", "chest", "chest", "groin", "head")
			if (H.organs[text("[]", dam_zone)])
				var/datum/organ/external/affecting = H.organs[text("[]", dam_zone)]
				if (affecting.take_damage(51, 0))
					H.UpdateDamageIcon()
				else
					H.UpdateDamage()
		else
			src.bruteloss += 51
		src.updatehealth()
		if (prob(80) && src.weakened <= 2)
			src.weakened = 2
	else if (flag == PROJECTILE_TASER)
		if (prob(75) && src.stunned <= 10)
			src.stunned = 10
		else
			src.weakened = 10
	else if (flag == PROJECTILE_DART)
		src.weakened += 5
		src.toxloss += 10
	else if(flag == PROJECTILE_LASER)
		if (istype(src, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = src
			var/dam_zone = pick("chest", "chest", "chest", "groin", "head")
			if (H.organs[text("[]", dam_zone)])
				var/datum/organ/external/affecting = H.organs[text("[]", dam_zone)]
				if (affecting.take_damage(20, 0))
					H.UpdateDamageIcon()
				else
					H.UpdateDamage()
		else
			src.bruteloss += 20
		src.updatehealth()
		if (prob(25) && src.stunned <= 2)
			src.stunned = 2
	else if(flag == PROJECTILE_PULSE)
		if (istype(src, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = src
			var/dam_zone = pick("chest", "chest", "chest", "groin", "head")
			if (H.organs[text("[]", dam_zone)])
				var/datum/organ/external/affecting = H.organs[text("[]", dam_zone)]
				if (affecting.take_damage(40, 0))
					H.UpdateDamageIcon()
				else
					H.UpdateDamage()
		else
			src.bruteloss += 40
		src.updatehealth()
		if (prob(50))
			src.stunned = min(src.stunned, 5)
	else if(flag == PROJECTILE_BOLT)
		src.toxloss += 3
		src.radiation += 100
		src.updatehealth()
		src.stuttering += 5
		src.drowsyness += 5
		if (prob(10))
			src.weakened = min(src.weakened, 2)
	return


/atom/movable/Move(NewLoc, direct)
	if (direct & direct - 1)
		if (direct & 1)
			if (direct & 4)
				if (step(src, NORTH))
					step(src, EAST)
				else
					if (step(src, EAST))
						step(src, NORTH)
			else
				if (direct & 8)
					if (step(src, NORTH))
						step(src, WEST)
					else
						if (step(src, WEST))
							step(src, NORTH)
		else
			if (direct & 2)
				if (direct & 4)
					if (step(src, SOUTH))
						step(src, EAST)
					else
						if (step(src, EAST))
							step(src, SOUTH)
				else
					if (direct & 8)
						if (step(src, SOUTH))
							step(src, WEST)
						else
							if (step(src, WEST))
								step(src, SOUTH)
	else
		. = ..()
	return

/atom/movable/verb/pull()
	set src in oview(1)

	if (!( usr ))
		return
	if (!( src.anchored ))
		usr.pulling = src
	return

/atom/verb/examine()
	set src in oview(12)	//make it work from farther away

	if (!( usr ))
		return
	usr << "This is \an [src.name]."
	usr << src.desc
	// *****RM
	//usr << "[src.name]: Dn:[density] dir:[dir] cont:[contents] icon:[icon] is:[icon_state] loc:[loc]"
	return

/client/North()
	..()

/client/South()
	..()

/client/West()
	..()

/client/East()
	..()

/client/Northeast()
	if(istype(src.mob, /mob/living/carbon))
		src.mob:swap_hand()
	return

/client/Southeast()
	var/obj/item/weapon/W = src.mob.equipped()
	if (W)
		W.attack_self(src.mob)
	return

/client/Northwest()
	src.mob.drop_item_v()
	return

/client/Center()
	if (isobj(src.mob.loc))
		var/obj/O = src.mob.loc
		if (src.mob.canmove)
			return O.relaymove(src.mob, 16)
	return

/client/Move(n, direct)
	if(src.mob.control_object)					// Hacking in something to control objects -- TLE
		src.mob.control_object.Move(get_step(src.mob.control_object, direct),direct)
	if(istype(src.mob, /mob/dead/observer))
		return src.mob.Move(n,direct)
	if (src.moving)
		return 0
	if (world.time < src.move_delay)
		return
	if (!( src.mob ))
		return
	if (src.mob.stat == 2)
		return
	if (src.mob.incorporeal_move)
		src.mob.dir = direct
		src.mob.loc = get_step(src.mob, direct)
		//return src.mob.Move(get_step(src.mob,direct))
		return
	if(istype(src.mob, /mob/living/silicon/ai))
		return AIMove(n,direct,src.mob)
	if(istype(src.mob, /mob/living/silicon/hive_mainframe))
		return MainframeMove(n,direct,src.mob)
	if (src.mob.monkeyizing)
		return

	var/is_monkey = istype(src.mob, /mob/living/carbon/monkey)
	if (locate(/obj/item/weapon/grab, locate(/obj/item/weapon/grab, src.mob.grabbed_by.len)))
		var/list/grabbing = list(  )
		if (istype(src.mob.l_hand, /obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = src.mob.l_hand
			grabbing += G.affecting
		if (istype(src.mob.r_hand, /obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = src.mob.r_hand
			grabbing += G.affecting
		for(var/obj/item/weapon/grab/G in src.mob.grabbed_by)
			if (G.state == 1)
				if (!( grabbing.Find(G.assailant) ))
					del(G)
			else
				if (G.state == 2)
					src.move_delay = world.time + 10
					if ((prob(25) && (!( is_monkey ) || prob(25))))
						mob.visible_message("\red [mob] has broken free of [G.assailant]'s grip!")
						del(G)
					else
						return
				else
					if (G.state == 3)
						src.move_delay = world.time + 10
						if ((prob(5) && !( is_monkey ) || prob(25)))
							mob.visible_message("\red [mob] has broken free of [G.assailant]'s headlock!")
							del(G)
						else
							return
	if (src.mob.canmove)

		if(src.mob.m_intent == "face")
			src.mob.dir = direct

		var/j_pack = 0
		if ((istype(src.mob.loc, /turf/space)))
			if (!( src.mob.restrained() ))
				if (!( (locate(/obj/grille) in oview(1, src.mob)) || (locate(/turf/simulated) in oview(1, src.mob)) || (locate(/obj/lattice) in oview(1, src.mob)) ))
					if (istype(src.mob.back, /obj/item/weapon/tank/jetpack))
						var/obj/item/weapon/tank/jetpack/J = src.mob.back
						j_pack = J.allow_thrust(0.01, src.mob)
						if(j_pack)
							src.mob.inertia_dir = 0
						if (!( j_pack ))
							return 0
					else
						return 0
			else
				return 0


		if (isturf(src.mob.loc))
			src.move_delay = world.time
			if ((j_pack && j_pack < 1))
				src.move_delay += 5
			switch(src.mob.m_intent)
				if("run")
					if (src.mob.drowsyness > 0)
						src.move_delay += 6
					src.move_delay += 1
				if("face")
					src.mob.dir = direct
					return
				if("walk")
					src.move_delay += 7


			src.move_delay += src.mob.movement_delay()

			if (src.mob.restrained())
				for(var/mob/M in range(src.mob, 1))
					if (((M.pulling == src.mob && (!( M.restrained() ) && M.stat == 0)) || locate(/obj/item/weapon/grab, src.mob.grabbed_by.len)))
						src << "\blue You're restrained! You can't move!"
						return 0
			src.moving = 1
			if (locate(/obj/item/weapon/grab, src.mob))
				src.move_delay = max(src.move_delay, world.time + 7)
				var/list/L = src.mob.ret_grab()
				if (istype(L, /list))
					if (L.len == 2)
						L -= src.mob
						var/mob/M = L[1]
						if ((get_dist(src.mob, M) <= 1 || M.loc == src.mob.loc))
							var/turf/T = src.mob.loc
							. = ..()
							if (isturf(M.loc))
								var/diag = get_dir(src.mob, M)
								if ((diag - 1) & diag)
								else
									diag = null
								if ((get_dist(src.mob, M) > 1 || diag))
									step(M, get_dir(M.loc, T))
					else
						for(var/mob/M in L)
							M.other_mobs = 1
							if (src.mob != M)
								M.animate_movement = 3
						for(var/mob/M in L)
							spawn( 0 )
								step(M, direct)
								return
							spawn( 1 )
								M.other_mobs = null
								M.animate_movement = 2
								return
			else
				if(src.mob.confused)
					step(src.mob, pick(cardinal))
				else
					. = ..()
			src.moving = null
			return .
		else
			if (isobj(src.mob.loc) || ismob(src.mob.loc))
				var/atom/O = src.mob.loc
				if (src.mob.canmove)
					return O.relaymove(src.mob, direct)
	else
		return
	return

/client/New()
	if(findtextEx(src.key, "Telnet @"))
		src << "Sorry, this game does not support Telnet."
		del(src)
	var/isbanned = CheckBan(src)
	if (isbanned)
		log_access("Failed Login: [src] - Banned")
		message_admins("\blue Failed Login: [src] - Banned")
		alert(src,"You have been banned.\nReason : [isbanned]","Ban","Ok")
		del(src)


	if (((world.address == src.address || !(src.address)) && !(host)))
		host = src.key
		world.update_status()

	..()

	if (join_motd)
		src << "<div class=\"motd\">[join_motd]</div>"

	src.authorize()
	//src.goonauth() -- Skie, commented out because not goons anymore.
	///src.beta_tester_auth()

	src.update_world()

//new admin bit - Nannek

	if (admins.Find(src.ckey))
		src.holder = new /obj/admins(src)
		src.holder.rank = admins[src.ckey]
		update_admins(admins[src.ckey])

	if (ticker && ticker.mode && ticker.mode.name =="sandbox" && src.authenticated)
		mob.CanBuild()
		if(src.holder  && (src.holder.level >= 3))
			src.verbs += /mob/proc/Delete

/client/Del()
	spawn(0)
		if(src.holder)
			del(src.holder)
	return ..()

/mob/proc/can_use_hands()
	if(src.handcuffed)
		return 0
	if(src.buckled && istype(src.buckled, /obj/stool/bed)) // buckling does not restrict hands
		return 0
	return ..()

/mob/proc/is_active()
	return (0 >= usr.stat)

/mob/proc/see(message)
	if(!src.is_active())
		return 0
	src << message
	return 1

/mob/proc/show_viewers(message)
	for(var/mob/M in viewers())
		M.see(message)

/mob/proc/updatehealth()
	if (src.nodamage == 0)
		src.health = 100 - src.oxyloss - src.toxloss - src.fireloss - src.bruteloss
	else
		src.health = 100
		src.stat = 0

//sort of a legacy burn method for /electrocute, /shock, and the e_chair
/mob/proc/burn_skin(burn_amount)
	if(istype(src, /mob/living/carbon/human))
		//world << "DEBUG: burn_skin(), mutations=[mutations]"
		if (src.mutations & 2) //fireproof
			return 0
		var/mob/living/carbon/human/H = src	//make this damage method divide the damage to be done among all the body parts, then burn each body part for that much damage. will have better effect then just randomly picking a body part
		var/divided_damage = (burn_amount)/(H.organs.len)
		var/datum/organ/external/affecting = null
		var/extradam = 0	//added to when organ is at max dam
		for(var/A in H.organs)
			if(!H.organs[A])	continue
			affecting = H.organs[A]
			if(!istype(affecting, /datum/organ/external))	continue
			if(affecting.take_damage(0, divided_damage+extradam))
				extradam = 0
			else
				extradam += divided_damage
		H.UpdateDamageIcon()
		H.updatehealth()
		return 1
	else if(istype(src, /mob/living/carbon/monkey))
		if (src.mutations & 2) //fireproof
			return 0
		var/mob/living/carbon/monkey/M = src
		M.fireloss += burn_amount
		M.updatehealth()
		return 1
	else if(istype(src, /mob/living/silicon/ai))
		return 0

/mob/proc/adjustBodyTemp(actual, desired, incrementboost)
	var/temperature = actual
	var/difference = abs(actual-desired)	//get difference
	var/increments = difference/10 //find how many increments apart they are
	var/change = increments*incrementboost	// Get the amount to change by (x per increment)

	// Too cold
	if(actual < desired)
		temperature += change
		if(actual > desired)
			temperature = desired
	// Too hot
	if(actual > desired)
		temperature -= change
		if(actual < desired)
			temperature = desired
//	if(istype(src, /mob/living/carbon/human))
//		world << "[src] ~ [src.bodytemperature] ~ [temperature]"
	return temperature

//This is the proc for gibbing a mob. Cannot gib ghosts. Removed the medal reference,
//added different sort of gibs and animations. N
/mob/proc/gib()

	if (istype(src, /mob/dead/observer))
		var/virus = src.virus
		gibs(src.loc, virus)
		return
	src.death(1)
	var/atom/movable/overlay/animation = null
	src.monkeyizing = 1
	src.canmove = 0
	src.icon = null
	src.invisibility = 101

	animation = new(src.loc)
	animation.icon_state = "blank"
	animation.icon = 'mob.dmi'
	animation.master = src
	if(ishuman(src))
		flick("gibbed-h", animation)
	else if(ismonkey(src))
		flick("gibbed-m", animation)
	else if(isalien(src))
		flick("gibbed-a", animation)
	else
		flick("gibbed-r", animation)

	if (src.client)
		var/mob/dead/observer/newmob

		newmob = new/mob/dead/observer(src)
		src:client:mob = newmob
		if (src.mind)
			src.mind.transfer_to(newmob)

		var/virus = src.virus
		if (istype(src, /mob/living/silicon))
			robogibs(src.loc, virus)
		else if (istype(src, /mob/living/carbon/alien))
			xgibs(src.loc, virus)
		else
			gibs(src.loc, virus)

	else if (!src.client)
		var/virus = src.virus
		if (istype(src, /mob/living/silicon))
			robogibs(src.loc, virus)
		else if (istype(src, /mob/living/carbon/alien))
			xgibs(src.loc, virus)
		else
			gibs(src.loc, virus)
	//CRASH("Generating error messages to attempt to fix random gibbins.") //no longer necessary
	sleep(15)
	del(src)

/*
This is the proc for turning a mob into ash. Mostly a copy of gib code (above).
Originally created for wizard disintegrate. I've removed the virus code since it's irrelevant here. N
*/
/mob/proc/dust()

	if (istype(src, /mob/dead/observer))
		return
	src.death(1)
	var/atom/movable/overlay/animation = null
	src.monkeyizing = 1
	src.canmove = 0
	src.icon = null
	src.invisibility = 101

	animation = new(src.loc)
	animation.icon_state = "blank"
	animation.icon = 'mob.dmi'
	animation.master = src
	if(ishuman(src))
		flick("dust-h", animation)
		new /obj/decal/remains/human(src.loc)
	else if(ismonkey(src))
		flick("dust-m", animation)
		new /obj/decal/remains/human(src.loc)
	else if(isalien(src))
		flick("dust-a", animation)
		new /obj/decal/remains/xeno(src.loc)
	else
		flick("dust-r", animation)
		new /obj/decal/remains/robot(src.loc)

	if (src.client)
		var/mob/dead/observer/newmob

		newmob = new/mob/dead/observer(src)
		src:client:mob = newmob
		if (src.mind)
			src.mind.transfer_to(newmob)

	sleep(15)
	del(src)

/mob/proc/get_contents()
	var/list/L = list()
	L += src.contents
	for(var/obj/item/weapon/storage/S in src.contents)
		L += S.return_inv()
	for(var/obj/item/weapon/gift/G in src.contents)
		L += G.gift
		if (istype(G.gift, /obj/item/weapon/storage))
			L += G.gift:return_inv()
	return L

/mob/proc/check_contents_for(A)
	var/list/L = list()
	L += src.contents
	for(var/obj/item/weapon/storage/S in src.contents)
		L += S.return_inv()
	for(var/obj/item/weapon/gift/G in src.contents)
		L += G.gift
		if (istype(G.gift, /obj/item/weapon/storage))
			L += G.gift:return_inv()

	for(var/obj/B in L)
		if(B.type == A)
			return 1
	return 0


/*
adds a dizziness amount to a mob
use this rather than directly changing var/dizziness
since this ensures that the dizzy_process proc is started
currently only humans get dizzy

value of dizziness ranges from 0 to 1000
below 100 is not dizzy
*/
/mob/proc/make_dizzy(var/amount)
	if(!istype(src, /mob/living/carbon/human)) // for the moment, only humans get dizzy
		return

	dizziness = min(1000, dizziness + amount)	// store what will be new value
													// clamped to max 1000
	if(dizziness > 100 && !is_dizzy)
		spawn(0)
			dizzy_process()


/*
dizzy process - wiggles the client's pixel offset over time
spawned from make_dizzy(), will terminate automatically when dizziness gets <100
note dizziness decrements automatically in the mob's Life() proc.
*/
/mob/proc/dizzy_process()
	is_dizzy = 1
	while(dizziness > 100)
		if(client)
			var/amplitude = dizziness*(sin(dizziness * 0.044 * world.time) + 1) / 70
			client.pixel_x = amplitude * sin(0.008 * dizziness * world.time)
			client.pixel_y = amplitude * cos(0.008 * dizziness * world.time)

		sleep(1)
	//endwhile - reset the pixel offsets to zero
	is_dizzy = 0
	if(client)
		client.pixel_x = 0
		client.pixel_y = 0

// jitteriness - copy+paste of dizziness

/mob/proc/make_jittery(var/amount)
	if(!istype(src, /mob/living/carbon/human)) // for the moment, only humans get dizzy
		return

	jitteriness = min(1000, jitteriness + amount)	// store what will be new value
													// clamped to max 1000
	if(jitteriness > 100 && !is_jittery)
		spawn(0)
			jittery_process()


// Typo from the oriignal coder here, below lies the jitteriness process. So make of his code what you will, the previous comment here was just a copypaste of the above.
/mob/proc/jittery_process()
	var/old_x = pixel_x
	var/old_y = pixel_y
	is_jittery = 1
	while(jitteriness > 100)
//		var/amplitude = jitteriness*(sin(jitteriness * 0.044 * world.time) + 1) / 70
//		pixel_x = amplitude * sin(0.008 * jitteriness * world.time)
//		pixel_y = amplitude * cos(0.008 * jitteriness * world.time)

		var/amplitude = min(4, jitteriness / 100)
		pixel_x = rand(-amplitude, amplitude)
		pixel_y = rand(-amplitude/3, amplitude/3)

		sleep(1)
	//endwhile - reset the pixel offsets to zero
	is_jittery = 0
	pixel_x = old_x
	pixel_y = old_y

/mob/Stat()
	..()

	statpanel("Status")

	if (src.client && src.client.holder)
		stat(null, "([x], [y], [z])")
		stat(null, "CPU: [world.cpu]")
		//if (master_controller)
		//	stat(null, "Loop: [master_controller.loop_freq]")

	if (src.spell_list.len)

		for(var/obj/spell/S in src.spell_list)
			statpanel("Spells","",S)

/client/proc/station_explosion_cinematic(var/derp)
	if(src.mob)
		var/mob/M = src.mob
		M.loc = null // HACK, but whatever, this works

		var/obj/screen/boom = M.hud_used.station_explosion
		if (M.client)
			M.client.screen += boom
			if(ticker)
				switch(ticker.mode.name)
					if("nuclear emergency")
						flick("start_nuke", boom)
					if("AI malfunction")
						flick("start_malf", boom)
					else
						boom.icon_state = "start"
			sleep(40)
			M << sound('explosionfar.ogg')
			boom.icon_state = "end"
			if(!derp) flick("explode", boom)
			else flick("explode2", boom)
			sleep(40)
			if(ticker)
				switch(ticker.mode.name)
					if("nuclear emergency")
						if (!derp) boom.icon_state = "loss_nuke"
						else boom.icon_state = "loss_nuke2"
					if("AI malfunction")
						boom.icon_state = "loss_malf"
					else
						boom.icon_state = "loss_general"

/mob/proc/electrocute_act(var/shock_damage, var/obj/source, var/siemens_coeff = 1.0)
	  return 0 //only carbon liveforms has this proc

/mob/emp_act(severity)
	var/list/L = src.get_contents()
	for(var/obj/O in L)
		O.emp_act(severity)
	..()