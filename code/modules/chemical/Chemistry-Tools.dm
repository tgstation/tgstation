
//BUG!!!: reactions on splashing etc cause errors because stuff gets deleted before it executes.
//		  Bandaid fix using spawn - very ugly, need to fix this.

///////////////////////////////Grenades
//Includes changes by Mord_Sith to allow for buildable cameras
/obj/item/weapon/chem_grenade
	name = "Grenade Casing"
	icon_state = "chemg"
	icon = 'chemical.dmi'
	item_state = "flashbang"
	w_class = 2.0
	force = 2.0
	throw_speed = 4
	throw_range = 20
	flags = FPRINT | TABLEPASS | CONDUCT | ONBELT | USEDELAY
	var/obj/item/weapon/reagent_containers/glass/beaker_one
	var/obj/item/weapon/reagent_containers/glass/beaker_two
	var/obj/item/device/assembly/attached_device
	var/active = 0
	var/exploding = 0
	var/state = 0
	var/path = 0
	var/motion = 0
	var/direct = "SOUTH"
	var/obj/item/weapon/circuitboard/circuit = null
	var/list/allowed_containers = list("/obj/item/weapon/reagent_containers/glass/beaker", "/obj/item/weapon/reagent_containers/glass/dispenser", "/obj/item/weapon/reagent_containers/glass/bottle")
	var/affected_area = 3
	var/mob/attacher = "Unknown"

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
						if(beaker_one && beaker_two)
							user << "\red There are already two beakers inside, remove one first!"
							return

						if(!beaker_one)
							beaker_one = W
							user.drop_item()
							W.loc = src
							user << "\blue You insert the beaker into the casing."
						else if(!beaker_two)
							beaker_two = W
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
						if(beaker_one && beaker_two && attached_device)
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
		<BR> <B> Beaker one:</B> [beaker_one] [beaker_one ? "<A href='?src=\ref[src];beakerone=1'>Remove</A>" : ""]
		<BR> <B> Beaker two:</B> [beaker_two] [beaker_two ? "<A href='?src=\ref[src];beakertwo=1'>Remove</A>" : ""]
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
				beaker_one.loc = get_turf(src)
				beaker_one = null
			if(href_list["beakertwo"])
				beaker_two.loc = get_turf(src)
				beaker_two = null
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


	proc
		explode()
			if(exploding) return
			exploding = 1

			if(reliability)
				playsound(src.loc, 'bamf.ogg', 50, 1)
				beaker_two.reagents.maximum_volume += beaker_one.reagents.maximum_volume // make sure everything can mix
				beaker_one.reagents.update_total()
				beaker_one.reagents.trans_to(beaker_two, beaker_one.reagents.total_volume)
				var/turf/bombturf = get_turf(src)
				var/bombarea = bombturf.loc.name
				var/log_str = "Grenade detonated in [bombarea] with device attacher: [attacher]. Last touched by: [src.fingerprintslast]"
				bombers += log_str
				message_admins(log_str)
				log_game(log_str)
				if(beaker_one.reagents.total_volume) //The possible reactions didnt use up all reagents.
					var/datum/effect/effect/system/steam_spread/steam = new /datum/effect/effect/system/steam_spread()
					steam.set_up(10, 0, get_turf(src))
					steam.attach(src)
					steam.start()

					for(var/atom/A in view(affected_area, src.loc))
						if( A == src ) continue
						src.reagents.reaction(A, 1, 10)


				invisibility = 100 //Why am i doing this?
				spawn(50)		   //To make sure all reagents can work
					del(src)	   //correctly before deleting the grenade.
			else
				icon_state = initial(icon_state) + "_locked"
				crit_fail = 1
				if(beaker_one)
					beaker_one.loc = get_turf(src.loc)
				if(beaker_two)
					beaker_two.loc = get_turf(src.loc)

		c_state(var/i = 0)
			if(i)
				icon_state = initial(icon_state) + "_armed"
			else
				icon_state = initial(icon_state) + "_locked"
			return

	large
		name = "Large Chem Grenade"
		desc = "An oversized grenade that affects a larger area."
		icon_state = "large_grenade"
		allowed_containers = list("/obj/item/weapon/reagent_containers/glass")
		origin_tech = "combat=3;materials=3"
		affected_area = 4

	metalfoam
		name = "Metal-Foam Grenade"
		desc = "Used for emergency sealing of air breaches."
		path = 1
		active = 2

		New()
			..()
			attached_device = new /obj/item/device/assembly/timer(src)
			attached_device.master = src
			var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
			var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)

			B1.reagents.add_reagent("aluminum", 30)
			B2.reagents.add_reagent("foaming_agent", 10)
			B2.reagents.add_reagent("pacid", 10)

			beaker_two = B1
			beaker_one = B2
			icon_state = "chemg_locked"

	incendiary
		name = "Incendiary Grenade"
		desc = "Used for clearing rooms of living things."
		path = 1
		active = 2

		New()
			..()
			attached_device = new /obj/item/device/assembly/timer(src)
			attached_device.master = src
			var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
			var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)

			B1.reagents.add_reagent("aluminum", 25)
			B2.reagents.add_reagent("plasma", 25)
			B2.reagents.add_reagent("acid", 25)

			beaker_two = B1
			beaker_one = B2
			icon_state = "chemg_locked"

	cleaner
		name = "Cleaner Grenade"
		desc = "BLAM!-brand foaming space cleaner. In a special applicator for rapid cleaning of wide areas."
		active = 2
		path = 1

		New()
			..()
			attached_device = new /obj/item/device/assembly/timer(src)
			attached_device.master = src
			var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
			var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)

			B1.reagents.add_reagent("fluorosurfactant", 40)
			B2.reagents.add_reagent("water", 40)
			B2.reagents.add_reagent("cleaner", 10)

			beaker_two = B1
			beaker_one = B2
			icon_state = "chemg_locked"

/obj/effect/syringe_gun_dummy
	name = ""
	desc = ""
	icon = 'chemical.dmi'
	icon_state = "null"
	anchored = 1
	density = 0

	New()
		var/datum/reagents/R = new/datum/reagents(15)
		reagents = R
		R.my_atom = src

/obj/item/weapon/gun/grenadelauncher
	name = "grenade launcher"
	icon = 'gun.dmi'
	icon_state = "riotgun"
	item_state = "riotgun"
	w_class = 4.0
	throw_speed = 2
	throw_range = 10
	force = 5.0
	var/list/grenades = new/list()
	var/max_grenades = 3
	m_amt = 2000

	examine()
		set src in view()
		..()
		if (!(usr in view(2)) && usr!=src.loc) return
		usr << "\icon [src] Grenade launcher:"
		usr << "\blue [grenades] / [max_grenades] Grenades."

	attackby(obj/item/I as obj, mob/user as mob)

		if((istype(I, /obj/item/weapon/chem_grenade)) || (istype(I, /obj/item/weapon/flashbang)) || (istype(I, /obj/item/weapon/smokebomb)) || (istype(I, /obj/item/weapon/mustardbomb)) || (istype(I, /obj/item/weapon/empgrenade)))
			if(grenades.len < max_grenades)
				user.drop_item()
				I.loc = src
				grenades += I
				user << "\blue You put the grenade in the grenade launcher."
				user << "\blue [grenades.len] / [max_grenades] Grenades."
			else
				usr << "\red The grenade launcher cannot hold more grenades."

	afterattack(obj/target, mob/user , flag)

		if (istype(target, /obj/item/weapon/storage/backpack ))
			return

		else if (locate (/obj/structure/table, src.loc))
			return

		else if(target == user)
			return

		if(grenades.len)
			spawn(0) fire_grenade(target,user)
		else
			usr << "\red The grenade launcher is empty."

	proc
		fire_grenade(atom/target, mob/user)
			for(var/mob/O in viewers(world.view, user))
				O.show_message(text("\red [] fired a grenade!", user), 1)
			user << "\red You fire the grenade launcher!"
			if (istype(grenades[1], /obj/item/weapon/chem_grenade))
				var/obj/item/weapon/chem_grenade/F = grenades[1]
				grenades -= F
				F.loc = user.loc
				F.throw_at(target, 30, 2)
				message_admins("[key_name_admin(user)] fired a chemistry grenade from a grenade launcher ([src.name]).")
				log_game("[key_name_admin(user)] used a chemistry grenade ([src.name]).")
				F.state = 1
				F.icon_state = initial(icon_state)+"_armed"
				playsound(user.loc, 'armbomb.ogg', 75, 1, -3)
				spawn(15)
					F.explode()
			else if (istype(grenades[1], /obj/item/weapon/flashbang))
				var/obj/item/weapon/flashbang/F = grenades[1]
				grenades -= F
				F.loc = user.loc
				F.throw_at(target, 30, 2)
				F.active = 1
				F.icon_state = "flashbang1"
				playsound(user.loc, 'armbomb.ogg', 75, 1, -3)
				spawn(15)
					F.prime()
			else if (istype(grenades[1], /obj/item/weapon/smokebomb))
				var/obj/item/weapon/smokebomb/F = grenades[1]
				grenades -= F
				F.loc = user.loc
				F.throw_at(target, 30, 2)
				F.icon_state = "flashbang1"
				playsound(user.loc, 'armbomb.ogg', 75, 1, -3)
				spawn(15)
					F.prime()
			else if (istype(grenades[1], /obj/item/weapon/mustardbomb))
				var/obj/item/weapon/mustardbomb/F = grenades[1]
				grenades -= F
				F.loc = user.loc
				F.throw_at(target, 30, 2)
				F.icon_state = "flashbang1"
				playsound(user.loc, 'armbomb.ogg', 75, 1, -3)
				spawn(15)
					F.prime()
			else if (istype(grenades[1], /obj/item/weapon/empgrenade))
				var/obj/item/weapon/empgrenade/F = grenades[1]
				grenades -= F
				F.loc = user.loc
				F.throw_at(target, 30, 2)
				F.active = 1
				F.icon_state = "empar"
				playsound(user.loc, 'armbomb.ogg', 75, 1, -3)
				spawn(15)
					F.prime()
			if (locate (/obj/structure/table, src.loc) || locate (/obj/item/weapon/storage, src.loc))
				return
			else
				for(var/mob/O in viewers(world.view, user))
					O.show_message(text("\red [] fired a grenade!", user), 1)
				user << "\red You fire the grenade launcher!"
				if (istype(grenades[1], /obj/item/weapon/chem_grenade))
					var/obj/item/weapon/chem_grenade/F = grenades[1]
					grenades -= F
					F.loc = user.loc
					F.throw_at(target, 30, 2)
					message_admins("[key_name_admin(user)] fired a chemistry grenade from a grenade launcher ([src.name]).")
					log_game("[key_name_admin(user)] used a chemistry grenade ([src.name]).")
					F.state = 1
					F.icon_state = initial(icon_state)+"_armed"
					playsound(user.loc, 'armbomb.ogg', 75, 1, -3)
					spawn(15)
						F.explode()
				else if (istype(grenades[1], /obj/item/weapon/flashbang))
					var/obj/item/weapon/flashbang/F = grenades[1]
					grenades -= F
					F.loc = user.loc
					F.throw_at(target, 30, 2)
					F.active = 1
					F.icon_state = "flashbang1"
					playsound(user.loc, 'armbomb.ogg', 75, 1, -3)
					spawn(15)
						F.prime()
				else if (istype(grenades[1], /obj/item/weapon/smokebomb))
					var/obj/item/weapon/smokebomb/F = grenades[1]
					grenades -= F
					F.loc = user.loc
					F.throw_at(target, 30, 2)
					F.icon_state = "flashbang1"
					playsound(user.loc, 'armbomb.ogg', 75, 1, -3)
					spawn(15)
						F.prime()
				else if (istype(grenades[1], /obj/item/weapon/mustardbomb))
					var/obj/item/weapon/mustardbomb/F = grenades[1]
					grenades -= F
					F.loc = user.loc
					F.throw_at(target, 30, 2)
					F.icon_state = "flashbang1"
					playsound(user.loc, 'armbomb.ogg', 75, 1, -3)
					spawn(15)
						F.prime()
				else if (istype(grenades[1], /obj/item/weapon/empgrenade))
					var/obj/item/weapon/empgrenade/F = grenades[1]
					grenades -= F
					F.loc = user.loc
					F.throw_at(target, 30, 2)
					F.active = 1
					F.icon_state = "empar"
					playsound(user.loc, 'armbomb.ogg', 75, 1, -3)
					spawn(15)
						F.prime()


/obj/item/weapon/gun/syringe
	name = "syringe gun"
	desc = "A spring loaded rifle designed to fit syringes, designed to incapacitate unruly patients from a distance."
	icon = 'gun.dmi'
	icon_state = "syringegun"
	item_state = "syringegun"
	w_class = 3.0
	throw_speed = 2
	throw_range = 10
	force = 4.0
	var/list/syringes = new/list()
	var/max_syringes = 1
	m_amt = 2000

	examine()
		set src in view()
		..()
		if (!(usr in view(2)) && usr!=src.loc) return
		usr << "\blue [syringes.len] / [max_syringes] syringes."

	attackby(obj/item/I as obj, mob/user as mob)

		if(istype(I, /obj/item/weapon/reagent_containers/syringe))
			if(syringes.len < max_syringes)
				user.drop_item()
				I.loc = src
				syringes += I
				user << "\blue You put the syringe in [src]."
				user << "\blue [syringes.len] / [max_syringes] syringes."
			else
				usr << "\red [src] cannot hold more syringes."

	afterattack(obj/target, mob/user , flag)
		if(!isturf(target.loc) || target == user) return

		if(syringes.len)
			spawn(0) fire_syringe(target,user)
		else
			usr << "\red [src] is empty."

	proc
		fire_syringe(atom/target, mob/user)
			if (locate (/obj/structure/table, src.loc))
				return
			else
				var/turf/trg = get_turf(target)
				var/obj/effect/syringe_gun_dummy/D = new/obj/effect/syringe_gun_dummy(get_turf(src))
				var/obj/item/weapon/reagent_containers/syringe/S = syringes[1]
				if((!S) || (!S.reagents))	//ho boy! wot runtimes!
					return
				S.reagents.trans_to(D, S.reagents.total_volume)
				syringes -= S
				del(S)
				D.icon_state = "syringeproj"
				D.name = "syringe"
				playsound(user.loc, 'syringeproj.ogg', 50, 1)

				for(var/i=0, i<6, i++)
					if(!D) break
					if(D.loc == trg) break
					step_towards(D,trg)

					if(D)
						for(var/mob/living/carbon/M in D.loc)
							if(!istype(M,/mob/living/carbon)) continue
							if(M == user) continue
							//Syring gune attack logging by Yvarov
							var/R
							for(var/datum/reagent/A in D.reagents.reagent_list)
								R += A.id + " ("
								R += num2text(A.volume) + "),"
							if (istype(M, /mob))
								M.attack_log += "\[[time_stamp()]\] <b>[user]/[user.ckey]</b> shot <b>[M]/[M.ckey]</b> with a <b>syringegun</b> ([R])"
								user.attack_log += "\[[time_stamp()]\] <b>[user]/[user.ckey]</b> shot <b>[M]/[M.ckey]</b> with a <b>syringegun</b> ([R])"
								log_attack("<font color='red'>[user] ([user.ckey]) shot [M] ([M.ckey]) with a syringegun ([R])</font>")
								log_admin("ATTACK: [user] ([user.ckey]) shot [M] ([M.ckey]) with a syringegun ([R]).")
								message_admins("ATTACK: [user] ([user.ckey]) shot [M] ([M.ckey]) with a syringegun ([R]).")
							else
								M.attack_log += "\[[time_stamp()]\] <b>UNKNOWN SUBJECT (No longer exists)</b> shot <b>[M]/[M.ckey]</b> with a <b>syringegun</b> ([R])"
								log_attack("<font color='red'>UNKNOWN shot [M] ([M.ckey]) with a <b>syringegun</b> ([R])</font>")
								log_admin("ATTACK: UNKNOWN shot [M] ([M.ckey]) with a <b>syringegun</b> ([R]).")
								message_admins("ATTACK: UNKNOWN shot [M] ([M.ckey]) with a <b>syringegun</b> ([R]).")
							D.reagents.trans_to(M, 15)
							M.take_organ_damage(5)
							for(var/mob/O in viewers(world.view, D))
								O.show_message(text("\red [] is hit by the syringe!", M.name), 1)

							del(D)
					if(D)
						for(var/atom/A in D.loc)
							if(A == user) continue
							if(A.density) del(D)

					sleep(1)

				if (D) spawn(10) del(D)

				return

