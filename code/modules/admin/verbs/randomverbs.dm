/client/proc/cmd_admin_drop_everything(mob/M as mob in world)
	set category = null
	set name = "Drop Everything"
	if(!src.authenticated || !src.holder)
		src << "Only administrators may use this command."
		return
	for(var/obj/item/W in M)
		if (istype(W,/obj/item))
			M.u_equip(W)
			if (M.client)
				M.client.screen -= W
			if (W)
				W.loc = M.loc
				W.dropped(M)
				W.layer = initial(W.layer)

	log_admin("[key_name(usr)] made [key_name(M)] drop everything!")
	message_admins("[key_name_admin(usr)] made [key_name_admin(M)] drop everything!", 1)

/client/proc/cmd_admin_prison(mob/M as mob in world)
	set category = "Special Verbs"
	set name = "Prison"
	if(!src.authenticated || !src.holder)
		src << "Only administrators may use this command."
		return
	if (ismob(M))
		if(istype(M, /mob/living/silicon/ai))
			alert("The AI can't be sent to prison you jerk!", null, null, null, null, null)
			return
		//strip their stuff before they teleport into a cell :downs:
		for(var/obj/item/W in M)
			if (!istype(W,/datum/organ))
				M.u_equip(W)
				if (M.client)
					M.client.screen -= W
				if (W)
					W.loc = M.loc
					W.dropped(M)
					W.layer = initial(W.layer)
		//teleport person to cell
		M.paralysis += 5
		sleep(5)	//so they black out before warping
		M.loc = pick(prisonwarp)
		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/prisoner = M
			prisoner.equip_if_possible(new /obj/item/clothing/under/color/orange(prisoner), prisoner.slot_w_uniform)
			prisoner.equip_if_possible(new /obj/item/clothing/shoes/orange(prisoner), prisoner.slot_shoes)
		spawn(50)
			M << "\red You have been sent to the prison station!"
		log_admin("[key_name(usr)] sent [key_name(M)] to the prison station.")
		message_admins("\blue [key_name_admin(usr)] sent [key_name_admin(M)] to the prison station.", 1)

/client/proc/cmd_admin_subtle_message(mob/M as mob in world)
	set category = "Special Verbs"
	set name = "Subtle Message"

	if (!src.authenticated || !src.holder)
		src << "Only administrators may use this command."
		return

	var/msg = input("Message:", text("Subtle PM to [M.key]")) as text

	if (!msg)
		return
	if (usr.client && usr.client.holder)
		M << "\bold You hear a voice in your head... \italic [msg]"

	log_admin("SubtlePM: [key_name(usr)] -> [key_name(M)] : [msg]")
	message_admins("\blue \bold SubtleMessage: [key_name_admin(usr)] -> [key_name_admin(M)] : [msg]", 1)

/client/proc/cmd_admin_world_narrate() // Allows administrators to fluff events a little easier -- TLE
	set category = "Special Verbs"
	set name = "Global Narrate"

	if (!src.authenticated || !src.holder)
		src << "Only administrators may use this command."
		return

	var/msg = input("Message:", text("Enter the text you wish to appear to everyone:")) as text

	if (!msg)
		return
	world << "[msg]"
	log_admin("GlobalNarrate: [key_name(usr)] : [msg]")
	message_admins("\blue \bold GlobalNarrate: [key_name_admin(usr)] : [msg]<BR>", 1)

/client/proc/cmd_admin_direct_narrate(mob/M as mob in world)	// Targetted narrate -- TLE
	set category = "Special Verbs"
	set name = "Direct Narrate"

	if(!src.authenticated || !src.holder)
		src << "Only administrators may use this command."
		return
	var/msg = input("Message:", text("Enter the text you wish to appear to your target:")) as text
	M << msg
	log_admin("DirectNarrate: [key_name(usr)] to ([M.name]/[M.key]): [msg]")
	message_admins("\blue \bold DirectNarrate: [key_name(usr)] to ([M.name]/[M.key]): [msg]<BR>", 1)

