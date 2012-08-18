/mob/living/silicon/hivebot/New(loc,mainframe)
	src << "\blue Your icons have been generated!"
	updateicon()

	if(mainframe)
		dependent = 1
		src.real_name = mainframe:name
		src.name = src.real_name
	else
		src.real_name = "Robot [pick(rand(1, 999))]"
		src.name = src.real_name

	src.radio = new /obj/item/device/radio(src)
	..()


/mob/living/silicon/hivebot/proc/pick_module()
	if(src.module)
		return
	var/mod = input("Please, select a module!", "Robot", null, null) in list("Combat", "Engineering")
	if(src.module)
		return
	switch(mod)
		if("Combat")
			src.module = new /obj/item/weapon/hive_module/standard(src)

		if("Engineering")
			src.module = new /obj/item/weapon/hive_module/engineering(src)


	src.hands.icon_state = "malf"
	updateicon()


/mob/living/silicon/hivebot/blob_act()
	if (src.stat != 2)
		src.adjustBruteLoss(60)
		src.updatehealth()
		return 1
	return 0

/mob/living/silicon/hivebot/Stat()
	..()
	statpanel("Status")
	if (src.client.statpanel == "Status")
		if(emergency_shuttle.online && emergency_shuttle.location < 2)
			var/timeleft = emergency_shuttle.timeleft()
			if (timeleft)
				stat(null, "ETA-[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]")
/*
		if(ticker.mode.name == "AI malfunction")
			stat(null, "Points left until the AI takes over: [AI_points]/[AI_points_win]")
*/

		stat(null, text("Charge Left: [src.energy]/[src.energy_max]"))

/mob/living/silicon/hivebot/restrained()
	return 0

/mob/living/silicon/hivebot/ex_act(severity)
	if(!blinded)
		flick("flash", src.flash)

	if (src.stat == 2 && src.client)
		src.gib(1)
		return

	else if (src.stat == 2 && !src.client)
		del(src)
		return

	switch(severity)
		if(1.0)
			if (src.stat != 2)
				adjustBruteLoss(100)
				adjustFireLoss(100)
				src.gib(1)
				return
		if(2.0)
			if (src.stat != 2)
				adjustBruteLoss(60)
				adjustFireLoss(60)
		if(3.0)
			if (src.stat != 2)
				adjustBruteLoss(30)

	src.updatehealth()

/mob/living/silicon/hivebot/meteorhit(obj/O as obj)
	for(var/mob/M in viewers(src, null))
		M.show_message(text("\red [src] has been hit by [O]"), 1)
		//Foreach goto(19)
	if (src.health > 0)
		src.adjustBruteLoss(30)
		if ((O.icon_state == "flaming"))
			src.adjustFireLoss(40)
		src.updatehealth()
	return

/mob/living/silicon/hivebot/bullet_act(flag)
/*
	if (flag == PROJECTILE_BULLET)
		if (src.stat != 2)
			src.bruteloss += 60
			src.updatehealth()

	else if (flag == PROJECTILE_MEDBULLET)
		if (src.stat != 2)
			src.bruteloss += 30
			src.updatehealth()

	else if (flag == PROJECTILE_WEAKBULLET)
		if (src.stat != 2)
			src.bruteloss += 15
			src.updatehealth()

	else if (flag == PROJECTILE_MPBULLET)
		if (src.stat != 2)
			src.bruteloss += 20
			src.updatehealth()

	else if (flag == PROJECTILE_SLUG)
		if (src.stat != 2)
			src.bruteloss += 40
			src.updatehealth()

	else if (flag == PROJECTILE_BAG)
		if (src.stat != 2)
			src.bruteloss += 2
			src.updatehealth()


	else if (flag == PROJECTILE_TASER)
		return

	else if (flag == PROJECTILE_WAVE)
		if (src.stat != 2)
			src.bruteloss += 25
			src.updatehealth()
		return

	else if(flag == PROJECTILE_LASER)
		if (src.stat != 2)
			src.bruteloss += 20
			src.updatehealth()
	else if(flag == PROJECTILE_PULSE)
		if (src.stat != 2)
			src.bruteloss += 40
			src.updatehealth()
*/
	return



