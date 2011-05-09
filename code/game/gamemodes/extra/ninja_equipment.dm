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
	aicard = new/obj/item/device/aicard
	cell.charge = 9000

/obj/item/clothing/suit/space/space_ninja/Del()
	if(aicard.contents.len)//If there are AIs present when the ninja kicks the bucket.
		killai(aicard)
	..()
	return

/obj/item/clothing/suit/space/space_ninja/proc/killai(var/obj/item/device/aicard/A as obj)
	for(var/mob/living/silicon/ai/AI in A)//In case intelicards are changes to house more than one AI.
		AI << "\red Self-destruct protocol dete-- *bzzzzz*"
		AI.death()//Kill
		AI.ghostize()//Turn into ghost
		del(AI)
	return

/obj/item/clothing/suit/space/space_ninja/attackby(var/obj/item/device/aicard/aicard_temp as obj, U as mob)//When the suit is attacked by an AI card.
	if(istype(aicard_temp, /obj/item/device/aicard))//If it's actually an AI card.
		if(control)
			if(initialize&&U==affecting)//If the suit is initialized and the actor is the user.

				var/mob/living/silicon/ai/A_T = locate() in aicard_temp//Determine if there is an AI on target card. Saves time when checking later.
				var/mob/living/silicon/ai/A = locate() in aicard//Deterine if there is an AI on the installed card.

				if(A)//If the installed AI card is not empty.
					if(A_T)//If there is an AI on the target card.
						U << "\red <b>ERROR</b>: \black [A_T.name] already installed. Remove [A_T.name] to install a new one."
					else
						if(aicard.flush)//If the installed card is purging.
							U << "\red <b>ERROR</b>: \black [A.name] is purging. Please wait until the process is finished."
						else
							A.loc = aicard_temp//Throw them into the target card. Since they are already on a card, transfer is easy.
							aicard_temp.name = "inteliCard - [A.name]"
							aicard_temp.icon_state = "aicard-full"
							A << "You have been uploaded to a mobile storage device."
							U << "\blue <b>SUCCESS</b>: \black [A.name] ([rand(1000,9999)].exe) removed from host and stored within local memory."

				else//If the installed AI card is empty.
					if(A_T&&A_T.stat!=2)//If there is an AI on the target card and it's not DED.
						if(aicard_temp.flush)//If the target card is purging.
							U << "\red <b>ERROR</b>: \black [A_T.name] is wiping. You cannot install this AI until it is repaired."
						else
							A_T.loc = aicard//Throw them into the installed card.
							aicard_temp.icon_state = "aicard"
							aicard_temp.name = "inteliCard"
							aicard_temp.overlays = null
							A_T << "You have been uploaded to a mobile storage device."
							U << "\blue <b>SUCCESS</b>: \black [A_T.name] ([rand(1000,9999)].exe) removed from local memory and installed to host."
					else if(A_T.stat==2)//If the target AI is dead. Else just got to return since nothing would happen if both are empty.
						U << "\red <b>ERROR</b>: \black [A_T.name] is inactive. Unable to install."
		else
			U << "\red <b>ERROR</b>: \black Remote access channel disabled."
	return

/obj/item/clothing/suit/space/space_ninja/proc/ntick(var/mob/living/carbon/human/U as mob)
	set hidden = 1
	set background = 1

	spawn while(initialize&&cell.charge>=0)//Suit on and has power.
		if(!initialize)	return//When turned off the proc stops.
		if(coold)	coold--//Checks for ability cooldown.
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
			if(active)
				A += 25
		else
			if(prob(25))
				U.bruteloss += 1
			A = 200
		cell.charge-=A
		if(cell.charge<0)
			if(kamikaze)
				U.say("I DIE TO LIVE AGAIN!")
				U.death()
				return
			cell.charge=0
			active=0
		sleep(10)//Checks every second.

