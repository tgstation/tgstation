/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
+++++++++++++++++++++++++++++++++++++//                \\++++++++++++++++++++++++++++++++++
======================================SPACE NINJA SETUP====================================
___________________________________________________________________________________________
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

/proc/space_ninja_arrival()//This is the random event proc. WIP
	/*
	var/datum/game_mode/current_mode = ticker.mode
	switch (current_mode.config_tag)
		if ("revolution")


		if ("cult")
			if (src in current_mode:cult)


		if ("wizard")
			if (current_mode:wizard && src == current_mode:wizard)


		if ("changeling")
			if (src in current_mode:changelings)


		if ("malfunction")
			if (src in current_mode:malf_ai)


		if ("nuclear")
			if(src in current_mode:syndicates)
	*/
	return

/client/proc/space_ninja()//This is the admin button.
	set category = "Fun"
	set name = "Spawn Space Ninja"
	set desc = "Spawns a space ninja for when you need a teenager with an attitude."
	if(!authenticated || !holder)
		src << "Only administrators may use this command."
		return
	if(!ticker.mode)
		alert("The game hasn't started yet!")
		return
	if(alert("Are you sure you want to send in a space ninja?",,"Yes","No")=="No")
		return

	var/input
	while(!input)
		input = input(src, "Please specify which mission the space ninja shall undertake.", "Specify Mission", "")
		if(!input)
			if(alert("Error, no mission set. Do you want to exit the setup process?",,"Yes","No")=="Yes")
				return

	var/list/spawn_list = list()
	for(var/obj/landmark/X in world)
		if (X.name == "carpspawn")
			spawn_list.Add(X)
	if(!spawn_list.len)
		alert("No spawn location could be found. Aborting.")
		return

	var/admin_name = src
	var/mob/living/carbon/human/new_ninja = create_space_ninja(pick(spawn_list))

	var/mob/dead/observer/G
	var/list/candidates = list()
	for(G in world)
		if(G.client&&!G.client.holder)
		//if(G.client)//Good for testing. Admins can spawn ninja equipment if they want to.
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

	new_ninja.mind.store_memory("<B>Mission:</B> \red [input].")
	new_ninja << "\blue \nYou are an elite mercenary assassin of the Spider Clan, [new_ninja.real_name]. The dreaded \red <B>SPACE NINJA</B>!\blue You have a variety of abilities at your disposal, thanks to your nano-enhanced cyber armor. Remember your training (initialize your suit by right clicking on it)! \nYour current mission is: \red <B>[input]</B>"

	message_admins("\blue [admin_name] has spawned [new_ninja.key] as a Space Ninja. Hide yo children!", 1)
	log_admin("[admin_name] used Spawn Space Ninja.")

client/proc/create_space_ninja(obj/spawn_point)
	var/mob/living/carbon/human/new_ninja = new(spawn_point.loc)
	var/ninja_title = pick(ninja_titles)
	var/ninja_name = pick(ninja_names)
	new_ninja.gender = pick(MALE, FEMALE)

	var/datum/preferences/A = new()//Randomize appearance for the ninja.
	A.randomize_appearance_for(new_ninja)

	new_ninja.real_name = "[ninja_title] [ninja_name]"
	new_ninja.dna.ready_dna(new_ninja)
	new_ninja.mind = new
	new_ninja.mind.current = new_ninja
	new_ninja.mind.assigned_role = "MODE"
	new_ninja.mind.special_role = "Space Ninja"
	new_ninja.equip_space_ninja()
	return new_ninja

