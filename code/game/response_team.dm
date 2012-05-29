//STRIKE TEAMS

var/list/response_team_members = list()
var/send_emergency_team = 0

client/verb/JoinResponseTeam()
	set category = "IC"

	if(istype(usr,/mob/dead/observer) || istype(usr,/mob/new_player))
		if(!send_emergency_team)
			usr << "No emergency response team is currently being sent."
			return
		if(jobban_isbanned(usr, "Syndicate") || jobban_isbanned(usr, "Emergency Response Team") || jobban_isbanned(usr, "Security Officer"))
			usr << "<font color=red><b>You are jobbanned from the emergency reponse team!"
			return

		if(response_team_members.len > 5) usr << "The emergency response team is already full!"

		var/leader_selected = (response_team_members.len == 0)

		for (var/obj/effect/landmark/L in world) if (L.name == "Commando")

			var/new_name = input(usr, "Pick a name","Name") as null|text
			if(!new_name) return
			var/mob/living/carbon/human/new_commando = create_response_team(L, leader_selected, new_name)

			new_commando.mind.key = usr.key
			new_commando.key = usr.key

			new_commando << "\blue You are [!leader_selected?"a member":"the <B>LEADER</B>"] of an Emergency Response Team under CentComm's service. There is a code red alert on [station_name()], you are tasked to go and fix the problem."
			new_commando << "<b>You should first gear up and discuss a plan with your team. More members may be joining, don't move out before you're ready."
			del(L)

	else
		usr << "You need to be an observer or new player to use this."

// returns a number of dead players in %
proc/percentage_dead()
	var/total = 0
	var/deadcount = 0
	for(var/mob/living/carbon/human/H in world) if(H.mind) // I *think* monkeys gone human don't have a mind
		if(H.stat == 2) deadcount++
		total++

	if(total == 0) return 0
	else return round(100 * deadcount / total)

// counts the number of antagonists in %
proc/percentage_antagonists()
	var/total = 0
	var/antagonists = 0
	for(var/mob/living/carbon/human/H in world)
		if(is_special_character(H) >= 1)
			antagonists++
		total++

	if(total == 0) return 0
	else return round(100 * antagonists / total)


proc/trigger_armed_response_team(var/force = 0)
	if(send_emergency_team)
		return

	var/send_team_chance = 20 // base chance that a team will be sent
	send_team_chance += 2*percentage_dead() // the more people are dead, the higher the chance
	send_team_chance += percentage_antagonists() // the more antagonists, the higher the chance
	send_team_chance = min(send_team_chance, 100)

	if(force) send_team_chance = 100

	// there's only a certain chance a team will be sent
	if(!prob(send_team_chance)) return

	command_alert("According to our sensors, [station_name()] has entered code red. We will prepare and dispatch an emergency response team to deal with the situation.", "Command Report")

	send_emergency_team = 1

	var/area/security/nuke_storage/nukeloc = locate()//To find the nuke in the vault
	var/obj/machinery/nuclearbomb/nuke = locate() in nukeloc
	if(!nuke)
		nuke = locate() in world
	var/obj/item/weapon/paper/P = new
	P.info = "Your orders, Commander, are to use all means necessary to return the station to a survivable condition.<br>To this end, you have been provided with the best tools we can give in the three areas of Medicine, Engineering, and Security. The nuclear authorization code is: <b>[ nuke ? nuke.r_code : "AHH, THE NUKE IS GONE!"]</b>. Be warned, if you detonate this without good reason, we will hold you to account for damages. Memorise this code, and then burn this message."
	P.name = "Emergency Nuclear Code, and ERT Orders"
	for (var/obj/effect/landmark/A in world)
		if (A.name == "nukecode")
			P.loc = A.loc
			del(A)
			continue