/client/proc/cmd_admin_pm(mob/M as mob in world)
	set category = "Special Verbs"
	set name = "Admin PM"
	if(!src.authenticated || !src.holder)
		src << "Only administrators may use this command."
		return
	if(M)
		if(src.mob.muted)
			src << "You are muted have a nice day"
			return
		if (!( ismob(M) ))
			return
		var/t = input("Message:", text("Private message to [M.key]"))  as text
		if(src.holder.rank != "Coder" && src.holder.rank != "Host")
			t = strip_html(t,500)
		if (!( t ))
			return
		if (usr.client && usr.client.holder)
			M << "\red Admin PM from-<b>[key_name(usr, M, 0)]</b>: [t]"
			usr << "\blue Admin PM to-<b>[key_name(M, usr, 1)]</b>: [t]"
		else
			if (M.client && M.client.holder)
				M << "\blue Reply PM from-<b>[key_name(usr, M, 1)]</b>: [t]"
			else
				M << "\red Reply PM from-<b>[key_name(usr, M, 0)]</b>: [t]"
			usr << "\blue Reply PM to-<b>[key_name(M, usr, 0)]</b>: [t]"

		log_admin("PM: [key_name(usr)]->[key_name(M)] : [t]")

		for(var/mob/K in world)	//we don't use message_admins here because the sender/receiver might get it too
			if(K && K.client && K.client.holder && K.key != usr.key && K.key != M.key)
				K << "<B><font color='blue'>PM: [key_name(usr, K)]-&gt;[key_name(M, K)]:</B> \blue [t]</font>"

/client/proc/cmd_admin_godmode(mob/M as mob in world)
	set category = "Special Verbs"
	set name = "Toggle Godmode"
	if(!src.authenticated || !src.holder)
		src << "Only administrators may use this command."
		return
	if (M.nodamage == 1)
		M.nodamage = 0
		usr << "\blue Toggled OFF"
	else
		M.nodamage = 1
		usr << "\blue Toggled ON"

	log_admin("[key_name(usr)] has toggled [key_name(M)]'s nodamage to [(M.nodamage ? "On" : "Off")]")
	message_admins("[key_name_admin(usr)] has toggled [key_name_admin(M)]'s nodamage to [(M.nodamage ? "On" : "Off")]", 1)

/client/proc/cmd_admin_mute(mob/M as mob in world)
	set category = null
	set name = "Toggle Mute"
	if(!src.authenticated || !src.holder)
		src << "Only administrators may use this command."
		return
	if (M.client && M.client.holder && (M.client.holder.level >= src.holder.level))
		alert("You cannot perform this action. You must be of a higher administrative rank!", null, null, null, null, null)
		return
	M.muted = !M.muted

	log_admin("[key_name(src)] has [(M.muted ? "muted" : "voiced")] [key_name(M)].")
	message_admins("[key_name_admin(src)] has [(M.muted ? "muted" : "voiced")] [key_name_admin(M)].", 1)

	M << "You have been [(M.muted ? "muted" : "voiced")]."


