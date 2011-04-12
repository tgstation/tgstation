//STRIKE TEAMS

var/const/commandos_possible = 6 //if more Commandos are needed in the future
var/global/sent_strike_team = 0
/client/proc/strike_team()
	set category = "Fun"
	set name = "Spawn Death Squad"
	set desc = "Spawns a squad of commandos in CentCom if you want to run an admin event."
	if(!src.authenticated || !src.holder)
		src << "Only administrators may use this command."
		return
	if(!ticker)
		alert("The game hasn't started yet!")
		return
	if(world.time < 6000)
		alert("Not so fast, buddy. Wait a few minutes until the game gets going. There are [(6000-world.time)/10] seconds remaining.")
		return
	if(sent_strike_team == 1)
		alert("CentCom is already sending a team, Mr. Dumbass.")
		return
	if(alert("Do you want to send in the CentCom death squad? Once enabled, this is irreversible.",,"Yes","No")=="No")
		return
	alert("This 'mode' will go on until everyone is dead or the station is destroyed. You may also admin-call the evac shuttle when appropriate. Spawned commandos have internals cameras which are viewable through a monitor inside the Spec. Ops. Office. Assigning the team's detailed task is recommended from there. While you will be able to manually pick the candidates from active ghosts, their assignment in the squad will be random.")

	TRYAGAIN

	var/input = input(usr, "Please specify which mission the death commando squad shall undertake.", "Specify Mission", "")
	if(!input)
		goto TRYAGAIN
	sent_strike_team = 1

	if (emergency_shuttle.direction == 1 && emergency_shuttle.online == 1)
		emergency_shuttle.recall()
		world << "\blue <B>Alert: The shuttle is going back!</B>"

	var/commando_number = 6 //for selecting a leader
	var/leader_selected = 0 //when the leader is chosen. The last person spawned.
	var/commando_leader_rank = pick("Lieutenant", "Captain", "Major")

//Code for spawning a nuke auth code.
	var/nuke_code = "[rand(10000, 99999.0)]"

//Generates a list of commandos from active ghosts. Then the user picks which characters to respawn as the commandos.
	var/mob/dead/observer/G
	var/list/commandos = list()//actual commando ghosts as picked by the user.
	var/list/candidates = list()//candidates for being a commando out of all the active ghosts in world.
	for(G in world)
		if(G.client)
			if(!G.client.holder && ((G.client.inactivity/10)/60) <= 5) //Whoever called/has the proc won't be added to the list.
//			if(((G.client.inactivity/10)/60) <= 5) //Removing it allows even the caller to jump in. Good for testing.
				candidates.Add(G)
	var/p=1
	while(candidates.len&&p<=commandos_possible)
		G = input("Pick characters to spawn as the commandos. This will go on until there either no more ghosts to pick from or the slots are full.", "Active Players", G) in candidates//It will auto-pick a person when there is only one candidate.
		commandos.Add(G)
		p++

