#define MECHA_INT_FIRE 1
#define MECHA_INT_TEMP_CONTROL 2
#define MECHA_INT_SHORT_CIRCUIT 4
#define MECHA_INT_TANK_BREACH 8
#define MECHA_INT_CONTROL_LOST 16


/obj/mecha
	name = "Mecha"
	desc = "Exosuit"
	icon = 'mecha.dmi'
	density = 1 //Dense. To raise the heat.
	opacity = 1 ///opaque. Menacing.
	anchored = 1 //no pulling around.
	unacidable = 1 //and no deleting hoomans inside
	layer = MOB_LAYER //icon draw layer
	infra_luminosity = 15
	var/can_move = 1
	var/mob/living/carbon/human/occupant = null
	var/step_in = 10 //make a step in step_in/10 sec.
	var/step_energy_drain = 10
	var/health = 300 //health is health
	var/deflect_chance = 2 //chance to deflect the incoming projectiles, hits, or lesser the effect of ex_act.
	var/obj/item/weapon/cell/cell = new
	var/state = 0
	var/list/log = new

	var/datum/effects/system/spark_spread/spark_system = new
	var/lights = 0
	var/lights_power = 6
	//var/inertia_dir = null //for open space travel.

	//inner atmos machinery. Air tank mostly
	var/use_internal_tank = 0
	var/datum/gas_mixture/air_contents = new
	var/obj/machinery/atmospherics/portables_connector/connected_port = null //filling the air tanks
	var/filled = 0.5
	var/gas_tank_volume = 500
	var/maximum_pressure = 30*ONE_ATMOSPHERE
	var/max_temperature = 2500
	var/internal_damage_threshold = 50 //health percentage below which internal damage is possible
	var/internal_damage = 0 //contains bitflags

	var/list/operation_req_access = list(access_engine)//required access level for mecha operation
	var/list/internals_req_access = list(access_engine)//required access level to open cell compartment

	var/datum/global_iterator/pr_int_temp_processor //normalizes internal air mixture temperature
	var/datum/global_iterator/pr_update_stats //used to auto-update stats window
	var/datum/global_iterator/pr_inertial_movement //controls intertial movement in spesss
	var/datum/global_iterator/pr_location_temp_check //processes location temperature damage
	var/datum/global_iterator/pr_internal_damage //processes internal damage

	var/wreckage


/obj/mecha/New()
	..()
	src.icon_state += "-open"
	src.air_contents.volume = gas_tank_volume //liters
	src.air_contents.temperature = T20C
	src.air_contents.oxygen = (src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)
	src.spark_system.set_up(2, 0, src)
	src.spark_system.attach(src)
	src.cell.charge = 15000
	src.cell.maxcharge = 15000

//misc global_iteration datums
	pr_int_temp_processor = new /datum/global_iterator/mecha_preserve_temp(list(src))
	pr_update_stats = new /datum/global_iterator/mecha_view_stats(list(src),0)
	pr_inertial_movement = new /datum/global_iterator/mecha_intertial_movement(null,0)
	pr_location_temp_check = new /datum/global_iterator/mecha_location_temp_check(list(src))
	pr_internal_damage = new /datum/global_iterator/mecha_internal_damage(list(src),0)

	src.verbs -= /obj/mecha/verb/disconnect_from_port
	src.verbs -= /atom/movable/verb/pull
	src.log_message("[src.name] created.")
	return

/obj/mecha/Del()
	src.go_out()
	..()
	return

///client/var/mech_click

/client/Click(object,location,control,params)
	..()
	var/mob/M = src.mob
	if(M && istype(M.loc, /obj/mecha))
/*
		if(mech_click == world.time) return
		mech_click = world.time
*/
		if(!location) return //probably GUI
		if(M.stat>0) return
		if(!istype(object,/atom)) return
		var/obj/mecha/Mech = M.loc
//		sleep(-1)
		spawn() //this helps prevent clickspam fest.
			Mech.click_action(object)



