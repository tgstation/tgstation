
/mob/camera/god
	name = "deity" //Auto changes to the player's deity name/random name
	real_name = "deity"
	icon = 'icons/mob/mob.dmi'
	icon_state = "marker"
	invisibility = 60
	see_in_dark = 0
	see_invisible = 55
	sight = SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_SELF
	languages_spoken = ALL
	languages_understood = ALL
	hud_possible = list(ANTAG_HUD)
	mouse_opacity = 0 //can't be clicked

	var/faith = 100 //For initial prophet appointing/stupid purchase
	var/max_faith = 100
	var/side = "neutral" //Red or Blue for the gamemode
	var/obj/structure/divine/nexus/god_nexus = null //The source of the god's power in this realm, kill it and the god is kill
	var/nexus_required = FALSE //If the god dies from losing it's nexus, defaults to off so that gods don't instantly die at roundstart
	var/followers_required = 0 //Same as above
	var/alive_followers = 0
	var/list/structures = list()
	var/list/conduits = list()
	var/prophets_sacrificed_in_name = 0
	var/image/ghostimage = null //For observer with darkness off visiblity
	var/list/prophets = list()
	var/datum/action/innate/godspeak/speak2god

/mob/camera/god/New()
	..()
	update_icons()
	build_hog_construction_lists()

	//Force nexuses after 15 minutes in hand of god mode
	if(ticker && ticker.mode && ticker.mode.name == "hand of god")
		addtimer(src, "forceplacenexus", 9000, FALSE)


//Rebuilds the list based on the gamemode's lists
//As they are the most accurate each tick
/mob/camera/god/proc/get_my_followers()
	switch(side)
		if("red")
			. = ticker.mode.red_deity_followers|ticker.mode.red_deity_prophets
		if("blue")
			. = ticker.mode.blue_deity_followers|ticker.mode.blue_deity_prophets
		else
			. = list()


/mob/camera/god/Destroy()
	var/list/followers = get_my_followers()
	for(var/datum/mind/F in followers)
		if(F.current)
			F.current << "<span class='danger'>Your god is DEAD!</span>"
	for(var/X in prophets)
		speak2god.Remove(X)
	ghost_darkness_images -= ghostimage
	updateallghostimages()
	return ..()



/mob/camera/god/proc/forceplacenexus()
	if(god_nexus)
		return

	if(ability_cost(0,1,0))
		place_nexus()

	else
		if(blobstart.len) //we're on invalid turf, try to pick from blobstart
			loc = pick(blobstart)
		place_nexus() //if blobstart fails, places on dense turf, but better than nothing
	src << "<span class='danger'>You failed to place your nexus, and it has been placed for you!</span>"


/mob/camera/god/update_icons()
	icon_state = "[initial(icon_state)]-[side]"

	if(ghostimage)
		ghost_darkness_images -= ghostimage

	ghostimage = image(src.icon,src,src.icon_state)
	ghost_darkness_images |= ghostimage
	updateallghostimages()


/mob/camera/god/Stat()
	..()
	if(statpanel("Status"))
		if(god_nexus)
			stat("Nexus health: ", god_nexus.health)
		stat("Followers: ", alive_followers)
		stat("Faith: ", "[faith]/[max_faith]")


/mob/camera/god/Login()
	..()
	sync_mind()
	src << "<span class='notice'>You are a deity!</span>"
	src << "You are a deity and are worshipped by a cult!  You are rather weak right now, but that will change as you gain more followers."
	src << "You will need to place an anchor to this world, a <b>Nexus</b>, in two minutes.  If you don't, one will be placed immediately below you."
	src << "Your <b>Follower</b> count determines how many people believe in you and are a part of your cult."
	src << "Your <b>Nexus Integrity</b> tells you the condition of your nexus.  If your nexus is destroyed, you will die. Place your Nexus on a safe, isolated place, that is still accessible to your followers."
	src << "Your <b>Faith</b> is used to interact with the world.  This will regenerate on its own, and it goes faster when you have more followers and power pylons."
	src << "The first thing you should do after placing your nexus is to <b>appoint a prophet</b>.  Only prophets can hear you talk, unless you use an expensive power."
	update_health_hud()


/mob/camera/god/update_health_hud()
	if(god_nexus && hud_used && hud_used.healths)
		hud_used.healths.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'> <font color='lime'>[god_nexus.health]   </font></div>"


/mob/camera/god/proc/add_faith(faith_amt)
	if(faith_amt)
		faith = round(Clamp(faith+faith_amt, 0, max_faith))
		if(hud_used && hud_used.deity_power_display)
			hud_used.deity_power_display.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'> <font color='cyan'>[faith]  </font></div>"



/mob/camera/god/proc/place_nexus()
	if(god_nexus || (z != 1))
		return 0

	var/obj/structure/divine/nexus/N = new(get_turf(src))
	N.assign_deity(src)
	god_nexus = N
	nexus_required = TRUE
	verbs -= /mob/camera/god/verb/constructnexus
	//verbs += /mob/camera/god/verb/movenexus //Translocators have no sprite
	update_health_hud()

	var/area/A = get_area(src)
	if(A)
		var/areaname = A.name
		var/list/followers = get_my_followers()
		for(var/datum/mind/F in followers)
			if(F.current)
				F.current << "<span class='boldnotice'>Your god's nexus is in \the [areaname]</span>"