/obj/item/weapon/gun/syringe/rapidsyringe
	name = "rapid syringe gun"
	desc = "A modification of the syringe gun design, using a rotating cylinder to store up to four syringes."
	icon_state = "rapidsyringegun"
	max_syringes = 4

/obj/structure/reagent_dispensers
	name = "Dispenser"
	desc = "..."
	icon = 'objects.dmi'
	icon_state = "watertank"
	density = 1
	anchored = 0
	flags = FPRINT
	pressure_resistance = 2*ONE_ATMOSPHERE

	var/amount_per_transfer_from_this = 10
	var/possible_transfer_amounts = list(10,25,50,100)

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		return

	New()
		var/datum/reagents/R = new/datum/reagents(1000)
		reagents = R
		R.my_atom = src
		if (!possible_transfer_amounts)
			src.verbs -= /obj/structure/reagent_dispensers/verb/set_APTFT
		..()

	examine()
		set src in view()
		..()
		if (!(usr in view(2)) && usr!=src.loc) return
		usr << "\blue It contains:"
		if(reagents && reagents.reagent_list.len)
			for(var/datum/reagent/R in reagents.reagent_list)
				usr << "\blue [R.volume] units of [R.name]"
		else
			usr << "\blue Nothing."

	verb/set_APTFT() //set amount_per_transfer_from_this
		set name = "Set transfer amount"
		set category = "Object"
		set src in view(1)
		var/N = input("Amount per transfer from this:","[src]") as null|anything in possible_transfer_amounts
		if (N)
			amount_per_transfer_from_this = N

	ex_act(severity)
		switch(severity)
			if(1.0)
				del(src)
				return
			if(2.0)
				if (prob(50))
					new /obj/effect/effect/water(src.loc)
					del(src)
					return
			if(3.0)
				if (prob(5))
					new /obj/effect/effect/water(src.loc)
					del(src)
					return
			else
		return

	blob_act()
		if(prob(50))
			new /obj/effect/effect/water(src.loc)
			del(src)



/obj/item/weapon/reagent_containers
	name = "Container"
	desc = "..."
	icon = 'chemical.dmi'
	icon_state = null
	w_class = 1
	var/amount_per_transfer_from_this = 5
	var/possible_transfer_amounts = list(5,10,15,25,30)
	var/volume = 30

	verb/set_APTFT() //set amount_per_transfer_from_this
		set name = "Set transfer amount"
		set category = "Object"
		set src in range(0)
		var/N = input("Amount per transfer from this:","[src]") as null|anything in possible_transfer_amounts
		if (N)
			amount_per_transfer_from_this = N

	New()
		..()
		if (!possible_transfer_amounts)
			src.verbs -= /obj/item/weapon/reagent_containers/verb/set_APTFT
		var/datum/reagents/R = new/datum/reagents(volume)
		reagents = R
		R.my_atom = src

	attackby(obj/item/weapon/W as obj, mob/user as mob)

		return
	attack_self(mob/user as mob)
		return
	attack(mob/M as mob, mob/user as mob, def_zone)
		return
	attackby(obj/item/I as obj, mob/user as mob)

		return
	afterattack(obj/target, mob/user , flag)
		return

////////////////////////////////////////////////////////////////////////////////
/// (Mixing)Glass.
////////////////////////////////////////////////////////////////////////////////
/obj/item/weapon/reagent_containers/glass
	name = " "
	desc = " "
	icon = 'chemical.dmi'
	icon_state = "null"
	item_state = "null"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,25,30,50)
	volume = 50
	flags = FPRINT | TABLEPASS | OPENCONTAINER

	var/list/can_be_placed_into = list(
		/obj/machinery/chem_master/,
		/obj/machinery/chem_dispenser/,
		/obj/machinery/reagentgrinder,
		/obj/structure/table,
		/obj/structure/closet/secure_closet,
		/obj/structure/closet,
		/obj/machinery/sink,
		/obj/item/weapon/storage,
		/obj/machinery/atmospherics/unary/cryo_cell,
		/obj/item/weapon/chem_grenade,
		/obj/machinery/bot/medbot,
		/obj/machinery/computer/pandemic,
		/obj/item/weapon/secstorage/ssafe,
		/obj/machinery/disposal,
		/obj/machinery/disease2/incubator,
		/obj/machinery/disease2/isolator,
		/obj/machinery/disease2/biodestroyer,
		/mob/living/simple_animal/livestock/cow
	)

	examine()
		set src in view()
		..()
		if (!(usr in view(2)) && usr!=src.loc) return
		usr << "\blue It contains:"
		if(reagents && reagents.reagent_list.len)
			for(var/datum/reagent/R in reagents.reagent_list)
				usr << "\blue [R.volume] units of [R.name]"
		else
			usr << "\blue Nothing."

	afterattack(obj/target, mob/user , flag)
		for(var/type in src.can_be_placed_into)
			if(istype(target, type))
				return

		if(ismob(target) && target.reagents && reagents.total_volume)
			user << "\blue You splash the solution onto [target]."
			for(var/mob/O in viewers(world.view, user))
				O.show_message(text("\red [] has been splashed with something by []!", target, user), 1)
			src.reagents.reaction(target, TOUCH)
			spawn(5) src.reagents.clear_reagents()
			return
		else if(istype(target, /obj/structure/reagent_dispensers)) //A dispenser. Transfer FROM it TO us.

			if(!target.reagents.total_volume && target.reagents)
				user << "\red [target] is empty."
				return

			if(reagents.total_volume >= reagents.maximum_volume)
				user << "\red [src] is full."
				return

			var/trans = target.reagents.trans_to(src, target:amount_per_transfer_from_this)
			user << "\blue You fill [src] with [trans] units of the contents of [target]."

		else if(target.is_open_container() && target.reagents) //Something like a glass. Player probably wants to transfer TO it.
			if(!reagents.total_volume)
				user << "\red [src] is empty."
				return

			if(target.reagents.total_volume >= target.reagents.maximum_volume)
				user << "\red [target] is full."
				return

			var/trans = src.reagents.trans_to(target, amount_per_transfer_from_this)
			user << "\blue You transfer [trans] units of the solution to [target]."

		//Safety for dumping stuff into a ninja suit. It handles everything through attackby() and this is unnecessary.
		else if(istype(target, /obj/item/clothing/suit/space/space_ninja))
			return

		else if(reagents.total_volume)
			user << "\blue You splash the solution onto [target]."
			src.reagents.reaction(target, TOUCH)
			spawn(5) src.reagents.clear_reagents()
			return

////////////////////////////////////////////////////////////////////////////////
/// (Mixing)Glass. END
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
/// Droppers.
////////////////////////////////////////////////////////////////////////////////
/obj/item/weapon/reagent_containers/dropper
	name = "Dropper"
	desc = "A dropper. Transfers 5 units."
	icon = 'chemical.dmi'
	icon_state = "dropper0"
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = list(1,2,3,4,5)
	volume = 5
	var/filled = 0

	afterattack(obj/target, mob/user , flag)
		if(!target.reagents) return

		if(filled)

			if(target.reagents.total_volume >= target.reagents.maximum_volume)
				user << "\red [target] is full."
				return

			if(!target.is_open_container() && !ismob(target) && !istype(target,/obj/item/weapon/reagent_containers/food)) //You can inject humans and food but you cant remove the shit.
				user << "\red You cannot directly fill this object."
				return

			if(ismob(target))
				for(var/mob/O in viewers(world.view, user))
					O.show_message(text("\red <B>[] drips something onto []!</B>", user, target), 1)
				src.reagents.reaction(target, TOUCH)

			var/trans = src.reagents.trans_to(target, amount_per_transfer_from_this)
			user << "\blue You transfer [trans] units of the solution."
			if (src.reagents.total_volume<=0)
				filled = 0
				icon_state = "dropper[filled]"

		else

			if(!target.is_open_container() && !istype(target,/obj/structure/reagent_dispensers))
				user << "\red You cannot directly remove reagents from [target]."
				return

			if(!target.reagents.total_volume)
				user << "\red [target] is empty."
				return

			var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this)

			user << "\blue You fill the dropper with [trans] units of the solution."

			filled = 1
			icon_state = "dropper[filled]"

		return

////////////////////////////////////////////////////////////////////////////////
/// Droppers. END
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
/// Syringes.
////////////////////////////////////////////////////////////////////////////////
#define SYRINGE_DRAW 0
#define SYRINGE_INJECT 1

/obj/item/weapon/reagent_containers/syringe
	name = "Syringe"
	desc = "A syringe."
	icon = 'syringe.dmi'
	item_state = "syringe_0"
	icon_state = "0"
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = null //list(5,10,15)
	volume = 15
	var/has_blood = 0
	var/mode = SYRINGE_DRAW

	on_reagent_change()
		update_icon()

	pickup(mob/user)
		..()
		update_icon()

	dropped(mob/user)
		..()
		update_icon()

	attack_self(mob/user as mob)
/*
		switch(mode)
			if(SYRINGE_DRAW)
				mode = SYRINGE_INJECT
			if(SYRINGE_INJECT)
				mode = SYRINGE_DRAW
*/
		mode = !mode
		update_icon()

	attack_hand()
		..()
		update_icon()

	attack_paw()
		return attack_hand()

	attackby(obj/item/I as obj, mob/user as mob)

		return

	afterattack(obj/target, mob/user , flag)
		if(!target.reagents) return

		switch(mode)
			if(SYRINGE_DRAW)

				if(reagents.total_volume >= reagents.maximum_volume)
					user << "\red The syringe is full."
					return

				if(ismob(target))//Blood!
					if(istype(target, /mob/living/carbon/metroid))
						user << "\red You are unable to locate any blood."
						return
					if(src.reagents.has_reagent("blood"))
						user << "\red There is already a blood sample in this syringe"
						return
					if(istype(target, /mob/living/carbon))//maybe just add a blood reagent to all mobs. Then you can suck them dry...With hundreds of syringes. Jolly good idea.
						var/amount = src.reagents.maximum_volume - src.reagents.total_volume
						var/mob/living/carbon/T = target
						if(!T.dna)
							usr << "You are unable to locate any blood. (To be specific, your target seems to be missing their DNA datum)"
							return
						if(T.mutations2 & NOCLONE) //target done been et, no more blood in him
							user << "\red You are unable to locate any blood."
							return
						if(ishuman(T))
							if(T:vessel.get_reagent_amount("blood") < amount)
								return

						var/datum/reagent/B = new /datum/reagent/blood
						B.holder = src
						B.volume = amount
						//set reagent data
						B.data["donor"] = T
						/*
						if(T.virus && T.virus.spread_type != SPECIAL)
							B.data["virus"] = new T.virus.type(0)
						*/



						for(var/datum/disease/D in T.viruses)
							if(!B.data["viruses"])
								B.data["viruses"] = list()


							B.data["viruses"] += new D.type

						// not sure why it was checking if(B.data["virus2"]), but it seemed wrong
						if(T.virus2)
							B.data["virus2"] = T.virus2.getcopy()

						B.data["blood_DNA"] = copytext(T.dna.unique_enzymes,1,0)
						if(T.resistances&&T.resistances.len)
							B.data["resistances"] = T.resistances.Copy()
						if(istype(target, /mob/living/carbon/human))//I wish there was some hasproperty operation...
							B.data["blood_type"] = copytext(T.dna.b_type,1,0)
						var/list/temp_chem = list()
						for(var/datum/reagent/R in target.reagents.reagent_list)
							temp_chem += R.name
							temp_chem[R.name] = R.volume
						B.data["trace_chem"] = list2params(temp_chem)
						B.data["antibodies"] = T.antibodies
						//debug
						//for(var/D in B.data)
						//	world << "Data [D] = [B.data[D]]"
						//debug
						if(ishuman(T))
							T:vessel.remove_reagent("blood",amount) // Removes blood if human

						src.reagents.reagent_list += B
						src.reagents.update_total()
						src.on_reagent_change()
						src.reagents.handle_reactions()
//						T:vessel.trans_to(src, amount) // Virus2 and antibodies aren't in blood in the first place.

						user << "\blue You take a blood sample from [target]"
						for(var/mob/O in viewers(4, user))
							O.show_message("\red [user] takes a blood sample from [target].", 1)

						if(prob(2) && istype(T,/mob/living/carbon/monkey))
							T:react_to_attack(user)

				else //if not mob
					if(!target.reagents.total_volume)
						user << "\red [target] is empty."
						return

					if(!target.is_open_container() && !istype(target,/obj/structure/reagent_dispensers) && !istype(target,/obj/item/metroid_core))
						user << "\red You cannot directly remove reagents from this object."
						return

					var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this) // transfer from, transfer to - who cares?

					user << "\blue You fill the syringe with [trans] units of the solution."
				if (reagents.total_volume >= reagents.maximum_volume)
					mode=!mode
					update_icon()

			if(SYRINGE_INJECT)
				if(!reagents.total_volume)
					user << "\red The Syringe is empty."
					return
				if(istype(target, /obj/item/weapon/implantcase/chem))
					return

				if(!target.is_open_container() && !ismob(target) && !istype(target, /obj/item/weapon/reagent_containers/food) && !istype(target, /obj/item/metroid_core))
					user << "\red You cannot directly fill this object."
					return
				if(target.reagents.total_volume >= target.reagents.maximum_volume)
					user << "\red [target] is full."
					return

				if(istype(target, /obj/item/metroid_core))
					var/obj/item/metroid_core/core = target
					core.Flush = 30 // reset flush counter

				if(ismob(target) && target != user)
					for(var/mob/O in viewers(world.view, user))
						O.show_message(text("\red <B>[] is trying to inject []!</B>", user, target), 1)
					if(!do_mob(user, target)) return
					for(var/mob/O in viewers(world.view, user))
						O.show_message(text("\red [] injects [] with the syringe!", user, target), 1)
					src.reagents.reaction(target, INGEST)
					if(prob(2) && istype(target,/mob/living/carbon/monkey))
						var/mob/living/carbon/monkey/M = target
						M.react_to_attack(user)
				if(ismob(target) && target == user)
					src.reagents.reaction(target, INGEST)
				spawn(5)
					var/datum/reagent/blood/B
					for(var/datum/reagent/blood/d in src.reagents.reagent_list)
						B = d
						break
					var/trans
					if(B && ishuman(target))
						var/mob/living/carbon/human/H = target
						H.vessel.add_reagent("blood",(B.volume > 5? 5 : B.volume),B.data)
						src.reagents.remove_reagent("blood",(B.volume > 5? 5 : B.volume))
					else
						trans = src.reagents.trans_to(target, amount_per_transfer_from_this)
					user << "\blue You inject [trans] units of the solution. The syringe now contains [src.reagents.total_volume] units."
					if (reagents.total_volume <= 0 && mode==SYRINGE_INJECT)
						mode = SYRINGE_DRAW
						update_icon()

		return

	update_icon()
		var/rounded_vol = round(reagents.total_volume,5)
		overlays = null
		has_blood = 0
		for(var/datum/reagent/blood/B in reagents.reagent_list)
			has_blood = 1
			break
		if(ismob(loc))
			var/injoverlay
			switch(mode)
				if (SYRINGE_DRAW)
					injoverlay = "draw"
				if (SYRINGE_INJECT)
					injoverlay = "inject"
			overlays += injoverlay
		icon_state = "[rounded_vol]"
		item_state = "syringe_[rounded_vol]"
		if(reagents.total_volume)
			var/obj/effect/overlay = new/obj
			overlay.icon = 'syringefilling.dmi'
			switch(rounded_vol)
				if(5)	overlay.icon_state = "5"
				if(10)	overlay.icon_state = "10"
				if(15)	overlay.icon_state = "15"

			var/list/rgbcolor = list(0,0,0)
			var/finalcolor
			for(var/datum/reagent/re in reagents.reagent_list) // natural color mixing bullshit/algorithm
				if(!finalcolor)
					rgbcolor = GetColors(re.color)
					finalcolor = re.color
				else
					var/newcolor[3]
					var/prergbcolor[3]
					prergbcolor = rgbcolor
					newcolor = GetColors(re.color)

					rgbcolor[1] = (prergbcolor[1]+newcolor[1])/2
					rgbcolor[2] = (prergbcolor[2]+newcolor[2])/2
					rgbcolor[3] = (prergbcolor[3]+newcolor[3])/2

					finalcolor = rgb(rgbcolor[1], rgbcolor[2], rgbcolor[3])

			overlay.icon += finalcolor
			if(!istype(src.loc, /turf))	overlay.layer = 30
			overlays += overlay


