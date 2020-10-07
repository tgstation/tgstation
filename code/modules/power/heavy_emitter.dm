#define EASY_TURN_ON linked_interface ? linked_interface.turn_on() : turn_on()
#define EASY_TURN_OFF linked_interface ? linked_interface.turn_off() : turn_off()
/obj/machinery/power/heavy_emitter
	name = "Heavy Emitter Base"
	desc = "Message an admin if you see this!"
	icon = 'icons/obj/heavy_emitter.dmi'
	icon_state = "centre_off"
	anchored = FALSE
	density = TRUE

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
	desc = "A dangerously unstable, military grade capacitor that eats power like it's candy, before releasing an incredibly potent burst of energy that can annihilate anything."
	idle_power_usage = 500
	active_power_usage = 2000
	///bool to check if the machine is fully constructed
	var/is_fully_constructed = FALSE
	///Current heat level
	var/heat = T0C
	///Max heat level
	var/max_heat = 1000 + T0C
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
		EASY_TURN_ON
	else
		EASY_TURN_OFF

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

/obj/machinery/power/heavy_emitter/centre/should_have_node()
	return anchored

/obj/machinery/power/heavy_emitter/centre/connect_to_network()
	if(!anchored)
		return FALSE
	. = ..()

/obj/machinery/power/heavy_emitter/centre/turn_on()
	if(!is_fully_constructed)
		return EASY_TURN_OFF
	log_game("Heavy Emitter was turned on in [loc]")
	use_power = IDLE_POWER_USE
	firing = TRUE
	icon_state = "centre"

/obj/machinery/power/heavy_emitter/centre/turn_off()
	log_game("Heavy Emitter was turned off in [loc]")
	firing = FALSE
	icon_state = "centre_off"

/obj/machinery/power/heavy_emitter/centre/process(delta_time)
	if(!firing || machine_stat & BROKEN || surplus() < active_power_usage)
		return

	if(!check_part_connectivity())
		return EASY_TURN_OFF

	timer += delta_time

	add_load(idle_power_usage)
	if(timer >= max_timer)
		timer = 0
		add_load(active_power_usage)
		radiation_pulse(src,500,can_contaminate=FALSE)
		visible_message("<span class='notice'>Heavy Emitter Core is powering the cannon....</span>")
		INVOKE_ASYNC(linked_cannon,/obj/machinery/power/heavy_emitter/cannon.proc/fire)
		heat += 500

	if(heat > max_heat)
		explosion(src,4,8,16)
		return

	for(var/V in vents)
		if(heat <= T0C || !V)
			break
		var/obj/machinery/power/heavy_emitter/vent/vent = V
		heat = vent.vent_gas(heat)

/obj/machinery/power/heavy_emitter/arm
	name = "Seismic Stabilizer Arm"
	desc = "Dampens the recoil from firing to virtually nothing"
	icon_state = "arm"

/obj/machinery/power/heavy_emitter/interface
	name = "Kinetic Amplification Manipulation Interface"
	desc = "Allows for control over the core."
	icon_state = "interface_off"
	///Core connected to this thing
	var/obj/machinery/power/heavy_emitter/centre/connected_core

/obj/machinery/power/heavy_emitter/interface/attack_hand(mob/living/user)
	. = ..()
	var/turf/T = get_step(src,turn(dir,180))
	var/obj/machinery/power/heavy_emitter/centre/centre = locate() in T

	if(!centre || !centre.check_part_connectivity())
		turn_off()
		return

	connected_core = centre

	if(connected_core.firing)
		to_chat(user, "<span class='warning'>You power on the Heavy Emitter!</span>")
		turn_off()
	else
		to_chat(user, "<span class='warning'>You disable the Heavy Emitter!</span>")
		turn_on()


/obj/machinery/power/heavy_emitter/interface/turn_on()
	icon_state = "interface"
	connected_core.turn_on()

/obj/machinery/power/heavy_emitter/interface/turn_off()
	icon_state = "interface_off"
	connected_core.turn_off()

/obj/machinery/power/heavy_emitter/vent
	name = "Energy Core Vent"
	desc = "Circulates air around the core, preventing it from overheating. Doesn't work in low pressure or when blocked by a wall"
	icon_state = "vent"

/obj/machinery/power/heavy_emitter/vent/proc/vent_gas(heat)
	. = heat
	var/turf/open/open_turf = get_step(src,dir)
	//You cant cheese it with space!
	if(!istype(open_turf) || isspaceturf(open_turf))
		return

	var/datum/gas_mixture/gases = open_turf.return_air()

	if(!gases)
		return

	flick("vent_on",src)
	return gases.temperature_share(null,0.33,heat,20000)

/obj/machinery/power/heavy_emitter/cannon
	name = "Energy Optic Converging Cannon"
	desc = "Converges the energy from the core into a singular destructive beam."
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

#undef EASY_TURN_ON
#undef EASY_TURN_OFF
