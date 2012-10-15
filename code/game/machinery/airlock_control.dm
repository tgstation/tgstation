#define AIRLOCK_CONTROL_RANGE 5

// This code allows for airlocks to be controlled externally by setting an id_tag and comm frequency (disables ID access)
obj/machinery/door/airlock
	var/id_tag
	var/frequency
	var/shockedby = list()
	var/datum/radio_frequency/radio_connection
	explosion_resistance = 15

	receive_signal(datum/signal/signal)
		if(!signal || signal.encryption) return

		if(id_tag != signal.data["tag"] || !signal.data["command"]) return

		switch(signal.data["command"])
			if("open")
				spawn open(1)

			if("close")
				spawn close(1)

			if("unlock")
				locked = 0
				update_icon()

			if("lock")
				locked = 1
				update_icon()

			if("secure_open")
				spawn
					locked = 0
					update_icon()

					sleep(2)
					open(1)

					locked = 1
					update_icon()

			if("secure_close")
				spawn
					locked = 0
					close(1)

					locked = 1
					sleep(2)
					update_icon()

		send_status()

	proc/send_status()
		if(radio_connection)
			var/datum/signal/signal = new
			signal.transmission_method = 1 //radio signal
			signal.data["tag"] = id_tag
			signal.data["timestamp"] = world.time

			signal.data["door_status"] = density?("closed"):("open")
			signal.data["lock_status"] = locked?("locked"):("unlocked")

			radio_connection.post_signal(src, signal, range = AIRLOCK_CONTROL_RANGE, filter = RADIO_AIRLOCK)

	open(surpress_send)
		. = ..()
		if(!surpress_send) send_status()

	close(surpress_send)
		. = ..()
		if(!surpress_send) send_status()

	proc/set_frequency(new_frequency)
		radio_controller.remove_object(src, frequency)
		if(new_frequency)
			frequency = new_frequency
			radio_connection = radio_controller.add_object(src, frequency, RADIO_AIRLOCK)

	initialize()
		if(frequency)
			set_frequency(frequency)

		update_icon()

	New()
		..()

		if(radio_controller)
			set_frequency(frequency)

obj/machinery/airlock_sensor
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "airlock_sensor_off"
	name = "Airlock Sensor"

	anchored = 1
	power_channel = ENVIRON

	var/id_tag
	var/master_tag
	var/frequency = 1449

	var/datum/radio_frequency/radio_connection

	var/on = 1
	var/alert = 0

	update_icon()
		if(on)
			if(alert)
				icon_state = "airlock_sensor_alert"
			else
				icon_state = "airlock_sensor_standby"
		else
			icon_state = "airlock_sensor_off"

	attack_hand(mob/user)
		var/datum/signal/signal = new
		signal.transmission_method = 1 //radio signal
		signal.data["tag"] = master_tag
		signal.data["command"] = "cycle"

		radio_connection.post_signal(src, signal, range = AIRLOCK_CONTROL_RANGE, filter = RADIO_AIRLOCK)
		flick("airlock_sensor_cycle", src)

	process()
		if(on)
			var/datum/signal/signal = new
			signal.transmission_method = 1 //radio signal
			signal.data["tag"] = id_tag
			signal.data["timestamp"] = world.time

			var/datum/gas_mixture/air_sample = return_air()

			var/pressure = round(air_sample.return_pressure(),0.1)
			alert = (pressure < ONE_ATMOSPHERE*0.8)

			signal.data["pressure"] = num2text(pressure)

			radio_connection.post_signal(src, signal, range = AIRLOCK_CONTROL_RANGE, filter = RADIO_AIRLOCK)

		update_icon()

	proc/set_frequency(new_frequency)
		radio_controller.remove_object(src, frequency)
		frequency = new_frequency
		radio_connection = radio_controller.add_object(src, frequency, RADIO_AIRLOCK)

	initialize()
		set_frequency(frequency)

	New()
		..()

		if(radio_controller)
			set_frequency(frequency)

obj/machinery/access_button
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "access_button_standby"
	name = "Access Button"

	anchored = 1
	power_channel = ENVIRON

	var/master_tag
	var/frequency = 1449
	var/command = "cycle"

	var/datum/radio_frequency/radio_connection

	var/on = 1

	update_icon()
		if(on)
			icon_state = "access_button_standby"
		else
			icon_state = "access_button_off"

	attack_hand(mob/user)
		src.add_fingerprint(usr)
		if(!allowed(user))
			user << "\red Access Denied"

		else if(radio_connection)
			var/datum/signal/signal = new
			signal.transmission_method = 1 //radio signal
			signal.data["tag"] = master_tag
			signal.data["command"] = command

			radio_connection.post_signal(src, signal, range = AIRLOCK_CONTROL_RANGE, filter = RADIO_AIRLOCK)
		flick("access_button_cycle", src)

	proc
		set_frequency(new_frequency)
			radio_controller.remove_object(src, frequency)
			frequency = new_frequency
			radio_connection = radio_controller.add_object(src, frequency, RADIO_AIRLOCK)

	initialize()
		set_frequency(frequency)

	New()
		..()

		if(radio_controller)
			set_frequency(frequency)