/obj/item/clothing/suit/space/space_ninja/proc/init()
	set name = "Initialize Suit"
	set desc = "Initializes the suit for field operation."
	set category = "Object"

	var/mob/living/carbon/human/U = usr
	if(U.mind&&U.mind.special_role=="Space Ninja"&&U:wear_suit==src&&!initialize)
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
		U.head:canremove=0
		U.shoes:canremove=0
		U.gloves:canremove=0
		canremove=0
		sleep(40)
		U << "\blue Extending neural-net interface...\nNow monitoring brain wave pattern..."
		sleep(40)
		if(U.stat==2||U.health<=0)
			U << "\red <B>FATAL ERROR</B>: 344--93#&&21 BRAIN WAV3 PATT$RN <B>RED</B>\nA-A-AB0RTING..."
			U.head:canremove=1
			U.shoes:canremove=1
			U.gloves:canremove=1
			canremove=1
			verbs += /obj/item/clothing/suit/space/space_ninja/proc/init
			return
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
		U.verbs += /mob/proc/ninjashift
		U.verbs += /mob/proc/ninjajaunt
		U.verbs += /mob/proc/ninjasmoke
		U.verbs += /mob/proc/ninjaboost
		U.verbs += /mob/proc/ninjapulse
		U.verbs += /mob/proc/ninjablade
		U.verbs += /mob/proc/ninjastar
		U.verbs += /mob/proc/ninjanet
		U.mind.special_verbs += /mob/proc/ninjashift
		U.mind.special_verbs += /mob/proc/ninjajaunt
		U.mind.special_verbs += /mob/proc/ninjasmoke
		U.mind.special_verbs += /mob/proc/ninjaboost
		U.mind.special_verbs += /mob/proc/ninjapulse
		U.mind.special_verbs += /mob/proc/ninjablade
		U.mind.special_verbs += /mob/proc/ninjastar
		U.mind.special_verbs += /mob/proc/ninjanet
		verbs += /obj/item/clothing/suit/space/space_ninja/proc/deinit
		verbs += /obj/item/clothing/suit/space/space_ninja/proc/spideros
		U.gloves.verbs += /obj/item/clothing/gloves/space_ninja/proc/drain_wire
		U.gloves.verbs += /obj/item/clothing/gloves/space_ninja/proc/toggled
		initialize=1
		affecting=U
		slowdown=0
		U.shoes:slowdown--
		ntick(U)
	else
		if(usr.mind&&usr.mind.special_role=="Space Ninja")
			usr << "\red You do not understand how this suit functions."
		else if(usr:wear_suit!=src)
			usr << "\red You must be wearing the suit to use this function."
		else if(initialize)
			usr << "\red The suit is already functioning."
		else
			usr << "\red You cannot use this function at this time."
	return

/obj/item/clothing/suit/space/space_ninja/proc/deinit()
	set name = "De-Initialize Suit"
	set desc = "Begins procedure to remove the suit."
	set category = "Object"

	if(!initialize)
		usr << "\red The suit is not initialized."
		return
	if(alert("Are you certain you wish to remove the suit? This will take time and remove all abilities.",,"Yes","No")=="No")
		return
	if(!verbs.Find(/obj/item/clothing/suit/space/space_ninja/proc/spideros))//If the guy engaged kamikaze after clicking on deinit.
		return

	var/mob/living/carbon/human/U = affecting
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/deinit
	U << "\blue Now de-initializing..."
	if(kamikaze)
		U << "\blue Disengaging mode...\n\black<b>CODE NAME</b>: \red <b>KAMIKAZE</b>"
		U.verbs -= /mob/proc/ninjaslayer
		U.verbs -= /mob/proc/ninjawalk
		U.verbs -= /mob/proc/ninjamirage
		U.mind.special_verbs -= /mob/proc/ninjaslayer
		U.mind.special_verbs -= /mob/proc/ninjawalk
		U.mind.special_verbs -= /mob/proc/ninjamirage
		kamikaze = 0
		unlock = 0
		U.incorporeal_move = 0
		U.density = 1
	spideros = 0
	sleep(40)
	U.verbs -= /mob/proc/ninjashift
	U.verbs -= /mob/proc/ninjajaunt
	U.verbs -= /mob/proc/ninjasmoke
	U.verbs -= /mob/proc/ninjaboost
	U.verbs -= /mob/proc/ninjapulse
	U.verbs -= /mob/proc/ninjablade
	U.verbs -= /mob/proc/ninjastar
	U.verbs -= /mob/proc/ninjanet
	U.mind.special_verbs -= /mob/proc/ninjashift
	U.mind.special_verbs -= /mob/proc/ninjajaunt
	U.mind.special_verbs -= /mob/proc/ninjasmoke
	U.mind.special_verbs -= /mob/proc/ninjaboost
	U.mind.special_verbs -= /mob/proc/ninjapulse
	U.mind.special_verbs -= /mob/proc/ninjablade
	U.mind.special_verbs -= /mob/proc/ninjastar
	U.mind.special_verbs -= /mob/proc/ninjanet
	U << "\blue Logging off, [U:real_name]. Shutting down <B>SpiderOS</B>."
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/spideros
	sleep(40)
	U << "\blue Primary system status: <B>OFFLINE</B>.\nBackup system status: <B>OFFLINE</B>."
	sleep(40)
	U << "\blue VOID-shift device status: <B>OFFLINE</B>.\nCLOAK-tech device status: <B>OFFLINE</B>."
	if(active)//Shutdowns stealth.
		active=0
	sleep(40)
	if(U.stat||U.health<=0)
		U << "\red <B>FATAL ERROR</B>: 412--GG##&77 BRAIN WAV3 PATT$RN <B>RED</B>\nI-I-INITIATING S-SELf DeStrCuCCCT%$#@@!!$^#!..."
		spawn(10)
			U << "\red #3#"
		spawn(20)
			U << "\red #2#"
		spawn(30)
			U << "\red #1#: <B>G00DBYE</B>"
			if(aicard.contents.len)
				killai(aicard)
			U.gib()
		return
	U << "\blue Disconnecting neural-net interface...\green<B>Success</B>\blue."
	sleep(40)
	U << "\blue Disengaging neural-net interface...\green<B>Success</B>\blue."
	sleep(40)
	if(istype(U.head, /obj/item/clothing/head/helmet/space/space_ninja))
		U.head.canremove=1
	if(istype(U.shoes, /obj/item/clothing/shoes/space_ninja))
		U.shoes:canremove=1
		U.shoes:slowdown++
	if(istype(U.gloves, /obj/item/clothing/gloves/space_ninja))
		U.gloves.icon_state = "s-ninja"
		U.gloves.item_state = "s-ninja"
		U.gloves:canremove=1
		U.gloves:candrain=0
		U.gloves:draining=0
		U.gloves.verbs -= /obj/item/clothing/gloves/space_ninja/proc/drain_wire
		U.gloves.verbs -= /obj/item/clothing/gloves/space_ninja/proc/toggled
	icon_state = "s-ninja"
	U.update_clothing()
	if(istype(U.get_active_hand(), /obj/item/weapon/blade))//Sword check.
		U.drop_item()
	if(istype(U.get_inactive_hand(), /obj/item/weapon/blade))
		U.swap_hand()
		U.drop_item()
	canremove=1
	U << "\blue Unsecuring external locking mechanism...\nNeural-net abolished.\nOperation status: <B>FINISHED</B>."
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/init
	initialize=0
	affecting=null
	slowdown=1
	return