/obj/item/weapon/reagent_containers/ld50_syringe
	name = "Lethal Injection Syringe"
	desc = "A syringe used for lethal injections."
	icon = 'syringe.dmi'
	item_state = "syringe_0"
	icon_state = "0"
	amount_per_transfer_from_this = 50
	possible_transfer_amounts = null //list(5,10,15)
	volume = 50
	var/mode = SYRINGE_DRAW

	on_reagent_change()
		update_icon()

	pickup(mob/user)
		..()
		update_icon()

	dropped(mob/user)
		..()
		update_icon()

	attack_self(mob/user as mob)
/*
		switch(mode)
			if(SYRINGE_DRAW)
				mode = SYRINGE_INJECT
			if(SYRINGE_INJECT)
				mode = SYRINGE_DRAW
*/
		mode = !mode
		update_icon()

	attack_hand()
		..()
		update_icon()

	attack_paw()
		return attack_hand()

	attackby(obj/item/I as obj, mob/user as mob)

		return

	afterattack(obj/target, mob/user , flag)
		if(!target.reagents) return

		switch(mode)
			if(SYRINGE_DRAW)

				if(reagents.total_volume >= reagents.maximum_volume)
					user << "\red The syringe is full."
					return

				if(ismob(target))
					if(istype(target, /mob/living/carbon))//I Do not want it to suck 50 units out of people
						usr << "This needle isn't designed for drawing blood."
						return
				else //if not mob
					if(!target.reagents.total_volume)
						user << "\red [target] is empty."
						return

					if(!target.is_open_container() && !istype(target,/obj/structure/reagent_dispensers))
						user << "\red You cannot directly remove reagents from this object."
						return

					var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this) // transfer from, transfer to - who cares?

					user << "\blue You fill the syringe with [trans] units of the solution."
				if (reagents.total_volume >= reagents.maximum_volume)
					mode=!mode
					update_icon()

			if(SYRINGE_INJECT)
				if(!reagents.total_volume)
					user << "\red The Syringe is empty."
					return
				if(istype(target, /obj/item/weapon/implantcase/chem))
					return
				if(!target.is_open_container() && !ismob(target) && !istype(target, /obj/item/weapon/reagent_containers/food))
					user << "\red You cannot directly fill this object."
					return
				if(target.reagents.total_volume >= target.reagents.maximum_volume)
					user << "\red [target] is full."
					return

				if(ismob(target) && target != user)
					for(var/mob/O in viewers(world.view, user))
						O.show_message(text("\red <B>[] is trying to inject [] with a giant syringe!</B>", user, target), 1)
					if(!do_mob(user, target, 300)) return
					for(var/mob/O in viewers(world.view, user))
						O.show_message(text("\red [] injects [] with a giant syringe!", user, target), 1)
					src.reagents.reaction(target, INGEST)
				if(ismob(target) && target == user)
					src.reagents.reaction(target, INGEST)
				spawn(5)
					var/trans = src.reagents.trans_to(target, amount_per_transfer_from_this)
					user << "\blue You inject [trans] units of the solution. The syringe now contains [src.reagents.total_volume] units."
					if (reagents.total_volume >= reagents.maximum_volume && mode==SYRINGE_INJECT)
						mode = SYRINGE_DRAW
						update_icon()

		return

	update_icon()
		var/rounded_vol = round(reagents.total_volume,50)
		if(ismob(loc))
			var/mode_t
			switch(mode)
				if (SYRINGE_DRAW)
					mode_t = "d"
				if (SYRINGE_INJECT)
					mode_t = "i"
			icon_state = "[mode_t][rounded_vol]"
		else
			icon_state = "[rounded_vol]"
		item_state = "syringe_[rounded_vol]"

////////////////////////////////////////////////////////////////////////////////
/// Syringes. END
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
/// HYPOSPRAY
////////////////////////////////////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/hypospray
	name = "hypospray"
	desc = "The DeForest Medical Corporation hypospray is a sterile, air-needle autoinjector for rapid administration of drugs to patients."
	icon = 'syringe.dmi'
	item_state = "hypo"
	icon_state = "hypo"
	amount_per_transfer_from_this = 5
	volume = 30
	possible_transfer_amounts = null
	flags = FPRINT | ONBELT | TABLEPASS | OPENCONTAINER

/obj/item/weapon/reagent_containers/hypospray/attack_paw(mob/user as mob)
	return src.attack_hand(user)


/obj/item/weapon/reagent_containers/hypospray/New() //comment this to make hypos start off empty
	..()
	reagents.add_reagent("tricordrazine", 30)
	return

/obj/item/weapon/reagent_containers/hypospray/attack(mob/M as mob, mob/user as mob)
	if(!reagents.total_volume)
		user << "\red The hypospray is empty."
		return
	if (!( istype(M, /mob) ))
		return
	if (reagents.total_volume)
		user << "\blue You inject [M] with the hypospray."
		M << "\red You feel a tiny prick!"

		M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been injected with [src.name] by [user.name] ([user.ckey])</font>")
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to inject [M.name] ([M.ckey])</font>")
		log_admin("ATTACK: [user] ([user.ckey]) injected [M] ([M.ckey]) with [src].")
		message_admins("ATTACK: [user] ([user.ckey]) injected [M] ([M.ckey]) with [src].")
		log_attack("<font color='red'>[user.name] ([user.ckey]) injected [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>")


		src.reagents.reaction(M, INGEST)
		if(M.reagents)
			var/trans = reagents.trans_to(M, amount_per_transfer_from_this)
			user << "\blue [trans] units injected.  [reagents.total_volume] units remaining in the hypospray."
	return

/obj/item/weapon/reagent_containers/borghypo
	name = "Cyborg Hypospray"
	desc = "An advanced chemical synthesizer and injection system, designed for heavy-duty medical equipment."
	icon = 'syringe.dmi'
	item_state = "hypo"
	icon_state = "borghypo"
	amount_per_transfer_from_this = 5
	volume = 30
	possible_transfer_amounts = null
	flags = FPRINT
	var/mode = 1
	var/charge_cost = 100
	var/charge_tick = 0
	var/recharge_time = 10 //Time it takes for shots to recharge (in seconds)

	New()
		..()
		processing_objects.Add(src)


	Del()
		processing_objects.Remove(src)
		..()

	process() //Every [recharge_time] seconds, recharge some reagents for the cyborg
		charge_tick++
		if(charge_tick < recharge_time) return 0
		charge_tick = 0

		if(isrobot(src.loc))
			var/mob/living/silicon/robot/R = src.loc
			if(R && R.cell)
				if(mode == 1 && reagents.total_volume < 30) 	//Don't recharge reagents and drain power if the storage is full.
					R.cell.use(charge_cost) 					//Take power from borg...
					reagents.add_reagent("tricordrazine",10)	//And fill hypo with reagent.
				if(mode == 2 && reagents.total_volume < 30)
					R.cell.use(charge_cost)
					reagents.add_reagent("inaprovaline", 10)
				if(mode == 3 && reagents.total_volume < 30)
					R.cell.use(charge_cost)
					reagents.add_reagent("spaceacillin", 10)
		//update_icon()
		return 1

/obj/item/weapon/reagent_containers/borghypo/attack(mob/M as mob, mob/user as mob)
	if(!reagents.total_volume)
		user << "\red The injector is empty."
		return
	if (!( istype(M, /mob) ))
		return
	if (reagents.total_volume)
		user << "\blue You inject [M] with the injector."
		M << "\red You feel a tiny prick!"

		src.reagents.reaction(M, INGEST)
		if(M.reagents)
			var/trans = reagents.trans_to(M, amount_per_transfer_from_this)
			user << "\blue [trans] units injected.  [reagents.total_volume] units remaining."
	return

/obj/item/weapon/reagent_containers/borghypo/attack_self(mob/user as mob)
	playsound(src.loc, 'pop.ogg', 50, 0)		//Change the mode
	if(mode == 1)
		mode = 2
		reagents.clear_reagents() //Flushes whatever was in the storage previously, so you don't get chems all mixed up.
		user << "\blue Synthesizer is now producing 'Inaprovaline'."
		return
	if(mode == 2)
		mode = 3
		reagents.clear_reagents()
		user << "\blue Synthesizer is now producing 'Spaceacillin'."
		return
	if(mode == 3)
		mode = 1
		reagents.clear_reagents()
		user << "\blue Synthesizer is now producing 'Tricordrazine'."
		return

/obj/item/weapon/reagent_containers/borghypo/examine()
	set src in view()
	..()
	if (!(usr in view(2)) && usr!=src.loc) return

	if(reagents && reagents.reagent_list.len)
		for(var/datum/reagent/R in reagents.reagent_list)
			usr << "\blue It currently has [R.volume] units of [R.name] stored."
	else
		usr << "\blue It is currently empty. Allow some time for the internal syntheszier to produce more."



/obj/item/weapon/reagent_containers/hypospray/ert
	name = "emergency hypospray"
	desc = "The DeForest Medical Corporation hypospray is a sterile, air-needle autoinjector for rapid administration of drugs to patients."
	amount_per_transfer_from_this = 50
	volume = 50

////////////////////////////////////////////////////////////////////////////////
/// Food.
////////////////////////////////////////////////////////////////////////////////
/obj/item/weapon/reagent_containers/food
	possible_transfer_amounts = null
	volume = 50 //Sets the default container amount for all food items.

	New()
		..()
		src.pixel_x = rand(-5.0, 5)						//Randomizes postion slightly.
		src.pixel_y = rand(-5.0, 5)


	proc/foodloc(var/mob/M, var/obj/item/O)
		if(O.loc == M)
			return M.loc
		else
			return O.loc