/mob/living/carbon/human/proc/equip_space_ninja()
	var/obj/item/device/radio/R = new /obj/item/device/radio/headset(src)
	equip_if_possible(R, slot_ears)
	equip_if_possible(new /obj/item/clothing/under/color/black(src), slot_w_uniform)
	equip_if_possible(new /obj/item/clothing/shoes/space_ninja(src), slot_shoes)
	equip_if_possible(new /obj/item/clothing/suit/space/space_ninja(src), slot_wear_suit)
	equip_if_possible(new /obj/item/clothing/gloves/space_ninja(src), slot_gloves)
	equip_if_possible(new /obj/item/clothing/head/helmet/space/space_ninja(src), slot_head)
	equip_if_possible(new /obj/item/clothing/mask/gas/voice/space_ninja(src), slot_wear_mask)
	equip_if_possible(new /obj/item/device/flashlight(src), slot_belt)
	equip_if_possible(new /obj/item/weapon/plastique(src), slot_r_store)
	equip_if_possible(new /obj/item/weapon/plastique(src), slot_l_store)
	equip_if_possible(new /obj/item/weapon/tank/emergency_oxygen(src), slot_s_store)
	resistances += "alien_embryo"
	return 1

//VERB MODIFIERS===================================

/obj/item/clothing/suit/space/space_ninja/proc/grant_ninja_verbs()
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjashift
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjajaunt
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjasmoke
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjaboost
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjapulse
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjablade
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjastar
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjanet

	s_initialized=1
	slowdown=0

/obj/item/clothing/suit/space/space_ninja/proc/remove_ninja_verbs()
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjashift
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjajaunt
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjasmoke
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjaboost
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjapulse
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjablade
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjastar
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjanet

/obj/item/clothing/suit/space/space_ninja/proc/grant_kamikaze_verbs()
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjashift
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjajaunt
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjapulse
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjastar
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjanet

	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjaslayer
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjawalk
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjamirage

	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/stealth

	kamikaze = 1
	cancel_stealth()

/obj/item/clothing/suit/space/space_ninja/proc/remove_kamikaze_verbs()
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjashift
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjajaunt
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjapulse
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjastar
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjanet

	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjaslayer
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjawalk
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjamirage

	verbs += /obj/item/clothing/suit/space/space_ninja/proc/stealth

	kamikaze = 0
	k_unlock = 0

/obj/item/clothing/suit/space/space_ninja/proc/grant_AI_verbs()
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ai_hack_ninja
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ai_return_control
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/deinit
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/spideros
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/stealth

	s_control = 0

/obj/item/clothing/suit/space/space_ninja/proc/remove_AI_verbs()
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ai_hack_ninja
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ai_return_control
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/deinit
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/spideros
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/stealth

	s_control = 1

//AI COUNTER HACKING/SPECIAL FUNCTIONS===================================

/obj/item/clothing/suit/space/space_ninja/proc/ai_holo(var/turf/T in oview(3,affecting))//To have an internal AI display a hologram to the ninja only.
	set name = "Display Hologram"
	set desc = "Channel a holographic image directly to the user's field of vision. Others will not see it."
	set category = null
	set src = usr.loc

	if(s_initialized&&affecting&&affecting.client&&istype(affecting.loc, /turf))//If the host exists and they are playing, and their location is a turf.
		if(!hologram)//If there is not already a hologram.
			hologram = new(T)//Spawn a blank effect at the location.
			hologram.invisibility = 101//So that it doesn't show up, ever. This also means one could attach a number of images to a single obj and display them to differently to differnet people.
			hologram.dir = get_dir_to(T,affecting.loc)
			var/image/I = image('mob.dmi',hologram,"ai-holo")//Attach an image to object.
			hologram.i_attached = I//To attach the image in order to later reference.
			AI << I
			affecting << I
			affecting << "<i>An image flicks to life nearby. It appears visible to you only.</i>"

			verbs += /obj/item/clothing/suit/space/space_ninja/proc/ai_holo_clear

			ai_holo_process()//Move to initialize
		else
			AI << "\red ERROR: \black Image feed in progress."
	else
		AI << "\red ERROR: \black Unable to project image."
	return