/obj/item/clothing/suit/space/space_ninja/proc/spideros()
	set name = "Display SpiderOS"
	set desc = "Utilize built-in computer system."
	set category = "Object"

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
	dat += "<img src=sos_11.png> Smoke Bombs: [sbombs]<br>"
	dat += "<br>"

	switch(spideros)
		if(0)
			dat += "<h4><img src=sos_1.png> Available Functions:</h4>"
			dat += "<ul>"
			dat += "<li><a href='byond://?src=\ref[src];choice=Stealth'><img src=sos_4.png> Toggle Stealth: [active == 1 ? "Disable" : "Enable"]</a></li>"
			if(aicard.contents.len)
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
			if(unlock==7)
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
			dat += "<li>*<b>The Space Wizard Federation</b> is a problem, mainly because they are an extremely dangerous group of unpredictable individuals--not to mention the wizards hate technology and are in direct opposition of the Spider Clan. Best avoided or left well-enough alone.</li>"
			dat += "<li>*<b>Changeling Hivemind</b>: extremely dangerous and to be killed on sight.</li>"
			dat += "<li>*<b>Xeno Hivemind</b>: their skulls make interesting kitchen decorations and are challenging to best, especially in larger nests.</li>"
			dat += "</ul>"
			dat += "<h5>The reason they (you) are here</h5>:"
			dat += "Space ninjas are renowned throughout the known controlled space as fearless spies, infiltrators, and assassins. They are sent on missions of varying nature by Nanotrasen, the Syndicate, and other shady organizations and people. To hire a space ninja means serious business."
			dat += "<h5>Their playstyle:</h5>"
			dat += "A mix of traitor, changeling, and wizard. Ninjas rely on energy, or electricity to be precise, to keep their suits running (when out of energy, a suit hibernates). Suits gain energy from objects or creatures that contain electrical charge. APCs, cell batteries, rechargers, SMES batteries, cyborgs, mechs, and exposed wires are currently supported. Through energy ninjas gain access to special powers--while all powers are tied to the ninja suit, the most useful of them are verb activated--to help them in their mission.<br>It is a constant struggle for a ninja to remain hidden long enough to recharge the suit and accomplish their objective; despite their arsenal of abilities, ninjas can die like any other. Unlike wizards, ninjas do not possess good crowd control and are typically forced to play more subdued in order to achieve their goals. Some of their abilities are specifically designed to confuse and disorient others.<br>With that said, it should be perfectly possible to completely flip the fuck out and rampage as a ninja."
			dat += "<h5>Their powers:</h5>"
			dat += "There are two primary types: powers that are activated through the suit and powers that are activated through the verb panel. Passive powers are always on. Active powers must be turned on and remain active only when there is energy to do so. All verb powers are active and their cost is listed next to them."
			dat += "<b>Powers of the suit</b>: cannot be tracked by AI (passive), faster speed (passive), stealth (active), vision switch (passive if toggled), voice masking (passive), SpiderOS (passive if toggled), energy drain (passive if toggled)."
			dat += "<ul>"
			dat += "<li><i>Voice masking</i> generates a random name the ninja can use over the radio and in-person. Although, the former use is recommended.</li>"
			dat += "<li><i>Toggling vision</i> cycles to one of the following: thermal, meson, or darkness vision.</li>"
			dat += "<li><i>Stealth</i>, when activated, drains more battery charge and works similarly to a syndicate cloak.</li>"
			dat += "<li><i>SpiderOS</i> is a specialized, PDA-like screen that allows for a small variety of functions, such as injecting healing chemicals directly from the suit. You are using it now, if that was not already obvious. You may also download AI modules directly to the OS.</li>"
			dat += "</ul>"
			dat += "<b>Verbpowers</b>:"
			dat += "<ul>"
			dat += "<li>*<b>Phase Shift</b> (<i>2000E</i>) and <b>Phase Jaunt</b> (<i>1000E</i>) are unique powers in that they can both be used for defense and offense. Jaunt launches the ninja forward facing up to 10 squares, somewhat randomly selecting the final destination. Shift can only be used on turf in view but is precise (cannot be used on walls). Any living mob in the area teleported to is instantly gibbed.</li>"
			dat += "<li>*<b>Energy Blade</b> (<i>500E</i>) is a highly effective weapon. It is summoned directly to the ninja's hand and can also function as an EMAG for certain objects (doors/lockers/etc). You may also use it to cut through walls and disabled doors. Experiment! The blade will crit humans in two hits. This item cannot be placed in containers and when dropped or thrown disappears. Having an energy sword drains more power from the battery each tick.</li>"
			dat += "<li>*<b>EM Pulse</b> (<i>2500E</i>) is a highly useful ability that will create an electromagnetic shockwave around the ninja, disabling technology whenever possible. If used properly it can render a security force effectively useless. Of course, getting beat up with a toolbox is not accounted for.</li>"
			dat += "<li>*<b>Energy Star</b> (<i>300E</i>) is a ninja star made of green energy AND coated in poison. It works by picking a random living target within range and can be spammed to great effect in incapacitating foes. Just remember that the poison used is also used by the Xeno Hivemind (and will have no effect on them).</li>"
			dat += "<li>*<b>Energy Net</b> (<i>2000E</i>) traps a right-clicked target in an energy field that will trasport them to a holding facility after 30 seconds. They, or someone else, may break the net in the mean time, cancelling the procedure. Abduction never looked this leet.</li>"
			dat += "<li>*<b>Adrenaline Boost</b> (<i>1 E. Boost/3</i>) recovers the user from stun, weakness, and paralysis. Also injects 20 units of radium into the bloodstream.</li>"
			dat += "<li>*<b>Smoke Bomb</b> (<i>1 Sm.Bomb/10</i>) is a weak but potentially useful ability. It creates harmful smoke and can be used in tandem with other powers to confuse enemies.</li>"
			dat += "<li>*<b>???</b>: unleash the <b>True Ultimate Power!</b></li>"
			dat += "</ul>"
			dat += "That is all you will need to know. The rest will come with practice and talent. Good luck!"
			dat += "<h4>Master /N</h4>"
		if(5)
			var/laws
			dat += "<h4><img src=sos_13.png> AI Control:</h4>"
			for(var/mob/living/silicon/ai/A in aicard)
				dat += "Stored AI: <b>[A.name]</b><br>"
				dat += "System integrity: [(A.health+100)/2]%<br>"

				for (var/index = 1, index <= A.laws_object.ion.len, index++)
					var/law = A.laws_object.ion[index]
					if (length(law) > 0)
						var/num = ionnum()
						laws += "<li>[num]. [law]</li>"

				//I personally think this makes things a little more fun. Ninjas can override all but law 0.
				//if (A.laws_object.zeroth)
				//	laws += "<li>0: [A.laws_object.zeroth]</li>"

				var/number = 1
				for (var/index = 1, index <= A.laws_object.inherent.len, index++)
					var/law = A.laws_object.inherent[index]
					if (length(law) > 0)
						laws += "<li>[number]: [law]</li>"
						number++

				for (var/index = 1, index <= A.laws_object.supplied.len, index++)
					var/law = A.laws_object.supplied[index]
					if (length(law) > 0)
						laws += "<li>[number]: [law]</li>"
						number++

				dat += "<h4>Laws:</h4><ul>[laws]<li><a href='byond://?src=\ref[src];choice=Override Laws;target=\ref[A]'><i>*Override Laws*</i></a></li></ul>"

				if (A.stat == 2)//If AI dies while inside the card.
					if(A.client)//If they are still in their body.
						A.ghostize()//Throw them into a ghost.
						del(A)//Delete A.
						aicard.overlays = null
					else
						del(A)
					U << "Artificial Intelligence has self-terminated. Rebooting..."
					spideros()//Refresh.
				else
					if (!aicard.flush)
						dat += {"<A href='byond://?src=\ref[src];choice=Purge AI'>Purge AI</A><br>"}
					else
						dat += "<b>Purge in progress...</b><br>"
					dat += {" <A href='byond://?src=\ref[src];choice=Wireless AI'>[A.control_disabled ? "Enable" : "Disable"] Wireless Activity</A>"}
	dat += "</body></html>"

	U << browse(dat,"window=spideros;size=400x444;border=1;can_resize=0;can_close=0;can_minimize=0")
	//Setting the can>resize etc to 0 remove them from the drag bar but still allows the window to be draggable.

