/obj/machinery/atmospherics/unary/cryo_cell
	name = "cryo cell"
	icon = 'icons/obj/cryogenics.dmi'
	icon_state = "cell-off"
	density = 1
	anchored = 1.0
	layer = 5

	var/on = 0
	var/temperature_archived
	var/mob/living/carbon/occupant = null
	var/obj/item/weapon/reagent_containers/beaker = null
	var/next_trans = 0
	var/current_heat_capacity = 50

/obj/machinery/atmospherics/unary/cryo_cell/New()
	..()
	initialize_directions = dir

/obj/machinery/atmospherics/unary/cryo_cell/Del()
	eject_contents()
	var/obj/item/weapon/reagent_containers/glass/B = beaker
	if(beaker)
		B.loc = get_step(loc, SOUTH) //Beaker is carefully ejected from the wreckage of the cryotube
	..() 

/obj/machinery/atmospherics/unary/cryo_cell/initialize()
	if(node) return
	var/node_connect = dir
	for(var/obj/machinery/atmospherics/target in get_step(src,node_connect))
		if(target.initialize_directions & get_dir(target,src))
			node = target
			break

/obj/machinery/atmospherics/unary/cryo_cell/process()
	..()
	if(!node)
		return
	if(!on)
		updateDialog()
		return

	if(air_contents)
		temperature_archived = air_contents.temperature
		heat_gas_contents()
		expel_gas()

		if(occupant)
			if(occupant.stat != 2)
				process_occupant()

	if(abs(temperature_archived-air_contents.temperature) > 1)
		network.update = 1

	updateDialog()
	return 1


/obj/machinery/atmospherics/unary/cryo_cell/allow_drop()
	return 0


/obj/machinery/atmospherics/unary/cryo_cell/container_resist()
	if(usr.stat)
		return
	go_out()
	return

/obj/machinery/atmospherics/unary/cryo_cell/examine()
	..()
	
	if(in_range(usr, src))
		usr << "You can just about make out some loose objects floating in the murk:"
		for(var/obj/O in src)
			if(O != beaker)
				usr << O.name
		for(var/mob/M in src)
			if(M != occupant)
				usr << M.name
	else
		usr << "<span class='notice'>Too far away to view contents.</span>"

/obj/machinery/atmospherics/unary/cryo_cell/attack_hand(mob/user)
	ui_interact(user)


 /**
  * The ui_interact proc is used to open and update Nano UIs
  * If ui_interact is not used then the UI will not update correctly
  * ui_interact is currently defined for /atom/movable
  *
  * @param user /mob The mob who is interacting with this ui
  * @param ui_key string A string key to use for this ui. Allows for multiple unique uis on one obj/mob (defaut value "main")
  *
  * @return nothing
  */
/obj/machinery/atmospherics/unary/cryo_cell/ui_interact(mob/user, ui_key = "main")
	if(user == occupant || user.stat)
		return

	// this is the data which will be sent to the ui
	var/data[0]
	data["isOperating"] = on
	data["hasOccupant"] = occupant ? 1 : 0

	var/occupantData[0]
	if (!occupant)
		occupantData["name"] = null
		occupantData["stat"] = null
		occupantData["health"] = null
		occupantData["maxHealth"] = null
		occupantData["minHealth"] = null
		occupantData["bruteLoss"] = null
		occupantData["oxyLoss"] = null
		occupantData["toxLoss"] = null
		occupantData["fireLoss"] = null
		occupantData["bodyTemperature"] = null
	else
		occupantData["name"] = occupant.name
		occupantData["stat"] = occupant.stat
		occupantData["health"] = occupant.health
		occupantData["maxHealth"] = occupant.maxHealth
		occupantData["minHealth"] = config.health_threshold_dead
		occupantData["bruteLoss"] = occupant.getBruteLoss()
		occupantData["oxyLoss"] = occupant.getOxyLoss()
		occupantData["toxLoss"] = occupant.getToxLoss()
		occupantData["fireLoss"] = occupant.getFireLoss()
		occupantData["bodyTemperature"] = occupant.bodytemperature
	data["occupant"] = occupantData;

	data["cellTemperature"] = round(air_contents.temperature)
	data["cellTemperatureStatus"] = "good"
	if(air_contents.temperature > T0C) // if greater than 273.15 kelvin (0 celcius)
		data["cellTemperatureStatus"] = "bad"
	else if(air_contents.temperature > 225)
		data["cellTemperatureStatus"] = "average"

	data["isBeakerLoaded"] = beaker ? 1 : 0
	var beakerContents[0]
	if(beaker && beaker:reagents && beaker:reagents.reagent_list.len)
		for(var/datum/reagent/R in beaker:reagents.reagent_list)
			beakerContents.Add(list(list("name" = R.name, "volume" = R.volume))) // list in a list because Byond merges the first list...
	data["beakerContents"] = beakerContents

	var/datum/nanoui/ui = nanomanager.get_open_ui(user, src, ui_key)
	if (!ui)
		// the ui does not exist, so we'll create a new one
		ui = new(user, src, ui_key, "cryo.tmpl", "Cryo Cell Control System", 520, 410)
		// When the UI is first opened this is the data it will use
		ui.set_initial_data(data)
		ui.open()
		// Auto update every Master Controller tick
		ui.set_auto_update(1)
	else
		// The UI is already open so push the new data to it
		ui.push_data(data)
		return
	//user.set_machine(src)

