/obj/screen
	name = "screen"
	icon = 'screen1.dmi'
	layer = 20.0
	unacidable = 1
	var/id = 0.0
	var/obj/master
	var/gun_click_time = -100 //I'm lazy.

/obj/screen/close
	name = "close"
	master = null

/obj/screen/close/DblClick()
	if (src.master)
		src.master:close(usr)
	return

/obj/screen/grab
	name = "grab"
	master = null

/obj/screen/storage
	name = "storage"
	master = null

/obj/screen/storage/attackby(W, mob/user as mob)
	src.master.attackby(W, user)
	return

/obj/screen/zone_sel
	name = "Damage Zone"
	icon = 'zone_sel.dmi'
	icon_state = "blank"
	var/selecting = "chest"
	screen_loc = "EAST+1,NORTH"

/obj/screen/gun
	name = "gun"
	icon = 'screen1.dmi'
	master = null
	dir = 2

	move
		name = "Allow Walking"
		icon_state = "no_walk"
		screen_loc = ui_gun2

	run
		name = "Allow Running"
		icon_state = "no_run"
		screen_loc = ui_gun3

	item
		name = "Allow Item Use"
		icon_state = "no_item"
		screen_loc = ui_gun1

	mode
		name = "Toggle Gun Mode"
		desc = "The shortcut key for this is \"F6\""
		icon_state = "gun"
		screen_loc = ui_gun_select
		dir = 1

