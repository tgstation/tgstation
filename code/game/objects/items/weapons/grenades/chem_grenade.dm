/obj/item/weapon/grenade/chem_grenade
	name = "Grenade Casing"
	icon_state = "chemg"
	icon = 'chemical.dmi'
	item_state = "flashbang"
	w_class = 2.0
	force = 2.0
	var/list/beakers = list()
	var/obj/item/device/assembly/attached_device
	var/exploding = 0
	var/state = 0
	var/path = 0
	var/motion = 0
	var/direct = "SOUTH"
	var/obj/item/weapon/circuitboard/circuit = null
	var/list/allowed_containers = list("/obj/item/weapon/reagent_containers/glass/beaker", "/obj/item/weapon/reagent_containers/glass/dispenser", "/obj/item/weapon/reagent_containers/glass/bottle")
	var/affected_area = 3
	var/mob/attacher = "Unknown"
	throw_speed = 4
	throw_range = 20
	flags = FPRINT | TABLEPASS | CONDUCT | USEDELAY
	slot_flags = SLOT_BELT

	attackby(var/obj/item/weapon/W, var/mob/user)
		if(path || !active)
			switch(active)
				if(0)
					if(istype(W, /obj/item/device/assembly/igniter))
						active = 1
						icon_state = initial(icon_state) +"_ass"
						name = "unsecured grenade"
						path = 1
						del(W)
				if(1)
					if(istype(W, /obj/item/weapon/reagent_containers/glass))
						if(beakers.len == 2)
							user << "\red There are already two beakers inside, remove one first!"
							return

						beakers |= W
						user.drop_item()
						W.loc = src
						user << "\blue You insert the beaker into the casing."

					else if(istype(W, /obj/item/device/assembly/signaler) || istype(W, /obj/item/device/assembly/timer) || istype(W, /obj/item/device/assembly/infra) || istype(W, /obj/item/device/assembly/prox_sensor))
						if(attached_device)
							user << "\red There is already an device attached to the controls, remove it first!"
							return

						attached_device = W
						user.drop_item()
						W.loc = src
						user << "\blue You attach the [W] to the grenade controls!"
						W.master = src
						bombers += "[key_name(user)] attached a [W] to a grenade casing."
						message_admins("[key_name_admin(user)] attached a [W] to a grenade casing.")
						log_game("[key_name_admin(user)] attached a [W] to a grenade casing.")
						attacher = key_name(user)

					else if(istype(W, /obj/item/weapon/screwdriver))
						if(beakers.len == 2 && attached_device)
							user << "\blue You lock the assembly."
							playsound(src.loc, 'Screwdriver.ogg', 25, -3)
							name = "grenade"
							icon_state = initial(icon_state) + "_locked"
							active = 2
							path = 1
						else
							user << "\red You need to add all components before locking the assembly."
				if(2)
					if(istype(W, /obj/item/weapon/screwdriver))
						user << "\blue You disarm the [src]!"
						playsound(src.loc, 'Screwdriver.ogg', 25, -3)
						name = "grenade casing"
						icon_state = initial(icon_state) +"_ass"
						active = 1
						path = 1

		if(path != 1)
			if(!istype(src.loc,/turf))
				user << "\red You need to put the canister on the ground to do that!"
			else
				switch(state)
					if(0)
						if(istype(W, /obj/item/weapon/wrench))
							playsound(src.loc, 'Ratchet.ogg', 50, 1)
							if(do_after(user, 20))
								user << "\blue You wrench the canister in place."
								src.name = "Camera Assembly"
								src.anchored = 1
								src.state = 1
								path = 2
					if(1)
						if(istype(W, /obj/item/weapon/wrench))
							playsound(src.loc, 'Ratchet.ogg', 50, 1)
							if(do_after(user, 20))
								user << "\blue You unfasten the canister."
								src.name = "Grenade Casing"
								src.anchored = 0
								src.state = 0
								path = 0
						if(istype(W, /obj/item/device/multitool))
							playsound(src.loc, 'Deconstruct.ogg', 50, 1)
							user << "\blue You place the electronics inside the canister."
							src.circuit = W
							user.drop_item()
							W.loc = src
						if(istype(W, /obj/item/weapon/screwdriver) && circuit)
							playsound(src.loc, 'Screwdriver.ogg', 50, 1)
							user << "\blue You screw the circuitry into place."
							src.state = 2
						if(istype(W, /obj/item/weapon/crowbar) && circuit)
							playsound(src.loc, 'Crowbar.ogg', 50, 1)
							user << "\blue You remove the circuitry."
							src.state = 1
							circuit.loc = src.loc
							src.circuit = null
					if(2)
						if(istype(W, /obj/item/weapon/screwdriver) && circuit)
							playsound(src.loc, 'Screwdriver.ogg', 50, 1)
							user << "\blue You unfasten the circuitry."
							src.state = 1
						if(istype(W, /obj/item/weapon/cable_coil))
							if(W:amount >= 1)
								playsound(src.loc, 'Deconstruct.ogg', 50, 1)
								if(do_after(user, 20))
									W:amount -= 1
									if(!W:amount) del(W)
									user << "\blue You add cabling to the canister."
									src.state = 3
					if(3)
						if(istype(W, /obj/item/weapon/wirecutters))
							playsound(src.loc, 'wirecutter.ogg', 50, 1)
							user << "\blue You remove the cabling."
							src.state = 2
							var/obj/item/weapon/cable_coil/A = new /obj/item/weapon/cable_coil( src.loc )
							A.amount = 1
						if(issignaler(W))
							playsound(src.loc, 'Deconstruct.ogg', 50, 1)
							user << "\blue You attach the wireless signaller unit to the circutry."
							user.drop_item()
							W.loc = src
							src.state = 4
					if(4)
						if(istype(W, /obj/item/weapon/crowbar) && !motion)
							playsound(src.loc, 'Crowbar.ogg', 50, 1)
							user << "\blue You remove the remote signalling device."
							src.state = 3
							var/obj/item/device/assembly/signaler/S = locate() in src
							if(S)
								S.loc = src.loc
							else
								new /obj/item/device/assembly/signaler( src.loc, 1 )
						if(isprox(W) && motion == 0)
