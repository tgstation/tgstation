/obj/machinery/power/heavy_emitter
	name = "Heavy Emitter Base"
	desc = "Message an admin if you see this!"
	icon = 'icons/obj/heavy_emitter.dmi'
	icon_state = "centre_off"
	anchored = FALSE
	density = TRUE
	payment_department = ACCOUNT_ENG

/obj/machinery/power/heavy_emitter/wrench_act(mob/living/user, obj/item/I)
	. = ..()
	if(anchored)
		return FALSE
	I.play_tool_sound(src, 50)
	to_chat(user, "<span class='notice'>You start to rotate [src].</span>")
	if(do_after(user,10 SECONDS,FALSE,src))
		setDir(turn(dir,-90))
	return TRUE

/obj/machinery/power/heavy_emitter/examine(mob/user)
	. = ..()
	if(anchored)
		. += "It is welded to the floor"

/obj/machinery/power/heavy_emitter/welder_act(mob/living/user, obj/item/I)
	. = ..()
	I.play_tool_sound(src, 50)
	to_chat(user, "<span class='notice'>You start welding [src].</span>")
	if(do_after(user,10 SECONDS,FALSE,src))
		anchored = !anchored
	return TRUE

/obj/machinery/power/heavy_emitter/proc/check_part_connectivity()
	return TRUE

/obj/machinery/power/heavy_emitter/proc/turn_on()
	return

/obj/machinery/power/heavy_emitter/proc/turn_off()
	return

/obj/machinery/power/heavy_emitter/centre
	name = "Heavy Emitter Core"
	desc = "Dangerously unstable, military grade capacitor that eats power like it's candy and then releases an incredibly potent burst of energy that can anihiliate anything."
	idle_power_usage = 500
	active_power_usage = 2000
	///bool to check if the machine is fully constructed
	var/is_fully_constructed = FALSE
	///Current heat level
	var/heat = 0
	///Max heat level
	var/max_heat = 1000
	///List of adjacent vents
	var/vents = list()
	///Linked interface
	var/obj/machinery/power/heavy_emitter/interface/linked_interface
	///Linked cannon
	var/obj/machinery/power/heavy_emitter/cannon/linked_cannon
	///Is this currently firing?
	var/firing = FALSE
	///Cooldown
	var/timer = 0
	///Cooldown threshold
	var/max_timer = 10

/obj/machinery/power/heavy_emitter/centre/Initialize()
	. = ..()
	START_PROCESSING(SSobj,src)

/obj/machinery/power/heavy_emitter/centre/examine(mob/user)
	. = ..()
	if(firing)
		. += "It is currently firing"
	else
		. += "It is currently turned off"

	if(!is_fully_constructed)
		. += "Insert a pyroclastic anomaly core to fuel the core!"

/obj/machinery/power/heavy_emitter/centre/attackby(obj/item/W, mob/user, params)
	. = ..()
	if(istype(W,/obj/item/assembly/signaler/anomaly/pyro) && !is_fully_constructed)
		is_fully_constructed = TRUE
		qdel(W)

/obj/machinery/power/heavy_emitter/centre/on_set_is_operational(old_value)
	. = ..()
	if(is_operational)
		turn_on()
	else
		turn_off()

/obj/machinery/power/heavy_emitter/centre/check_part_connectivity()
	. = ..()
	if(!anchored)
		return FALSE
	for(var/obj/machinery/power/heavy_emitter/object in orange(1,src))
		if(. == FALSE)
			break
		if(!object.anchored)
			. = FALSE
		if(istype(object,/obj/machinery/power/heavy_emitter/arm))
			var/dir = get_dir(src,object)
			if(dir in GLOB.cardinals)
				. =  FALSE
			switch(dir)
				if(SOUTHEAST)
					if(object.dir != SOUTH)
						. = FALSE
				if(SOUTHWEST)
					if(object.dir != WEST)
						. =  FALSE
				if(NORTHEAST)
					if(object.dir != EAST)
						. =  FALSE
				if(NORTHWEST)
					if(object.dir != NORTH)
						. =  FALSE
			continue

		if(get_step(object,turn(object.dir,180)) != loc)
			. =  FALSE

		if(istype(object,/obj/machinery/power/heavy_emitter/vent))
			//we dont want an object to appear twice in here
			vents |= object

		if(istype(object,/obj/machinery/power/heavy_emitter/interface))
			if(linked_interface && linked_interface != object)
				. =  FALSE
			linked_interface = object

		if(istype(object,/obj/machinery/power/heavy_emitter/cannon))
			if(linked_cannon && linked_cannon != object)
				. =  FALSE
			linked_cannon = object
	if(.)
		turn_on()
	else
		turn_off()

