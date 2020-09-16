/obj/machinery/heavy_emitter
	name = "Heavy Emitter Base"
	desc = "This should never fucking exist!"
	icon = 'icons/obj/heavy_emitter.dmi'
	icon_state = "centre_off"
	density = TRUE
	payment_department = ACCOUNT_ENG

/obj/machinery/heavy_emitter/proc/check_part_connectivity()
	return TRUE

/obj/machinery/heavy_emitter/centre
	name = "Heavy Emitter Core"
	desc = "Dangerously unstable, military grade capacitor that eats power like it's candy and then releases an incredibly potent burst of energy that can anihiliate anything."
	idle_power_usage = 500
	active_power_usage = 2000
	var/heat = 0
	var/max_heat = 1000
	var/vent_num = 0
	var/obj/machinery/heavy_emitter/interface/linked
	var/firing = FALSE

/obj/machinery/heavy_emitter/centre/check_part_connectivity()
	. = ..()
	for(var/obj/machinery/heavy_emitter/object in orange(1,src))
		if(istype(object,/obj/machinery/heavy_emitter/arm))
			var/dir = get_dir(src,object)
			switch(dir)
				if(SOUTHEAST)
					if(object.dir != DOWN)
						return FALSE
				if(SOUTWEST)
					if(object.dir != WEST)
						return FALSE
				if(NORTHEAST)
					if(object.dir != EAST)
						return FALSE
				if(NORTHWEST)
					if(object.dir != WEST)
						return FALSE
		if(istype(object,/obj/machinery/heavy_emitter/vent))
			vent_num++
		if(istype(object,/obj/machinery/heavy_emitter/interface))
			if(!linked)
				return FALSE
			linked = object

/obj/machinery/heavy_emitter/centre/proc/turn_on()
	if(firing)
		return
	firing = TRUE
	icon_state = "centre"
	START_PROCESSING(SSobj,src)

/obj/machinery/heavy_emitter/centre/proc/turn_off()
	if(!firing)
		return
	firing = FALSE
	icon_state = "centre_off"
	STOP_PROCESSING(SSobj,src)


/obj/machinery/heavy_emitter/arm

/obj/machinery/heavy_emitter/interface
delta_time
/obj/machinery/heavy_emitter/vent