/obj/item/weapon/reagent_containers/food/snacks		//Food items that are eaten normally and don't leave anything behind.
	name = "snack"
	desc = "yummy"
	icon = 'food.dmi'
	icon_state = null
	var/bitesize = 1
	var/bitecount = 0
	var/trash = null

	//Placeholder for effect that trigger on eating that aren't tied to reagents.
	proc/On_Consume()
		if (!trash) return
		if(!reagents.total_volume)
			var/mob/M = usr
			switch(trash)
				if ("raisins")
					var/obj/item/trash/raisins/T = new /obj/item/trash/raisins/( M )
					M.put_in_hand(T)
				if ("candy")
					var/obj/item/trash/candy/T = new /obj/item/trash/candy/( M )
					M.put_in_hand(T)
				if ("cheesie")
					var/obj/item/trash/cheesie/T = new /obj/item/trash/cheesie/( M )
					M.put_in_hand(T)
				if ("chips")
					var/obj/item/trash/chips/T = new /obj/item/trash/chips/( M )
					M.put_in_hand(T)
				if ("popcorn")
					var/obj/item/trash/popcorn/T = new /obj/item/trash/popcorn/( M )
					M.put_in_hand(T)
				if ("sosjerky")
					var/obj/item/trash/sosjerky/T = new /obj/item/trash/sosjerky/( M )
					M.put_in_hand(T)
				if ("syndi_cakes")
					var/obj/item/trash/syndi_cakes/T = new /obj/item/trash/syndi_cakes/( M )
					M.put_in_hand(T)
				if ("waffles")
					var/obj/item/trash/waffles/T = new /obj/item/trash/waffles/( M )
					M.put_in_hand(T)
				if ("plate")
					var/obj/item/trash/plate/T = new /obj/item/trash/plate/( M )
					M.put_in_hand(T)
				if ("snack_bowl")
					var/obj/item/trash/snack_bowl/T = new /obj/item/trash/snack_bowl/( M )
					M.put_in_hand(T)
				if ("pistachios")
					var/obj/item/trash/pistachios/T = new /obj/item/trash/pistachios/( M )
					M.put_in_hand(T)
				if ("semki")
					var/obj/item/trash/semki/T = new /obj/item/trash/semki/( M )
					M.put_in_hand(T)
				if ("tray")
					var/obj/item/trash/tray/T = new /obj/item/trash/tray/( M )
					M.put_in_hand(T)
		return

	attackby(obj/item/weapon/W as obj, mob/user as mob)

		return
	attack_self(mob/user as mob)
		return
	attack(mob/M as mob, mob/user as mob, def_zone)
		if(!reagents.total_volume)						//Shouldn't be needed but it checks to see if it has anything left in it.
			user << "\red None of [src] left, oh no!"
			del(src)
			return 0
		if(istype(M, /mob/living/carbon))
			if(M == user)								//If you're eating it yourself.
				var/fullness = M.nutrition + (M.reagents.get_reagent_amount("nutriment") * 25)
				if (fullness <= 50)
					M << "\red You hungrily chew out a piece of [src] and gobble it!"
				if (fullness > 50 && fullness <= 150)
					M << "\blue You hungrily begin to eat [src]."
				if (fullness > 150 && fullness <= 350)
					M << "\blue You take a bite of [src]."
				if (fullness > 350 && fullness <= 550)
					M << "\blue You unwillingly chew a bit of [src]."
				if (fullness > (550 * (1 + M.overeatduration / 2000)))	// The more you eat - the more you can eat
					M << "\red You cannot force any more of [src] to go down your throat."
					return 0
			else
				if(!istype(M, /mob/living/carbon/metroid))		//If you're feeding it to someone else.
					var/fullness = M.nutrition + (M.reagents.get_reagent_amount("nutriment") * 25)
					if (fullness <= (550 * (1 + M.overeatduration / 1000)))
						for(var/mob/O in viewers(world.view, user))
							O.show_message("\red [user] attempts to feed [M] [src].", 1)
					else
						for(var/mob/O in viewers(world.view, user))
							O.show_message("\red [user] cannot force anymore of [src] down [M]'s throat.", 1)
							return 0

					if(!do_mob(user, M)) return

					M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been fed [src.name] by [user.name] ([user.ckey]) Reagents: \ref[reagents]</font>")
					user.attack_log += text("\[[time_stamp()]\] <font color='red'>Fed [M.name] by [M.name] ([M.ckey]) Reagents: \ref[reagents]</font>")
					log_admin("ATTACK: [user] ([user.ckey]) fed [M] ([M.ckey]) with [src].")
					message_admins("ATTACK: [user] ([user.ckey]) fed [M] ([M.ckey]) with [src].")

					log_attack("<font color='red'>[user.name] ([user.ckey]) fed [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>")

					for(var/mob/O in viewers(world.view, user))
						O.show_message("\red [user] feeds [M] [src].", 1)

				else
					user << "This creature does not seem to have a mouth!"
					return

			if(reagents)								//Handle ingestion of the reagent.
				if(reagents.total_volume)
					reagents.reaction(M, INGEST)
					spawn(5)
						if(reagents.total_volume > bitesize)
							/*
							 * I totally cannot understand what this code supposed to do.
							 * Right now every snack consumes in 2 bites, my popcorn does not work right, so I simplify it. -- rastaf0
							var/temp_bitesize =  max(reagents.total_volume /2, bitesize)
							reagents.trans_to(M, temp_bitesize)
							*/
							reagents.trans_to(M, bitesize)
						else
							reagents.trans_to(M, reagents.total_volume)
						bitecount++
						On_Consume()
						if(!reagents.total_volume)
							if(M == user) user << "\red You finish eating [src]."
							else user << "\red [M] finishes eating [src]."
							del(src)
							spawn(5)
								user.update_clothing()

				playsound(M.loc,'eatfood.ogg', rand(10,50), 1)
				return 1
		else if(istype(M, /mob/living/simple_animal/livestock))
			if(M == user)								//If you're eating it yourself.
				var/fullness = (M.nutrition + (M.reagents.get_reagent_amount("nutriment") * 25)) / M:max_nutrition
				if (fullness <= 0.1)
					M << "\red You hungrily chew out a piece of [src] and gobble it!"
				if (fullness > 0.1 && fullness <= 0.27)
					M << "\blue You hungrily begin to eat [src]."
				if (fullness > 0.27 && fullness <= 0.64)
					M << "\blue You take a bite of [src]."
				if (fullness > 0.64 && fullness <= 1)
					M << "\blue You unwillingly chew a bit of [src]."
				if (fullness > 1)
					M << "\red You cannot force any more of [src] to go down your throat."
					return 0
			else
				var/fullness = (M.nutrition + (M.reagents.get_reagent_amount("nutriment") * 25)) / M:max_nutrition
				if (fullness <= 1)
					for(var/mob/O in viewers(world.view, user))
						O.show_message("\red [user] attempts to feed [M] [src].", 1)
				else
					for(var/mob/O in viewers(world.view, user))
						O.show_message("\red [user] cannot force anymore of [src] down [M]'s throat.", 1)
						return 0

				if(!do_mob(user, M)) return

				M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been fed [src.name] by [user.name] ([user.ckey]) Reagents: \ref[reagents]</font>")
				user.attack_log += text("\[[time_stamp()]\] <font color='red'>Fed [M.name] by [M.name] ([M.ckey]) Reagents: \ref[reagents]</font>")
				log_admin("ATTACK: [user] ([user.ckey]) fed [M] ([M.ckey]) with [src].")
				message_admins("ATTACK: [user] ([user.ckey]) fed [M] ([M.ckey]) with [src].")

				for(var/mob/O in viewers(world.view, user))
					O.show_message("\red [user] feeds [M] [src].", 1)

			if(reagents)								//Handle ingestion of the reagent.
				if(reagents.total_volume)
					reagents.reaction(M, INGEST)
					spawn(5)
						if(reagents.total_volume > bitesize)
							/*
							 * I totally cannot understand what this code supposed to do.
							 * Right now every snack consumes in 2 bites, my popcorn does not work right, so I simplify it. -- rastaf0
							var/temp_bitesize =  max(reagents.total_volume /2, bitesize)
							reagents.trans_to(M, temp_bitesize)
							*/
							reagents.trans_to(M, bitesize)
						else
							reagents.trans_to(M, reagents.total_volume)
						bitecount++
						On_Consume()
						if(!reagents.total_volume)
							if(M == user) user << "\red You finish eating [src]."
							else user << "\red [M] finishes eating [src]."
							spawn(2)
								user.update_clothing()
							del(src)
				playsound(M.loc,'eatfood.ogg', rand(10,50), 1)
				return 1
		return 0

	attackby(obj/item/I as obj, mob/user as mob)

		return
	afterattack(obj/target, mob/user , flag)
		return

	examine()
		set src in view()
		..()
		if (!(usr in range(0)) && usr!=src.loc) return
		if (bitecount==0)
			return
		else if (bitecount==1)
			usr << "\blue \The [src] was bitten by someone!"
		else if (bitecount<=3)
			usr << "\blue \The [src] was bitten [bitecount] times!"
		else
			usr << "\blue \The [src] was bitten multiple times!"

/obj/item/weapon/reagent_containers/food/snacks
	var/slice_path
	var/slices_num

	attackby(obj/item/weapon/W as obj, mob/user as mob)

		if((slices_num <= 0 || !slices_num) || !slice_path)
			return 1
		var/inaccurate = 0
		if( \
				istype(W, /obj/item/weapon/kitchenknife) || \
				istype(W, /obj/item/weapon/butch) || \
				istype(W, /obj/item/weapon/scalpel) || \
				istype(W, /obj/item/weapon/kitchen/utensil/knife) \
			)
		else if( \
				istype(W, /obj/item/weapon/circular_saw) || \
				istype(W, /obj/item/weapon/melee/energy/sword) && W:active || \
				istype(W, /obj/item/weapon/melee/energy/blade) || \
				istype(W, /obj/item/weapon/shovel) || \
				istype(W, /obj/item/weapon/hatchet) \
			)
			inaccurate = 1
		/*else if(W.w_class <= 2 && istype(src,/obj/item/weapon/reagent_containers/food/snacks/sliceable))
			user << "\red You slip [W] inside [src]."
			user.drop_item()
			W.loc = src
			add_fingerprint(user)
			return*/
		else
			return 1
		if ( \
				!isturf(src.loc) || \
				!(locate(/obj/structure/table) in src.loc) && \
				!(locate(/obj/machinery/optable) in src.loc) && \
				!(locate(/obj/item/weapon/tray) in src.loc) \
			)
			user << "\red You cannot slice [src] here! You need a table or at least a tray to do it."
			return 1
		var/slices_lost = 0
		if (!inaccurate)
			user.visible_message( \
				"\blue [user] slices \the [src]!", \
				"\blue You slice \the [src]!" \
			)
		else
			user.visible_message( \
				"\blue [user] inaccurately slices \the [src] with [W]!", \
				"\blue You inaccurately slice \the [src] with your [W]!" \
			)
			slices_lost = rand(1,min(1,round(slices_num/2)))
		var/reagents_per_slice = reagents.total_volume/slices_num
		for(var/i=1 to (slices_num-slices_lost))
			var/obj/slice = new slice_path (src.loc)
			reagents.trans_to(slice,reagents_per_slice)
		del(src)
		return

	Del()
		if(contents)
			for(var/atom/movable/something in contents)
				something.loc = get_turf(src)
		..()


////////////////////////////////////////////////////////////////////////////////
/// FOOD END
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
/// Drinks.
////////////////////////////////////////////////////////////////////////////////
/obj/item/weapon/reagent_containers/food/drinks
	name = "drink"
	desc = "yummy"
	icon = 'drinks.dmi'
	icon_state = null
	flags = FPRINT | TABLEPASS | OPENCONTAINER
	var/gulp_size = 5 //This is now officially broken ... need to think of a nice way to fix it.
	possible_transfer_amounts = list(5,10,25)
	volume = 50

	on_reagent_change()
		if (gulp_size < 5) gulp_size = 5
		else gulp_size = max(round(reagents.total_volume / 5), 5)

	attack_self(mob/user as mob)
		return

	attack(mob/M as mob, mob/user as mob, def_zone)
		var/datum/reagents/R = src.reagents
		var/fillevel = gulp_size

		if(!R.total_volume || !R)
			user << "\red None of [src] left, oh no!"
			return 0

		if(M == user)
			M << "\blue You swallow a gulp of [src]."
			if(reagents.total_volume)
				reagents.reaction(M, INGEST)
				spawn(5)
					reagents.trans_to(M, gulp_size)

			playsound(M.loc,'drink.ogg', rand(10,50), 1)
			return 1
		else if( istype(M, /mob/living/carbon/human) )

			for(var/mob/O in viewers(world.view, user))
				O.show_message("\red [user] attempts to feed [M] [src].", 1)
			if(!do_mob(user, M)) return
			for(var/mob/O in viewers(world.view, user))
				O.show_message("\red [user] feeds [M] [src].", 1)

			M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been fed [src.name] by [user.name] ([user.ckey]) Reagents: \ref[reagents]</font>")
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Fed [M.name] by [M.name] ([M.ckey]) Reagents: \ref[reagents]</font>")
			log_admin("ATTACK: [user] ([user.ckey]) fed [M] ([M.ckey]) with [src].")
			message_admins("ATTACK: [user] ([user.ckey]) fed [M] ([M.ckey]) with [src].")

			log_attack("<font color='red'>[user.name] ([user.ckey]) fed [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>")


			if(reagents.total_volume)
				reagents.reaction(M, INGEST)
				spawn(5)
					reagents.trans_to(M, gulp_size)

			if(isrobot(user)) //Cyborg modules that include drinks automatically refill themselves, but drain the borg's cell
				var/mob/living/silicon/robot/bro = user
				bro.cell.use(30)
				var/refill = R.get_master_reagent_id()
				spawn(600)
					R.add_reagent(refill, fillevel)


			playsound(M.loc,'drink.ogg', rand(10,50), 1)
			return 1

		return 0


	afterattack(obj/target, mob/user , flag)

		if(istype(target, /obj/structure/reagent_dispensers)) //A dispenser. Transfer FROM it TO us.

			if(!target.reagents.total_volume)
				user << "\red [target] is empty."
				return

			if(reagents.total_volume >= reagents.maximum_volume)
				user << "\red [src] is full."
				return

			var/trans = target.reagents.trans_to(src, target:amount_per_transfer_from_this)
			user << "\blue You fill [src] with [trans] units of the contents of [target]."

		else if(target.is_open_container()) //Something like a glass. Player probably wants to transfer TO it.
			if(!reagents.total_volume)
				user << "\red [src] is empty."
				return

			if(target.reagents.total_volume >= target.reagents.maximum_volume)
				user << "\red [target] is full."
				return

			var/trans = src.reagents.trans_to(target, amount_per_transfer_from_this)
			user << "\blue You transfer [trans] units of the solution to [target]."

			if(isrobot(user)) //Cyborg modules that include drinks automatically refill themselves, but drain the borg's cell
				var/mob/living/silicon/robot/bro = user
				bro.cell.use(30)
				var/refill = reagents.get_master_reagent_id()
				spawn(600)
					reagents.add_reagent(refill, trans)

		return

	examine()
		set src in view()
		..()
		if (!(usr in range(0)) && usr!=src.loc) return
		if(!reagents || reagents.total_volume==0)
			usr << "\blue \The [src] is empty!"
		else if (reagents.total_volume<src.volume/4)
			usr << "\blue \The [src] is almost empty!"
		else if (reagents.total_volume<src.volume/2)
			usr << "\blue \The [src] is half full!"
		else if (reagents.total_volume<src.volume/0.90)
			usr << "\blue \The [src] is almost full!"
		else
			usr << "\blue \The [src] is full!"
////////////////////////////////////////////////////////////////////////////////
/// Drinks. END
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
/// Pills.
////////////////////////////////////////////////////////////////////////////////
/obj/item/weapon/reagent_containers/pill
	name = "pill"
	desc = "a pill."
	icon = 'chemical.dmi'
	icon_state = null
	item_state = "pill"
	possible_transfer_amounts = null
	volume = 50

	New()
		..()
		if(!icon_state)
			icon_state = "pill[rand(1,20)]"

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if (istype(W, /obj/item/weapon/storage/pill_bottle))
			var/obj/item/weapon/storage/pill_bottle/P = W
			if (P.mode == 1)
				for (var/obj/item/weapon/reagent_containers/pill/O in locate(src.x,src.y,src.z))
					if(P.contents.len < P.storage_slots)
						O.loc = P
						P.orient2hud(user)
					else
						user << "\blue The pill bottle is full."
						return
				user << "\blue You pick up all the pills."
			else
				if (P.contents.len < P.storage_slots)
					loc = P
					P.orient2hud(user)
				else
					user << "\blue The pill bottle is full."
		return
	attack_self(mob/user as mob)
		return
	attack(mob/M as mob, mob/user as mob, def_zone)
		if(M == user)
			M << "\blue You swallow [src]."
			if(reagents.total_volume)
				reagents.reaction(M, INGEST)
				spawn(5)
					reagents.trans_to(M, reagents.total_volume)
					del(src)
			else
				del(src)
			return 1

		else if(istype(M, /mob/living/carbon/human) )

			for(var/mob/O in viewers(world.view, user))
				O.show_message("\red [user] attempts to force [M] to swallow [src].", 1)

			if(!do_mob(user, M)) return

			for(var/mob/O in viewers(world.view, user))
				O.show_message("\red [user] forces [M] to swallow [src].", 1)

			M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been fed [src.name] by [user.name] ([user.ckey]) Reagents: \ref[reagents]</font>")
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Fed [M.name] by [M.name] ([M.ckey]) Reagents: \ref[reagents]</font>")
			log_admin("ATTACK: [user] ([user.ckey]) fed [M] ([M.ckey]) with [src].")
			message_admins("ATTACK: [user] ([user.ckey]) fed [M] ([M.ckey]) with [src].")


			log_attack("<font color='red'>[user.name] ([user.ckey]) fed [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>")

			if(reagents.total_volume)
				reagents.reaction(M, INGEST)
				spawn(5)
					reagents.trans_to(M, reagents.total_volume)
					del(src)
			else
				del(src)

			return 1

		return 0

	afterattack(obj/target, mob/user , flag)

		if(target.is_open_container() == 1 && target.reagents)
			if(!target.reagents.total_volume)
				user << "\red [target] is empty. Cant dissolve pill."
				return
			user << "\blue You dissolve the pill in [target]"
			reagents.trans_to(target, reagents.total_volume)
			for(var/mob/O in viewers(2, user))
				O.show_message("\red [user] puts something in [target].", 1)
			spawn(5)
				del(src)

		return

////////////////////////////////////////////////////////////////////////////////
/// Pills. END
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
/// Subtypes.
////////////////////////////////////////////////////////////////////////////////

//Glasses
/obj/item/weapon/reagent_containers/glass/bucket
	desc = "It's a bucket."
	name = "bucket"
	icon = 'janitor.dmi'
	icon_state = "bucket"
	item_state = "bucket"
	m_amt = 200
	g_amt = 0
	w_class = 3.0
	amount_per_transfer_from_this = 20
	possible_transfer_amounts = list(10,20,30,50,70)
	volume = 70
	flags = FPRINT | OPENCONTAINER

	attackby(var/obj/D, mob/user as mob)
		if(isprox(D))
			var/obj/item/weapon/bucket_sensor/B = new /obj/item/weapon/bucket_sensor(user.loc)
			B.layer = 20
			user << "You add the sensor to the bucket"
			del(D)
			del(src)