/obj/screen/zone_sel/MouseDown(location, control,params)
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
					usr << "\blue No longer running on internals."
					if (usr.internals)
						usr.internals.icon_state = "internal0"
				else
					if(ishuman(usr))
						if (!( istype(usr.wear_mask, /obj/item/clothing/mask) ))
							usr << "\red You are not wearing a mask"
							return
						else
							if (istype(usr.back, /obj/item/weapon/tank))
								usr << "\blue You are now running on internals from the [usr.back] on your back."
								usr.internal = usr.back
							else if (ishuman(usr) && istype(usr:s_store, /obj/item/weapon/tank))
								usr << "\blue You are now running on internals from the [usr:s_store] on your [usr:wear_suit]."
								usr.internal = usr:s_store
							else if (ishuman(usr) && istype(usr:belt, /obj/item/weapon/tank))
								usr << "\blue You are now running on internals from the [usr:belt] on your belt."
								usr.internal = usr:belt
							else if (istype(usr:l_store, /obj/item/weapon/tank))
								usr << "\blue You are now running on internals from the [usr:l_store] in your left pocket."
								usr.internal = usr:l_store
							else if (istype(usr:r_store, /obj/item/weapon/tank))
								usr << "\blue You are now running on internals from the [usr:r_store] in your right pocket."
								usr.internal = usr:r_store
							else if (istype(usr.l_hand, /obj/item/weapon/tank))
								usr << "\blue You are now running on internals from the [usr.l_hand] on your left hand."
								usr.internal = usr.l_hand
							else if (istype(usr.r_hand, /obj/item/weapon/tank))
								usr << "\blue You are now running on internals from the [usr.r_hand] on your right hand."
								usr.internal = usr.r_hand
							if (usr.internal)
								//for(var/mob/M in viewers(usr, 1))
								//	M.show_message(text("[] is now running on internals.", usr), 1)
								if (usr.internals)
									usr.internals.icon_state = "internal1"
							else
								usr << "\blue You don't have an oxygen tank."
		if("pull")
			usr.pulling = null
		if("sleep")
			if(usr.sleeping && usr.sleeping_willingly)
				usr.sleeping = 0
				usr.sleeping_willingly = 0
			else if(!usr.sleeping)
				usr.sleeping = 1
				usr.sleeping_willingly = 1
		if("rest")
			usr.resting = !usr.resting
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
			if(usr.next_move > world.time)
				return
			usr.next_move = world.time + 20
			if ((!( usr.stat ) && usr.canmove && !( usr.restrained() )))
				var/resisting = 0
				for(var/obj/O in usr.requests)
					del(O)
					resisting++
				for(var/obj/item/weapon/grab/G in usr.grabbed_by)
					resisting++
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
				if(resisting)
					for(var/mob/O in viewers(usr, null))
						O.show_message(text("\red <B>[] resists!</B>", usr), 1)
			if(usr:handcuffed && usr:canmove && (usr.last_special <= world.time))
				var/breakouttime = 1200
				var/displaytime = 2
				if(!usr:canmove)
					breakouttime = 2400
					displaytime = 4
				usr.next_move = world.time + 100
				usr.last_special = world.time + 100
				if(isalienadult(usr) || usr.mutations & HULK)//Don't want to do a lot of logic gating here.
					usr << "\green You attempt to break your handcuffs. (This will take around 5 seconds and you need to stand still)"
					for(var/mob/O in viewers(usr))
						O.show_message(text("\red <B>[] is trying to break the handcuffs!</B>", usr), 1)
					spawn(0)
						if(do_after(usr, 50))
							if(!usr:handcuffed || usr:buckled)
								return
							for(var/mob/O in viewers(usr))
								O.show_message(text("\red <B>[] manages to break the handcuffs!</B>", usr), 1)
							usr << "\green You successfully break your handcuffs."
							del(usr:handcuffed)
							usr:handcuffed = null
				else
					usr << "\red You attempt to remove your handcuffs. (This will take around [displaytime] minutes and you need to stand still)"
					for(var/mob/O in viewers(usr))
						O.show_message(text("\red <B>[] attempts to remove the handcuffs!</B>", usr), 1)
					spawn(0)
						var/increment = 150
						for(var/i = 0, i < breakouttime, i += increment)
							if(!do_after(usr, increment))
								return

							else
								usr << pick("You hear something click, but it doesn't open yet.",	// - Uristqwerty
											"The latch resists!",									// - IRC: BowlSoldier
											"The chain is starting to give!",						// - IRC: BowlSoldier
											"The chain bends a little.",							// - IRC: STALKER
											"Your wrist hurts.",									// - IRC: STALKER
											"Unnng",												// - IRC: Doug_H_Nuts
											"The chain jangles a bit.",								// - SkyMarshal
											"\red Hurry up, dammit!",								// - SkyMarshal
											"This is exhausting!")									// - SkyMarshal
								for(var/mob/O in viewers(usr))
									if(prob(50)) //Reduces spam slightly
										O.show_message(text("\red [] continues to struggle in their cuffs!", usr), 1)
						if(!usr:handcuffed) return
						for(var/mob/O in viewers(usr))
							O.show_message(text("\red <B>[] manages to remove the handcuffs!</B>", usr), 1)
						usr << "\blue You successfully remove your handcuffs."
						usr:handcuffed:loc = usr:loc
						usr:handcuffed = null
						usr.update_clothing()

			if(istype(usr, /mob/living/carbon/human) && istype(usr:wear_suit, /obj/item/clothing/suit/straight_jacket) && usr:canmove && (usr.last_special <= world.time))
				usr.next_move = world.time + 200
				usr.last_special = world.time + 200
				if(isalienadult(usr) || usr.mutations & HULK)//Don't want to do a lot of logic gating here.
					usr << "\green You attempt to break out of your straight jacket. (This will take around 5 seconds and you need to stand still)"
					for(var/mob/O in viewers(usr))
						O.show_message(text("\red <B>[] is trying to break out of \his straight jacket!</B>", usr), 1)
					spawn(0)
						if(do_after(usr, 50))
							if(!istype(usr:wear_suit, /obj/item/clothing/suit/straight_jacket)) return
							for(var/mob/O in viewers(usr))
								O.show_message(text("\red <B>[] manages to break out of the straight jacket!</B>", usr), 1)
							usr << "\green You successfully break out of your straight jacket."
							var/obj/sj = usr:wear_suit
							usr.remove_from_mob(sj)
							sj.loc = usr.loc
				else
					usr << "\red You attempt to get out of your straight jacket. (This will take around 4 minutes and you need to stand still)"
					for(var/mob/O in viewers(usr))
						O.show_message(text("\red <B>[] attempts to get out \his straight jacket!</B>", usr), 1)
					spawn(0)
						if(do_after(usr, 1200))
							if(!istype(usr:wear_suit, /obj/item/clothing/suit/straight_jacket)) return
							for(var/mob/O in viewers(usr))
								O.show_message(text("\red <B>[] manages to wriggle out of the straight jacket!</B>", usr), 1)
							usr << "\blue You successfully get out of your straight jacket."
							var/obj/sj = usr:wear_suit
							usr.remove_from_mob(sj)
							sj.loc = usr.loc

			if(usr:handcuffed && (usr.last_special <= world.time) && usr:buckled)
				usr.next_move = world.time + 100
				usr.last_special = world.time + 100
				usr << "\red You attempt to unbuckle yourself. (This will take around 2 minutes and you need to stand still)"
				for(var/mob/O in viewers(usr))
					O.show_message(text("\red <B>[] attempts to unbuckle themself!</B>", usr), 1)
				spawn(0)
					if(do_after(usr, 1200))
						if(!usr:buckled)
							return
						for(var/mob/O in viewers(usr))
							O.show_message(text("\red <B>[] manages to unbuckle themself!</B>", usr), 1)
						usr << "\blue You successfully unbuckle yourself."
						usr:buckled.manual_unbuckle(usr)


		if("module")
			if(issilicon(usr))
				if(usr:module)
					return
				usr:pick_module()

		if("radio")
			if(issilicon(usr))
				usr:radio_menu()
		if("panel")
			if(issilicon(usr))
				usr:installed_modules()

		if("store")
			if(issilicon(usr))
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

		if("Allow Walking")
			if(gun_click_time > world.time - 30)	//give them 3 seconds between mode changes.
				return
			if(!istype(usr.equipped(),/obj/item/weapon/gun))
				usr << "You need your gun in your active hand to do that!"
				return
			usr.client.AllowTargetMove()
			gun_click_time = world.time

		if("Disallow Walking")
			if(gun_click_time > world.time - 30)	//give them 3 seconds between mode changes.
				return
			if(!istype(usr.equipped(),/obj/item/weapon/gun))
				usr << "You need your gun in your active hand to do that!"
				return
			usr.client.AllowTargetMove()
			gun_click_time = world.time

		if("Allow Running")
			if(gun_click_time > world.time - 30)	//give them 3 seconds between mode changes.
				return
			if(!istype(usr.equipped(),/obj/item/weapon/gun))
				usr << "You need your gun in your active hand to do that!"
				return
			usr.client.AllowTargetRun()
			gun_click_time = world.time

		if("Disallow Running")
			if(gun_click_time > world.time - 30)	//give them 3 seconds between mode changes.
				return
			if(!istype(usr.equipped(),/obj/item/weapon/gun))
				usr << "You need your gun in your active hand to do that!"
				return
			usr.client.AllowTargetRun()
			gun_click_time = world.time

		if("Allow Item Use")
			if(gun_click_time > world.time - 30)	//give them 3 seconds between mode changes.
				return
			if(!istype(usr.equipped(),/obj/item/weapon/gun))
				usr << "You need your gun in your active hand to do that!"
				return
			usr.client.AllowTargetClick()
			gun_click_time = world.time


		if("Disallow Item Use")
			if(gun_click_time > world.time - 30)	//give them 3 seconds between mode changes.
				return
			if(!istype(usr.equipped(),/obj/item/weapon/gun))
				usr << "You need your gun in your active hand to do that!"
				return
			usr.client.AllowTargetClick()
			gun_click_time = world.time

		if("Toggle Gun Mode")
			usr.client.ToggleGunMode()

		else
			DblClick()
	return

/obj/screen/attack_hand(mob/user as mob, using)
	user.db_click(name, using)
	return

/obj/screen/attack_paw(mob/user as mob, using)
	user.db_click(name, using)
	return
