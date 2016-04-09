var/global/list/cryo_health_indicator = list(	"full" = image("icon" = 'icons/obj/cryogenics.dmi', "icon_state" = "moverlay_full"),\
												"good" = image("icon" = 'icons/obj/cryogenics.dmi', "icon_state" = "moverlay_good"),\
												"average" = image("icon" = 'icons/obj/cryogenics.dmi', "icon_state" = "moverlay_average"),\
												"bad" = image("icon" = 'icons/obj/cryogenics.dmi', "icon_state" = "moverlay_bad"),\
												"worse" = image("icon" = 'icons/obj/cryogenics.dmi', "icon_state" = "moverlay_worse"),\
												"crit" = image("icon" = 'icons/obj/cryogenics.dmi', "icon_state" = "moverlay_crit"),\
												"dead" = image("icon" = 'icons/obj/cryogenics.dmi', "icon_state" = "moverlay_dead"))
/obj/machinery/atmospherics/unary/cryo_cell
	name = "cryo cell"
	icon = 'icons/obj/cryogenics.dmi'
	icon_state = "cell-off"
	density = 1
	anchored = 1.0
	layer = 2.8

	var/on = 0
	var/ejecting = 0
	var/temperature_archived
	var/mob/living/carbon/occupant = null
	var/obj/item/weapon/reagent_containers/glass/beaker = null

	var/current_heat_capacity = 50

	machine_flags = SCREWTOGGLE | CROWDESTROY

	light_color = LIGHT_COLOR_GREEN
	light_range_on = 1
	light_power_on = 2
	use_auto_lights = 1

/obj/machinery/atmospherics/unary/cryo_cell/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/cryo,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/console_screen
	)

	RefreshParts()

	initialize_directions = dir
	initialize()
	build_network()
	if (node)
		node.initialize()
		node.build_network()

/obj/machinery/atmospherics/unary/cryo_cell/initialize()
	if(node) return
	for(var/cdir in cardinal)
		node = findConnecting(cdir)
		if(node)
			break
	update_icon()

/obj/machinery/atmospherics/unary/cryo_cell/Destroy()
	go_out()
	if(beaker)
		detach()
		//beaker.loc = get_step(loc, SOUTH) //Beaker is carefully ejected from the wreckage of the cryotube
	..()

/obj/machinery/atmospherics/unary/cryo_cell/MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
	if(!ismob(O)) //humans only
		return
	if(O.loc == user) //no you can't pull things out of your ass
		return
	if(user.incapacitated() || user.lying) //are you cuffed, dying, lying, stunned or other
		return
	if(O.anchored || get_dist(user, src) > 1 || get_dist(user, O) > 1 || user.contents.Find(src)) // is the mob anchored, too far away from you, or are you too far away from the source
		return
	if(istype(O, /mob/living/simple_animal) || istype(O, /mob/living/silicon)) //animals and robutts dont fit
		return
	if(!ishuman(user) && !isrobot(user)) //No ghosts or mice putting people into the sleeper
		return
	if(user.loc==null) // just in case someone manages to get a closet into the blue light dimension, as unlikely as that seems
		return
	if(!istype(user.loc, /turf) || !istype(O.loc, /turf)) // are you in a container/closet/pod/etc?
		return
	if(occupant)
		to_chat(user, "<span class='bnotice'>The cryo cell is already occupied!</span>")
		return
	if(isrobot(user))
		var/mob/living/silicon/robot/robit = usr
		if(istype(robit) && !istype(robit.module, /obj/item/weapon/robot_module/medical))
			to_chat(user, "<span class='warning'>You do not have the means to do this!</span>")
			return
	var/mob/living/L = O
	if(!istype(L) || L.locked_to)
		return
	/*if(L.abiotic())
		to_chat(user, "<span class='danger'>Subject cannot have abiotic items on.</span>")
		return*/
	for(var/mob/living/carbon/slime/M in range(1,L))
		if(M.Victim == L)
			to_chat(usr, "[L.name] will not fit into the cryo cell because they have a slime latched onto their head.")
			return
	if(put_mob(L))
		if(L == user)
			visible_message("[user] climbs into \the [src].")
		else
			visible_message("[user] puts [L.name] into \the [src].")
			if(user.pulling == L)
				user.pulling = null