/obj/mecha/proc/click_action(atom/target)
	if(!istype(target,/turf) && !istype(target.loc,/turf)) return
	if(!src.occupant) return
	if(state || !cell || cell.charge<=0) return
	if(src == target) return
	if(!(get_dir(src,target) & src.dir))//wrong direction
		return
	if(get_dist(src,target)<=1)
		src.melee_action(target)
	else
		src.range_action(target)
	return


/obj/mecha/proc/melee_action(atom/target)
	return

/obj/mecha/proc/range_action(atom/target)
	return
/*
/obj/mecha/verb/test_int_damage()
	set name = "Test internal damage"
	set category = "Exosuit Interface"
	set src in view(0)
	if(!src.occupant) return
	if(usr!=src.occupant)
		return
	src.health = initial(src.health)/2.2
	src.check_for_internal_damage(list(MECHA_INT_FIRE,MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST))
	return
*/

//////////////////////////////////
////////  Movement procs  ////////
//////////////////////////////////

/obj/mecha/relaymove(mob/user,direction)
	if(!can_move)
		return 0
	if(connected_port)
		src.occupant_message("Unable to move while connected to the air system port")
		return 0
	if(src.pr_inertial_movement.active())
		return 0
	if(state || !cell || cell.charge<=0)
		return 0
	var/move_result = 0
	if(internal_damage&MECHA_INT_CONTROL_LOST)
		move_result = step_rand(src)
	else if(src.dir!=direction)
		src.dir=direction
		move_result = 1
	else
		move_result	= step(src,direction)
	if(move_result)
		can_move = 0
		spawn(step_in) can_move = 1
		cell.use(src.step_energy_drain)
		if(istype(src.loc, /turf/space))
			if(!src.check_for_support())
				src.pr_inertial_movement.start(list(src,direction))
				src.log_message("Movement control lost. Inertial movement started.")
		return 1
	return 0

/*
/obj/mecha/proc/inertial_movement(direction)
	src.inertia_dir = direction
	spawn while(src && src.inertia_dir)
		if(!step(src, src.inertia_dir)||check_for_support())
			src.inertia_dir = null
		sleep(7)
	return
*/
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
	if(istype(obstacle, /obj))
		var/obj/O = obstacle
		if(istype(obstacle , /obj/machinery/door))
			if(src.occupant)
				O.Bumped(src.occupant)
		else if(!O.anchored)
			step(obstacle,src.dir)
//		else
//			obstacle.Bumped(src)
	else if(istype(obstacle, /mob))
		step(obstacle,src.dir)
	return


////////////////////////////////////////
////////  Health related procs  ////////
////////////////////////////////////////

/obj/mecha/proc/take_damage(amount, type="brute")
	switch(type)
		if("brute")
			src.health -= amount
		if("fire")
			src.health -= amount*1.2
	src.update_health()
	src.log_append_to_last("Took [amount] points of damage. Damage type: \"[type]\".",1)
	return

/obj/mecha/proc/check_for_internal_damage(var/list/possible_int_damage,var/ignore_threshold=null)//TODO
	if(!src) return
	if(prob(40))
		if(ignore_threshold || src.health*100/initial(src.health)<src.internal_damage_threshold)
			for(var/T in possible_int_damage)
				if(internal_damage & T)
					possible_int_damage -= T
			if(possible_int_damage.len)
				var/int_dam_flag = pick(possible_int_damage)
				if(int_dam_flag)
					internal_damage |= int_dam_flag
					pr_internal_damage.start()
					src.log_append_to_last("Internal damage of type [int_dam_flag].[ignore_threshold?"Ignoring damage threshold.":null]",1)
					src.occupant << sound('warning-buzzer.ogg',wait=0)
	return


/obj/mecha/proc/update_health()
	if(src.health > 0)
		src.spark_system.start()
	else
		src.destroy()
	return

/obj/mecha/attack_hand(mob/user as mob)
	src.log_message("Attack by hand/paw. Attacker - [user].",1)
	if (user.mutations & 8 && !prob(src.deflect_chance))
		src.take_damage(15)
		src.check_for_internal_damage(list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST))
		user.visible_message("<font color='red'><b>[user] hits [src.name], doing some damage.</b></font>", "<font color='red'><b>You hit [src.name] with all your might. The metal creaks and bends.</b></font>")
	else
		user.visible_message("<font color='red'><b>[user] hits [src.name]. Nothing happens</b></font>","<font color='red'><b>You hit [src.name] with no visible effect.</b></font>")
		src.log_append_to_last("Armor saved.")
	return

