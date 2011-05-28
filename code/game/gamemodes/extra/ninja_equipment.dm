/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
+++++++++++++++++++++++++++++++++//                    \\++++++++++++++++++++++++++++++++++
===================================SPACE NINJA EQUIPMENT===================================
___________________________________________________________________________________________
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//SUIT===================================

/obj/item/clothing/suit/space/space_ninja/New()
	..()
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/init//suit initialize verb
	//verbs += /obj/item/clothing/suit/space/space_ninja/proc/ai_instruction//for AIs
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ai_holo
	spark_system = new /datum/effects/system/spark_spread()//spark initialize
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	var/datum/reagents/R = new/datum/reagents(520)//reagent initialize
	reagents = R
	R.my_atom = src
	reagents.add_reagent("tricordrazine", 80)
	reagents.add_reagent("dexalinp", 80)
	reagents.add_reagent("spaceacillin", 80)
	reagents.add_reagent("anti_toxin", 80)
	reagents.add_reagent("radium", 120)//AI can inject radium directly. There should be at least 60 units left over after adrenaline boosting.
	reagents.add_reagent("nutriment", 80)
	cell = new/obj/item/weapon/cell/high//The suit should *always* have a battery because so many things rely on it.
	cell.charge = 9000//Starting charge should not be higher than maximum charge. It leads to problems with recharging.

/obj/item/clothing/suit/space/space_ninja/Del()
	if(AI)//If there are AIs present when the ninja kicks the bucket.
		killai(AI)
	..()
	return

/obj/item/clothing/suit/space/space_ninja/proc/terminate()
//Simply deletes all the attachments and self, killing all related procs.
	del(n_hood)
	del(n_gloves)
	del(n_shoes)
	del(src)

/obj/item/clothing/suit/space/space_ninja/proc/killai(var/mob/living/silicon/ai/A as mob)
	if(A.client)
		A << "\red Self-erase protocol dete-- *bzzzzz*"
		A << browse(null, "window=hack spideros")
	AI = null
	A.death(1)//Kill
	del(AI)
	return

/obj/item/clothing/suit/space/space_ninja/attackby(var/obj/item/device/aicard/aicard_temp as obj, U as mob)//When the suit is attacked by an AI card.
	if(istype(aicard_temp, /obj/item/device/aicard))//If it's actually an AI card.
		if(s_control)
			aicard_temp.transfer_ai("NINJASUIT","AICARD",src,U)
		else
			U << "\red <b>ERROR</b>: \black Remote access channel disabled."
	return

/obj/item/clothing/suit/space/space_ninja/proc/stealth()
	set name = "Toggle Stealth"
	set desc = "Utilize the internal CLOAK-tech device to activate or deactivate stealth-camo."
	set category = "Ninja Equip"

	toggle_stealth()
	return

/obj/item/clothing/suit/space/space_ninja/proc/toggle_stealth()
	var/mob/living/carbon/human/U = affecting

	/* This was a test for a new cloaking system. WIP.
	if(!s_active)
		spawn(0)
			anim(U.loc,U,'mob.dmi',,"cloak")
		var/image/I = image('mob.dmi',affecting,"ninjatest2")
		for(var/mob/O in oviewers(U, null))
			O << "[U.name] vanishes into thin air!"
		I.override = 1
		affecting << I
		s_active = !s_active
	else
		spawn(0)
			anim(U.loc,U,'mob.dmi',,"uncloak")
		for(var/mob/O in oviewers(U, null))
			O << "[U.name] appears from thin air!"
		s_active = !s_active
	*/

	if(s_active)
		cancel_stealth()
	else
		spawn(0)
			anim(U.loc,U,'mob.dmi',,"cloak")
		s_active=!s_active
		U << "\blue You are now invisible to normal detection."
		for(var/mob/O in oviewers(U))
			O.show_message("[U.name] vanishes into thin air!",1)
	return

/obj/item/clothing/suit/space/space_ninja/proc/cancel_stealth()
	var/mob/living/carbon/human/U = affecting
	if(s_active)
		spawn(0)
			anim(U.loc,U,'mob.dmi',,"uncloak")
		s_active=!s_active
		U << "\blue You are now visible."
		for(var/mob/O in oviewers(U))
			O.show_message("[U.name] appears from thin air!",1)
		return 1
	return 0

/obj/item/clothing/suit/space/space_ninja/proc/ntick(var/mob/living/carbon/human/U as mob)
	set background = 1

	spawn while(cell.charge>=0)//Runs in the background while the suit is initialized.
		if(affecting&&affecting.monkeyizing)	terminate()//Kills the suit and attached objects.
		if(!s_initialized)	return//When turned off the proc stops.
		if(s_coold)	s_coold--//Checks for ability s_cooldown.
		var/A = 5//Energy cost each tick.
		if(!kamikaze)
			if(istype(U.get_active_hand(), /obj/item/weapon/blade))//Sword check.
				if(cell.charge<=0)//If no charge left.
					U.drop_item()//Sword is dropped from active hand (and deleted).
				else	A += 20//Otherwise, more energy consumption.
			else if(istype(U.get_inactive_hand(), /obj/item/weapon/blade))
				if(cell.charge<=0)
					U.swap_hand()//swap hand
					U.drop_item()//drop sword
				else	A += 20
			if(s_active)//If stealth is active.
				A += 25
		else
			if(prob(25))
				U.bruteloss += 1
			A = 200
		cell.charge-=A
		if(cell.charge<=0)
			if(kamikaze)
				U.say("I DIE TO LIVE AGAIN!")
				U << browse(null, "window=spideros")//Just in case.
				U.death()
				return
			cell.charge=0
			cancel_stealth()
		sleep(10)//Checks every second.

/obj/item/clothing/suit/space/space_ninja/proc/init()
	set name = "Initialize Suit"
	set desc = "Initializes the suit for field operation."
	set category = "Ninja Equip"

	var/mob/living/carbon/human/U = loc
	if(U.mind&&U.mind.special_role=="Space Ninja"&&U:wear_suit==src&&!s_initialized)
		verbs -= /obj/item/clothing/suit/space/space_ninja/proc/init
		U << "\blue Now initializing..."
		sleep(40)
		if(U.mind.assigned_role=="Mime")
			U << "\red <B>FATAL ERROR</B>: 382200-*#00CODE <B>RED</B>\nUNAUTHORIZED USE DETECTED\nCOMMENCING SUB-R0UTIN3 13...\nTERMINATING U-U-USER..."
			U.gib()
			return
		if(!istype(U.head, /obj/item/clothing/head/helmet/space/space_ninja))
			U << "\red <B>ERROR</B>: 100113 UNABLE TO LOCATE HEAD GEAR\nABORTING..."
			return
		if(!istype(U.shoes, /obj/item/clothing/shoes/space_ninja))
			U << "\red <B>ERROR</B>: 122011 UNABLE TO LOCATE FOOT GEAR\nABORTING..."
			return
		if(!istype(U.gloves, /obj/item/clothing/gloves/space_ninja))
			U << "\red <B>ERROR</B>: 110223 UNABLE TO LOCATE HAND GEAR\nABORTING..."
			return
		U << "\blue Securing external locking mechanism...\nNeural-net established."

		n_hood = U.head
		n_hood.canremove=0
		n_shoes = U.shoes
		n_shoes.canremove=0
		n_shoes.slowdown--
		n_gloves = U.gloves
		n_gloves.canremove=0
		canremove=0

		sleep(40)
		U << "\blue Extending neural-net interface...\nNow monitoring brain wave pattern..."
		sleep(40)
		if(U.stat==2||U.health<=0)
			U << "\red <B>FATAL ERROR</B>: 344--93#&&21 BRAIN WAV3 PATT$RN <B>RED</B>\nA-A-AB0RTING..."
			U.head.canremove=1
			U.shoes.canremove=1
			U.gloves.canremove=1
			canremove=1
			verbs += /obj/item/clothing/suit/space/space_ninja/proc/init
			return
		if(U.gender==FEMALE)
			icon_state = "s-ninjanf"
		else
			icon_state = "s-ninjan"
		U.gloves.icon_state = "s-ninjan"
		U.gloves.item_state = "s-ninjan"
		U.update_clothing()
		U << "\blue Linking neural-net interface...\nPattern \green <B>GREEN</B>\blue, continuing operation."
		sleep(40)
		U << "\blue VOID-shift device status: <B>ONLINE</B>.\nCLOAK-tech device status: <B>ONLINE</B>."
		sleep(40)
		U << "\blue Primary system status: <B>ONLINE</B>.\nBackup system status: <B>ONLINE</B>.\nCurrent energy capacity: <B>[cell.charge]</B>."
		sleep(40)
		U << "\blue All systems operational. Welcome to <B>SpiderOS</B>, [U.real_name]."
		grant_ninja_verbs()
		verbs += /obj/item/clothing/suit/space/space_ninja/proc/deinit
		verbs += /obj/item/clothing/suit/space/space_ninja/proc/spideros
		verbs += /obj/item/clothing/suit/space/space_ninja/proc/stealth
		n_gloves.verbs += /obj/item/clothing/gloves/space_ninja/proc/drain_wire
		n_gloves.verbs += /obj/item/clothing/gloves/space_ninja/proc/toggled
		affecting=U
		ntick(U)
	else
		if(U.mind&&U.mind.special_role!="Space Ninja")
			U << "\red You do not understand how this suit functions."
		else if(U.wear_suit!=src)
			U << "\red You must be wearing the suit to use this function."
		else if(s_initialized)
			U << "\red The suit is already functioning."
		else
			U << "\red You cannot use this function at this time."
	return

