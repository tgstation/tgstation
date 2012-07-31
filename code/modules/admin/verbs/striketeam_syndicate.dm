//STRIKE TEAMS

var/const/syndicate_commandos_possible = 6 //if more Commandos are needed in the future
var/global/sent_syndicate_strike_team = 0
/client/proc/syndicate_strike_team()
	set category = "Fun"
	set name = "Spawn Syndicate Strike Team"
	set desc = "Spawns a squad of commandos in the Syndicate Mothership if you want to run an admin event."
	if(!src.holder)
		src << "Only administrators may use this command."
		return
	if(!ticker)
		alert("The game hasn't started yet!")
		return
//	if(world.time < 6000)
//		alert("Not so fast, buddy. Wait a few minutes until the game gets going. There are [(6000-world.time)/10] seconds remaining.")
//		return
	if(sent_syndicate_strike_team == 1)
		alert("The Syndicate are already sending a team, Mr. Dumbass.")
		return
	if(alert("Do you want to send in the Syndicate Strike Team? Once enabled, this is irreversible.",,"Yes","No")=="No")
		return
	alert("This 'mode' will go on until everyone is dead or the station is destroyed. You may also admin-call the evac shuttle when appropriate. Spawned syndicates have internals cameras which are viewable through a monitor inside the Syndicate Mothership Bridge. Assigning the team's detailed task is recommended from there. While you will be able to manually pick the candidates from active ghosts, their assignment in the squad will be random.")

	var/input = null
	while(!input)
		input = copytext(sanitize(input(src, "Please specify which mission the syndicate strike team shall undertake.", "Specify Mission", "")),1,MAX_MESSAGE_LEN)
		if(!input)
			if(alert("Error, no mission set. Do you want to exit the setup process?",,"Yes","No")=="Yes")
				return

	if(sent_syndicate_strike_team)
		src << "Looks like someone beat you to it."
		return

	sent_syndicate_strike_team = 1

	if (emergency_shuttle.direction == 1 && emergency_shuttle.online == 1)
		emergency_shuttle.recall()

	var/syndicate_commando_number = syndicate_commandos_possible //for selecting a leader
	var/syndicate_leader_selected = 0 //when the leader is chosen. The last person spawned.

//Code for spawning a nuke auth code.
	var/nuke_code
	var/temp_code
	for(var/obj/machinery/nuclearbomb/N in world)
		temp_code = text2num(N.r_code)
		if(temp_code)//if it's actually a number. It won't convert any non-numericals.
			nuke_code = N.r_code
			break

//Generates a list of commandos from active ghosts. Then the user picks which characters to respawn as the commandos.
	var/mob/dead/observer/G//Basic variable to search for later.
	var/candidates_list[] = list()//candidates for being a commando out of all the active ghosts in world.
	var/syndicate_commandos_list[] = list()//actual commando ghosts as picked by the user.
	for(G in dead_mob_list)
		if(!G.client.holder && ((G.client.inactivity/10)/60) <= 5) //Whoever called/has the proc won't be added to the list.
//		if(((G.client.inactivity/10)/60) <= 5) //Removing it allows even the caller to jump in. Good for testing.
			candidates_list += G//Add their client to list.
	for(var/i=syndicate_commandos_possible,(i>0&&candidates_list.len),i--)//Decrease with every commando selected.
		var/client/G_client = input("Pick characters to spawn as the commandos. This will go on until there either no more ghosts to pick from or the slots are full.", "Active Players") as null|anything in candidates_list//It will auto-pick a person when there is only one candidate.
		if(G_client)//They may have logged out when the admin was choosing people. Or were not chosen. Would run time error otherwise.
			candidates_list -= G_client//Subtract from candidates.
			syndicate_commandos_list += G_client.mob//Add their ghost to commandos.

//Spawns commandos and equips them.
	for (var/obj/effect/landmark/L in world)
		if(syndicate_commando_number<=0)	break
		if (L.name == "Syndicate-Commando")
			syndicate_leader_selected = syndicate_commando_number == 1?1:0

			var/mob/living/carbon/human/new_syndicate_commando = create_syndicate_death_commando(L, syndicate_leader_selected)

			if(syndicate_commandos_list.len)
				G = pick(syndicate_commandos_list)
				new_syndicate_commando.mind.key = G.key//For mind stuff.
				new_syndicate_commando.key = G.key
				new_syndicate_commando.internal = new_syndicate_commando.s_store
				new_syndicate_commando.internals.icon_state = "internal1"
				syndicate_commandos_list -= G
				del(G)

			//So they don't forget their code or mission.
			if(nuke_code)
				new_syndicate_commando.mind.store_memory("<B>Nuke Code:</B> \red [nuke_code].")
			new_syndicate_commando.mind.store_memory("<B>Mission:</B> \red [input].")

			new_syndicate_commando << "\blue You are an Elite Syndicate. [!syndicate_leader_selected?"commando":"<B>LEADER</B>"] in the service of the Syndicate. \nYour current mission is: \red<B>[input]</B>"

			syndicate_commando_number--