/obj/item/clothing/suit/space/space_ninja/Topic(href, href_list)
	..()
	var/mob/living/carbon/human/U = affecting
	if(control)//If the player is in control.
		if(!affecting||U.stat||!initialize)//Check to make sure the guy is wearing the suit after clicking and it's on.
			U << "\red Your suit must be worn and active to use this function."
			U << browse(null, "window=spideros")//Closes the window.
			return

		switch(unlock)//To unlock Kamikaze mode. Irrelevant elsewhere.
			if(0)
				if(href_list["choice"]=="Stealth"&&spideros==0)	unlock++
			if(1)
				if(href_list["choice"]=="2"&&spideros==0)	unlock++
				else if(href_list["choice"]=="Return")
				else	unlock=0
			if(2)
				if(href_list["choice"]=="3"&&spideros==0)	unlock++
				else if(href_list["choice"]=="Return")
				else	unlock=0
			if(3)
				if(href_list["choice"]=="Stealth"&&spideros==0)	unlock++
				else if(href_list["choice"]=="Return")
				else	unlock=0
			if(4)
				if(href_list["choice"]=="1"&&spideros==0)	unlock++
				else if(href_list["choice"]=="Return")
				else	unlock=0
			if(5)
				if(href_list["choice"]=="1"&&spideros==0)	unlock++
				else if(href_list["choice"]=="Return")
				else	unlock=0
			if(6)
				if(href_list["choice"]=="4"&&spideros==0)	unlock++
				else if(href_list["choice"]=="Return")
				else	unlock=0
			if(7)//once unlocked, stays unlocked until deactivated.
			else
				unlock = 0

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
				if(active)
					spawn(0)
						anim(U.loc,'mob.dmi',U,"uncloak")
					active=0
					U << "\blue You are now visible."
					for(var/mob/O in oviewers(U, null))
						O << "[U.name] appears from thin air!"
				else
					spawn(0)
						anim(U.loc,'mob.dmi',U,"cloak")
					active=1
					U << "\blue You are now invisible to normal detection."
					for(var/mob/O in oviewers(U, null))
						O << "[U.name] vanishes into thin air!"
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
				if(!t||U.stat||U.wear_suit!=src||!initialize)//Wow, another one of these. Man...
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
					if( !(U.stat||U.wear_suit!=src||!initialize) )
						U << "\blue Engaging mode...\n\black<b>CODE NAME</b>: \red <b>KAMIKAZE</b>"
						verbs -= /obj/item/clothing/suit/space/space_ninja/proc/spideros
						sleep(40)
						U << "\blue Re-routing power nodes... \nUnlocking limiter..."
						sleep(40)
						U << "\blue Power nodes re-routed. \nLimiter unlocked."
						sleep(10)
						U << "\red Do or Die, <b>LET'S ROCK!!</b>"
						if(verbs.Find(/obj/item/clothing/suit/space/space_ninja/proc/deinit))//To hopefully prevent engaging kamikaze and de-initializing at the same time.
							kamikaze = 1
							active = 0
							icon_state = "s-ninjak"
							if(istype(U.gloves, /obj/item/clothing/gloves/space_ninja))
								U.gloves.icon_state = "s-ninjak"
								U.gloves.item_state = "s-ninjak"
								U.gloves:candrain = 0
								U.gloves:draining = 0
								U.gloves.verbs -= /obj/item/clothing/gloves/space_ninja/proc/drain_wire
								U.gloves.verbs -= /obj/item/clothing/gloves/space_ninja/proc/toggled
							U.update_clothing()
							U.verbs -= /mob/proc/ninjashift
							U.verbs -= /mob/proc/ninjajaunt
							U.verbs -= /mob/proc/ninjapulse
							U.verbs -= /mob/proc/ninjastar
							U.verbs -= /mob/proc/ninjanet
							U.mind.special_verbs -= /mob/proc/ninjashift
							U.mind.special_verbs -= /mob/proc/ninjajaunt
							U.mind.special_verbs -= /mob/proc/ninjapulse
							U.mind.special_verbs -= /mob/proc/ninjastar
							U.mind.special_verbs -= /mob/proc/ninjanet
							U.verbs += /mob/proc/ninjaslayer
							U.verbs += /mob/proc/ninjawalk
							U.verbs += /mob/proc/ninjamirage
							U.mind.special_verbs += /mob/proc/ninjaslayer
							U.mind.special_verbs += /mob/proc/ninjawalk
							U.mind.special_verbs += /mob/proc/ninjamirage
							U.ninjablade()
							message_admins("\blue [U.key] used KAMIKAZE mode.", 1)
						else
							U << "Nevermind, you cheater."
					U << browse(null, "window=spideros")
					return
				else
					U << "\red ERROR: WRONG PASSWORD!"
					unlock = 0
					spideros = 0
			if("Dylovene")//These names really don't matter for specific functions but it's easier to use descriptive names.
				if(!reagents.get_reagent_amount("anti_toxin"))
					U << "\red Error: the suit cannot perform this function. Out of dylovene."
				else
					reagents.reaction(U, 2)
					reagents.trans_id_to(U, "anti_toxin", transfera)
					U << "You feel a tiny prick and a sudden rush of liquid in to your veins."
			if("Dexalin Plus")
				if(!reagents.get_reagent_amount("dexalinp"))
					U << "\red Error: the suit cannot perform this function. Out of dexalinp."
				else
					reagents.reaction(U, 2)
					reagents.trans_id_to(U, "dexalinp", transfera)
					U << "You feel a tiny prick and a sudden rush of liquid in to your veins."
			if("Tricordazine")
				if(!reagents.get_reagent_amount("tricordrazine"))
					U << "\red Error: the suit cannot perform this function. Out of tricordrazine."
				else
					reagents.reaction(U, 2)
					reagents.trans_id_to(U, "tricordrazine", transfera)
					U << "You feel a tiny prick and a sudden rush of liquid in to your veins."
			if("Spacelin")
				if(!reagents.get_reagent_amount("spaceacillin"))
					U << "\red Error: the suit cannot perform this function. Out of spaceacillin."
				else
					reagents.reaction(U, 2)
					reagents.trans_id_to(U, "spaceacillin", transfera)
					U << "You feel a tiny prick and a sudden rush of liquid in to your veins."
			if("Nutriment")
				if(!reagents.get_reagent_amount("nutriment"))
					U << "\red Error: the suit cannot perform this function. Out of nutriment."
				else
					reagents.reaction(U, 2)
					reagents.trans_id_to(U, "nutriment", 5)
					U << "You feel a tiny prick and a sudden rush of substance in to your veins."

			if("Override Laws")
				var/mob/living/silicon/ai/A = locate(href_list["target"])
				var/law_zero = A.laws_object.zeroth//Remembers law zero, if there is one.
				A.laws_object = new /datum/ai_laws/ninja_override
				A.set_zeroth_law(law_zero)//Adds back law zero if there was one.
				A.show_laws()
				U << "\blue Law Override: <b>SUCCESS</b>."
			if("Purge AI")
				var/confirm = alert("Are you sure you want to purge the AI? This cannot be undone once started.", "Confirm Purge", "Yes", "No")
				var/mob/living/silicon/ai/AI = locate() in aicard//Important to place here in case the AI does not exist anymore.
				if(U.stat||U.wear_suit!=src||!initialize||!AI)
					U << browse(null, "window=spideros")
					return
				if(confirm == "Yes")
					if(AI.laws_object.zeroth)
						AI << "\red <b>WARNING</b>: \black Purge procedure detected. \n Now hacking terminal..."
						AI.control_disabled = 0
						U << "\red <b>WARNING</b>: HACKING ATT--TEMPT IN PR0GRESsS!"
						spideros = 0
						unlock = 0
						active = 0
						control = 0
						verbs -= /obj/item/clothing/suit/space/space_ninja/proc/deinit
						verbs -= /obj/item/clothing/suit/space/space_ninja/proc/spideros
						U << browse(null, "window=spideros")
						return
					else
						aicard.flush = 1
						AI.suiciding = 1
						AI << "Your core files are being purged! This is the end..."
						while (AI.stat != 2)
							AI.oxyloss += 2
							AI.updatehealth()
							sleep(10)
						killai(AI)
						aicard.overlays = null
						aicard.flush = 0
			if("Wireless AI")
				for(var/mob/living/silicon/ai/A in aicard)
					A.control_disabled = !A.control_disabled
					A << "AI wireless has been [A.control_disabled ? "disabled" : "enabled"]."

		spideros()//Refreshes the screen by calling it again (which replaces current screen with new screen).
	else//If they are not in control.
		var/mob/living/silicon/ai/AI = usr

		//While AI has control, the person can't take off the suit so checking here would be moot.

		switch(href_list["choice"])
			if("Close")
				AI << browse(null, "window=hack spideros")
				return
			if("Refresh")//Refresh, goes to the end of the proc.
			if("Return")//Return
				if(spideros<=9)
					spideros=0
				else
					spideros = round(spideros/10)//Best way to do this, flooring to nearest integer. As an example, another way of doing it is attached below:
			if("Shock")
				var/damage = min(cell.charge, rand(50,150))//Uses either the current energy left over or between 50 and 150.
				cell.charge -= damage
				if(damage>1)//So they don't spam it when energy is a factor.
					spark_system.start()//SPARKS THERE SHALL BE SPARKS
					U.electrocute_act(damage, src, 0.1)
				else
					AI << "\red <b>ERROR</b>: \black Not enough energy remaining."
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
			if("Message")
				var/obj/item/device/pda/P = locate(href_list["target"])
				var/t = input(U, "Please enter untraceable message.") as text
				t = copytext(sanitize(t), 1, MAX_MESSAGE_LEN)
				if(!t||affecting!=U||!initialize)//Wow, another one of these. Man...
					AI << browse(null, "window=hack spideros")
					return
				if(isnull(P)||P.toff)//So it doesn't freak out if the object no-longer exists.
					AI << "\red Error: unable to deliver message."
					AI.ninja_spideros()
					return
				P.tnote += "<i><b>&larr; From [AI]:</b></i><br>[t]<br>"//Oh ai, u so silly
				if (!P.silent)
					playsound(P.loc, 'twobeep.ogg', 50, 1)
					for (var/mob/O in hearers(3, P.loc))
						O.show_message(text("\icon[P] *[P.ttone]*"))
				P.overlays = null
				P.overlays += image('pda.dmi', "pda-r")
			if("Unlock Kamikaze")
				AI << "\red <b>ERROR</b>: \black TARANTULA.v.4.77.12 encryption algorithm detected. Unable to decrypt archive. \n Aborting..."
			if("Dylovene")
				if(!reagents.get_reagent_amount("anti_toxin"))
					AI << "\red Error: the suit cannot perform this function. Out of dylovene."
				else
					reagents.reaction(U, 2)
					reagents.trans_id_to(U, "anti_toxin", transfera)
					AI << "Injecting..."
					U << "You feel a tiny prick and a sudden rush of liquid in to your veins."
			if("Dexalin Plus")
				if(!reagents.get_reagent_amount("dexalinp"))
					AI << "\red Error: the suit cannot perform this function. Out of dexalinp."
				else
					reagents.reaction(U, 2)
					reagents.trans_id_to(U, "dexalinp", transfera)
					AI << "Injecting..."
					U << "You feel a tiny prick and a sudden rush of liquid in to your veins."
			if("Tricordazine")
				if(!reagents.get_reagent_amount("tricordrazine"))
					AI << "\red Error: the suit cannot perform this function. Out of tricordrazine."
				else
					reagents.reaction(U, 2)
					reagents.trans_id_to(U, "tricordrazine", transfera)
					AI << "Injecting..."
					U << "You feel a tiny prick and a sudden rush of liquid in to your veins."
			if("Spacelin")
				if(!reagents.get_reagent_amount("spaceacillin"))
					AI << "\red Error: the suit cannot perform this function. Out of spaceacillin."
				else
					reagents.reaction(U, 2)
					reagents.trans_id_to(U, "spaceacillin", transfera)
					AI << "Injecting..."
					U << "You feel a tiny prick and a sudden rush of liquid in to your veins."
			if("Radium")
				if((reagents.get_reagent_amount("radium"))<=60)//Special case. If there are only 60 radium units left.
					AI << "\red Error: the suit cannot perform this function. Out of spaceacillin."
				else
					reagents.reaction(U, 2)
					reagents.trans_id_to(U, "spaceacillin", transfera)
					AI << "Injecting..."
					U << "You feel a tiny prick and a sudden rush of liquid in to your veins."
			if("Nutriment")
				if(!reagents.get_reagent_amount("nutriment"))
					AI << "\red Error: the suit cannot perform this function. Out of nutriment."
				else
					reagents.reaction(U, 2)
					reagents.trans_id_to(U, "nutriment", 5)
					AI << "Injecting..."
					U << "You feel a tiny prick and a sudden rush of substance in to your veins."
		AI.ninja_spideros()//Calls spideros for AI.
	return