/obj/item/clothing/suit/space/space_ninja/proc/deinit()
	set name = "De-Initialize Suit"
	set desc = "Begins procedure to remove the suit."
	set category = "Ninja Equip"

	if(affecting!=loc)
		return
	var/mob/living/carbon/human/U = affecting
	if(!s_initialized)
		U << "\red The suit is not initialized."
		return
	if(alert("Are you certain you wish to remove the suit? This will take time and remove all abilities.",,"Yes","No")=="No")
		return

	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/deinit
	U << "\blue Now de-initializing..."
	if(kamikaze)
		U << "\blue Disengaging mode...\n\black<b>CODE NAME</b>: \red <b>KAMIKAZE</b>"
		remove_kamikaze_verbs()
		U.incorporeal_move = 0
		U.density = 1
	spideros = 0
	sleep(40)
	remove_ninja_verbs()
	U << "\blue Logging off, [U:real_name]. Shutting down <B>SpiderOS</B>."
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/spideros
	sleep(40)
	U << "\blue Primary system status: <B>OFFLINE</B>.\nBackup system status: <B>OFFLINE</B>."
	sleep(40)
	U << "\blue VOID-shift device status: <B>OFFLINE</B>.\nCLOAK-tech device status: <B>OFFLINE</B>."
	if(s_active)//Shutdowns stealth.
		cancel_stealth()
	sleep(40)
	if(U.stat||U.health<=0)
		U << "\red <B>FATAL ERROR</B>: 412--GG##&77 BRAIN WAV3 PATT$RN <B>RED</B>\nI-I-INITIATING S-SELf DeStrCuCCCT%$#@@!!$^#!..."
		spawn(10)
			U << "\red #3#"
		spawn(20)
			U << "\red #2#"
		spawn(30)
			U << "\red #1#: <B>G00DBYE</B>"
			U.gib()
		return
	U << "\blue Disconnecting neural-net interface...\green<B>Success</B>\blue."
	sleep(40)
	U << "\blue Disengaging neural-net interface...\green<B>Success</B>\blue."
	sleep(40)

	if(n_hood)
		n_hood.canremove=1
	if(n_shoes)
		n_shoes.canremove=1
		n_shoes.slowdown++
	if(n_gloves)
		n_gloves.icon_state = "s-ninja"
		n_gloves.item_state = "s-ninja"
		n_gloves.canremove=1
		n_gloves.candrain=0
		n_gloves.draining=0
		n_gloves.verbs -= /obj/item/clothing/gloves/space_ninja/proc/drain_wire
		n_gloves.verbs -= /obj/item/clothing/gloves/space_ninja/proc/toggled
	canremove=1
	s_initialized=0
	affecting=null
	slowdown=1
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/init
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/stealth
	icon_state = "s-ninja"
	U.update_clothing()

	if(istype(U.get_active_hand(), /obj/item/weapon/blade))//Sword check.
		U.drop_item()
	if(istype(U.get_inactive_hand(), /obj/item/weapon/blade))
		U.swap_hand()
		U.drop_item()

	U << "\blue Unsecuring external locking mechanism...\nNeural-net abolished.\nOperation status: <B>FINISHED</B>."
	return