/obj/machinery/atmospherics/unary/cryo_cell/MouseDrop(over_object, src_location, var/turf/over_location, src_control, over_control, params)
	if(!ishuman(usr) && !isrobot(usr) || occupant == usr || usr.incapacitated() || usr.lying)
		return
	if(!occupant)
		to_chat(usr, "<span class='warning'>The sleeper is unoccupied!</span>")
		return
	if(isrobot(usr))
		var/mob/living/silicon/robot/robit = usr
		if(istype(robit) && !istype(robit.module, /obj/item/weapon/robot_module/medical))
			to_chat(usr, "<span class='warning'>You do not have the means to do this!</span>")
			return
	if(!istype(over_location) || over_location.density)
		return
	if(!Adjacent(over_location) || !Adjacent(usr) || !usr.Adjacent(over_location))
		return
	for(var/atom/movable/A in over_location.contents)
		if(A.density)
			if((A == src) || istype(A, /mob))
				continue
			return
	visible_message("[usr] starts to remove [occupant.name] from \the [src].")
	go_out(over_location)

/obj/machinery/atmospherics/unary/cryo_cell/process()
	..()

	if(stat & NOPOWER)
		on = 0

	update_icon()
	if(!node)
		return
	if(!on)
		updateUsrDialog()
		return

	if(occupant)
		if(occupant.stat != 2)
			process_occupant()

	if(air_contents)
		temperature_archived = air_contents.temperature
		heat_gas_contents()
		expel_gas()

	if(abs(temperature_archived-air_contents.temperature) > 1)
		network.update = 1

	updateUsrDialog()
	return 1


/obj/machinery/atmospherics/unary/cryo_cell/allow_drop()
	return 0


/obj/machinery/atmospherics/unary/cryo_cell/relaymove(mob/user as mob)
	if(user.stat)
		return
	go_out()
	return

/obj/machinery/atmospherics/unary/cryo_cell/examine(mob/user)
	..()
	if(Adjacent(user))
		if(contents)
			to_chat(user, "You can just about make out some properties of the cryo's murky depths:")
			for(var/atom/movable/floater in (contents - beaker))
				to_chat(user, "A figure floats in the depths, they appear to be [floater.name]")
			if(beaker)
				to_chat(user, "A beaker, releasing the following chemicals into the fluids:")
				for(var/datum/reagent/R in beaker.reagents.reagent_list)
					to_chat(user, "<span class='info'>[R.volume] units of [R.name]</span>")
		else
			to_chat(user, "<span class='info'>The chamber appears devoid of anything but its biotic fluids.</span>")
	else
		to_chat(user, "<span class='notice'>Too far away to view contents.</span>")

/obj/machinery/atmospherics/unary/cryo_cell/attack_hand(mob/user)
	ui_interact(user)

 /**
  * The ui_interact proc is used to open and update Nano UIs
  * If ui_interact is not used then the UI will not update correctly
  * ui_interact is currently defined for /atom/movable (which is inherited by /obj and /mob)
  *
  * @param user /mob The mob who is interacting with this ui
  * @param ui_key string A string key to use for this ui. Allows for multiple unique uis on one obj/mob (defaut value "main")
  * @param ui /datum/nanoui This parameter is passed by the nanoui process() proc when updating an open ui
  *
  * @return nothing
  */