/obj/item/clothing/suit/space/space_ninja/proc/ai_holo_process()
	set background = 1

	spawn while(hologram&&s_initialized&&AI)//Suit on and there is an AI present.
		if(!s_initialized||get_dist(affecting,hologram.loc)>3)//Once suit is de-initialized or hologram reaches out of bounds.
			del(hologram.i_attached)
			del(hologram)

			verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ai_holo_clear
			return
		sleep(10)//Checks every second.

/obj/item/clothing/suit/space/space_ninja/proc/ai_instruction()//Let's the AI know what they can do.
	set name = "Instructions"
	set desc = "Displays a list of helpful information."
	set category = "AI Ninja Equip"
	set src = usr.loc

	AI << "The menu you are seeing will contain other commands if they become available.\nRight click a nearby turf to display an AI Hologram. It will only be visible to you and your host. You can move it freely using normal movement keys--it will disappear if placed too far away."

/obj/item/clothing/suit/space/space_ninja/proc/ai_holo_clear()
	set name = "Clear Hologram"
	set desc = "Stops projecting the current holographic image."
	set category = "AI Ninja Equip"
	set src = usr.loc

	del(hologram.i_attached)
	del(hologram)

	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ai_holo_clear
	return

/obj/item/clothing/suit/space/space_ninja/proc/ai_hack_ninja()
	set name = "Hack SpiderOS"
	set desc = "Hack directly into the Black Widow(tm) neuro-interface."
	set category = "AI Ninja Equip"
	set src = usr.loc

	hack_spideros()
	return

/obj/item/clothing/suit/space/space_ninja/proc/ai_return_control()
	set name = "Relinquish Control"
	set desc = "Return control to the user."
	set category = "AI Ninja Equip"
	set src = usr.loc

	AI << browse(null, "window=hack spideros")//Close window
	AI << "You have seized your hacking attempt. [affecting] has regained control."
	affecting << "<b>UPDATE</b>: [AI.real_name] has ceased hacking attempt. All systems clear."

	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ai_return_control
	return

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
	dat += "<img src=sos_11.png> Smoke Bombs: [s_bombs]<br>"
	dat += "<br>"

	switch(spideros)
		if(0)
			dat += "<h4><img src=sos_1.png> Available Functions:</h4>"
			dat += "<ul>"
			dat += "<li><a href='byond://?src=\ref[src];choice=Shock'><img src=sos_4.png> Shock [U.real_name]</a></li>"
			dat += "<li><a href='byond://?src=\ref[src];choice=4'><img src=sos_6.png> Activate Abilities</a></li>"
			dat += "<li><a href='byond://?src=\ref[src];choice=1'><img src=sos_3.png> Medical Screen</a></li>"
			dat += "<li><a href='byond://?src=\ref[src];choice=2'><img src=sos_5.png> Atmos Scan</a></li>"
			dat += "<li><a href='byond://?src=\ref[src];choice=3'><img src=sos_12.png> Messenger</a></li>"
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
			dat += "<li><a href='byond://?src=\ref[src];choice=Radium'><img src=sos_2.png> Inject Radium: [(reagents.get_reagent_amount("radium")-60)/20] left</a></li>"//There is 120 radium at start. -60 for adrenaline boosts.
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
		if(4)
			dat += "<h4><img src=sos_6.png> Activate Abilities:</h4>"
			dat += "<ul>"
			dat += "<li><a href='byond://?src=\ref[src];choice=Phase Jaunt'><img src=sos_13.png> Phase Jaunt</a></li>"
			dat += "<li><a href='byond://?src=\ref[src];choice=Phase Shift'><img src=sos_13.png> Phase Shift</a></li>"
			dat += "<li><a href='byond://?src=\ref[src];choice=Energy Blade'><img src=sos_13.png> Energy Blade</a></li>"
			dat += "<li><a href='byond://?src=\ref[src];choice=Energy Star'><img src=sos_13.png> Energy Star</a></li>"
			dat += "<li><a href='byond://?src=\ref[src];choice=Energy Net'><img src=sos_13.png> Energy Net</a></li>"
			dat += "<li><a href='byond://?src=\ref[src];choice=EM Pulse'><img src=sos_13.png> EM Pulse</a></li>"
			dat += "<li><a href='byond://?src=\ref[src];choice=Smoke Bomb'><img src=sos_13.png> Smoke Bomb</a></li>"
			dat += "<li><a href='byond://?src=\ref[src];choice=Adrenaline Boost'><img src=sos_13.png> Adrenaline Boost</a></li>"
			dat += "</ul>"

	dat += "</body></html>"

	A << browse(dat,"window=hack spideros;size=400x444;border=1;can_resize=0;can_close=0;can_minimize=0")