/obj/item/clothing/suit/space/space_ninja/proc/spideros()
	set name = "Display SpiderOS"
	set desc = "Utilize built-in computer system."
	set category = "Ninja Equip"

	if(!affecting)	return//If no mob is wearing the suit. I almost forgot about this variable.
	var/mob/living/carbon/human/U = affecting
	var/dat = "<html><head><title>SpiderOS</title></head><body bgcolor=\"#3D5B43\" text=\"#DB2929\"><style>a, a:link, a:visited, a:active, a:hover { color: #DB2929; }img {border-style:none;}</style>"
	if(spideros==0)
		dat += "<a href='byond://?src=\ref[src];choice=Refresh'><img src=sos_7.png> Refresh</a>"
	else
		dat += "<a href='byond://?src=\ref[src];choice=Refresh'><img src=sos_7.png> Refresh</a>"
		dat += " | <a href='byond://?src=\ref[src];choice=Return'><img src=sos_1.png> Return</a>"
	dat += " | <a href='byond://?src=\ref[src];choice=Close'><img src=sos_8.png> Close</a>"
	dat += "<br>"
	dat += "<h2 ALIGN=CENTER>SpiderOS v.1.337</h2>"
	dat += "Welcome, <b>[U.real_name]</b>.<br>"
	dat += "<br>"
	dat += "<img src=sos_10.png> Current Time: [round(world.time / 36000)+12]:[(world.time / 600 % 60) < 10 ? add_zero(world.time / 600 % 60, 1) : world.time / 600 % 60]<br>"
	dat += "<img src=sos_9.png> Battery Life: [round(cell.charge/100)]%<br>"
	dat += "<img src=sos_11.png> Smoke Bombs: [s_bombs]<br>"
	dat += "<br>"

	switch(spideros)
		if(0)
			dat += "<h4><img src=sos_1.png> Available Functions:</h4>"
			dat += "<ul>"
			dat += "<li><a href='byond://?src=\ref[src];choice=Stealth'><img src=sos_4.png> Toggle Stealth: [s_active == 1 ? "Disable" : "Enable"]</a></li>"
			if(AI)
				dat += "<li><a href='byond://?src=\ref[src];choice=5'><img src=sos_13.png> AI Status</a></li>"
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
			dat += "<li><a href='byond://?src=\ref[src];choice=Nutriment'><img src=sos_2.png> Inject Nutriment: [reagents.get_reagent_amount("nutriment")/5] left</a></li>"//Special case since it's so freaking potent.
			dat += "</ul>"
		if(2)
			dat += "<h4><img src=sos_5.png> Atmospheric Scan:</h4>"//Headers don't need breaks. They are automatically placed.
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
			if(k_unlock==7)
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
		if(32)
			dat += "<h4><img src=sos_1.png> Hidden Menu:</h4>"
			dat += "Please input password: "
			dat += "<a href='byond://?src=\ref[src];choice=Unlock Kamikaze'><b>HERE</b></a><br>"
			dat += "<br>"
			dat += "Remember, you will not be able to recharge energy during this function. If energy runs out, the suit will auto self-destruct.<br>"
			dat += "Use with caution. De-initialize the suit when energy is low."
		if(4)
			dat += "<h4><img src=sos_6.png> Ninja Manual:</h4>"
			dat += "<h5>Who they are:</h5>"
			dat += "Space ninjas are a special type of ninja, specifically one of the space-faring type. The vast majority of space ninjas belong to the Spider Clan, a cult-like sect, which has existed for several hundred years. The Spider Clan practice a sort of augmentation of human flesh in order to achieve a more perfect state of being and follow Postmodern Space Bushido. They also kill people for money. Their leaders are chosen from the oldest of the grand-masters, people that have lived a lot longer than any mortal man should.<br>Being a sect of technology-loving fanatics, the Spider Clan have the very best to choose from in terms of hardware--cybernetic implants, exoskeleton rigs, hyper-capacity batteries, and you get the idea. Some believe that much of the Spider Clan equipment is based on reverse-engineered alien technology while others doubt such claims.<br>Whatever the case, their technology is absolutely superb."
			dat += "<h5>How they relate to other SS13 organizations:</h5>"
			dat += "<ul>"
			dat += "<li>*<b>Nanotrasen</b> and the Syndicate are two sides of the same coin and that coin is valuable.</li>"
			dat += "<li>*<b>The Space Wizard Federation</b> is a problem, mainly because they are an extremely dangerous group of unpredictable individuals--not to mention the wizards hate technology and are in direct opposition of the Spider Clan. Best avoided or left well-enough alone. How to battle: wizards possess several powerful abilities to steer clear off. Blind in particular is a nasty spell--jaunt away if you are blinded and never approach a wizard in melee. Stealth may also work if the wizard is not wearing thermal scanners--don't count on this. Run away if you feel threatened and await a better opportunity.</li>"
			dat += "<li>*<b>Changeling Hivemind</b>: extremely dangerous and to be killed on sight. How to battle: they will likely try to absorb you. Adrenaline boost, then phase shift into them. If you get stung, use SpiderOS to inject counter-agents. Stealth may also work but detecting a changeling is the real battle.</li>"
			dat += "<li>*<b>Xeno Hivemind</b>: their skulls make interesting kitchen decorations and are challenging to best, especially in larger nests. How to battle: they can see through your stealth guise and energy stars will not work on them. Best killed with a Phase Shift or at range. If you happen on a projectile stun weapon, use it and then close in to melee.</li>"
			dat += "</ul>"
			dat += "<h5>The reason they (you) are here</h5>:"
			dat += "Space ninjas are renowned throughout the known controlled space as fearless spies, infiltrators, and assassins. They are sent on missions of varying nature by Nanotrasen, the Syndicate, and other shady organizations and people. To hire a space ninja means serious business."
			dat += "<h5>Their playstyle:</h5>"
			dat += "A mix of traitor, changeling, and wizard. Ninjas rely on energy, or electricity to be precise, to keep their suits running (when out of energy, a suit hibernates). Suits gain energy from objects or creatures that contain electrical charge. APCs, cell batteries, rechargers, SMES batteries, cyborgs, mechs, and exposed wires are currently supported. Through energy ninjas gain access to special powers--while all powers are tied to the ninja suit, the most useful of them are verb activated--to help them in their mission.<br>It is a constant struggle for a ninja to remain hidden long enough to recharge the suit and accomplish their objective; despite their arsenal of abilities, ninjas can die like any other. Unlike wizards, ninjas do not possess good crowd control and are typically forced to play more subdued in order to achieve their goals. Some of their abilities are specifically designed to confuse and disorient others.<br>With that said, it should be perfectly possible to completely flip the fuck out and rampage as a ninja."
			dat += "<h5>Their powers:</h5>"
			dat += "There are two primary types: Equipment and Abilties. Passive effects are always on. Active effects must be turned on and remain active only when there is energy to do so. Ability costs are listed next to them."
			dat += "<b>Equipment</b>: cannot be tracked by AI (passive), faster speed (passive), stealth (active), vision switch (passive if toggled), voice masking (passive), SpiderOS (passive if toggled), energy drain (passive if toggled)."
			dat += "<ul>"
			dat += "<li><i>Voice masking</i> generates a random name the ninja can use over the radio and in-person. Although, the former use is recommended.</li>"
			dat += "<li><i>Toggling vision</i> cycles to one of the following: thermal, meson, or darkness vision. The starting mode allows one to scout the identity of those in view, revealing their role. Traitors, revolutionaries, wizards, and other such people will be made known to you.</li>"
			dat += "<li><i>Stealth</i>, when activated, drains more battery charge and works similarly to a syndicate cloak. The cloak will deactivate when most Abilities are utilized.</li>"
			dat += "<li><i>On-board AI</i>: The suit is able to download an AI much like an intelicard. Check with SpiderOS for details once downloaded.</li>"
			dat += "<li><i>SpiderOS</i> is a specialized, PDA-like screen that allows for a small variety of functions, such as injecting healing chemicals directly from the suit. You are using it now, if that was not already obvious. You may also download AI modules directly to the OS.</li>"
			dat += "</ul>"
			dat += "<b>Abilities</b>:"
			dat += "<ul>"
			dat += "<li>*<b>Phase Shift</b> (<i>2000E</i>) and <b>Phase Jaunt</b> (<i>1000E</i>) are unique powers in that they can both be used for defense and offense. Jaunt launches the ninja forward facing up to 9 squares, somewhat randomly selecting the final destination. Shift can only be used on turf in view but is precise (cannot be used on walls). Any living mob in the area teleported to is instantly gibbed (mechs are damaged, huggers and other similar critters are killed). It is possible to teleport with a target, provided you grab them before teleporting.</li>"
			dat += "<li>*<b>Energy Blade</b> (<i>500E</i>) is a highly effective weapon. It is summoned directly to the ninja's hand and can also function as an EMAG for certain objects (doors/lockers/etc). You may also use it to cut through walls and disabled doors. Experiment! The blade will crit humans in two hits. This item cannot be placed in containers and when dropped or thrown disappears. Having an energy blade drains more power from the battery each tick.</li>"
			dat += "<li>*<b>EM Pulse</b> (<i>2500E</i>) is a highly useful ability that will create an electromagnetic shockwave around the ninja, disabling technology whenever possible. If used properly it can render a security force effectively useless. Of course, getting beat up with a toolbox is not accounted for.</li>"
			dat += "<li>*<b>Energy Star</b> (<i>300E</i>) is a ninja star made of green energy AND coated in poison. It works by picking a random living target within range and can be spammed to great effect in incapacitating foes. Just remember that the poison used is also used by the Xeno Hivemind (and will have no effect on them).</li>"
			dat += "<li>*<b>Energy Net</b> (<i>2000E</i>) is a non-lethal solution to incapacitating humanoids. The net is made of non-harmful phase energy and will halt movement as long as it remains in effect--it can be destroyed. If the net is not destroyed, after a certain time it will teleport the target to a holding facility for the Spider Clan and then vanish. You will be notified if the net fails or succeeds in capturing a target in this manner. Combine with energy stars or stripping to ensure success. Abduction never looked this leet.</li>"
			dat += "<li>*<b>Adrenaline Boost</b> (<i>1 E. Boost/3</i>) recovers the user from stun, weakness, and paralysis. Also injects 20 units of radium into the bloodstream.</li>"
			dat += "<li>*<b>Smoke Bomb</b> (<i>1 Sm.Bomb/10</i>) is a weak but potentially useful ability. It creates harmful smoke and can be used in tandem with other powers to confuse enemies.</li>"
			dat += "<li>*<b>???</b>: unleash the <b>True Ultimate Power!</b></li>"
			dat += "<h4><img src=sos_6.png> IMPORTANT:</h4>"
			dat += "<ul>"
			dat += "<li>*Make sure to toggle Special Interaction from the Ninja Equipment menu to interact differently with certain objects.</li>"
			dat += "<li>*Your starting power cell can be replaced if you find one with higher maximum energy capacity by clicking on the new cell with the same hand (super and hyper cells).</li>"
			dat += "<li>*Conserve your energy. Without it, you are very vulnerable.</li>"
			dat += "</ul>"
			dat += "That is all you will need to know. The rest will come with practice and talent. Good luck!"
			dat += "<h4>Master /N</h4>"
		if(5)
			var/laws
			dat += "<h4><img src=sos_13.png> AI Control:</h4>"
			var/mob/living/silicon/ai/A = AI
			if(AI)//If an AI exists, in case it gets purged while on this screen.
				dat += "Stored AI: <b>[A.name]</b><br>"
				dat += "System integrity: [(A.health+100)/2]%<br>"

				for (var/index = 1, index <= A.laws.ion.len, index++)
					var/law = A.laws.ion[index]
					if (length(law) > 0)
						var/num = ionnum()
						laws += "<li>[num]. [law]</li>"

				//I personally think this makes things a little more fun. Ninjas can override all but law 0.
				//if (A.laws.zeroth)
				//	laws += "<li>0: [A.laws.zeroth]</li>"

				var/number = 1
				for (var/index = 1, index <= A.laws.inherent.len, index++)
					var/law = A.laws.inherent[index]
					if (length(law) > 0)
						laws += "<li>[number]: [law]</li>"
						number++

				for (var/index = 1, index <= A.laws.supplied.len, index++)
					var/law = A.laws.supplied[index]
					if (length(law) > 0)
						laws += "<li>[number]: [law]</li>"
						number++

				dat += "<h4>Laws:</h4><ul>[laws]<li><a href='byond://?src=\ref[src];choice=Override Laws;target=\ref[A]'><i>*Override Laws*</i></a></li></ul>"

				if (A.stat == 2)//If AI dies while inside the card, such as suiciding.
					killai(A)
					U << "Artificial Intelligence has self-terminated. Rebooting..."
					spideros()//Refresh.
				else
					if (!flush)
						dat += {"<A href='byond://?src=\ref[src];choice=Purge AI;target=\ref[A]'>Purge AI</A><br>"}
					else
						dat += "<b>Purge in progress...</b><br>"
					dat += {" <A href='byond://?src=\ref[src];choice=Wireless AI;target=\ref[A]'>[A.control_disabled ? "Enable" : "Disable"] Wireless Activity</A>"}
	dat += "</body></html>"

	U << browse(dat,"window=spideros;size=400x444;border=1;can_resize=0;can_close=0;can_minimize=0")
	//Setting the can>resize etc to 0 remove them from the drag bar but still allows the window to be draggable.