//Spawns commandos and equips them.
	for (var/obj/landmark/STARTLOC in world)
		if (STARTLOC.name == "Commando")
			var/mob/living/carbon/human/new_commando = new(STARTLOC.loc)
			var/commando_rank = pick("Corporal", "Sergeant", "Staff Sergeant", "Sergeant 1st Class", "Master Sergeant", "Sergeant Major")
			var/commando_name = pick(last_names)
			new_commando.gender = pick(MALE, FEMALE)
			if (commando_number == 1)
				leader_selected = 1
			if (leader_selected == 0)
				new_commando.real_name = "[commando_rank] [commando_name]"
			else
				new_commando.real_name = "[commando_leader_rank] [commando_name]"
			if (leader_selected == 0)
				new_commando.age = rand(23,35)
			else
				new_commando.age = rand(35,45)
			new_commando.b_type = pick("A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-")
			new_commando.dna.ready_dna(new_commando) //Creates DNA
			//Creates mind stuff.
			new_commando.mind = new
			new_commando.mind.current = new_commando
			new_commando.mind.assigned_role = "Centcom Contractor"
			new_commando.mind.special_role = "Death Commando"
			new_commando.mind.store_memory("<B>Nuke Code:</B> \red [nuke_code].")//So they don't forget their code or mission.
			new_commando.mind.store_memory("<B>Mission:</B> \red [input].")
			new_commando.resistances += "alien_embryo"

			del(STARTLOC)

			var/obj/machinery/camera/cam = new /obj/machinery/camera(new_commando) //Gives all the commandos internals cameras.
			cam.network = "CREED"
			cam.c_tag = new_commando.real_name

			var/obj/item/device/radio/R = new /obj/item/device/radio/headset(new_commando)
			R.set_frequency(1441)
			new_commando.equip_if_possible(R, new_commando.slot_ears)
			if (leader_selected == 0)
				new_commando.equip_if_possible(new /obj/item/clothing/under/color/green(new_commando), new_commando.slot_w_uniform)
			else
				new_commando.equip_if_possible(new /obj/item/clothing/under/rank/centcom_officer(new_commando), new_commando.slot_w_uniform)
			new_commando.equip_if_possible(new /obj/item/clothing/shoes/swat(new_commando), new_commando.slot_shoes)
			new_commando.equip_if_possible(new /obj/item/clothing/suit/armor/swat(new_commando), new_commando.slot_wear_suit)
			new_commando.equip_if_possible(new /obj/item/clothing/gloves/swat(new_commando), new_commando.slot_gloves)
			new_commando.equip_if_possible(new /obj/item/clothing/head/helmet/swat(new_commando), new_commando.slot_head)
			new_commando.equip_if_possible(new /obj/item/clothing/mask/gas/swat(new_commando), new_commando.slot_wear_mask)
			new_commando.equip_if_possible(new /obj/item/clothing/glasses/thermal(new_commando), new_commando.slot_glasses)

			new_commando.equip_if_possible(new /obj/item/weapon/storage/backpack(new_commando), new_commando.slot_back)

			new_commando.equip_if_possible(new /obj/item/weapon/ammo/a357(new_commando), new_commando.slot_in_backpack)
			new_commando.equip_if_possible(new /obj/item/weapon/storage/firstaid/regular(new_commando), new_commando.slot_in_backpack)
			new_commando.equip_if_possible(new /obj/item/weapon/storage/flashbang_kit(new_commando), new_commando.slot_in_backpack)
			new_commando.equip_if_possible(new /obj/item/device/flashlight(new_commando), new_commando.slot_in_backpack)
			if (leader_selected == 0)
				new_commando.equip_if_possible(new /obj/item/weapon/plastique(new_commando), new_commando.slot_in_backpack)
			else
				new_commando.equip_if_possible(new /obj/item/weapon/pinpointer(new_commando), new_commando.slot_in_backpack)
			if (leader_selected == 1)
				new_commando.equip_if_possible(new /obj/item/weapon/disk/nuclear(new_commando), new_commando.slot_in_backpack)

			new_commando.equip_if_possible(new /obj/item/weapon/sword(new_commando), new_commando.slot_l_store)
			new_commando.equip_if_possible(new /obj/item/weapon/flashbang(new_commando), new_commando.slot_r_store)
			new_commando.equip_if_possible(new /obj/item/weapon/tank/emergency_oxygen(new_commando), new_commando.slot_belt)

			var/obj/item/weapon/gun/revolver/GUN = new /obj/item/weapon/gun/revolver/mateba(new_commando)
			GUN.bullets = 7
			new_commando.equip_if_possible(GUN, new_commando.slot_s_store)
//			new_commando.equip_if_possible(new /obj/item/weapon/gun/energy/pulse_rifle(new_commando), new_commando.slot_l_hand)
/*Commented out because Commandos now have their rifles spawn in front of them, along with operation manuals.
Useful for copy pasta since I'm lazy.*/

			var/obj/item/weapon/card/id/W = new(new_commando)
			W.name = "[new_commando.real_name]'s ID Card"
			W.access = get_all_accesses()
			W.assignment = "Death Commando"
			W.registered = new_commando.real_name
			new_commando.equip_if_possible(W, new_commando.slot_wear_id)

			if(commandos.len)
				G = pick(commandos)
				new_commando.mind.key = G.key//For mind stuff.
				new_commando.client = G.client
				del(G)
			else
				new_commando.key = "null"
				new_commando.mind.key = new_commando.key

			commando_number--

			if (leader_selected == 0)
				new_commando << "\blue \nYou are a Special Ops. commando in the service of Central Command. Check the table ahead for detailed instructions.\nYour current mission is: \red<B>[input]</B>"
			else
				new_commando << "\blue \nYou are a Special Ops. <B>LEADER</B> in the service of Central Command. Check the table ahead for detailed instructions.\nYour current mission is: \red<B>[input]</B>"

