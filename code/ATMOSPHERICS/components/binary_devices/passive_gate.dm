obj/machinery/atmospherics/binary/passive_gate
	//Tries to achieve target pressure at output (like a normal pump) except
	//	Uses no power but can not transfer gases from a low pressure area to a high pressure area
	icon = 'passive_gate.dmi'
	icon_state = "intact_off"

	name = "Passive gate"
	desc = "A one-way air valve that does not require power"

	var/on = 0

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
		..()
		if(!on)
			return 0

		var/output_starting_pressure = air2.return_pressure()
		var/input_starting_pressure = air1.return_pressure()

		if(input_starting_pressure - output_starting_pressure < 1)
			//No need to pump gas if input pressure is too low
			//Need at least 1 KPa difference to overcome friction in the mechanism
			return 1

		//Calculate necessary moles to transfer using PV = nRT
		if((air1.total_moles() > 0) && (air1.temperature>0))
			var/pressure_delta = (input_starting_pressure - output_starting_pressure)/2
			//Can not have a pressure delta that would cause output_pressure > input_pressure

			var/transfer_moles = pressure_delta*air2.volume/(air1.temperature * R_IDEAL_GAS_EQUATION)

			//Actually transfer the gas
			var/datum/gas_mixture/removed = air1.remove(transfer_moles)
			air2.merge(removed)

			if(network1)
				network1.update = 1

			if(network2)
				network2.update = 1

	attack_ai(mob/user as mob)
		return src.attack_hand(user)

	attack_hand(mob/user as mob)
		src.on = !src.on
		src.update_icon()
		return