/mob/dead/observer/New(mob/body, var/safety = 0)
	invisibility = 10
	sight |= SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_SELF
	see_invisible = 15
	see_in_dark = 100
	verbs += /mob/dead/observer/proc/dead_tele
	stat = DEAD

	dead_mob_list += src
	add_to_mob_list(src)
	if(body)
		var/turf/T = get_turf(body)			//Where is the body located?
		if(!T)	T = pick(latejoin)			//Safety in case we cannot find the body's position
		loc = T
		if(ismob(body))
			real_name = body.real_name
			original_name = body.original_name	//Original name is only used in ghost chat! It is not to be edited by anything!
			name = body.original_name
			if(!safety)
				corpse = body
		if(!name)							//To prevent nameless ghosts
			name = capitalize(pick(first_names_male) + " " + capitalize(pick(last_names)))
			real_name = name
		return

/mob/dead/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	return 1
/*
Transfer_mind is there to check if mob is being deleted/not going to have a body.
Works together with spawning an observer, noted above.
*/

/mob/proc/ghostize(var/transfer_mind = 0)
	if(key)
		var/mob/dead/observer/ghost = new(src,transfer_mind)	//Transfer safety to observer spawning proc.
		ghost.attack_log = attack_log			//preserve our attack logs by copying them to our ghost
		if(transfer_mind && mind)				//When a body is destroyed attempt to transfer their mind
			mind.transfer_to(ghost)
		else									//Else just modify their key and connect them.
			ghost.key = key

	else if(transfer_mind)						//Body getting destroyed but the person is not present inside.
		for(var/mob/dead/observer/O in dead_mob_list)
			if(O.corpse == src && O.key)		//If they have the same corpse and are keyed.
				if(mind)
					O.mind = mind				//Transfer their mind if they have one.
				break
	return

/*
This is the proc mobs get to turn into a ghost. Forked from ghostize due to compatibility issues.
*/
/mob/living/verb/ghost()
	set category = "OOC"
	set name = "Ghost"
	set desc = "Relinquish your life and enter the land of the dead."

	if(stat == DEAD)
		ghostize(0)
	else
		var/response = alert(src, "Are you -sure- you want to ghost?\n(You are alive. If you ghost whilst still alive you may not play again this round! You can't change your mind so choose wisely!!)","Are you sure you want to ghost?","Ghost","Stay in body")
		if(response != "Ghost")	return	//didn't want to ghost after-all
		ghostize(1)						//safety is on so we can never re-enter our body, "Charlie, you can never come baaaack~" :3
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
		stat(null, "Station Time: [worldtime2text()]")
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

/mob/dead/observer/verb/reenter_corpse()
	set category = "Ghost"
	set name = "Re-enter Corpse"
	if(!client)	return
	if(!corpse)
		src << "<span class='warning'>Sorry, you don't have a corpse to re-enter.</span>"
		return
	if(client.holder && client.holder.state == 2)
		var/rank = client.holder.rank
		client.clear_admin_verbs()
		client.holder.state = 1
		client.update_admins(rank)

	if(iscultist(corpse) && corpse.ajourn==1 && corpse.stat != DEAD) //checks if it's an astral-journeying cultistm if it is and he's not on an astral journey rune, re-entering won't work
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
	remove_from_mob_list(src)
	dead_mob_list -= src
	del(src)

/mob/dead/observer/proc/dead_tele()
	set category = "Ghost"
	set name = "Teleport"
	set desc= "Teleport to a location"
	if(!istype(usr, /mob/dead/observer))
		usr << "Not when you're not dead!"
		return
	usr.verbs -= /mob/dead/observer/proc/dead_tele
	spawn(30)
		usr.verbs += /mob/dead/observer/proc/dead_tele
	var/A
	A = input("Area to jump to", "BOOYEA", A) as null|anything in ghostteleportlocs
	var/area/thearea = ghostteleportlocs[A]
	if(!thearea)	return

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
		target = input("Please, select a player!", "Jump to Mob", null, null) as null|anything in sortList(dest)

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

/mob/dead/observer/verb/boo()
	set category = "Ghost"
	set name = "Boo!"
	set desc= "Scare your crew members because of boredom!"

	if(bootime > world.time) return
	var/obj/machinery/light/L = locate(/obj/machinery/light) in view(1, src)
	if(L)
		L.flicker()
		bootime = world.time + 600
		return
	//Maybe in the future we can add more <i>spooky</i> code here!
	return

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