/mob/Del()//This makes sure that mobs with clients/keys are not just deleted from the game.
	ghostize(1)
	..()

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
	if(istype(A, /mob/living/carbon/human))
		return 1
	return 0

/proc/ismonkey(A)
	if(A && istype(A, /mob/living/carbon/monkey))
		return 1
	return 0

/proc/isbrain(A)
	if(A && istype(A, /mob/living/carbon/brain))
		return 1
	return 0

/proc/isalien(A)
	if(istype(A, /mob/living/carbon/alien))
		return 1
	return 0

/proc/isalienadult(A)
	if(istype(A, /mob/living/carbon/alien/humanoid))
		return 1
	return 0

/proc/islarva(A)
	if(istype(A, /mob/living/carbon/alien/larva))
		return 1
	return 0

/proc/isrobot(A)
	if(istype(A, /mob/living/silicon/robot))
		return 1
	return 0

/proc/isanimal(A)
	if(istype(A, /mob/living/simple_animal))
		return 1
	return 0

/proc/iscorgi(A)
	if(istype(A, /mob/living/simple_animal/corgi))
		return 1
	return 0

/*proc/ishivebot(A)
	if(A && istype(A, /mob/living/silicon/hivebot))
		return 1
	return 0*/

/*proc/ishivemainframe(A)
	if(A && istype(A, /mob/living/silicon/hive_mainframe))
		return 1
	return 0*/

/proc/isAI(A)
	if(istype(A, /mob/living/silicon/ai))
		return 1
	return 0

/proc/iscarbon(A)
	if(istype(A, /mob/living/carbon))
		return 1
	return 0

/proc/issilicon(A)
	if(istype(A, /mob/living/silicon))
		return 1
	return 0

/proc/isliving(A)
	if(istype(A, /mob/living))
		return 1
	return 0

proc/isobserver(A)
	if(istype(A, /mob/dead/observer))
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
	var/t = ""//placed before the message. Not really sure what it's for.
	n = length(n)//length of the entire word
	var/p = null
	p = 1//1 is the start of any word
	while(p <= n)//while P, which starts at 1 is less or equal to N which is the length.
		var/n_letter = copytext(te, p, p + 1)//copies text from a certain distance. In this case, only one letter at a time.
		if (prob(80) && (ckey(n_letter) in list("b","c","d","f","g","h","j","k","l","m","n","p","q","r","s","t","v","w","x","y","z")))
			if (prob(10))
				n_letter = text("[n_letter]-[n_letter]-[n_letter]-[n_letter]")//replaces the current letter with this instead.
			else
				if (prob(20))
					n_letter = text("[n_letter]-[n_letter]-[n_letter]")
				else
					if (prob(5))
						n_letter = null
					else
						n_letter = text("[n_letter]-[n_letter]")
		t = text("[t][n_letter]")//since the above is ran through for each letter, the text just adds up back to the original word.
		p++//for each letter p is increased to find where the next letter will be.
	return copytext(sanitize(t),1,MAX_MESSAGE_LEN)

/proc/ninjaspeak(n)
/*
The difference with stutter is that this proc can stutter more than 1 letter
The issue here is that anything that does not have a space is treated as one word (in many instances). For instance, "LOOKING," is a word, including the comma.
It's fairly easy to fix if dealing with single letters but not so much with compounds of letters./N
*/
	var/te = html_decode(n)
	var/t = ""
	n = length(n)
	var/p = 1
	while(p <= n)
		var/n_letter
		var/n_mod = rand(1,4)
		if(p+n_mod>n+1)
			n_letter = copytext(te, p, n+1)
		else
			n_letter = copytext(te, p, p+n_mod)
		if (prob(50))
			if (prob(30))
				n_letter = text("[n_letter]-[n_letter]-[n_letter]")
			else
				n_letter = text("[n_letter]-[n_letter]")
		else
			n_letter = text("[n_letter]")
		t = text("[t][n_letter]")
		p=p+n_mod
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

/atom/proc/relaymove()
	return

/obj/item/weapon/grab/proc/throw()
	if(affecting)
		var/grabee = affecting
		spawn(0)
			del(src)
		return grabee
	return null

/obj/item/weapon/grab/proc/synch()
	if(affecting.anchored)//This will prevent from grabbing people that are anchored.
		del(src)
	if (assailant.r_hand == src)
		hud1.screen_loc = ui_rhand
	else
		hud1.screen_loc = ui_lhand
	return

/obj/item/weapon/grab/process()
	if(!assailant || !affecting)
		del(src)
		return
	if ((!( isturf(assailant.loc) ) || (!( isturf(affecting.loc) ) || (assailant.loc != affecting.loc && get_dist(assailant, affecting) > 1))))
		//SN src = null
		del(src)
		return
	if (assailant.client)
		assailant.client.screen -= hud1
		assailant.client.screen += hud1
	if (assailant.pulling == affecting)
		assailant.pulling = null
	if (state <= 2)
		allow_upgrade = 1
		if ((assailant.l_hand && assailant.l_hand != src && istype(assailant.l_hand, /obj/item/weapon/grab)))
			var/obj/item/weapon/grab/G = assailant.l_hand
			if (G.affecting != affecting)
				allow_upgrade = 0
		if ((assailant.r_hand && assailant.r_hand != src && istype(assailant.r_hand, /obj/item/weapon/grab)))
			var/obj/item/weapon/grab/G = assailant.r_hand
			if (G.affecting != affecting)
				allow_upgrade = 0
		if (state == 2)
			var/h = affecting.hand
			affecting.hand = 0
			affecting.drop_item()
			affecting.hand = 1
			affecting.drop_item()
			affecting.hand = h
			for(var/obj/item/weapon/grab/G in affecting.grabbed_by)
				if (G.state == 2)
					allow_upgrade = 0
				//Foreach goto(341)
		if (allow_upgrade)
			hud1.icon_state = "reinforce"
		else
			hud1.icon_state = "!reinforce"
	else
		if (!( affecting.buckled ))
			affecting.loc = assailant.loc
	if ((killing && state == 3))
		affecting.stunned = max(5, affecting.stunned)
		affecting.paralysis = max(3, affecting.paralysis)
		affecting.losebreath = min(affecting.losebreath + 2, 3)
	return

