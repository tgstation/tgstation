/obj/machinery/meter/New()
	..()

	src.target = locate(/obj/machinery/atmospherics/pipe) in loc

	return 1

/obj/machinery/meter/initialize()
	if (!target)
		src.target = locate(/obj/machinery/atmospherics/pipe) in loc

/obj/machinery/meter/process()
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

/obj/machinery/meter/examine()
	set src in view(3)

	var/t = "A gas flow meter. "
	if (src.target)
		var/datum/gas_mixture/environment = target.return_air()
		if(environment)
			t += "The pressure gauge reads [round(environment.return_pressure(), 0.01)] kPa; [round(environment.temperature,0.01)]&deg;K ([round(environment.temperature-T0C,0.01)]&deg;C)"
		else
			t += "The sensor error light is blinking."
	else
		t += "The connect error light is blinking."

	usr << t



/obj/machinery/meter/Click()

	if(stat & (NOPOWER|BROKEN))
		return 1

	var/t = null
	if (get_dist(usr, src) <= 3 || istype(usr, /mob/living/silicon/ai) || istype(usr, /mob/dead))
		if (src.target)
			var/datum/gas_mixture/environment = target.return_air()
			if(environment)
				t = "<B>Pressure:</B> [round(environment.return_pressure(), 0.01)] kPa; <B>Temperature:</B> [round(environment.temperature,0.01)]&deg;K ([round(environment.temperature-T0C,0.01)]&deg;C)"
			else
				t = "\red <B>Results: Sensor Error!</B>"
		else
			t = "\red <B>Results: Connection Error!</B>"
	else
		usr << "\blue <B>You are too far away.</B>"

	usr << t
	return 1

/obj/machinery/meter/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	if (!istype(W, /obj/item/weapon/wrench))
		return ..()
	playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
	user << "\blue You begin to unfasten \the [src]..."
	if (do_after(user, 40))
		user.visible_message( \
			"[user] unfastens \the [src].", \
			"\blue You have unfastened \the [src].", \
			"You hear ratchet.")
		new /obj/item/pipe_meter(src.loc)
		del(src)