//Spawns the rest of the commando gear.
//	for (var/obj/effect/landmark/L)
	//	if (L.name == "Commando_Manual")
			//new /obj/item/weapon/gun/energy/pulse_rifle(L.loc)
		//	var/obj/item/weapon/paper/P = new(L.loc)
		//	P.info = "<p><b>Good morning soldier!</b>. This compact guide will familiarize you with standard operating procedure. There are three basic rules to follow:<br>#1 Work as a team.<br>#2 Accomplish your objective at all costs.<br>#3 Leave no witnesses.<br>You are fully equipped and stocked for your mission--before departing on the Spec. Ops. Shuttle due South, make sure that all operatives are ready. Actual mission objective will be relayed to you by Central Command through your headsets.<br>If deemed appropriate, Central Command will also allow members of your team to equip assault power-armor for the mission. You will find the armor storage due West of your position. Once you are ready to leave, utilize the Special Operations shuttle console and toggle the hull doors via the other console.</p><p>In the event that the team does not accomplish their assigned objective in a timely manner, or finds no other way to do so, attached below are instructions on how to operate a Nanotrasen Nuclear Device. Your operations <b>LEADER</b> is provided with a nuclear authentication disk and a pin-pointer for this reason. You may easily recognize them by their rank: Lieutenant, Captain, or Major. The nuclear device itself will be present somewhere on your destination.</p><p>Hello and thank you for choosing Nanotrasen for your nuclear information needs. Today's crash course will deal with the operation of a Fission Class Nanotrasen made Nuclear Device.<br>First and foremost, <b>DO NOT TOUCH ANYTHING UNTIL THE BOMB IS IN PLACE.</b> Pressing any button on the compacted bomb will cause it to extend and bolt itself into place. If this is done to unbolt it one must completely log in which at this time may not be possible.<br>To make the device functional:<br>#1 Place bomb in designated detonation zone<br> #2 Extend and anchor bomb (attack with hand).<br>#3 Insert Nuclear Auth. Disk into slot.<br>#4 Type numeric code into keypad ([nuke_code]).<br>Note: If you make a mistake press R to reset the device.<br>#5 Press the E button to log onto the device.<br>You now have activated the device. To deactivate the buttons at anytime, for example when you have already prepped the bomb for detonation, remove the authentication disk OR press the R on the keypad. Now the bomb CAN ONLY be detonated using the timer. A manual detonation is not an option.<br>Note: Toggle off the <b>SAFETY</b>.<br>Use the - - and + + to set a detonation time between 5 seconds and 10 minutes. Then press the timer toggle button to start the countdown. Now remove the authentication disk so that the buttons deactivate.<br>Note: <b>THE BOMB IS STILL SET AND WILL DETONATE</b><br>Now before you remove the disk if you need to move the bomb you can: Toggle off the anchor, move it, and re-anchor.</p><p>The nuclear authorization code is: <b>[nuke_code ? nuke_code : "None provided"]</b></p><p><b>Good luck, soldier!</b></p>"
		//	P.name = "Spec. Ops. Manual"

	for (var/obj/effect/landmark/L in world)
		if (L.name == "Syndicate-Commando-Bomb")
			new /obj/effect/spawner/newbomb/timer/syndicate(L.loc)
			del(L)

	message_admins("\blue [key_name_admin(usr)] has spawned a Syndicate strike squad.", 1)
	log_admin("[key_name(usr)] used Spawn Syndicate Squad.")
	feedback_add_details("admin_verb","SDTHS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/create_syndicate_death_commando(obj/spawn_location, syndicate_leader_selected = 0)
	var/mob/living/carbon/human/new_syndicate_commando = new(spawn_location.loc)
	var/syndicate_commando_leader_rank = pick("Lieutenant", "Captain", "Major")
	var/syndicate_commando_rank = pick("Corporal", "Sergeant", "Staff Sergeant", "Sergeant 1st Class", "Master Sergeant", "Sergeant Major")
	var/syndicate_commando_name = pick(last_names)

	new_syndicate_commando.gender = pick(MALE, FEMALE)

	var/datum/preferences/A = new()//Randomize appearance for the commando.
	A.randomize_appearance_for(new_syndicate_commando)

	new_syndicate_commando.real_name = "[!syndicate_leader_selected ? syndicate_commando_rank : syndicate_commando_leader_rank] [syndicate_commando_name]"
	new_syndicate_commando.age = !syndicate_leader_selected ? rand(23,35) : rand(35,45)

	new_syndicate_commando.dna.ready_dna(new_syndicate_commando)//Creates DNA.

	//Creates mind stuff.
	new_syndicate_commando.mind = new
	new_syndicate_commando.mind.current = new_syndicate_commando
	new_syndicate_commando.mind.original = new_syndicate_commando
	new_syndicate_commando.mind.assigned_role = "MODE"
	new_syndicate_commando.mind.special_role = "Syndicate Commando"
	if(!(new_syndicate_commando.mind in ticker.minds))
		ticker.minds += new_syndicate_commando.mind//Adds them to regular mind list.
	if(!(new_syndicate_commando.mind in ticker.mode.traitors))//If they weren't already an extra traitor.
		ticker.mode.traitors += new_syndicate_commando.mind//Adds them to current traitor list. Which is really the extra antagonist list.
	new_syndicate_commando.equip_syndicate_commando(syndicate_leader_selected)
	del(spawn_location)
	return new_syndicate_commando

/mob/living/carbon/human/proc/equip_syndicate_commando(syndicate_leader_selected = 0)
	var/obj/machinery/camera/camera = new /obj/machinery/camera(src) //Gives all the commandos internals cameras.
	camera.network = "Syndicate"
	camera.c_tag = real_name

	var/obj/item/device/radio/R = new /obj/item/device/radio/headset/syndicate(src)
	R.set_frequency(SYND_FREQ) //Same frequency as the syndicate team in Nuke mode.
	equip_if_possible(R, slot_ears)
	equip_if_possible(new /obj/item/clothing/under/syndicate(src), slot_w_uniform)
	equip_if_possible(new /obj/item/clothing/shoes/swat(src), slot_shoes)
	if (!syndicate_leader_selected)
		equip_if_possible(new /obj/item/clothing/suit/space/syndicate/elite(src), slot_wear_suit)
	else
		equip_if_possible(new /obj/item/clothing/suit/space/syndicate/elite/leader(src), slot_wear_suit)
	equip_if_possible(new /obj/item/clothing/gloves/swat(src), slot_gloves)
	if (!syndicate_leader_selected)
		equip_if_possible(new /obj/item/clothing/head/helmet/space/syndicate/elite(src), slot_head)
	else
		equip_if_possible(new /obj/item/clothing/head/helmet/space/syndicate/elite/leader(src), slot_head)
	equip_if_possible(new /obj/item/clothing/mask/gas/syndicate(src), slot_wear_mask)
	equip_if_possible(new /obj/item/clothing/glasses/thermal(src), slot_glasses)

	equip_if_possible(new /obj/item/weapon/storage/backpack/security(src), slot_back)
	equip_if_possible(new /obj/item/weapon/storage/box(src), slot_in_backpack)

	equip_if_possible(new /obj/item/ammo_magazine/c45(src), slot_in_backpack)
	equip_if_possible(new /obj/item/weapon/storage/firstaid/regular(src), slot_in_backpack)
	equip_if_possible(new /obj/item/weapon/plastique(src), slot_in_backpack)
	equip_if_possible(new /obj/item/device/flashlight(src), slot_in_backpack)
	if (!syndicate_leader_selected)
		equip_if_possible(new /obj/item/weapon/plastique(src), slot_in_backpack)
	else
		equip_if_possible(new /obj/item/weapon/pinpointer(src), slot_in_backpack)
		equip_if_possible(new /obj/item/weapon/disk/nuclear(src), slot_in_backpack)

	equip_if_possible(new /obj/item/weapon/melee/energy/sword(src), slot_l_store)
	equip_if_possible(new /obj/item/weapon/grenade/empgrenade(src), slot_r_store)
	equip_if_possible(new /obj/item/weapon/tank/emergency_oxygen(src), slot_s_store)
	equip_if_possible(new /obj/item/weapon/gun/projectile/silenced(src), slot_belt)

	equip_if_possible(new /obj/item/weapon/gun/energy/pulse_rifle(src), slot_r_hand) //Will change to something different at a later time -- Superxpdude

	var/obj/item/weapon/card/id/syndicate/W = new(src) //Untrackable by AI
	W.name = "[real_name]'s ID Card"
	W.icon_state = "id"
	W.access = get_all_accesses()//They get full station access because obviously the syndicate has HAAAX, and can make special IDs for their most elite members.
	W.access += list(access_cent_general, access_cent_specops, access_cent_living, access_cent_storage, access_syndicate)//Let's add their forged CentCom access and syndicate access.
	W.assignment = "Syndicate Commando"
	W.registered_name = real_name
	equip_if_possible(W, slot_wear_id)

	resistances += "alien_embryo"
	return 1