/obj/item/weapon/grab/proc/s_click(obj/screen/S as obj)
	if (assailant.next_move > world.time)
		return
	if ((!( assailant.canmove ) || assailant.lying))
		//SN src = null
		del(src)
		return
	switch(S.id)
		if(1.0)
			if (state >= 3)
				if (!( killing ))
					for(var/mob/O in viewers(assailant, null))
						O.show_message(text("\red [] has temporarily tightened his grip on []!", assailant, affecting), 1)
						//Foreach goto(97)
					assailant.next_move = world.time + 10
					//affecting.stunned = max(2, affecting.stunned)
					//affecting.paralysis = max(1, affecting.paralysis)
					affecting.losebreath = min(affecting.losebreath + 1, 3)
					last_suffocate = world.time
					flick("disarm/killf", S)
		else
	return

/obj/item/weapon/grab/proc/s_dbclick(obj/screen/S as obj)
	//if ((assailant.next_move > world.time && !( last_suffocate < world.time + 2 )))
	//	return
	if ((!( assailant.canmove ) || assailant.lying))
		del(src)
		return
	switch(S.id)
		if(1.0)
			if (state < 2)
				if (!( allow_upgrade ))
					return
				if (prob(75))
					for(var/mob/O in viewers(assailant, null))
						O.show_message(text("\red [] has grabbed [] aggressively (now hands)!", assailant, affecting), 1)
					state = 2
					icon_state = "grabbed1"
				else
					for(var/mob/O in viewers(assailant, null))
						O.show_message(text("\red [] has failed to grab [] aggressively!", assailant, affecting), 1)
					del(src)
					return
			else
				if (state < 3)
					if(istype(affecting, /mob/living/carbon/human))
						var/mob/living/carbon/human/H = affecting
						if(H.mutations & FAT)
							assailant << "\blue You can't strangle [affecting] through all that fat!"
							return

						/*Hrm might want to add this back in
						//we should be able to strangle the Captain if he is wearing a hat
						for(var/obj/item/clothing/C in list(H.head, H.wear_suit, H.wear_mask, H.w_uniform))
							if(C.body_parts_covered & HEAD)
								assailant << "\blue You have to take off [affecting]'s [C.name] first!"
								return

						if(istype(H.wear_suit, /obj/item/clothing/suit/space) || istype(H.wear_suit, /obj/item/clothing/suit/armor) || istype(H.wear_suit, /obj/item/clothing/suit/bio_suit) || istype(H.wear_suit, /obj/item/clothing/suit/swat_suit))
							assailant << "\blue You can't strangle [affecting] through their suit collar!"
							return
						*/
					for(var/mob/O in viewers(assailant, null))
						O.show_message(text("\red [] has reinforced his grip on [] (now neck)!", assailant, affecting), 1)

					state = 3
					icon_state = "grabbed+1"
					if (!( affecting.buckled ))
						affecting.loc = assailant.loc
					affecting.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their neck grabbed by [assailant.name] ([assailant.ckey])</font>")
					assailant.attack_log += text("\[[time_stamp()]\] <font color='red'>Grabbed the neck of [affecting.name] ([affecting.ckey])</font>")
					hud1.icon_state = "disarm/kill"
					hud1.name = "disarm/kill"
				else
					if (state >= 3)
						killing = !( killing )
						if (killing)
							for(var/mob/O in viewers(assailant, null))
								O.show_message(text("\red [] has tightened his grip on []'s neck!", assailant, affecting), 1)
							affecting.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been strangled (kill intent) by [assailant.name] ([assailant.ckey])</font>")
							assailant.attack_log += text("\[[time_stamp()]\] <font color='red'>Strangled (kill intent) [affecting.name] ([affecting.ckey])</font>")
							assailant.next_move = world.time + 10
							affecting.losebreath += 1
							hud1.icon_state = "disarm/kill1"
						else
							hud1.icon_state = "disarm/kill"
							for(var/mob/O in viewers(assailant, null))
								O.show_message(text("\red [] has loosened the grip on []'s neck!", assailant, affecting), 1)
		else
	return

/obj/item/weapon/grab/New()
	..()
	hud1 = new /obj/screen/grab( src )
	hud1.icon_state = "reinforce"
	hud1.name = "Reinforce Grab"
	hud1.id = 1
	hud1.master = src
	return

/obj/item/weapon/grab/attack(mob/M as mob, mob/user as mob)
	if (M == affecting)
		if (state < 3)
			s_dbclick(hud1)
		else
			s_click(hud1)
		return
	if(M == assailant && state >= 2)
		if( ( ishuman(user) && (user.mutations & FAT) && ismonkey(affecting) ) || ( isalien(user) && iscarbon(affecting) ) )
			var/mob/living/carbon/attacker = user
			for(var/mob/N in viewers(user, null))
				if(N.client)
					N.show_message(text("\red <B>[user] is attempting to devour [affecting]!</B>"), 1)
			if(istype(user, /mob/living/carbon/alien/humanoid/hunter))
				if(!do_mob(user, affecting)||!do_after(user, 30)) return
			else
				if(!do_mob(user, affecting)||!do_after(user, 100)) return
			for(var/mob/N in viewers(user, null))
				if(N.client)
					N.show_message(text("\red <B>[user] devours [affecting]!</B>"), 1)
			affecting.loc = user
			attacker.stomach_contents.Add(affecting)
			del(src)