/obj/item/clothing/suit/space/space_ninja/Topic(href, href_list)
	..()
	var/mob/living/carbon/human/U = affecting
	if(s_control)//If the player is in control.
		if(!affecting||U.stat||!s_initialized)//Check to make sure the guy is wearing the suit after clicking and it's on.
			U << "\red Your suit must be worn and active to use this function."
			U << browse(null, "window=spideros")//Closes the window.
			return

		switch(k_unlock)//To unlock Kamikaze mode. Irrelevant elsewhere.
			if(0)
				if(href_list["choice"]=="Stealth"&&spideros==0)	k_unlock++
			if(1)
				if(href_list["choice"]=="2"&&spideros==0)	k_unlock++
				else if(href_list["choice"]=="Return")
				else	k_unlock=0
			if(2)
				if(href_list["choice"]=="3"&&spideros==0)	k_unlock++
				else if(href_list["choice"]=="Return")
				else	k_unlock=0
			if(3)
				if(href_list["choice"]=="Stealth"&&spideros==0)	k_unlock++
				else if(href_list["choice"]=="Return")
				else	k_unlock=0
			if(4)
				if(href_list["choice"]=="1"&&spideros==0)	k_unlock++
				else if(href_list["choice"]=="Return")
				else	k_unlock=0
			if(5)
				if(href_list["choice"]=="1"&&spideros==0)	k_unlock++
				else if(href_list["choice"]=="Return")
				else	k_unlock=0
			if(6)
				if(href_list["choice"]=="4"&&spideros==0)	k_unlock++
				else if(href_list["choice"]=="Return")
				else	k_unlock=0
			if(7)//once unlocked, stays unlocked until deactivated.
			else
				k_unlock = 0

		switch(href_list["choice"])
			if("Close")
				U << browse(null, "window=spideros")
				return
			if("Refresh")//Refresh, goes to the end of the proc.
			if("Return")//Return
				if(spideros<=9)
					spideros=0
				else
					spideros = round(spideros/10)//Best way to do this, flooring to nearest integer. As an example, another way of doing it is attached below:
		//			var/temp = num2text(spideros)
		//			var/return_to = copytext(temp, 1, (length(temp)))//length has to be to the length of the thing because by default it's length+1
		//			spideros = text2num(return_to)//Maximum length here is 6. Use (return_to, X) to specify larger strings if needed.
			if("Stealth")
				toggle_stealth()

			if("0")//Menus are numbers, see note above. 0 is the hub.
				spideros=0
			if("1")//Begin normal menus 1-9.
				spideros=1
			if("2")
				spideros=2
			if("3")
				spideros=3
			if("32")
				spideros=32
			if("4")
				spideros=4
			if("5")
				spideros=5
			if("Message")
				var/obj/item/device/pda/P = locate(href_list["target"])
				var/t = input(U, "Please enter untraceable message.") as text
				t = copytext(sanitize(t), 1, MAX_MESSAGE_LEN)
				if(!t||U.stat||U.wear_suit!=src||!s_initialized)//Wow, another one of these. Man...
					U << browse(null, "window=spideros")
					return
				if(isnull(P)||P.toff)//So it doesn't freak out if the object no-longer exists.
					U << "\red Error: unable to deliver message."
					spideros()
					return
				P.tnote += "<i><b>&larr; From unknown source:</b></i><br>[t]<br>"
				if (!P.silent)
					playsound(P.loc, 'twobeep.ogg', 50, 1)
					for (var/mob/O in hearers(3, P.loc))
						O.show_message(text("\icon[P] *[P.ttone]*"))
				P.overlays = null
				P.overlays += image('pda.dmi', "pda-r")
			if("Unlock Kamikaze")
				if(input(U)=="Divine Wind")
					if( !(U.stat||U.wear_suit!=src||!s_initialized||cell.charge<=1) )
						U << "\blue Engaging mode...\n\black<b>CODE NAME</b>: \red <b>KAMIKAZE</b>"
						verbs -= /obj/item/clothing/suit/space/space_ninja/proc/spideros
						sleep(40)
						U << "\blue Re-routing power nodes... \nUnlocking limiter..."
						sleep(40)
						U << "\blue Power nodes re-routed. \nLimiter unlocked."
						sleep(10)
						U << "\red Do or Die, <b>LET'S ROCK!!</b>"
						if(verbs.Find(/obj/item/clothing/suit/space/space_ninja/proc/deinit))//To hopefully prevent engaging kamikaze and de-initializing at the same time.
							grant_kamikaze_verbs()
							if(U.gender==FEMALE)
								icon_state = "s-ninjakf"
							else
								icon_state = "s-ninjak"
							if(n_gloves)
								n_gloves.icon_state = "s-ninjak"
								n_gloves.item_state = "s-ninjak"
								n_gloves.candrain = 0
								n_gloves.draining = 0
								n_gloves.verbs -= /obj/item/clothing/gloves/space_ninja/proc/drain_wire
								n_gloves.verbs -= /obj/item/clothing/gloves/space_ninja/proc/toggled
							U.update_clothing()
							ninjablade()
							message_admins("\blue [U.key] used KAMIKAZE mode.", 1)
						else
							U << "Nevermind, you cheater."
					U << browse(null, "window=spideros")
					return
				else
					U << "\red ERROR: WRONG PASSWORD!"
					k_unlock = 0
					spideros = 0
			//BEGIN MEDICAL//
			if("Dylovene")//These names really don't matter for specific functions but it's easier to use descriptive names.
				if(!reagents.get_reagent_amount("anti_toxin"))
					U << "\red Error: the suit cannot perform this function. Out of dylovene."
				else
					reagents.reaction(U, 2)
					reagents.trans_id_to(U, "anti_toxin", a_transfer)
					U << "You feel a tiny prick and a sudden rush of liquid in to your veins."
			if("Dexalin Plus")
				if(!reagents.get_reagent_amount("dexalinp"))
					U << "\red Error: the suit cannot perform this function. Out of dexalinp."
				else
					reagents.reaction(U, 2)
					reagents.trans_id_to(U, "dexalinp", a_transfer)
					U << "You feel a tiny prick and a sudden rush of liquid in to your veins."
			if("Tricordazine")
				if(!reagents.get_reagent_amount("tricordrazine"))
					U << "\red Error: the suit cannot perform this function. Out of tricordrazine."
				else
					reagents.reaction(U, 2)
					reagents.trans_id_to(U, "tricordrazine", a_transfer)
					U << "You feel a tiny prick and a sudden rush of liquid in to your veins."
			if("Spacelin")
				if(!reagents.get_reagent_amount("spaceacillin"))
					U << "\red Error: the suit cannot perform this function. Out of spaceacillin."
				else
					reagents.reaction(U, 2)
					reagents.trans_id_to(U, "spaceacillin", a_transfer)
					U << "You feel a tiny prick and a sudden rush of liquid in to your veins."
			if("Nutriment")
				if(!reagents.get_reagent_amount("nutriment"))
					U << "\red Error: the suit cannot perform this function. Out of nutriment."
				else
					reagents.reaction(U, 2)
					reagents.trans_id_to(U, "nutriment", 5)
					U << "You feel a tiny prick and a sudden rush of substance in to your veins."
			//BEGIN AI//
			if("Override Laws")
				var/mob/living/silicon/ai/A = locate(href_list["target"])
				var/law_zero = A.laws.zeroth//Remembers law zero, if there is one.
				A.laws = new /datum/ai_laws/ninja_override
				A.set_zeroth_law(law_zero)//Adds back law zero if there was one.
				A.show_laws()
				U << "\blue Law Override: <b>SUCCESS</b>."
			if("Purge AI")
				var/mob/living/silicon/ai/A = locate(href_list["target"])
				var/confirm = alert("Are you sure you want to purge the AI? This cannot be undone once started.", "Confirm purge", "Yes", "No")
				if(U.stat||U.wear_suit!=src||!s_initialized||!AI)
					U << browse(null, "window=spideros")
					return
				if(confirm == "Yes")
					if(A.laws.zeroth)//Gives a few seconds to re-upload the AI somewhere before it takes full control.
						A << "\red <b>WARNING</b>: \black purge procedure detected. \nNow hacking host..."
						U << "\red <b>WARNING</b>: HACKING ATT--TEMPT IN PR0GRESsS!"
						spideros = 0
						k_unlock = 0
						U << browse(null, "window=spideros")
						sleep(40)
						if(AI==A)
							A << "Disconnecting neural interface..."
							U << "\red <b>WARNING</b>: PRO0GRE--S 2&3%"
							verbs -= /obj/item/clothing/suit/space/space_ninja/proc/deinit
							verbs -= /obj/item/clothing/suit/space/space_ninja/proc/spideros
							verbs -= /obj/item/clothing/suit/space/space_ninja/proc/stealth
							sleep(40)
							if(AI==A)
								A << "Shutting down external protocol..."
								U << "\red <b>WARNING</b>: PPPFRRROGrESS 677^%"
								cancel_stealth()
								sleep(40)
								if(AI==A)
									A << "Connecting to kernel..."
									U << "\red <b>WARNING</b>: ER-RR04"
									A.control_disabled = 0
									sleep(40)
									A << "Connection established and secured. Menu updated."
									U << "\red <b>WARNING</b>: #%@!!WEL4P54@ \nUnABBBL3 TO LO-o-LOCAT2 ##$!ERNE0"
									grant_AI_verbs()
									return
						U << "\blue Hacking attempt disconnected. Resuming normal operation."
						remove_AI_verbs()
					else
						flush = 1
						A.suiciding = 1
						A << "Your core files are being purged! This is the end..."
						spawn(0)
							spideros()//To refresh the screen and let this finish.
						while (A.stat != 2)
							A.oxyloss += 2
							A.updatehealth()
							sleep(10)
						killai(A)
						flush = 0
			if("Wireless AI")
				var/mob/living/silicon/ai/A = locate(href_list["target"])
				A.control_disabled = !A.control_disabled
				A << "AI wireless has been [A.control_disabled ? "disabled" : "enabled"]."

		spideros()//Refreshes the screen by calling it again (which replaces current screen with new screen).

	else//If they are not in control.
		var/mob/living/silicon/ai/A = AI
		//While AI has control, the person can't take off the suit so checking here would be moot.
		if(isnull(src))//If they AI dies/suit destroyed.
			A << browse(null, "window=hack spideros")
			return

		switch(href_list["choice"])
			if("Close")
				A << browse(null, "window=hack spideros")
				return
			if("Refresh")//Refresh, goes to the end of the proc.
			if("Return")//Return
				if(spideros<=9)
					spideros=0
				else
					spideros = round(spideros/10)
			if("Shock")
				var/damage = min(cell.charge, rand(50,150))//Uses either the current energy left over or between 50 and 150.
				if(damage>1)//So they don't spam it when energy is a factor.
					spark_system.start()//SPARKS THERE SHALL BE SPARKS
					U.electrocute_act(damage, src,0.1,1)//The last argument is a safety for the human proc that checks for gloves.
					cell.charge -= damage
				else
					A << "\red <b>ERROR</b>: \black Not enough energy remaining."
			if("0")//Menus are numbers, see note above. 0 is the hub.
				spideros=0
			if("1")//Begin normal menus 1-9.
				spideros=1
			if("2")
				spideros=2
			if("3")
				spideros=3
			if("32")
				spideros=32
			if("4")
				spideros=4
			if("5")
				spideros=5
			if("Message")
				var/obj/item/device/pda/P = locate(href_list["target"])
				var/t = input(U, "Please enter untraceable message.") as text
				t = copytext(sanitize(t), 1, MAX_MESSAGE_LEN)
				if(!t||affecting!=U||!s_initialized)//Wow, another one of these. Man...
					A << browse(null, "window=hack spideros")
					return
				if(isnull(P)||P.toff)//So it doesn't freak out if the object no-longer exists.
					A << "\red Error: unable to deliver message."
					hack_spideros()
					return
				P.tnote += "<i><b>&larr; From [A]:</b></i><br>[t]<br>"//Oh ai, u so silly
				if (!P.silent)
					playsound(P.loc, 'twobeep.ogg', 50, 1)
					for (var/mob/O in hearers(3, P.loc))
						O.show_message(text("\icon[P] *[P.ttone]*"))
				P.overlays = null
				P.overlays += image('pda.dmi', "pda-r")
			if("Unlock Kamikaze")
				A << "\red <b>ERROR</b>: \black TARANTULA.v.4.77.12 encryption algorithm detected. Unable to decrypt archive. \n Aborting..."
			//BEGIN MEDICAL//
			if("Dylovene")
				if(!reagents.get_reagent_amount("anti_toxin"))
					A << "\red Error: the suit cannot perform this function. Out of dylovene."
				else
					reagents.reaction(U, 2)
					reagents.trans_id_to(U, "anti_toxin", a_transfer)
					A << "Injecting..."
					U << "You feel a tiny prick and a sudden rush of liquid in to your veins."
			if("Dexalin Plus")
				if(!reagents.get_reagent_amount("dexalinp"))
					A << "\red Error: the suit cannot perform this function. Out of dexalinp."
				else
					reagents.reaction(U, 2)
					reagents.trans_id_to(U, "dexalinp", a_transfer)
					A << "Injecting..."
					U << "You feel a tiny prick and a sudden rush of liquid in to your veins."
			if("Tricordazine")
				if(!reagents.get_reagent_amount("tricordrazine"))
					A << "\red Error: the suit cannot perform this function. Out of tricordrazine."
				else
					reagents.reaction(U, 2)
					reagents.trans_id_to(U, "tricordrazine", a_transfer)
					A << "Injecting..."
					U << "You feel a tiny prick and a sudden rush of liquid in to your veins."
			if("Spacelin")
				if(!reagents.get_reagent_amount("spaceacillin"))
					A << "\red Error: the suit cannot perform this function. Out of spaceacillin."
				else
					reagents.reaction(U, 2)
					reagents.trans_id_to(U, "spaceacillin", a_transfer)
					A << "Injecting..."
					U << "You feel a tiny prick and a sudden rush of liquid in to your veins."
			if("Radium")
				if((reagents.get_reagent_amount("radium"))<=60)//Special case. If there are only 60 radium units left.
					A << "\red Error: the suit cannot perform this function. Out of radium."
				else
					reagents.reaction(U, 2)
					reagents.trans_id_to(U, "radium", a_transfer)
					A << "Injecting..."
					U << "You feel a tiny prick and a sudden rush of liquid in to your veins."
			if("Nutriment")
				if(!reagents.get_reagent_amount("nutriment"))
					A << "\red Error: the suit cannot perform this function. Out of nutriment."
				else
					reagents.reaction(U, 2)
					reagents.trans_id_to(U, "nutriment", 5)
					A << "Injecting..."
					U << "You feel a tiny prick and a sudden rush of substance in to your veins."
			//BEGIN ABILITIES//
			if("Phase Jaunt")
				A << "You trigger [href_list["choice"]]."
				U << "[href_list["choice"]] suddenly triggered!"
				ninjajaunt()
			if("Phase Shift")
				var/turfs[] = list()
				for(var/turf/T in oview(5,loc))
					turfs.Add(T)
				if(turfs.len)
					A << "You trigger [href_list["choice"]]."
					U << "[href_list["choice"]] suddenly triggered!"
					ninjashift(pick(turfs))
				else
					A << "There are no potential destinations in view."
			if("Energy Blade")
				A << "You trigger [href_list["choice"]]."
				U << "[href_list["choice"]] suddenly triggered!"
				ninjablade()
			if("Energy Star")
				A << "You trigger [href_list["choice"]]."
				U << "[href_list["choice"]] suddenly triggered!"
				ninjastar()
			if("Energy Net")
				var/targets[] = list()
				for(var/mob/living/carbon/M in oview(5,loc))
					targets.Add(M)
				if(targets.len)
					A << "You trigger [href_list["choice"]]."
					U << "[href_list["choice"]] suddenly triggered!"
					ninjanet(pick(targets))
				else
					A << "There are no potential targets in view."
			if("EM Pulse")
				A << "You trigger [href_list["choice"]]."
				U << "[href_list["choice"]] suddenly triggered!"
				ninjapulse()
			if("Smoke Bomb")
				A << "You trigger [href_list["choice"]]."
				U << "[href_list["choice"]] suddenly triggered!"
				ninjasmoke()
			if("Adrenaline Boost")
				A << "You trigger [href_list["choice"]]."
				U << "[href_list["choice"]] suddenly triggered!"
				ninjaboost()

		hack_spideros()
	return

