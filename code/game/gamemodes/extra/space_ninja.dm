/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
+++++++++++++++++++++++++++++++++++++//                \\++++++++++++++++++++++++++++++++++
======================================SPACE NINJA SETUP====================================
___________________________________________________________________________________________
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

/client/proc/space_ninja()
	set category = "Fun"
	set name = "Spawn Space Ninja"
	set desc = "Spawns a space ninja for when you need a teenager with attitude."
	if(!src.authenticated || !src.holder)
		src << "Only administrators may use this command."
		return
	if(!ticker.mode)//Apparently, this doesn't actually prevent anything. Huh
		alert("The game hasn't started yet!")
		return
	if(alert("Are you sure you want to send in a space ninja?",,"Yes","No")=="No")
		return

	TRYAGAIN
	var/input = input(usr, "Please specify which mission the space ninja shall undertake.", "Specify Mission", "")
	if(!input)
		goto TRYAGAIN

	var/list/LOCLIST = list()
	for(var/obj/landmark/X in world)
		if (X.name == "carpspawn")
			LOCLIST.Add(X)
	if(!LOCLIST.len)
		alert("No spawn location could be found. Aborting.")
		return

	var/obj/landmark/STARTLOC = pick(LOCLIST)

	var/mob/living/carbon/human/new_ninja = new(STARTLOC.loc)

	new_ninja.create_ninja()

	var/admin_name = src//In case admins want to spawn themselves as ninjas. Badmins

	var/mob/dead/observer/G
	var/list/candidates = list()
	for(G in world)
		if(G.client)
			if(((G.client.inactivity/10)/60) <= 5)
				candidates.Add(G)
	if(candidates.len)
		G = input("Pick character to spawn as the Space Ninja", "Active Players", G) in candidates//It will auto-pick a person when there is only one candidate.
		new_ninja.mind.key = G.key
		new_ninja.client = G.client
		new_ninja.mind.store_memory("<B>Mission:</B> \red [input].")
		del(G)
	else
		alert("Could not locate a suitable ghost. Aborting.")
		del(new_ninja)
		return

	new_ninja.internal = new_ninja.s_store //So the poor ninja has something to breath when they spawn in spess.
	new_ninja.internals.icon_state = "internal1"

	new_ninja << "\blue \nYou are an elite mercenary assassin of the Spider Clan, [new_ninja.real_name]. The dreaded \red <B>SPACE NINJA</B>!\blue You have a variety of abilities at your disposal, thanks to your nano-enhanced cyber armor. Remember your training (initialize your suit by right clicking on it)! \nYour current mission is: \red <B>[input]</B>"

	message_admins("\blue [admin_name] has spawned [new_ninja.key] as a Space Ninja. Hide yo children!", 1)
	log_admin("[admin_name] used Spawn Space Ninja.")

mob/proc/create_ninja()
	var/mob/living/carbon/human/new_ninja = src
	var/ninja_title = pick(ninja_titles)
	var/ninja_name = pick(ninja_names)
	new_ninja.gender = pick(MALE, FEMALE)
	new_ninja.real_name = "[ninja_title] [ninja_name]"
	new_ninja.age = rand(17,45)
	new_ninja.b_type = pick("A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-")
	new_ninja.dna.ready_dna(new_ninja)
	new_ninja.mind = new
	new_ninja.mind.current = new_ninja
	new_ninja.mind.assigned_role = "Space Ninja"
	new_ninja.mind.special_role = "Space Ninja"
	new_ninja.resistances += "alien_embryo"

	var/obj/item/device/radio/R = new /obj/item/device/radio/headset(new_ninja)
	new_ninja.equip_if_possible(R, new_ninja.slot_ears)
	new_ninja.equip_if_possible(new /obj/item/clothing/under/color/black(new_ninja), new_ninja.slot_w_uniform)
	new_ninja.equip_if_possible(new /obj/item/clothing/shoes/space_ninja(new_ninja), new_ninja.slot_shoes)
	new_ninja.equip_if_possible(new /obj/item/clothing/suit/space/space_ninja(new_ninja), new_ninja.slot_wear_suit)
	new_ninja.equip_if_possible(new /obj/item/clothing/gloves/space_ninja(new_ninja), new_ninja.slot_gloves)
	new_ninja.equip_if_possible(new /obj/item/clothing/head/helmet/space/space_ninja(new_ninja), new_ninja.slot_head)
	new_ninja.equip_if_possible(new /obj/item/clothing/mask/gas/voice/space_ninja(new_ninja), new_ninja.slot_wear_mask)
	new_ninja.equip_if_possible(new /obj/item/device/flashlight(new_ninja), new_ninja.slot_belt)
	new_ninja.equip_if_possible(new /obj/item/weapon/plastique(new_ninja), new_ninja.slot_r_store)
	new_ninja.equip_if_possible(new /obj/item/weapon/plastique(new_ninja), new_ninja.slot_l_store)
	new_ninja.equip_if_possible(new /obj/item/weapon/tank/emergency_oxygen(new_ninja), new_ninja.slot_s_store)