/obj/item/weapon/reagent_containers/glass/bucket/wateringcan
	name = "watering can"
	desc = "A watering can, for all your watering needs."
	icon = 'hydroponics.dmi'
	icon_state = "watercan"
	item_state = "bucket"

	attackby(var/obj/D, mob/user as mob)
		if(isprox(D))
			return

/obj/item/weapon/reagent_containers/glass/cantister
	desc = "It's a canister. Mainly used for transporting fuel."
	name = "canister"
	icon = 'tank.dmi'
	icon_state = "canister"
	item_state = "canister"
	m_amt = 300
	g_amt = 0
	w_class = 4.0

	amount_per_transfer_from_this = 20
	possible_transfer_amounts = list(10,20,30,60)
	volume = 120
	flags = FPRINT


/obj/item/weapon/reagent_containers/glass/dispenser
	name = "reagent glass"
	desc = "A reagent glass."
	icon = 'chemical.dmi'
	icon_state = "beaker0"
	amount_per_transfer_from_this = 10
	flags = FPRINT | TABLEPASS | OPENCONTAINER

/obj/item/weapon/reagent_containers/glass/dispenser/surfactant
	name = "reagent glass (surfactant)"
	icon_state = "liquid"

	New()
		..()
		reagents.add_reagent("fluorosurfactant", 20)

/obj/item/weapon/reagent_containers/glass/beaker
	name = "beaker"
	desc = "A beaker. Can hold up to 50 units."
	icon = 'chemical.dmi'
	icon_state = "beaker0"
	item_state = "beaker"
	m_amt = 0
	g_amt = 500

	pickup(mob/user)
		on_reagent_change(user)

	dropped(mob/user)
		on_reagent_change()

	on_reagent_change(var/mob/user)
		/*
		if(reagents.total_volume)
			icon_state = "beaker1"
		else
			icon_state = "beaker0"
		*/
		overlays = null

		if(reagents.total_volume)
			var/obj/effect/overlay = new/obj
			overlay.icon = 'beaker1.dmi'
			var/percent = round((reagents.total_volume / volume) * 100)
			switch(percent)
				if(0 to 9)		overlay.icon_state = "-10"
				if(10 to 24) 	overlay.icon_state = "10"
				if(25 to 49)	overlay.icon_state = "25"
				if(50 to 74)	overlay.icon_state = "50"
				if(75 to 79)	overlay.icon_state = "75"
				if(80 to 90)	overlay.icon_state = "80"
				if(91 to 100)	overlay.icon_state = "100"

			var/list/rgbcolor = list(0,0,0)
			var/finalcolor
			for(var/datum/reagent/re in reagents.reagent_list) // natural color mixing bullshit/algorithm
				if(!finalcolor)
					rgbcolor = GetColors(re.color)
					finalcolor = re.color
				else
					var/newcolor[3]
					var/prergbcolor[3]
					prergbcolor = rgbcolor
					newcolor = GetColors(re.color)

					rgbcolor[1] = (prergbcolor[1]+newcolor[1])/2
					rgbcolor[2] = (prergbcolor[2]+newcolor[2])/2
					rgbcolor[3] = (prergbcolor[3]+newcolor[3])/2

					finalcolor = rgb(rgbcolor[1], rgbcolor[2], rgbcolor[3])
					// This isn't a perfect color mixing system, the more reagents that are inside,
					// the darker it gets until it becomes absolutely pitch black! I dunno, maybe
					// that's pretty realistic? I don't do a whole lot of color-mixing anyway.
					// If you add brighter colors to it it'll eventually get lighter, though.

			overlay.icon += finalcolor
			if(user || !istype(src.loc, /turf))
				overlay.layer = 30
			overlays += overlay


/obj/item/weapon/reagent_containers/glass/blender_jug
	name = "Blender Jug"
	desc = "A blender jug, part of a blender."
	icon = 'kitchen.dmi'
	icon_state = "blender_jug_e"
	volume = 100

	on_reagent_change()
		switch(src.reagents.total_volume)
			if(0)
				icon_state = "blender_jug_e"
			if(1 to 75)
				icon_state = "blender_jug_h"
			if(76 to 100)
				icon_state = "blender_jug_f"

/obj/item/weapon/reagent_containers/glass/large
	name = "large reagent glass"
	desc = "A large reagent glass. Can hold up to 100 units."
	icon = 'chemical.dmi'
	icon_state = "beakerlarge"
	item_state = "beaker"
	m_amt = 0
	g_amt = 5000
	volume = 100
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,25,30,50,100)
	flags = FPRINT | TABLEPASS | OPENCONTAINER


	pickup(mob/user)
		on_reagent_change(user)

	dropped(mob/user)
		on_reagent_change()

	on_reagent_change(var/mob/user)
		overlays = null

		if(reagents.total_volume)

			var/obj/effect/overlay = new/obj
			overlay.icon = 'beaker2.dmi'
			var/percent = round((reagents.total_volume / volume) * 100)
			switch(percent)
				if(0 to 9)		overlay.icon_state = "-10"
				if(10 to 24) 	overlay.icon_state = "10"
				if(25 to 49)	overlay.icon_state = "25"
				if(50 to 74)	overlay.icon_state = "50"
				if(75 to 79)	overlay.icon_state = "75"
				if(80 to 90)	overlay.icon_state = "80"
				if(91 to 100)	overlay.icon_state = "100"

			var/list/rgbcolor = list(0,0,0)
			var/finalcolor
			for(var/datum/reagent/re in reagents.reagent_list) // natural color mixing bullshit/algorithm
				if(!finalcolor)
					rgbcolor = GetColors(re.color)
					finalcolor = re.color
				else
					var/newcolor[3]
					var/prergbcolor[3]
					prergbcolor = rgbcolor
					newcolor = GetColors(re.color)

					rgbcolor[1] = (prergbcolor[1]+newcolor[1])/2
					rgbcolor[2] = (prergbcolor[2]+newcolor[2])/2
					rgbcolor[3] = (prergbcolor[3]+newcolor[3])/2

					finalcolor = rgb(rgbcolor[1], rgbcolor[2], rgbcolor[3])
					// This isn't a perfect color mixing system, the more reagents that are inside,
					// the darker it gets until it becomes absolutely pitch black! I dunno, maybe
					// that's pretty realistic? I don't do a whole lot of color-mixing anyway.
					// If you add brighter colors to it it'll eventually get lighter, though.

			overlay.icon += finalcolor
			if(user || !istype(src.loc, /turf))
				overlay.layer = 30
			overlays += overlay

/obj/item/weapon/reagent_containers/glass/bottle
	name = "bottle"
	desc = "A small bottle."
	icon = 'chemical.dmi'
	icon_state = null
	item_state = "atoxinbottle"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,25,30)
	flags = FPRINT | TABLEPASS | OPENCONTAINER
	volume = 50

	New()
		..()
		if(!icon_state)
			icon_state = "bottle[rand(1,20)]"

/obj/item/weapon/reagent_containers/glass/bottle/inaprovaline
	name = "inaprovaline bottle"
	desc = "A small bottle. Contains inaprovaline - used to stabilize patients."
	icon = 'chemical.dmi'
	icon_state = "bottle16"

	New()
		..()
		reagents.add_reagent("inaprovaline", 30)

/obj/item/weapon/reagent_containers/glass/bottle/toxin
	name = "toxin bottle"
	desc = "A small bottle of toxins. Do not drink, it is poisonous."
	icon = 'chemical.dmi'
	icon_state = "bottle12"

	New()
		..()
		reagents.add_reagent("toxin", 30)

/*/obj/item/weapon/reagent_containers/glass/bottle/cyanide
	name = "cyanide bottle"
	desc = "A small bottle of cyanide. Bitter almonds?"
	icon = 'chemical.dmi'
	icon_state = "bottle12"

	New()
		..()
		reagents.add_reagent("cyanide", 30)	*/

/obj/item/weapon/reagent_containers/glass/bottle/stoxin
	name = "sleep-toxin bottle"
	desc = "A small bottle of sleep toxins. Just the fumes make you sleepy."
	icon = 'chemical.dmi'
	icon_state = "bottle20"

	New()
		..()
		reagents.add_reagent("stoxin", 30)

/obj/item/weapon/reagent_containers/glass/bottle/chloralhydrate
	name = "Chloral Hydrate Bottle"
	desc = "A small bottle of Choral Hydrate. Mickey's Favorite!"
	icon = 'chemical.dmi'
	icon_state = "bottle20"

	New()
		..()
		reagents.add_reagent("chloralhydrate", 15)		//Intentionally low since it is so strong. Still enough to knock someone out.

/obj/item/weapon/reagent_containers/glass/bottle/antitoxin
	name = "anti-toxin bottle"
	desc = "A small bottle of Anti-toxins. Counters poisons, and repairs damage, a wonder drug."
	icon = 'chemical.dmi'
	icon_state = "bottle17"

	New()
		..()
		reagents.add_reagent("anti_toxin", 30)

/obj/item/weapon/reagent_containers/glass/bottle/ammonia
	name = "ammonia bottle"
	desc = "A small bottle."
	icon = 'chemical.dmi'
	icon_state = "bottle20"

	New()
		..()
		reagents.add_reagent("ammonia", 30)

/obj/item/weapon/reagent_containers/glass/bottle/diethylamine
	name = "diethylamine bottle"
	desc = "A small bottle."
	icon = 'chemical.dmi'
	icon_state = "bottle17"

	New()
		..()
		reagents.add_reagent("diethylamine", 30)

/obj/item/weapon/reagent_containers/glass/bottle/flu_virion
	name = "Flu virion culture bottle"
	desc = "A small bottle. Contains H13N1 flu virion culture in synthblood medium."
	icon = 'chemical.dmi'
	icon_state = "bottle3"
	New()
		..()
		var/datum/disease/F = new /datum/disease/flu(0)
		var/list/data = list("viruses"= list(F))
		reagents.add_reagent("blood", 20, data)

/obj/item/weapon/reagent_containers/glass/bottle/pierrot_throat
	name = "Pierrot's Throat culture bottle"
	desc = "A small bottle. Contains H0NI<42 virion culture in synthblood medium."
	icon = 'chemical.dmi'
	icon_state = "bottle3"
	New()
		..()
		var/datum/disease/F = new /datum/disease/pierrot_throat(0)
		var/list/data = list("viruses"= list(F))
		reagents.add_reagent("blood", 20, data)

/obj/item/weapon/reagent_containers/glass/bottle/cold
	name = "Rhinovirus culture bottle"
	desc = "A small bottle. Contains XY-rhinovirus culture in synthblood medium."
	icon = 'chemical.dmi'
	icon_state = "bottle3"
	New()
		..()
		var/datum/disease/F = new /datum/disease/cold(0)
		var/list/data = list("viruses"= list(F))
		reagents.add_reagent("blood", 20, data)

/obj/item/weapon/reagent_containers/glass/bottle/retrovirus
	name = "Retrovirus culture bottle"
	desc = "A small bottle. Contains a retrovirus culture in a synthblood medium."
	icon = 'chemical.dmi'
	icon_state = "bottle3"
	New()
		..()
		var/datum/disease/F = new /datum/disease/dna_retrovirus(0)
		var/list/data = list("viruses"= list(F))
		reagents.add_reagent("blood", 20, data)


/obj/item/weapon/reagent_containers/glass/bottle/gbs
	name = "GBS culture bottle"
	desc = "A small bottle. Contains Gravitokinetic Bipotential SADS+ culture in synthblood medium."//Or simply - General BullShit
	icon = 'chemical.dmi'
	icon_state = "bottle3"
	amount_per_transfer_from_this = 5

	New()
		var/datum/reagents/R = new/datum/reagents(20)
		reagents = R
		R.my_atom = src
		var/datum/disease/F = new /datum/disease/gbs
		var/list/data = list("virus"= F)
		R.add_reagent("blood", 20, data)

/obj/item/weapon/reagent_containers/glass/bottle/fake_gbs
	name = "GBS culture bottle"
	desc = "A small bottle. Contains Gravitokinetic Bipotential SADS- culture in synthblood medium."//Or simply - General BullShit
	icon = 'chemical.dmi'
	icon_state = "bottle3"
	New()
		..()
		var/datum/disease/F = new /datum/disease/fake_gbs(0)
		var/list/data = list("viruses"= list(F))
		reagents.add_reagent("blood", 20, data)
/*
/obj/item/weapon/reagent_containers/glass/bottle/rhumba_beat
	name = "Rhumba Beat culture bottle"
	desc = "A small bottle. Contains The Rhumba Beat culture in synthblood medium."//Or simply - General BullShit
	icon = 'chemical.dmi'
	icon_state = "bottle3"
	amount_per_transfer_from_this = 5

	New()
		var/datum/reagents/R = new/datum/reagents(20)
		reagents = R
		R.my_atom = src
		var/datum/disease/F = new /datum/disease/rhumba_beat
		var/list/data = list("virus"= F)
		R.add_reagent("blood", 20, data)
*/

/obj/item/weapon/reagent_containers/glass/bottle/brainrot
	name = "Brainrot culture bottle"
	desc = "A small bottle. Contains Cryptococcus Cosmosis culture in synthblood medium."
	icon = 'chemical.dmi'
	icon_state = "bottle3"
	New()
		..()
		var/datum/disease/F = new /datum/disease/brainrot(0)
		var/list/data = list("viruses"= list(F))
		reagents.add_reagent("blood", 20, data)

/obj/item/weapon/reagent_containers/glass/bottle/magnitis
	name = "Magnitis culture bottle"
	desc = "A small bottle. Contains a small dosage of Fukkos Miracos."
	icon = 'chemical.dmi'
	icon_state = "bottle3"
	New()
		..()
		var/datum/disease/F = new /datum/disease/magnitis(0)
		var/list/data = list("viruses"= list(F))
		reagents.add_reagent("blood", 20, data)


/obj/item/weapon/reagent_containers/glass/bottle/wizarditis
	name = "Wizarditis culture bottle"
	desc = "A small bottle. Contains a sample of Rincewindus Vulgaris."
	icon = 'chemical.dmi'
	icon_state = "bottle3"
	New()
		..()
		var/datum/disease/F = new /datum/disease/wizarditis(0)
		var/list/data = list("viruses"= list(F))
		reagents.add_reagent("blood", 20, data)

/obj/item/weapon/reagent_containers/glass/bottle/pacid
	name = "Polytrinic Acid Bottle"
	desc = "A small bottle. Contains a small amount of Polytrinic Acid"
	icon = 'chemical.dmi'
	icon_state = "bottle17"
	New()
		..()
		reagents.add_reagent("pacid", 30)

/obj/item/weapon/reagent_containers/glass/bottle/adminordrazine
	name = "Adminordrazine Bottle"
	desc = "A small bottle. Contains the liquid essence of the gods."
	icon = 'drinks.dmi'
	icon_state = "holyflask"
	New()
		..()
		reagents.add_reagent("adminordrazine", 30)


/obj/item/weapon/reagent_containers/glass/bottle/ert
	name = "emergency medicine bottle"
	desc = "A large bottle."
	icon = 'chemical.dmi'
	icon_state = "bottle3"
	item_state = "atoxinbottle"
	amount_per_transfer_from_this = 50
	possible_transfer_amounts = null
	flags = FPRINT | TABLEPASS | OPENCONTAINER
	volume = 50

	New()
		..()
		if(!icon_state)
			icon_state = "bottle[rand(1,20)]"