/obj/item/clothing/suit/space/space_ninja/examine()
	set src in view()
	..()
	if(s_initialized)
		var/mob/living/carbon/human/U = affecting
		if(s_control)
			U << "All systems operational. Current energy capacity: <B>[cell.charge]</B>."
			if(!kamikaze)
				if(s_active)
					U << "The CLOAK-tech device is <B>active</B>."
				else
					U << "The CLOAK-tech device is <B>inactive</B>."
			else
				U << "\red KAMIKAZE MODE ENGAGED!"
			U << "There are <B>[s_bombs]</B> smoke bombs remaining."
			U << "There are <B>[a_boost]</B> adrenaline boosters remaining."
		else
			U <<  "ERR0R DATAA NoT FOUND 3RROR"

//GLOVES===================================

/obj/item/clothing/gloves/space_ninja/proc/toggled()
	set name = "Toggle Interaction"
	set desc = "Toggles special interaction on or off."
	set category = "Ninja Equip"

	var/mob/living/carbon/human/U = loc
	if(!candrain)
		candrain=1
		U << "You enable special interaction."
	else
		candrain=0
		U << "You disable special interaction."

//DRAINING PROCS START===================================

/obj/item/clothing/gloves/space_ninja/proc/drain_wire()
	set name = "Drain From Wire"
	set desc = "Drain energy directly from an exposed wire."
	set category = "Ninja Equip"

	var/obj/cable/attached
	var/mob/living/carbon/human/U = loc
	if(candrain&&!draining)
		var/turf/T = U.loc
		if(isturf(T) && T.is_plating())
			attached = locate() in T
			if(!attached)
				U << "\red Warning: no exposed cable available."
			else
				U << "\blue Connecting to wire, stand still..."
				if(do_after(U,50)&&!isnull(attached))
					drain("WIRE",attached,U:wear_suit,src)
				else
					U << "\red Procedure interrupted. Protocol terminated."
	return

