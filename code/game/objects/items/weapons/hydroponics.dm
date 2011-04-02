/*

CONTAINS:
Plant-B-Gone
Nettle
Deathnettle

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

	else if (locate (/obj/table, src.loc))
		return

	else if (src.reagents.total_volume < 1)
		src.empty = 1
		user << "\blue Add more Plant-B-Gone mixture!"
		return

	else
		src.empty = 0

		if (istype(A, /obj/machinery/hydroponics)) // We are targeting hydrotray
			return

		else if (istype(A, /obj/blob)) // blob damage in blob code
			return

		else
			var/obj/decal/D = new/obj/decal/(get_turf(src)) // Targeting elsewhere
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

			return

/obj/item/weapon/plantbgone/examine()
	set src in usr
	usr << text("\icon[] [] units of Plant-B-Gone left!", src, src.reagents.total_volume)
	..()
	return


// Nettle

/obj/item/weapon/grown/nettle/pickup(mob/living/carbon/human/user as mob)
	if(!user.gloves)
		user << "\red The nettle burns your bare hand!"
		user.fireloss += force

/obj/item/weapon/grown/nettle/afterattack(atom/A as mob|obj, mob/user as mob)
	if (force > 0)
		force -= rand(1,(force/3)+1) // When you whack someone with it, leaves fall off
	else
		usr << "All the leaves have fallen off the nettle from violent whacking."
		del(src)


// Deathnettle

/obj/item/weapon/grown/deathnettle/pickup(mob/living/carbon/human/user as mob)
	if(!user.gloves)
		user.fireloss += force
		if(prob(50))
			user.paralysis += 5
			user << "\red You are stunned by the Deathnettle when you try picking it up!"

/obj/item/weapon/grown/deathnettle/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(!..()) return
	if(istype(M, /mob/living/carbon/human))
		M << "\red You are stunned by the powerful acid of the Deathnettle!"
		M.eye_blurry += 4
		if(prob(20))
			M.paralysis += 5
			M.weakened += 2
		M.drop_item()


/obj/item/weapon/grown/deathnettle/afterattack(atom/A as mob|obj, mob/user as mob)
	if (force > 0)
		force -= rand(1,(force/3)+1) // When you whack someone with it, leaves fall off

	else
		usr << "All the leaves have fallen off the deathnettle from violent whacking."
		del(src)
