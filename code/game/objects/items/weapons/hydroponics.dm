/*

CONTAINS:
Plant-B-Gone
Nettle
Deathnettle
Craftables (Cob pipes, potato batteries, pumpkinheads)

*/


// Plant-B-Gone
/obj/item/weapon/plantbgone/New()
	var/datum/reagents/R = new/datum/reagents(100) // 100 units of solution
	reagents = R
	R.my_atom = src
	R.add_reagent("plantbgone", 100)

/obj/item/weapon/plantbgone/attack(mob/living/carbon/human/M as mob, mob/user as mob)
	return

/obj/item/weapon/plantbgone/afterattack(atom/A as mob|obj, mob/user as mob)

	if (istype(A, /obj/item/weapon/storage/backpack ))
		return

	else if (locate (/obj/structure/table, src.loc))
		return

	else if (src.reagents.total_volume < 1)
		src.empty = 1
		user << "\blue Add more Plant-B-Gone mixture!"
		return

	else
		src.empty = 0

		if (istype(A, /obj/machinery/hydroponics)) // We are targeting hydrotray
			return

		else if (istype(A, /obj/effect/blob)) // blob damage in blob code
			return

		else
			var/obj/effect/decal/D = new/obj/effect/decal/(get_turf(src)) // Targeting elsewhere
			D.name = "chemicals"
			D.icon = 'chemical.dmi'
			D.icon_state = "weedpuff"
			D.create_reagents(5)
			src.reagents.trans_to(D, 5) // 5 units of solution used at a time => 20 uses
			playsound(src.loc, 'spray3.ogg', 50, 1, -6)

			spawn(0)
				for(var/i=0, i<3, i++) // Max range = 3 tiles
					step_towards(D,A) // Moves towards target as normally (not thru walls)
					D.reagents.reaction(get_turf(D))
					for(var/atom/T in get_turf(D))
						D.reagents.reaction(T)
					sleep(4)
				del(D)


			if((src.reagents.has_reagent("pacid")) || (src.reagents.has_reagent("lube"))) 	   				// Messages admins if someone sprays polyacid or space lube from a Plant-B-Gone bottle.
				message_admins("[key_name_admin(user)] fired Polyacid/Space lube from a PlantBGone bottle.")		// Polymorph
				log_game("[key_name(user)] fired Polyacid/Space lube from a PlantBGone bottle.")


			return

/obj/item/weapon/plantbgone/examine()
	set src in usr
	usr << text("\icon[] [] units of Plant-B-Gone left!", src, src.reagents.total_volume)
	..()
	return

// Sunflower
/obj/item/weapon/grown/sunflower/attack(mob/M as mob, mob/user as mob)
	M << "<font color='green'><b> [user] smacks you with a sunflower!</font><font color='yellow'><b>FLOWER POWER<b></font>"
	user << "<font color='green'> Your sunflower's </font><font color='yellow'><b>FLOWER POWER</b></font><font color='green'> strikes [M]</font>"

// Nettle

/obj/item/weapon/grown/nettle/pickup(mob/living/carbon/human/user as mob)
	if(!user.gloves)
		user << "\red The nettle burns your bare hand!"
		if(hasorgans(user))
			var/organ = ((user.hand ? "l_":"r_") + "arm")
			var/datum/organ/external/affecting = user:get_organ(organ)
			affecting.take_damage(0,force)
		else
			user.take_organ_damage(0,force)

/obj/item/weapon/grown/nettle/afterattack(atom/A as mob|obj, mob/user as mob)
	if(force > 0)
		force -= rand(1,(force/3)+1) // When you whack someone with it, leaves fall off
	else
		usr << "All the leaves have fallen off the nettle from violent whacking."
		del(src)


// Deathnettle

/obj/item/weapon/grown/deathnettle/pickup(mob/living/carbon/human/user as mob)
	if(!user.gloves)
		if(hasorgans(user))
			var/organ = ((user.hand ? "l_":"r_") + "arm")
			var/datum/organ/external/affecting = user:get_organ(organ)
			affecting.take_damage(0,force)
		else
			user.take_organ_damage(0,force)
		if(prob(50))
			user.Paralyse(5)
			user << "\red You are stunned by the Deathnettle when you try picking it up!"

/obj/item/weapon/grown/deathnettle/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(!..()) return
	if(istype(M, /mob/living))
		M << "\red You are stunned by the powerful acid of the Deathnettle!"
		M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Had the [src.name] used on them by [user.name] ([user.ckey])</font>")
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] on [M.name] ([M.ckey])</font>")

		log_admin("ATTACK: [user] ([user.ckey]) attacked [M] ([M.ckey]) with [src].")
		message_admins("ATTACK: [user] ([user.ckey]) attacked [M] ([M.ckey]) with [src].")
		log_attack("<font color='red'> [user.name] ([user.ckey]) used the [src.name] on [M.name] ([M.ckey])</font>")

		M.eye_blurry += force/7
		if(prob(20))
			M.Paralyse(force/6)
			M.Weaken(force/15)
		M.drop_item()

/obj/item/weapon/grown/deathnettle/afterattack(atom/A as mob|obj, mob/user as mob)
	if (force > 0)
		force -= rand(1,(force/3)+1) // When you whack someone with it, leaves fall off

	else
		usr << "All the leaves have fallen off the deathnettle from violent whacking."
		del(src)

//Crafting

/obj/item/weapon/corncob/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if(istype(W, /obj/item/weapon/circular_saw) || istype(W, /obj/item/weapon/hatchet) || istype(W, /obj/item/weapon/kitchen/utensil/knife))
		user << "<span class='notice'>You use [W] to fashion a pipe out of the corn cob!</span>"
		new /obj/item/clothing/mask/pipe/cobpipe (user.loc)
		del(src)
		return

/obj/item/weapon/reagent_containers/food/snacks/grown/pumpkin/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if(istype(W, /obj/item/weapon/circular_saw) || istype(W, /obj/item/weapon/hatchet) || istype(W, /obj/item/weapon/fireaxe) || istype(W, /obj/item/weapon/kitchen/utensil/knife) || istype(W, /obj/item/weapon/melee/energy))
		user.show_message("<span class='notice'>You carve a face into [src]!</span>", 1)
		new /obj/item/clothing/head/helmet/hardhat/pumpkinhead (user.loc)
		del(src)
		return

/obj/item/weapon/reagent_containers/food/snacks/grown/potato/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if(istype(W, /obj/item/weapon/cable_coil))
		if(W:amount >= 5)
			W:amount -= 5
			if(!W:amount) del(W)
			user << "<span class='notice'>You add some cable to the potato and slide it inside the battery encasing.</span>"
			new /obj/item/weapon/cell/potato(user.loc)
			del(src)
			return