/obj/item/clothing/suit/space/space_ninja/examine()
	set src in view()
	..()
	if(initialize)
		if(control)
			usr << "All systems operational. Current energy capacity: <B>[cell.charge]</B>."
			if(!kamikaze)
				if(active)
					usr << "The CLOAK-tech device is <B>active</B>."
				else
					usr << "The CLOAK-tech device is <B>inactive</B>."
			else
				usr << "\red KAMIKAZE MODE ENGAGED!"
			usr << "There are <B>[sbombs]</B> smoke bombs remaining."
			usr << "There are <B>[aboost]</B> adrenaline boosters remaining."
		else
			usr <<  "ERR0R DATAA NoT FOUND 3RROR"

//GLOVES===================================

/obj/item/clothing/gloves/space_ninja/proc/toggled()
	set name = "Toggle Interaction"
	set desc = "Toggles special interaction on or off."
	set category = "Object"
	if(!candrain)
		candrain=1
		usr << "You enable special interaction."
	else
		candrain=0
		usr << "You disable special interaction."

//DRAINING PROCS START===================================

/obj/item/clothing/gloves/space_ninja/proc/drain_wire()
	set name = "Drain From Wire"
	set desc = "Drain energy directly from an exposed wire."
	set category = "Object"

	var/obj/cable/attached
	var/mob/living/carbon/human/U = usr
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

