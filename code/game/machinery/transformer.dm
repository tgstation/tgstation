/obj/machinery/transformer
	name = "Automatic Robotic Factory 5000"
	desc = "A large metalic machine with an entrance and an exit. A sign on the side reads, 'human go in, robot come out', human must be lying down and alive."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "separator-AO1"
	layer = MOB_LAYER+1 // Overhead
	anchored = 1
	density = 1
	var/transform_dead = 0

/obj/machinery/transformer/New()
	..()
	var/turf/T = loc
	if(T)
		// Spawn Conveyour Belts

		//East
		var/turf/east = locate(T.x + 1, T.y, T.z)
		if(istype(east, /turf/simulated/floor))
			new /obj/machinery/conveyor(east, WEST, 1)

		// West
		var/turf/west = locate(T.x - 1, T.y, T.z)
		if(istype(west, /turf/simulated/floor))
			new /obj/machinery/conveyor(west, WEST, 1)

		// On us
		new /obj/machinery/conveyor(T, WEST, 1)

/obj/machinery/transformer/Bumped(var/atom/movable/AM)
	// HasEntered didn't like people lying down.
	if(ishuman(AM))
		// Only humans can enter from the west side, while lying down.
		var/move_dir = get_dir(loc, AM.loc)
		var/mob/living/carbon/human/H = AM
		if(H.lying && move_dir == EAST)// || move_dir == WEST)
			AM.loc = src.loc
			transform(AM)

/obj/machinery/transformer/proc/transform(var/mob/living/carbon/human/H)
	if(stat & (BROKEN|NOPOWER))
		return
	if(!transform_dead && H.stat == DEAD)
		playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
		return
	playsound(src.loc, 'sound/items/Welder.ogg', 50, 1)
	use_power(5000) // Use a lot of power.
	var/mob/living/silicon/robot = H.Robotize()
	robot.lying = 1
	spawn(50) // So he can't jump out the gate right away.
		playsound(src.loc, 'sound/machines/ping.ogg', 50, 0)
		if(robot)
			robot.lying = 0