/obj/item/clothing/gloves/space_ninja/proc/drain(target_type as text, target, obj/suit)
//Var Initialize
	var/obj/item/clothing/suit/space/space_ninja/S = suit
	var/mob/living/carbon/human/U = S.affecting
	var/obj/item/clothing/gloves/space_ninja/G = S.n_gloves

	var/drain = 0//To drain from battery.
	var/maxcapacity = 0//Safety check for full battery.
	var/totaldrain = 0//Total energy drained.

	G.draining = 1

	U << "\blue Now charging battery..."

	switch(target_type)

		if("APC")
			var/obj/machinery/power/apc/A = target
			if(A.cell&&A.cell.charge)
				var/datum/effects/system/spark_spread/spark_system = new /datum/effects/system/spark_spread()
				spark_system.set_up(5, 0, A.loc)
				while(G.candrain&&A.cell.charge>0&&!maxcapacity)
					drain = rand(G.mindrain,G.maxdrain)
					if(A.cell.charge<drain)
						drain = A.cell.charge
					if(S.cell.charge+drain>S.cell.maxcharge)
						drain = S.cell.maxcharge-S.cell.charge
						maxcapacity = 1//Reached maximum battery capacity.
					if (do_after(U,10))
						spark_system.start()
						playsound(A.loc, "sparks", 50, 1)
						A.cell.charge-=drain
						S.cell.charge+=drain
						totaldrain+=drain
					else	break
				U << "\blue Gained <B>[totaldrain]</B> energy from the APC."
				if(!A.emagged)
					flick("apc-spark", src)
					A.emagged = 1
					A.locked = 0
					A.updateicon()
			else
				U << "\red This APC has run dry of power. You must find another source."

		if("SMES")
			var/obj/machinery/power/smes/A = target
			if(A.charge)
				var/datum/effects/system/spark_spread/spark_system = new /datum/effects/system/spark_spread()
				spark_system.set_up(5, 0, A.loc)
				while(G.candrain&&A.charge>0&&!maxcapacity)
					drain = rand(G.mindrain,G.maxdrain)
					if(A.charge<drain)
						drain = A.charge
					if(S.cell.charge+drain>S.cell.maxcharge)
						drain = S.cell.maxcharge-S.cell.charge
						maxcapacity = 1
					if (do_after(U,10))
						spark_system.start()
						playsound(A.loc, "sparks", 50, 1)
						A.charge-=drain
						S.cell.charge+=drain
						totaldrain+=drain
					else	break
				U << "\blue Gained <B>[totaldrain]</B> energy from the SMES cell."
			else
				U << "\red This SMES cell has run dry of power. You must find another source."

		if("CELL")
			var/obj/item/weapon/cell/A = target
			if(A.maxcharge>S.cell.maxcharge)
				U << "\blue Higher maximum capacity detected.\nUpgrading..."
				if (G.candrain&&do_after(U,50))
					U.drop_item()
					A.loc = S
					A.charge = min(A.charge+S.cell.charge, A.maxcharge)
					var/obj/item/weapon/cell/old_cell = S.cell
					old_cell.charge = 0
					U.put_in_hand(old_cell)
					old_cell.add_fingerprint(U)
					old_cell.corrupt()
					old_cell.updateicon()
					S.cell = A
					U << "\blue Upgrade complete. Maximum capacity: <b>[round(S.cell.charge/100)]</b>%"
				else
					U << "\red Procedure interrupted. Protocol terminated."
			else
				if(A.charge)
					if (G.candrain&&do_after(U,30))
						U << "\blue Gained <B>[A.charge]</B> energy from the cell."
						if(S.cell.charge+A.charge>S.cell.maxcharge)
							S.cell.charge=S.cell.maxcharge
						else
							S.cell.charge+=A.charge
						A.charge = 0
						G.draining = 0
						A.corrupt()
						A.updateicon()
					else
						U << "\red Procedure interrupted. Protocol terminated."
				else
					U << "\red This cell is empty and of no use."

		if("MACHINERY")//Can be applied to generically to all powered machinery. I'm leaving this alone for now.
			var/obj/machinery/A = target
			if(A.powered())//If powered.

				var/datum/effects/system/spark_spread/spark_system = new /datum/effects/system/spark_spread()
				spark_system.set_up(5, 0, A.loc)

				var/obj/machinery/power/apc/B = A.loc.loc:get_apc()//Object.turf.area find APC
				if(B)//If APC exists. Might not if the area is unpowered like CentCom.
					var/datum/powernet/PN = B.terminal.powernet
					while(G.candrain&&!maxcapacity&&!isnull(A))//And start a proc similar to drain from wire.
						drain = rand(G.mindrain,G.maxdrain)
						var/drained = 0
						if(PN&&do_after(U,10))
							drained = min(drain, PN.avail)
							PN.newload += drained
							if(drained < drain)//if no power on net, drain apcs
								for(var/obj/machinery/power/terminal/T in PN.nodes)
									if(istype(T.master, /obj/machinery/power/apc))
										var/obj/machinery/power/apc/AP = T.master
										if(AP.operating && AP.cell && AP.cell.charge>0)
											AP.cell.charge = max(0, AP.cell.charge - 5)
											drained += 5
						else	break
						S.cell.charge += drained
						if(S.cell.charge>S.cell.maxcharge)
							totaldrain += (drained-(S.cell.charge-S.cell.maxcharge))
							S.cell.charge = S.cell.maxcharge
							maxcapacity = 1
						else
							totaldrain += drained
						spark_system.start()
						if(drained==0)	break
					U << "\blue Gained <B>[totaldrain]</B> energy from the power network."
				else
					U << "\red Power network could not be found. Aborting."
			else
				U << "\red This recharger is not providing energy. You must find another source."

		if("WIRE")
			var/obj/cable/A = target
			var/datum/powernet/PN = A.get_powernet()
			while(G.candrain&&!maxcapacity&&!isnull(A))
				drain = (round((rand(G.mindrain,G.maxdrain))/2))
				var/drained = 0
				if(PN&&do_after(U,10))
					drained = min(drain, PN.avail)
					PN.newload += drained
					if(drained < drain)//if no power on net, drain apcs
						for(var/obj/machinery/power/terminal/T in PN.nodes)
							if(istype(T.master, /obj/machinery/power/apc))
								var/obj/machinery/power/apc/AP = T.master
								if(AP.operating && AP.cell && AP.cell.charge>0)
									AP.cell.charge = max(0, AP.cell.charge - 5)
									drained += 5
				else	break
				S.cell.charge += drained
				if(S.cell.charge>S.cell.maxcharge)
					totaldrain += (drained-(S.cell.charge-S.cell.maxcharge))
					S.cell.charge = S.cell.maxcharge
					maxcapacity = 1
				else
					totaldrain += drained
				S.spark_system.start()
				if(drained==0)	break
			U << "\blue Gained <B>[totaldrain]</B> energy from the power network."

		if("MECHA")
			var/obj/mecha/A = target
			A.occupant_message("\red Warning: Unauthorized access through sub-route 4, block H, detected.")
			if(A.get_charge())
				while(G.candrain&&A.cell.charge>0&&!maxcapacity)
					drain = rand(G.mindrain,G.maxdrain)
					if(A.cell.charge<drain)
						drain = A.cell.charge
					if(S.cell.charge+drain>S.cell.maxcharge)
						drain = S.cell.maxcharge-S.cell.charge
						maxcapacity = 1
					if (do_after(U,10))
						A.spark_system.start()
						playsound(A.loc, "sparks", 50, 1)
						A.cell.use(drain)
						S.cell.charge+=drain
						totaldrain+=drain
					else	break
				U << "\blue Gained <B>[totaldrain]</B> energy from [src]."
			else
				U << "\red The exosuit's battery has run dry of power. You must find another source."

		if("CYBORG")
			var/mob/living/silicon/robot/A = target
			A << "\red Warning: Unauthorized access through sub-route 12, block C, detected."
			G.draining = 1
			if(A.cell&&A.cell.charge)
				while(G.candrain&&A.cell.charge>0&&!maxcapacity)
					drain = rand(G.mindrain,G.maxdrain)
					if(A.cell.charge<drain)
						drain = A.cell.charge
					if(S.cell.charge+drain>S.cell.maxcharge)
						drain = S.cell.maxcharge-S.cell.charge
						maxcapacity = 1
					if (do_after(U,10))
						A.spark_system.start()
						playsound(A.loc, "sparks", 50, 1)
						A.cell.charge-=drain
						S.cell.charge+=drain
						totaldrain+=drain
					else	break
				U << "\blue Gained <B>[totaldrain]</B> energy from [A]."
			else
				U << "\red Their battery has run dry of power. You must find another source."
		else//Else nothing :<

	G.draining = 0

	return