/obj/machinery/atmospherics/unary/cryo_cell/Topic(href, href_list)
	if(usr == occupant)
		return 0 // don't update UIs attached to this object

	if(..())
		return 0 // don't update UIs attached to this object

	if(href_list["switchOn"])
		on = 1
		update_icon()
		
	if(href_list["switchOff"])
		on = 0
		update_icon()

	if(href_list["ejectBeaker"])
		if(beaker)
			var/obj/item/weapon/reagent_containers/glass/B = beaker
			B.loc = get_step(loc, SOUTH)
			beaker = null
			
	if(href_list["ejectOccupant"])
		if(!occupant || isslime(usr) || ispAI(usr))
			return 0 // don't update UIs attached to this object
		go_out()
	
	add_fingerprint(usr)
	return 1 // update UIs attached to this object

/obj/machinery/atmospherics/unary/cryo_cell/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/reagent_containers/glass))
		if(beaker)
			user << "<span class='notice'>A beaker is already loaded into [src].</span>"
			return

		beaker = I
		user.drop_item()
		I.loc = src
		user.visible_message("<span class='notice'>[user] places [I] in [src].</span>", \
							"<span class='notice'>You place [I] in [src].</span>")
	else if(istype(I, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = I
		if(!ismob(G.affecting))
			return
		for(var/mob/living/carbon/slime/M in range(1, G.affecting))
			if(M.Victim == G.affecting)
				user << "[G.affecting] will not fit into [src] because they have [M] latched onto their head."
				return
		var/mob/M = G.affecting
		if(put_mob(M))
			del(G)
	nanomanager.update_uis(src)


/obj/machinery/atmospherics/unary/cryo_cell/update_icon()
	if(on)
		if(occupant)
			icon_state = "cell-occupied"
			return
		icon_state = "cell-on"
		return
	icon_state = "cell-off"


/obj/machinery/atmospherics/unary/cryo_cell/proc/process_occupant()
	if(air_contents.total_moles() < 10)
		return
	if(occupant)
		if(occupant.stat == 2)
			return
		occupant.bodytemperature += 2*(air_contents.temperature - occupant.bodytemperature) * current_heat_capacity / (current_heat_capacity + air_contents.heat_capacity())
		occupant.bodytemperature = max(occupant.bodytemperature, air_contents.temperature) // this is so ugly i'm sorry for doing it i'll fix it later i promise
		occupant.stat = 1
		if(occupant.bodytemperature < T0C)
			occupant.sleeping = max(5, (1 / occupant.bodytemperature)*2000)
			occupant.Paralyse(max(5, (1 / occupant.bodytemperature)*3000))
			if(air_contents.oxygen > 2)
				if(occupant.getOxyLoss()) occupant.adjustOxyLoss(-1)
			else
				occupant.adjustOxyLoss(-1)
			//severe damage should heal waaay slower without proper chemicals
			if(occupant.bodytemperature < 225)
				if(occupant.getToxLoss())
					occupant.adjustToxLoss(max(-1, -20 / occupant.getToxLoss()))
				var/heal_brute = occupant.getBruteLoss() ? min(1, 20 / occupant.getBruteLoss()) : 0
				var/heal_fire = occupant.getFireLoss() ? min(1, 20 / occupant.getFireLoss()) : 0
				occupant.heal_organ_damage(heal_brute,heal_fire)
		if(beaker && next_trans == 0)
			beaker.reagents.trans_to(occupant, 1, 10)
			beaker.reagents.reaction(occupant)
	next_trans++
	if(next_trans == 10)
		next_trans = 0


/obj/machinery/atmospherics/unary/cryo_cell/proc/heat_gas_contents()
	if(air_contents.total_moles() < 1)
		return
	var/air_heat_capacity = air_contents.heat_capacity()
	var/combined_heat_capacity = current_heat_capacity + air_heat_capacity
	if(combined_heat_capacity > 0)
		var/combined_energy = T20C * current_heat_capacity + air_heat_capacity * air_contents.temperature
		air_contents.temperature = combined_energy/combined_heat_capacity


/obj/machinery/atmospherics/unary/cryo_cell/proc/expel_gas()
	if(air_contents.total_moles() < 1)
		return
	var/datum/gas_mixture/expel_gas = new
	var/remove_amount = air_contents.total_moles() / 100
	expel_gas = air_contents.remove(remove_amount)
	expel_gas.temperature = T20C	//Lets expel hot gas and see if that helps people not die as they are removed
	loc.assume_air(expel_gas)
	air_update_turf()


/obj/machinery/atmospherics/unary/cryo_cell/proc/go_out()
	if(!occupant)
		return
	if(occupant.client)
		occupant.client.eye = occupant.client.mob
		occupant.client.perspective = MOB_PERSPECTIVE
	if(occupant.loc == src)
		occupant.loc = get_step(loc, SOUTH)	//this doesn't account for walls or anything, but i don't forsee that being a problem.
	if(occupant.bodytemperature < 261 && occupant.bodytemperature > 140) //Patch by Aranclanos to stop people from taking burn damage after being ejected
		occupant.bodytemperature = 261

	occupant = null
	update_icon()


/obj/machinery/atmospherics/unary/cryo_cell/proc/put_mob(mob/living/carbon/M)
	if(!istype(M))
		usr << "<span class='notice'>[src] cannot handle this liveform.</span>"
		return
	if(occupant)
		usr << "<span class='notice'>[src] is already occupied.</span>"
		return
	if(!node)
		usr << "<span class='notice'>The cell is not correctly connected to its pipe network!</span>"
		return

	if(M.client)
		M.client.perspective = EYE_PERSPECTIVE
		M.client.eye = src
	M.stop_pulling()
	M.loc = src

	if(M.health > -100 && (M.health < 0 || M.sleeping))
		M << "\blue <b>You feel a cold liquid surround you. Your skin starts to freeze up.</b>"
	occupant = M
	add_fingerprint(usr)
	update_icon()
	M.ExtinguishMob()
	return 1


/obj/machinery/atmospherics/unary/cryo_cell/verb/move_eject()
	set name = "Eject contents"
	set category = "Object"
	set src in oview(1)
	if(usr == occupant || contents.Find(usr))	//If the user is inside the tube...
		if(usr.stat == DEAD)	//and he's not dead....
			return
		usr << "<span class='notice'>Release sequence activated. This will take about two minutes.</span>"
		sleep(1200)
		if(!src || !usr || (!occupant && !contents.Find(usr)))	//Check if someone's released/replaced/bombed him already
			return
		go_out()	//and release him from the eternal prison.
		eject_contents()
	else
		if(usr.stat || isslime(usr) || ispAI(usr))
			return
		go_out()
		eject_contents()
	add_fingerprint(usr)


/obj/machinery/atmospherics/unary/cryo_cell/verb/move_inside()
	set name = "Enter cryo"
	set category = "Object"
	set src in oview(1)

	for(var/mob/living/carbon/slime/M in range(1,usr))
		if(M.Victim == usr)
			usr << "<span class='warning'>You're too busy getting your life sucked out of you!</span>"
			return
	if(usr.stat || stat & (NOPOWER|BROKEN))
		return
	put_mob(usr)

/obj/machinery/atmospherics/unary/cryo_cell/proc/eject_contents()
	for(var/obj/O in src)
		if(O != beaker)
			O.loc = get_step(loc, SOUTH)
	for(var/mob/M in contents) 
		M.loc = get_step(loc, SOUTH)
		update_icon()