//Targets any nukes in the world and changes their auth code as needed.
//Bad news for Nuke operatives--or great news.
	for(var/obj/machinery/nuclearbomb/NUAK in world)
		if (NUAK.name == "Nuclear Fission Explosive")
			NUAK.r_code = nuke_code

	for (var/obj/landmark/MANUAL)
		if (MANUAL.name == "Commando_Manual")
			new /obj/item/weapon/gun/energy/pulse_rifle(MANUAL.loc)
			var/obj/item/weapon/paper/PAPER = new(MANUAL.loc)
			PAPER.info = "<p><b>Good morning soldier!</b>. This compact guide will familiarize you with standard operating procedure. There are three basic rules to follow:<br>#1 Work as a team.<br>#2 Accomplish your objective at all costs.<br>#3 Leave no witnesses.<br>You are fully equipped and stocked for your mission--before departing on the Spec. Ops. Shuttle due South, make sure that all operatives are ready. Actual mission objective will be relayed to you by Central Command through your headsets.<br>If deemed appropriate, Central Command will also allow members of your team to equip assault power-armor for the mission. You will find the armor storage due West of your position. Once you are ready to leave, utilize the Special Operations shuttle console and toggle the hull doors via the other console.</p><p>In the event that the team does not accomplish their assigned objective in a timely manner, or finds no other way to do so, attached below are instructions on how to operate a Nanotrasen Nuclear Device. Your operations <b>LEADER</b> is provided with a nuclear authentication disk and a pin-pointer for this reason. You may easily recognize them by their rank: Lieutenant, Captain, or Major. The nuclear device itself will be present somewhere on your destination.</p><p>Hello and thank you for choosing Nanotrasen for your nuclear information needs. Today's crash course will deal with the operation of a Fission Class Nanotrasen made Nuclear Device.<br>First and foremost, <b>DO NOT TOUCH ANYTHING UNTIL THE BOMB IS IN PLACE.</b> Pressing any button on the compacted bomb will cause it to extend and bolt itself into place. If this is done to unbolt it one must completely log in which at this time may not be possible.<br>To make the device functional:<br>#1 Place bomb in designated detonation zone<br> #2 Extend and anchor bomb (attack with hand).<br>#3 Insert Nuclear Auth. Disk into slot.<br>#4 Type numeric code into keypad ([nuke_code]).<br>Note: If you make a mistake press R to reset the device.<br>#5 Press the E button to log onto the device.<br>You now have activated the device. To deactivate the buttons at anytime, for example when you have already prepped the bomb for detonation, remove the authentication disk OR press the R on the keypad. Now the bomb CAN ONLY be detonated using the timer. A manual detonation is not an option.<br>Note: Toggle off the <b>SAFETY</b>.<br>Use the - - and + + to set a detonation time between 5 seconds and 10 minutes. Then press the timer toggle button to start the countdown. Now remove the authentication disk so that the buttons deactivate.<br>Note: <b>THE BOMB IS STILL SET AND WILL DETONATE</b><br>Now before you remove the disk if you need to move the bomb you can: Toggle off the anchor, move it, and re-anchor.</p><p>The nuclear authorization code is: <b>[nuke_code]</b></p><p><b>Good luck, soldier!</b></p>"
			PAPER.name = "Spec. Ops. Manual"

	for (var/obj/landmark/BOMB in world)
		if (BOMB.name == "Commando-Bomb")
			new /obj/spawner/newbomb/timer/syndicate(BOMB.loc)
			del(BOMB)

	message_admins("\blue [key_name_admin(usr)] has spawned a CentCom strike squad.", 1)
	log_admin("[key_name(usr)] used Spawn Death Squad.")

