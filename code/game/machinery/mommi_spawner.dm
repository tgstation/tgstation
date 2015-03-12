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
	var/locked_to_zlevel = 0 // Whether to lock the spawned MoMMIs to the z-level

/obj/machinery/mommi_spawner/dorf
	machine_flags = WRENCHMOVE
	desc = "A large pad mounted to the ground with large bolts."

/obj/machinery/mommi_spawner/dorf/attack_ghost(var/mob/dead/observer/user)
	if(stat & NOPOWER|BROKEN)
		return
	..()

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
	if(metal >= metalPerMoMMI)
		update_icon()

/obj/machinery/mommi_spawner/attack_ghost(var/mob/dead/observer/user as mob)
	if(building)
		user << "\red \The [src] is busy building something already."
		return 1

	var/timedifference = world.time - user.client.time_died_as_mouse
	if(user.client.time_died_as_mouse && timedifference <= mouse_respawn_time * 600)
		var/timedifference_text
		timedifference_text = time2text(mouse_respawn_time * 600 - timedifference,"mm:ss")
		user << "<span class='warning'>You may only spawn again as a mouse or MoMMI more than [mouse_respawn_time] minutes after your death. You have [timedifference_text] left.</span>"
		return
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
	if(jobban_isbanned(user, "MoMMI"))
		user << "\red \The [src] lets out an annoyed buzz."
		return TRUE

	if(metal < metalPerMoMMI)
		user << "\red \The [src] doesn't have enough metal to complete this task."
		return 1

	if(alert(user, "Do you wish to be turned into a MoMMI at this position?", "Confirm", "Yes", "No") != "Yes") return

	building=1
	update_icon()
	spawn(50)
		if(!user || !istype(user))
			building=0
			update_icon()
			return
		makeMoMMI(user)

/obj/machinery/mommi_spawner/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(!..())
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
				return TRUE

			building=1
			update_icon()
			user.drop_item(src)
			mmi.icon = null
			mmi.invisibility = 101
			spawn(50)
				makeMoMMI(mmi.brainmob)
			return TRUE

/obj/machinery/mommi_spawner/proc/makeMoMMI(var/mob/user)
	var/turf/T = get_turf(src)

	var/mob/living/silicon/robot/mommi/M = new /mob/living/silicon/robot/mommi(T)
	if(!M)	return

	M.invisibility = 0
	if (locked_to_zlevel)
		M.add_ion_law("You belong to the station where you were created; do not leave it.")
		M.locked_to_z = T.z

	if(user.mind)
		user.mind.transfer_to(M)
		if(M.mind.assigned_role == "MoMMI")
			M.mind.original = M
		else if(user.mind.special_role)
			M.mind.store_memory("In case you look at this after being borged, the objectives are only here until I find a way to make them not show up for you, as I can't simply delete them without screwing up round-end reporting. --NeoFite")
	M.key = user.key
	M.job = "Mobile MMI"

	//M.cell = locate(/obj/item/weapon/cell) in contents
	//M.cell.loc = M
	user.loc = M//Should fix cybros run time erroring when blown up. It got deleted before, along with the frame.

	M.mmi = new /obj/item/device/mmi(M)
	M.mmi.transfer_identity(user)
	M.Namepick()
	M.updatename()

	del(user)

	metal=0
	building=0
	update_icon()
	M.cell.maxcharge = 15000
	M.cell.charge = 15000

/obj/machinery/mommi_spawner/update_icon()
	if(stat & NOPOWER)
		icon_state="mommispawner-nopower"
	else if(metal < metalPerMoMMI)
		icon_state="mommispawner-recharging"
	else if(building)
		icon_state="mommispawner-building"
	else
		icon_state="mommispawner-idle"