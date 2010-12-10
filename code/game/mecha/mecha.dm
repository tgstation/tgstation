/obj/mecha
	name = "Mecha"
	desc = "Exosuit"
	icon = 'mecha.dmi'
	density = 1 //Dense. To raise the heat.
	opacity = 1 ///opaque. Menacing.
	anchored = 1 //no pulling around.
	layer = MOB_LAYER
	var/can_move = 1
	var/mob/living/carbon/human/occupant = null
	var/step_in = 10 //make a step in step_in/10 sec.
	var/step_energy_drain = 10
	var/health = 300 //health is health
	var/deflect_chance = 2 //chance to deflect the incoming projectiles, hits, or lesser the effect of ex_act.
	var/obj/item/weapon/cell/cell = new
	var/state = 0
	var/update_stats = null //used to auto-update stats window

	var/datum/effects/system/spark_spread/spark_system = new
	var/lights = 0
	var/lights_power = 6
	var/inertia_dir = null //for open space travel.

	//inner atmos machinery. Air tank mostly
	var/datum/gas_mixture/air_contents = new
	var/obj/machinery/atmospherics/portables_connector/connected_port = null //filling the air tanks
	var/filled = 0.5
	var/gas_tank_volume = 500
	var/maximum_pressure = 30*ONE_ATMOSPHERE
	var/operating_access = null
	var/max_temperature = 2500

	var/list/operation_req_access = list(access_engine)//required access level for mecha operation
	var/list/internals_req_access = list(access_engine)//required access level to open cell compartment

/obj/mecha/New()
	..()
	src.air_contents.volume = gas_tank_volume //liters
	src.air_contents.temperature = T20C
	src.air_contents.oxygen = (src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)
	src.spark_system.set_up(2, 0, src)
	src.spark_system.attach(src)
	src.cell.charge = 15000
	src.cell.maxcharge = 15000
	preserve_temp()
	check_location_temp()
	src.verbs -= /obj/mecha/verb/disconnect_from_port
	src.verbs -= /atom/movable/verb/pull
	return


/client/Click(object,location,control,params)
	..()
	var/mob/M = src.mob
	if(M && istype(M.loc, /obj/mecha))
		if(!location) return
		if(M.stat>0) return
		if(!istype(object,/atom)) return
		var/obj/mecha/Mech = M.loc
		Mech.click_action(object)


/obj/mecha/proc/click_action(atom/target)
	if(!istype(target,/turf) && !istype(target.loc,/turf)) return
	if(!src.occupant) return
	if(state || !cell || cell.charge<=0) return
	if(src == target) return
	if(get_dist(src,target)<=1)
		src.melee_action(target)
	else
		src.range_action(target)
	return


/obj/mecha/proc/melee_action(atom/target)
	return

/obj/mecha/proc/range_action(atom/target)
	return

//////////////////////////////////
////////  Movement procs  ////////
//////////////////////////////////

/obj/mecha/relaymove(mob/user,direction)
	if(!can_move)
		return 0
	if(connected_port)
		src.occupant << "Unable to move while connected to the air system port"
		return 0
	if(src.inertia_dir)
		return 0
	if(state || !cell || cell.charge<=0)
		return 0
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
//	set background = 1
	spawn while(src && src.inertia_dir)
		if(!step(src, src.inertia_dir)||check_for_support())
			src.inertia_dir = null
		sleep(7)

/*
	if(check_for_support())
		src.inertia_dir = null
	if(src.inertia_dir)
		if(step(src, src.inertia_dir))
			spawn(5)
				.()
		else
			src.inertia_dir = null
	return
*/
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

/obj/mecha/proc/take_damage(amount, type="brute")
	switch(type)
		if("brute")
			src.health -= amount
		if("fire")
			src.health -= amount*1.5
	src.update_health()
	return


/obj/mecha/proc/update_health()
	if(src.health > 0)
		src.spark_system.start()
	else
		src.destroy()
	return