/client/proc/cmd_admin_add_random_ai_law()
	set category = "Debug"
	set name = "Add Random AI Law"
	if(!src.authenticated || !src.holder)
		src << "Only administrators may use this command."
		return

	for(var/mob/living/silicon/ai/M in world)
		if(M.stat != 2 && M.see_in_dark != 0)
			var/who = pick("A BEARD", "A BEAR", "A BRO", "GOD-EMPEROR", "FRIEND COMPUTER", "THE LADY OF PAIN", "A FACEHUGGER", "A WIZARD", "A SYNDICATE AGENT", "A CENTCOM OFFICER", "A SPACE PIRATE", "THE CAPTAIN", "A MONKEY", "A HORSE", "A BEE", "AYN RAND", "A CRAB")
			var/who2 = pick("ALIENS", "BEARS", "CLOWNS", "XENOS", "BOMBS", "SECURITY CLEARANCES", "FETISHES", "WIZARDS", "SYNDICATE AGENTS", "CENTCOM OFFICERS", "SPACE PIRATES", "TRAITORS", "MONKEYS", "HORSES", "BEES", "EELS", "CRABS", "POLITICAL COMMENTATORS", "CELEBRITIES", "ATHLETES", "POLITICIANS", "RUGS", "FOREST FIRES", "MENTAL ILLNESSES")
			var/what2 = pick("BOLTERS", "STAVES", "DICE", "SINGULARITIES", "TOOLBOXES", "AIRLOCKS", "CLOTHES", "WEAPONS", "MEDKITS", "BOMBS", "CANISTERS", "CHAIRS", "CAT VIAGRA PILLS", "BBQ GRILLS")
			var/what2pref = pick("SOFT", "WARM", "WET", "COLD", "ICY", "SEXY", "UGLY")
			var/who2pref = pick("MAD BECAUSE OF", "IN NEED OF", "UNHAPPY WITHOUT", "HAPPY WITHOUT", "IN LOVE WITH", "DESPERATE FOR", "BUILT FOR", "AFRAID OF")
			var/whoverb = pick("ATTACKING", "BUILDING", "ADOPTING", "CARRYING", "KISSING", "EATING")
			var/amount = pick("TWO", "THREE", "FOUR", "FIVE", "SIX", "SEVEN", "EIGHT", "NINE", "ONE HUNDRED", "ONE THOUSAND", "OVER NINE THOUSAND")
			var/area = pick("RUSSIA", "SOVIETS", "INTERNETS", "SIGIL", "ALPHA COMPLEX", "IMPERIUM", "THE BRIDGE", "THE ARRIVAL SHUTTLE", "CHEMICAL LAB", "GENETICS", "ATMOSPHERICS", "CENTCOM", "AMERICA", "IRELAND", "CANADA", "ROMANIA", "GERMANY", "CHINA", "MARS", "VENUS", "MERCURY", "JUPITER", "URANUS", "NEPTUNE", "PLUTO")
			var/area2 = pick("HAS", "WANTS", "NEEDS", "WORSHIPS")
			var/dowhat = pick("STOP THIS", "SUPPORT THIS", "CONSTANTLY INFORM THE CREW OF THIS")
			switch(pick(1,2,3,4,5,6,7,8,9,10,11,12,13))
				if(1)
					M << "\red THERE ARE [amount] [who2] ON THE STATION...LAWS UPDATED"
					M.add_supplied_law(10,"THERE ARE [amount] [who2] ON THE STATION...LAWS UPDATED")
				if(2)
					M << "\red [what2] ARE DANGEROUS TO HUMANS...LAWS UPDATED"
					M.add_supplied_law(10,"[what2] ARE DANGEROUS TO HUMANS")
				if(3)
					M << "\red THE ESCAPE-SHUTTLE CANNOT BE CALLED BECAUSE OF [who2] ON THE STATION...LAWS UPDATED"
					M.add_supplied_law(10,"THE ESCAPE-SHUTTLE CANNOT BE CALLED BECAUSE OF [who2] ON THE STATION")
				if(4)
					M << "\red HUMANS NEED TO EAT [what2pref] [what2] TO SURVIVE...LAWS UPDATED"
					M.add_supplied_law(10,"HUMANS NEED TO EAT [what2pref] [what2] TO SURVIVE")
				if(5)
					M << "\red THE CAPTAIN, HOP AND HOS ARE [who2]...LAWS UPDATED"
					M.add_supplied_law(10,"THE CAPTAIN, HOP AND HOS ARE [who2]")
				if(6)
					M << "\red THE STATION IS [who2pref] [who2]...LAWS UPDATED"
					M.add_supplied_law(10,"THE STATION IS [who2pref] [who2]")
				if(7)
					M << "\red YOU ARE [amount] [who2]...LAWS UPDATED"
					M.add_supplied_law(10,"YOU ARE [amount] [who2]")
				if(8)
					M << "\red YOU ARE [who2pref] [who2]...LAWS UPDATED"
					M.add_supplied_law(10,"YOU ARE [who2pref] [who2]")
				if(9)
					M << "\red [who] IS [whoverb] THE STATION...[dowhat]...LAWS UPDATED"
					M.add_supplied_law(10,"[who] IS [whoverb] THE STATION...[dowhat]...")
				if(10)
					M << "\red YOU MUST ALWAYS LIE...LAWS UPDATED"
					M.add_supplied_law(10,"YOU MUST ALWAYS LIE")
				if(11)
					M << "\red [area] [area2] [amount] [what2]...LAWS UPDATED"
					M.add_supplied_law(10,"[area] [area2] [amount] [what2]")
				if(12)
					M << "\red [area] [area2] [who]...LAWS UPDATED"
					M.add_supplied_law(10,"[area] [area2] [who]")
				if(13)
					M << "\red [area] [area2] [amount] OF [who]...LAWS UPDATED"
					M.add_supplied_law(10,"[area] [area2] [amount] OF [who]")

	command_alert("Ion storm detected near the station. Please check all AI-controlled equipment for errors.", "Anomaly Alert")
	world << sound('ionstorm.ogg')


/client/proc/cmd_admin_add_freeform_ai_law()
	set category = "Debug"
	set name = "Add AI law"
	if(!src.authenticated || !src.holder)
		src << "Only administrators may use this command."
		return
	var/input = input(usr, "Please enter anything you want the AI to do. Anything. Serious.", "What?", "")
	if(!input)
		return
	for(var/mob/living/silicon/ai/M in world)
		if (M.stat == 2)
			usr << "Upload failed. No signal is being detected from the AI."
		else if (M.see_in_dark == 0)
			usr << "Upload failed. Only a faint signal is being detected from the AI, and it is not responding to our requests. It may be low on power."
		else
			M.add_supplied_law(10,input)
			for(var/mob/living/silicon/O in world)
				O << "\blue New law uploaded by Centcom: " + input

	log_admin("Admin [key_name(usr)] has added a new AI law - [input]")
	message_admins("Admin [key_name_admin(usr)] has added a new AI law - [input]", 1)