//OLD & UNUSED===================================

/*
I've tried a lot of stuff but adding verbs to the AI while inside an object, inside another object, did not want to work properly.
This was the best work-around I could come up with at the time. Uses objects to then display to panel, based on the object spell system.
Can be added on to pretty easily.

BYOND fixed the verb bugs so this is no longer necessary. I prefer verb panels.

/obj/item/clothing/suit/space/space_ninja/proc/grant_AI_verbs()
	var/obj/proc_holder/ai_return_control/A_C = new(AI)
	var/obj/proc_holder/ai_hack_ninja/B_C = new(AI)
	var/obj/proc_holder/ai_instruction/C_C = new(AI)
	new/obj/proc_holder/ai_holo_clear(AI)
	AI.proc_holder_list += A_C
	AI.proc_holder_list += B_C
	AI.proc_holder_list += C_C

	s_control = 0

/obj/item/clothing/suit/space/space_ninja/proc/remove_AI_verbs()
	var/obj/proc_holder/ai_return_control/A_C = locate() in AI
	var/obj/proc_holder/ai_hack_ninja/B_C = locate() in AI
	var/obj/proc_holder/ai_instruction/C_C = locate() in AI
	var/obj/proc_holder/ai_holo_clear/D_C = locate() in AI
	del(A_C)
	del(B_C)
	del(C_C)
	del(D_C)
	AI.proc_holder_list = list()
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/deinit
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/spideros
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/stealth

	s_control = 1

//Workaround
/obj/proc_holder/ai_holo_clear
	name = "Clear Hologram"
	desc = "Stops projecting the current holographic image."
	panel = "AI Ninja Equip"
	density = 0
	opacity = 0


/obj/proc_holder/ai_holo_clear/Click()
	var/obj/item/clothing/suit/space/space_ninja/S = loc.loc//This is so stupid but makes sure certain things work. AI.SUIT
	del(S.hologram.i_attached)
	del(S.hologram)
	var/obj/proc_holder/ai_holo_clear/D_C = locate() in S.AI
	S.AI.proc_holder_list -= D_C
	return

/obj/proc_holder/ai_instruction//Let's the AI know what they can do.
	name = "Instructions"
	desc = "Displays a list of helpful information."
	panel = "AI Ninja Equip"
	density = 0
	opacity = 0

/obj/proc_holder/ai_instruction/Click()
	loc << "The menu you are seeing will contain other commands if they become available.\nRight click a nearby turf to display an AI Hologram. It will only be visible to you and your host. You can move it freely using normal movement keys--it will disappear if placed too far away."

/obj/proc_holder/ai_hack_ninja//Generic proc holder to make sure the two verbs below work propely.
	name = "Hack SpiderOS"
	desc = "Hack directly into the Black Widow(tm) neuro-interface."
	panel = "AI Ninja Equip"
	density = 0
	opacity = 0

/obj/proc_holder/ai_hack_ninja/Click()//When you click on it.
	var/obj/item/clothing/suit/space/space_ninja/S = loc.loc
	S.hack_spideros()
	return

/obj/proc_holder/ai_return_control
	name = "Relinquish Control"
	desc = "Return control to the user."
	panel = "AI Ninja Equip"
	density = 0
	opacity = 0

/obj/proc_holder/ai_return_control/Click()
	var/mob/living/silicon/ai/A = loc
	var/obj/item/clothing/suit/space/space_ninja/S = A.loc
	A << browse(null, "window=hack spideros")//Close window
	A << "You have seized your hacking attempt. [S.affecting] has regained control."
	S.affecting << "<b>UPDATE</b>: [A.real_name] has ceased hacking attempt. All systems clear."
	S.remove_AI_verbs()
	return
*/