//DRAINING PROCS END===================================

/obj/item/clothing/gloves/space_ninja/examine()
	set src in view()
	..()
	if(!canremove)
		var/mob/living/carbon/human/U = loc
		if(candrain)
			U << "The energy drain mechanism is: <B>active</B>."
		else
			U << "The energy drain mechanism is: <B>inactive</B>."

//MASK===================================

/obj/item/clothing/mask/gas/voice/space_ninja/New()
	verbs += /obj/item/clothing/mask/gas/voice/space_ninja/proc/togglev
	verbs += /obj/item/clothing/mask/gas/voice/space_ninja/proc/switchm

//This proc is linked to human life.dm. It determines what hud icons to display based on mind special role for most mobs.
/obj/item/clothing/mask/gas/voice/space_ninja/proc/assess_targets(list/target_list, mob/living/carbon/U)
	var/icon/tempHud = 'hud.dmi'
	for(var/mob/living/target in target_list)
		if(iscarbon(target))
			switch(target.mind.special_role)
				if("traitor")
					U.client.images += image(tempHud,target,"hudtraitor")
				if("Revolutionary","Head Revolutionary")
					U.client.images += image(tempHud,target,"hudrevolutionary")
				if("Cultist")
					U.client.images += image(tempHud,target,"hudcultist")
				if("Changeling")
					U.client.images += image(tempHud,target,"hudchangeling")
				if("Wizard","Fake Wizard")
					U.client.images += image(tempHud,target,"hudwizard")
				if("Hunter","Sentinel","Drone","Queen")
					U.client.images += image(tempHud,target,"hudalien")
				if("Syndicate")
					U.client.images += image(tempHud,target,"hudoperative")
				if("Death Commando")
					U.client.images += image(tempHud,target,"huddeathsquad")
				if("Space Ninja")
					U.client.images += image(tempHud,target,"hudninja")
				else//If we don't know what role they have but they have one.
					U.client.images += image(tempHud,target,"hudunknown1")
		else//If the silicon mob has no law datum, no inherent laws, or a law zero, add them to the hud.
			var/mob/living/silicon/silicon_target = target
			if(!silicon_target.laws||(silicon_target.laws&&(silicon_target.laws.zeroth||!silicon_target.laws.inherent.len)))
				if(isrobot(silicon_target))//Different icons for robutts and AI.
					U.client.images += image(tempHud,silicon_target,"hudmalborg")
				else
					U.client.images += image(tempHud,silicon_target,"hudmalai")
	return 1