/obj/machinery/atmospherics/unary/cryo_cell/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null)

	if(user == occupant || (user.stat && !isobserver(user)))
		return

	// this is the data which will be sent to the ui
	var/data[0]
	data["isOperating"] = on
	data["ejecting"] 	= ejecting
	data["hasOccupant"] = occupant ? 1 : 0

	var/occupantData[0]
	if (occupant)
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
	data["occupantTemperatureStatus"] = "bad"
	if(occupant)
		if(occupant.bodytemperature <= 170) //Temperature at which Cryoxadone and Clonexadone start working
			data["occupantTemperatureStatus"] = "good"
		else if(occupant.bodytemperature <= T0C + 31) //Temperature at which a body temperature regulation cycle is necessary before ejection
			data["occupantTemperatureStatus"] = "average"

	data["isBeakerLoaded"] = beaker ? 1 : 0
	/* // Removing beaker contents list from front-end, replacing with a total remaining volume
	var beakerContents[0]
	if(beaker && beaker.reagents && beaker.reagents.reagent_list.len)
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			beakerContents.Add(list(list("name" = R.name, "volume" = R.volume))) // list in a list because Byond merges the first list...
	data["beakerContents"] = beakerContents
	*/
	data["beakerLabel"] = null
	data["beakerVolume"] = 0
	if(beaker)
		data["beakerLabel"] = beaker.label_text ? beaker.label_text : null
		if (beaker.reagents && beaker.reagents.reagent_list.len)
			for(var/datum/reagent/R in beaker.reagents.reagent_list)
				data["beakerVolume"] += R.volume

	// update the ui if it exists, returns null if no ui is passed/found
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "cryo.tmpl", "Cryo Cell Control System", 520, 410)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()
		// auto update every Master Controller tick
		ui.set_auto_update(1)

/obj/machinery/atmospherics/unary/cryo_cell/Topic(href, href_list)
	if(usr == occupant)
		return 0 // don't update UIs attached to this object

	if(..())
		return 0 // don't update UIs attached to this object

	if(href_list["close"])
		if(usr.machine == src) usr.unset_machine()
		return 1

	if(href_list["switchOn"])
		on = 1
		update_icon()

	if(href_list["switchOff"])
		on = 0
		update_icon()

	if(href_list["ejectBeaker"])
		if(beaker)
			detach()

	if(href_list["ejectOccupant"])
		if(!occupant || isslime(usr) || ispAI(usr))
			return 0 // don't update UIs attached to this object
		go_out()

	add_fingerprint(usr)
	return 1 // update UIs attached to this object
/obj/machinery/atmospherics/unary/cryo_cell/proc/detach()
	if(beaker)
		beaker.loc = get_step(loc, SOUTH)
		if(istype(beaker, /obj/item/weapon/reagent_containers/glass/beaker/large/cyborg))
			var/mob/living/silicon/robot/R = beaker:holder:loc
			if(R.module_state_1 == beaker || R.module_state_2 == beaker || R.module_state_3 == beaker)
				beaker.loc = R
			else
				beaker.loc = beaker:holder
		beaker = null

/obj/machinery/atmospherics/unary/cryo_cell/crowbarDestroy(mob/user)
	if(on)
		to_chat(user, "[src] is on.")
		return
	if(occupant)
		to_chat(user, "<span class='warning'>[occupant.name] is inside the [src]!</span>")
		return
	if(beaker) //special check to avoid destroying this
		detach()
	return ..()

/obj/machinery/atmospherics/unary/cryo_cell/attackby(var/obj/item/weapon/G as obj, var/mob/user as mob)
	if(istype(G, /obj/item/weapon/reagent_containers/glass))
		if(beaker)
			to_chat(user, "<span class='warning'>A beaker is already loaded into the machine.</span>")
			return
		if(user.drop_item(G, src))
			beaker =  G
			user.visible_message("[user] adds \a [G] to \the [src]!", "You add \a [G] to \the [src]!")
	if(iswrench(G))//FUCK YOU PARENT, YOU AREN'T MY REAL DAD
		return
	if(..())
		return
	if (panel_open)
		user.set_machine(src)
		interact(user)
		return 1
	if(istype(G, /obj/item/weapon/grab))
		if(!ismob(G:affecting))
			return
		for(var/mob/living/carbon/slime/M in range(1,G:affecting))
			if(M.Victim == G:affecting)
				to_chat(usr, "[G:affecting:name] will not fit into the cryo because they have a slime latched onto their head.")
				return
		var/mob/M = G:affecting
		if(put_mob(M))
			qdel(G)
			G = null
	updateUsrDialog()
	return

