/obj/item/weapon/grenade/chem_grenade
	name = "Grenade Casing"
	icon_state = "chemg"
	item_state = "flashbang"
	desc = "A hand made chemical grenade."
	w_class = 2.0
	force = 2.0
	var/stage = 0
	var/state = 0
	var/path = 0
	var/obj/item/device/assembly_holder/detonator = null
	var/list/beakers = new/list()
	var/list/allowed_containers = list(/obj/item/weapon/reagent_containers/glass/beaker, /obj/item/weapon/reagent_containers/glass/bottle)
	var/affected_area = 3

	New()
		var/datum/reagents/R = new/datum/reagents(1000)
		reagents = R
		R.my_atom = src

	attack_self(mob/user as mob)
		if(!stage || stage==1)
			if(detonator)
//				detonator.loc=src.loc
				usr.put_in_hands(detonator)
				detonator=null
				stage=0
				icon_state = initial(icon_state)
			else if(beakers.len)
				for(var/obj/B in beakers)
					if(istype(B))
						beakers -= B
						user.put_in_hands(B)
			name = "unsecured grenade with [beakers.len] containers[stage?" and detonator":""]"
		if(stage > 1 && !active && clown_check(user))
			user << "<span class='warning'>You prime \the [name]!</span>"

			log_attack("<font color='red'>[user.name] ([user.ckey]) primed \a [src].</font>")
			log_admin("ATTACK: [user] ([user.ckey]) primed \a [src].")
			message_admins("ATTACK: [user] ([user.ckey]) primed \a [src].")

			activate()
			add_fingerprint(user)
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.throw_mode_on()

	attackby(obj/item/weapon/W as obj, mob/user as mob)//TODO:Have grenades use the new assembly things

		if(istype(W,/obj/item/device/assembly_holder) && (!stage || stage==1) && path != 2)
			var/obj/item/device/assembly_holder/det = W
			if(istype(det.a_left,det.a_right.type) || (!isigniter(det.a_left) && !isigniter(det.a_right)))
				user << "\red Assembly must contain one igniter."
				return
			if(!det.secured)	
				user << "\red Assembly must be secured with screwdriver."
				return
			path = 1
			user << "\blue You add [W] to the metal casing."
			playsound(src.loc, 'sound/items/Screwdriver2.ogg', 25, -3)
			user.remove_from_mob(det)
			det.loc = src
			detonator = det
			icon_state = initial(icon_state) +"_ass"
			name = "unsecured grenade with [beakers.len] containers[stage?" and detonator":""]"
			stage = 1
		else if(istype(W,/obj/item/weapon/screwdriver) && path != 2)
			if(stage == 1)
				path = 1
				if(beakers.len)
					user << "\blue You lock the assembly."
					playsound(src.loc, 'sound/items/Screwdriver.ogg', 25, -3)
					name = "grenade"
					icon_state = initial(icon_state) +"_locked"
					stage = 2
				else