//DEBUG===================================

/*
Most of these are at various points of incomplete.

/mob/verb/grant_object_panel()
	set name = "Grant AI Ninja Verbs Debug"
	set category = "Ninja Debug"
	var/obj/proc_holder/ai_return_control/A_C = new(src)
	var/obj/proc_holder/ai_hack_ninja/B_C = new(src)
	usr:proc_holder_list += A_C
	usr:proc_holder_list += B_C

mob/verb/remove_object_panel()
	set name = "Remove AI Ninja Verbs Debug"
	set category = "Ninja Debug"
	var/obj/proc_holder/ai_return_control/A = locate() in src
	var/obj/proc_holder/ai_hack_ninja/B = locate() in src
	usr:proc_holder_list -= A
	usr:proc_holder_list -= B
	del(A)//First.
	del(B)//Second, to keep the proc going.
	return

/client/verb/grant_verb_ninja_debug1(var/mob/M in view())
	set name = "Grant AI Ninja Verbs Debug"
	set category = "Ninja Debug"

	M.verbs += /mob/living/silicon/ai/verb/ninja_return_control
	M.verbs += /mob/living/silicon/ai/verb/ninja_spideros
	return

/client/verb/grant_verb_ninja_debug2(var/mob/living/carbon/human/M in view())
	set name = "Grant Back Ninja Verbs"
	set category = "Ninja Debug"

	M.wear_suit.verbs += /obj/item/clothing/suit/space/space_ninja/proc/deinit
	M.wear_suit.verbs += /obj/item/clothing/suit/space/space_ninja/proc/spideros
	return

/obj/proc/grant_verb_ninja_debug3(var/mob/living/silicon/ai/A as mob)
	set name = "Grant AI Ninja Verbs"
	set category = "null"
	set hidden = 1
	A.verbs -= /obj/item/clothing/suit/space/space_ninja/proc/deinit
	A.verbs -= /obj/item/clothing/suit/space/space_ninja/proc/spideros
	return

/mob/verb/get_dir_to_target(var/mob/M in oview())
	set name = "Get Direction to Target"
	set category = "Ninja Debug"

	world << "DIR: [get_dir_to(src.loc,M.loc)]"
	return
//
/mob/verb/kill_self_debug()
	set name = "DEBUG Kill Self"
	set category = "Ninja Debug"

	src:death()

/client/verb/switch_client_debug()
	set name = "DEBUG Switch Client"
	set category = "Ninja Debug"

	mob = mob:loc:loc

/mob/verb/possess_mob(var/mob/M in oview())
	set name = "DEBUG Possess Mob"
	set category = "Ninja Debug"

	client.mob = M

/client/verb/switcharoo(var/mob/M in oview())
	set name = "DEBUG Switch to AI"
	set category = "Ninja Debug"

	var/mob/last_mob = mob
	mob = M
	last_mob:wear_suit:AI:key = key
//
/client/verb/ninjaget(var/mob/M in oview())
	set name = "DEBUG Ninja GET"
	set category = "Ninja Debug"

	mob = M
	M.gib()
	space_ninja()

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

I made this as a test for a possible ninja ability (or perhaps more) for a certain mob to see hallucinations.
The thing here is that these guys have to be coded to do stuff as they are simply images that you can't even click on.
That is why you attached them to objects.
/mob/verb/TestNinjaShadow()
	set name = "Test Ninja Ability"
	set category = "Ninja Debug"

	if(client)
		var/safety = 4
		for(var/turf/T in oview(5))
			if(prob(20))
				var/current_clone = image('mob.dmi',T,"s-ninja")
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