/obj/item/clothing/gloves/space_ninja/proc/drain(var/target_type as text, var/target, var/obj/suit, var/obj/gloves)
//Var Initialize
	var/mob/living/carbon/human/U = usr
	var/obj/item/clothing/suit/space/space_ninja/S = suit
	var/obj/item/clothing/gloves/space_ninja/G = gloves

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
		if(candrain)
			usr << "The energy drain mechanism is: <B>active</B>."
		else
			usr << "The energy drain mechanism is: <B>inactive</B>."

//MASK===================================

/obj/item/clothing/mask/gas/voice/space_ninja/New()
	verbs += /obj/item/clothing/mask/gas/voice/space_ninja/proc/togglev
	verbs += /obj/item/clothing/mask/gas/voice/space_ninja/proc/switchm

/obj/item/clothing/mask/gas/voice/space_ninja/proc/togglev()
	set name = "Toggle Voice"
	set desc = "Toggles the voice synthesizer on or off."
	set category = "Object"
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
					if(M==usr||!M.client||!M.real_name)	continue
					names.Add(M)
				if(!names.len)
					voice = "Cuban Pete"//Smallest chance to be the man.
				else
					var/mob/picked = pick(names)
					voice = picked.real_name
		usr << "You are now mimicking <B>[voice]</B>."
	else
		if(voice!="Unknown")
			usr << "You deactivate the voice synthesizer."
			voice = "Unknown"
		else
			usr << "The voice synthesizer is already deactivated."
	return