/obj/item/weapon/reagent_containers/glass/bottle/ert/quikheal
	name = "Quikheal bottle"
	desc = "Seems to be a strange mix of delicious goodness. Smells woozy."

	New()
		..()
		reagents.add_reagent("bicaridine", 8)
		reagents.add_reagent("dexalinp", 5)
		reagents.add_reagent("dermaline", 8)
		reagents.add_reagent("arithrazine", 8)
		reagents.add_reagent("inaprovaline", 8)
		reagents.add_reagent("cryptobiolin", 13)

/obj/item/weapon/reagent_containers/glass/bottle/ert/boost
	name = "Combat Boost bottle"
	desc = "Seems to be a strange mix of delicious goodness. It... Pulses slightly before your eyes."

	New()
		..()
		reagents.add_reagent("hyperzine", 10)
		reagents.add_reagent("dermaline", 10)
		reagents.add_reagent("leporazine", 10)
		reagents.add_reagent("bicaridine", 10)
		reagents.add_reagent("mutagen", 10)

/obj/item/weapon/reagent_containers/glass/bottle/ert/cryo
	name = "Cryo-in-a-bottle"
	desc = "Seems to be a strange mix of delicious goodness. It's freezing cold to the touch."

	New()
		..()
		reagents.add_reagent("clonexadone", 25)
		reagents.add_reagent("liquidnitrogen", 15)
		reagents.add_reagent("chloralhydrate", 10)


/obj/item/weapon/reagent_containers/glass/beaker/cryoxadone
	name = "beaker"
	desc = "A beaker. Can hold up to 50 units."
	icon = 'chemical.dmi'
	icon_state = "beaker0"
	item_state = "beaker"

	New()
		..()
		reagents.add_reagent("cryoxadone", 30)

/obj/item/weapon/reagent_containers/glass/beaker/tricordrazine
	name = "beaker"
	desc = "A beaker. Can hold up to 50 units."
	icon = 'chemical.dmi'
	icon_state = "beaker0"
	item_state = "beaker"

	New()
		..()
		reagents.add_reagent("tricordrazine", 30)

/obj/item/weapon/reagent_containers/food/drinks/golden_cup
	desc = "A golden cup"
	name = "golden cup"
	icon_state = "golden_cup"
	item_state = "" //nope :(
	w_class = 4
	force = 14
	throwforce = 10
	amount_per_transfer_from_this = 20
	possible_transfer_amounts = null
	volume = 150
	flags = FPRINT | CONDUCT | TABLEPASS | OPENCONTAINER

/obj/item/weapon/reagent_containers/food/drinks/golden_cup/tournament_26_06_2011
	desc = "A golden cup. It will be presented to a winner of tournament 26 june and name of the winner will be graved on it."

//Syringes
/obj/item/weapon/reagent_containers/syringe/robot/antitoxin
	name = "Syringe (anti-toxin)"
	desc = "Contains anti-toxins."
	New()
		..()
		reagents.add_reagent("anti_toxin", 15)
		mode = SYRINGE_INJECT
		update_icon()

/obj/item/weapon/reagent_containers/syringe/robot/inaprovaline
	name = "Syringe (inaprovaline)"
	desc = "Contains inaprovaline - used to stabilize patients."
	New()
		..()
		reagents.add_reagent("inaprovaline", 15)
		mode = SYRINGE_INJECT
		update_icon()

/obj/item/weapon/reagent_containers/syringe/robot/mixed
	name = "Syringe (mixed)"
	desc = "Contains inaprovaline & anti-toxins."
	New()
		..()
		reagents.add_reagent("inaprovaline", 7)
		reagents.add_reagent("anti_toxin", 8)
		mode = SYRINGE_INJECT
		update_icon()

/obj/item/weapon/reagent_containers/syringe/inaprovaline
	name = "Syringe (inaprovaline)"
	desc = "Contains inaprovaline - used to stabilize patients."
	New()
		..()
		reagents.add_reagent("inaprovaline", 15)
		mode = SYRINGE_INJECT
		update_icon()

/obj/item/weapon/reagent_containers/syringe/antitoxin
	name = "Syringe (anti-toxin)"
	desc = "Contains anti-toxins."
	New()
		..()
		reagents.add_reagent("anti_toxin", 15)
		mode = SYRINGE_INJECT
		update_icon()

/obj/item/weapon/reagent_containers/syringe/antiviral
	name = "Syringe (spaceacillin)"
	desc = "Contains antiviral agents."
	New()
		..()
		reagents.add_reagent("spaceacillin", 15)
		mode = SYRINGE_INJECT
		update_icon()

/obj/item/weapon/reagent_containers/ld50_syringe/choral
	New()
		..()
		reagents.add_reagent("chloralhydrate", 50)
		mode = SYRINGE_INJECT
		update_icon()

////////////////////////////////////////////////////////////////////////////////
/// Concrete food moved to code/modules/food/food.dm
/////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////Condiments
//Notes by Darem: The condiments food-subtype is for stuff you don't actually eat but you use to modify existing food. They all
//	leave empty containers when used up and can be filled/re-filled with other items. Formatting for first section is identical
//	to mixed-drinks code. If you want an object that starts pre-loaded, you need to make it in addition to the other code.

/obj/item/weapon/reagent_containers/food/condiment	//Food items that aren't eaten normally and leave an empty container behind.
	name = "Condiment Container"
	desc = "Just your average condiment container."
	icon = 'food.dmi'
	icon_state = "emptycondiment"
	flags = FPRINT | TABLEPASS | OPENCONTAINER
	possible_transfer_amounts = list(1,5,10)
	volume = 50

	attackby(obj/item/weapon/W as obj, mob/user as mob)

		return
	attack_self(mob/user as mob)
		return
	attack(mob/M as mob, mob/user as mob, def_zone)
		var/datum/reagents/R = src.reagents

		if(!R || !R.total_volume)
			user << "\red None of [src] left, oh no!"
			return 0

		if(M == user)
			M << "\blue You swallow some of contents of the [src]."
			if(reagents.total_volume)
				reagents.reaction(M, INGEST)
				spawn(5)
					reagents.trans_to(M, 10)

			playsound(M.loc,'drink.ogg', rand(10,50), 1)
			return 1
		else if( istype(M, /mob/living/carbon/human) )

			for(var/mob/O in viewers(world.view, user))
				O.show_message("\red [user] attempts to feed [M] [src].", 1)
			if(!do_mob(user, M)) return
			for(var/mob/O in viewers(world.view, user))
				O.show_message("\red [user] feeds [M] [src].", 1)

			M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been fed [src.name] by [user.name] ([user.ckey]) Reagents: \ref[reagents]</font>")
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Fed [src.name] by [M.name] ([M.ckey]) Reagents: \ref[reagents]</font>")
			log_admin("ATTACK: [user] ([user.ckey]) fed [M] ([M.ckey]) with [src].")
			message_admins("ATTACK: [user] ([user.ckey]) fed [M] ([M.ckey]) with [src].")


			log_attack("<font color='red'>[user.name] ([user.ckey]) fed [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>")

			if(reagents.total_volume)
				reagents.reaction(M, INGEST)
				spawn(5)
					reagents.trans_to(M, 10)

			playsound(M.loc,'drink.ogg', rand(10,50), 1)
			return 1
		return 0

	attackby(obj/item/I as obj, mob/user as mob)

		return

	afterattack(obj/target, mob/user , flag)
		if(istype(target, /obj/structure/reagent_dispensers)) //A dispenser. Transfer FROM it TO us.

			if(!target.reagents.total_volume)
				user << "\red [target] is empty."
				return

			if(reagents.total_volume >= reagents.maximum_volume)
				user << "\red [src] is full."
				return

			var/trans = target.reagents.trans_to(src, target:amount_per_transfer_from_this)
			user << "\blue You fill [src] with [trans] units of the contents of [target]."

		//Something like a glass or a food item. Player probably wants to transfer TO it.
		else if(target.is_open_container() || istype(target, /obj/item/weapon/reagent_containers/food/snacks))
			if(!reagents.total_volume)
				user << "\red [src] is empty."
				return
			if(target.reagents.total_volume >= target.reagents.maximum_volume)
				user << "\red you can't add anymore to [target]."
				return
			var/trans = src.reagents.trans_to(target, amount_per_transfer_from_this)
			user << "\blue You transfer [trans] units of the condiment to [target]."

	on_reagent_change()
		if(icon_state == "saltshakersmall" || icon_state == "peppermillsmall")
			return
		if(reagents.reagent_list.len > 0)
			switch(reagents.get_master_reagent_id())
				if("ketchup")
					name = "Ketchup"
					desc = "You feel more American already."
					icon_state = "ketchup"
				if("capsaicin")
					name = "Hotsauce"
					desc = "You can almost TASTE the stomach ulcers now!"
					icon_state = "hotsauce"
				if("enzyme")
					name = "Universal Enzyme"
					desc = "Used in cooking various dishes."
					icon_state = "enzyme"
				if("soysauce")
					name = "Soy Sauce"
					desc = "A salty soy-based flavoring."
					icon_state = "soysauce"
				if("frostoil")
					name = "Coldsauce"
					desc = "Leaves the tongue numb in its passage."
					icon_state = "coldsauce"
				if("sodiumchloride")
					name = "Salt Shaker"
					desc = "Salt. From space oceans, presumably."
					icon_state = "saltshaker"
				if("blackpepper")
					name = "Pepper Mill"
					desc = "Often used to flavor food or make people sneeze."
					icon_state = "peppermillsmall"
				if("cornoil")
					name = "Corn Oil"
					desc = "A delicious oil used in cooking. Made from corn."
					icon_state = "oliveoil"
				if("sugar")
					name = "Sugar"
					desc = "Tastey space sugar!"
				else
					name = "Misc Condiment Bottle"
					if (reagents.reagent_list.len==1)
						desc = "Looks like it is [reagents.get_master_reagent_name()], but you are not sure."
					else
						desc = "A mixture of various condiments. [reagents.get_master_reagent_name()] is one of them."
					icon_state = "mixedcondiments"
		else
			icon_state = "emptycondiment"
			name = "Condiment Bottle"
			desc = "An empty condiment bottle."
			return

/obj/item/weapon/reagent_containers/food/condiment/enzyme
	name = "Universal Enzyme"
	desc = "Used in cooking various dishes."
	icon_state = "enzyme"
	New()
		..()
		reagents.add_reagent("enzyme", 50)

/obj/item/weapon/reagent_containers/food/condiment/sugar
	New()
		..()
		reagents.add_reagent("sugar", 50)

/obj/item/weapon/reagent_containers/food/condiment/saltshaker		//Seperate from above since it's a small shaker rather then
	name = "Salt Shaker"											//	a large one.
	desc = "Salt. From space oceans, presumably."
	icon_state = "saltshakersmall"
	possible_transfer_amounts = list(1,20) //for clown turning the lid off
	amount_per_transfer_from_this = 1
	volume = 20
	New()
		..()
		reagents.add_reagent("sodiumchloride", 20)

/obj/item/weapon/reagent_containers/food/condiment/peppermill
	name = "Pepper Mill"
	desc = "Often used to flavor food or make people sneeze."
	icon_state = "peppermillsmall"
	possible_transfer_amounts = list(1,20) //for clown turning the lid off
	amount_per_transfer_from_this = 1
	volume = 20
	New()
		..()
		reagents.add_reagent("blackpepper", 20)


///////////////////////////////////////////////Drinks
//Notes by Darem: Drinks are simply containers that start preloaded. Unlike condiments, the contents can be ingested directly
//	rather then having to add it to something else first. They should only contain liquids. They have a default container size of 50.
//	Formatting is the same as food.

/obj/item/weapon/reagent_containers/food/drinks/milk
	name = "Space Milk"
	desc = "It's milk. White and nutritious goodness!"
	icon_state = "milk"
	New()
		..()
		reagents.add_reagent("milk", 50)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/soymilk
	name = "SoyMilk"
	desc = "It's soy milk. White and nutritious goodness!"
	icon_state = "soymilk"
	New()
		..()
		reagents.add_reagent("soymilk", 50)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/coffee
	name = "Robust Coffee"
	desc = "Careful, the beverage you're about to enjoy is extremely hot."
	icon_state = "coffee"
	New()
		..()
		reagents.add_reagent("coffee", 30)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/tea
	name = "Duke Purple Tea"
	desc = "A refreshingly quaint drink, served piping hot."
	icon_state = "tea"
	New()
		..()
		reagents.add_reagent("tea", 30)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/ice
	name = "Ice Cup"
	desc = "Careful, cold ice, do not chew."
	icon_state = "coffee"
	New()
		..()
		reagents.add_reagent("ice", 30)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/h_chocolate
	name = "Dutch Hot Coco"
	desc = "Made in Space South America."
	icon_state = "hotchocolate"
	New()
		..()
		reagents.add_reagent("hot_coco", 30)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/dry_ramen
	name = "Cup Ramen"
	desc = "Just add 10ml water, self heats! A taste that reminds you of your school years."
	icon_state = "ramen"
	New()
		..()
		reagents.add_reagent("dry_ramen", 30)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/cola
	name = "Space Cola"
	desc = "Cola. in space."
	icon_state = "cola"
	New()
		..()
		reagents.add_reagent("cola", 30)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/beer
	name = "Space Beer"
	desc = "Beer. In space."
	icon_state = "beer"
	New()
		..()
		reagents.add_reagent("beer", 30)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/ale
	name = "Magm-Ale"
	desc = "A true dorf's drink of choice."
	icon_state = "alebottle"
	New()
		..()
		reagents.add_reagent("ale", 30)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/space_mountain_wind
	name = "Space Mountain Wind"
	desc = "Blows right through you like a space wind."
	icon_state = "space_mountain_wind"
	New()
		..()
		reagents.add_reagent("spacemountainwind", 30)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/thirteenloko
	name = "Thirteen Loko"
	desc = "The CMO has advised crew members that consumption of Thirteen Loko may result in seizures, blindness, drunkeness, or even death. Please Drink Responsably."
	icon_state = "thirteen_loko"
	New()
		..()
		reagents.add_reagent("thirteenloko", 30)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/dr_gibb
	name = "Dr. Gibb"
	desc = "A delicious mixture of 42 different flavors."
	icon_state = "dr_gibb"
	New()
		..()
		reagents.add_reagent("dr_gibb", 30)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/starkist
	name = "Star-kist"
	desc = "The taste of a star in liquid form. And, a bit of tuna...?"
	icon_state = "starkist"
	New()
		..()
		reagents.add_reagent("cola", 15)
		reagents.add_reagent("orangejuice", 15)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/space_up
	name = "Space-Up"
	desc = "Tastes like a hull breach in your mouth."
	icon_state = "space-up"
	New()
		..()
		reagents.add_reagent("space_up", 30)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/lemon_lime
	name = "Lemon-Lime"
	desc = "You wanted ORANGE. It gave you Lemon Lime."
	icon_state = "lemon-lime"
	New()
		..()
		reagents.add_reagent("lemon_lime", 30)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/waterbottle
	name = "water bottle"
	desc = "Straight from the ice lakes of Mars!"
	icon_state = "waterbottle"
	New()
		..()
		reagents.add_reagent("water", 30)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/sillycup
	name = "Paper Cup"
	desc = "A paper water cup."
	icon_state = "water_cup_e"
	possible_transfer_amounts = null
	volume = 10
	New()
		..()
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)
	on_reagent_change()
		if(reagents.total_volume)
			icon_state = "water_cup"
		else
			icon_state = "water_cup_e"

///////////////////////////////////////////////Alchohol bottles! -Agouri //////////////////////////
//Notes by Darem: Functionally identical to regular drinks. The only difference is that the default bottle size is 100.
/obj/item/weapon/reagent_containers/food/drinks/bottle
	amount_per_transfer_from_this = 10
	volume = 100