//SPACE NINJAS
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
	new_ninja.mind.store_memory("<B>Mission:</B> \red [input].")
	new_ninja.resistances += "alien_embryo"

	var/obj/item/device/radio/R = new /obj/item/device/radio/headset(new_ninja)
	new_ninja.equip_if_possible(R, new_ninja.slot_ears)
	new_ninja.equip_if_possible(new /obj/item/clothing/under/color/black(new_ninja), new_ninja.slot_w_uniform)
	new_ninja.equip_if_possible(new /obj/item/clothing/shoes/space_ninja(new_ninja), new_ninja.slot_shoes)
	new_ninja.equip_if_possible(new /obj/item/clothing/suit/space/space_ninja(new_ninja), new_ninja.slot_wear_suit)
	new_ninja.equip_if_possible(new /obj/item/clothing/gloves/space_ninja(new_ninja), new_ninja.slot_gloves)
	new_ninja.equip_if_possible(new /obj/item/clothing/head/helmet/space/space_ninja(new_ninja), new_ninja.slot_head)
	new_ninja.equip_if_possible(new /obj/item/clothing/mask/gas/space_ninja(new_ninja), new_ninja.slot_wear_mask)
	new_ninja.equip_if_possible(new /obj/item/device/flashlight(new_ninja), new_ninja.slot_belt)
	new_ninja.equip_if_possible(new /obj/item/weapon/plastique(new_ninja), new_ninja.slot_r_store)
	new_ninja.equip_if_possible(new /obj/item/weapon/plastique(new_ninja), new_ninja.slot_l_store)
	var/obj/item/weapon/tank/emergency_oxygen/OXYTANK = new /obj/item/weapon/tank/emergency_oxygen(new_ninja)
	new_ninja.equip_if_possible(OXYTANK, new_ninja.slot_s_store)

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
		del(G)
	else
		alert("Could not locate a suitable ghost. Aborting.")
		del(new_ninja)
		return

	new_ninja.internal = OXYTANK //So the poor ninja has something to breath when they spawn in spess.
	new_ninja.internals.icon_state = "internal1"

	new_ninja << "\blue \nYou are an elite mercenary assassin of the Spider Clan, [new_ninja.real_name]. The dreaded \red <B>SPACE NINJA</B>!\blue You have a variety of abilities at your disposal, thanks to your nano-enhanced cyber armor. Remember your training (initialize your suit by right clicking on it)! \nYour current mission is: \red <B>[input]</B>"

	message_admins("\blue [admin_name] has spawned [new_ninja.key] as a Space Ninja. Hide yo children!", 1)
	log_admin("[admin_name] used Spawn Space Ninja.")


//SPACE NINJA ABILITIES

/*
//	src << "\red Something has gone awry and you are missing one or more pieces of equipment."

/mob/proc/ninjagear()
	if(!istype(src:wear_suit, /obj/item/clothing/suit/space/space_ninja))	return 0
	else if(!istype(src:head, /obj/item/clothing/head/helmet/space/space_ninja))	return 0
	else if(!istype(src:gloves, /obj/item/clothing/gloves/space_ninja))	return 0
	else if(!istype(src:shoes, /obj/item/clothing/shoes/space_ninja))	return 0
	else	return 1

/mob/proc/ninjacost(var/cost)
	if(cost>src.wear_suit:energy)
		return 0
	else
		src.wear_suit:energy=src.wear_suit:energy-cost
		return 1

//else if (istype(src.wear_mask, /obj/item/clothing/mask/gas/space_ninja))
	//			switch(src.wear_mask:mode)
*/
//Smoke
//Summons smoke in radius of user.
//Not sure why this would be useful (it's not) but whatever. Ninjas need their smoke bombs.
/mob/proc/ninjasmoke()
	set name = "Smoke Bomb"
	set desc = "Blind your enemies momentarily with a well-placed smoke bomb."
	set category = "Ninja"

	if(src.stat)
		src << "\red You must be conscious to do this."
		return
	//add energy cost check
	//add warning message for low energy

	var/datum/effects/system/bad_smoke_spread/smoke = new /datum/effects/system/bad_smoke_spread()
	smoke.set_up(10, 0, src.loc)
	smoke.start()
	playsound(src.loc, 'bamf.ogg', 50, 2)
	//subtract cost(5)