/obj/item/clothing/mask/gas/voice/space_ninja/proc/switchm()
	set name = "Switch Mode"
	set desc = "Switches between Night Vision, Meson, or Thermal vision modes."
	set category = "Object"
	//Have to reset these manually since life.dm is retarded like that. Go figure.
	switch(mode)
		if(1)
			mode=2
			usr.see_in_dark = 2
			usr << "Switching mode to <B>Thermal Scanner</B>."
		if(2)
			mode=3
			usr.see_invisible = 0
			usr.sight &= ~SEE_MOBS
			usr << "Switching mode to <B>Meson Scanner</B>."
		if(3)
			mode=1
			usr.sight &= ~SEE_TURFS
			usr << "Switching mode to <B>Night Vision</B>."

/obj/item/clothing/mask/gas/voice/space_ninja/examine()
	set src in view()
	..()
	var/mode = "Night Vision"
	var/voice = "inactive"
	switch(mode)
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
	usr << "<B>[mode]</B> is active."
	usr << "Voice mimicking algorithm is set to <B>[voice]</B>."

//ENERGY NET===================================

/*
HerpA:
I'm not really sure what you want this to do.
For now it will teleport people to the prison after 30 seconds.
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
	var/mob/living/master = null//Who shot the net. Will let this person know if net was successful or failed.

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
			healthcheck()
		if(2.0)
			health-=50
			healthcheck()
		if(3.0)
			if (prob(50))
				health-=50
				healthcheck()
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

	if(isnull(M))//If mob is gone.
		if(!isnull(master))//As long as they still exist.
			master << "\red <b>ERROR</b>: \black unable to locate [affecting]. Procedure terminated."
		del(src)//Get rid of the net.
		return

	if(!isnull(src))//As long as both net and person exist.
		//No need to check for countdown here since while() broke, it's implicit that it finished.
		spawn(0)
			playsound(M.loc, 'sparks4.ogg', 50, 1)
			anim(M.loc,'mob.dmi',M,"phaseout")

		M.loc = pick(prisonwarp)//Throw mob in prison.

		spawn(0)
			var/datum/effects/system/spark_spread/spark_system = new /datum/effects/system/spark_spread()
			spark_system.set_up(5, 0, M.loc)
			spark_system.start()
			playsound(M.loc, 'Deconstruct.ogg', 50, 1)
			playsound(M.loc, 'sparks2.ogg', 50, 1)
			anim(M.loc,'mob.dmi',M,"phasein")
			del(src)//Wait for everything to finish, delete the net. Else it will stop everything once net is deleted, including the spawn(0).

		for(var/mob/O in viewers(src, 3))
			O.show_message(text("[] vanished!", M), 1, text("You hear sparks flying!"), 2)

		if(!isnull(master))//As long as they still exist.
			master << "\blue <b>SUCCESS</b>: \black transport procedure of [affecting] complete."

		M.anchored = 0//Important.

	else//And they are free.
		M << "\blue You are free of the net!"
	return