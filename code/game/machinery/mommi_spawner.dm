/obj/machinery/mommi_spawner
	name = "MoMMI Fabricator"
	desc = "A large pad sunk into the ground."
	icon = 'icons/obj/robotics.dmi'
	icon_state = "mommispawner-idle"
	density = 1
	anchored = 1
	var/building=0
	var/metal=0
	var/const/metalPerMoMMI=10
	var/const/metalPerTick=1
	use_power = 1
	idle_power_usage = 20
	active_power_usage = 5000
	var/recharge_time=600 // 60s

/obj/machinery/mommi_spawner/power_change()
	if (powered())
		stat &= ~NOPOWER
	else
		stat |= NOPOWER
	update_icon()

/obj/machinery/mommi_spawner/proc/canSpawn()
	return !(stat & NOPOWER) && !building && metal >= metalPerMoMMI

/obj/machinery/mommi_spawner/process()
	if(stat & NOPOWER || building || metal >= metalPerMoMMI)
		return
	metal+=metalPerTick

/obj/machinery/mommi_spawner/attack_ghost(var/mob/dead/observer/user as mob)
	if(building)
		user << "\red \The [src] is busy building something already."
		return 1
	/*
	if(!mmi.brainmob)
		user << "\red \The [mmi] appears to be devoid of any soul."
		return 1
	if(!mmi.brainmob.key)
		var/ghost_can_reenter = 0
		if(mmi.brainmob.mind)
			for(var/mob/dead/observer/G in player_list)
				if(G.can_reenter_corpse && G.mind == mmi.brainmob.mind)
					ghost_can_reenter = 1
					break
		if(!ghost_can_reenter)
			user << "<span class='notice'>\The [src] indicates that their mind is completely unresponsive; there's no point.</span>"
			return TRUE

	if(mmi.brainmob.stat == DEAD)
		user << "\red Yeah, good idea. Give something deader than the pizza in your fridge legs.  Mom would be so proud."
		return TRUE

	if(mmi.brainmob.mind in ticker.mode.head_revolutionaries)
		user << "\red \The [src]'s firmware lets out a shrill sound, and flashes 'Abnormal Memory Engram'. It refuses to accept \the [mmi]."
		return TRUE
	*/
	if(jobban_isbanned(user, "Cyborg"))
		user << "\red \The [src] lets out an annoyed buzz."
		return TRUE

	if(metal < metalPerMoMMI)
		user << "\red \The [src] doesn't have enough metal to complete this task."
		return 1

	if(alert(src, "Do you wish to be turned into a MoMMI at this position?", "Confirm", "Yes", "No") != "Yes") return

	building=1
	update_icon()
	spawn(50)
		user.canmove = 0
		user.icon = null
		user.invisibility = 101

		var/mob/living/silicon/robot/mommi/O = new /mob/living/silicon/robot/mommi( loc )

		// cyborgs produced by Robotize get an automatic power cell
		O.cell = new(O)
		O.cell.maxcharge = 7500
		O.cell.charge = 7500

		O.gender = gender
		O.invisibility = 0

		if(user.mind)		//TODO
			user.mind.transfer_to(O)
			if(O.mind.assigned_role == "MoMMI")
				O.mind.original = O
			else if(user.mind.special_role)
				O.mind.store_memory("In case you look at this after being borged, the objectives are only here until I find a way to make them not show up for you, as I can't simply delete them without screwing up round-end reporting. --NeoFite")
		else
			O.key = user.key

		O.loc = loc
		O.job = "Mobile MMI"

		O.mmi = new /obj/item/device/mmi(O)
		O.mmi.transfer_identity(user)//Does not transfer key/client.

		O.Namepick()

		del(user)
		metal=0
		building=0
		update_icon()

/obj/machinery/mommi_spawner/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(istype(O,/obj/item/device/mmi))
		var/obj/item/device/mmi/mmi = O
		if(building)
			user << "\red \The [src] is busy building something already."
			return 1
		if(!mmi.brainmob)
			user << "\red \The [mmi] appears to be devoid of any soul."
			return 1
		if(!mmi.brainmob.key)
			var/ghost_can_reenter = 0
			if(mmi.brainmob.mind)
				for(var/mob/dead/observer/G in player_list)
					if(G.can_reenter_corpse && G.mind == mmi.brainmob.mind)
						ghost_can_reenter = 1
						break
			if(!ghost_can_reenter)
				user << "<span class='notice'>\The [src] indicates that their mind is completely unresponsive; there's no point.</span>"
				return TRUE

		if(mmi.brainmob.stat == DEAD)
			user << "\red Yeah, good idea. Give something deader than the pizza in your fridge legs.  Mom would be so proud."
			return TRUE

		if(mmi.brainmob.mind in ticker.mode.head_revolutionaries)
			user << "\red \The [src]'s firmware lets out a shrill sound, and flashes 'Abnormal Memory Engram'. It refuses to accept \the [mmi]."
			return TRUE

		if(jobban_isbanned(mmi.brainmob, "Cyborg"))
			user << "\red \The [src] lets out an annoyed buzz and rejects \the [mmi]."
			return TRUE

		if(metal < metalPerMoMMI)
			user << "\red \The [src] doesn't have enough metal to complete this task."
			return 1

		building=1
		update_icon()
		user.drop_item()
		mmi.icon = null
		mmi.invisibility = 101
		mmi.loc=src
		spawn(50)
			var/mob/living/silicon/robot/mommi/M = new /mob/living/silicon/robot/mommi(get_turf(loc))
			if(!M)	return

			user.drop_item()

			M.invisibility = 0
			//M.custom_name = created_name
			M.Namepick()
			M.updatename()
			mmi.brainmob.mind.transfer_to(M)

			if(M.mind && M.mind.special_role)
				M.mind.store_memory("In case you look at this after being borged, the objectives are only here until I find a way to make them not show up for you, as I can't simply delete them without screwing up round-end reporting. --NeoFite")

			M.job = "Mobile MMI"

			//M.cell = locate(/obj/item/weapon/cell) in contents
			//M.cell.loc = M
			src.loc = M//Should fix cybros run time erroring when blown up. It got deleted before, along with the frame.
			M.mmi = mmi
			building=0
			update_icon()
		return TRUE

/obj/machinery/mommi_spawner/update_icon()
	if(stat & NOPOWER)
		icon_state="mommispawner-nopower"
	else if(metal < metalPerMoMMI)
		icon_state="mommispawner-recharging"
	else if(building)
		icon_state="mommispawner-building"
	else
		icon_state="mommispawner-idle"