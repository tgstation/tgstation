/obj/machinery/meter
	name = "meter"
	desc = "It measures something."
	icon = 'icons/obj/meter.dmi'
	icon_state = "meterX"
	var/obj/machinery/atmospherics/pipe/target = null
	anchored = 1.0
	power_channel = ENVIRON
	var/frequency = 0
	var/id_tag
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 4

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
		// Pop the meter off when the pipe we're attached to croaks.
		new /obj/item/pipe_meter(src.loc)
		spawn(0) del(src)
		return 0

	if(stat & (BROKEN|NOPOWER))
		icon_state = "meter0"
		return 0

	use_power(5)

	var/datum/gas_mixture/environment = target.return_air()
	if(!environment)
		icon_state = "meterX"
		// Pop the meter off when the environment we're attached to croaks.
		new /obj/item/pipe_meter(src.loc)
		spawn(0) del(src)
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
			"tag" = id_tag,
			"device" = "AM",
			"pressure" = round(env_pressure),
			"temperature" = round(environment.temperature),
			"sigtype" = "status"
		)

		var/total_moles = environment.total_moles()
		if(total_moles > 0)
			signal.data["oxygen"] = round(100*environment.oxygen/total_moles,0.1)
			signal.data["toxins"] = round(100*environment.toxins/total_moles,0.1)
			signal.data["nitrogen"] = round(100*environment.nitrogen/total_moles,0.1)
			signal.data["carbon_dioxide"] = round(100*environment.carbon_dioxide/total_moles,0.1)
		else
			signal.data["oxygen"] = 0
			signal.data["toxins"] = 0
			signal.data["nitrogen"] = 0
			signal.data["carbon_dioxide"] = 0

		radio_connection.post_signal(src, signal)

/obj/machinery/meter/proc/status()
	var/t = ""
	if (src.target)
		var/datum/gas_mixture/environment = target.return_air()
		if(environment)
			t += "The pressure gauge reads [round(environment.return_pressure(), 0.01)] kPa; [round(environment.temperature,0.01)]&deg;K ([round(environment.temperature-T0C,0.01)]&deg;C)"
		else
			t += "The sensor error light is blinking."
	else
		t += "The connect error light is blinking."
	return t

/obj/machinery/meter/examine()
	set src in view(3)

	var/t = "A gas flow meter. "
	t += status()
	usr << t

/obj/machinery/meter/attack_ai(var/mob/user)
	attack_hand(user)

/obj/machinery/meter/attack_ghost(var/mob/user)
	attack_hand(user)

// Why the FUCK was this Click()?
/obj/machinery/meter/attack_hand(var/mob/user)
	if(stat & (NOPOWER|BROKEN))
		return 1

	var/t = null
	if (get_dist(usr, src) <= 3 || istype(usr, /mob/living/silicon/ai) || istype(usr, /mob/dead))
		t += status()
	else
		usr << "\blue <B>You are too far away.</B>"
		return 1

	usr << t
	return 1

/obj/machinery/meter/multitool_menu(var/mob/user, var/obj/item/device/multitool/P)
	return {"
	<b>Main</b>
	<ul>
		<li><b>Frequency:</b> <a href="?src=\ref[src];set_freq=-1">[format_frequency(frequency)] GHz</a> (<a href="?src=\ref[src];set_freq=[initial(frequency)]">Reset</a>)</li>
		<li>[format_tag("ID Tag","id_tag")]</li>
	</ul>"}

/obj/machinery/meter/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	if(istype(W, /obj/item/device/multitool))
		update_multitool_menu(user)
		return 1

	if (!istype(W, /obj/item/weapon/wrench))
		return ..()

	playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
	user << "\blue You begin to unfasten \the [src]..."
	if (do_after(user, 40))
		user.visible_message( \
			"[user] unfastens \the [src].", \
			"\blue You have unfastened \the [src].", \
			"You hear ratchet.")
		new /obj/item/pipe_meter(src.loc)
		del(src)

// TURF METER - REPORTS A TILE'S AIR CONTENTS

/obj/machinery/meter/turf/New()
	..()
	src.target = loc
	return 1


/obj/machinery/meter/turf/initialize()
	if (!target)
		src.target = loc

/obj/machinery/meter/turf/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	return