/client/proc/create_response_team(obj/spawn_location, leader_selected = 0, commando_name)

	var/mob/living/carbon/human/M = new(null)
	response_team_members |= M

	var/new_facial = input("Please select facial hair color.", "Character Generation") as color
	if(new_facial)
		M.r_facial = hex2num(copytext(new_facial, 2, 4))
		M.g_facial = hex2num(copytext(new_facial, 4, 6))
		M.b_facial = hex2num(copytext(new_facial, 6, 8))

	var/new_hair = input("Please select hair color.", "Character Generation") as color
	if(new_facial)
		M.r_hair = hex2num(copytext(new_hair, 2, 4))
		M.g_hair = hex2num(copytext(new_hair, 4, 6))
		M.b_hair = hex2num(copytext(new_hair, 6, 8))

	var/new_eyes = input("Please select eye color.", "Character Generation") as color
	if(new_eyes)
		M.r_eyes = hex2num(copytext(new_eyes, 2, 4))
		M.g_eyes = hex2num(copytext(new_eyes, 4, 6))
		M.b_eyes = hex2num(copytext(new_eyes, 6, 8))

	var/new_tone = input("Please select skin tone level: 1-220 (1=albino, 35=caucasian, 150=black, 220='very' black)", "Character Generation")  as text

	if (!new_tone)
		new_tone = 35
	M.s_tone = max(min(round(text2num(new_tone)), 220), 1)
	M.s_tone =  -M.s_tone + 35

	// hair
	var/list/all_hairs = typesof(/datum/sprite_accessory/hair) - /datum/sprite_accessory/hair
	var/list/hairs = list()

	// loop through potential hairs
	for(var/x in all_hairs)
		var/datum/sprite_accessory/hair/H = new x // create new hair datum based on type x
		hairs.Add(H.name) // add hair name to hairs
		del(H) // delete the hair after it's all done

	var/new_style = input("Please select hair style", "Character Generation")  as null|anything in hairs

	// if new style selected (not cancel)
	if (new_style)
		M.h_style = new_style

		for(var/x in all_hairs) // loop through all_hairs again. Might be slightly CPU expensive, but not significantly.
			var/datum/sprite_accessory/hair/H = new x // create new hair datum
			if(H.name == new_style)
				M.hair_style = H // assign the hair_style variable a new hair datum
				break
			else
				del(H) // if hair H not used, delete. BYOND can garbage collect, but better safe than sorry

	// facial hair
	var/list/all_fhairs = typesof(/datum/sprite_accessory/facial_hair) - /datum/sprite_accessory/facial_hair
	var/list/fhairs = list()

	for(var/x in all_fhairs)
		var/datum/sprite_accessory/facial_hair/H = new x
		fhairs.Add(H.name)
		del(H)

	new_style = input("Please select facial style", "Character Generation")  as null|anything in fhairs

	if(new_style)
		M.f_style = new_style
		for(var/x in all_fhairs)
			var/datum/sprite_accessory/facial_hair/H = new x
			if(H.name == new_style)
				M.facial_hair_style = H
				break
			else
				del(H)

	var/new_gender = alert(usr, "Please select gender.", "Character Generation", "Male", "Female")
	if (new_gender)
		if(new_gender == "Male")
			M.gender = MALE
		else
			M.gender = FEMALE
	M.rebuild_appearance()

	M.real_name = commando_name
	M.name = commando_name
	M.age = !leader_selected ? rand(23,35) : rand(35,45)

	M.dna.ready_dna(M)//Creates DNA.

	//Creates mind stuff.
	M.mind = new
	M.mind.current = M
	M.mind.original = M
	M.mind.assigned_role = "MODE"
	M.mind.special_role = "Response Team"
	if(!(M.mind in ticker.minds))
		ticker.minds += M.mind//Adds them to regular mind list.
	M.loc = spawn_location.loc
	M.equip_strike_team(leader_selected)
	del(spawn_location)
	return M

/mob/living/carbon/human/proc/equip_strike_team(leader_selected = 0)

	//Special radio setup
	equip_if_possible(new /obj/item/device/radio/headset/ert(src), slot_ears)

	//Adding Camera Network
	var/obj/machinery/camera/camera = new /obj/machinery/camera(src) //Gives all the commandos internals cameras.
	camera.network = "CREED"
	camera.c_tag = real_name

	//Basic Uniform
	equip_if_possible(new /obj/item/clothing/under/syndicate/tacticool(src), slot_w_uniform)
	equip_if_possible(new /obj/item/device/flashlight(src), slot_l_store)
	equip_if_possible(new /obj/item/weapon/clipboard(src), slot_r_store)
	equip_if_possible(new /obj/item/weapon/gun/energy/gun(src), slot_belt)

	//Glasses
	equip_if_possible(new /obj/item/clothing/glasses/sunglasses/sechud(src), slot_glasses)

	//Shoes & gloves
	equip_if_possible(new /obj/item/clothing/shoes/swat(src), slot_shoes)
	equip_if_possible(new /obj/item/clothing/gloves/swat(src), slot_gloves)

	//Removed
//	equip_if_possible(new /obj/item/clothing/suit/armor/swat(src), slot_wear_suit)
//	equip_if_possible(new /obj/item/clothing/head/helmet/space/deathsquad(src), slot_head)
//	equip_if_possible(new /obj/item/clothing/mask/gas/swat(src), slot_wear_mask)

	//Backpack
	equip_if_possible(new /obj/item/weapon/storage/backpack/security(src), slot_back)
	equip_if_possible(new /obj/item/weapon/storage/box/engineer(src), slot_in_backpack)
	equip_if_possible(new /obj/item/weapon/storage/firstaid/regular(src), slot_in_backpack)

	var/obj/item/weapon/card/id/W = new(src)
	W.name = "[real_name]'s ID Card (Emergency Response Team)"
	W.icon_state = "centcom"
	if(leader_selected)
		W.name = "[real_name]'s ID Card (Emergency Response Team Leader)"
		W.access = get_access("Captain")
		W.access += list(access_cent_teleporter)
		W.assignment = "Emergency Response Team Leader"
	else
		W.access = get_access("Head of Personnel")
		W.assignment = "Emergency Response Team"
	W.access += list(access_cent_general, access_cent_specops, access_cent_living, access_cent_storage)//Let's add their alloted CentCom access.
	W.registered_name = real_name
	equip_if_possible(W, slot_wear_id)

	return 1