/obj/machinery/atmospherics/unary/cryo_cell/update_icon()
	overlays.len = 0
	if(on)
		if(occupant)
			if(occupant.stat == DEAD || !occupant.has_brain())
				overlays += cryo_health_indicator["dead"]
			else
				if(occupant.health >= occupant.maxHealth)
					overlays += cryo_health_indicator["full"]
				else
					if(occupant.health < config.health_threshold_crit)
						overlays += cryo_health_indicator["crit"]
					else
						switch((occupant.health / occupant.maxHealth) * 100) // Get a ratio of health to work with
							if(100 to INFINITY) // No idea how we got here with the check above...
								overlays += cryo_health_indicator["full"]
							if(75 to 100)
								overlays += cryo_health_indicator["good"]
							if(50 to 75)
								overlays += cryo_health_indicator["average"]
							if(25 to 50)
								overlays += cryo_health_indicator["bad"]
							if(1 to 25)
								overlays += cryo_health_indicator["worse"]
							else //Shouldn't ever happen.
								overlays += cryo_health_indicator["dead"]
			icon_state = "cell-occupied"
			return
		icon_state = "cell-on"
		return
	icon_state = "cell-off"

/obj/machinery/atmospherics/unary/cryo_cell/proc/process_occupant()
	if(air_contents.total_moles() < 10)
		return
	if(occupant)
		if(occupant.stat == DEAD)
			return
		modify_occupant_bodytemp()
		occupant.stat = 1
		if(occupant.bodytemperature < T0C)
			occupant.sleeping = max(5, (1/occupant.bodytemperature)*2000)
			occupant.Paralyse(max(5, (1/occupant.bodytemperature)*3000))
			var/mob/living/carbon/human/guy = occupant //Gotta cast to read this guy's species
			if(istype(guy) && guy.species && guy.species.breath_type != "oxygen")
				occupant.nobreath = 15 //Prevent them from suffocating until someone can get them internals. Also prevents plasmamen from combusting.
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
		var/has_cryo = occupant.reagents.get_reagent_amount("cryoxadone") >= 1
		var/has_clonexa = occupant.reagents.get_reagent_amount("clonexadone") >= 1
		var/has_cryo_medicine = has_cryo || has_clonexa
		if(beaker && !has_cryo_medicine)
			beaker.reagents.trans_to(occupant, 1, 1)
			beaker.reagents.reaction(occupant)

/obj/machinery/atmospherics/unary/cryo_cell/proc/modify_occupant_bodytemp()
	if(!occupant)
		return
	if(!ejecting)
		occupant.bodytemperature += 20*(air_contents.temperature - occupant.bodytemperature)*current_heat_capacity/(current_heat_capacity + air_contents.heat_capacity())
		occupant.bodytemperature = max(occupant.bodytemperature, air_contents.temperature) // this is so ugly i'm sorry for doing it i'll fix it later i promise
	else
		occupant.bodytemperature = mix(occupant.bodytemperature, T0C + 37, 0.6)

/obj/machinery/atmospherics/unary/cryo_cell/proc/heat_gas_contents()
	if(air_contents.total_moles() < 1)
		return
	var/air_heat_capacity = air_contents.heat_capacity()
	var/combined_heat_capacity = current_heat_capacity + air_heat_capacity
	if(combined_heat_capacity > 0)
		var/combined_energy = T20C*current_heat_capacity + air_heat_capacity*air_contents.temperature
		air_contents.temperature = combined_energy/combined_heat_capacity

/obj/machinery/atmospherics/unary/cryo_cell/proc/expel_gas()
	if(air_contents.total_moles() < 1)
		return
//	var/datum/gas_mixture/expel_gas = new
//	var/remove_amount = air_contents.total_moles()/50
//	expel_gas = air_contents.remove(remove_amount)

	// Just have the gas disappear to nowhere.
	//expel_gas.temperature = T20C // Lets expel hot gas and see if that helps people not die as they are removed
	//loc.assume_air(expel_gas)

