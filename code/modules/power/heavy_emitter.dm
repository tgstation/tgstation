/obj/machinery/power/heavy_emitter
	name = "Heavy Emitter Base"
	desc = "This should never fucking exist!"
	icon = 'icons/obj/heavy_emitter.dmi'
	icon_state = "centre_off"
	density = TRUE
	payment_department = ACCOUNT_ENG

/obj/machinery/power/heavy_emitter/wrench_act(mob/living/user, obj/item/I)
	..()
	I.play_tool_sound(src, 50)
	setDir(turn(dir,-90))
	to_chat(user, "<span class='notice'>You rotate [src].</span>")
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
	var/heat = 0
	var/max_heat = 1000
	var/vents = list()
	var/obj/machinery/power/heavy_emitter/interface/linked_interface
	var/obj/machinery/power/heavy_emitter/cannon/linked_cannon
	var/firing = FALSE
	var/timer = 0
	var/max_timer = 10

/obj/machinery/power/heavy_emitter/centre/on_set_is_operational(old_value)
	. = ..()
	if(is_operational)
		turn_on()
	else
		turn_off()

/obj/machinery/power/heavy_emitter/centre/check_part_connectivity()
	. = ..()
	for(var/obj/machinery/power/heavy_emitter/object in orange(1,src))
		if(. == FALSE)
			break
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
			vents += object

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

/obj/machinery/power/heavy_emitter/centre/turn_on()
	if(firing || surplus() < active_power_usage)
		return
	use_power = IDLE_POWER_USE
	firing = TRUE
	icon_state = "centre"
	START_PROCESSING(SSobj,src)

/obj/machinery/power/heavy_emitter/centre/turn_off()
	if(!firing)
		return
	linked_interface.turn_off()
	firing = FALSE
	icon_state = "centre_off"
	STOP_PROCESSING(SSobj,src)

/obj/machinery/power/heavy_emitter/centre/process(delta_time)
	timer += delta_time

	if(surplus() < active_power_usage)
		turn_off()

	if(timer >= max_timer)
		timer = 0
		add_load(active_power_usage)
		INVOKE_ASYNC(linked_cannon,/obj/machinery/power/heavy_emitter/cannon.proc/fire)

/obj/machinery/power/heavy_emitter/arm
	icon_state = "arm"

/obj/machinery/power/heavy_emitter/interface
	icon_state = "interface_off"
	var/connected_core

/obj/machinery/power/heavy_emitter/interface/attack_hand(mob/living/user)
	. = ..()
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
	icon_state = "vent"

/obj/machinery/power/heavy_emitter/vent/proc/vent_gas()
	var/turf/open/open_turf = get_step(src,dir)
	var/datum/gas_mixture/gases = open_turf.return_air()
	gases.temperature += rand(100,500)

/obj/machinery/power/heavy_emitter/cannon
	icon_state = "cannon"
	var/warmup_sound = 'sound/machines/warmup1.ogg'
	var/cooldown_sound = 'sound/machines/cooldown1.ogg'
	var/projectile_sound = 'sound/weapons/beam_sniper.ogg'
	var/projectile_type = /obj/projectile/beam/emitter/heavy

/obj/machinery/power/heavy_emitter/cannon/proc/fire()
	playsound(src, warmup_sound, 50)
	sleep(5 SECONDS)

	var/obj/projectile/P = new projectile_type(get_turf(src))
	playsound(src, projectile_sound, 50, TRUE)
	P.firer = src
	P.fired_from = src
	P.fire(dir2angle(dir))
	playsound(src, cooldown_sound, 50)
	sleep(2 SECONDS)