/obj/mecha/attack_paw(mob/user as mob)
	return src.attack_hand(user)


/obj/mecha/attack_alien(mob/user as mob)
	src.log_message("Attack by alien. Attacker - [user].",1)
	if(!prob(src.deflect_chance))
		src.take_damage(15)
		src.check_for_internal_damage(list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST))
		playsound(src.loc, 'slash.ogg', 50, 1, -1)
		user << "\red You slash at the armored suit!"
		for (var/mob/V in viewers(src))
			if(V.client && !(V.blinded))
				V.show_message("\red The [user] slashes at [src.name]'s armor!", 1)
	else
		src.log_append_to_last("Armor saved.")
		playsound(src.loc, 'slash.ogg', 50, 1, -1)
		user << "\green Your claws had no effect!"
		src.occupant_message("\blue The [user]'s claws are stopped by the armor.")
		for (var/mob/V in viewers(src))
			if(V.client && !(V.blinded))
				V.show_message("\blue The [user] rebounds off the [src.name] armor!", 1)
	return


/obj/mecha/hitby(A as mob|obj)
	src.log_message("Hit by [A].",1)
	if(prob(src.deflect_chance) || istype(A, /mob))
		src.occupant_message("\blue The [A] bounces off the armor.")
		src.visible_message("The [A] bounces off the [src.name] armor")
		src.log_append_to_last("Armor saved.")
		if(istype(A, /mob))
			var/mob/M = A
			M.bruteloss += 10
			M.updatehealth()

	else if(istype(A, /obj))
		var/obj/O = A
		if(O.throwforce)
			src.take_damage(O.throwforce)
			src.check_for_internal_damage(list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST))

	return


/obj/mecha/bullet_act(flag)
	var/dam_type
	switch(dam_type)
		if(PROJECTILE_PULSE)
			dam_type = "Pulse"
		if(PROJECTILE_LASER)
			dam_type = "Laser"
		if(PROJECTILE_TASER)
			dam_type = "Taser"
		else
			dam_type = "Default"
	src.log_message("Hit by projectile. Type: [dam_type]([flag]).",1)
	if(prob(src.deflect_chance))
		src.occupant_message("\blue The armor deflects the incoming projectile.")
		src.visible_message("The [src.name] armor deflects the projectile")
		src.log_append_to_last("Armor saved.")
	else
		var/damage
		var/ignore_threshold
		switch(flag)
			if(PROJECTILE_PULSE)
				damage = 40
				ignore_threshold = 1
			if(PROJECTILE_LASER)
				damage = 20
			if(PROJECTILE_TASER)
				src.cell.use(500)
			else
				damage = 10
		src.take_damage(damage)
		src.check_for_internal_damage(list(MECHA_INT_FIRE,MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST),ignore_threshold)
	return

/obj/mecha/proc/destroy()
	var/obj/mecha/mecha = src
	src = null
	var/mob/M
	spawn()
		if(mecha.occupant)
			M = mecha.occupant
		explosion(mecha.loc, 0, 0, 1, 3)
		if(mecha.wreckage)
			new mecha.wreckage(get_turf(mecha))
		del(mecha)
		if(M)
			if(prob(20))
				M.bruteloss += rand(10,20)
				M.updatehealth()
			else
				M.gib()
	return

/obj/mecha/ex_act(severity)
	src.log_message("Affected by explosion of severity: [severity].",1)
	if(prob(src.deflect_chance))
		severity++
		src.log_append_to_last("Armor saved, changing severity to [severity].")
	switch(severity)
		if(1.0)
			src.destroy()
		if(2.0)
			if (prob(30))
				src.destroy()
			else
				src.take_damage(initial(src.health)/2)
				src.check_for_internal_damage(list(MECHA_INT_FIRE, MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST),1)
		if(3.0)
			if (prob(5))
				src.destroy()
			else
				src.take_damage(initial(src.health)/5)
				src.check_for_internal_damage(list(MECHA_INT_FIRE, MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST),1)
	return