/obj/machinery/atmospherics/unary/cryo_cell/proc/go_out(var/exit = src.loc)
	if(!occupant || ejecting)
		return 0
	if (occupant.bodytemperature > T0C+31)
		boot_contents(exit, regulatetemp = 0) //No temperature regulation cycle required
	else
		ejecting = 1
		playsound(get_turf(src), 'sound/machines/pressurehiss.ogg', 40, 1)
		modify_occupant_bodytemp() //Start to heat them up a little bit immediately
		nanomanager.update_uis(src)
		spawn(4 SECONDS)
			if(!src || !src.ejecting)
				return
			ejecting = 0
			boot_contents(exit)
	return 1

/obj/machinery/atmospherics/unary/cryo_cell/proc/boot_contents(var/exit = src.loc, var/regulatetemp = 1)
	for (var/atom/movable/x in src.contents)
		if((x in component_parts) || (x == src.beaker))
			continue
		x.forceMove(src.loc)
	if(occupant)
		if(exit == src.loc)
			occupant.forceMove(get_step(loc, SOUTH))	//this doesn't account for walls or anything, but i don't forsee that being a problem.
		else
			occupant.forceMove(exit)
		occupant.reset_view()
		if (regulatetemp && occupant.bodytemperature < T0C+34.5)
			occupant.bodytemperature = T0C+34.5 //just a little bit chilly still
	//	occupant.metabslow = 0
		occupant = null
	update_icon()
	nanomanager.update_uis(src)


/obj/machinery/atmospherics/unary/cryo_cell/proc/put_mob(mob/living/carbon/M as mob)
	if (!istype(M))
		to_chat(usr, "<span class='danger'>The cryo cell cannot handle such a lifeform!</span>")
		return
	if (occupant)
		to_chat(usr, "<span class='danger'>The cryo cell is already occupied!</span>")
		return
	/*if (M.abiotic())
		to_chat(usr, "<span class='warning'>Subject may not have abiotic items on.</span>")
		return*/
	if(M.locked_to)
		M.unlock_from()
	if(!node)
		to_chat(usr, "<span class='warning'>The cell is not correctly connected to its pipe network!</span>")
		return
	if(usr.pulling == M)
		usr.stop_pulling()
	M.stop_pulling()
	M.loc = src
	M.reset_view()
	if(M.health > -100 && (M.health < 0 || M.sleeping))
		to_chat(M, "<span class='bnotice'>You feel a cold liquid surround you. Your skin starts to freeze up.</span>")
	occupant = M
	//M.metabslow = 1
	add_fingerprint(usr)
	update_icon()
	nanomanager.update_uis(src)
	M.ExtinguishMob()
	return 1

/obj/machinery/atmospherics/unary/cryo_cell/verb/move_eject()
	set name = "Eject occupant"
	set category = "Object"
	set src in oview(1)
	if(usr == occupant)//If the user is inside the tube...
		if (usr.isDead())//and he's not dead....
			return
		to_chat(usr, "<span class='notice'>Release sequence activated. This will take thirty seconds.</span>")
		sleep(300)
		if(!src || !usr || !occupant || (occupant != usr)) //Check if someone's released/replaced/bombed him already
			return
		go_out()//and release him from the eternal prison.
	else
		if (usr.isUnconscious() || istype(usr, /mob/living/simple_animal))
			return
		go_out()
	add_fingerprint(usr)
	return

/obj/machinery/atmospherics/unary/cryo_cell/verb/move_inside()
	set name = "Move Inside"
	set category = "Object"
	set src in oview(1)
	if(usr.incapacitated() || usr.lying || usr.locked_to) //are you cuffed, dying, lying, stunned or other
		return
	for(var/mob/living/carbon/slime/M in range(1,usr))
		if(M.Victim == usr)
			to_chat(usr, "You're too busy getting your life sucked out of you.")
			return
	if (usr.isUnconscious() || stat & (NOPOWER|BROKEN))
		return
	put_mob(usr)
	return



/datum/data/function/proc/reset()
	return

/datum/data/function/proc/r_input(href, href_list, mob/user as mob)
	return

/datum/data/function/proc/display()
	return