/obj/item/weapon/grab/dropped()
	del(src)
	return

/obj/item/weapon/grab/Del()
	del(hud1)
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
				selecting = "r_foot"
			else
				selecting = "l_foot"
	else if (icon_y < 11)
		if ((icon_x > 11 && icon_x < 21))
			if (icon_x < 16)
				selecting = "r_leg"
			else
				selecting = "l_leg"
	else if (icon_y < 12)
		if ((icon_x > 11 && icon_x < 21))
			if (icon_x < 14)
				selecting = "r_leg"
			else if (icon_x < 19)
				selecting = "groin"
			else
				selecting = "l_leg"
		else
			return
	else if (icon_y < 13)
		if ((icon_x > 7 && icon_x < 25))
			if (icon_x < 12)
				selecting = "r_hand"
			else if (icon_x < 13)
				selecting = "r_leg"
			else if (icon_x < 20)
				selecting = "groin"
			else if (icon_x < 21)
				selecting = "l_leg"
			else
				selecting = "l_hand"
		else
			return
	else if (icon_y < 14)
		if ((icon_x > 7 && icon_x < 25))
			if (icon_x < 12)
				selecting = "r_hand"
			else if (icon_x < 21)
				selecting = "groin"
			else
				selecting = "l_hand"
		else
			return
	else if (icon_y < 16)
		if ((icon_x > 7 && icon_x < 25))
			if (icon_x < 13)
				selecting = "r_hand"
			else if (icon_x < 20)
				selecting = "chest"
			else
				selecting = "l_hand"
		else
			return
	else if (icon_y < 23)
		if ((icon_x > 7 && icon_x < 25))
			if (icon_x < 12)
				selecting = "r_arm"
			else if (icon_x < 21)
				selecting = "chest"
			else
				selecting = "l_arm"
		else
			return
	else if (icon_y < 24)
		if ((icon_x > 11 && icon_x < 21))
			selecting = "chest"
		else
			return
	else if (icon_y < 25)
		if ((icon_x > 11 && icon_x < 21))
			if (icon_x < 16)
				selecting = "head"
			else if (icon_x < 17)
				selecting = "mouth"
			else
				selecting = "head"
		else
			return
	else if (icon_y < 26)
		if ((icon_x > 11 && icon_x < 21))
			if (icon_x < 15)
				selecting = "head"
			else if (icon_x < 18)
				selecting = "mouth"
			else
				selecting = "head"
		else
			return
	else if (icon_y < 27)
		if ((icon_x > 11 && icon_x < 21))
			if (icon_x < 15)
				selecting = "head"
			else if (icon_x < 16)
				selecting = "eyes"
			else if (icon_x < 17)
				selecting = "mouth"
			else if (icon_x < 18)
				selecting = "eyes"
			else
				selecting = "head"
		else
			return
	else if (icon_y < 28)
		if ((icon_x > 11 && icon_x < 21))
			if (icon_x < 14)
				selecting = "head"
			else if (icon_x < 19)
				selecting = "eyes"
			else
				selecting = "head"
		else
			return
	else if (icon_y < 29)
		if ((icon_x > 11 && icon_x < 21))
			if (icon_x < 15)
				selecting = "head"
			else if (icon_x < 16)
				selecting = "eyes"
			else if (icon_x < 17)
				selecting = "head"
			else if (icon_x < 18)
				selecting = "eyes"
			else
				selecting = "head"
		else
			return
	else if (icon_y < 31)
		if ((icon_x > 11 && icon_x < 21))
			selecting = "head"
		else
			return
	else
		return

	overlays = null
	overlays += image("icon" = 'zone_sel.dmi', "icon_state" = text("[]", selecting))

	return

/obj/screen/grab/Click()
	master:s_click(src)
	return

/obj/screen/grab/DblClick()
	master:s_dbclick(src)
	return

/obj/screen/grab/attack_hand()
	return

/obj/screen/grab/attackby()
	return

/obj/screen/Click(location, control, params)

	var/list/pa = params2list(params)

	switch(name)
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
				if(isalienadult(usr) || usr.mutations & HULK)//Don't want to do a lot of logic gating here.
					usr << "\green You attempt to break your handcuffs. (This will take around 5 seconds and you need to stand still)"
					for(var/mob/O in viewers(usr))
						O.show_message(text("\red <B>[] is trying to break the handcuffs!</B>", usr), 1)
					spawn(0)
						if(do_after(usr, 50))
							if(!usr:handcuffed) return
							for(var/mob/O in viewers(usr))
								O.show_message(text("\red <B>[] manages to break the handcuffs!</B>", usr), 1)
							usr << "\green You successfully break your handcuffs."
							del(usr:handcuffed)
							usr:handcuffed = null
				else
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

			if(usr:handcuffed && (usr.last_special <= world.time) && usr:buckled)
				usr.next_move = world.time + 100
				usr.last_special = world.time + 100
				usr << "\red You attempt to unbuckle yourself. (This will take around 2 minutes and you need to stand still)"
				for(var/mob/O in viewers(usr))
					O.show_message(text("\red <B>[] attempts to unbuckle themself!</B>", usr), 1)
				spawn(0)
					if(do_after(usr, 1200))
						if(!usr:buckled) return
						for(var/mob/O in viewers(usr))
							O.show_message(text("\red <B>[] manages to unbuckle themself!</B>", usr), 1)
						usr << "\blue You successfully unbuckle yourself."
						usr:buckled.manual_unbuckle_all(usr)
		if("module")
			if(istype(usr, /mob/living/silicon/robot))
				if(usr:module)
					return
				usr:pick_module()

		if("radio")
			if(istype(usr, /mob/living/silicon/robot))
				usr:radio_menu()
		if("panel")
			if(istype(usr, /mob/living/silicon/robot))
				usr:installed_modules()

		if("store")
			if(istype(usr, /mob/living/silicon/robot))
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
			DblClick()
	return