//AI COUNTER HACKING===================================

/mob/living/silicon/ai/proc/ninja_spideros()
	set name = "Hack SpiderOS"
	set desc = "Hack directly into the Black Widow(tm) neuro-interface."
	set category = "AI Commands"

	loc.loc:hack_spideros()//ninjasuit:hack_spideros()

/mob/living/silicon/ai/proc/ninja_return_control()
	set name = "Relinquish Control"
	set desc = "Return control to the user."
	set category = "AI Commands"

	src << browse(null, "window=hack spideros")//Close window
	loc:control = 0//Return control
	loc:affecting:verbs += /obj/item/clothing/suit/space/space_ninja/proc/deinit//Add back verbs
	loc:affecting:verbs += /obj/item/clothing/suit/space/space_ninja/proc/spideros
	verbs -= /mob/living/silicon/ai/proc/ninja_spideros
	verbs -= /mob/living/silicon/ai/proc/ninja_return_control
	loc:affecting << "<b>UPDATE</b>: [real_name] has seized hacking attempt. All systems clear."

/obj/item/clothing/suit/space/space_ninja/proc/hack_spideros()

	if(!affecting||!AI)	return//Just in case... something went wrong. Very wrong.
	var/mob/living/carbon/human/U = affecting
	var/mob/living/silicon/ai/A = AI

	var/dat = "<html><head><title>SpiderOS</title></head><body bgcolor=\"#3D5B43\" text=\"#DB2929\"><style>a, a:link, a:visited, a:active, a:hover { color: #DB2929; }img {border-style:none;}</style>"
	if(spideros==0)
		dat += "<a href='byond://?src=\ref[src];choice=Refresh'><img src=sos_7.png> Refresh</a>"
	else
		dat += "<a href='byond://?src=\ref[src];choice=Refresh'><img src=sos_7.png> Refresh</a>"
		dat += " | <a href='byond://?src=\ref[src];choice=Return'><img src=sos_1.png> Return</a>"
	dat += " | <a href='byond://?src=\ref[src];choice=Close'><img src=sos_8.png> Close</a>"
	dat += "<br>"
	dat += "<h2 ALIGN=CENTER>SpiderOS v.<b>ERR-RR00123</b></h2>"
	dat += "<br>"
	dat += "<img src=sos_10.png> Current Time: [round(world.time / 36000)+12]:[(world.time / 600 % 60) < 10 ? add_zero(world.time / 600 % 60, 1) : world.time / 600 % 60]<br>"
	dat += "<img src=sos_9.png> Battery Life: [round(cell.charge/100)]%<br>"
	dat += "<img src=sos_11.png> Smoke Bombs: [sbombs]<br>"
	dat += "<br>"

	switch(spideros)
		if(0)
			dat += "<h4><img src=sos_1.png> Available Functions:</h4>"
			dat += "<ul>"
			dat += "<li><a href='byond://?src=\ref[src];choice=Shock'><img src=sos_4.png> Shock [U.real_name]</a></li>"
			dat += "<li><a href='byond://?src=\ref[src];choice=1'><img src=sos_3.png> Medical Screen</a></li>"
			dat += "<li><a href='byond://?src=\ref[src];choice=2'><img src=sos_5.png> Atmos Scan</a></li>"
			dat += "<li><a href='byond://?src=\ref[src];choice=3'><img src=sos_12.png> Messenger</a></li>"
			dat += "<li><a href='byond://?src=\ref[src];choice=4'><img src=sos_6.png> Other</a></li>"
			dat += "</ul>"
		if(1)
			dat += "<h4><img src=sos_3.png> Medical Report:</h4>"
			if(U.dna)
				dat += "<b>Fingerprints</b>: <i>[md5(U.dna.uni_identity)]</i><br>"
				dat += "<b>Unique identity</b>: <i>[U.dna.unique_enzymes]</i><br>"
			dat += "<h4>Overall Status: [U.stat > 1 ? "dead" : "[U.health]% healthy"]</h4>"
			dat += "<h4>Nutrition Status: [U.nutrition]</h4>"
			dat += "Oxygen loss: [U.oxyloss]"
			dat += " | Toxin levels: [U.toxloss]<br>"
			dat += "Burn severity: [U.fireloss]"
			dat += " | Brute trauma: [U.bruteloss]<br>"
			dat += "Body Temperature: [U.bodytemperature-T0C]&deg;C ([U.bodytemperature*1.8-459.67]&deg;F)<br>"
			if(U.virus)
				dat += "Warning Virus Detected. Name: [U.virus.name].Type: [U.virus.spread]. Stage: [U.virus.stage]/[U.virus.max_stages]. Possible Cure: [U.virus.cure].<br>"
			dat += "<ul>"
			dat += "<li><a href='byond://?src=\ref[src];choice=Dylovene'><img src=sos_2.png> Inject Dylovene: [reagents.get_reagent_amount("anti_toxin")/20] left</a></li>"
			dat += "<li><a href='byond://?src=\ref[src];choice=Dexalin Plus'><img src=sos_2.png> Inject Dexalin Plus: [reagents.get_reagent_amount("dexalinp")/20] left</a></li>"
			dat += "<li><a href='byond://?src=\ref[src];choice=Tricordazine'><img src=sos_2.png> Inject Tricordazine: [reagents.get_reagent_amount("tricordrazine")/20] left</a></li>"
			dat += "<li><a href='byond://?src=\ref[src];choice=Spacelin'><img src=sos_2.png> Inject Spacelin: [reagents.get_reagent_amount("spaceacillin")/20] left</a></li>"
			dat += "<li><a href='byond://?src=\ref[src];choice=Spacelin'><img src=sos_2.png> Inject Radium: [(reagents.get_reagent_amount("radium")/20)-60] left</a></li>"//There is 120 radium at start. -60 for adrenaline boosts.
			dat += "<li><a href='byond://?src=\ref[src];choice=Nutriment'><img src=sos_2.png> Inject Nutriment: [reagents.get_reagent_amount("nutriment")/5] left</a></li>"//Special case since it's so freaking potent.
			dat += "</ul>"
		if(2)
			dat += "<h4><img src=sos_5.png> Atmospheric Scan:</h4>"
			var/turf/T = get_turf_or_move(U.loc)
			if (isnull(T))
				dat += "Unable to obtain a reading."
			else
				var/datum/gas_mixture/environment = T.return_air()

				var/pressure = environment.return_pressure()
				var/total_moles = environment.total_moles()

				dat += "Air Pressure: [round(pressure,0.1)] kPa"

				if (total_moles)
					var/o2_level = environment.oxygen/total_moles
					var/n2_level = environment.nitrogen/total_moles
					var/co2_level = environment.carbon_dioxide/total_moles
					var/plasma_level = environment.toxins/total_moles
					var/unknown_level =  1-(o2_level+n2_level+co2_level+plasma_level)
					dat += "<ul>"
					dat += "<li>Nitrogen: [round(n2_level*100)]%</li>"
					dat += "<li>Oxygen: [round(o2_level*100)]%</li>"
					dat += "<li>Carbon Dioxide: [round(co2_level*100)]%</li>"
					dat += "<li>Plasma: [round(plasma_level*100)]%</li>"
					dat += "</ul>"
					if(unknown_level > 0.01)
						dat += "OTHER: [round(unknown_level)]%<br>"

					dat += "Temperature: [round(environment.temperature-T0C)]&deg;C"
		if(3)
			dat += "<a href='byond://?src=\ref[src];choice=32'><img src=sos_1.png> Hidden Menu</a>"
			dat += "<h4><img src=sos_12.png> Anonymous Messenger:</h4>"//Anonymous because the receiver will not know the sender's identity.
			dat += "<h4><img src=sos_6.png> Detected PDAs:</h4>"
			dat += "<ul>"
			var/count = 0
			for (var/obj/item/device/pda/P in world)
				if (!P.owner||P.toff)
					continue
				dat += "<li><a href='byond://?src=\ref[src];choice=Message;target=\ref[P]'>[P]</a>"
				dat += "</li>"
				count++
			dat += "</ul>"
			if (count == 0)
				dat += "None detected.<br>"
		if(32)//Only leaving this in for funnays. CAN'T LET YOU DO THAT STAR FOX
			dat += "<h4><img src=sos_1.png> Hidden Menu:</h4>"
			dat += "Hostile runtime intrusion detected: operation locked. The Spider Clan is watching you, <b>INTRUDER</b>."
	dat += "</body></html>"

	A << browse(dat,"window=hack spideros;size=400x444;border=1;can_resize=0;can_close=0;can_minimize=0")

