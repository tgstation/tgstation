/*

CONTAINS:
Weed-B-Gone
Nettle
Deathnettle

*/
/obj/item/weapon/weedbgone/New()
	var/datum/reagents/R = new/datum/reagents(100) // 100 units of solution
	reagents = R
	R.my_atom = src
	R.add_reagent("weedbgone", 100)

/obj/item/weapon/weedbgone/attack(mob/living/carbon/human/M as mob, mob/user as mob)
	return

/obj/item/weapon/weedbgone/afterattack(atom/A as mob|obj, mob/user as mob)
	if (src.reagents.total_volume < 1)
		user << "\blue Add more Weed-B-Gone mixture!"
		return

	else if (istype(A, /obj/machinery/hydroponics)) // We are targeting hydrotray
	/*  Gotta figure out how to make this work, chemical sprite doesn't appear.
		var/obj/decal/spraystill/D = new /obj/decal/spraystill( src ) // new decal at tray location
		D.name = "chemicals"
		D.icon = 'chemical.dmi'
		D.icon_state = "weedpuff"

		spawn(0) // spawn on top of tray
		sleep(3)
		del(D)

		*/
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
			for(var/i=0, i<2, i++) // Max range = 2 tiles
				step_towards(D,A) // Moves towards target as normally (not thru walls)
				D.reagents.reaction(get_turf(D))
				for(var/atom/T in get_turf(D))
					D.reagents.reaction(T)
				sleep(4)
			del(D)

		return

/obj/item/weapon/weedbgone/examine()
	set src in usr
	usr << text("\icon[] [] units of Weed-B-Gone left!", src, src.reagents.total_volume)
	..()
	return
