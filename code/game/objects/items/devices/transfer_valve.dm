/obj/item/transfer_valve
	icon = 'icons/obj/assemblies.dmi'
	lefthand_file = 'icons/mob/inhands/weapons/bombs_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/bombs_righthand.dmi'
	name = "Payload Device"
	icon_state = "valve"
	inhand_icon_state = "ttv"
	desc = "Injects a bomb payload with superheated Hyper-Noblium, containing enough energy to kickstart a tritium reaction."
	w_class = WEIGHT_CLASS_BULKY

	var/obj/item/tank/payload
	var/obj/item/tank/tank_one
	var/obj/item/tank/tank_two
	var/obj/item/assembly/attached_device
	var/datum/gas_mixture/thermonuclear
	var/mob/attacher = null
	var/range = FALSE
	var/failed = 0
	var/deltaW

/obj/item/transfer_valve/Initialize()
	. = ..()

	thermonuclear = new(100) //liters
	thermonuclear.temperature = T20C
	
	add_overlay("valve_hotmix")

/obj/item/transfer_valve/IsAssemblyHolder()
	return TRUE

/obj/item/transfer_valve/attackby(obj/item/item, mob/user, params)
	if(istype(item, /obj/item/tank))
		if(payload)
			to_chat(user, "<span class='warning'>There is a payload on the device!</span>")
			return
		else
			if(!user.transferItemToLoc(item, src))
				return
			payload = item
			to_chat(user, "<span class='notice'>You attach the tank to the bomb.</span>")

		update_icon()
		
	else if(isassembly(item))
		var/obj/item/assembly/A = item
		if(A.secured)
			to_chat(user, "<span class='notice'>The device is secured.</span>")
			return
		if(attached_device)
			to_chat(user, "<span class='warning'>There is already a device attached to the valve, remove it first!</span>")
			return
		if(!user.transferItemToLoc(item, src))
			return
		attached_device = A
		to_chat(user, "<span class='notice'>You attach the [item] to the valve controls and secure it.</span>")
		A.holder = src
		A.toggle_secure()	//this calls update_icon(), which calls update_icon() on the holder (i.e. the bomb).
		log_bomber(user, "attached a [item.name] to a ttv -", src, null, FALSE)
		attacher = user
	return

//These keep attached devices synced up, for example a TTV with a mouse trap being found in a bag so it's triggered, or moving the TTV with an infrared beam sensor to update the beam's direction.
/obj/item/transfer_valve/Move()
	. = ..()
	if(attached_device)
		attached_device.holder_movement()

/obj/item/transfer_valve/dropped()
	. = ..()
	if(attached_device)
		attached_device.dropped()

/obj/item/transfer_valve/on_found(mob/finder)
	if(attached_device)
		attached_device.on_found(finder)

/obj/item/transfer_valve/Crossed(atom/movable/AM as mob|obj)
	. = ..()
	if(attached_device)
		attached_device.Crossed(AM)

//Triggers mousetraps
/obj/item/transfer_valve/attack_hand()
	. = ..()
	if(.)
		return
	if(attached_device)
		attached_device.attack_hand()

/obj/item/transfer_valve/update_icon()
	cut_overlays()

	add_overlay("valve_hotmix")

	if(payload)
		var/mutable_appearance/J = mutable_appearance(icon, icon_state = "[payload.icon_state]")
		var/matrix/T = matrix()
		T.Translate(-13, 0)
		J.transform = T
		underlays = list(J)
	else
		underlays = null

	if(attached_device)
		add_overlay("device")
		if(istype(attached_device, /obj/item/assembly/infra))
			var/obj/item/assembly/infra/sensor = attached_device
			if(sensor.on && sensor.visible)
				add_overlay("proxy_beam")
/*

	Exadv1: I know this isn't how it's going to work, but this was just to check
	it explodes properly when it gets a signal (and it does).
*/
/obj/item/transfer_valve/proc/log_activation()
	var/turf/bombturf = get_turf(src)
	var/attachment
	var/attachment_signal_log
	var/admin_attachment_message
	var/attachment_message
	var/mob/bomber = get_mob_by_key(fingerprintslast)
	var/admin_bomber_message
	var/bomber_message
	
	if(attached_device)
		if(istype(attached_device, /obj/item/assembly/signaler))
			var/obj/item/assembly/signaler/attached_signaller = attached_device
			attachment = "<A HREF='?_src_=holder;[HrefToken()];secrets=list_signalers'>[attached_signaller]</A>"
			attachment_signal_log = attached_signaller.last_receive_signal_log ? "The following log entry is the last one associated with the attached signaller<br>[attached_signaller.last_receive_signal_log]" : "There is no signal log entry."
		else
			attachment = attached_device

	if(attachment)
		admin_attachment_message = "The bomb had [attachment], which was attached by [attacher ? ADMIN_LOOKUPFLW(attacher) : "Unknown"]"
		attachment_message = " with [attachment] attached by [attacher ? key_name_admin(attacher) : "Unknown"]"

	if(bomber)
		admin_bomber_message = "The bomb's most recent set of fingerprints indicate it was last touched by [ADMIN_LOOKUPFLW(bomber)]"
		bomber_message = " - Last touched by: [key_name_admin(bomber)]"

	var/admin_bomb_message = "Bomb valve opened in [ADMIN_VERBOSEJMP(bombturf)]<br>[admin_attachment_message]<br>[admin_bomber_message]<br>[attachment_signal_log]"
	GLOB.bombers += admin_bomb_message
	message_admins(admin_bomb_message)
	log_game("Bomb valve opened in [AREACOORD(bombturf)][attachment_message][bomber_message]")


