///BLUESPACE SCRUBBER
/obj/machinery/portable_atmospherics/scrubber/bluespace
	name = "portable bluespace scrubber"
	desc = "A portable variant of the station scrubbers, capable of filtering gas from the air around it or inserted tank. May also be linked with bluespace gas receivers."
	icon_state = "bluespace_scrubber"

	var/obj/machinery/portable_atmospherics/gas_receiver/target = null

/obj/machinery/portable_atmospherics/scrubber/bluespace/Destroy()
	set_teleport_target(null)
	return ..()

///Links scrubber with a bluespace gas receiver with multitool
/obj/machinery/portable_atmospherics/scrubber/bluespace/multitool_act(mob/living/user, obj/item/multitool/M)
	if(!istype(M.buffer, /obj/machinery/portable_atmospherics/gas_receiver))
		to_chat(user, span_warning("Invalid buffer."))
		return ITEM_INTERACT_BLOCKING

	set_teleport_target(M.buffer)

	to_chat(user, span_green("You successfully link [src] to the [M.buffer]."))
	return ITEM_INTERACT_SUCCESS

///Set a receiving gas object, cleaning up any previous link first.
/obj/machinery/portable_atmospherics/scrubber/bluespace/proc/set_teleport_target(obj/machinery/portable_atmospherics/gas_receiver/new_target)
	if(target)
		//Clear the old link (and its qdel signal) before we point somewhere new
		UnregisterSignal(target, COMSIG_QDELETING)
		target.unregister_sender(src)
	target = new_target
	if(target)
		//If our target is ever deleted, drop our reference to it
		RegisterSignal(target, COMSIG_QDELETING, PROC_REF(clear_teleport_target))
		target.register_sender(src)

///Signal handler for our target being deleted, clears our reference to it.
/obj/machinery/portable_atmospherics/scrubber/bluespace/proc/clear_teleport_target(datum/source)
	SIGNAL_HANDLER
	set_teleport_target(null)

///Transfer our scrubbed gas into the linked gas receiver's air
/obj/machinery/portable_atmospherics/scrubber/bluespace/proc/transfer_gas(datum/gas_mixture/receiver_air)
	if(receiver_air.return_pressure() >= overpressure_m * ONE_ATMOSPHERE)
		return

	var/list/cached_moles = air_contents.moles

	//contains all of the gas we're pulling out of our air_contents, gets merged into the receiver
	var/datum/gas_mixture/filtered_out = new

	filtered_out.temperature = air_contents.temperature

	//maximum percentage of our stored gas we can transfer
	var/removal_ratio = 1

	var/total_moles_to_remove = 0
	for(var/gas_id in cached_moles & scrubbing)
		total_moles_to_remove += cached_moles[gas_id]

	if(!total_moles_to_remove)//no gases to remove
		return FALSE

	for(var/gas_id in cached_moles & scrubbing)
		var/transferred_moles = max(QUANTIZE(cached_moles[gas_id] * removal_ratio * (cached_moles[gas_id] / total_moles_to_remove)), min(MOLAR_ACCURACY*1000, cached_moles[gas_id]))

		filtered_out.moles[gas_id] += transferred_moles
		cached_moles[gas_id] -= transferred_moles

	//Hand the filtered gases over to the receiver
	receiver_air.merge(filtered_out)

///GAS RECEIVER
/obj/machinery/portable_atmospherics/gas_receiver
	name = "Bluespace Gas Receiver"
	desc = "Receive gases from a bluespace portable scrubber."
	icon_state = "bluespace_gas_receiver"
	density = TRUE
	max_integrity = 250
	volume = 2000
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.5

	var/on = FALSE
	///All synced up bluespace scrubbers we can tap from
	var/list/senders = list()
	///We only grab one machine per process, so store which one is next
	var/next_index = 1

/obj/machinery/portable_atmospherics/gas_receiver/Destroy()
	lose_senders()
	return ..()

/obj/machinery/portable_atmospherics/gas_receiver/on_deconstruction(disassembled)
	var/turf/local_turf = get_turf(src)
	local_turf.assume_air(air_contents)
	return ..()

/obj/machinery/portable_atmospherics/gas_receiver/update_icon_state()
	icon_state = "[initial(icon_state)]_[on]"
	return ..()

///overlays for gas receiver
/obj/machinery/portable_atmospherics/gas_receiver/update_overlays()
	. = ..()
	if(holding)
		. += "siphon-open"
	if(connected_port)
		. += "siphon-connector"

/obj/machinery/portable_atmospherics/gas_receiver/multitool_act(mob/living/user, obj/item/multitool/M)
	M.set_buffer(src)
	balloon_alert(user, "saved to multitool buffer")
	return ITEM_INTERACT_SUCCESS

/obj/machinery/portable_atmospherics/gas_receiver/click_alt(mob/user)
	if(!is_operational)
		update_icon_state()
		return on

	on = !on
	update_icon_state()

	balloon_alert(user, "turned [on ? "on" : "off"]")
	investigate_log("was turned [on ? "on" : "off"] by [key_name(user)]", INVESTIGATE_ATMOS)
	return CLICK_ACTION_SUCCESS

/obj/machinery/portable_atmospherics/gas_receiver/process(seconds_per_tick)
	if(!is_operational)
		return

	if(!on)
		return

	if(senders.len)
		if(senders.len < next_index)
			next_index = 1

		var/obj/machinery/portable_atmospherics/scrubber/bluespace/S = senders[next_index]
		S.transfer_gas(air_contents)

		next_index++

		use_energy(active_power_usage * seconds_per_tick)

///Track a scrubber that has linked to us, listening for its deletion so we can drop it.
/obj/machinery/portable_atmospherics/gas_receiver/proc/register_sender(obj/machinery/portable_atmospherics/scrubber/bluespace/sender)
	if(sender in senders)
		return
	senders += sender
	RegisterSignal(sender, COMSIG_QDELETING, PROC_REF(unregister_sender))

///Stop tracking a scrubber, also fired as a signal handler when a sender is deleted.
/obj/machinery/portable_atmospherics/gas_receiver/proc/unregister_sender(datum/source)
	SIGNAL_HANDLER
	senders -= source
	UnregisterSignal(source, COMSIG_QDELETING)

///Notify all scrubbers to forget us
/obj/machinery/portable_atmospherics/gas_receiver/proc/lose_senders()
	//Copy the list since each scrubber removes itself from senders as we go
	for(var/obj/machinery/portable_atmospherics/scrubber/bluespace/S as anything in senders.Copy())
		S.set_teleport_target(null)

/// wirecutter makes it lose all its senders
/obj/machinery/portable_atmospherics/gas_receiver/wirecutter_act(mob/living/user, obj/item/I)
	lose_senders()
	to_chat(user, span_warning("All scrubbers has been disconnected from receiver."))
	return ITEM_INTERACT_SUCCESS
