/obj/machinery/drone_fabricator
	name = "drone fabricator"
	desc = "A large automated factory for producing maintenance drones."

	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 20
	active_power_usage = 5000

	var/drone_progress = 0
	var/produce_drones = 1
	var/time_last_drone = 500

	icon = 'icons/obj/machines/drone_fab.dmi'
	icon_state = "drone_fab_idle"

/obj/machinery/drone_fabricator/power_change()
	..()
	if(stat & NOPOWER)
		icon_state = "drone_fab_nopower"

/obj/machinery/drone_fabricator/process()

	if(ticker.current_state < GAME_STATE_PLAYING)
		return

	if(stat & NOPOWER || !produce_drones)
		icon_state = "drone_fab_nopower"
		return

	if(drone_progress >= 100)
		icon_state = "drone_fab_idle"
		return

	icon_state = "drone_fab_active"
	var/elapsed = world.time - time_last_drone
	drone_progress = round((elapsed/config.drone_build_time)*100)

	if(drone_progress >= 100)
		visible_message("\The [src] voices a strident beep, indicating a drone chassis is prepared.")

/obj/machinery/drone_fabricator/examine(mob/user)
	..(user)
	if(produce_drones && drone_progress >= 100 && istype(user,/mob/dead) && count_drones() < config.max_maint_drones)
		user << "<BR><span class='warning'>A drone is prepared! Click on the machine to create a drone for yourself..</span>"

/obj/machinery/drone_fabricator/proc/count_drones()
	var/drones = 0
	for(var/mob/living/simple_animal/drone/D in world)
		if(D.key && D.client)
			drones++
	return drones

/obj/machinery/drone_fabricator/proc/create_drone(var/client/player)

	if(stat & NOPOWER)
		return

	if(!produce_drones || count_drones() >= config.max_maint_drones)
		return

	if(!player || !istype(player.mob,/mob/dead))
		return

	visible_message("\The [src] churns and grinds as it lurches into motion, disgorging a shiny new drone after a few moments.")
	flick("h_lathe_leave",src)

	time_last_drone = world.time
	var/mob/living/simple_animal/drone/D = new /mob/living/simple_animal/drone(get_turf(loc))
	D.key = player.key

	drone_progress = 0



/obj/machinery/drone_fabricator/attack_ghost(mob/user)
	if(ticker.current_state < GAME_STATE_PLAYING)
		user << "<span class='warning'>The game hasn't started yet!</span>"
		return

	if(!user.stat)
		return

	if(jobban_isbanned(user,"pAI"))
		usr << "<span class='warning'>You are banned from playing drones.</span>"
		return

	var/deathtime = world.time - user.timeofdeath

	var/deathtimeminutes = round(deathtime / 600)
	var/pluralcheck = "minute"
	if(deathtimeminutes == 0)
		pluralcheck = ""
	else if(deathtimeminutes == 1)
		pluralcheck = " [deathtimeminutes] minute and"
	else if(deathtimeminutes > 1)
		pluralcheck = " [deathtimeminutes] minutes and"
	var/deathtimeseconds = round((deathtime - deathtimeminutes * 600) / 10,1)

	if(deathtime < 6000)
		user << "You have been dead for[pluralcheck] [deathtimeseconds] seconds."
		user << "You must wait 10 minutes to respawn as a drone!"
		return

	for(var/obj/machinery/drone_fabricator/DF in world)
		if(DF.stat & NOPOWER || !DF.produce_drones)
			continue

		if(DF.count_drones() >= config.max_maint_drones)
			user << "<span class='warning'>There are too many active drones in the world for you to spawn.</span>"
			return

		if(DF.drone_progress >= 100)
			DF.create_drone(user.client)
			return

	user << "<span class='warning'>There are no available drone fabricators!</span>"