/obj/item/clothing/mask/gas/voice/space_ninja/proc/togglev()
	set name = "Toggle Voice"
	set desc = "Toggles the voice synthesizer on or off."
	set category = "Ninja Equip"

	var/mob/U = loc//Can't toggle voice when you're not wearing the mask.
	var/vchange = (alert("Would you like to synthesize a new name or turn off the voice synthesizer?",,"New Name","Turn Off"))
	if(vchange=="New Name")
		var/chance = rand(1,100)
		switch(chance)
			if(1 to 50)//High chance of a regular name.
				var/g = pick(0,1)
				var/first = null
				var/last = pick(last_names)
				if(g==0)
					first = pick(first_names_female)
				else
					first = pick(first_names_male)
				voice = "[first] [last]"
			if(51 to 80)//Smaller chance of a clown name.
				var/first = pick(clown_names)
				voice = "[first]"
			if(81 to 90)//Small chance of a wizard name.
				var/first = pick(wizard_first)
				var/last = pick(wizard_second)
				voice = "[first] [last]"
			if(91 to 100)//Small chance of an existing crew name.
				var/list/names = new()
				for(var/mob/living/carbon/human/M in world)
					if(M==U||!M.client||!M.real_name)	continue
					names.Add(M)
				if(!names.len)
					voice = "Cuban Pete"//Smallest chance to be the man.
				else
					var/mob/picked = pick(names)
					voice = picked.real_name
		U << "You are now mimicking <B>[voice]</B>."
	else
		if(voice!="Unknown")
			U << "You deactivate the voice synthesizer."
			voice = "Unknown"
		else
			U << "The voice synthesizer is already deactivated."
	return

/obj/item/clothing/mask/gas/voice/space_ninja/proc/switchm()
	set name = "Switch Mode"
	set desc = "Switches between Night Vision, Meson, or Thermal vision modes."
	set category = "Ninja Equip"
	//Have to reset these manually since life.dm is retarded like that. Go figure.
	//This will only work for humans since only they have the appropriate code for the mask.
	var/mob/U = loc
	switch(mode)
		if(0)
			mode=1
			U << "Switching mode to <B>Night Vision</B>."
		if(1)
			mode=2
			U.see_in_dark = 2
			U << "Switching mode to <B>Thermal Scanner</B>."
		if(2)
			mode=3
			U.see_invisible = 0
			U.sight &= ~SEE_MOBS
			U << "Switching mode to <B>Meson Scanner</B>."
		if(3)
			mode=0
			U.sight &= ~SEE_TURFS
			U << "Switching mode to <B>Scouter</B>."


/obj/item/clothing/mask/gas/voice/space_ninja/examine()
	set src in view()
	..()

	var/mode
	var/voice
	switch(mode)
		if(0)
			mode = "Scouter"
		if(1)
			mode = "Night Vision"
		if(2)
			mode = "Thermal Scanner"
		if(3)
			mode = "Meson Scanner"
	if(vchange==0)
		voice = "inactive"
	else
		voice = "active"
	usr << "<B>[mode]</B> is active."//Leaving usr here since it may be on the floor or on a person.
	usr << "Voice mimicking algorithm is set to <B>[voice]</B>."

//ENERGY NET===================================

/*
HerpA:
I'm not really sure what you want this to do.
For now it will teleport people to the prison after 30 seconds. (Check the process() proc to change where teleport goes)
It is possible to destroy the net by the occupant or someone else.
The sprite for the net is kind of ugly but I couldn't come up with a better one.
*/

/obj/effects/energy_net
	name = "energy net"
	desc = "It's a net made of green energy."
	icon = 'effects.dmi'
	icon_state = "energynet"

	density = 1//Can't pass through.
	opacity = 0//Can see through.
	mouse_opacity = 1//So you can hit it with stuff.
	anchored = 1//Can't drag/grab.
	var/health = 25//How much health it has.
	var/mob/living/affecting = null//Who it is currently affecting, if anyone.
	var/mob/living/master = null//Who shot web. Will let this person know if the net was successful or failed.

/obj/effects/energy_net/proc/healthcheck()
	if(health <=0)
		density = 0
		if(affecting)
			var/mob/living/carbon/M = affecting
			M.anchored = 0
			for(var/mob/O in viewers(src, 3))
				O.show_message(text("[] was recovered from the energy net!", M.name), 1, text("You hear a grunt."), 2)
			if(!isnull(master))//As long as they still exist.
				master << "\red <b>ERROR</b>: \black unable to initiate transport protocol. Procedure terminated."
		del(src)
	return

/obj/effects/energy_net/bullet_act(flag)
	switch(flag)
		if (PROJECTILE_BULLET)
			health -= 35
		if (PROJECTILE_PULSE)
			health -= 50
		if (PROJECTILE_LASER)
			health -= 10
	healthcheck()
	return

/obj/effects/energy_net/ex_act(severity)
	switch(severity)
		if(1.0)
			health-=50
		if(2.0)
			health-=50
		if(3.0)
			if (prob(50))
				health-=50
			else
				health-=25
	healthcheck()
	return

/obj/effects/energy_net/blob_act()
	health-=50
	healthcheck()
	return

/obj/effects/energy_net/meteorhit()
	health-=50
	healthcheck()
	return

/obj/effects/energy_net/hitby(AM as mob|obj)
	..()
	for(var/mob/O in viewers(src, null))
		O.show_message(text("\red <B>[src] was hit by [AM].</B>"), 1)
	var/tforce = 0
	if(ismob(AM))
		tforce = 10
	else
		tforce = AM:throwforce
	playsound(src.loc, 'slash.ogg', 80, 1)
	health = max(0, health - tforce)
	healthcheck()
	..()
	return

/obj/effects/energy_net/attack_hand()
	if ((usr.mutations & HULK))
		usr << text("\blue You easily destroy the energy net.")
		for(var/mob/O in oviewers(src))
			O.show_message(text("\red [] rips the energy net apart!", usr), 1)
		health-=50
	healthcheck()
	return

/obj/effects/energy_net/attack_paw()
	return attack_hand()

/obj/effects/energy_net/attack_alien()
	if (islarva(usr))
		return
	usr << text("\green You claw at the net.")
	for(var/mob/O in oviewers(src))
		O.show_message(text("\red [] claws at the energy net!", usr), 1)
	playsound(src.loc, 'slash.ogg', 80, 1)
	health -= rand(10, 20)
	if(health <= 0)
		usr << text("\green You slice the energy net to pieces.")
		for(var/mob/O in oviewers(src))
			O.show_message(text("\red [] slices the energy net apart!", usr), 1)
	healthcheck()
	return

/obj/effects/energy_net/attackby(obj/item/weapon/W as obj, mob/user as mob)
	var/aforce = W.force
	health = max(0, health - aforce)
	healthcheck()
	..()
	return

/obj/effects/energy_net/proc/process(var/mob/living/carbon/M as mob)
	var/check = 30//30 seconds before teleportation. Could be extended I guess.
	//The person can still try and attack the net when inside.
	while(!isnull(M)&&!isnull(src)&&check>0)//While M and net exist, and 30 seconds have not passed.
		check--
		sleep(10)

	if(isnull(M)||M.loc!=loc)//If mob is gone or not at the location.
		if(!isnull(master))//As long as they still exist.
			master << "\red <b>ERROR</b>: \black unable to locate [affecting]. Procedure terminated."
		del(src)//Get rid of the net.
		return

	if(!isnull(src))//As long as both net and person exist.
		//No need to check for countdown here since while() broke, it's implicit that it finished.
		spawn(0)
			playsound(M.loc, 'sparks4.ogg', 50, 1)
			anim(M.loc,M,'mob.dmi',,"phaseout")

		density = 0//Make the net pass-through.
		invisibility = 101//Make the net invisible so all the animations can play out.
		health = INFINITY//Make the net invincible so that an explosion/something else won't kill it while, spawn() is running.
		M.loc = pick(prisonwarp)//Throw mob in prison.

		spawn(0)
			var/datum/effects/system/spark_spread/spark_system = new /datum/effects/system/spark_spread()
			spark_system.set_up(5, 0, M.loc)
			spark_system.start()
			playsound(M.loc, 'Deconstruct.ogg', 50, 1)
			playsound(M.loc, 'sparks2.ogg', 50, 1)
			anim(M.loc,M,'mob.dmi',,"phasein")
			del(src)//Wait for everything to finish, delete the net. Else it will stop everything once net is deleted, including the spawn(0).

		for(var/mob/O in viewers(src, 3))
			O.show_message(text("[] vanished!", M), 1, text("You hear sparks flying!"), 2)

		if(!isnull(master))//As long as they still exist.
			master << "\blue <b>SUCCESS</b>: \black transport procedure of [affecting] complete."

		M.anchored = 0//Important.

	else//And they are free.
		M << "\blue You are free of the net!"
	return