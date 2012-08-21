/obj/screen
	name = "screen"
	icon = 'icons/mob/screen1.dmi'
	layer = 20.0
	unacidable = 1
	var/id = 0.0
	var/obj/master

/obj/screen/inventory
	var/slot_id

/obj/screen/close
	name = "close"
	master = null

/obj/screen/close/DblClick()
	if (src.master)
		src.master:close(usr)
	return

/obj/screen/item_action
	var/obj/item/owner

/obj/screen/item_action/DblClick()
	if(!usr || !owner)
		return

	if(usr.stat || usr.restrained() || usr.stunned || usr.lying)
		return

	if(!(owner in usr))
		return

	spawn()
		owner.ui_action_click()

//This is the proc used to update all the action buttons. It just returns for all mob types except humans.
/mob/proc/update_action_buttons()
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
	icon = 'icons/mob/screen1.dmi'
	icon_state = "zone_sel"
	var/selecting = "chest"
	screen_loc = ui_zonesel


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
	overlays += image('icons/mob/zone_sel.dmi', "[selecting]")

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

/obj/screen/MouseEntered(object,location,control,params)
	if(!ishuman(usr) && !istype(usr,/mob/living/carbon/alien/humanoid) && !islarva(usr) && !ismonkey(usr))
		return
	switch(name)
		/*
		if("other")
			if (usr.hud_used.inventory_shown)
				usr.hud_used.inventory_shown = 0
				usr.client.screen -= usr.hud_used.other
			else
				usr.hud_used.inventory_shown = 1
				usr.client.screen += usr.hud_used.other

			usr.hud_used.hidden_inventory_update()*/
		if("act_intent")
			if(ishuman(usr) || istype(usr,/mob/living/carbon/alien/humanoid) || islarva(usr))
				usr.hud_used.action_intent.icon_state = "intent_[usr.a_intent]"

/obj/screen/MouseExited(object,location,control,params)
	if(!ishuman(usr) && !istype(usr,/mob/living/carbon/alien/humanoid) && !islarva(usr) && !ismonkey(usr))
		return
	switch(name)
		if("act_intent")
			if(ishuman(usr) || istype(usr,/mob/living/carbon/alien/humanoid) || islarva(usr))
				var/intent = usr.a_intent
				if(intent == "hurt")
					intent = "harm"	//hurt and harm have different sprite names for some reason.
				usr.hud_used.action_intent.icon_state = "[intent]"

