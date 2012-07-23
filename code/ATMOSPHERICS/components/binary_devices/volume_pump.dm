/*
Every cycle, the pump uses the air in air_in to try and make air_out the perfect pressure.

node1, air1, network1 correspond to input
node2, air2, network2 correspond to output

Thus, the two variables affect pump operation are set in New():
	air1.volume
		This is the volume of gas available to the pump that may be transfered to the output
	air2.volume
		Higher quantities of this cause more air to be perfected later
			but overall network volume is also increased as this increases...
*/

obj/machinery/atmospherics/binary/volume_pump
	icon = 'icons/obj/atmospherics/volume_pump.dmi'
	icon_state = "intact_off"

	name = "Gas pump"
	desc = "A pump"

	var/on = 0
	var/transfer_rate = 200

	var/frequency = 0
	var/id = null
	var/datum/radio_frequency/radio_connection

	update_icon()
		if(node1&&node2)
			icon_state = "intact_[on?("on"):("off")]"
		else
			if(node1)
				icon_state = "exposed_1_off"
			else if(node2)
				icon_state = "exposed_2_off"
			else
				icon_state = "exposed_3_off"
			on = 0

		return

	process()
//		..()
		if(!on)
			return 0

		var/transfer_ratio = max(1, transfer_rate/air1.volume)

		var/datum/gas_mixture/removed = air1.remove_ratio(transfer_ratio)

		air2.merge(removed)

		if(network1)
			network1.update = 1

		if(network2)
			network2.update = 1

		return 1

	proc
		set_frequency(new_frequency)
			radio_controller.remove_object(src, frequency)
			frequency = new_frequency
			if(frequency)
				radio_connection = radio_controller.add_object(src, frequency)

		broadcast_status()
			if(!radio_connection)
				return 0

			var/datum/signal/signal = new
			signal.transmission_method = 1 //radio signal
			signal.source = src

			signal.data = list(
				"tag" = id,
				"device" = "APV",
				"power" = on,
				"transfer_rate" = transfer_rate,
				"sigtype" = "status"
			)
			radio_connection.post_signal(src, signal)

			return 1

	initialize()
		..()

		set_frequency(frequency)

	receive_signal(datum/signal/signal)
		if(!signal.data["tag"] || (signal.data["tag"] != id) || (signal.data["sigtype"]!="command"))
			return 0

		if("power" in signal.data)
			on = text2num(signal.data["power"])

		if("power_toggle" in signal.data)
			on = !on

		if("set_transfer_rate" in signal.data)
			transfer_rate = between(
				0,
				text2num(signal.data["set_transfer_rate"]),
				air1.volume
			)

		if("status" in signal.data)
			spawn(2)
				broadcast_status()
			return //do not update_icon

		spawn(2)
			broadcast_status()
		update_icon()