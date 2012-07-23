/obj/machinery/atmospherics/unary/cryo_cell
	name = "cryo cell"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "celltop-P"
	density = 1
	anchored = 1.0
	layer = 5

	var/on = 0
	var/temperature_archived
	var/obj/effect/overlay/O1 = null
	var/mob/living/carbon/occupant = null
	var/beaker = null
	var/next_trans = 0

	var/current_heat_capacity = 50



	New()
		..()
		build_icon()
		initialize_directions = dir

	initialize()
		if(node) return
		var/node_connect = dir
		for(var/obj/machinery/atmospherics/target in get_step(src,node_connect))
			if(target.initialize_directions & get_dir(target,src))
				node = target
				break

	process()
		..()
		if(!node)
			return
		if(!on)
			src.updateUsrDialog()
			return

		if(src.occupant)
			if(occupant.stat != 2)
				process_occupant()

		if(air_contents)
			temperature_archived = air_contents.temperature
			heat_gas_contents()
			expel_gas()

		if(abs(temperature_archived-air_contents.temperature) > 1)
			network.update = 1

		src.updateUsrDialog()
		return 1


	allow_drop()
		return 0


	relaymove(mob/user as mob)
		if(user.stat)
			return
		src.go_out()
		return

	attack_hand(mob/user as mob)
		user.machine = src
		var/beaker_text = ""
		var/health_text = ""
		var/temp_text = ""
		if(src.occupant)
			if(src.occupant.health <= -100)
				health_text = "<FONT color=red>Dead</FONT>"
			else if(src.occupant.health < 0)
				health_text = "<FONT color=red>[round(src.occupant.health,0.1)]</FONT>"
			else
				health_text = "[round(src.occupant.health,0.1)]"
		if(air_contents.temperature > T0C)
			temp_text = "<FONT color=red>[air_contents.temperature]</FONT>"
		else if(air_contents.temperature > 225)
			temp_text = "<FONT color=black>[air_contents.temperature]</FONT>"
		else
			temp_text = "<FONT color=blue>[air_contents.temperature]</FONT>"
		if(src.beaker)
			beaker_text = "<B>Beaker:</B> <A href='?src=\ref[src];eject=1'>Eject</A>"
		else
			beaker_text = "<B>Beaker:</B> <FONT color=red>No beaker loaded</FONT>"
		var/dat = {"<B>Cryo cell control system</B><BR>
			<B>Current cell temperature:</B> [temp_text]K<BR>
			<B>Cryo status:</B> [ src.on ? "<A href='?src=\ref[src];start=1'>Off</A> <B>On</B>" : "<B>Off</B> <A href='?src=\ref[src];start=1'>On</A>"]<BR>
			[beaker_text]<BR><BR>
			<B>Current occupant:</B> [src.occupant ? "<BR>Name: [src.occupant]<BR>Health: [health_text]<BR>Oxygen deprivation: [round(src.occupant.getOxyLoss(),0.1)]<BR>Brute damage: [round(src.occupant.getBruteLoss(),0.1)]<BR>Fire damage: [round(src.occupant.getFireLoss(),0.1)]<BR>Toxin damage: [round(src.occupant.getToxLoss(),0.1)]<BR>Body temperature: [src.occupant.bodytemperature]" : "<FONT color=red>None</FONT>"]<BR>

		"}
		user.machine = src
		user << browse(dat, "window=cryo")
		onclose(user, "cryo")

	Topic(href, href_list)
		if ((get_dist(src, usr) <= 1) || istype(usr, /mob/living/silicon/ai))
			if(href_list["start"])
				src.on = !src.on
				build_icon()
			if(href_list["eject"])
				beaker:loc = src.loc
				beaker = null

			src.updateUsrDialog()
			src.add_fingerprint(usr)
			return

	attackby(var/obj/item/weapon/G as obj, var/mob/user as mob)
		if(istype(G, /obj/item/weapon/reagent_containers/glass))
			if(src.beaker)
				user << "\red A beaker is already loaded into the machine."
				return

			src.beaker =  G
			user.drop_item()
			G.loc = src
			user.visible_message("[user] adds \a [G] to \the [src]!", "You add \a [G] to \the [src]!")
		else if(istype(G, /obj/item/weapon/grab))
			if(!ismob(G:affecting))
				return
			for(var/mob/living/carbon/metroid/M in range(1,G:affecting))
				if(M.Victim == G:affecting)
					usr << "[G:affecting:name] will not fit into the cryo because they have a Metroid latched onto their head."
					return
			var/mob/M = G:affecting
			if(put_mob(M))
				del(G)
		src.updateUsrDialog()
		return

	proc
		add_overlays()
			src.overlays = list(O1)

		build_icon()
			if(on)
				if(src.occupant)
					icon_state = "celltop_1"
				else
					icon_state = "celltop"
			else
				icon_state = "celltop-p"
			O1 = new /obj/effect/overlay(  )
			O1.icon = 'icons/obj/Cryogenic2.dmi'
			if(src.node)
				O1.icon_state = "cryo_bottom_[src.on]"
			else
				O1.icon_state = "cryo_bottom"
			O1.pixel_y = -32.0
			src.pixel_y = 32
			add_overlays()

		process_occupant()
			if(air_contents.total_moles() < 10)
				return
			if(occupant)
				if(occupant.stat == 2)
					return
				occupant.bodytemperature += 2*(air_contents.temperature - occupant.bodytemperature)*current_heat_capacity/(current_heat_capacity + air_contents.heat_capacity())
				occupant.bodytemperature = max(occupant.bodytemperature, air_contents.temperature) // this is so ugly i'm sorry for doing it i'll fix it later i promise
				occupant.stat = 1
				if(occupant.bodytemperature < T0C)
					occupant.sleeping = max(5, (1/occupant.bodytemperature)*2000)
					occupant.Paralyse(max(5, (1/occupant.bodytemperature)*3000))
					if(air_contents.oxygen > 2)
						if(occupant.getOxyLoss()) occupant.adjustOxyLoss(-1)
					else
						occupant.adjustOxyLoss(-1)
					//severe damage should heal waaay slower without proper chemicals
					if(occupant.bodytemperature < 225)
						if (occupant.getToxLoss())
							occupant.adjustToxLoss(max(-1, -20/occupant.getToxLoss()))
						var/heal_brute = occupant.getBruteLoss() ? min(1, 20/occupant.getBruteLoss()) : 0
						var/heal_fire = occupant.getFireLoss() ? min(1, 20/occupant.getFireLoss()) : 0
						occupant.heal_organ_damage(heal_brute,heal_fire)
				if(beaker && (next_trans == 0))
					beaker:reagents.trans_to(occupant, 1, 10)
					beaker:reagents.reaction(occupant)
			next_trans++
			if(next_trans == 10)
				next_trans = 0

		heat_gas_contents()
			if(air_contents.total_moles() < 1)
				return
			var/air_heat_capacity = air_contents.heat_capacity()
			var/combined_heat_capacity = current_heat_capacity + air_heat_capacity
			if(combined_heat_capacity > 0)
				var/combined_energy = T20C*current_heat_capacity + air_heat_capacity*air_contents.temperature
				air_contents.temperature = combined_energy/combined_heat_capacity

		expel_gas()
			if(air_contents.total_moles() < 1)
				return
			var/datum/gas_mixture/expel_gas = new
			var/remove_amount = air_contents.total_moles()/100
			expel_gas = air_contents.remove(remove_amount)
			expel_gas.temperature = T20C // Lets expel hot gas and see if that helps people not die as they are removed
			loc.assume_air(expel_gas)

		go_out()
			if(!( src.occupant ))
				return
			//for(var/obj/O in src)
			//	O.loc = src.loc
			if (src.occupant.client)
				src.occupant.client.eye = src.occupant.client.mob
				src.occupant.client.perspective = MOB_PERSPECTIVE
			src.occupant.loc = src.loc
//			src.occupant.metabslow = 0
			src.occupant = null
			build_icon()
			return
		put_mob(mob/living/carbon/M as mob)
			if (!istype(M))
				usr << "\red <B>The cryo cell cannot handle such liveform!</B>"
				return
			if (src.occupant)
				usr << "\red <B>The cryo cell is already occupied!</B>"
				return
			if (M.abiotic())
				usr << "\red Subject may not have abiotic items on."
				return
			if(!src.node)
				usr << "\red The cell is not correctly connected to its pipe network!"
				return
			if (M.client)
				M.client.perspective = EYE_PERSPECTIVE
				M.client.eye = src
			M.pulling = null
			M.loc = src
			if(M.health > -100 && (M.health < 0 || M.sleeping))
				M << "\blue <b>You feel a cold liquid surround you. Your skin starts to freeze up.</b>"
			src.occupant = M
//			M.metabslow = 1
			src.add_fingerprint(usr)
			build_icon()
			return 1

	verb
		move_eject()
			set name = "Eject occupant"
			set category = "Object"
			set src in oview(1)
			if(usr == src.occupant)//If the user is inside the tube...
				if (usr.stat == 2)//and he's not dead....
					return
				usr << "\blue Release sequence activated. This will take two minutes."
				sleep(1200)
				if(!src || !usr || !src.occupant || (src.occupant != usr)) //Check if someone's released/replaced/bombed him already
					return
				src.go_out()//and release him from the eternal prison.
			else
				if (usr.stat != 0)
					return
				src.go_out()
			add_fingerprint(usr)
			return

		move_inside()
			set name = "Move Inside"
			set category = "Object"
			set src in oview(1)
			for(var/mob/living/carbon/metroid/M in range(1,usr))
				if(M.Victim == usr)
					usr << "You're too busy getting your life sucked out of you."
					return
			if (usr.stat != 0 || stat & (NOPOWER|BROKEN))
				return
			put_mob(usr)
			return



/datum/data/function/proc/reset()
	return

/datum/data/function/proc/r_input(href, href_list, mob/user as mob)
	return

/datum/data/function/proc/display()
	return