/obj/item/transfer_valve/proc/merge_gases()
	var/datum/gas_mixture/payload_content = payload.air_contents
	var/old_energy = payload_content.temperature * payload_content.heat_capacity()
	var/injected_energy = 6e7 //0.03 moles of Hyper-Noblium at 1 million kelvins
	var/energy_after_reacting = 0
	
	if (!payload_content)
		return
	thermonuclear.merge(payload_content)

	ASSERT_GAS(/datum/gas/hypernoblium, thermonuclear)
	thermonuclear.gases[/datum/gas/hypernoblium][MOLES] += 0.03
	thermonuclear.temperature = (injected_energy + old_energy) / thermonuclear.heat_capacity()
	thermonuclear.react()
	energy_after_reacting = thermonuclear.temperature * thermonuclear.heat_capacity()
	deltaW = energy_after_reacting - (injected_energy + old_energy)

/obj/item/transfer_valve/proc/calculate_power() //Other dependencies now only have to call this proc and merge_gases to get the explosion range.
	if (deltaW > 1e5) //Only allows for explosions for differences in delta W. This is to prevent Hypernob abuse.
		var/range_update = deltaW / 1e5
		return range_update
	else
		return FALSE

/obj/item/transfer_valve/proc/handle_explosion()
	var/turf/epicenter = get_turf(loc)
	explosion(epicenter, round(range*0.25), round(range*0.5), round(range), round(range*1.5))
	qdel(src)

/obj/item/transfer_valve/proc/activate()
	if(!failed)
		log_activation()
		merge_gases()
		range = calculate_power()
	
		if (range)
			handle_explosion()
		else
			failed = TRUE

/obj/item/transfer_valve/proc/process_activation(obj/item/D)
	activate()

/obj/item/transfer_valve/ui_state(mob/user)
	return GLOB.hands_state

/obj/item/transfer_valve/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TransferValve", name)
		ui.open()

/obj/item/transfer_valve/ui_data(mob/user)
	var/list/data = list()
	data["payload"] = payload ? payload.name : null
	data["attached_device"] = attached_device ? attached_device.name : null
	data["failed"] = failed ? TRUE : null
	return data

/obj/item/transfer_valve/proc/ready()
	return (payload ? TRUE: FALSE)
	
/obj/item/transfer_valve/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("payload")
			if(payload)
				payload.forceMove(drop_location())
				payload = null
				. = TRUE
		if("toggle")
			activate()
			. = TRUE
		if("device")
			if(attached_device)
				attached_device.attack_self(usr)
				. = TRUE
		if("remove_device")
			if(attached_device)
				attached_device.on_detach()
				attached_device = null
				. = TRUE

	update_icon()

/obj/item/transfer_valve/helium_bomb
	name = "Generation V Payload Device"
	desc = "Cutting edge experimental weaponry, allowing for Helium-based thermonuclear reactions commonly seen in stars."

	var/equation_random
	var/random_multiplier_x
	var/random_multiplier_y

/obj/item/transfer_valve/helium_bomb/Initialize()
	. = ..()
	equation_random = pick("equation_1", "equation_2", "equation_3", "equation_4", "equation_5", "equation_6")
	random_multiplier_x = rand(-200,200) / 100
	random_multiplier_y = rand(-200,200) / 100

