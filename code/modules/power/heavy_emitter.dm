/obj/machinery/heavy_emitter
	name = "Heavy Emitter Base"
	desc = "This should never fucking exist!"
	icon = 'icons/obj/heavy_emitter.dmi'
	icon_state = "centre_off"
	density = TRUE
	payment_department = ACCOUNT_ENG

/obj/machinery/heavy_emitter/proc/check_part_connectivity()
	return TRUE

/obj/machinery/heavy_emitter/proc/turn_on()
	return

/obj/machinery/heavy_emitter/proc/turn_off()
	return

/obj/machinery/heavy_emitter/centre
	name = "Heavy Emitter Core"
	desc = "Dangerously unstable, military grade capacitor that eats power like it's candy and then releases an incredibly potent burst of energy that can anihiliate anything."
	idle_power_usage = 500
	active_power_usage = 2000
	var/heat = 0
	var/max_heat = 1000
	var/vents = list()
	var/obj/machinery/heavy_emitter/interface/linked
	var/firing = FALSE

/obj/machinery/heavy_emitter/centre/on_set_is_operational(old_value)
	. = ..()
	if(is_operational)
		turn_on()
	else
		turn_off()

/obj/machinery/heavy_emitter/centre/check_part_connectivity()
	. = ..()
	for(var/obj/machinery/heavy_emitter/object in orange(1,src))
		if(istype(object,/obj/machinery/heavy_emitter/arm))
			var/dir = get_dir(src,object)
			if(dir in GLOB.cardinals)
				return FALSE
			switch(dir)
				if(SOUTHEAST)
					if(object.dir != DOWN)
						return FALSE
				if(SOUTHWEST)
					if(object.dir != WEST)
						return FALSE
				if(NORTHEAST)
					if(object.dir != EAST)
						return FALSE
				if(NORTHWEST)
					if(object.dir != WEST)
						return FALSE

		if(istype(object,/obj/machinery/heavy_emitter/vent))
			vents = object

		if(istype(object,/obj/machinery/heavy_emitter/interface))
			if(linked)
				return FALSE
			linked = object
	turn_on()

/obj/machinery/heavy_emitter/centre/turn_on()
	if(firing)
		return
	firing = TRUE
	icon_state = "centre"
	START_PROCESSING(SSobj,src)

/obj/machinery/heavy_emitter/centre/turn_off()
	if(!firing)
		return
	firing = FALSE
	icon_state = "centre_off"
	STOP_PROCESSING(SSobj,src)

/obj/machinery/heavy_emitter/arm
	icon_state = "arm"

/obj/machinery/heavy_emitter/interface
	icon_state = "interface_off"
	var/connected_core

/obj/machinery/heavy_emitter/interface/attack_hand(mob/living/user)
	. = ..()
	var/turf/T = get_step(src,turn(dir,180))
	var/obj/machinery/heavy_emitter/centre/centre = locate() in T
	if(!centre)
		turn_off()
		return
	if(centre.check_part_connectivity())
		connected_core = centre
		turn_on()
	else
		turn_off()

/obj/machinery/heavy_emitter/interface/turn_on()
	icon_state = "interface"

/obj/machinery/heavy_emitter/interface/turn_off()
	icon_state = "interface_off"
	connected_core = null

/obj/machinery/heavy_emitter/vent
	icon_state = "vent"

/obj/machinery/heavy_emitter/cannon
	icon_state = "cannon"