//DEBUG===================================

//Switches keys with AI stored inside suit. Useful for quickly testing things.
/*
var/ninja_debug_target//Easiest way to do this. The proc below sets this variable to your mob.

/mob/verb/possess_mob(var/mob/M in oview())
	set name = "Possess Mob"
	set category = "Ninja Debug"

	if(!M.client)
		client.mob = M

/mob/verb/set_debug_ninja_target()
	set name = "Set Debug Target"
	set category = "Ninja Debug"

	ninja_debug_target = src//The target is you, brohime.
	world << "Target: [src]"

/mob/verb/hack_spideros_debug()
	set name = "Debug Hack Spider OS"
	set category = "Ninja Debug"

	var/mob/living/silicon/ai/A = loc:AI
	if(A)
		if(!A.key)
			A.client.mob = loc:affecting
		else
			loc:affecting:client:mob = A
	return

//Tests the net and what it does.
/mob/verb/ninjanet_debug()
	set name = "Energy Net Debug"
	set category = "Ninja Debug"

	var/obj/effects/energy_net/E = new /obj/effects/energy_net(loc)
	E.layer = layer+1//To have it appear one layer above the mob.
	stunned = 10//So they are stunned initially but conscious.
	anchored = 1//Anchors them so they can't move.
	E.affecting = src
	spawn(0)//Parallel processing.
		E.process(src)
	return
*/
/*
I made this as a test for a possible ninja ability (or perhaps more) for a certain mob to see hallucinations.
The thing here is that these guys have to be coded to do stuff as they are simply images that you can't even click on.
/mob/verb/TestNinjaShadow()
	set name = "Test Ninja Ability"
	set category = "Ninja Debug"

	if(client)
		var/safety = 4
		for(var/turf/T in oview(5))
			if(prob(20))
				var/current_clone = image('mob.dmi',T,"s-ninja",dir)
				safety--
				spawn(0)
					src << current_clone
					spawn(300)
						del(current_clone)
					spawn while(!isnull(current_clone))
						step_to(current_clone,src,1)
						sleep(5)
			if(safety<=0)	break
	return */