/obj/screen/attack_hand(mob/user as mob, using)
	user.db_click(name, using)
	return

/obj/screen/attack_paw(mob/user as mob, using)
	user.db_click(name, using)
	return

/obj/equip_e/process()
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

/mob/proc/show_message(msg, type, alt, alt_type)//Message, type of message (1 or 2), alternative message, alt message type (1 or 2)
	if(!client)	return
	if (type)
		if ((type & 1 && (sdisabilities & 1 || (blinded || paralysis))))//Vision related
			if (!( alt ))
				return
			else
				msg = alt
				type = alt_type
		if ((type & 2 && (sdisabilities & 4 || ear_deaf)))//Hearing related
			if (!( alt ))
				return
			else
				msg = alt
				type = alt_type
				if ((type & 1 && sdisabilities & 1))
					return
	// Added voice muffling for Issue 41.
	if (stat == 1 || sleeping > 0)
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
	if(organStructure)
		organStructure.ProcessOrgans()
	return

/mob/proc/update_clothing()
	return

/mob/proc/death(gibbed)
	timeofdeath = world.time
	return ..(gibbed)

/mob/proc/restrained()
	if (handcuffed)
		return 1
	return

/mob/proc/db_click(text, t1)
	var/obj/item/weapon/W = equipped()
	switch(text)
		if("mask")
			if (wear_mask)
				return
			if (!( istype(W, /obj/item/clothing/mask) ))
				return
			u_equip(W)
			wear_mask = W
			W.equipped(src, text)
		if("back")
			if ((back || !( istype(W, /obj/item/weapon) )))
				return
			if (!( W.flags & 1 ))
				return
			u_equip(W)
			back = W
			W.equipped(src, text)
		else
	return



/mob/proc/drop_item_v()
	if (stat == 0)
		drop_item()
	return

/mob/proc/drop_from_slot(var/obj/item/item)
	if(!item)
		return
	if(!(item in contents))
		return
	u_equip(item)
	if (client)
		client.screen -= item
	if (item)
		item.loc = loc
		item.dropped(src)
		if (item)
			item.layer = initial(item.layer)
		var/turf/T = get_turf(loc)
		if (istype(T))
			T.Entered(item)
	return

/mob/proc/drop_item()
	var/obj/item/W = equipped()

	if (W)
		if(W.twohanded)
			if(W.wielded)
				if(hand)
					var/obj/item/weapon/offhand/O = r_hand
					del O
				else
					var/obj/item/weapon/offhand/O = l_hand
					del O
			W.wielded = 0          //Kinda crude, but gets the job done with minimal pain -Agouri
			W.name = "[initial(W.name)]" //name reset so people don't see world fireaxes with (unwielded) or (wielded) tags
			W.update_icon()
		u_equip(W)
		if (client)
			client.screen -= W
		if (W)
			W.loc = loc
			W.dropped(src)
			if (W)
				W.layer = initial(W.layer)
		var/turf/T = get_turf(loc)
		if (istype(T))
			T.Entered(W)
	return

/mob/proc/before_take_item(var/obj/item/item)
	item.loc = null
	item.layer = initial(item.layer)
	u_equip(item)
	//if (client)
	//	client.screen -= item
	//update_clothing()
	return

/mob/proc/get_active_hand()
	if (hand)
		return l_hand
	else
		return r_hand

/mob/proc/get_inactive_hand()
	if ( ! hand)
		return l_hand
	else
		return r_hand

/mob/proc/put_in_hand(var/obj/item/I)
	if(!I) return
	I.loc = src
	if (hand)
		l_hand = I
	else
		r_hand = I
	I.layer = 20
	update_clothing()

/mob/proc/put_in_inactive_hand(var/obj/item/I)
	I.loc = src
	if (!hand)
		l_hand = I
	else
		r_hand = I
	I.layer = 20
	update_clothing()

/mob/proc/reset_view(atom/A)
	if (client)
		if (istype(A, /atom/movable))
			client.perspective = EYE_PERSPECTIVE
			client.eye = A
		else
			if (isturf(loc))
				client.eye = client.mob
				client.perspective = MOB_PERSPECTIVE
			else
				client.perspective = EYE_PERSPECTIVE
				client.eye = loc
	return

/mob/proc/equipped()
	if(issilicon(src))
		if(isrobot(src))
			if(src:module_active)
				return src:module_active
	else
		if (hand)
			return l_hand
		else
			return r_hand
		return