//					user << "\red You need to add at least one beaker before locking the assembly."
					user << "\blue You lock the empty assembly."
					playsound(src.loc, 'sound/items/Screwdriver.ogg', 25, -3)
					name = "fake grenade"
					icon_state = initial(icon_state) +"_locked"
					stage = 2
			else if(stage == 2)
				user << "\blue You unlock the assembly."
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 25, -3)
				name = "unsecured grenade with [beakers.len] containers[stage?" and detonator":""]"
				icon_state = initial(icon_state) + (detonator?"_ass":"")
				stage = 1
				active = 0
		else if(is_type_in_list(W, allowed_containers) && (!stage || stage==1) && path != 2)
			path = 1
			if(beakers.len == 2)
				user << "\red The grenade can not hold more containers."
				return
			else
				if(W.reagents.total_volume)
					user << "\blue You add \the [W] to the assembly."
					user.drop_item()
					W.loc = src
					beakers += W
					stage = 1
					name = "unsecured grenade with [beakers.len] containers[stage?" and detonator":""]"
				else
					user << "\red \the [W] is empty."

	examine()
		set src in usr
		usr << desc
		if(detonator)
			usr << "With attached [detonator.name]"

	activate()
		if(active) return
		if(detonator)
			if(!isigniter(detonator.a_left))
				detonator.a_left.activate()
				active = 1
			if(!isigniter(detonator.a_right))
				detonator.a_right.activate()
				active = 1
		if(active)
			icon_state = initial(icon_state) + "_active"

		return

	proc/primed(var/primed = 1)
		if(active)
			icon_state = initial(icon_state) + (primed?"_primed":"_active")

	prime()
		if(!stage || stage<2) return

		//if(prob(reliability))
		var/has_reagents = 0
		for(var/obj/item/weapon/reagent_containers/glass/G in beakers)
			if(G.reagents.total_volume) has_reagents = 1

		active = 0
		if(!has_reagents)
			icon_state = initial(icon_state) +"_locked"
			playsound(src.loc, 'sound/items/Screwdriver2.ogg', 50, 1)
			return

		playsound(src.loc, 'sound/effects/bamf.ogg', 50, 1)

		for(var/obj/item/weapon/reagent_containers/glass/G in beakers)
			G.reagents.trans_to(src, G.reagents.total_volume)

		if(src.reagents.total_volume) //The possible reactions didnt use up all reagents.
			var/datum/effect/effect/system/steam_spread/steam = new /datum/effect/effect/system/steam_spread()
			steam.set_up(10, 0, get_turf(src))
			steam.attach(src)
			steam.start()

			for(var/atom/A in view(affected_area, src.loc))
				if( A == src ) continue
				src.reagents.reaction(A, 1, 10)


		invisibility = INVISIBILITY_MAXIMUM //Why am i doing this?
		spawn(50)		   //To make sure all reagents can work
			del(src)	   //correctly before deleting the grenade.
		/*else
			icon_state = initial(icon_state) + "_locked"
			crit_fail = 1
			for(var/obj/item/weapon/reagent_containers/glass/G in beakers)
				G.loc = get_turf(src.loc)*/


/obj/item/weapon/grenade/chem_grenade/large
	name = "Large Chem Grenade"
	desc = "An oversized grenade that affects a larger area."
	icon_state = "large_grenade"
	allowed_containers = list(/obj/item/weapon/reagent_containers/glass)
	origin_tech = "combat=3;materials=3"
	affected_area = 4

/obj/item/weapon/grenade/chem_grenade/metalfoam
	name = "Metal-Foam Grenade"
	desc = "Used for emergency sealing of air breaches."
	path = 1
	stage = 2

	New()
		..()
		var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
		var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)

		B1.reagents.add_reagent("aluminum", 30)
		B2.reagents.add_reagent("foaming_agent", 10)
		B2.reagents.add_reagent("pacid", 10)

		beakers += B1
		beakers += B2
		icon_state = "grenade"

/obj/item/weapon/grenade/chem_grenade/incendiary
	name = "Incendiary Grenade"
	desc = "Used for clearing rooms of living things."
	path = 1
	stage = 2

	New()
		..()
		var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
		var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)

		B1.reagents.add_reagent("aluminum", 25)
		B2.reagents.add_reagent("plasma", 25)
		B2.reagents.add_reagent("sacid", 25)

		beakers += B1
		beakers += B2
		icon_state = "grenade"

/obj/item/weapon/grenade/chem_grenade/cleaner
	name = "Cleaner Grenade"
	desc = "BLAM!-brand foaming space cleaner. In a special applicator for rapid cleaning of wide areas."
	stage = 2
	path = 1

	New()
		..()
		var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
		var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)

		B1.reagents.add_reagent("fluorosurfactant", 40)
		B2.reagents.add_reagent("water", 40)
		B2.reagents.add_reagent("cleaner", 10)

		beakers += B1
		beakers += B2
		icon_state = "grenade"
