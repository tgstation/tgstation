//SPACE NINJAS=============================
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