//							if(W:amount >= 1)
							playsound(src.loc, 'Deconstruct.ogg', 50, 1)
//								W:use(1)
							user << "\blue You attach the proximity sensor."
							user.drop_item()
							W.loc = src
							motion = 1
						if(istype(W, /obj/item/weapon/crowbar) && motion)
							playsound(src.loc, 'Crowbar.ogg', 50, 1)
							user << "\blue You remove the proximity sensor."
							var/obj/item/device/assembly/prox_sensor/S = locate() in src
							if(S)
								S.loc = src.loc
							else
								new /obj/item/device/assembly/prox_sensor( src.loc, 1 )
							motion = 0
						if(istype(W, /obj/item/stack/sheet/glass))
							if(W:amount >= 1)
								playsound(src.loc, 'Deconstruct.ogg', 50, 1)
								if(do_after(user, 20))
									if(W)
										W:use(1)
										user << "\blue You put in the glass lens."
										src.state = 5
					if(5)
						if(istype(W, /obj/item/weapon/crowbar))
							playsound(src.loc, 'Crowbar.ogg', 50, 1)
							user << "\blue You remove the glass lens."
							src.state = 4
							new /obj/item/stack/sheet/glass( src.loc, 2 )
						if(istype(W, /obj/item/weapon/screwdriver))
							playsound(src.loc, 'Screwdriver.ogg', 50, 1)
							user << "\blue You connect the lense."
							var/B
							if(motion == 1)
								B = new /obj/machinery/camera/motion( src.loc )
							else
								B = new /obj/machinery/camera( src.loc )
							B:network = "SS13"
							B:network = input(usr, "Which network would you like to connect this camera to?", "Set Network", "SS13")
							direct = input(user, "Direction?", "Assembling Camera", null) in list( "NORTH", "EAST", "SOUTH", "WEST" )
							B:dir = text2dir(direct)
							del(src)
		return


	attack_self(mob/user as mob)
		if(active == 2)
			attached_device.attack_self(user)
			return
		user.machine = src
		var/dat = {"<B> Grenade properties: </B>
		<BR> <B> Beaker one:</B> [beakers[1]] [beakers[1] ? "<A href='?src=\ref[src];beakerone=1'>Remove</A>" : ""]
		<BR> <B> Beaker two:</B> [beakers[2]] [beakers[2] ? "<A href='?src=\ref[src];beakertwo=1'>Remove</A>" : ""]
		<BR> <B> Control attachment:</B> [attached_device ? "<A href='?src=\ref[src];device=1'>[attached_device]</A>" : "None"] [attached_device ? "<A href='?src=\ref[src];rem_device=1'>Remove</A>" : ""]"}

		user << browse(dat, "window=trans_valve;size=600x300")
		onclose(user, "trans_valve")
		return


	Topic(href, href_list)
		..()
		if (usr.stat || usr.restrained())
			return
		if (src.loc == usr)
			if(href_list["beakerone"])
				if(beakers.len < 1)
					return
				var/obj/b1 = beakers[1]
				b1.loc = get_turf(src)
				beakers.Remove(b1)
			if(href_list["beakertwo"])
				if(beakers.len < 2)
					return
				var/obj/b2 = beakers[2]
				b2.loc = get_turf(src)
				beakers.Remove(b2)
			if(href_list["rem_device"])
				attached_device.loc = get_turf(src)
				attached_device = null
			if(href_list["device"])
				attached_device.attack_self(usr)
			src.attack_self(usr)
			src.add_fingerprint(usr)
			return

	receive_signal(signal)
		if(!(active == 2))
			return	//cant go off before it gets primed
		explode()


	HasProximity(atom/movable/AM as mob|obj)
		if(istype(attached_device, /obj/item/device/assembly/prox_sensor))
			var/obj/item/device/assembly/prox_sensor/D = attached_device
			if (istype(AM, /obj/effect/beam))
				return
			if (AM.move_speed < 12)
				D.sense()


	proc/explode()
		if(exploding) return
		exploding = 1

		//if(prob(reliability))
		var/has_reagents = 0
		for(var/obj/item/weapon/reagent_containers/glass/G in beakers)
			if(G.reagents.total_volume)
				has_reagents = 1
				break

		active = 0
		if(!has_reagents)
			icon_state = initial(icon_state) +"_locked"
			playsound(src.loc, 'sound/items/Screwdriver2.ogg', 50, 1)
			return

		var/datum/reagents/R = new/datum/reagents(1000)
		reagents = R
		R.my_atom = src

		playsound(src.loc, 'sound/effects/bamf.ogg', 50, 1)

		for(var/obj/item/weapon/reagent_containers/glass/G in beakers)
			G.reagents.trans_to(src, G.reagents.total_volume)

		var/obj/item/weapon/reagent_containers/glass/G = locate() in beakers
		reagents.trans_to(G, reagents.total_volume/2)

		if(src.reagents.total_volume) //The possible reactions didnt use up all reagents.
			var/datum/effect/effect/system/steam_spread/steam = new /datum/effect/effect/system/steam_spread()
			steam.set_up(10, 0, get_turf(src))
			steam.attach(src)
			steam.start()

			for(var/atom/A in view(affected_area, src.loc))
				if( A == src ) continue
				src.reagents.reaction(A, 1, 10)

			for(var/atom/A in view(affected_area, src.loc))
				if( A == src ) continue
				G.reagents.reaction(A, 1, 10)


		invisibility = INVISIBILITY_MAXIMUM //Why am i doing this?
		spawn(50)		   //To make sure all reagents can work
			del(src)	   //correctly before deleting the grenade.
		/*else
			icon_state = initial(icon_state) + "_locked"
			crit_fail = 1
			for(var/obj/item/weapon/reagent_containers/glass/G in beakers)
				G.loc = get_turf(src.loc)*/

	proc/c_state(var/i = 0)
		if(i)
			icon_state = initial(icon_state) + "_armed"
		else
			icon_state = initial(icon_state) + "_locked"
		return


/obj/item/weapon/grenade/chem_grenade/large
	name = "Large Chem Grenade"
	desc = "An oversized grenade that affects a larger area."
	icon_state = "large_grenade"
	allowed_containers = list("/obj/item/weapon/reagent_containers/glass")
	origin_tech = "combat=3;materials=3"
	affected_area = 4

/obj/item/weapon/grenade/chem_grenade/metalfoam
	name = "Metal-Foam Grenade"
	desc = "Used for emergency sealing of air breaches."
	path = 1
	active = 2

	New()
		..()
		attached_device = new /obj/item/device/assembly/timer(src)
		attached_device.master = src
		attached_device.toggle_secure()
		var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
		var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)

		B1.reagents.add_reagent("aluminum", 30)
		B2.reagents.add_reagent("foaming_agent", 10)
		B2.reagents.add_reagent("pacid", 10)

		beakers.Add(B1, B2)
		icon_state = "chemg_locked"

/obj/item/weapon/grenade/chem_grenade/incendiary
	name = "Incendiary Grenade"
	desc = "Used for clearing rooms of living things."
	path = 1
	active = 2

	New()
		..()
		attached_device = new /obj/item/device/assembly/timer(src)
		attached_device.master = src
		attached_device.toggle_secure()
		var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
		var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)

		B1.reagents.add_reagent("aluminum", 25)
		B2.reagents.add_reagent("plasma", 25)
		B2.reagents.add_reagent("acid", 25)

		beakers.Add(B1, B2)
		icon_state = "chemg_locked"

/obj/item/weapon/grenade/chem_grenade/cleaner
	name = "Cleaner Grenade"
	desc = "BLAM!-brand foaming space cleaner. In a special applicator for rapid cleaning of wide areas."
	active = 2
	path = 1

	New()
		..()
		attached_device = new /obj/item/device/assembly/timer(src)
		attached_device.master = src
		attached_device.toggle_secure()
		var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
		var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)

		B1.reagents.add_reagent("fluorosurfactant", 40)
		B2.reagents.add_reagent("water", 40)
		B2.reagents.add_reagent("cleaner", 10)

		beakers.Add(B1, B2)
		icon_state = "chemg_locked"