/obj/mecha/blob_act()
	return

/obj/mecha/meteorhit()
	return ex_act(rand(1,3))//should do for now

/obj/mecha/emp_act()
	cell.use(rand(cell.maxcharge/2, cell.maxcharge))
	src.check_for_internal_damage(list(MECHA_INT_FIRE,MECHA_INT_TEMP_CONTROL,MECHA_INT_CONTROL_LOST),1)
	return

/////////////////////////////////////
////////  Atmospheric stuff  ////////
/////////////////////////////////////

/*
//standard for /obj class
/obj/mecha/handle_internal_lifeform(lifeform, volume)
	..()
	world << "Handling [lifeform] breathing. Requested [volume]"
*/

/obj/mecha/remove_air(amount)
	if(src.use_internal_tank)
		return src.air_contents.remove(amount)
	else
		var/turf/T = get_turf(src)
		return T.remove_air(amount)

/obj/mecha/return_air()
	return src.air_contents

/obj/mecha/proc/return_pressure()
	return src.air_contents.return_pressure()

/*
/obj/mecha/proc/preserve_temp()
//	set background = 1
	spawn while(src)
		if(cell && cell.charge>0)
			if(src.occupant)
				if(src.occupant.bodytemperature > 320 || src.occupant.bodytemperature < 300)
					src.occupant.bodytemperature += src.occupant.adjust_body_temperature(src.occupant.bodytemperature, 310.15, 10)
					cell.charge--
		sleep(10)
*/

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
	src.log_message("Connected to gas port.")
	return 1

/obj/mecha/proc/disconnect()
	if(!connected_port)
		return 0

	var/datum/pipe_network/network = connected_port.return_network(src)
	if(network)
		network.gases -= air_contents

	connected_port.connected_device = null
	connected_port = null
	src.log_message("Disconnected from gas port.")
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
			src.occupant_message("\red [name] failed to connect to the port.")
			return
	else
		src.occupant_message("Nothing happens")


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
		src.occupant_message("\red [name] is not connected to the port at the moment.")


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
	src.log_message("Toggled lights.")
	return


/obj/mecha/verb/toggle_internal_tank()
	set name = "Toggle internal airtank usage."
	set category = "Exosuit Interface"
	set src in view(0)
	if(usr!=src.occupant)
		return
	use_internal_tank = !use_internal_tank
	src.log_message("Now taking air from [use_internal_tank?"internal airtank":"environment"].")
	return


/obj/mecha/verb/move_inside()
	set name = "Move Inside"
	set src in oview(1)

	if (usr.stat != 0 || !istype(usr, /mob/living/carbon/human))
		return
	src.log_message("[usr] tries to move in.")
	if (src.occupant)
		usr << "\blue <B>The [src.name] is already occupied!</B>"
		src.log_append_to_last("Permission denied.")
		return
/*
	if (usr.abiotic())
		usr << "\blue <B>Subject cannot have abiotic items on.</B>"
		return
*/
	if(!src.operation_allowed(usr))
		usr << "\red Access denied"
		src.log_append_to_last("Permission denied.")
		return
	usr << "You start climbing into [src.name]"
	spawn(20)
		moved_inside(usr)
	return

/obj/mecha/proc/moved_inside(var/mob/living/carbon/human/H as mob)
	if(H && H in range(1))
		H.pulling = null
		src.occupant = H
		H.loc = src
		if(H.client)
			H.client.eye = src
			H.client.perspective = EYE_PERSPECTIVE
		src.add_fingerprint(H)
		src.Entered(H)
		src.Move(src.loc)
		src.log_append_to_last("[H] moved in as pilot.")
		src.icon_state = initial(icon_state)
		playsound(src, 'windowdoor.ogg', 50, 1)
		return 1
	else
		return 0


