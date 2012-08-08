/mob/dead/observer/New(mob/body, var/safety = 0)
	invisibility = 10
	sight |= SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_SELF
	see_invisible = 15
	see_in_dark = 100
	verbs += /mob/dead/observer/proc/dead_tele
	verbs += /mob/dead/observer/proc/become_mouse
	taj_talk_understand = 1

	if(body)
		var/turf/location = get_turf(body)//Where is the mob located?
		if(location)//Found turf.
			loc = location
		else//Safety, in case a turf cannot be found.
			loc = pick(latejoin)
		if(!istype(body,/mob))	return//This needs to be recoded sometime so it has loc as its first arg
		real_name = body.name
		if(!body.original_name)
			body.original_name = real_name
		original_name = body.original_name
		//name = body.original_name		//original
		if(issimpleanimal(body))
			name = original_name
		else
			name = body.name
		real_name = body.real_name

		if(!name)
			name = capitalize(pick(first_names_male) + " " + capitalize(pick(last_names)))
			real_name = name

		if( original_name != real_name )
			name = name + " (died as [src.real_name])"

		if(!safety)
			corpse = body
			verbs += /mob/dead/observer/proc/reenter_corpse
		return

/mob/dead/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	return 1
/*
Transfer_mind is there to check if mob is being deleted/not going to have a body.
Works together with spawning an observer, noted above.
*/

/mob/proc/ghostize(var/transfer_mind = 0)
	if(key)
		if(client)
			client.screen.len = null//Clear the hud, just to be sure.
		var/mob/dead/observer/ghost = new(src,transfer_mind)//Transfer safety to observer spawning proc.
		if(transfer_mind)//When a body is destroyed.
			if(mind)
				mind.transfer_to(ghost)
			else//They may not have a mind and be gibbed/destroyed.
				ghost.key = key
		else//Else just modify their key and connect them.
			ghost.key = key

		verbs -= /mob/proc/ghost
		if (ghost.client)
			ghost.client.eye = ghost

	else if(transfer_mind)//Body getting destroyed but the person is not present inside.
		for(var/mob/dead/observer/O in world)
			if(O.corpse == src&&O.key)//If they have the same corpse and are keyed.
				if(mind)
					O.mind = mind//Transfer their mind if they have one.
				break
	return

/*
This is the proc mobs get to turn into a ghost. Forked from ghostize due to compatibility issues.
*/
/mob/proc/ghost()
	set category = "Ghost"
	set name = "Ghost"

	/*if(stat != 2) //this check causes nothing but troubles. Commented out for Nar-Sie's sake. --rastaf0
		src << "Only dead people and admins get to ghost, and admins don't use this verb to ghost while alive."
		return*/
	if(key)
		var/mob/dead/observer/ghost = new(src)
		ghost.key = key
		if(timeofdeath)
			ghost.timeofdeath = timeofdeath
		verbs -= /mob/proc/ghost
		if (ghost.client)
			ghost.client.eye = ghost
		/*if(issimpleanimal(src))
			ghost.name = src.name + " ([src.real_name])"
			ghost.voice_name = src.name + " ([src.real_name])"*/
	return

/mob/proc/adminghostize()
	if(client)
		client.mob = new/mob/dead/observer(src)
	return

/mob/dead/observer/Move(NewLoc, direct)
	if(NewLoc)
		loc = NewLoc
		for(var/obj/effect/step_trigger/S in NewLoc)
			S.HasEntered(src)

		return
	loc = get_turf(src) //Get out of closets and such as a ghost
	if((direct & NORTH) && y < world.maxy)
		y++
	if((direct & SOUTH) && y > 1)
		y--
	if((direct & EAST) && x < world.maxx)
		x++
	if((direct & WEST) && x > 1)
		x--

	for(var/obj/effect/step_trigger/S in locate(x, y, z))
		S.HasEntered(src)

/mob/dead/observer/examine()
	if(usr)
		usr << desc

/mob/dead/observer/can_use_hands()	return 0
/mob/dead/observer/is_active()		return 0

