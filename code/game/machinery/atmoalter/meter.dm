/obj/machinery/meter
	name = "gas flow meter"
	desc = "It measures something."
	icon = 'icons/obj/meter.dmi'
	icon_state = "meterX"
	var/obj/machinery/atmospherics/pipe/target = null
	anchored = 1.0
	power_channel = ENVIRON
	var/frequency = 0
	var/id
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 4

/obj/machinery/meter/New()
	..()
	SSair.atmos_machinery += src
	src.target = locate(/obj/machinery/atmospherics/pipe) in loc
	return 1

/obj/machinery/meter/Destroy()
	SSair.atmos_machinery -= src
	src.target = null
	..()

/obj/machinery/meter/initialize()
	if (!target)
		src.target = locate(/obj/machinery/atmospherics/pipe) in loc

/obj/machinery/meter/process_atmos()
	if(!target)
		icon_state = "meterX"
		return 0

	if(stat & (BROKEN|NOPOWER))
		icon_state = "meter0"
		return 0

	use_power(5)

	var/datum/gas_mixture/environment = target.return_air()
	if(!environment)
		icon_state = "meterX"
		return 0

	var/env_pressure = environment.return_pressure()
	if(env_pressure <= 0.15*ONE_ATMOSPHERE)
		icon_state = "meter0"
	else if(env_pressure <= 1.8*ONE_ATMOSPHERE)
		var/val = round(env_pressure/(ONE_ATMOSPHERE*0.3) + 0.5)
		icon_state = "meter1_[val]"
	else if(env_pressure <= 30*ONE_ATMOSPHERE)
		var/val = round(env_pressure/(ONE_ATMOSPHERE*5)-0.35) + 1
		icon_state = "meter2_[val]"
	else if(env_pressure <= 59*ONE_ATMOSPHERE)
		var/val = round(env_pressure/(ONE_ATMOSPHERE*5) - 6) + 1
		icon_state = "meter3_[val]"
	else
		icon_state = "meter4"

	if(frequency)
		var/datum/radio_frequency/radio_connection = radio_controller.return_frequency(frequency)

		if(!radio_connection) return

		var/datum/signal/signal = new
		signal.source = src
		signal.transmission_method = 1
		signal.data = list(
			"tag" = id,
			"device" = "AM",
			"pressure" = round(env_pressure),
			"sigtype" = "status"
		)
		radio_connection.post_signal(src, signal)

/obj/machinery/meter/proc/status()
	var/t = ""
	if (src.target)
		var/datum/gas_mixture/environment = target.return_air()
		if(environment)
			t += "The pressure gauge reads [round(environment.return_pressure(), 0.01)] kPa; [round(environment.temperature,0.01)] K ([round(environment.temperature-T0C,0.01)]&deg;C)"
		else
			t += "The sensor error light is blinking."
	else
		t += "The connect error light is blinking."
	return t

/obj/machinery/meter/examine(mob/user)
	..()
	user << status()


/obj/machinery/meter/attackby(obj/item/weapon/W, mob/user, params)
	if (istype(W, /obj/item/weapon/wrench))
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		user << "<span class='notice'>You begin to unfasten \the [src]...</span>"
		if (do_after(user, 40, target = src))
			user.visible_message( \
				"[user] unfastens \the [src].", \
				"<span class='notice'>You unfasten \the [src].</span>", \
				"<span class='italics'>You hear ratchet.</span>")
			new /obj/item/pipe_meter(src.loc)
			qdel(src)
		return
	..()

/obj/machinery/meter/attack_ai(mob/user)
	return src.attack_hand(user)

/obj/machinery/meter/attack_paw(mob/user)
	return src.attack_hand(user)

/obj/machinery/meter/attack_hand(mob/user)

	if(stat & (NOPOWER|BROKEN))
		return 1
	else
		usr << status()
		return 1

/obj/machinery/meter/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		new /obj/item/pipe_meter(loc)
		qdel(src)

// TURF METER - REPORTS A TILE'S AIR CONTENTS
//	why are you yelling?

/obj/machinery/meter/turf/New()
	..()
	src.target = loc
	return 1


/obj/machinery/meter/turf/initialize()
	if (!target)
		src.target = loc