/mob/proc/show_inv(mob/user as mob)
	user.machine = src
	var/dat = text("<TT>\n<B><FONT size=3>[]</FONT></B><BR>\n\t<B>Head(Mask):</B> <A href='?src=\ref[];item=mask'>[]</A><BR>\n\t<B>Left Hand:</B> <A href='?src=\ref[];item=l_hand'>[]</A><BR>\n\t<B>Right Hand:</B> <A href='?src=\ref[];item=r_hand'>[]</A><BR>\n\t<B>Back:</B> <A href='?src=\ref[];item=back'>[]</A><BR>\n\t[]<BR>\n\t[]<BR>\n\t[]<BR>\n\t<A href='?src=\ref[];item=pockets'>Empty Pockets</A><BR>\n<A href='?src=\ref[];mach_close=mob[]'>Close</A><BR>\n</TT>", name, src, (wear_mask ? text("[]", wear_mask) : "Nothing"), src, (l_hand ? text("[]", l_hand) : "Nothing"), src, (r_hand ? text("[]", r_hand) : "Nothing"), src, (back ? text("[]", back) : "Nothing"), ((istype(wear_mask, /obj/item/clothing/mask) && istype(back, /obj/item/weapon/tank) && !( internal )) ? text(" <A href='?src=\ref[];item=internal'>Set Internal</A>", src) : ""), (internal ? text("<A href='?src=\ref[];item=internal'>Remove Internal</A>", src) : ""), (handcuffed ? text("<A href='?src=\ref[];item=handcuff'>Handcuffed</A>", src) : text("<A href='?src=\ref[];item=handcuff'>Not Handcuffed</A>", src)), src, user, name)
	user << browse(dat, text("window=mob[];size=325x500", name))
	onclose(user, "mob[name]")
	return



/mob/proc/u_equip(W as obj)
	if (W == r_hand)
		r_hand = null
	else if (W == l_hand)
		l_hand = null
	else if (W == handcuffed)
		handcuffed = null
	else if (W == back)
		back = null
	else if (W == wear_mask)
		wear_mask = null
	update_clothing()
	return


//Attemps to remove an object on a mob.  Will not move it to another area or such, just removes from the mob.
/mob/proc/remove_from_mob(var/obj/O)
	src.u_equip(O)
	if (src.client)
		src.client.screen -= O
	O.layer = initial(O.layer)
	O.screen_loc = null
	return 1


