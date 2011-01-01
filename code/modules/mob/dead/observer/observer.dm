/mob/dead/observer/New(mob/corpse)
	src.invisibility = 10
	src.sight |= SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_SELF
	src.see_invisible = 15
	src.see_in_dark = 100
	src.verbs += /mob/dead/observer/proc/dead_tele

	if(corpse)
		src.corpse = corpse
		src.loc = get_turf(corpse.loc)
		src.real_name = corpse.real_name
		src.name = corpse.real_name
		src.verbs += /mob/dead/observer/proc/reenter_corpse

/mob/proc/ghostize()
	set category = "Special Verbs"
	set name = "Ghost"
	set desc = "You cannot be revived as a ghost"
	if(src.client)
		src.client.mob = new/mob/dead/observer(src)
	return

/mob/dead/observer/Move(NewLoc, direct)
	if(NewLoc)
		src.loc = NewLoc
		return
	if((direct & NORTH) && src.y < world.maxy)
		src.y++
	if((direct & SOUTH) && src.y > 1)
		src.y--
	if((direct & EAST) && src.x < world.maxx)
		src.x++
	if((direct & WEST) && src.x > 1)
		src.x--

/mob/dead/observer/examine()
	if(usr)
		usr << src.desc

/mob/dead/observer/can_use_hands()	return 0
/mob/dead/observer/is_active()		return 0

/mob/dead/observer/Stat()
	..()
	statpanel("Status")
	if (src.client.statpanel == "Status")
		if(ticker.mode != null)
			//world << "DEBUG: ticker not null"
			if(ticker.mode.name == "AI malfunction")
				//world << "DEBUG: malf mode ticker test"
				if(ticker.mode:malf_mode_declared)
					stat(null, "Time left: [max(ticker.mode:AI_win_timeleft/(ticker.mode:apcs/3), 0)]")
		if(emergency_shuttle)
			if(emergency_shuttle.online && emergency_shuttle.location < 2)
				var/timeleft = emergency_shuttle.timeleft()
				if (timeleft)
					stat(null, "ETA-[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]")

/mob/dead/observer/proc/reenter_corpse()
	set category = "Special Verbs"
	set name = "Re-enter Corpse"
	if(!corpse)
		alert("You don't have a corpse!")
		return
//	if(corpse.stat == 2)
//		alert("Your body is dead!")
//		return
	if(src.client && src.client.holder && src.client.holder.state == 2)
		var/rank = src.client.holder.rank
		src.client.clear_admin_verbs()
		src.client.holder.state = 1
		src.client.update_admins(rank)
	if(cultists.Find(corpse) && corpse.ajourn==1 && corpse.health>-100) //checks if it's an astral-journeying cultistm if it is and he's not on an astral journey rune, re-entering won't work
		var/S=0
		for(var/obj/rune/R in world)
			if(corpse.loc==R.loc && R.word1 == wordhell && R.word2 == wordtravel && R.word3 == wordself)
				S=1
		if(!S)
			usr << "\red The astral cord that ties your body and your spirit has been severed. You are likely to wander the realm beyond until your body is finally dead and thus reunited with you."
			return
	if(corpse.ajourn)
		corpse.ajourn=0
	src.client.mob = corpse
	del(src)