/mob/camera/god/verb/freeturret()
	set category = "Deity"
	set name = "Free Turret (0)"
	set desc = "Place a single turret, for 0 faith."

	if(!ability_cost(0,1,1))
		return
	var/obj/structure/divine/defensepylon/DP = new(get_turf(src))
	DP.assign_deity(src)
	verbs -= /mob/camera/god/verb/freeturret



/mob/camera/god/proc/update_followers()
	alive_followers = 0
	var/list/all_followers = get_my_followers()
	for(var/datum/mind/F in all_followers)
		if(F.current && F.current.stat != DEAD)
			alive_followers++

	if(hud_used && hud_used.deity_follower_display)
		hud_used.deity_follower_display.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'> <font color='red'>[alive_followers]     </font></div>"


/mob/camera/god/proc/check_death()
	if(!alive_followers)
		src << "<span class='userdanger'>You no longer have any followers. You shudder as you feel your existence cease...</span>"
		if(god_nexus && !qdeleted(god_nexus))
			god_nexus.visible_message("<span class='danger'>\The [src] suddenly disappears!</span>")
			qdel(god_nexus)
		qdel(src)


/mob/camera/god/say(msg)
	if(!msg)
		return
	if(client)
		if(client.prefs.muted & MUTE_IC)
			src << "You cannot send IC messages (muted)."
			return
		if(src.client.handle_spam_prevention(msg,MUTE_IC))
			return
	if(stat)
		return

	god_speak(msg)


/mob/camera/god/proc/god_speak(msg)
	log_say("Hand of God: [capitalize(side)] God/[key_name(src)] : [msg]")
	msg = trim(copytext(sanitize(msg), 1, MAX_MESSAGE_LEN))
	if(!msg)
		return

	msg = say_quote(msg, get_spans())
	var/rendered = "<font color='[src.side]'><i><span class='game say'>Divine Telepathy,</i> <span class='name'>[name]</span> <span class='message'>[msg]</span></span></font>"
	src << rendered

	for(var/mob/M in mob_list)
		if(is_handofgod_myfollowers(M))
			M << rendered
		if(isobserver(M))
			var/link = FOLLOW_LINK(M, src)
			M << "[link] [rendered]"


/mob/camera/god/emote(act,m_type = 1 ,msg = null)
	return


/mob/camera/god/Move(NewLoc, Dir = 0)
	loc = NewLoc



/mob/camera/god/Topic(href, href_list)
	if(href_list["create_structure"])
		if(!ability_cost(75,1,1))
			return

		var/obj/structure/divine/construct_type = text2path(href_list["create_structure"]) //it's a path but we need to initial() some vars
		if(!construct_type)
			return

		add_faith(-75)
		var/obj/structure/divine/construction_holder/CH = new(get_turf(src))
		CH.assign_deity(src)
		CH.setup_construction(construct_type)
		CH.visible_message("<span class='notice'>[src] has created a transparent, unfinished [initial(construct_type.name)]. It can be finished by adding materials.</span>")
		src << "<span class='boldnotice'>You may click a construction site to cancel it, but only faith is refunded.</span>"
		structure_construction_ui(src)
		return

	if(href_list["place_trap"])
		if(!ability_cost(20,1,1))
			return

		var/atom/trap_type = text2path(href_list["place_trap"])
		if(!trap_type)
			return

		src << "You lay \a [initial(trap_type.name)]"
		add_faith(-20)
		new trap_type(get_turf(src))
		return

	..()


/mob/camera/god/proc/structure_construction_ui(mob/camera/god/user)
	var/dat = ""
	for(var/t in global_handofgod_structuretypes)
		if(global_handofgod_structuretypes[t])
			var/obj/structure/divine/apath = global_handofgod_structuretypes[t]
			dat += "<center><B>[capitalize(t)]</B></center><BR>"
			var/imgstate = initial(apath.autocolours) ? "[initial(apath.icon_state)]-[side]" : "[initial(apath.icon_state)]"
			var/icon/I = icon('icons/obj/hand_of_god_structures.dmi',imgstate)
			var/img_component = lowertext(t)
			//I hate byond, but atleast it autocaches these so it's only 1*number_of_structures worth of actual calls
			user << browse_rsc(I,"hog_structure-[img_component].png")
			dat += "<center><img src='hog_structure-[img_component].png' height=64 width=64></center>"
			dat += "Description: [initial(apath.desc)]<BR>"
			dat += "<center><a href='?src=\ref[src];create_structure=[apath]'>Construct [capitalize(t)]</a></center><BR><BR>"

	var/datum/browser/popup = new(src, "structures","Construct Structure",350,500)
	popup.set_content(dat)
	popup.open()


/mob/camera/god/proc/trap_construction_ui(mob/camera/god/user)
	var/dat = ""
	for(var/t in global_handofgod_traptypes)
		if(global_handofgod_traptypes[t])
			var/obj/structure/divine/trap/T = global_handofgod_traptypes[t]
			dat += "<center><B>[capitalize(t)]</B></center><BR>"
			var/icon/I = icon('icons/obj/hand_of_god_structures.dmi',"[initial(T.icon_state)]")
			var/img_component = lowertext(t)
			user << browse_rsc(I,"hog_trap-[img_component].png")
			dat += "<center><img src='hog_trap-[img_component].png' height=64 width=64></center>"
			dat += "Description: [initial(T.desc)]<BR>"
			dat += "<center><a href='?src=\ref[src];place_trap=[T]'>Place [capitalize(t)]</a></center><BR><BR>"

	var/datum/browser/popup = new(src, "traps", "Place Trap",350,500)
	popup.set_content(dat)
	popup.open()