/obj/screen/Click(location, control, params)
	switch(name)
		if("map")
			usr.clearmap()

		if("other")
			if (usr.hud_used.inventory_shown)
				usr.hud_used.inventory_shown = 0
				usr.client.screen -= usr.hud_used.other
			else
				usr.hud_used.inventory_shown = 1
				usr.client.screen += usr.hud_used.other

			usr.hud_used.hidden_inventory_update()

		if("equip")
			var/obj/item/I = usr.get_active_hand()
			if(!I)
				usr << "\blue You are not holding anything to equip."
				return
			if(ishuman(usr))
				var/mob/living/carbon/human/H = usr
				H.equip_to_appropriate_slot(I)

		if("resist")
			if(isliving(usr))
				var/mob/living/L = usr
				L.resist()

		if("maprefresh")
			var/obj/machinery/computer/security/seccomp = usr.machine

			if(seccomp!=null)
				seccomp.drawmap(usr)
			else
				usr.clearmap()

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
			if(usr.legcuffed)
				usr << "\red You are legcuffed! You cannot run until you get your cuffs removed!"
				usr.m_intent = "walk"	//Just incase
				usr.hud_used.move_intent.icon_state = "walking"
				return
			switch(usr.m_intent)
				if("run")
					usr.m_intent = "walk"
					usr.hud_used.move_intent.icon_state = "walking"
				if("walk")
					usr.m_intent = "run"
					usr.hud_used.move_intent.icon_state = "running"
			if(istype(usr,/mob/living/carbon/alien/humanoid))	usr.update_icons()
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
							if (ishuman(usr) && istype(usr:s_store, /obj/item/weapon/tank))
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
							else if (istype(usr.back, /obj/item/weapon/tank))
								usr << "\blue You are now running on internals from the [usr.back] on your back."
								usr.internal = usr.back
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
		if("act_intent")
			if(ishuman(usr) || istype(usr,/mob/living/carbon/alien/humanoid) || islarva(usr))
				switch(usr.a_intent)
					if("help")
						usr.a_intent = "disarm"
						usr.hud_used.action_intent.icon_state = "intent_disarm"
					if("disarm")
						usr.a_intent = "grab"
						usr.hud_used.action_intent.icon_state = "intent_grab"
					if("grab")
						usr.a_intent = "hurt"
						usr.hud_used.action_intent.icon_state = "intent_hurt"
					if("hurt")
						usr.a_intent = "help"
						usr.hud_used.action_intent.icon_state = "intent_help"
				/*if (usr.hud_used.show_intent_icons)
					usr.hud_used.show_intent_icons = 0
					usr.client.screen -= usr.hud_used.intent_small_hud_objects
				else
					usr.hud_used.show_intent_icons = 1
					usr.client.screen += usr.hud_used.intent_small_hud_objects*/ //Small intent icons
			if(issilicon(usr))
				if(usr.a_intent == "help")
					usr.a_intent = "hurt"
					usr.hud_used.action_intent.icon_state = "harm"
				else
					usr.a_intent = "help"
					usr.hud_used.action_intent.icon_state = "help"
		if("help")
			usr.a_intent = "help"
			usr.hud_used.action_intent.icon_state = "help"
			usr.hud_used.show_intent_icons = 0
		if("harm")
			usr.a_intent = "hurt"
			usr.hud_used.action_intent.icon_state = "harm"
			usr.hud_used.show_intent_icons = 0
		if("grab")
			usr.a_intent = "grab"
			usr.hud_used.action_intent.icon_state = "grab"
			usr.hud_used.show_intent_icons = 0
		if("disarm")
			usr.a_intent = "disarm"
			usr.hud_used.action_intent.icon_state = "disarm"
			usr.hud_used.show_intent_icons = 0
		if("pull")
			usr.stop_pulling()
		if("throw")
			if (!usr.stat && isturf(usr.loc) && !usr.restrained())
				usr:toggle_throw_mode()
		if("drop")
			usr.drop_item_v()
		if("swap")
			usr:swap_hand()
		if("hand")
			usr:swap_hand()
		if("r_hand")
			if(iscarbon(usr))
				var/mob/living/carbon/C = usr
				C.activate_hand("r")
		if("l_hand")
			if(iscarbon(usr))
				var/mob/living/carbon/C = usr
				C.activate_hand("l")
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

		if("radar")
			usr:close_radar()

		if("radar closed")
			usr:start_radar()

		else
			DblClick()
	return

/obj/screen/inventory/attack_hand(mob/user as mob)
	user.attack_ui(slot_id)
	return

/obj/screen/inventory/attack_paw(mob/user as mob)
	user.attack_ui(slot_id)
	return


/mob/living/carbon/verb/mob_sleep()
	set name = "Sleep"
	set category = "IC"

	if(usr.sleeping)
		usr << "\red You are already sleeping"
		return
	else
		if(alert(src,"You sure you want to sleep for a while?","Sleep","Yes","No") == "Yes")
			usr.sleeping = 20 //Short nap

/mob/living/carbon/verb/lay_down()
	set name = "Lay down / Get up"
	set category = "IC"

	usr.resting = !( usr.resting )
	usr << "\blue You are now [(usr.resting) ? "resting" : "getting up"]"