/mob/dead/observer/Stat()
	..()
	statpanel("Status")
	if (client.statpanel == "Status")
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
	set category = "Ghost"
	set name = "Re-enter Corpse"
	if(!corpse)
		alert("You don't have a corpse!")
		return
	if(client && client.holder && client.holder.state == 2)
		var/rank = client.holder.rank
		client.clear_admin_verbs()
		client.holder.state = 1
		client.update_admins(rank)
	if(iscultist(corpse) && corpse.ajourn==1 && corpse.stat!=2) //checks if it's an astral-journeying cultistm if it is and he's not on an astral journey rune, re-entering won't work
		var/S=0
		for(var/obj/effect/rune/R in world)
			if(corpse.loc==R.loc && R.word1 == wordhell && R.word2 == wordtravel && R.word3 == wordself)
				S=1
		if(!S)
			usr << "\red The astral cord that ties your body and your spirit has been severed. You are likely to wander the realm beyond until your body is finally dead and thus reunited with you."
			return
	if(corpse.ajourn)
		corpse.ajourn=0
	client.mob = corpse
	if (corpse.stat==2)
		verbs += /mob/proc/ghost
	del(src)

/mob/dead/observer/proc/become_mouse()
	set category = "Ghost"
	set name = "Become mouse"

	//locate an empty mouse
	var/list/eligible_targets = new()
	for(var/mob/living/simple_animal/mouse/M in world)
		if(!M.ckey && !M.stat)
			eligible_targets.Add(M)

	var/mob/living/simple_animal/mouse/target_mouse
	if(ticker.spawn_vermin)
		if(eligible_targets.len)
			//grab a random existing one
			target_mouse = pick(eligible_targets)
		else
			//make a new mouse
			target_mouse = new(pick(ticker.vermin_spawn_turfs))

	if(target_mouse)
		//move player into mouse
		//the mouse ai will deactivate itself
		client.mob = target_mouse
		target_mouse.original_name = src.original_name

		//reset admin verbs
		if(client && client.holder && client.holder.state == 2)
			var/rank = client.holder.rank
			client.clear_admin_verbs()
			client.holder.state = 1
			client.update_admins(rank)

		//update allowed verbs
		target_mouse.verbs += /mob/proc/ghost
		target_mouse.verbs -= /mob/verb/observe
		target_mouse.verbs -= /client/verb/toggle_ghost_ears
		target_mouse.verbs -= /client/verb/toggle_ghost_sight

		del(src)

	else
		client << "\red Unable to become a mouse!"

/mob/dead/observer/proc/dead_tele()
	set category = "Ghost"
	set name = "Teleport"
	set desc= "Teleport to a location"
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

/mob/dead/observer/verb/jumptomob() //Moves the ghost instead of just changing the ghosts's eye -Nodrak
	set category = "Ghost"
	set name = "Jump to Mob"
	set desc = "Teleport to a mob"

	if(istype(usr, /mob/dead/observer)) //Make sure they're an observer!


		var/list/dest = list() //List of possible destinations (mobs)
		var/target = null	   //Chosen target.

		dest += getmobs() //Fill list, prompt user with list
		target = input("Please, select a player!", "Jump to Mob", null, null) as null|anything in dest

		if (!target)//Make sure we actually have a target
			return
		else
			var/mob/M = dest[target] //Destination mob
			var/mob/A = src			 //Source mob
			var/turf/T = get_turf(M) //Turf of the destination mob

			if(T && isturf(T))	//Make sure the turf exists, then move the source to that destination.
				A.loc = T
			else
				A << "This mob is not located in the game world."


/mob/dead/observer/verb/toggle_alien_candidate()
	set name = "Toggle Be Alien Candidate"
	set category = "Ghost"
	set desc = "Determines whether you will or will not be an alien candidate when someone bursts."
	if(client.be_alien)
		client.be_alien = 0
		src << "You are now excluded from alien candidate lists until end of round."
	else if(!client.be_alien)
		client.be_alien = 1
		src << "You are now included in alien candidate lists until end of round."

/mob/dead/observer/verb/toggle_pai_candidate()
	set name = "Toggle Be pAI Candidate"
	set category = "Ghost"
	set desc = "Receive a pop-up request when a pAI device requests a new personality. (toggle)"
	if(client.be_pai)
		client.be_pai = 0
		src << "You will no longer receive pAI recruitment pop-ups this round."
	else
		client.be_pai = 1
		src << "You will now be considered a viable candidate when a pAI device requests a new personality, effective until the end of this round."

/mob/dead/observer/memory()
	set hidden = 1
	src << "\red You are dead! You have no mind to store memory!"

/mob/dead/observer/add_memory()
	set hidden = 1
	src << "\red You are dead! You have no mind to store memory!"