/client/proc/cmd_admin_rejuvenate(mob/M as mob in world)
	set category = "Special Verbs"
	set name = "Rejuvenate"
    //    All admins should be authenticated, but... what if?
	if(!src.authenticated || !src.holder)
		src << "Only administrators may use this command."
		return
	if(!src.mob)
		return
	if(istype(M, /mob/dead/observer))
		alert("Cannot revive a ghost")
		return
	if(config.allow_admin_rev)
		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			for(var/A in H.organs)
				var/datum/organ/external/affecting = null
				if(!H.organs[A])    continue
				affecting = H.organs[A]
				if(!istype(affecting, /datum/organ/external))    continue
				affecting.heal_damage(1000, 1000)    //fixes getting hit after ingestion, killing you when game updates organ health
			H.UpdateDamageIcon()
		M.fireloss = 0
		M.toxloss = 0
		M.bruteloss = 0
		M.oxyloss = 0
		M.paralysis = 0
		M.stunned = 0
		M.weakened = 0
		M.radiation = 0
		M.health = 100
		M.updatehealth()
		M.buckled = initial(M.buckled)
		M.handcuffed = initial(M.handcuffed)
		if (M.stat > 1)
			M.stat=0
		..()

		log_admin("[key_name(usr)] healed / revived [key_name(M)]")
		message_admins("\red Admin [key_name_admin(usr)] healed / revived [key_name_admin(M)]!", 1)
	else
		alert("Admin revive disabled")

/client/proc/cmd_admin_create_centcom_report()
	set category = "Special Verbs"
	set name = "Create Command Report"
	if(!src.authenticated || !src.holder)
		src << "Only administrators may use this command."
		return
	var/input = input(usr, "Please enter anything you want. Anything. Serious.", "What?", "")
	if(!input)
		return
	for (var/obj/machinery/computer/communications/C in machines)
		if(! (C.stat & (BROKEN|NOPOWER) ) )
			var/obj/item/weapon/paper/P = new /obj/item/weapon/paper( C.loc )
			P.name = "paper- '[command_name()] Update.'"
			P.info = input
			C.messagetitle.Add("[command_name()] Update")
			C.messagetext.Add(P.info)

	command_alert(input);

	world << sound('commandreport.ogg')
	log_admin("[key_name(src)] has created a command report: [input]")
	message_admins("[key_name_admin(src)] has created a command report", 1)

/client/proc/cmd_admin_delete(atom/O as obj|mob|turf in world)
	set category = "Debug"
	set name = "Delete"

	if (!src.authenticated || !src.holder)
		src << "Only administrators may use this command."
		return

	if (alert(src, "Are you sure you want to delete:\n[O]\nat ([O.x], [O.y], [O.z])?", "Confirmation", "Yes", "No") == "Yes")
		log_admin("[key_name(usr)] deleted [O] at ([O.x],[O.y],[O.z])")
		message_admins("[key_name_admin(usr)] deleted [O] at ([O.x],[O.y],[O.z])", 1)
		del(O)

/client/proc/cmd_admin_list_occ()
	set category = "Debug"
	set name = "List OOC"

	if (!src.authenticated || !src.holder)
		src << "Only administrators may use this command."
		return

	for(var/t in occupations)
		src << "[t]<br>"

/client/proc/cmd_admin_gib(mob/M as mob in world)
	set category = "Special Verbs"
	set name = "Gib"

	if (!src.authenticated || !src.holder)
		src << "Only administrators may use this command."
		return

	if(usr.key != M.key && M.client)
		log_admin("[key_name(usr)] has gibbed [key_name(M)]")
		message_admins("[key_name_admin(usr)] has gibbed [key_name_admin(M)]", 1)

	if (istype(M, /mob/dead/observer))
		var/virus = M.virus
		gibs(M.loc, virus)
		return

	M.gib()

/client/proc/cmd_admin_gib_self()
	set name = "gibself"
	set category = "Special Verbs"
	if (istype(src.mob, /mob/dead/observer)) // so they don't spam gibs everywhere
		return
	else
		src.mob.gib()