//9-10 Tile Teleport
//Click to to teleport 9-10 tiles in direction facing.
/mob/proc/ninjajaunt()
	set name = "Phase Jaunt"
	set desc = "Utilizes the internal VOID-shift device to rapidly transit in direction facing."
	set category = "Ninja"

	if(src.stat)
		src << "\red You must be conscious to do this."
		return
	//add energy cost check
	//add warning message for low energy

	var/list/turfs = new/list()
	var/turf/picked
	var/turf/mobloc = get_turf(src.loc)
	switch(src.dir)
		if(NORTH)
			//highest Y
			//X the same
			for(var/turf/T in orange(10))
				if(T.density) continue
				if(T.x>world.maxx || T.x<1)	continue
				if(T.y>world.maxy || T.y<1)	continue
				if((T.y-mobloc.y)<9 || ((T.x+mobloc.x+1)-(mobloc.x*2))>2)	continue
				turfs += T
		if(SOUTH)
			//lowest Y
			//X the same
			for(var/turf/T in orange(10))
				if(T.density) continue
				if(T.x>world.maxx || T.x<1)	continue
				if(T.y>world.maxy || T.y<1)	continue
				if((mobloc.y-T.y)<9 || ((T.x+mobloc.x+1)-(mobloc.x*2))>2)	continue
				turfs += T
		if(EAST)
			//highest X
			//Y the same
			for(var/turf/T in orange(10))
				if(T.density) continue
				if(T.x>world.maxx || T.x<1)	continue
				if(T.y>world.maxy || T.y<1)	continue
				if((T.x-mobloc.x)<9 || ((T.y+mobloc.y+1)-(mobloc.y*2))>2)	continue
				turfs += T
		if(WEST)
			//lowest X
			//Y the same
			for(var/turf/T in orange(10))
				if(T.density) continue
				if(T.x>world.maxx || T.x<1)	continue
				if(T.y>world.maxy || T.y<1)	continue
				if((mobloc.x-T.x)<9 || ((T.y+mobloc.y+1)-(mobloc.y*2))>2)	continue
				turfs += T
		else
			return
	if(!turfs.len)//Cancels the teleportation if no valid turf is found. Usually when teleporting near map edge.
		src << "\red The VOID-shift device is malfunctioning, <B>teleportation failed</B>."
		return
	picked = pick(turfs)
	spawn(0)
		playsound(src.loc, "sparks", 50, 1)
		anim(mobloc,'mob.dmi',src,"phaseout")

	src.loc = picked

	spawn(0)
		var/datum/effects/system/spark_spread/spark_system = new /datum/effects/system/spark_spread()
		spark_system.set_up(5, 0, src.loc)
		spark_system.start()
		playsound(src.loc, 'Deconstruct.ogg', 50, 1)
		playsound(src.loc, "sparks", 50, 1)
		anim(src.loc,'mob.dmi',src,"phasein")

	spawn(0) //Any living mobs in teleport area are gibbed.
		for(var/mob/living/M in picked)
			if(M==src)	continue
			M.gib()
	//subtract cost(10)

//Right Click Teleport
//Right click to teleport somewhere, almost exactly like admin jump to turf.
/mob/proc/ninjashift(var/turf/T in oview())
	set name = "Phase Shift"
	set desc = "Utilizes the internal VOID-shift device to rapidly transit to a destination in view."
	set category = null//So it does not show up on the panel but can still be right-clicked.

	if(src.stat)
		src << "\red You must be conscious to do this."
		return
	//add energy cost check
	//add warning message for low energy
	if(T.density)
		src << "\red You cannot teleport into solid walls."
		return

	var/turf/mobloc = get_turf(src.loc)

	spawn(0)
		playsound(src.loc, 'sparks4.ogg', 50, 1)
		anim(mobloc,'mob.dmi',src,"phaseout")

	src.loc = T

	spawn(0)
		var/datum/effects/system/spark_spread/spark_system = new /datum/effects/system/spark_spread()
		spark_system.set_up(5, 0, src.loc)
		spark_system.start()
		playsound(src.loc, 'Deconstruct.ogg', 50, 1)
		playsound(src.loc, 'sparks2.ogg', 50, 1)
		anim(src.loc,'mob.dmi',src,"phasein")

	spawn(0) //Any living mobs in teleport area are gibbed.
		for(var/mob/living/M in T)
			if(M==src)	continue
			M.gib()
	//subtract cost(20)

//EMP Pulse
//Disables nearby tech equipment.
/mob/proc/ninjapulse()
	set name = "EM Burst"
	set desc = "Disable any nearby technology with a electro-magnetic pulse."
	set category = "Ninja"

	if(src.stat)
		src << "\red You must be conscious to do this."
		return
	//add energy cost check
	//add warning message for low energy

	empulse(src, 4, 6) //Procs sure are nice. Slightly weaker than wizard's disable tch.

	//subtract cost(25)

/mob/proc/ninjablade()
//Summon Energy Blade
//Summons a blade of energy in active hand.
	set name = "Energy Blade"
	set desc = "Create a focused beam of energy in your active hand."
	set category = "Ninja"

	if(src.stat)
		src << "\red You must be conscious to do this."
		return

	//add energy cost check
	//add warning message for low energy

	if(!src.get_active_hand()&&!istype(src.get_inactive_hand(), /obj/item/weapon/blade))
		var/obj/item/weapon/blade/W = new()
		W.spark_system.start()
		playsound(src.loc, "sparks", 50, 1)
		src.put_in_hand(W)
/*
/mob/proc/ninjastar(var/mob/living/M in oview())
*/