/mob/proc/ret_grab(obj/list_container/mobl/L as obj, flag)
	if ((!( istype(l_hand, /obj/item/weapon/grab) ) && !( istype(r_hand, /obj/item/weapon/grab) )))
		if (!( L ))
			return null
		else
			return L.container
	else
		if (!( L ))
			L = new /obj/list_container/mobl( null )
			L.container += src
			L.master = src
		if (istype(l_hand, /obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = l_hand
			if (!( L.container.Find(G.affecting) ))
				L.container += G.affecting
				if (G.affecting)
					G.affecting.ret_grab(L, 1)
		if (istype(r_hand, /obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = r_hand
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
	set name = "Activate Held Object"
	set category = "IC"

	set src = usr

	var/obj/item/W = equipped()
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
	set category = "OOC"
	if(mind)
		mind.show_memory(src)
	else
		src << "The game appears to have misplaced your mind datum, so we can't show you your notes."

/mob/verb/add_memory(msg as message)
	set name = "Add Note"
	set category = "OOC"

	msg = copytext(msg, 1, MAX_MESSAGE_LEN)
	msg = sanitize(msg)

	if(mind)
		mind.store_memory(msg)
	else
		src << "The game appears to have misplaced your mind datum, so we can't show you your notes."

/mob/proc/store_memory(msg as message, popup, sane = 1)
	msg = copytext(msg, 1, MAX_MESSAGE_LEN)

	if (sane)
		msg = sanitize(msg)

	if (length(memory) == 0)
		memory += msg
	else
		memory += "<BR>[msg]"

	if (popup)
		memory()

/*
/mob/verb/help()
	set name = "Help"
	src << browse('help.html', "window=help")
	return
*/

/mob/verb/abandon_mob()
	set name = "Respawn"
	set category = "OOC"

	if (!( abandon_allowed ))
		return
	if ((stat != 2 || !( ticker )))
		usr << "\blue <B>You must be dead to use this!</B>"
		return

	log_game("[usr.name]/[usr.key] used abandon mob.")

	usr << "\blue <B>Please roleplay correctly!</B>"

	if(!client)
		log_game("[usr.key] AM failed due to disconnect.")
		return
	for(var/obj/screen/t in usr.client.screen)
		if (t.loc == null)
			//t = null
			del(t)
	if(!client)
		log_game("[usr.key] AM failed due to disconnect.")
		return

	var/mob/new_player/M = new /mob/new_player()
	if(!client)
		log_game("[usr.key] AM failed due to disconnect.")
		del(M)
		return



	if(client && client.holder && (client.holder.state == 2))
		client.admin_play()
		return

	M.key = client.key
	M.Login()
	return

/mob/verb/cmd_rules()
	set name = "Rules"
	set category = "OOC"
	src << browse(rules, "window=rules;size=480x320")

/mob/verb/changes()
	set name = "Changelog"
	set category = "OOC"
	if (client)
		src << browse_rsc('postcardsmall.jpg')
		src << browse_rsc('somerights20.png')
		src << browse_rsc('88x31.png')
		src << browse('changelog.html', "window=changes;size=675x650")
		client.changes = 1

/client/var/ghost_ears = 1
/client/verb/toggle_ghost_ears()
	set name = "Ghost ears"
	set category = "OOC"
	set desc = "Hear talks from everywhere"
	ghost_ears = !ghost_ears
	if (ghost_ears)
		usr << "\blue Now you hear all speech in the world"
	else
		usr << "\blue Now you hear speech only from nearest creatures."

/mob/verb/observe()
	set name = "Observe"
	set category = "OOC"
	var/is_admin = 0

	if (client.holder && client.holder.level >= 1 && ( client.holder.state == 2 || client.holder.level > 3 ))
		is_admin = 1
	else if (istype(src, /mob/new_player) || stat != 2)
		usr << "\blue You must be observing to use this!"
		return

	if (is_admin && stat == 2)
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

	client.perspective = EYE_PERSPECTIVE

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
			reset_view(eye)
			client.adminobs = 1
			if(eye == client.mob)
				client.adminobs = 0
		else
			reset_view(null)
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
			client.eye = eye
		else
			client.eye = client.mob

/mob/verb/cancel_camera()
	set name = "Cancel Camera View"
	set category = "OOC"
	reset_view(null)
	machine = null
	if(istype(src, /mob/living))
		if(src:cameraFollow)
			src:cameraFollow = null

/mob/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group || (height==0)) return 1

	if(ismob(mover))
		var/mob/moving_mob = mover
		if ((other_mobs && moving_mob.other_mobs))
			return 1
		return (!mover.density || !density || lying)
	else
		return (!mover.density || !density || lying)
	return

/mob/dead/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	return 1

/mob/Topic(href, href_list)
	if(href_list["mach_close"])
		var/t1 = text("window=[href_list["mach_close"]]")
		machine = null
		src << browse(null, t1)

	if(href_list["priv_msg"])
		var/mob/M = locate(href_list["priv_msg"])
		if(M)
			if(muted)
				src << "You are muted have a nice day"
				return
			if (!ismob(M))
				return
			//This should have a check to prevent the player to player chat but I am too tired atm to add it.
			var/t = input("Message:", text("Private message to [M.key]"))  as text|null
			if (!t || !usr || !M)
				return
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
	return health


/mob/proc/UpdateLuminosity()
	if(src.total_luminosity == src.last_luminosity)	return 0//nothing to do here
	src.last_luminosity = src.total_luminosity
	sd_SetLuminosity(min(src.total_luminosity,7))//Current hardcode max at 7, should likely be a const somewhere else
	return 1


/mob/MouseDrop(mob/M as mob)
	..()
	if(M != usr) return
	if(usr == src) return
	if(get_dist(usr,src) > 1) return
	if(istype(M,/mob/living/silicon/ai)) return
	if(LinkBlocked(usr.loc,loc)) return
	show_inv(usr)



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
	set name = "Pull"
	set category = "IC"
	set src in oview(1)

	if (!( usr ))
		return
	if (!( anchored ))
		usr.pulling = src
		if(ismob(src))
			var/mob/M = src
			if(!istype(usr, /mob/living/carbon))
				M.LAssailant = null
			else
				M.LAssailant = usr
	return

/atom/verb/examine()
	set name = "Examine"
	set category = "IC"
	set src in oview(12)	//make it work from farther away

	if (!( usr ))
		return
	usr << "This is \an [name]."
	usr << desc
	// *****RM
	//usr << "[name]: Dn:[density] dir:[dir] cont:[contents] icon:[icon] is:[icon_state] loc:[loc]"
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
	if(istype(mob, /mob/living/carbon))
		mob:swap_hand()
	return

/client/Southeast()
	var/obj/item/weapon/W = mob.equipped()
	if (W)
		W.attack_self(mob)
	return

/client/Northwest()
	if(!isrobot(mob))
		mob.drop_item_v()
	return

/client/Center()
	if (isobj(mob.loc))
		var/obj/O = mob.loc
		if (mob.canmove)
			return O.relaymove(mob, 16)
	return

/client/Move(n, direct)
	if(mob.control_object)					// Hacking in something to control objects -- TLE
		if(mob.control_object.density)
			step(mob.control_object,direct)
			mob.control_object.dir = direct
		else
			mob.control_object.loc = get_step(mob.control_object,direct)
	if(isobserver(mob))
		return mob.Move(n,direct)
	if (moving)
		return 0
	if (world.time < move_delay)
		return
	if (!( mob ))
		return
	if (mob.stat==2)
		return

	if(isAI(mob))
		return AIMove(n,direct,mob)
//	if(ishivemainframe(mob))
//		return MainframeMove(n,direct,mob)

	if(mob.anchored)/*If mob is not AI and is anchored. This means most anchored mobs will not be able to move.
	This is a fix for ninja energy_net to where mobs can not move but can still act to destroy it.
	If needed, this should be changed in the appropriate manner. I think the only time you would need to anchor a mob
	is when they are not meant to move.*/
		return

	if (mob.incorporeal_move)
		var/turf/mobloc = get_turf(mob.loc)
		switch(mob.incorporeal_move)//1 is for all mobs. 2 is for ninjas only.
			if(1)
				mob.loc = get_step(mob, direct)
				mob.dir = direct
			if(2)
				//For Ninja crazy porting powers. Moves either 1 or 2 tiles.
				if(prob(50))
					var/locx
					var/locy
					switch(direct)
						if(NORTH)
							locx = mobloc.x
							locy = (mobloc.y+2)
							if(locy>world.maxy)
								return
						if(SOUTH)
							locx = mobloc.x
							locy = (mobloc.y-2)
							if(locy<1)
								return
						if(EAST)
							locy = mobloc.y
							locx = (mobloc.x+2)
							if(locx>world.maxx)
								return
						if(WEST)
							locy = mobloc.y
							locx = (mobloc.x-2)
							if(locx<1)
								return
						else
							return
					mob.loc = locate(locx,locy,mobloc.z)
					spawn(0)
						var/limit = 2//For only two trailing shadows.
						for(var/turf/T in getline(mobloc, mob.loc))
							spawn(0)
								anim(T,mob,'mob.dmi',,"shadow",,mob.dir)
							limit--
							if(limit<=0)	break
				else
					spawn(0)
						anim(mobloc,mob,'mob.dmi',,"shadow",,mob.dir)
					mob.loc = get_step(mob, direct)
				mob.dir = direct
		return

	if (mob.monkeyizing)
		return

	var/is_monkey = ismonkey(mob)
	if (locate(/obj/item/weapon/grab, locate(/obj/item/weapon/grab, mob.grabbed_by.len)))
		var/list/grabbing = list(  )
		if (istype(mob.l_hand, /obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = mob.l_hand
			grabbing += G.affecting
		if (istype(mob.r_hand, /obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = mob.r_hand
			grabbing += G.affecting
		for(var/obj/item/weapon/grab/G in mob.grabbed_by)
			if (G.state == 1)
				if (!( grabbing.Find(G.assailant) ))
					del(G)
			else
				if (G.state == 2)
					move_delay = world.time + 10
					if ((prob(25) && (!( is_monkey ) || prob(25))))
						mob.visible_message("\red [mob] has broken free of [G.assailant]'s grip!")
						del(G)
					else
						return
				else
					if (G.state == 3)
						move_delay = world.time + 10
						if ((prob(5) && !( is_monkey ) || prob(25)))
							mob.visible_message("\red [mob] has broken free of [G.assailant]'s headlock!")
							del(G)
						else
							return
	if (mob.canmove)

		if(mob.m_intent == "face")
			mob.dir = direct

		var/j_pack = 0
		if ((istype(mob.loc, /turf/space) && !istype(mob, /mob/living/carbon/metroid)))
			if (!( mob.restrained() ))
				if (!( (locate(/obj/grille) in oview(1, mob)) || (locate(/turf/simulated) in oview(1, mob)) || (locate(/obj/lattice) in oview(1, mob)) ))
					if (istype(mob.back, /obj/item/weapon/tank/jetpack))
						var/obj/item/weapon/tank/jetpack/J = mob.back
						j_pack = J.allow_thrust(0.01, mob)
						if(j_pack)
							mob.inertia_dir = 0
						if (!( j_pack ))
							return 0
					else
						return 0
			else
				return 0


		if (isturf(mob.loc))
			move_delay = world.time
			if ((j_pack && j_pack < 1))
				move_delay += 5
			switch(mob.m_intent)
				if("run")
					if (mob.drowsyness > 0)
						move_delay += 6
					if(mob.organStructure && mob.organStructure.legs)
						move_delay += mob.organStructure.legs.moveRunDelay
					else
						move_delay += 1
				if("face")
					mob.dir = direct
					return
				if("walk")
					if(mob.organStructure && mob.organStructure.legs)
						move_delay += mob.organStructure.legs.moveWalkDelay
					else
						move_delay += 7


			move_delay += mob.movement_delay()

			if (mob.restrained())
				for(var/mob/M in range(mob, 1))
					if (((M.pulling == mob && (!( M.restrained() ) && M.stat == 0)) || locate(/obj/item/weapon/grab, mob.grabbed_by.len)))
						src << "\blue You're restrained! You can't move!"
						return 0
			moving = 1
			if (locate(/obj/item/weapon/grab, mob))
				move_delay = max(move_delay, world.time + 7)
				var/list/L = mob.ret_grab()
				if (istype(L, /list))
					if (L.len == 2)
						L -= mob
						var/mob/M = L[1]
						if ((get_dist(mob, M) <= 1 || M.loc == mob.loc))
							var/turf/T = mob.loc
							. = ..()
							if (isturf(M.loc))
								var/diag = get_dir(mob, M)
								if ((diag - 1) & diag)
								else
									diag = null
								if ((get_dist(mob, M) > 1 || diag))
									step(M, get_dir(M.loc, T))
					else
						for(var/mob/M in L)
							M.other_mobs = 1
							if (mob != M)
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
				if(mob.confused)
					step(mob, pick(cardinal))
				else
					. = ..()
					for(var/obj/speech_bubble/S in range(1, mob))
						if(S.parent == mob)
							S.loc = mob.loc

			moving = null
			return .
		else
			if (isobj(mob.loc) || ismob(mob.loc))
				var/atom/O = mob.loc
				if (mob.canmove)
					return O.relaymove(mob, direct)
	else
		return
	return

/client/New()
	if(findtextEx(key, "Telnet @"))
		src << "Sorry, this game does not support Telnet."
		del(src)
	var/isbanned = CheckBan(src)
	if (isbanned)
		log_access("Failed Login: [src] - Banned")
		message_admins("\blue Failed Login: [src] - Banned")
		alert(src,"You have been banned.\nReason : [isbanned]","Ban","Ok")
		del(src)

	if (!guests_allowed && IsGuestKey(key))
		log_access("Failed Login: [src] - Guests not allowed")
		message_admins("\blue Failed Login: [src] - Guests not allowed")
		alert(src,"You cannot play here.\nReason : Guests not allowed","Guests not allowed","Ok")
		del(src)

	if (((world.address == address || !(address)) && !(host)))
		host = key
		world.update_status()

	..()

	if (join_motd)
		src << "<div class=\"motd\">[join_motd]</div>"

	authorize()
	//goonauth() -- Skie, commented out because not goons anymore.
	///beta_tester_auth()

	update_world()

//new admin bit - Nannek

	if (admins.Find(ckey))
		holder = new /obj/admins(src)
		holder.rank = admins[ckey]
		update_admins(admins[ckey])

	if (ticker && ticker.mode && ticker.mode.name =="sandbox" && authenticated)
		mob.CanBuild()
		if(holder  && (holder.level >= 3))
			verbs += /mob/proc/Delete

/client/Del()
	spawn(0)
		if(holder)
			del(holder)
	return ..()

/mob/proc/can_use_hands()
	if(handcuffed)
		return 0
	if(buckled && istype(buckled, /obj/stool/bed)) // buckling does not restrict hands
		return 0
	return ..()

/mob/proc/is_active()
	return (0 >= usr.stat)

/mob/proc/see(message)
	if(!is_active())
		return 0
	src << message
	return 1

/mob/proc/show_viewers(message)
	for(var/mob/M in viewers())
		M.see(message)

//This is the proc for gibbing a mob. Cannot gib ghosts. Removed the medal reference,
//added different sort of gibs and animations. N
/mob/proc/gib()

	if (istype(src, /mob/dead/observer))
		gibs(loc, viruses)
		return
	if(!isrobot(src))//Cyborgs no-longer "die" when gibbed.
		death(1)
	var/atom/movable/overlay/animation = null
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101

	animation = new(loc)
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

	spawn()
		if(key)
			if (istype(src, /mob/living/silicon))
				robogibs(loc, viruses)
			else if (istype(src, /mob/living/carbon/alien))
				xgibs(loc, viruses)
			else
				gibs(loc, viruses)

		else
			if (istype(src, /mob/living/silicon))
				robogibs(loc, viruses)
			else if (istype(src, /mob/living/carbon/alien))
				xgibs(loc, viruses)
			else
				gibs(loc, viruses)
		sleep(15)
		del(src)

/*
This is the proc for turning a mob into ash. Mostly a copy of gib code (above).
Originally created for wizard disintegrate. I've removed the virus code since it's irrelevant here.
Dusting robots does not eject the MMI, so it's a bit more powerful than gib() /N
*/
/mob/proc/dust()
	death(1)
	var/atom/movable/overlay/animation = null
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101

	animation = new(loc)
	animation.icon_state = "blank"
	animation.icon = 'mob.dmi'
	animation.master = src
	if(ishuman(src))
		flick("dust-h", animation)
		new /obj/decal/remains/human(loc)
	else if(ismonkey(src))
		flick("dust-m", animation)
		new /obj/decal/remains/human(loc)
	else if(isalien(src))
		flick("dust-a", animation)
		new /obj/decal/remains/xeno(loc)
	else
		flick("dust-r", animation)
		new /obj/decal/remains/robot(loc)

	sleep(15)
	if(isrobot(src)&&src:mmi)//Is a robot and it has an mmi.
		del(src:mmi)//Delete the MMI first so that it won't go popping out.
	del(src)

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

	if (client && client.holder)
		stat(null, "([x], [y], [z])")
		stat(null, "CPU: [world.cpu]")
		stat(null, "Controller: [controllernum]")
		//if (master_controller)
		//	stat(null, "Loop: [master_controller.loop_freq]")

	if (spell_list.len)

		for(var/obj/proc_holder/spell/S in spell_list)
			switch(S.charge_type)
				if("recharge")
					statpanel("Spells","[S.charge_counter/10.0]/[S.charge_max/10]",S)
				if("charges")
					statpanel("Spells","[S.charge_counter]/[S.charge_max]",S)
#if 1
/client/proc/station_explosion_cinematic(var/derp)
	if(mob)
		var/mob/M = mob
		M.loc = null // HACK, but whatever, this works

		if (M.client&&M.hud_used)//They may some times not have a hud, apparently.
			var/obj/screen/boom = M.hud_used.station_explosion
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
					if("malfunction")
						boom.icon_state = "loss_malf"
					if("blob")
						return//Nothin here yet and the general one does not fit.
					else
						boom.icon_state = "loss_general"
#elif
/client/proc/station_explosion_cinematic(var/derp)
	if(!src.mob)
		return

	var/mob/M = src.mob
	M.loc = null // HACK, but whatever, this works

	if(!M.hud_used)
		return

	var/obj/screen/boom = M.hud_used.station_explosion
	src.screen += boom
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
	if(!derp)
		flick("explode", boom)
	else
		flick("explode2", boom)
	sleep(40)
	if(ticker)
		switch(ticker.mode.name)
			if("nuclear emergency")
				if (!derp)
					boom.icon_state = "loss_nuke"
				else
					boom.icon_state = "loss_nuke2"
			if("AI malfunction")
				boom.icon_state = "loss_malf"
			else
				boom.icon_state = "loss_general"
#endif






// facing verbs
/mob/verb/eastface()
	set hidden = 1
	if(!canmove)
		return
	if (client.moving)
		return 0
	if (world.time < client.move_delay)
		return
	if (stat==2)
		return
	if (anchored)
		return
	if (monkeyizing)
		return
	if (restrained())
		return
	dir = EAST
	client.move_delay += movement_delay()

/mob/verb/westface()
	set hidden = 1
	if(!canmove)
		return
	if (client.moving)
		return 0
	if (world.time < client.move_delay)
		return
	if (stat==2)
		return
	if (anchored)
		return
	if (monkeyizing)
		return
	if (restrained())
		return
	dir = WEST
	client.move_delay += movement_delay()

/mob/verb/northface()
	set hidden = 1
	if(!canmove)
		return
	if (client.moving)
		return 0
	if (world.time < client.move_delay)
		return
	if (stat==2)
		return
	if (anchored)
		return
	if (monkeyizing)
		return
	if (restrained())
		return
	dir = NORTH
	client.move_delay += movement_delay()

/mob/verb/southface()
	set hidden = 1
	if(!canmove)
		return
	if (client.moving)
		return 0
	if (world.time < client.move_delay)
		return
	if (stat==2)
		return
	if (anchored)
		return
	if (monkeyizing)
		return
	if (restrained())
		return
	dir = SOUTH
	client.move_delay += movement_delay()


/mob/proc/IsAdvancedToolUser()//This might need a rename but it should replace the can this mob use things check
	return 0

