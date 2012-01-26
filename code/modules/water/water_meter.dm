/obj/machinery/water_meter
	name = "water meter"
	desc = "It measures water flow."
	icon = 'meter.dmi'
	icon_state = "meterX"
	var/obj/machinery/water/pipe/target = null
	anchored = 1.0
	var/frequency = 0
	var/id
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 4

/obj/machinery/water_meter/New()
	..()

	target = locate(/obj/machinery/water/pipe) in loc
	return 1

/obj/machinery/water_meter/initialize()
	if (!target)
		target = locate(/obj/machinery/water/pipe) in loc

/obj/machinery/water_meter/process()
	if(!target)
		icon_state = "meterX"
		return 0

	if(stat & (BROKEN|NOPOWER))
		icon_state = "meter0"
		return 0

	use_power(5)

	if(!target || !target.parent)
		icon_state = "meterX"
		return 0

	var/datum/water/pipeline/pl = target.parent
	var/pressure = pl.return_pressure() / target.max_pressure * 60*ONE_ATMOSPHERE
	if(pressure <= 0.15*ONE_ATMOSPHERE)
		icon_state = "meter0"
	else if(pressure <= 1.8*ONE_ATMOSPHERE)
		var/val = round(pressure/(ONE_ATMOSPHERE*0.3) + 0.5)
		icon_state = "meter1_[val]"
	else if(pressure <= 30*ONE_ATMOSPHERE)
		var/val = round(pressure/(ONE_ATMOSPHERE*5)-0.35) + 1
		icon_state = "meter2_[val]"
	else if(pressure <= 59*ONE_ATMOSPHERE)
		var/val = round(pressure/(ONE_ATMOSPHERE*5) - 6) + 1
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
			"pressure" = round(pl.return_pressure()),
			"sigtype" = "status"
		)
		radio_connection.post_signal(src, signal)

/obj/machinery/water_meter/examine()
	set src in view(3)

	var/t = "A gas flow meter. "
	if (target)
		if(target.parent)
			var/datum/water/pipeline/pl = target.parent
			var/pressure = pl.return_pressure()
			t += "The pressure gauge reads [round(pressure, 0.01)] kPa"
		else
			t += "The sensor error light is blinking."
	else
		t += "The connect error light is blinking."

	usr << t



/obj/machinery/water_meter/attack_hand(mob/user as mob)
	if(stat & (NOPOWER|BROKEN))
		return 1

	var/t = null
	if (get_dist(usr, src) <= 3 || istype(usr, /mob/living/silicon/ai) || istype(usr, /mob/dead))
		if (target)
			if(target.parent)
				var/datum/water/pipeline/pl = target.parent
				var/pressure = pl.return_pressure()
				t = "<B>Pressure:</B> [round(pressure, 0.01)] kPa"
			else
				t = "\red <B>Results: Sensor Error!</B>"
		else
			t = "\red <B>Results: Connection Error!</B>"
	else
		usr << "\blue <B>You are too far away.</B>"

	usr << t
	return 1

/obj/machinery/water_meter/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	if (!istype(W, /obj/item/weapon/wrench))
		return ..()
	playsound(src.loc, 'Ratchet.ogg', 50, 1)
	user << "\blue You begin to unfasten \the [src]..."
	if (do_after(user, 40))
		user.visible_message( \
			"[user] unfastens \the [src].", \
			"\blue You have unfastened \the [src].", \
			"You hear ratchet.")
		new /obj/item/water_pipe_meter(src.loc)
		del(src)