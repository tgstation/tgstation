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
	/*if(src.stat != 2) //this check causes nothing but troubles. Commented out for Nar-Sie's sake. --rastaf0
		src << "Only dead people and admins get to ghost, and admins don't use this verb to ghost while alive."
		return*/
	if(src.client)
		src.client.mob = new/mob/dead/observer(src)
		src.verbs -= /mob/proc/ghostize
	return

/mob/proc/adminghostize()
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
		if(ticker)
			if(ticker.mode)
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
	if(iscultist(corpse) && corpse.ajourn==1 && corpse.stat!=2) //checks if it's an astral-journeying cultistm if it is and he's not on an astral journey rune, re-entering won't work
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
	if (corpse.stat==2)
		src.verbs += /mob/proc/ghostize
	del(src)

/mob/dead/observer/proc/dead_tele()
	set category = "Special Verbs"
	set name = "Teleport"
	set desc= "Teleport"
	if((usr.stat != 2) || !istype(usr, /mob/dead/observer))
		usr << "Not when you're not dead!"
		return
	usr.verbs -= /mob/dead/observer/proc/dead_tele
	spawn(30)
		usr.verbs += /mob/dead/observer/proc/dead_tele
	var/A
	A = input("Area to jump to", "BOOYEA", A) in ghostteleportlocs
	var/area/thearea = ghostteleportlocs[A]

	var/list/L = list()
	for(var/turf/T in get_area_turfs(thearea.type))
		L+=T
	usr.loc = pick(L)

var/list/karma_spenders = list()

/mob/dead/observer/verb/spend_karma(var/mob/M in world) // Karma system -- TLE
	set name = "Spend Karma"
	set category = "Special Verbs"
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
	set category = "OOC"
	set desc = "Determines whether you will or will not be an alien candidate when someone bursts."
	if(src.client.be_alien)
		src.client.be_alien = 0
		src << "You are now excluded from alien candidate lists until end of round."
	else if(!src.client.be_alien)
		src.client.be_alien = 1
		src << "You are now included in alien candidate lists until end of round."

/mob/dead/observer/memory()
	set hidden = 1
	src << "\red You are dead! You have no mind to store memory!"

/mob/dead/observer/add_memory()
	set hidden = 1
	src << "\red You are dead! You have no mind to store memory!"

