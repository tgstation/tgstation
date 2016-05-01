/obj/machinery/transformer
	name = "\improper Automatic Robotic Factory 5000"
	desc = "A large metallic machine with an entrance and an exit. A sign on the side reads, 'human go in, robot come out', human must be lying down and alive. Has to cooldown between each use."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "separator-AO1"
	layer = MOB_LAYER+1 // Overhead
	anchored = 1
	density = 0
	var/transform_dead = 0
	var/transform_standing = 0
	var/cooldown_duration = 600 // 1 minute
	var/cooldown = 0
	var/robot_cell_charge = 5000

/obj/machinery/transformer/New()
	// On us
	..()
	new /obj/machinery/conveyor/auto(loc, WEST)

/obj/machinery/transformer/power_change()
	..()
	update_icon()

/obj/machinery/transformer/update_icon()
	..()
	if(stat & (BROKEN|NOPOWER) || cooldown == 1)
		icon_state = "separator-AO0"
	else
		icon_state = initial(icon_state)

/obj/machinery/transformer/Bumped(atom/movable/AM)

	if(cooldown == 1)
		return

	// Crossed didn't like people lying down.
	if(ishuman(AM))
		// Only humans can enter from the west side, while lying down.
		var/move_dir = get_dir(loc, AM.loc)
		var/mob/living/carbon/human/H = AM
		if((transform_standing || H.lying) && move_dir == EAST)// || move_dir == WEST)
			AM.loc = src.loc
			do_transform(AM)

/obj/machinery/transformer/CanPass(atom/movable/mover, turf/target, height=0)
	if(!ishuman(mover)) // Allows items to go through, to stop them from blocking the conveyour belt.
		var/dir = get_dir(src, mover)
		if(dir == EAST)
			return ..()
	return 0

/obj/machinery/transformer/proc/do_transform(mob/living/carbon/human/H)
	if(stat & (BROKEN|NOPOWER))
		return
	if(cooldown == 1)
		return

	if(!transform_dead && H.stat == DEAD)
		playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
		return

	// Activate the cooldown
	cooldown = 1
	update_icon()
	spawn(cooldown_duration)
		cooldown = 0
		update_icon()

	playsound(src.loc, 'sound/items/Welder.ogg', 50, 1)
	H.emote("scream") // It is painful
	H.adjustBruteLoss(max(0, 80 - H.getBruteLoss())) // Hurt the human, don't try to kill them though.

	// Sleep for a couple of ticks to allow the human to see the pain
	sleep(5)

	use_power(5000) // Use a lot of power.
	var/mob/living/silicon/robot/R = H.Robotize(1) // Delete the items or they'll all pile up in a single tile and lag

	R.cell.maxcharge = robot_cell_charge
	R.cell.charge = robot_cell_charge

 	// So he can't jump out the gate right away.
	R.SetLockdown()
	spawn(50)
		playsound(src.loc, 'sound/machines/ping.ogg', 50, 0)
		sleep(30)
		if(R)
			R.SetLockdown(0)
			R.notify_ai(1)

/obj/machinery/transformer/conveyor/New()
	..()
	var/turf/T = loc
	if(T)
		// Spawn Conveyour Belts

		//East
		var/turf/east = locate(T.x + 1, T.y, T.z)
		if(istype(east, /turf/open/floor))
			new /obj/machinery/conveyor/auto(east, WEST)

		// West
		var/turf/west = locate(T.x - 1, T.y, T.z)
		if(istype(west, /turf/open/floor))
			new /obj/machinery/conveyor/auto(west, WEST)