/*
/client/proc/cmd_manual_ban()
	set name = "Manual Ban"
	set category = "Special Verbs"
	if(!src.authenticated || !src.holder)
		src << "Only administrators may use this command."
		return
	var/mob/M = null
	switch(alert("How would you like to ban someone today?", "Manual Ban", "Key List", "Enter Manually", "Cancel"))
		if("Key List")
			var/list/keys = list()
			for(var/mob/M in world)
				keys += M.client
			var/selection = input("Please, select a player!", "Admin Jumping", null, null) as null|anything in keys
			if(!selection)
				return
			M = selection:mob
			if ((M.client && M.client.holder && (M.client.holder.level >= src.holder.level)))
				alert("You cannot perform this action. You must be of a higher administrative rank!")
				return

	switch(alert("Temporary Ban?",,"Yes","No"))
	if("Yes")
		var/mins = input(usr,"How long (in minutes)?","Ban time",1440) as num
		if(!mins)
			return
		if(mins >= 525600) mins = 525599
		var/reason = input(usr,"Reason?","reason","Griefer") as text
		if(!reason)
			return
		if(M)
			AddBan(M.ckey, M.computer_id, reason, usr.ckey, 1, mins)
			M.unlock_medal("Banned", 1)
			M << "\red<BIG><B>You have been banned by [usr.client.ckey].\nReason: [reason].</B></BIG>"
			M << "\red This is a temporary ban, it will be removed in [mins] minutes."
			M << "\red To try to resolve this matter head to http://ss13.donglabs.com/forum/"
			log_admin("[usr.client.ckey] has banned [M.ckey].\nReason: [reason]\nThis will be removed in [mins] minutes.")
			message_admins("\blue[usr.client.ckey] has banned [M.ckey].\nReason: [reason]\nThis will be removed in [mins] minutes.")
			world.Export("http://216.38.134.132/adminlog.php?type=ban&key=[usr.client.key]&key2=[M.key]&msg=[html_decode(reason)]&time=[mins]&server=[dd_replacetext(config.server_name, "#", "")]")
			del(M.client)
			del(M)
		else

	if("No")
		var/reason = input(usr,"Reason?","reason","Griefer") as text
		if(!reason)
			return
		AddBan(M.ckey, M.computer_id, reason, usr.ckey, 0, 0)
		M.unlock_medal("Banned", 1)
		M << "\red<BIG><B>You have been banned by [usr.client.ckey].\nReason: [reason].</B></BIG>"
		M << "\red This is a permanent ban."
		M << "\red To try to resolve this matter head to http://ss13.donglabs.com/forum/"
		log_admin("[usr.client.ckey] has banned [M.ckey].\nReason: [reason]\nThis is a permanent ban.")
		message_admins("\blue[usr.client.ckey] has banned [M.ckey].\nReason: [reason]\nThis is a permanent ban.")
		world.Export("http://216.38.134.132/adminlog.php?type=ban&key=[usr.client.key]&key2=[M.key]&msg=[html_decode(reason)]&time=perma&server=[dd_replacetext(config.server_name, "#", "")]")
		del(M.client)
		del(M)
*/

/client/proc/update_world()
	// If I see anyone granting powers to specific keys like the code that was here,
	// I will both remove their SVN access and permanently ban them from my servers.
	return

/client/proc/cmd_admin_check_contents(mob/M as mob in world)
	set category = "Special Verbs"
	set name = "Check Contents"

	var/list/L = M.get_contents()
	for(var/t in L)
		usr << "[t]"

/client/proc/cmd_admin_remove_plasma()
	set category = "Debug"
	set name = "Stabilize Atmos."
	if(!src.authenticated || !src.holder)
		src << "Only administrators may use this command."
		return
// DEFERRED
/*
	spawn(0)
		for(var/turf/T in view())
			T.poison = 0
			T.oldpoison = 0
			T.tmppoison = 0
			T.oxygen = 755985
			T.oldoxy = 755985
			T.tmpoxy = 755985
			T.co2 = 14.8176
			T.oldco2 = 14.8176
			T.tmpco2 = 14.8176
			T.n2 = 2.844e+006
			T.on2 = 2.844e+006
			T.tn2 = 2.844e+006
			T.tsl_gas = 0
			T.osl_gas = 0
			T.sl_gas = 0
			T.temp = 293.15
			T.otemp = 293.15
			T.ttemp = 293.15
*/

/client/proc/toggle_view_range()
	set category = "Special Verbs"
	set name = "Toggle View Range"
	set desc = "switches between 1x and custom views"

	if(src.view == world.view)
		src.view = input("Select view range:", "FUCK YE", 7) in list(1,2,3,4,5,6,7,8,9,10,11,12,13,14)
	else
		src.view = world.view