/mob/living/silicon/hivebot/Bump(atom/movable/AM as mob|obj, yes)
	spawn( 0 )
		if ((!( yes ) || src.now_pushing))
			return
		src.now_pushing = 1
		if(ismob(AM))
			var/mob/tmob = AM
			if(istype(tmob, /mob/living/carbon/human) && tmob.mutations & FAT)
				if(prob(20))
					for(var/mob/M in viewers(src, null))
						if(M.client)
							M << M << "\red <B>[src] fails to push [tmob]'s fat ass out of the way.</B>"
					src.now_pushing = 0
					//src.unlock_medal("That's No Moon, That's A Gourmand!", 1)
					return
		src.now_pushing = 0
		..()
		if (!istype(AM, /atom/movable))
			return
		if (!src.now_pushing)
			src.now_pushing = 1
			if (!AM.anchored)
				var/t = get_dir(src, AM)
				step(AM, t)
			src.now_pushing = null
		return
	return


/mob/living/silicon/hivebot/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/weldingtool) && W:welding)
		if (W:remove_fuel(0))
			src.adjustBruteLoss(-30)
			src.updatehealth()
			src.add_fingerprint(user)
			for(var/mob/O in viewers(user, null))
				O.show_message(text("\red [user] has fixed some of the dents on [src]!"), 1)
		else
			user << "Need more welding fuel!"
			return

