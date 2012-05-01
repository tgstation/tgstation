

/obj/vehicle
	name = "Vehicle"
	icon = 'vehicles.dmi'
	density = 1
	anchored = 1
	unacidable = 1 //To avoid the pilot-deleting shit that came with mechas
	layer = MOB_LAYER
	//var/can_move = 1
	var/mob/living/carbon/occupant = null
	//var/step_in = 10 //make a step in step_in/10 sec.
	//var/dir_in = 2//What direction will the mech face when entered/powered on? Defaults to South.
	//var/step_energy_drain = 10
	var/health = 300 //health is health
	//var/deflect_chance = 10 //chance to deflect the incoming projectiles, hits, or lesser the effect of ex_act.
	//the values in this list show how much damage will pass through, not how much will be absorbed.
	var/list/damage_absorption = list("brute"=0.8,"fire"=1.2,"bullet"=0.9,"laser"=1,"energy"=1,"bomb"=1)
	var/obj/item/weapon/cell/cell //Our power source
	var/state = 0
	var/list/log = new
	var/last_message = 0
	var/add_req_access = 1
	var/maint_access = 1
	//var/dna	//dna-locking the mech
	var/list/proc_res = list() //stores proc owners, like proc_res["functionname"] = owner reference
	var/datum/effect/effect/system/spark_spread/spark_system = new
	var/lights = 0
	var/lights_power = 6

	//inner atmos 						//These go in airtight.dm, not all vehicles are space-faring -Agouri
	//var/use_internal_tank = 0
	//var/internal_tank_valve = ONE_ATMOSPHERE
	//var/obj/machinery/portable_atmospherics/canister/internal_tank
	//var/datum/gas_mixture/cabin_air
	//var/obj/machinery/atmospherics/portables_connector/connected_port = null

	var/obj/item/device/radio/radio = null

	var/max_temperature = 2500
	//var/internal_damage_threshold = 50 //health percentage below which internal damage is possible
	var/internal_damage = 0 //contains bitflags

	var/list/operation_req_access = list()//required access level for mecha operation
	var/list/internals_req_access = list(access_engine,access_robotics)//required access level to open cell compartment

	//var/datum/global_iterator/pr_int_temp_processor //normalizes internal air mixture temperature     //In airtight.dm you go -Agouri
	var/datum/global_iterator/pr_inertial_movement //controls intertial movement in spesss

	//var/datum/global_iterator/pr_give_air //moves air from tank to cabin   //Y-you too -Agouri

	var/datum/global_iterator/pr_internal_damage //processes internal damage


	var/wreckage

	var/list/equipment = new
	var/obj/selected
	//var/max_equip = 3

	var/datum/events/events



/obj/vehicle/New()
	..()
	events = new
	icon_state += "-unmanned"
	add_radio()
	//add_cabin() //No cabin for non-airtights

	spark_system.set_up(2, 0, src)
	spark_system.attach(src)
	add_cell()
	add_iterators()
	removeVerb(/obj/mecha/verb/disconnect_from_port)
	removeVerb(/atom/movable/verb/pull)
	log_message("[src.name]'s functions initialised. Work protocols active - Entering IDLE mode.")
	loc.Entered(src)
	return


//################ Helpers ###########################################################


/obj/vehicle/proc/removeVerb(verb_path)
	verbs -= verb_path

/obj/vehicle/proc/addVerb(verb_path)
	verbs += verb_path

/*/obj/vehicle/proc/add_airtank() //In airtight.dm -Agouri
	internal_tank = new /obj/machinery/portable_atmospherics/canister/air(src)
	return internal_tank*/

/obj/vehicle/proc/add_cell(var/obj/item/weapon/cell/C=null)
	if(C)
		C.forceMove(src)
		cell = C
		return
	cell = new(src)
	cell.charge = 15000
	cell.maxcharge = 15000

/*/obj/vehicle/proc/add_cabin()   //In airtight.dm -Agouri
	cabin_air = new
	cabin_air.temperature = T20C
	cabin_air.volume = 200
	cabin_air.oxygen = O2STANDARD*cabin_air.volume/(R_IDEAL_GAS_EQUATION*cabin_air.temperature)
	cabin_air.nitrogen = N2STANDARD*cabin_air.volume/(R_IDEAL_GAS_EQUATION*cabin_air.temperature)
	return cabin_air*/