/mob/dead/observer/proc/dead_tele()
	set category = "Special Verbs"
	set name = "Teleport"
	set desc= "Teleport"
	if((usr.stat != 2) || !istype(usr, /mob/dead/observer))
		usr << "Not when you're not dead!"
		return
	var/A
	usr.verbs -= /mob/dead/observer/proc/dead_tele
	spawn(50)
		usr.verbs += /mob/dead/observer/proc/dead_tele
	A = input("Area to jump to", "BOOYEA", A) in list("Engine","Hallways","Toxins","Storage","Maintenance","Crew Quarters","Medical","Security","Chapel","Bridge","AI Satellite","Thunderdome","Derelict")

	switch (A)
		if ("Engine")
			var/list/L = list()
			for(var/area/B in world)
				if(istype(B, /area/engine) && !istype(B, /area/engine/combustion) && !istype(B, /area/engine/engine_walls))
					L += B
			A = pick(L)
		if ("Hallways")
			var/list/L = list()
			for(var/area/B in world)
				if(istype(B, /area/hallway))
					L += B
			A = pick(L)
		if ("Toxins")
			var/list/L = list()
			for(var/area/B in world)
				if(istype(B, /area/toxins) && !istype(B, /area/toxins/test_area))
					L += B
			A = pick(L)
		if ("Storage")
			var/list/L = list()
			for(var/area/B in world)
				if(istype(B, /area/storage))
					L += B
			A = pick(L)
		if ("Maintenance")
			var/list/L = list()
			for(var/area/B in world)
				if(istype(B, /area/maintenance))
					L += B
			A = pick(L)
		if ("Crew Quarters")
			var/list/L = list()
			for(var/area/B in world)
				if(istype(B, /area/crew_quarters))
					L += B
			A = pick(L)
		if ("Medical")
			var/list/L = list()
			for(var/area/B in world)
				if(istype(B, /area/medical))
					L += B
			A = pick(L)
		if ("Security")
			var/list/L = list()
			for(var/area/B in world)
				if(istype(B, /area/security))
					L += B
			A = pick(L)
		if ("Chapel")
			var/list/L = list()
			for(var/area/B in world)
				if(istype(B, /area/chapel))
					L += B
			A = pick(L)
		if ("Bridge")
			var/list/L = list()
			for(var/area/B in world)
				if(istype(B, /area/bridge))
					L += B
			A = pick(L)
		if ("AI Satellite")
			var/list/L = list()
			for(var/area/B in world)
				if(istype(B, /area/turret_protected/aisat))
					L += B
			A = pick(L)
		if ("Thunderdome")
			var/list/L = list()
			for(var/area/B in world)
				if(istype(B, /area/tdome))
					L += B
			A = pick(L)
		if ("Derelict")
			var/list/L = list()
			for(var/area/B in world)
				if(istype(B, /area/derelict))
					L += B
			A = pick(L)

	var/list/Q = list()
	for(var/turf/T in A)
		var/clear = 1
		if(clear)
			Q+=T
//	A = pick(Q)
	if (Q.len)
		usr.loc = pick(Q)
	else
		usr << "Teleporting to that area doesn't seem to be working currently. But at least now it tells you that."

var/list/karma_spenders = list()

/mob/dead/observer/verb/spend_karma(var/mob/M in world) // Karma system -- TLE
	set name = "Spend Karma"
	set desc = "Let the gods know whether someone's been naughty or nice. <One use only>"
	if(!istype(M, /mob))
		usr << "\red That's not a mob. You shouldn't have even been able to specify that. Please inform your server administrator post haste."
		return

	if(!M.client)
		usr << "\red That mob has no client connected at the moment."
		return
	if(src.client.karma_spent)
		usr << "\red You've already spent your karma for the round."
		return
	for(var/a in karma_spenders)
		if(a == src.key)
			usr << "\red You've already spent your karma for the round."
			return
	if(M.key == src.key)
		usr << "\red You can't spend karma on yourself!"
		return
	var/choice = input("Give [M.name] good karma or bad karma?", "Karma") in list("Good", "Bad", "Cancel")
	if(!choice || choice == "Cancel")
		return
	if(choice == "Good")
		M.client.karma += 1
	if(choice == "Bad")
		M.client.karma -= 1
	usr << "[choice] karma spent on [M.name]."
	src.client.karma_spent = 1
	karma_spenders.Add(src.key)
	if(M.client.karma <= -2 || M.client.karma >= 2)
		var/special_role = "None"
		var/assigned_role = "None"
		var/karma_diary = file("data/logs/karma_[time2text(world.realtime, "YYYY/MM-Month/DD-Day")].log")
		if(M.mind)
			if(M.mind.special_role)
				special_role = M.mind.special_role
			if(M.mind.assigned_role)
				assigned_role = M.mind.assigned_role
		karma_diary << "[M.name] ([M.key]) [assigned_role]/[special_role]: [M.client.karma] - [time2text(world.timeofday, "hh:mm:ss")]"
	var/isnegative = 1
	if(choice == "Good")
		isnegative = 0
	else
		isnegative = 1
	sql_report_karma(src, M, isnegative)

/mob/dead/observer/verb/toggle_alien_candidate()
	set name = "Toggle Be Alien Candidate"
	set desc = "Determines whether you will or will not be an alien candidate when someone bursts."
	if(src.client.be_alien)
		src.client.be_alien = 0
		src << "You are now excluded from alien candidate lists until end of round."
	else if(!src.client.be_alien)
		src.client.be_alien = 1
		src << "You are now included in alien candidate lists until end of round."