/obj/mecha/attack_hand(mob/user as mob)
	if (user.mutations & 8 && !prob(src.deflect_chance))
		src.take_damage(15)
		user << "\red You hit [src.name] with all your might. The metal creaks and bends."
		for (var/mob/V in viewers(src))
			if(V.client && V != user && !(V.blinded))
				V.show_message("[user] hits [src.name], doing some damage.", 1)
	else
		user << "\red You hit [src.name] with no visible effect."
		for (var/mob/V in viewers(src))
			if(V.client && V != user && !(V.blinded))
				V.show_message("[user] hits [src.name]. Nothing happens", 1)
	return

/obj/mecha/attack_paw(mob/user as mob)
	return src.attack_hand()


/obj/mecha/attack_alien(mob/user as mob)
	if(!prob(src.deflect_chance))
		src.take_damage(10)
	//TODO: Add text
	else
		user << "No effect"
	return


/obj/mecha/hitby(A as mob|obj)
	if(prob(src.deflect_chance) || istype(A, /mob))
		if(src.occupant && src.occupant.client)
			src.occupant << "\blue The [A] bounces off the armor."
		for (var/mob/V in viewers(src))
			if(V.client && !(V.blinded))
				V.show_message("The [A] bounces off the [src.name] armor", 1)
		if(istype(A, /mob))
			var/mob/M = A
			M.bruteloss += 10
			M.updatehealth()
		return

	else if(istype(A, /obj))
		var/obj/O = A
		if(O.throwforce)
			src.take_damage(O.throwforce)
		return


/obj/mecha/bullet_act(flag)
	if(prob(src.deflect_chance))
		if(src.occupant && src.occupant.client)
			src.occupant << "\blue The armor deflects the incoming projectile."
		for (var/mob/V in viewers(src))
			if(V.client && !(V.blinded))
				V.show_message("The [src.name] armor deflects the projectile", 1)
	else
		var/damage
		switch(flag)
			if(PROJECTILE_PULSE)
				damage = 40
			if(PROJECTILE_LASER)
				damage = 20
			else
				damage = 10
		src.take_damage(damage)
	return

/obj/mecha/proc/destroy()
	if(src.occupant)
		src.go_out()
		if(prob(20))
			src.occupant.bruteloss += rand(10,20)
			src.occupant.updatehealth()
		else
			src.occupant.gib()
	spawn()
		explosion(src.loc, 0, 0, 1, 3)
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
				src.take_damage(src.health/2)
			return
		if(3.0)
			if (prob(5))
				destroy(src)
			else
				src.take_damage(src.health/4)
			return

/obj/mecha/proc/check_location_temp()
	spawn while(src)
		if(istype(src.loc, /turf/simulated/))
			var/turf/simulated/T = src.loc
			if(T.air)
				if(T.air.temperature > src.max_temperature)
					src.take_damage(10)
		sleep(10)
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
//	set background = 1
	spawn while(src)
		if(cell && cell.charge>0)
			if(src.occupant)
				if(src.occupant.bodytemperature > 320 || src.occupant.bodytemperature < 300)
					src.occupant.bodytemperature += src.occupant.adjust_body_temperature(src.occupant.bodytemperature, 310.15, 10)
					cell.charge--
		sleep(10)

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
	if(usr!=src.occupant)
		return
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
	if(usr!=src.occupant)
		return
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
	if(usr!=src.occupant)
		return
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
	if(!src.operation_allowed(usr))
		usr << "\red Access denied"
		return
	usr << "You start climbing into [src.name]"
	spawn(20)
		if(usr in range(1))
			usr.pulling = null
	//		usr.client.eye = src
			src.occupant = usr
			usr.loc = src
			src.add_fingerprint(usr)
	return


/obj/mecha/verb/view_stats()
	set name = "View Stats"
	set category = "Exosuit Interface"
	set src in view(0)
	if(usr!=src.occupant)
		return
	src.update_stats = 1
	spawn while(src && src.occupant && src.update_stats)
		src.occupant << browse(get_stats_html(), "window=exosuit")
		onclose(src.occupant, "exosuit", src)
		sleep(10)
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
	src.occupant << browse(null, "window=exosuit")
	src.occupant.loc = src.loc
	src.occupant = null
	return

////// Misc