/obj/vehicle/proc/add_radio()
	radio = new(src)
	radio.name = "[src] radio"
	radio.icon = icon
	radio.icon_state = icon_state
	radio.subspace_transmission = 1

/obj/vehicle/proc/add_iterators()
	pr_inertial_movement = new /datum/global_iterator/vehicle_intertial_movement(null,0)
	//pr_internal_damage = new /datum/global_iterator/vehicle_internal_damage(list(src),0)
	//pr_int_temp_processor = new /datum/global_iterator/vehicle_preserve_temp(list(src)) //In airtight.dm's add_airtight_iterators -Agouri
	//pr_give_air = new /datum/global_iterator/vehicle_tank_give_air(list(src)            //Same here -Agouri

/obj/vehicle/proc/check_for_support()
	if(locate(/obj/structure/grille, orange(1, src)) || locate(/obj/structure/lattice, orange(1, src)) || locate(/turf/simulated, orange(1, src)) || locate(/turf/unsimulated, orange(1, src)))
		return 1
	else
		return 0

//################ Logs and messages ############################################


/obj/vehicle/proc/log_message(message as text,red=null)
	log.len++
	log[log.len] = list("time"=world.timeofday,"message"="[red?"<font color='red'>":null][message][red?"</font>":null]")
	return log.len



//################ Global Iterator Datums ######################################


/datum/global_iterator/vehicle_intertial_movement //inertial movement in space
	delay = 7

	process(var/obj/vehicle/V as obj, direction)
		if(direction)
			if(!step(V, direction)||V.check_for_support())
				src.stop()
		else
			src.stop()
		return


/datum/global_iterator/mecha_internal_damage // processing internal damage

	process(var/obj/mecha/mecha)
		if(!mecha.hasInternalDamage())
			return stop()
		if(mecha.hasInternalDamage(MECHA_INT_FIRE))
			if(!mecha.hasInternalDamage(MECHA_INT_TEMP_CONTROL) && prob(5))
				mecha.clearInternalDamage(MECHA_INT_FIRE)
			if(mecha.internal_tank)
				if(mecha.internal_tank.return_pressure()>mecha.internal_tank.maximum_pressure && !(mecha.hasInternalDamage(MECHA_INT_TANK_BREACH)))
					mecha.setInternalDamage(MECHA_INT_TANK_BREACH)
				var/datum/gas_mixture/int_tank_air = mecha.internal_tank.return_air()
				if(int_tank_air && int_tank_air.return_volume()>0) //heat the air_contents
					int_tank_air.temperature = min(6000+T0C, int_tank_air.temperature+rand(10,15))
			if(mecha.cabin_air && mecha.cabin_air.return_volume()>0)
				mecha.cabin_air.temperature = min(6000+T0C, mecha.cabin_air.return_temperature()+rand(10,15))
				if(mecha.cabin_air.return_temperature()>mecha.max_temperature/2)
					mecha.take_damage(4/round(mecha.max_temperature/mecha.cabin_air.return_temperature(),0.1),"fire")
		if(mecha.hasInternalDamage(MECHA_INT_TEMP_CONTROL)) //stop the mecha_preserve_temp loop datum
			mecha.pr_int_temp_processor.stop()
		if(mecha.hasInternalDamage(MECHA_INT_TANK_BREACH)) //remove some air from internal tank
			if(mecha.internal_tank)
				var/datum/gas_mixture/int_tank_air = mecha.internal_tank.return_air()
				var/datum/gas_mixture/leaked_gas = int_tank_air.remove_ratio(0.10)
				if(mecha.loc && hascall(mecha.loc,"assume_air"))
					mecha.loc.assume_air(leaked_gas)
				else
					del(leaked_gas)
		if(mecha.hasInternalDamage(MECHA_INT_SHORT_CIRCUIT))
			if(mecha.get_charge())
				mecha.spark_system.start()
				mecha.cell.charge -= min(20,mecha.cell.charge)
				mecha.cell.maxcharge -= min(20,mecha.cell.maxcharge)
		return