/obj/mecha/verb/view_stats()
	set name = "View Stats"
	set category = "Exosuit Interface"
	set src in view(0)
	if(usr!=src.occupant)
		return
	pr_update_stats.start()
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
	if(src.occupant.Move(src.loc))
		src.log_message("[src.occupant] moved out.")
		src.Exited(src.occupant)
		if (src.occupant.client)
			src.occupant.client.eye = src.occupant.client.mob
			src.occupant.client.perspective = MOB_PERSPECTIVE
		src.occupant << browse(null, "window=exosuit")
		src.occupant = null
		src.pr_update_stats.stop()
		src.icon_state = initial(icon_state)+"-open"
		src.dir = SOUTH
	return

////// Misc

/obj/mecha/proc/occupant_message(message as text)
	if(message)
		if(src.occupant && src.occupant.client)
			src.occupant << "[message]"
	return

/obj/mecha/proc/log_message(message as text,red=null)
	log.len++
	log[log.len] = list("time"=world.timeofday,"message"="[red?"<font color='red'>":null][message][red?"</font>":null]")
	return log.len

/obj/mecha/proc/log_append_to_last(message as text,red=null)
	var/list/last_entry = src.log[src.log.len]
	last_entry["message"] += "<br>[red?"<font color='red'>":null][message][red?"</font>":null]"
	return


