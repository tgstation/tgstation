/obj/mecha
	name = "Mecha"
	icon = 'mecha.dmi'
	density = 1 //Dense. To raise the heat.
	opacity = 1 ///opaque. Menacing.
	anchored = 1 //no pulling around.
	var/can_move = 1
	var/mob/living/carbon/human/occupant = null
	var/step_in = 10 //make a step in step_in/10 sec.
	var/step_energy_drain = 10
	var/health = 300 //health is health
	var/deflect_chance = 5 //chance to deflect the incoming projectiles, or lesser the effect of ex_act.
	var/obj/item/weapon/cell/cell = new
	var/state = 0


	var/datum/effects/system/spark_spread/spark_system = new
	var/lights = 0
	var/lights_power = 6
	var/inertia_dir = null //for open space travel.

	//inner atmos machinery. Air tank mostly
	var/datum/gas_mixture/air_contents = new
	var/obj/machinery/atmospherics/portables_connector/connected_port = null //filling the air tanks
	var/filled = 0.5
	var/gas_tank_volume = 80
	var/maximum_pressure = 30*ONE_ATMOSPHERE

	req_access = access_engine
	var/operating_access = null

/obj/mecha/New()
	..()
	src.air_contents.volume = gas_tank_volume //liters
	src.air_contents.temperature = T20C
	src.air_contents.oxygen = (src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)
	src.spark_system.set_up(5, 0, src)
	src.spark_system.attach(src)
	src.cell.charge = 15000
	src.cell.maxcharge = 15000
	preserve_temp()
	src.verbs -= /obj/mecha/verb/disconnect_from_port


/client/Click(object,location,control,params)
	..()
	var/mob/M = src.mob
	if(M && istype(M.loc, /obj/mecha))
		if(M.stat>0) return
		if(!istype(object,/atom)) return
		var/obj/mecha/Mech = M.loc
		Mech.click_action(object)


/obj/mecha/proc/click_action(target)
	return



//////////////////////////////////
////////  Movement procs  ////////
//////////////////////////////////

/obj/mecha/relaymove(mob/user,direction)
	if(connected_port)
		src.occupant << "Unable to move while connected to the air system port"
		return 0
	if(src.inertia_dir)
		return 0
	if(state || !cell || cell.charge<=0) return 0
	if(can_move)
		if(step(src,direction))
			can_move = 0
			spawn(step_in) can_move = 1
			cell.use(src.step_energy_drain)
			if(istype(src.loc, /turf/space))
				if(!src.check_for_support())
					src.inertia_dir = direction
					src.inertial_movement()
			return 1
	return 0

/obj/mecha/proc/inertial_movement()
	if(check_for_support())
		src.inertia_dir = null
	if(src.inertia_dir)
		if(step(src, src.inertia_dir))
			spawn(5)
				.()
		else
			src.inertia_dir = null
	return

/obj/mecha/proc/check_for_support()
	if(locate(/obj/grille, orange(1, src)) || locate(/obj/lattice, orange(1, src)) || locate(/turf/simulated, orange(1, src)) || locate(/turf/unsimulated, orange(1, src)))
		return 1
	else
		return 0

/obj/mecha/Bump(var/atom/obstacle)
//	src.inertia_dir = null
	if(src.occupant)
		if(istype(obstacle , /obj/machinery/door))
			var/obj/machinery/door/D = obstacle
			D.Bumped(src.occupant)
			return
//		else
//			obstacle.Bumped(src)
	return


////////////////////////////////////////
////////  Health related procs  ////////
////////////////////////////////////////

/obj/mecha/bullet_act(flag)
	if(prob(src.deflect_chance))
		if(src.occupant && src.occupant.client)
			src.occupant << "\blue The armor deflects the incoming projectile."
		return
	else
		switch(flag)
			if(PROJECTILE_PULSE)
				src.health -= 40
			if(PROJECTILE_LASER)
				src.health -= 20
			else
				src.health -= 10
	if(src.health > 0)
		src.spark_system.start()
	else
		src.destroy()

/obj/mecha/proc/destroy()
	if(src.occupant)
		var/mob/M = src.occupant
		src.go_out()
		if(prob(20))
			M.bruteloss += rand(10,20)
			M.updatehealth()
		else
			M.gib()
	explosion(src.loc, 1, 0, 2, 4)
	spawn()
		del(src)
	return

/obj/mecha/ex_act(severity)
	if(prob(src.deflect_chance))
		severity++
	switch(severity)
		if(1.0)
			destroy(src)
			return
		if(2.0)
			if (prob(30))
				destroy(src)
			else
				src.health = src.health/2
				src.spark_system.start()
			return
		if(3.0)
			if (prob(5))
				destroy(src)
			else
				src.health = src.health - src.health/4
				src.spark_system.start()
			return


/////////////////////////////////////
////////  Atmospheric stuff  ////////
/////////////////////////////////////

/* //standard for /obj class
/obj/mecha/handle_internal_lifeform(lifeform, volume)
	..()
	world << "Handling occupant breathing"
*/

/obj/mecha/remove_air(amount)
	return src.air_contents.remove(amount)

/obj/mecha/return_air()
	return src.air_contents

/obj/mecha/proc/return_pressure()
	return src.air_contents.return_pressure()