/obj/machinery/power/heavy_emitter/centre/should_have_node()
	return anchored

/obj/machinery/power/heavy_emitter/centre/connect_to_network()
	if(!anchored)
		return FALSE
	. = ..()

/obj/machinery/power/heavy_emitter/centre/turn_on()
	if(firing || surplus() < active_power_usage || !is_fully_constructed)
		return
	use_power = IDLE_POWER_USE
	firing = TRUE
	icon_state = "centre"

/obj/machinery/power/heavy_emitter/centre/turn_off()
	if(!firing)
		return
	linked_interface.turn_off()
	firing = FALSE
	icon_state = "centre_off"

/obj/machinery/power/heavy_emitter/centre/process(delta_time)
	if(!firing || machine_stat & BROKEN)
		return
	if(surplus() < active_power_usage || !check_part_connectivity())
		turn_off()
		return

	timer += delta_time

	add_load(idle_power_usage)
	if(timer >= max_timer)
		timer = 0
		add_load(active_power_usage)
		radiation_pulse(src,500,can_contaminate=FALSE)
		INVOKE_ASYNC(linked_cannon,/obj/machinery/power/heavy_emitter/cannon.proc/fire)
		heat += 500

	if(heat > max_heat)
		explosion(src,4,8,16)
		return

	for(var/V in vents)
		if(heat <= 0 || !V)
			break
		var/obj/machinery/power/heavy_emitter/vent/vent = V
		if(vent.vent_gas())
			heat -= 100


/obj/machinery/power/heavy_emitter/arm
	name = "Seismic Stabilizer Arm"
	desc = "Reduces the knockback from firing to virtually nothing."
	icon_state = "arm"

/obj/machinery/power/heavy_emitter/interface
	name = "Kinetic Amplification Manipulation Interface"
	desc = "Allows for control over the core."
	icon_state = "interface_off"
	///Core connected to this thing
	var/connected_core

/obj/machinery/power/heavy_emitter/interface/attack_hand(mob/living/user)
	. = ..()
	if(connected_core)
		var/obj/machinery/power/heavy_emitter/centre/centre = connected_core
		if(!QDELETED(centre))
			if(centre.firing)
				centre.turn_off()
			else
				centre.turn_on()
			return

	var/turf/T = get_step(src,turn(dir,180))
	var/obj/machinery/power/heavy_emitter/centre/centre = locate() in T
	if(!centre)
		turn_off()
		return
	if(centre.check_part_connectivity())
		connected_core = centre
		turn_on()
	else
		turn_off()

/obj/machinery/power/heavy_emitter/interface/turn_on()
	icon_state = "interface"

/obj/machinery/power/heavy_emitter/interface/turn_off()
	icon_state = "interface_off"
	connected_core = null

/obj/machinery/power/heavy_emitter/vent
	name = "Energy Core Vent"
	desc = "Circulates air around core preventing overheating"
	icon_state = "vent"

/obj/machinery/power/heavy_emitter/vent/proc/vent_gas()
	var/turf/open/open_turf = get_step(src,dir)
	if(!istype(open_turf))
		return FALSE
	var/datum/gas_mixture/gases = open_turf.return_air()
	//Space can exist
	if(gases)
		gases.temperature += 100
	flick("vent_on",src)
	return TRUE

/obj/machinery/power/heavy_emitter/cannon
	name = "Energy Optic Converging Cannon"
	desc = "Converges the energy of the core into singular destructive beam."
	icon_state = "cannon"
	var/warmup_sound = 'sound/machines/warmup1.ogg'
	var/cooldown_sound = 'sound/machines/cooldown1.ogg'
	var/projectile_sound = 'sound/weapons/beam_sniper.ogg'
	var/projectile_type = /obj/projectile/beam/emitter/heavy

/obj/machinery/power/heavy_emitter/cannon/proc/fire()
	playsound(src, warmup_sound, 100)
	sleep(5 SECONDS)
	var/turf/hot_turf = get_step(src,dir)
	new /obj/effect/hotspot(hot_turf)
	var/obj/projectile/proj = new projectile_type(get_turf(src))
	playsound(src, projectile_sound, 100, TRUE)
	proj.firer = src
	proj.fired_from = src
	proj.fire(dir2angle(dir))
	playsound(src, cooldown_sound, 100)
	sleep(2 SECONDS)
