
//Verbs link to procs because verb-like procs have a bug which prevents their use if the arguments are not readily referenced.
//^ Old coder words may be false these days, Not taking the risk for now.

/obj/item/clothing/suit/space/space_ninja/proc/init()
	set name = "Initialize Suit"
	set desc = "Initializes the suit for field operation."
	set category = "Ninja Equip"

	ninitialize()

/obj/item/clothing/suit/space/space_ninja/proc/deinit()
	set name = "De-Initialize Suit"
	set desc = "Begins procedure to remove the suit."
	set category = "Ninja Equip"

	if(!s_busy)
		deinitialize()
	else
		to_chat(affecting, "<span class='danger'>The function did not trigger!</span>")


/obj/item/clothing/suit/space/space_ninja/proc/ninitialize(delay = s_delay, mob/living/carbon/human/U = loc)
	if(U.mind && U.mind.assigned_role==U.mind.special_role && !s_initialized && !s_busy)//Shouldn't be busy... but anything is possible I guess.
		s_busy = 1
		for(var/i,i<7,i++)
			switch(i)
				if(0)
					to_chat(U, "<span class='notice'>Now initializing...</span>")
				if(1)
					if(!lock_suit(U))//To lock the suit onto wearer.
						break
					to_chat(U, "<span class='notice'>Securing external locking mechanism...\nNeural-net established.</span>")
				if(2)
					to_chat(U, "<span class='notice'>Extending neural-net interface...\nNow monitoring brain wave pattern...</span>")
				if(3)
					if(U.stat==2||U.health<=0)
						to_chat(U, "<span class='danger'><B>FÄAL ï¿½Rrï¿½R</B>: 344--93#ï¿½&&21 BRï¿½ï¿½N |/|/aVï¿½ PATT$RN <B>RED</B>\nA-A-aBï¿½rTï¿½NG...</span>")
						unlock_suit()
						break
					lock_suit(U,1)//Check for icons.
					U.regenerate_icons()
					to_chat(U, "<span class='notice'>Linking neural-net interface...\nPattern</span>\green <B>GREEN</B><span class='notice'>, continuing operation.</span>")
				if(4)
					to_chat(U, "<span class='notice'>VOID-shift device status: <B>ONLINE</B>.\nCLOAK-tech device status: <B>ONLINE</B>.</span>")
				if(5)
					to_chat(U, "<span class='notice'>Primary system status: <B>ONLINE</B>.\nBackup system status: <B>ONLINE</B>.\nCurrent energy capacity: <B>[cell.charge]</B>.</span>")
				if(6)
					to_chat(U, "<span class='notice'>All systems operational. Welcome to <B>SpiderOS</B>, [U.real_name].</span>")
					grant_ninja_verbs()
					grant_equip_verbs()
					ntick()
			sleep(delay)
		s_busy = 0
	else
		if(!U.mind||U.mind.assigned_role!=U.mind.special_role)//Your run of the mill persons shouldn't know what it is. Or how to turn it on.
			to_chat(U, "You do not understand how this suit functions. Where the heck did it even come from?")
		else if(s_initialized)
			to_chat(U, "<span class='danger'>The suit is already functioning.</span> Please report this bug.")
		else
			to_chat(U, "<span class='userdanger'>ERROR</span>: You cannot use this function at this time.")
	return



/obj/item/clothing/suit/space/space_ninja/proc/deinitialize(delay = s_delay)
	if(affecting==loc&&!s_busy)
		var/mob/living/carbon/human/U = affecting
		if(!s_initialized)
			to_chat(U, "<span class='danger'>The suit is not initialized.</span> Please report this bug.")
			return
		if(alert("Are you certain you wish to remove the suit? This will take time and remove all abilities.",,"Yes","No")=="No")
			return
		if(s_busy)
			to_chat(U, "<span class='userdanger'>ERROR</span>: You cannot use this function at this time.")
			return
		s_busy = 1
		for(var/i = 0,i<7,i++)
			switch(i)
				if(0)
					to_chat(U, "<span class='notice'>Now de-initializing...</span>")
					spideros = 0//Spideros resets.
				if(1)
					to_chat(U, "<span class='notice'>Logging off, [U:real_name]. Shutting down <B>SpiderOS</B>.</span>")
					remove_ninja_verbs()
				if(2)
					to_chat(U, "<span class='notice'>Primary system status: <B>OFFLINE</B>.\nBackup system status: <B>OFFLINE</B>.</span>")
				if(3)
					to_chat(U, "<span class='notice'>VOID-shift device status: <B>OFFLINE</B>.\nCLOAK-tech device status: <B>OFFLINE</B>.</span>")
					cancel_stealth()//Shutdowns stealth.
				if(4)
					to_chat(U, "<span class='notice'>Disconnecting neural-net interface...</span>\green<B>Success</B><span class='notice'>.</span>")
				if(5)
					to_chat(U, "<span class='notice'>Disengaging neural-net interface...</span>\green<B>Success</B><span class='notice'>.</span>")
				if(6)
					to_chat(U, "<span class='notice'>Unsecuring external locking mechanism...\nNeural-net abolished.\nOperation status: <B>FINISHED</B>.</span>")
					remove_equip_verbs()
					unlock_suit()
					U.regenerate_icons()
			sleep(delay)
		s_busy = 0
	return