/obj/mecha/proc/preserve_temp()
	if(!cell || cell.charge<=0) return
	if(src.occupant)
		if(src.occupant.bodytemperature > 320 || src.occupant.bodytemperature < 300)
			src.occupant.bodytemperature += src.occupant.adjust_body_temperature(src.occupant.bodytemperature, 310.15, 10)
			cell.charge--
	spawn(10)
		.()

/obj/mecha/proc/connect(obj/machinery/atmospherics/portables_connector/new_port)
	//Make sure not already connected to something else
	if(src.connected_port || !new_port || new_port.connected_device)
		return 0

	//Make sure are close enough for a valid connection
	if(new_port.loc != src.loc)
		return 0

	//Perform the connection
	src.connected_port = new_port
	src.connected_port.connected_device = src

	//Actually enforce the air sharing
	var/datum/pipe_network/network = connected_port.return_network(src)
	if(network && !network.gases.Find(air_contents))
		network.gases += air_contents

	return 1

/obj/mecha/proc/disconnect()
	if(!connected_port)
		return 0

	var/datum/pipe_network/network = connected_port.return_network(src)
	if(network)
		network.gases -= air_contents

	connected_port.connected_device = null
	connected_port = null

	return 1


/////////////////////////
////////  Verbs  ////////
/////////////////////////

/obj/mecha/verb/connect_to_port()
	set name = "Connect to port"
	set category = "Exosuit Interface"
	set src in view(0)
	if(!src.occupant) return
	var/obj/machinery/atmospherics/portables_connector/possible_port = locate(/obj/machinery/atmospherics/portables_connector/) in loc
	if(possible_port)
		if(connect(possible_port))
			src.occupant << "\blue [name] connects to the port."
			src.verbs += /obj/mecha/verb/disconnect_from_port
			src.verbs -= /obj/mecha/verb/connect_to_port
			return
		else
			src.occupant << "\red [name] failed to connect to the port."
			return
	else
		src.occupant << "Nothing happens"


/obj/mecha/verb/disconnect_from_port()
	set name = "Disconnect from port"
	set category = "Exosuit Interface"
	set src in view(0)
	if(!src.occupant) return
	if(disconnect())
		src.occupant << "\blue [name] disconnects from the port."
		src.verbs -= /obj/mecha/verb/disconnect_from_port
		src.verbs += /obj/mecha/verb/connect_to_port
	else
		src.occupant << "\red [name] is not connected to the port at the moment."


/obj/mecha/verb/toggle_lights()
	set name = "Toggle Lights"
	set category = "Exosuit Interface"
	set src in view(0)
	lights = !lights
	if(lights)
		src.sd_SetLuminosity(src.luminosity + src.lights_power)
	else
		src.sd_SetLuminosity(src.luminosity - src.lights_power)

/obj/mecha/verb/move_inside()
	set name = "Move Inside"
	set src in oview(1)

	if (usr.stat != 0 || !istype(usr, /mob/living/carbon/human))
		return
	if (src.occupant)
		usr << "\blue <B>The [src.name] is already occupied!</B>"
		return
/*
	if (usr.abiotic())
		usr << "\blue <B>Subject cannot have abiotic items on.</B>"
		return
*/
	usr << "You start climbing into [src.name]"
	spawn(20)
		if(usr in range(1))
			usr.pulling = null
	//		usr.client.eye = src
			usr.loc = src
			src.occupant = usr
			src.add_fingerprint(usr)
	return

/obj/mecha/verb/eject()
	set name = "Eject"
	set category = "Exosuit Interface"
	set src in view(0)
	if(usr!=src.occupant)
		return
	src.go_out()
	add_fingerprint(usr)
	return


/obj/mecha/proc/go_out()
	if(!src.occupant) return
	if (src.occupant.client)
		src.occupant.client.eye = src.occupant.client.mob
		src.occupant.client.perspective = MOB_PERSPECTIVE
	src.occupant.loc = src.loc
	src.occupant = null
	return

////// Misc

/obj/mecha/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/card/id))
		if(src.allowed(usr))
			if(state==0)
				state = 1
				user << "The securing bolts are now exposed."
			else if(state==1)
				state = 0
				user << "The securing bolts are now hidden."
		else
			user << "\red Access denied."
		return

	else if(istype(W, /obj/item/weapon/wrench))
		if(state==1)
			state = 2
			user << "You undo the securing bolts."
		else if(state==2)
			state = 1
			user << "You tighten the securing bolts."
		return

	else if(istype(W, /obj/item/weapon/crowbar))
		if(state==2)
			state = 3
			user << "You open the hatch to the power unit"
		else if(state==3)
			state=2
			user << "You close the hatch to the power unit"
		return

	else if(istype(W, /obj/item/weapon/screwdriver))
		if(state==3 && src.cell)
			src.cell.loc = src.loc
			src.cell = null
			state = 4
			user << "You unscrew and pry out the powercell."
		else if(state==4 && src.cell)
			state=3
			user << "You screw the cell in place"
		return

	else if(istype(W, /obj/item/weapon/cell))
		if(state==4)
			if(!src.cell)
				user << "You install the powercell"
				user.drop_item()
				W.loc = src
				src.cell = W
			else
				user << "There's already a powercell installed."
		return


	..()
	return



