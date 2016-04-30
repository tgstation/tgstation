/obj/structure/russian_portal
	name = "jury-rigged portal"
	desc = "A damaged alien gateway hooked up to an experimental plasma engine."
	icon = 'icons/effects/96x96.dmi'
	icon_state = "door"
	anchored = 1
	density = 1
	bound_width = 96
	bound_height = 96
	burn_state = LAVA_PROOF
	luminosity = 1
	var/points = 0

/obj/structure/russian_portal/attackby(obj/item/I, mob/user, params)
	..()
	if(istype(I, /obj/item/stack/sheet/mineral/plasma))
		var/obj/item/stack/sheet/mineral/plasma/P = I
		points += P.amount
		user << "You feed [P.amount] sheets into the machine. It now has [points] sheets of plasma fueling it."
		qdel(P)



/obj/structure/russian_portal/proc/select_reinforcement(mob/user)
	var/selection = input(user, "Request Reinforcements", "Portal") as null|anything in list("Prisoner (4)", "Conscript (8)", "Spetsnaz (20)", "Commissar (20)", "Spare Ammo (10)", "Medical Supplies (10)")
	if(!selection || !Adjacent(user))
		return
	switch(selection)
		if("Prisoner (4)")
			if(points >= 4)
				points -= 4
				new /obj/effect/mob_spawn/human/prisoner_transport/russian(src)
			else
				user << "Not enough points!"

		if("Conscript (8)")
			if(points >= 8)
				points -= 8
				new /obj/effect/mob_spawn/human/corpse/russian/invasion(src)
			else
				user << "Not enough points!"

		if("Bear Cavalry (5)")
			if(points >= 5)
				points -= 5
				new /obj/effect/mob_spawn/bear(src)
			else
				user << "Not enough points!"

		if("Spetsnaz (20)")
			if(points >= 8)
				points -= 8
				new /obj/effect/mob_spawn/human/corpse/russian/ranged/trooper/invasion(src)
			else
				user << "Not enough points!"

		if("Commissar (25)")
			if(points >= 20)
				points -= 20
				new /obj/effect/mob_spawn/human/corpse/russian/ranged/officer/invasion(src)
			else
				user << "Not enough points!"

		if("Spare Ammo (7)")
			if(points >= 7)
				points -= 7
				new /obj/item/ammo_box/a762(loc)
				new /obj/item/ammo_box/a762(loc)
				new /obj/item/ammo_box/a762(loc)
				new /obj/item/ammo_box/a762(loc)
				new /obj/item/ammo_box/magazine/pistolm9mm(loc)
				new /obj/item/ammo_box/magazine/pistolm9mm(loc)
			else
				user << "Not enough points!"
		if("Medical Supplies (10)")
			if(points >= 10)
				points -=10
				new /obj/item/weapon/storage/firstaid/regular(loc)
				new /obj/item/weapon/storage/firstaid/regular(loc)
			else
				user << "Not enough points!"




/obj/structure/russian_portal/attack_hand(mob/user)
	if(..())
		return
	select_reinforcement(user)

/obj/structure/russian_portal/attack_ghost(mob/user)
	var/list/possible_spawns = list()
	for(var/obj/effect/mob_spawn/human/Z in contents)
		possible_spawns += Z.name

	if(!possible_spawns.len)
		user << "No reinforcements have been requisitioned!"


	var/choice = input(user,"What type of reinforcement would you like to spawn as?","Pick Reinforcement") as null|anything in possible_spawns

	for(var/obj/effect/mob_spawn/human/Z in contents)
		if(Z.name == choice)
			Z.attack_ghost(user)
			return
	user << "No reinforcements of that type are still available!"


//Reinforcments

/obj/effect/mob_spawn/human/prisoner_transport/russian
	name = "prisoner"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeper"
	uniform = /obj/item/clothing/under/rank/prisoner
	mask = /obj/item/clothing/mask/breath
	shoes = /obj/item/clothing/shoes/sneakers/orange
	pocket1 = /obj/item/weapon/tank/internals/emergency_oxygen
	roundstart = FALSE
	death = FALSE
	flavour_text = {"You are a prisoner, working to supply a secret Russian military operation. Working hard enough may earn you a pardon, but there are always more underhanded ways to earn your freedom..."}

/obj/effect/mob_spawn/human/corpse/russian/invasion
	name = "conscript"
	r_hand = /obj/item/weapon/gun/projectile/shotgun/boltaction
	l_hand = /obj/item/ammo_box/a762
	uniform = /obj/item/clothing/under/soviet
	helmet = /obj/item/clothing/head/ushanka
	shoes = /obj/item/clothing/shoes/jackboots
	helmet = /obj/item/clothing/head/bearpelt
	pocket1 = /obj/item/weapon/tank/internals/emergency_oxygen
	mask = /obj/item/clothing/mask/breath
	roundstart = FALSE
	death = FALSE
	flavour_text = {"You are a Russian conscript serving in a secret military operation. Follow the orders of your mission commander."}

/obj/effect/mob_spawn/human/corpse/russian/ranged/trooper/invasion
	name = "spetsnaz"
	l_hand = /obj/item/weapon/gun/projectile/automatic/pistol/APS
	r_hand = /obj/item/ammo_box/magazine/pistolm9mm
	uniform = /obj/item/clothing/under/syndicate/camo
	suit = /obj/item/clothing/suit/armor/bulletproof
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	mask = /obj/item/clothing/mask/balaclava
	helmet = /obj/item/clothing/head/helmet/alt
	pocket1 = /obj/item/weapon/tank/internals/emergency_oxygen
	pocket2 = /obj/item/clothing/mask/breath
	roundstart = FALSE
	death = FALSE
	flavour_text = {"You are an elite Russian soldier serving in a secret military operation. Follow the orders of your mission commander."}

/obj/effect/mob_spawn/human/corpse/russian/ranged/officer/invasion
	name = "commissar"
	uniform = /obj/item/clothing/under/rank/security/navyblue/russian
	l_hand = /obj/item/weapon/gun/projectile/automatic/pistol/APS
	suit = /obj/item/clothing/suit/security/officer/russian
	shoes = /obj/item/clothing/shoes/laceup
	helmet = /obj/item/clothing/head/ushanka
	pocket1 = /obj/item/weapon/tank/internals/emergency_oxygen
	mask = /obj/item/clothing/mask/breath
	pocket2 = /obj/item/ammo_box/magazine/pistolm9mm
	roundstart = FALSE
	death = FALSE
	flavour_text = {"You are a Russian officer serving in a secret military operation. Follow the orders of your mission commander. Ensure the loyalty of the conscripts and prisoners, by force if need be."}

/obj/effect/mob_spawn/bear
	name = "bear cavalry"
	mob_type = 	/mob/living/simple_animal/hostile/bear
	death = FALSE
	roundstart = FALSE
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeper"
	flavour_text = {"You are a bear. Roar! Help your russian allies on their secret military mission."}