/*
/datum/game_mode/ctf
	name = "ctf"
	config_tag = "ctf"

/datum/game_mode/ctf/announce()
	world << "<B>The current game mode is - Capture the Flag!</B>"
	world << "<B>Capture the other teams flag and bring it back to your base!</B>"
	world << "Respawn is on"

/datum/game_mode/ctf/pre_setup()

	config.allow_ai = 0
	var/list/mobs = list()
	var/total_mobs
	for(var/mob/living/carbon/human/M in world)
		if (M.client)
			mobs += M
			total_mobs++

	var/obj/R = locate("landmark*Red-Spawn")
	var/obj/G = locate("landmark*Green-Spawn")

	var/mob_check
	for(var/mob/living/carbon/human/M in mobs)
		if(!M)
			continue
		mob_check++
		if(mob_check <= total_mobs/2) //add to red team else to green
			spawn()
				if(M.client)
					M << "You are in the Red Team!"
					del(M.wear_suit)
					M.w_uniform = new /obj/item/clothing/under/color/red(M)
					M.w_uniform.layer = 20
					del(M.shoes)
					M.wear_suit = new /obj/item/clothing/suit/armor/tdome/red(M)
					M.wear_suit.layer = 20
					M.shoes = new /obj/item/clothing/shoes/black(M)
					M.shoes.layer = 20
					M.wear_mask = new /obj/item/clothing/mask/gas/emergency(M)
					M.wear_mask.layer = 20
					M.gloves = new /obj/item/clothing/gloves/swat(M)
					M.gloves.layer = 20
					M.glasses = new /obj/item/clothing/glasses/thermal(M)
					M.glasses.layer = 20
					var/obj/item/device/radio/headset/H = new /obj/item/device/radio/headset(M)
					H.set_frequency(1465)
					M.w_radio = H
					M.w_radio.layer = 20
					var/obj/item/weapon/tank/air/O = new /obj/item/weapon/tank/air(M)
					M.back = O
					M.back.layer = 20
					M.internal = O

					del(M.wear_id)
					var/obj/item/weapon/card/id/W = new(M)
					W.name = "[M.real_name]'s ID card (Red Team)"
					W.access = access_red
					W.assignment = "Red Team"
					W.registered_name = M.real_name
					M.wear_id = W
					M.wear_id.layer = 20
					if(R)
						M.loc = R.loc
					else
						world << "No red team spawn point detected"
					M.client.team = "Red"
		else
			spawn()
				if(M.client)
					M << "You are in the Green Team!"
					del(M.wear_suit)
					M.w_uniform = new /obj/item/clothing/under/color/green(M)
					M.w_uniform.layer = 20
					del(M.shoes)
					M.wear_suit = new /obj/item/clothing/suit/armor/tdome/green(M)
					M.wear_suit.layer = 20
					M.shoes = new /obj/item/clothing/shoes/black(M)
					M.shoes.layer = 20
					M.wear_mask = new /obj/item/clothing/mask/gas/emergency(M)
					M.wear_mask.layer = 20
					M.gloves = new /obj/item/clothing/gloves/swat(M)
					M.gloves.layer = 20
					M.glasses = new /obj/item/clothing/glasses/thermal(M)
					M.glasses.layer = 20
					var/obj/item/device/radio/headset/H = new /obj/item/device/radio/headset(M)
					H.set_frequency(1449)
					M.w_radio = H
					M.w_radio.layer = 20
					var/obj/item/weapon/tank/air/O = new /obj/item/weapon/tank/air(M)
					M.back = O
					M.back.layer = 20
					M.internal = O

					del(M.wear_id)
					var/obj/item/weapon/card/id/W = new(M)
					W.name = "[M.real_name]'s ID card (Green Team)"
					W.access = access_green
					W.assignment = "Green Team"
					W.registered_name = M.real_name
					M.wear_id = W
					M.wear_id.layer = 20
					if(G)
						M.loc = G.loc
					else
						world << "No green team spawn point detected"
					M.client.team = "Green"


/datum/game_mode/ctf/post_setup()
	abandon_allowed = 1
	setup_game()

	spawn (50)
		var/obj/L = locate("landmark*Red-Flag")
		if (L)
			new /obj/item/weapon/ctf_flag/red(L.loc)
		else
			world << "No red flag spawn point detected"

		L = locate("landmark*Green-Flag")
		if (L)
			new /obj/item/weapon/ctf_flag/green(L.loc)
		else
			world << "No green flag spawn point detected"

		L = locate("landmark*The-Red-Team")
		if (L)
			new /obj/machinery/red_injector(L.loc)
		else
			world << "No red team spawn injector point detected"

		L = locate("landmark*The-Green-Team")
		if (L)
			new /obj/machinery/green_injector(L.loc)
		else
			world << "No green team injector spawn point detected"
	..()

*/