/mob/living/verb/resist()
	set name = "Resist"
	set category = "IC"

	if(!isliving(usr) || usr.next_move > world.time)
		return
	usr.next_move = world.time + 20

	var/mob/living/L = usr

	//resisting grabs (as if it helps anyone...)
	if ((!( L.stat ) && L.canmove && !( L.restrained() )))
		var/resisting = 0
		for(var/obj/O in L.requests)
			del(O)
			resisting++
		for(var/obj/item/weapon/grab/G in usr.grabbed_by)
			resisting++
			if (G.state == 1)
				del(G)
			else
				if (G.state == 2)
					if (prob(25))
						for(var/mob/O in viewers(L, null))
							O.show_message(text("\red [] has broken free of []'s grip!", L, G.assailant), 1)
						del(G)
				else
					if (G.state == 3)
						if (prob(5))
							for(var/mob/O in viewers(usr, null))
								O.show_message(text("\red [] has broken free of []'s headlock!", L, G.assailant), 1)
							del(G)
		if(resisting)
			for(var/mob/O in viewers(usr, null))
				O.show_message(text("\red <B>[] resists!</B>", L), 1)


	//unbuckling yourself
	if(L.buckled && (L.last_special <= world.time) )
		if( L.handcuffed )
			L.next_move = world.time + 100
			L.last_special = world.time + 100
			L << "\red You attempt to unbuckle yourself. (This will take around 2 minutes and you need to stand still)"
			for(var/mob/O in viewers(L))
				O.show_message("\red <B>[usr] attempts to unbuckle themself!</B>", 1)
			spawn(0)
				if(do_after(usr, 1200))
					if(!L.buckled)
						return
					for(var/mob/O in viewers(L))
						O.show_message("\red <B>[usr] manages to unbuckle themself!</B>", 1)
					L << "\blue You successfully unbuckle yourself."
					L.buckled.manual_unbuckle(L)
		else
			L.buckled.manual_unbuckle(L)

	//Breaking out of a locker?
	else if( src.loc && (istype(src.loc, /obj/structure/closet)) )
		var/breakout_time = 2 //2 minutes by default

		var/obj/structure/closet/C = L.loc
		if(C.opened)
			return //Door's open... wait, why are you in it's contents then?
		if(istype(L.loc, /obj/structure/closet/secure_closet))
			var/obj/structure/closet/secure_closet/SC = L.loc
			if(!SC.locked && !SC.welded)
				return //It's a secure closet, but isn't locked. Easily escapable from, no need to 'resist'
		else
			if(!C.welded)
				return //closed but not welded...
		//	else Meh, lets just keep it at 2 minutes for now
		//		breakout_time++ //Harder to get out of welded lockers than locked lockers

		//okay, so the closet is either welded or locked... resist!!!
		usr.next_move = world.time + 100
		L.last_special = world.time + 100
		L << "\red You lean on the back of \the [C] and start pushing the door open. (this will take about [breakout_time] minutes)"
		for(var/mob/O in viewers(usr.loc))
			O.show_message("\red <B>The [L.loc] begins to shake violently!</B>", 1)


		spawn(0)
			if(do_after(usr,(breakout_time*60*10))) //minutes * 60seconds * 10deciseconds
				if(!C || !L || L.stat != CONSCIOUS || L.loc != C || C.opened) //closet/user destroyed OR user dead/unconcious OR user no longer in closet OR closet opened
					return

				//Perform the same set of checks as above for weld and lock status to determine if there is even still a point in 'resisting'...
				if(istype(L.loc, /obj/structure/closet/secure_closet))
					var/obj/structure/closet/secure_closet/SC = L.loc
					if(!SC.locked && !SC.welded)
						return
				else
					if(!C.welded)
						return

				//Well then break it!
				if(istype(usr.loc, /obj/structure/closet/secure_closet))
					var/obj/structure/closet/secure_closet/SC = L.loc
					SC.desc = "It appears to be broken."
					SC.icon_state = SC.icon_off
					flick(SC.icon_broken, SC)
					sleep(10)
					flick(SC.icon_broken, SC)
					sleep(10)
					SC.broken = 1
					SC.locked = 0
					usr << "\red You successfully break out!"
					for(var/mob/O in viewers(L.loc))
						O.show_message("\red <B>\the [usr] successfully broke out of \the [SC]!</B>", 1)
					if(istype(SC.loc, /obj/structure/bigDelivery)) //Do this to prevent contents from being opened into nullspace (read: bluespace)
						var/obj/structure/bigDelivery/BD = SC.loc
						BD.attack_hand(usr)
					SC.open()
				else
					C.welded = 0
					usr << "\red You successfully break out!"
					for(var/mob/O in viewers(L.loc))
						O.show_message("\red <B>\the [usr] successfully broke out of \the [C]!</B>", 1)
					if(istype(C.loc, /obj/structure/bigDelivery)) //nullspace ect.. read the comment above
						var/obj/structure/bigDelivery/BD = C.loc
						BD.attack_hand(usr)
					C.open()

	//breaking out of handcuffs
	else if(iscarbon(L))
		var/mob/living/carbon/CM = L
		if(CM.handcuffed && CM.canmove && (CM.last_special <= world.time))
			CM.next_move = world.time + 100
			CM.last_special = world.time + 100
			if(isalienadult(CM) || (HULK in usr.mutations) || (SUPRSTR in CM.augmentations))//Don't want to do a lot of logic gating here.
				usr << "\green You attempt to break your handcuffs. (This will take around 5 seconds and you need to stand still)"
				for(var/mob/O in viewers(CM))
					O.show_message(text("\red <B>[] is trying to break the handcuffs!</B>", CM), 1)
				spawn(0)
					if(do_after(CM, 50))
						if(!CM.handcuffed || CM.buckled)
							return
						for(var/mob/O in viewers(CM))
							O.show_message(text("\red <B>[] manages to break the handcuffs!</B>", CM), 1)
						CM << "\green You successfully break your handcuffs."
						del(CM.handcuffed)
						CM.handcuffed = null
						CM.update_inv_handcuffed()
			else
				var/obj/item/weapon/handcuffs/HC = CM.handcuffed
				var/breakouttime = 1200 //A default in case you are somehow handcuffed with something that isn't an obj/item/weapon/handcuffs type
				var/displaytime = 2 //Minutes to display in the "this will take X minutes."
				if(istype(HC)) //If you are handcuffed with actual handcuffs... Well what do I know, maybe someone will want to handcuff you with toilet paper in the future...
					breakouttime = HC.breakouttime
					displaytime = breakouttime / 600 //Minutes
				CM << "\red You attempt to remove \the [HC]. (This will take around [displaytime] minutes and you need to stand still)"
				for(var/mob/O in viewers(CM))
					O.show_message( "\red <B>[usr] attempts to remove \the [HC]!</B>", 1)
				spawn(0)
					if(do_after(CM, breakouttime))
						if(!CM.handcuffed || CM.buckled)
							return // time leniency for lag which also might make this whole thing pointless but the server
						for(var/mob/O in viewers(CM))//                                         lags so hard that 40s isn't lenient enough - Quarxink
							O.show_message("\red <B>[CM] manages to remove the handcuffs!</B>", 1)
						CM << "\blue You successfully remove \the [CM.handcuffed]."
						CM.handcuffed.loc = usr.loc
						CM.handcuffed = null
						CM.update_inv_handcuffed()
		else if(CM.legcuffed && CM.canmove && (CM.last_special <= world.time))
			CM.next_move = world.time + 100
			CM.last_special = world.time + 100
			if(isalienadult(CM) || (HULK in usr.mutations) || (SUPRSTR in CM.augmentations))//Don't want to do a lot of logic gating here.
				usr << "\green You attempt to break your legcuffs. (This will take around 5 seconds and you need to stand still)"
				for(var/mob/O in viewers(CM))
					O.show_message(text("\red <B>[] is trying to break the legcuffs!</B>", CM), 1)
				spawn(0)
					if(do_after(CM, 50))
						if(!CM.legcuffed || CM.buckled)
							return
						for(var/mob/O in viewers(CM))
							O.show_message(text("\red <B>[] manages to break the legcuffs!</B>", CM), 1)
						CM << "\green You successfully break your legcuffs."
						del(CM.legcuffed)
						CM.legcuffed = null
						CM.update_inv_legcuffed()
			else
				var/obj/item/weapon/legcuffs/HC = CM.legcuffed
				var/breakouttime = 1200 //A default in case you are somehow legcuffed with something that isn't an obj/item/weapon/legcuffs type
				var/displaytime = 2 //Minutes to display in the "this will take X minutes."
				if(istype(HC)) //If you are legcuffed with actual legcuffs... Well what do I know, maybe someone will want to legcuff you with toilet paper in the future...
					breakouttime = HC.breakouttime
					displaytime = breakouttime / 600 //Minutes
				CM << "\red You attempt to remove \the [HC]. (This will take around [displaytime] minutes and you need to stand still)"
				for(var/mob/O in viewers(CM))
					O.show_message( "\red <B>[usr] attempts to remove \the [HC]!</B>", 1)
				spawn(0)
					if(do_after(CM, breakouttime))
						if(!CM.legcuffed || CM.buckled)
							return // time leniency for lag which also might make this whole thing pointless but the server
						for(var/mob/O in viewers(CM))//                                         lags so hard that 40s isn't lenient enough - Quarxink
							O.show_message("\red <B>[CM] manages to remove the legcuffs!</B>", 1)
						CM << "\blue You successfully remove \the [CM.legcuffed]."
						CM.legcuffed.loc = usr.loc
						CM.legcuffed = null
						CM.update_inv_legcuffed()