/obj/item/transfer_valve/helium_bomb/merge_gases()
	var/datum/gas_mixture/payload_content = payload.air_contents
	thermonuclear.merge(payload_content)
	thermonuclear.temperature = payload_content.temperature

	var/helium = thermonuclear.gases[/datum/gas/helium][MOLES]
	var/tritium = thermonuclear.gases[/datum/gas/tritium][MOLES]
	var/hydrogen = thermonuclear.gases[/datum/gas/hydrogen][MOLES]
	var/gas_to_graph_scale_factor = 1000
	var/helium_graph_amount = clamp(helium / gas_to_graph_scale_factor, 0, 6.28)
	var/tritium_graph_amount = clamp(tritium / gas_to_graph_scale_factor, 0, 6.28)
	var/hydrogen_graph_amount = clamp(hydrogen / gas_to_graph_scale_factor, 0, 6.28)
	var/hydrogen_and_isotopes = tritium + hydrogen
	var/constant = 0
	var/list/x_component = new
	var/list/x_component_helium = new
	var/list/y_component = new
	var/y_value = 0
	var/helium_helium_fuse_efficiency = 0
	var/fused_helium_amount = 0
	var/fused_hydrogen_helium_amount = 0
	var/fused_hydrogen_amount = 0
	
	if (helium > 10 && (hydrogen > 10 && tritium > 10))
		// HELIUM TO HELIUM FUSION EFFICIENCY CALCULATION
		x_component["equation_1"] = (1/2 * tritium_graph_amount) - (1 / (4 * random_multiplier_x) * sin(2 * tritium_graph_amount * random_multiplier_x)) // Integral of sin^2(kx)
		x_component["equation_2"] = (1/2 * tritium_graph_amount) - (1 / (2 * random_multiplier_x) * sin(2 * tritium_graph_amount * random_multiplier_x)) // Integral of cos^2(kx)
		x_component["equation_3"] = tritium_graph_amount // Integral of 1, sort of.
		x_component["equation_4"] = (1/2 * tritium_graph_amount) - (1 / (2 * random_multiplier_x) * sin(2 * tritium_graph_amount * random_multiplier_x)) // Integral of cos^2(kx)
		x_component["equation_5"] = tritium_graph_amount // Integral of 1, sort of.
		x_component["equation_6"] = (1/2 * tritium_graph_amount) - (1 / (4 * random_multiplier_x) * sin(2 * tritium_graph_amount * random_multiplier_x)) // Integral of sin^2(kx)

		x_component_helium["equation_1"] = (1/2 * helium_graph_amount) - (1 / (4 * random_multiplier_x) * sin(2 * helium_graph_amount * random_multiplier_x)) // Integral of sin^2(kx)
		x_component_helium["equation_2"] = (1/2 * helium_graph_amount) - (1 / (2 * random_multiplier_x) * sin(2 * helium_graph_amount * random_multiplier_x)) // Integral of cos^2(kx)
		x_component_helium["equation_3"] = helium_graph_amount // Integral of 1, sort of.
		x_component_helium["equation_4"] = (1/2 * helium_graph_amount) - (1 / (2 * random_multiplier_x) * sin(2 * helium_graph_amount * random_multiplier_x)) // Integral of cos^2(kx)
		x_component_helium["equation_5"] = helium_graph_amount // Integral of 1, sort of.
		x_component_helium["equation_6"] = (1/2 * helium_graph_amount) - (1 / (4 * random_multiplier_x) * sin(2 * helium_graph_amount * random_multiplier_x)) // Integral of sin^2(kx)

		y_component["equation_1"] = 1 / random_multiplier_y * tan(hydrogen_graph_amount * random_multiplier_y) // Integral of 1 / cos^2(ky)
		y_component["equation_2"] = -1 / random_multiplier_y * COT(hydrogen_graph_amount * random_multiplier_y) // Integral of 1 / sin^2(ky)
		y_component["equation_3"] = 1 / random_multiplier_y * tan(hydrogen_graph_amount * random_multiplier_y) // Integral of 1 / cos^2(ky)
		y_component["equation_4"] = hydrogen_graph_amount // Integral of 1, sort of.
		y_component["equation_5"] = -1 / random_multiplier_y * COT(hydrogen_graph_amount * random_multiplier_y) // Integral of 1 / sin^2(ky)
		y_component["equation_6"] = hydrogen_graph_amount // Integral of 1, sort of.

		constant = y_component[equation_random] - x_component[equation_random] // Calculate the special constant for the specific trit-h2 coordinate
		y_value = clamp(x_component_helium[equation_random] + constant, 0, 6.28) // Calculate the f(x) (y coord)

		helium_helium_fuse_efficiency = y_value + helium_graph_amount / 12.56 // Efficiency is f(x) + x for the graph. (x coord + y coord)
		message_admins(y_value)
		message_admins(helium_helium_fuse_efficiency)

		// AMOUNT CALCULATION
		fused_helium_amount = (helium_helium_fuse_efficiency * helium) / 2 //First rate, beautiful, very energetic reaction. 2 Helium fuses together. Optimal and what one should be striving for.
		fused_hydrogen_helium_amount = min(hydrogen_and_isotopes / 3, (helium - (fused_helium_amount * 2))) // Second rate, less energetic reaction. 3 Hydrogen + 1 Helium. If the hydrogen isnt enough to accomodate, some helium is left lying around. Woops!
		fused_hydrogen_amount = hydrogen_and_isotopes - (fused_hydrogen_helium_amount * 3) // Pretty much tritium/hydrogen burn. Only occurs if we dont have enough helium to be fused into by the hydrogen.

		// ENERGY CALCULATION
		deltaW += fused_helium_amount * 4e14 // 4e14 for two moles consumed. 2e14 per mol.
		deltaW += fused_hydrogen_helium_amount * 4e10 //4e13 for four moles consumed. 1e10 per mol.
		deltaW += fused_hydrogen_amount * FIRE_HYDROGEN_ENERGY_RELEASED //2.8e7 per mol. Regular tritfire bomb. Will not happen if we have enough helium in mix.

	else
		failed = TRUE
	