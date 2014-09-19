/obj/item/weapon/grenade/clown_grenade
	name = "Banana Grenade"
	desc = "HONK! brand Bananas. In a special applicator for rapid slipping of wide areas."
	icon_state = "chemg"
	item_state = "flashbang"
	w_class = 2.0
	force = 2.0
	var/stage = 0
	var/state = 0
	var/path = 0
	var/affected_area = 2

	New()
		icon_state = initial(icon_state) +"_locked"

	prime()
		..()
		playsound(get_turf(src), 'sound/items/bikehorn.ogg', 25, -3)
		/*
		for(var/turf/simulated/floor/T in view(affected_area, src.loc))
			if(prob(75))
				banana(T)
		*/
		var/i = 0
		var/number = 0
		for(var/direction in alldirs)
			for(i = 0; i < 2; i++)
				number++
				var/obj/item/weapon/bananapeel/traitorpeel/peel = new /obj/item/weapon/bananapeel/traitorpeel(get_turf(src.loc))
			/*	var/direction = pick(alldirs)
				var/spaces = pick(1;150, 2)
				var/a = 0
				for(a = 0; a < spaces; a++)
					step(peel,direction)*/
				var/a = 1
				if(number & 2)
					for(a = 1; a <= 2; a++)
						step(peel,direction)
				else
					step(peel,direction)
		new /obj/item/weapon/bananapeel/traitorpeel(get_turf(src.loc))
		del(src)
		return
/*
	proc/banana(turf/T as turf)
		if(!T || !istype(T))
			return
		if(locate(/obj/structure/grille) in T)
			return
		if(locate(/obj/structure/window) in T)
			return
		new /obj/item/weapon/bananapeel/traitorpeel(T)
*/

/obj/item/weapon/bananapeel/traitorpeel
	name = "banana peel"
	desc = "A peel from a banana."
	icon = 'icons/obj/items.dmi'
	icon_state = "banana_peel"
	item_state = "banana_peel"
	w_class = 1.0
	throwforce = 0
	throw_speed = 4
	throw_range = 20

	Crossed(AM as mob|obj)
		var/burned = rand(2,5)
		if(istype(AM, /mob/living))
			var/mob/living/M = AM
			if(ishuman(M))
				if(isobj(M:shoes))
					if(M:shoes.flags&NOSLIP)
						return
				else
					M << "\red Your feet feel like they're on fire!"
					M.take_overall_damage(0, max(0, (burned - 2)))

			if(!istype(M, /mob/living/carbon/slime) && !isrobot(M))
				M.stop_pulling()
				step(M, M.dir)
				spawn(1) step(M, M.dir)
				spawn(2) step(M, M.dir)
				spawn(3) step(M, M.dir)
				spawn(4) step(M, M.dir)
				M.take_organ_damage(2) // Was 5 -- TLE
				M << "\blue You slipped on \the [name]!"
				playsound(get_turf(src), 'sound/misc/slip.ogg', 50, 1, -3)
				M.Weaken(10)
				M.take_overall_damage(0, burned)

	throw_impact(atom/hit_atom)
		var/burned = rand(1,3)
		if(istype(hit_atom ,/mob/living))
			var/mob/living/M = hit_atom
			M.take_organ_damage(0, burned)
		return ..()