/obj/mecha/proc/get_log_html()
	var/output = "<html><head><title>[src.name] Log</title></head><body style='font: 13px 'Courier', monospace;'>"
	for(var/list/entry in log)
		output += {"<div style='font-weight: bold;'>[time2text(entry["time"],"DDD MMM DD hh:mm:ss")]</div>
						<div style='margin-left:15px; margin-bottom:10px;'>[entry["message"]]</div>
						"}
	output += "</body></html>"
	return output

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
	if(istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
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
			src.log_message("Powercell removed")
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
				src.log_message("Powercell installed")
			else
				user << "There's already a powercell installed."
		return

	else if(istype(W, /obj/item/weapon/weldingtool) && W:welding)
		if (W:remove_fuel(1,user))
			if (src.internal_damage & MECHA_INT_TANK_BREACH)
				src.internal_damage &= ~MECHA_INT_TANK_BREACH
				user << "\blue You repair the damaged gas tank."
		else
			return
		if(src.health<initial(src.health))
			user << "\blue You repair some damage to [src.name]."
			src.health += min(20, initial(src.health)-src.health)
		else
			user << "The [src.name] is at full integrity"
		return

	else
		src.log_message("Attacked by [W]. Attacker - [user]")
		if(prob(src.deflect_chance))
			user << "\red The [W] bounces off [src.name] armor."
			src.log_append_to_last("Armor saved.")
/*
			for (var/mob/V in viewers(src))
				if(V.client && !(V.blinded))
					V.show_message("The [W] bounces off [src.name] armor.", 1)
*/
		else
			src.occupant_message("[user] hits [src] with [W].")
			user.visible_message("[user] hits [src] with [W].", "You hit [src] with [W]")
			src.take_damage(W.force,W.damtype)
			src.check_for_internal_damage(list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST))
	return


/obj/mecha/proc/get_stats_html()
	var/output = {"<html>
						<head><title>[src.name] data</title></head>
						<body style="color: #00ff00; background: #000000; font: 13px 'Courier', monospace;">
						[src.get_stats_part()]
						<hr>
						[src.get_commands()]
						</body>
						</html>
					 "}
	return output

/obj/mecha/proc/get_stats_part()
	var/integrity = health/initial(health)*100
	var/output = {"[internal_damage&MECHA_INT_FIRE?"<font color='red'><b>INTERNAL FIRE</b></font><br>":null]
						[internal_damage&MECHA_INT_TEMP_CONTROL?"<font color='red'><b>LIFE SUPPORT SYSTEM MALFUNCTION</b></font><br>":null]
						[internal_damage&MECHA_INT_TANK_BREACH?"<font color='red'><b>GAS TANK BREACH</b></font><br>":null]
						[internal_damage&MECHA_INT_CONTROL_LOST?"<font color='red'><b>COORDINATION SYSTEM CALIBRATION FAILURE</b></font> - <a href='?src=\ref[src];repair_int_control_lost=1'>Recalibrate</a><br>":null]
						[integrity<30?"<font color='red'><b>DAMAGE LEVEL CRITICAL</b></font>":null]
						<b>Integrity: </b> [integrity]%<br>
						<b>Powercell charge: </b>[cell.charge/cell.maxcharge*100]%<br>
						<b>Air source: </b>[use_internal_tank?"Internal Airtank":"Environment"]<br>
						<b>Airtank pressure: </b>[src.return_pressure()]kPa<br>
						<b>Internal temperature: </b> [src.air_contents.temperature]&deg;K|[src.air_contents.temperature - T0C]&deg;C<br>
						<b>Lights: </b>[lights?"on":"off"]<br>
					"}
	return output

/obj/mecha/proc/get_commands()
	var/output = {"<a href='?src=\ref[src];toggle_lights=1'>Toggle Lights</a><br>
						<a href='?src=\ref[src];toggle_airtank=1'>Toggle Internal Airtank Usage</a><br>
						[(/obj/mecha/verb/disconnect_from_port in src.verbs)?"<a href='?src=\ref[src];port_disconnect=1'>Disconnect from port</a><br>":null]
						[(/obj/mecha/verb/connect_to_port in src.verbs)?"<a href='?src=\ref[src];port_connect=1'>Connect to port</a><br>":null]
						<a href='?src=\ref[src];view_log=1'>View internal log</a><br>
						<a href='?src=\ref[src];eject=1'>Eject</a><br>
					"}
	return output

/obj/mecha/Topic(href, href_list)
	..()
	if (href_list["close"])
		src.pr_update_stats.stop()
		return
	if (href_list["toggle_lights"])
		src.toggle_lights()
		return
	if (href_list["toggle_airtank"])
		src.toggle_internal_tank()
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
	if (href_list["view_log"])
		src.occupant << browse(src.get_log_html(), "window=exosuit_log")
		onclose(occupant, "exosuit_log")
		return
	if (href_list["repair_int_control_lost"])
		src.occupant_message("Recalibrating coordination system.")
		src.log_message("Recalibration of coordination system started.")
		var/T = src.loc
		spawn(100)
			if(T == src.loc)
				src.internal_damage &= ~MECHA_INT_CONTROL_LOST
				src.occupant_message("<font color='blue'>Recalibration successful.</font>")
				src.log_message("Recalibration of coordination system finished with 0 errors.")
			else
				src.occupant_message("<font color='red'>Recalibration failed.</font>")
				src.log_message("Recalibration of coordination system failed with 1 error.",1)
/*

	if (href_list["ai_take_control"])
		var/var/mob/living/silicon/ai/AI = locate(href_list["ai_take_control"])
		var/duration = text2num(href_list["duration"])
		var/mob/living/silicon/ai/O = new /mob/living/silicon/ai(src)
		var/cur_occupant = src.occupant
		O.invisibility = 0
		O.canmove = 1
		O.name = AI.name
		O.real_name = AI.real_name
		O.anchored = 1
		O.aiRestorePowerRoutine = 0
		O.control_disabled = 1 // Can't control things remotely if you're stuck in a card!
		O.laws_object = AI.laws_object
		O.stat = AI.stat
		O.oxyloss = AI.oxyloss
		O.fireloss = AI.fireloss
		O.bruteloss = AI.bruteloss
		O.toxloss = AI.toxloss
		O.updatehealth()
		src.occupant = O
		if(AI.mind)
			AI.mind.transfer_to(O)
		AI.name = "Inactive AI"
		AI.real_name = "Inactive AI"
		AI.icon_state = "ai-empty"
		spawn(duration)
			AI.name = O.name
			AI.real_name = O.real_name
			if(O.mind)
				O.mind.transfer_to(AI)
			AI.control_disabled = 0
			AI.laws_object = O.laws_object
			AI.oxyloss = O.oxyloss
			AI.fireloss = O.fireloss
			AI.bruteloss = O.bruteloss
			AI.toxloss = O.toxloss
			AI.updatehealth()
			del(O)
			if (!AI.stat)
				AI.icon_state = "ai"
			else
				AI.icon_state = "ai-crash"
			src.occupant = cur_occupant
*/
	return


/obj/mecha/proc/drop_item()//Derpfix, but may be useful in future for engineering exosuits.
	return

/*
/obj/mecha/attack_ai(var/mob/living/silicon/ai/user as mob)
	if(!istype(user, /mob/living/silicon/ai))
		return
	var/output = {"<b>Assume direct control over [src]?</b>
						<a href='?src=\ref[src];ai_take_control=\ref[user];duration=3000'>Yes</a><br>
						"}
	user << browse(output, "window=mecha_attack_ai")
	return
*/

/obj/mecha/hear_talk(mob/M as mob, text)
	if(occupant && M)
		var/rendered = "<span class='game say'><span class='name'>[M.name]</span> <span class='message'>[M.say_quote(text)]</span></span>"
		occupant.show_message(rendered, 2)
	return


//////////////////////////////////////////
////////  Mecha global iterators  ////////
//////////////////////////////////////////


/datum/global_iterator/mecha_preserve_temp  //normalizing air contents temperature to 20 degrees celsium
	delay = 20

	process(var/obj/mecha/mecha)
		if(mecha.air_contents && mecha.air_contents.volume > 0)
			var/delta = mecha.air_contents.temperature - T20C
			mecha.air_contents.temperature -= max(-10, min(10, round(delta/4,0.1)))
		return

/datum/global_iterator/mecha_view_stats // open and update stats window

	process(var/obj/mecha/mecha)
		if(mecha.occupant)
			mecha.occupant << browse(mecha.get_stats_html(), "window=exosuit")
			onclose(mecha.occupant, "exosuit", mecha)
		return

/datum/global_iterator/mecha_intertial_movement //inertial movement in space
	delay = 7

	process(var/obj/mecha/mecha,direction)
		if(direction)
			if(!step(mecha, direction)||mecha.check_for_support())
				src.stop()
		else
			src.stop()
		return

/datum/global_iterator/mecha_location_temp_check //mecha location temperature checks

	process(var/obj/mecha/mecha)
		if(istype(mecha.loc, /turf/simulated))
			var/turf/simulated/T = mecha.loc
			if(T.air)
				if(T.air.temperature > mecha.max_temperature)
					mecha.take_damage(5,"fire")
					mecha.check_for_internal_damage(list(MECHA_INT_FIRE, MECHA_INT_TEMP_CONTROL))
		return

/datum/global_iterator/mecha_internal_damage // processing internal damage

	process(var/obj/mecha/mecha)
		if(!mecha.internal_damage)
			src.stop()
			return
		if(mecha.internal_damage & MECHA_INT_FIRE)
			if(mecha.return_pressure()>mecha.maximum_pressure*1.5 && !(mecha.internal_damage&MECHA_INT_TANK_BREACH))
				mecha.internal_damage |= MECHA_INT_TANK_BREACH
			if(!(mecha.internal_damage & MECHA_INT_TEMP_CONTROL) && prob(5))
				mecha.internal_damage &= ~MECHA_INT_FIRE
				mecha.occupant_message("<font color='blue'><b>Internal fire extinquished.</b></font>")
			if(mecha.air_contents && mecha.air_contents.volume > 0) //heat the air_contents
				mecha.air_contents.temperature = min(1500+T0C, mecha.air_contents.temperature+rand(10,15))
				if(mecha.air_contents.temperature>mecha.max_temperature/2)
					mecha.take_damage(1,"fire")
		if(mecha.internal_damage & MECHA_INT_TEMP_CONTROL) //stop the mecha_preserve_temp loop datum
			mecha.pr_int_temp_processor.stop()
		if(mecha.internal_damage & MECHA_INT_TANK_BREACH) //remove some air from internal tank
			var/datum/gas_mixture/environment = mecha.loc.return_air()
			var/env_pressure = environment.return_pressure()
			var/pressure_delta = min(115 - env_pressure, (mecha.air_contents.return_pressure() - env_pressure)/2)
			var/transfer_moles = 0
			if(mecha.air_contents.temperature > 0 && pressure_delta > 0)
				transfer_moles = pressure_delta*environment.volume/(mecha.air_contents.temperature * R_IDEAL_GAS_EQUATION)
				mecha.loc.assume_air(mecha.air_contents.remove(transfer_moles))
		return