/obj/mecha/proc/operation_allowed(mob/living/carbon/human/H)
	//check if it doesn't require any access at all
	if(src.check_operational_access(null))
		return 1
	if(src.check_operational_access(H.equipped()) || src.check_operational_access(H.wear_id))
		return 1
	return 0


/obj/mecha/proc/internals_access_allowed(mob/living/carbon/human/H)
	//check if it doesn't require any access at all
	if(src.check_internals_access(null))
		return 1
	if(src.check_internals_access(H.equipped()) || src.check_internals_access(H.wear_id))
		return 1
	return 0


/obj/mecha/proc/check_operational_access(obj/item/weapon/card/id/I)
	if(!istype(operation_req_access, /list)) //something's very wrong
		return 1
//	var/list/L = src.operation_req_access
	if(!operation_req_access.len) //no requirements
		return 1
	if(!I || !istype(I, /obj/item/weapon/card/id) || !I.access) //not ID or no access
		return 0
	for(var/req in src.operation_req_access)
		if(!(req in I.access)) //doesn't have this access
			return 0
	return 1

/obj/mecha/proc/check_internals_access(obj/item/weapon/card/id/I)
	if(!istype(src.internals_req_access, /list)) //something's very wrong
		return 1

//	var/list/L = src.internals_req_access
	if(!internals_req_access.len) //no requirements
		return 1
	if(!I || !istype(I, /obj/item/weapon/card/id) || !I.access) //not ID or no access
		return 0
	for(var/req in src.internals_req_access)
		if(!(req in I.access)) //doesn't have this access
			return 0
	return 1


/obj/mecha/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/card/id))
		if(src.internals_access_allowed(usr))
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

	else if(istype(W, /obj/item/weapon/weldingtool) && W:welding)
		if (W:get_fuel() < 2)
			user << "\blue You need more welding fuel to complete this task."
			return
		if(src.health>=initial(src.health))
			user << "\blue The [src.name] is at full integrity."
			return
		W:use_fuel(1)
		src.health += 20
		return

	else
		..()
		if(prob(src.deflect_chance))
			user << "\red The [W] bounces off [src.name] armor."
/*
			for (var/mob/V in viewers(src))
				if(V.client && !(V.blinded))
					V.show_message("The [W] bounces off [src.name] armor.", 1)
*/
		else
			src.take_damage(W.force,W.damtype)
	return


/obj/mecha/proc/get_stats_html()
	var/output = {"<html>
						<head><title>[src.name] data</title><meta HTTP-EQUIV='Refresh' content='10'></head>
						<body style="color: #00ff00; background: #000000; font: 13px 'Courier', monospace;">
						[src.get_stats_part()]
						<hr>
						[src.get_commands()]
						</body>
						</html>
					 "}
	return output

/obj/mecha/proc/get_stats_part()
	var/output = {"<b>Integrity: </b> [health/initial(health)*100]%<br>
						<b>Powercell charge: </b>[cell.charge/cell.maxcharge*100]%<br>
						<b>Airtank pressure: </b>[src.return_pressure()]<br>
						<b>Lights: </b>[lights?"on":"off"]<br>
					"}
	return output

/obj/mecha/proc/get_commands()
	var/output = {"<a href='?src=\ref[src];toggle_lights=1'>Toggle Lights</a><br>
						[(/obj/mecha/verb/disconnect_from_port in src.verbs)?"<a href='?src=\ref[src];port_disconnect=1'>Disconnect from port</a><br>":null]
						[(/obj/mecha/verb/connect_to_port in src.verbs)?"<a href='?src=\ref[src];port_connect=1'>Connect to port</a><br>":null]
						<a href='?src=\ref[src];eject=1'>Eject</a><br>
					"}
	return output

/obj/mecha/Topic(href, href_list)
	..()
	if (href_list["close"])
		src.update_stats = null
		return
	if (href_list["toggle_lights"])
		src.toggle_lights()
		return
	if (href_list["port_disconnect"])
		src.disconnect_from_port()
		return
	if (href_list["port_connect"])
		src.connect_to_port()
		return
	if (href_list["eject"])
		src.eject()
		return
	return



/obj/mecha/proc/drop_item()//Derpfix, but may be useful in future for engineering exosuits.
	return