/mob/living/silicon/hivebot/attack_alien(mob/living/carbon/alien/humanoid/M as mob)

	if (M.a_intent == "grab")
		if (M == src)
			return
		var/obj/item/weapon/grab/G = new /obj/item/weapon/grab( M )
		G.assailant = M
		if (M.hand)
			M.l_hand = G
		else
			M.r_hand = G
		G.layer = 20
		G.affecting = src
		src.grabbed_by += G
		G.synch()
		playsound(src.loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
		for(var/mob/O in viewers(src, null))
			O.show_message(text("\red [] has grabbed [] passively!", M, src), 1)

	else if (M.a_intent == "hurt")
		var/damage = rand(5, 10)
		if (prob(90))
		/*
			if (M.class == "combat")
				damage += 15
				if(prob(20))
					src.weakened = max(src.weakened,4)
					src.stunned = max(src.stunned,4)
		*/
			playsound(src.loc, 'sound/weapons/slash.ogg', 25, 1, -1)
			for(var/mob/O in viewers(src, null))
				O.show_message(text("\red <B>[] has slashed at []!</B>", M, src), 1)
			if(prob(8))
				flick("noise", src.flash)
			src.adjustBruteLoss(damage)
			src.updatehealth()
		else
			playsound(src.loc, 'sound/weapons/slashmiss.ogg', 25, 1, -1)
			for(var/mob/O in viewers(src, null))
				O.show_message(text("\red <B>[] took a swipe at []!</B>", M, src), 1)
			return

	else if (M.a_intent == "disarm")
		if(!(src.lying))
			var/randn = rand(1, 100)
			if (randn <= 40)
				src.stunned = 5
				step(src,get_dir(M,src))
				spawn(5) step(src,get_dir(M,src))
				playsound(src.loc, 'sound/weapons/slash.ogg', 50, 1, -1)
				for(var/mob/O in viewers(src, null))
					O.show_message(text("\red <B>[] has pushed back []!</B>", M, src), 1)
			else
				playsound(src.loc, 'sound/weapons/slashmiss.ogg', 25, 1, -1)
				for(var/mob/O in viewers(src, null))
					O.show_message(text("\red <B>[] attempted to push back []!</B>", M, src), 1)
	return

/mob/living/silicon/hivebot/attack_hand(mob/user)
	..()
	return


/mob/living/silicon/hivebot/proc/allowed(mob/M)
	//check if it doesn't require any access at all
	if(src.check_access(null))
		return 1
	return 0

/mob/living/silicon/hivebot/proc/check_access(obj/item/weapon/card/id/I)
	if(!istype(src.req_access, /list)) //something's very wrong
		return 1

	var/list/L = src.req_access
	if(!L.len) //no requirements
		return 1
	if(!I || !istype(I, /obj/item/weapon/card/id) || !I.access) //not ID or no access
		return 0
	for(var/req in src.req_access)
		if(!(req in I.access)) //doesn't have this access
			return 0
	return 1

/mob/living/silicon/hivebot/proc/updateicon()

	src.overlays = null

	if(src.stat == 0)
		src.overlays += "eyes"
	else
		src.overlays -= "eyes"


/mob/living/silicon/hivebot/proc/installed_modules()

	if(!src.module)
		src.pick_module()
		return
	var/dat = "<HEAD><TITLE>Modules</TITLE><META HTTP-EQUIV='Refresh' CONTENT='10'></HEAD><BODY>\n"
	dat += {"<A HREF='?src=\ref[src];mach_close=robotmod'>Close</A>
	<BR>
	<BR>
	<B>Activated Modules</B>
	<BR>
	Module 1: [module_state_1 ? "<A HREF=?src=\ref[src];mod=\ref[module_state_1]>[module_state_1]<A>" : "No Module"]<BR>
	Module 2: [module_state_2 ? "<A HREF=?src=\ref[src];mod=\ref[module_state_2]>[module_state_2]<A>" : "No Module"]<BR>
	Module 3: [module_state_3 ? "<A HREF=?src=\ref[src];mod=\ref[module_state_3]>[module_state_3]<A>" : "No Module"]<BR>
	<BR>
	<B>Installed Modules</B><BR><BR>"}

	for (var/obj in src.module.modules)
		if(src.activated(obj))
			dat += text("[obj]: <B>Activated</B><BR>")
		else
			dat += text("[obj]: <A HREF=?src=\ref[src];act=\ref[obj]>Activate</A><BR>")
/*
		if(src.activated(obj))
			dat += text("[obj]: \[<B>Activated</B> | <A HREF=?src=\ref[src];deact=\ref[obj]>Deactivate</A>\]<BR>")
		else
			dat += text("[obj]: \[<A HREF=?src=\ref[src];act=\ref[obj]>Activate</A> | <B>Deactivated</B>\]<BR>")
*/
	src << browse(dat, "window=robotmod&can_close=0")


/mob/living/silicon/hivebot/Topic(href, href_list)
	..()
	if (href_list["mach_close"])
		var/t1 = text("window=[href_list["mach_close"]]")
		src.machine = null
		src << browse(null, t1)
		return

	if (href_list["mod"])
		var/obj/item/O = locate(href_list["mod"])
		O.attack_self(src)

	if (href_list["act"])
		var/obj/item/O = locate(href_list["act"])
		if(activated(O))
			src << "Already activated"
			return
		if(!src.module_state_1)
			src.module_state_1 = O
			O.layer = 20
			src.contents += O
		else if(!src.module_state_2)
			src.module_state_2 = O
			O.layer = 20
			src.contents += O
		else if(!src.module_state_3)
			src.module_state_3 = O
			O.layer = 20
			src.contents += O
		else
			src << "You need to disable a module first!"
		src.installed_modules()

	if (href_list["deact"])
		var/obj/item/O = locate(href_list["deact"])
		if(activated(O))
			if(src.module_state_1 == O)
				src.module_state_1 = null
				src.contents -= O
			else if(src.module_state_2 == O)
				src.module_state_2 = null
				src.contents -= O
			else if(src.module_state_3 == O)
				src.module_state_3 = null
				src.contents -= O
			else
				src << "Module isn't activated."
		else
			src << "Module isn't activated"
		src.installed_modules()
	return

/mob/living/silicon/hivebot/proc/uneq_active()
	if(isnull(src.module_active))
		return
	if(src.module_state_1 == src.module_active)
		if (src.client)
			src.client.screen -= module_state_1
		src.contents -= module_state_1
		src.module_active = null
		src.module_state_1 = null
		src.inv1.icon_state = "inv1"
	else if(src.module_state_2 == src.module_active)
		if (src.client)
			src.client.screen -= module_state_2
		src.contents -= module_state_2
		src.module_active = null
		src.module_state_2 = null
		src.inv2.icon_state = "inv2"
	else if(src.module_state_3 == src.module_active)
		if (src.client)
			src.client.screen -= module_state_3
		src.contents -= module_state_3
		src.module_active = null
		src.module_state_3 = null
		src.inv3.icon_state = "inv3"


/mob/living/silicon/hivebot/proc/activated(obj/item/O)
	if(src.module_state_1 == O)
		return 1
	else if(src.module_state_2 == O)
		return 1
	else if(src.module_state_3 == O)
		return 1
	else
		return 0

/mob/living/silicon/hivebot/proc/radio_menu()
	var/dat = {"
<TT>
Microphone: [src.radio.broadcasting ? "<A href='byond://?src=\ref[src.radio];talk=0'>Engaged</A>" : "<A href='byond://?src=\ref[src.radio];talk=1'>Disengaged</A>"]<BR>
Speaker: [src.radio.listening ? "<A href='byond://?src=\ref[src.radio];listen=0'>Engaged</A>" : "<A href='byond://?src=\ref[src.radio];listen=1'>Disengaged</A>"]<BR>
Frequency:
<A href='byond://?src=\ref[src.radio];freq=-10'>-</A>
<A href='byond://?src=\ref[src.radio];freq=-2'>-</A>
[format_frequency(src.radio.frequency)]
<A href='byond://?src=\ref[src.radio];freq=2'>+</A>
<A href='byond://?src=\ref[src.radio];freq=10'>+</A><BR>
-------
</TT>"}
	src << browse(dat, "window=radio")
	onclose(src, "radio")
	return


/mob/living/silicon/hivebot/Move(a, b, flag)

	if (src.buckled)
		return

	if (src.restrained())
		src.stop_pulling()

	var/t7 = 1
	if (src.restrained())
		for(var/mob/M in range(src, 1))
			if ((M.pulling == src && M.stat == 0 && !( M.restrained() )))
				t7 = null
	if ((t7 && (src.pulling && ((get_dist(src, src.pulling) <= 1 || src.pulling.loc == src.loc) && (src.client && src.client.moving)))))
		var/turf/T = src.loc
		. = ..()

		if (src.pulling && src.pulling.loc)
			if(!( isturf(src.pulling.loc) ))
				src.stop_pulling()
				return
			else
				if(Debug)
					diary <<"src.pulling disappeared? at [__LINE__] in mob.dm - src.pulling = [src.pulling]"
					diary <<"REPORT THIS"

		/////
		if(src.pulling && src.pulling.anchored)
			src.stop_pulling()
			return

		if (!src.restrained())
			var/diag = get_dir(src, src.pulling)
			if ((diag - 1) & diag)
			else
				diag = null
			if ((get_dist(src, src.pulling) > 1 || diag))
				if (ismob(src.pulling))
					var/mob/M = src.pulling
					var/ok = 1
					if (locate(/obj/item/weapon/grab, M.grabbed_by))
						if (prob(75))
							var/obj/item/weapon/grab/G = pick(M.grabbed_by)
							if (istype(G, /obj/item/weapon/grab))
								for(var/mob/O in viewers(M, null))
									O.show_message(text("\red [G.affecting] has been pulled from [G.assailant]'s grip by [src]"), 1)
								del(G)
						else
							ok = 0
						if (locate(/obj/item/weapon/grab, M.grabbed_by.len))
							ok = 0
					if (ok)
						var/atom/movable/t = M.pulling
						M.stop_pulling()
						step(src.pulling, get_dir(src.pulling.loc, T))
						M.start_pulling(t)
				else
					if (src.pulling)
						step(src.pulling, get_dir(src.pulling.loc, T))
	else
		src.stop_pulling()
		. = ..()
	if ((src.s_active && !( s_active in src.contents ) ))
		src.s_active.close(src)
	return


/mob/living/silicon/hivebot/verb/cmd_return_mainframe()
	set category = "Robot Commands"
	set name = "Recall to Mainframe."
	return_mainframe()

/mob/living/silicon/hivebot/proc/return_mainframe()
	if(mainframe)
		mainframe.return_to(src)
	else
		src << "\red You lack a dedicated mainframe!"
		return