/obj/item/weapon/reagent_containers/food/drinks/bottle/gin
	name = "Griffeater Gin"
	desc = "A bottle of high quality gin, produced in the New London Space Station."
	icon_state = "ginbottle"
	New()
		..()
		reagents.add_reagent("gin", 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/whiskey
	name = "Uncle Git's Special Reserve"
	desc = "A premium single-malt whiskey, gently matured inside the tunnels of a nuclear shelter. TUNNEL WHISKEY RULES."
	icon_state = "whiskeybottle"
	New()
		..()
		reagents.add_reagent("whiskey", 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/vodka
	name = "Tunguska Triple Distilled"
	desc = "Aah, vodka. Prime choice of drink AND fuel by Russians worldwide."
	icon_state = "vodkabottle"
	New()
		..()
		reagents.add_reagent("vodka", 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/tequilla
	name = "Caccavo Guaranteed Quality Tequilla"
	desc = "Made from premium petroleum distillates, pure thalidomide and other fine quality ingredients!"
	icon_state = "tequillabottle"
	New()
		..()
		reagents.add_reagent("tequilla", 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/bottleofnothing
	name = "Bottle of Nothing"
	desc = "A bottle filled with nothing"
	icon_state = "bottleofnothing"
	New()
		..()
		reagents.add_reagent("nothing", 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/patron
	name = "Wrapp Artiste Patron"
	desc = "Silver laced tequilla, served in space night clubs across the galaxy."
	icon_state = "patronbottle"
	New()
		..()
		reagents.add_reagent("patron", 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/rum
	name = "Captain Pete's Cuban Spiced Rum"
	desc = "This isn't just rum, oh no. It's practically GRIFF in a bottle."
	icon_state = "rumbottle"
	New()
		..()
		reagents.add_reagent("rum", 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/holywater
	name = "Flask of Holy Water"
	desc = "A flask of the chaplain's holy water."
	icon_state = "holyflask"
	New()
		..()
		reagents.add_reagent("holywater", 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/vermouth
	name = "Goldeneye Vermouth"
	desc = "Sweet, sweet dryness~"
	icon_state = "vermouthbottle"
	New()
		..()
		reagents.add_reagent("vermouth", 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/kahlua
	name = "Robert Robust's Coffee Liqueur"
	desc = "A widely known, Mexican coffee-flavoured liqueur. In production since 1936, HONK"
	icon_state = "kahluabottle"
	New()
		..()
		reagents.add_reagent("kahlua", 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/goldschlager
	name = "College Girl Goldschlager"
	desc = "Because they are the only ones who will drink 100 proof cinnamon schnapps."
	icon_state = "goldschlagerbottle"
	New()
		..()
		reagents.add_reagent("goldschlager", 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/cognac
	name = "Chateau De Baton Premium Cognac"
	desc = "A sweet and strongly alchoholic drink, made after numerous distillations and years of maturing. You might as well not scream 'SHITCURITY' this time."
	icon_state = "cognacbottle"
	New()
		..()
		reagents.add_reagent("cognac", 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/wine
	name = "Doublebeard Bearded Special Wine"
	desc = "A faint aura of unease and asspainery surrounds the bottle."
	icon_state = "winebottle"
	New()
		..()
		reagents.add_reagent("wine", 100)

//////////////////////////JUICES AND STUFF ///////////////////////

/obj/item/weapon/reagent_containers/food/drinks/bottle/orangejuice
	name = "Orange Juice"
	desc = "Full of vitamins and deliciousness!"
	icon_state = "orangejuice"
	New()
		..()
		reagents.add_reagent("orangejuice", 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/cream
	name = "Milk Cream"
	desc = "It's cream. Made from milk. What else did you think you'd find in there?"
	icon_state = "cream"
	New()
		..()
		reagents.add_reagent("cream", 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/tomatojuice
	name = "Tomato Juice"
	desc = "Well, at least it LOOKS like tomato juice. You can't tell with all that redness."
	icon_state = "tomatojuice"
	New()
		..()
		reagents.add_reagent("tomatojuice", 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/limejuice
	name = "Lime Juice"
	desc = "Sweet-sour goodness."
	icon_state = "limejuice"
	New()
		..()
		reagents.add_reagent("limejuice", 100)

/obj/item/weapon/reagent_containers/food/drinks/tonic
	name = "T-Borg's Tonic Water"
	desc = "Quinine tastes funny, but at least it'll keep that Space Malaria away."
	icon_state = "tonic"
	New()
		..()
		reagents.add_reagent("tonic", 50)

/obj/item/weapon/reagent_containers/food/drinks/sodawater
	name = "Soda Water"
	desc = "A can of soda water. Why not make a scotch and soda?"
	icon_state = "sodawater"
	New()
		..()
		reagents.add_reagent("sodawater", 50)

////////////////////////// PILLS ///////////////////////

/obj/item/weapon/reagent_containers/pill/antitox
	name = "Anti-toxins pill"
	desc = "Neutralizes many common toxins."
	icon_state = "pill17"
	New()
		..()
		reagents.add_reagent("anti_toxin", 50)

/obj/item/weapon/reagent_containers/pill/antitox/tajaran
	name = "peacebody plant powder"
	desc = "A powder ingested to rid the body of poisons."
	icon = 'food.dmi'
	icon_state = "nettlesoup"
	New()
		..()
		reagents.add_reagent("anti_toxin", 100)

/obj/item/weapon/reagent_containers/pill/tox
	name = "Toxins pill"
	desc = "Highly toxic."
	icon_state = "pill5"
	New()
		..()
		reagents.add_reagent("toxin", 50)

/obj/item/weapon/reagent_containers/pill/cyanide
	name = "Suicide pill"
	desc = "Don't swallow this."
	icon_state = "pill5"
	New()
		..()
		reagents.add_reagent("chloralhydrate", 100)

/obj/item/weapon/reagent_containers/pill/adminordrazine
	name = "Adminordrazine pill"
	desc = "It's magic. We don't have to explain it."
	icon_state = "pill16"
	New()
		..()
		reagents.add_reagent("adminordrazine", 50)

/obj/item/weapon/reagent_containers/pill/stox
	name = "Sleeping pill"
	desc = "Commonly used to treat insomnia."
	icon_state = "pill8"
	New()
		..()
		reagents.add_reagent("stoxin", 15)

/obj/item/weapon/reagent_containers/pill/kelotane
	name = "Kelotane pill"
	desc = "Used to treat burns."
	icon_state = "pill11"
	New()
		..()
		reagents.add_reagent("kelotane", 15)

/obj/item/weapon/reagent_containers/pill/tramadol
	name = "Tramadol pill"
	desc = "A simple painkiller."
	icon_state = "pill8"
	New()
		..()
		reagents.add_reagent("tramadol", 15)

/obj/item/weapon/reagent_containers/pill/inaprovaline
	name = "Inaprovaline pill"
	desc = "Used to stabilize patients."
	icon_state = "pill20"
	New()
		..()
		reagents.add_reagent("inaprovaline", 30)

/obj/item/weapon/reagent_containers/pill/dexalin
	name = "Dexalin pill"
	desc = "Used to treat oxygen deprivation."
	icon_state = "pill16"
	New()
		..()
		reagents.add_reagent("dexalin", 15)

/obj/item/weapon/reagent_containers/pill/bicaridine
	name = "Bicaridine pill"
	desc = "Used to treat physical injuries."
	icon_state = "pill18"
	New()
		..()
		reagents.add_reagent("bicaridine", 15)

//Dispensers
/obj/structure/reagent_dispensers/watertank
	name = "watertank"
	desc = "A watertank"
	icon = 'objects.dmi'
	icon_state = "watertank"
	amount_per_transfer_from_this = 10
	New()
		..()
		reagents.add_reagent("water",1000)

/obj/structure/reagent_dispensers/fueltank
	name = "fueltank"
	desc = "A fueltank"
	icon = 'objects.dmi'
	icon_state = "weldtank"
	amount_per_transfer_from_this = 10
	New()
		..()
		reagents.add_reagent("fuel",1000)


	bullet_act(var/obj/item/projectile/Proj)
		if(istype(Proj ,/obj/item/projectile/beam)||istype(Proj,/obj/item/projectile/bullet))
			explosion(src.loc,-1,0,2)
			if(src)
				del(src)



	blob_act()
		explosion(src.loc,0,1,5,7,10)
		if(src)
			del(src)

	ex_act()
		explosion(src.loc,-1,0,2)
		if(src)
			del(src)

/obj/structure/reagent_dispensers/peppertank
	name = "Pepper Spray Refiller"
	desc = "Refill pepper spray canisters."
	icon = 'objects.dmi'
	icon_state = "peppertank"
	anchored = 1
	density = 0
	amount_per_transfer_from_this = 45
	New()
		..()
		reagents.add_reagent("condensedcapsaicin",1000)


/obj/structure/reagent_dispensers/water_cooler
	name = "Water-Cooler"
	desc = "A machine that dispenses water to drink"
	amount_per_transfer_from_this = 5
	icon = 'vending.dmi'
	icon_state = "water_cooler"
	possible_transfer_amounts = null
	anchored = 1
	New()
		..()
		reagents.add_reagent("water",500)


/obj/structure/reagent_dispensers/beerkeg
	name = "beer keg"
	desc = "A beer keg"
	icon = 'objects.dmi'
	icon_state = "beertankTEMP"
	amount_per_transfer_from_this = 10
	New()
		..()
		reagents.add_reagent("beer",1000)

/obj/structure/reagent_dispensers/beerkeg/blob_act()
	explosion(src.loc,0,3,5,7,10)
	del(src)


//////////////////////////drinkingglass and shaker//
//Note by Darem: This code handles the mixing of drinks. New drinks go in three places: In Chemistry-Reagents.dm (for the drink
//	itself), in Chemistry-Recipes.dm (for the reaction that changes the components into the drink), and here (for the drinking glass
//	icon states.

/obj/item/weapon/reagent_containers/food/drinks/shaker
	name = "Shaker"
	desc = "A metal shaker to mix drinks in."
	icon_state = "shaker"
	amount_per_transfer_from_this = 10
	volume = 100

/obj/item/weapon/reagent_containers/food/drinks/flask
	name = "Captain's Flask"
	desc = "A metal flask belonging to the captain"
	icon_state = "flask"
	volume = 60

/obj/item/weapon/reagent_containers/food/drinks/dflask
	name = "Detective's Flask"
	desc = "A well used metal flask with the detective's name etched into it."
	icon_state = "dflask"
	volume = 60

/obj/item/weapon/reagent_containers/food/drinks/britcup
	name = "cup"
	desc = "A cup with the british flag emblazoned on it."
	icon_state = "britcup"
	volume = 30

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass
	name = "glass"
	desc = "Your standard drinking glass."
	icon_state = "glass_empty"
	amount_per_transfer_from_this = 10
	volume = 50

	on_reagent_change()
		/*if(reagents.reagent_list.len > 1 )
			icon_state = "glass_brown"
			name = "Glass of Hooch"
			desc = "Two or more drinks, mixed together."*/
		/*else if(reagents.reagent_list.len == 1)
			for(var/datum/reagent/R in reagents.reagent_list)
				switch(R.id)*/
		if (reagents.reagent_list.len > 0)
			//mrid = R.get_master_reagent_id()
			switch(reagents.get_master_reagent_id())
				if("beer")
					icon_state = "beerglass"
					name = "Beer glass"
					desc = "A freezing pint of beer"
				if("beer2")
					icon_state = "beerglass"
					name = "Beer glass"
					desc = "A freezing pint of beer"
				if("ale")
					icon_state = "aleglass"
					name = "Ale glass"
					desc = "A freezing pint of delicious Ale"
				if("milk")
					icon_state = "glass_white"
					name = "Glass of milk"
					desc = "White and nutritious goodness!"
				if("cream")
					icon_state  = "glass_white"
					name = "Glass of cream"
					desc = "Ewwww..."
				if("chocolate")
					icon_state  = "chocolateglass"
					name = "Glass of chocolate"
					desc = "Tasty"
				if("lemon")
					icon_state  = "lemonglass"
					name = "Glass of lemon"
					desc = "Sour..."
				if("cola")
					icon_state  = "glass_brown"
					name = "Glass of Space Cola"
					desc = "A glass of refreshing Space Cola"
				if("nuka_cola")
					icon_state = "nuka_colaglass"
					name = "Nuka Cola"
					desc = "Don't cry, Don't raise your eye, It's only nuclear wasteland"
				if("orangejuice")
					icon_state = "glass_orange"
					name = "Glass of Orange juice"
					desc = "Vitamins! Yay!"
				if("tomatojuice")
					icon_state = "glass_red"
					name = "Glass of Tomato juice"
					desc = "Are you sure this is tomato juice?"
				if("blood")
					icon_state = "glass_red"
					name = "Glass of Tomato juice"
					desc = "Are you sure this is tomato juice?"
				if("limejuice")
					icon_state = "glass_green"
					name = "Glass of Lime juice"
					desc = "A glass of sweet-sour lime juice."
				if("whiskey")
					icon_state = "whiskeyglass"
					name = "Glass of whiskey"
					desc = "The silky, smokey whiskey goodness inside the glass makes the drink look very classy."
				if("gin")
					icon_state = "ginvodkaglass"
					name = "Glass of gin"
					desc = "A crystal clear glass of Griffeater gin."
				if("vodka")
					icon_state = "ginvodkaglass"
					name = "Glass of vodka"
					desc = "The glass contain wodka. Xynta."
				if("goldschlager")
					icon_state = "ginvodkaglass"
					name = "Glass of goldschlager"
					desc = "100 proof that teen girls will drink anything with gold in it."
				if("wine")
					icon_state = "wineglass"
					name = "Glass of wine"
					desc = "A very classy looking drink."
				if("cognac")
					icon_state = "cognacglass"
					name = "Glass of cognac"
					desc = "Damn, you feel like some kind of French aristocrat just by holding this."
				if ("kahlua")
					icon_state = "kahluaglass"
					name = "Glass of RR coffee Liquor"
					desc = "DAMN, THIS THING LOOKS ROBUST"
				if("vermouth")
					icon_state = "vermouthglass"
					name = "Glass of Vermouth"
					desc = "You wonder why you're even drinking this straight."
				if("tequilla")
					icon_state = "tequillaglass"
					name = "Glass of Tequilla"
					desc = "Now all that's missing is the weird colored shades!"
				if("patron")
					icon_state = "patronglass"
					name = "Glass of Patron"
					desc = "Drinking patron in the bar, with all the subpar ladies."
				if("rum")
					icon_state = "rumglass"
					name = "Glass of Rum"
					desc = "Now you want to Pray for a pirate suit, don't you?"
				if("gintonic")
					icon_state = "gintonicglass"
					name = "Gin and Tonic"
					desc = "A mild but still great cocktail. Drink up, like a true Englishman."
				if("whiskeycola")
					icon_state = "whiskeycolaglass"
					name = "Whiskey Cola"
					desc = "An innocent-looking mixture of cola and Whiskey. Delicious."
				if("whiterussian")
					icon_state = "whiterussianglass"
					name = "White Russian"
					desc = "A very nice looking drink. But that's just, like, your opinion, man."
				if("screwdrivercocktail")
					icon_state = "screwdriverglass"
					name = "Screwdriver"
					desc = "A simple, yet superb mixture of Vodka and orange juice. Just the thing for the tired engineer."
				if("bloodymary")
					icon_state = "bloodymaryglass"
					name = "Bloody Mary"
					desc = "Tomato juice, mixed with Vodka and a lil' bit of lime. Tastes like liquid murder."
				if("martini")
					icon_state = "martiniglass"
					name = "Classic Martini"
					desc = "Damn, the bartender even stirred it, not shook it."
				if("vodkamartini")
					icon_state = "martiniglass"
					name = "Vodka martini"
					desc ="A bastardisation of the classic martini. Still great."
				if("gargleblaster")
					icon_state = "gargleblasterglass"
					name = "Pan-Galactic Gargle Blaster"
					desc = "Does... does this mean that Arthur and Ford are on the station? Oh joy."
				if("bravebull")
					icon_state = "bravebullglass"
					name = "Brave Bull"
					desc = "Tequilla and Coffee liquor, brought together in a mouthwatering mixture. Drink up."
				if("tequillasunrise")
					icon_state = "tequillasunriseglass"
					name = "Tequilla Sunrise"
					desc = "Oh great, now you feel nostalgic about sunrises back on Terra..."
				if("toxinsspecial")
					icon_state = "toxinsspecialglass"
					name = "Toxins Special"
					desc = "Whoah, this thing is on FIRE"
				if("beepskysmash")
					icon_state = "beepskysmashglass"
					name = "Beepsky Smash"
					desc = "Heavy, hot and strong. Just like the Iron fist of the LAW."
				if("doctorsdelight")
					icon_state = "doctorsdelightglass"
					name = "Doctor's Delight"
					desc = "A healthy mixture of juices, guaranteed to keep you healthy until the next toolboxing takes place."
				if("manlydorf")
					icon_state = "manlydorfglass"
					name = "The Manly Dorf"
					desc = "A manly concotion made from Ale and Beer. Intended for true men only."
				if("irishcream")
					icon_state = "irishcreamglass"
					name = "Irish Cream"
					desc = "It's cream, mixed with whiskey. What else would you expect from the Irish?"
				if("cubalibre")
					icon_state = "cubalibreglass"
					name = "Cuba Libre"
					desc = "A classic mix of rum and cola."
				if("b52")
					icon_state = "b52glass"
					name = "B-52"
					desc = "Kahlua, Irish Cream, and congac. You will get bombed."
				if("atomicbomb")
					icon_state = "atomicbombglass"
					name = "Atomic Bomb"
					desc = "Nanotrasen cannot take legal responsibility for your actions after imbibing."
				if("longislandicedtea")
					icon_state = "longislandicedteaglass"
					name = "Long Island Iced Tea"
					desc = "The liquor cabinet, brought together in a delicious mix. Intended for middle-aged alcoholic women only."
				if("threemileisland")
					icon_state = "threemileislandglass"
					name = "Three Mile Island Ice Tea"
					desc = "A glass of this is sure to prevent a meltdown."
				if("margarita")
					icon_state = "margaritaglass"
					name = "Margarita"
					desc = "On the rocks with salt on the rim. Arriba~!"
				if("blackrussian")
					icon_state = "blackrussianglass"
					name = "Black Russian"
					desc = "For the lactose-intolerant. Still as classy as a White Russian."
				if("vodkatonic")
					icon_state = "vodkatonicglass"
					name = "Vodka and Tonic"
					desc = "For when a gin and tonic isn't russian enough."
				if("manhattan")
					icon_state = "manhattanglass"
					name = "Manhattan"
					desc = "The Detective's undercover drink of choice. He never could stomach gin..."
				if("manhattan_proj")
					icon_state = "proj_manhattanglass"
					name = "Manhattan Project"
					desc = "A scienitst drink of choice, for thinking how to blow up the station."
				if("ginfizz")
					icon_state = "ginfizzglass"
					name = "Gin Fizz"
					desc = "Refreshingly lemony, deliciously dry."
				if("irishcoffee")
					icon_state = "irishcoffeeglass"
					name = "Irish Coffee"
					desc = "Coffee and alcohol. More fun than a Mimosa to drink in the morning."
				if("hooch")
					icon_state = "glass_brown2"
					name = "Hooch"
					desc = "You've really hit rock bottom now... your liver packed its bags and left last night."
				if("whiskeysoda")
					icon_state = "whiskeysodaglass2"
					name = "Whiskey Soda"
					desc = "Ultimate refreshment."
				if("tonic")
					icon_state = "glass_clear"
					name = "Glass of Tonic Water"
					desc = "Quinine tastes funny, but at least it'll keep that Space Malaria away."
				if("sodawater")
					icon_state = "glass_clear"
					name = "Glass of Soda Water"
					desc = "Soda water. Why not make a scotch and soda?"
				if("water")
					icon_state = "glass_clear"
					name = "Glass of Water"
					desc = "The father of all refreshments."
				if("spacemountainwind")
					icon_state = "Space_mountain_wind_glass"
					name = "Glass of Space Mountain Wind"
					desc = "Space Mountain Wind. As you know, there are no mountains in space, only wind."
				if("thirteenloko")
					icon_state = "thirteen_loko_glass"
					name = "Glass of Thirteen Loko"
					desc = "This is a glass of Thirteen Loko, it appears to be of the highest quality. The drink, not the glass"
				if("dr_gibb")
					icon_state = "dr_gibb_glass"
					name = "Glass of Dr. Gibb"
					desc = "Dr. Gibb. Not as dangerous as the name might imply."
				if("space_up")
					icon_state = "space-up_glass"
					name = "Glass of Space-up"
					desc = "Space-up. It helps keep your cool."
				if("moonshine")
					icon_state = "glass_clear"
					name = "Moonshine"
					desc = "You've really hit rock bottom now... your liver packed its bags and left last night."
				if("soymilk")
					icon_state = "glass_white"
					name = "Glass of soy milk"
					desc = "White and nutritious soy goodness!"
				if("berryjuice")
					icon_state = "berryjuice"
					name = "Glass of berry juice"
					desc = "Berry juice. Or maybe its jam. Who cares?"
				if("poisonberryjuice")
					icon_state = "poisonberryjuice"
					name = "Glass of poison berry juice"
					desc = "A glass of deadly juice."
				if("carrotjuice")
					icon_state = "carrotjuice"
					name = "Glass of  carrot juice"
					desc = "It is just like a carrot but without crunching."
				if("banana")
					icon_state = "banana"
					name = "Glass of banana juice"
					desc = "The raw essence of a banana. HONK"
				if("bahama_mama")
					icon_state = "bahama_mama"
					name = "Bahama Mama"
					desc = "Tropic cocktail"
				if("singulo")
					icon_state = "singulo"
					name = "Singulo"
					desc = "A blue-space beverage."
				if("alliescocktail")
					icon_state = "alliescocktail"
					name = "Allies cocktail"
					desc = "A drink made from your allies."
				if("antifreeze")
					icon_state = "antifreeze"
					name = "Anti-freeze"
					desc = "The ultimate refreshment."
				if("barefoot")
					icon_state = "b&p"
					name = "Barefoot"
					desc = "Barefoot and pregnant"
				if("demonsblood")
					icon_state = "demonsblood"
					name = "Demons Blood"
					desc = "Just looking at this thing makes the hair at the back of your neck stand up."
				if("booger")
					icon_state = "booger"
					name = "Booger"
					desc = "Ewww..."
				if("snowwhite")
					icon_state = "snowwhite"
					name = "Snow White"
					desc = "A cold refreshment."
				if("aloe")
					icon_state = "aloe"
					name = "Aloe"
					desc = "Very, very, very good."
				if("andalusia")
					icon_state = "andalusia"
					name = "Andalusia"
					desc = "A nice, strange named drink."
				if("sbiten")
					icon_state = "sbitenglass"
					name = "Sbiten"
					desc = "A spicy mix of Vodka and Spice. Very hot."
				if("red_mead")
					icon_state = "red_meadglass"
					name = "Red Mead"
					desc = "A True Vikings Beverage, though its color is strange."
				if("mead")
					icon_state = "meadglass"
					name = "Mead"
					desc = "A Vikings Beverage, though a cheap one."
				if("iced_beer")
					icon_state = "iced_beerglass"
					name = "Iced Beer"
					desc = "A beer so frosty, the air around it freezes."
				if("grog")
					icon_state = "grogglass"
					name = "Grog"
					desc = "A fine and cepa drink for Space."
				if("soy_latte")
					icon_state = "soy_latte"
					name = "Soy Latte"
					desc = "A nice and refrshing beverage while you are reading."
				if("cafe_latte")
					icon_state = "cafe_latte"
					name = "Cafe Latte"
					desc = "A nice, strong and refreshing beverage while you are reading."
				if("acidspit")
					icon_state = "acidspitglass"
					name = "Acid Spit"
					desc = "A drink from Nanotrasen. Made from live aliens."
				if("amasec")
					icon_state = "amasecglass"
					name = "Amasec"
					desc = "Always handy before COMBAT!!!"
				if("neurotoxin")
					icon_state = "neurotoxinglass"
					name = "Neurotoxin"
					desc = "A drink that is guaranteed to knock you silly."
				if("hippiesdelight")
					icon_state = "hippiesdelightglass"
					name = "Hippiesdelight"
					desc = "A drink enjoyed by people during the 1960's."
				if("bananahonk")
					icon_state = "bananahonkglass"
					name = "Banana Honk"
					desc = "A drink from Clown Heaven."
				if("silencer")
					icon_state = "silencerglass"
					name = "Silencer"
					desc = "A drink from mime Heaven."
				if("nothing")
					icon_state = "nothing"
					name = "Nothing"
					desc = "Absolutely nothing."
				if("devilskiss")
					icon_state = "devilskiss"
					name = "Devils Kiss"
					desc = "Creepy time!"
				if("changelingsting")
					icon_state = "changelingsting"
					name = "Changeling Sting"
					desc = "A stingy drink."
				if("irishcarbomb")
					icon_state = "irishcarbomb"
					name = "Irish Car Bomb"
					desc = "An irish car bomb."
				if("syndicatebomb")
					icon_state = "syndicatebomb"
					name = "Syndicate Bomb"
					desc = "A syndicate bomb."
				if("erikasurprise")
					icon_state = "erikasurprise"
					name = "Erika Surprise"
					desc = "The surprise is, it's green!"
				if("driestmartini")
					icon_state = "driestmartiniglass"
					name = "Driest Martini"
					desc = "Only for the experienced. You think you see sand floating in the glass."
				else
					icon_state ="glass_brown"
					name = "Glass of ..what?"
					desc = "You can't really tell what this is."
		else
			icon_state = "glass_empty"
			name = "drinking glass"
			desc = "Your standard drinking glass"
			return

// for /obj/machinery/vending/sovietsoda
/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/soda
	New()
		..()
		reagents.add_reagent("sodawater", 50)
		on_reagent_change()

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/cola
	New()
		..()
		reagents.add_reagent("cola", 50)
		on_reagent_change()

///jar

/obj/item/weapon/reagent_containers/food/drinks/jar
	name = "empty jar"
	desc = "A jar. You're not sure what it's supposed to hold."
	icon_state = "jar"
	item_state = "beaker"
	New()
		..()
		reagents.add_reagent("metroid", 50)

	on_reagent_change()
		if (reagents.reagent_list.len > 0)
			switch(reagents.get_master_reagent_id())
				if("metroid")
					icon_state = "jar_metroid"
					name = "metroid jam"
					desc = "A jar of metroid jam. Delicious!"
				else
					icon_state ="jar_what"
					name = "jar of something"
					desc = "You can't really tell what this is."
		else
			icon_state = "jar"
			name = "empty jar"
			desc = "A jar. You're not sure what it's supposed to hold."
			return

//////////////////
//STYROFOAM CUPS//
//////////////////
/obj/item/weapon/reagent_containers/food/drinks/styrofoamcup
	name = "styrofoam cup"
	desc = "Cups for drinking."
	icon_state = "styrocup-empty"
	amount_per_transfer_from_this = 10
	volume = 50

	on_reagent_change()
		if (reagents.reagent_list.len > 0)
			switch(reagents.get_master_reagent_id())
				if("water")
					icon_state = "styrocup-clear"
				else
					icon_state ="styrocup-brown"
		else
			icon_state = "styrocup-empty"
			return

/*/obj/item/weapon/reagent_containers/food/drinks/styrofoamcuppile
	name = "Styrofoam Cup Pile"
	//desc = "A pile of styrofoam cups."
	icon_state = "styrocup-stack6"
	item_state = "styrocup-stack6"
	w_class = 1
	throwforce = 1
	var/cupcount = 6
	flags = TABLEPASS

/obj/item/weapon/reagent_containers/food/drinks/styrofoamcuppile/update_icon()
	src.icon_state = text("styrocup-stack[]", src.cupcount)
	src.desc = text("There are [] cups left!", src.cupcount)
	return

/obj/item/weapon/reagent_containers/food/drinks/styrofoamcuppile/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/reagent_containers/food/drinks/styrofoamcup) && (cupcount < 6))
		user.drop_item()
		W.loc = src
		usr << "You place a cup back onto the pile."
		if (src.cupcount < 6)
			src.cupcount++
	src.update()
	return


/obj/item/weapon/reagent_containers/food/drinks/styrofoamcuppile/proc/update()
	src.icon_state = text("styrocup-stack[]", src.cupcount)
	return

/obj/item/weapon/reagent_containers/food/drinks/styrofoamcuppile/MouseDrop(mob/user as mob)
	if ((user == usr && (!( usr.restrained() ) && (!( usr.stat ) && (usr.contents.Find(src) || in_range(src, usr))))))
		if(ishuman(user))
			if (usr.hand)
				if (!( usr.l_hand ))
					spawn( 0 )
						src.attack_hand(usr, 1, 1)
						return
			else
				if (!( usr.r_hand ))
					spawn( 0 )
						src.attack_hand(usr, 0, 1)
						return
	return

/obj/item/weapon/reagent_containers/food/drinks/styrofoamcuppile/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/item/weapon/reagent_containers/food/drinks/styrofoamcuppile/attack_hand(mob/user as mob, unused, flag)
	if (flag)
		return ..()
	src.add_fingerprint(user)
	if (locate(/obj/item/weapon/reagent_containers/food/drinks/styrofoamcup, src))
		for(var/obj/item/weapon/reagent_containers/food/drinks/styrofoamcup/P in src)
			if (!usr.l_hand)
				P.loc = usr
				P.layer = 20
				usr.l_hand = P
				usr.update_clothing()
				usr << "You take a cup from the pile."
				break
			else if (!usr.r_hand)
				P.loc = usr
				P.layer = 20
				usr.r_hand = P
				usr.update_clothing()
				usr << "You take a cup from the pile."
				break
	else
		if (src.cupcount >= 1)
			src.cupcount--
			var/obj/item/weapon/reagent_containers/food/drinks/styrofoamcup/D = new /obj/item/weapon/reagent_containers/food/drinks/styrofoamcup
			D.loc = usr.loc
			if(ishuman(usr))
				if(!usr.get_active_hand())
					usr.put_in_hand(D)
					usr << "You take a cup from the pile."
			else
				D.loc = get_turf_loc(src)
				usr << "You take a cup from the pile."

	src.update()
	return

/obj/item/weapon/reagent_containers/food/drinks/styrofoamcuppile/examine()
	set src in oview(1)

	src.cupcount = round(src.cupcount)
	var/n = src.cupcount
	for(var/obj/item/weapon/reagent_containers/food/drinks/styrofoamcup/P in src)
		n++
	if (n <= 0)
		n = 0
		usr << "There are no cups left on this pile."
	else
		if (n == 1)
			usr << "There is one cup left on this pile."
		else
			usr << text("There are [] cups on this pile.", n)
	return
*/