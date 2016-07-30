// Relays don't handle any actual communication. Global NTNet datum does that, relays only tell the datum if it should or shouldn't work.
/obj/machinery/ntnet_relay
	name = "NTNet Quantum Relay"
	desc = "A very complex router and transmitter capable of connecting electronic devices together. Looks fragile."
	use_power = 2
	active_power_usage = 20000 //20kW, apropriate for machine that keeps massive cross-Zlevel wireless network operational.
	idle_power_usage = 100
	icon_state = "bus"
	anchored = 1
	density = 1
	var/datum/ntnet/NTNet = null // This is mostly for backwards reference and to allow varedit modifications from ingame.
	var/enabled = 1				// Set to 0 if the relay was turned off
	var/dos_failure = 0			// Set to 1 if the relay failed due to (D)DoS attack
	var/list/dos_sources = list()	// Backwards reference for qdel() stuff

	// Denial of Service attack variables
	var/dos_overload = 0		// Amount of DoS "packets" in this relay's buffer
	var/dos_capacity = 500		// Amount of DoS "packets" in buffer required to crash the relay
	var/dos_dissipate = 1		// Amount of DoS "packets" dissipated over time.


// TODO: Implement more logic here. For now it's only a placeholder.
/obj/machinery/ntnet_relay/proc/is_operational()
	if(stat & (BROKEN | NOPOWER | EMPED))
		return 0
	if(dos_failure)
		return 0
	if(!enabled)
		return 0
	return 1

/obj/machinery/ntnet_relay/update_icon()
	if(is_operational())
		icon_state = "bus"
	else
		icon_state = "bus_off"

/obj/machinery/ntnet_relay/process()
	if(is_operational())
		use_power = 2
	else
		use_power = 1

	if(dos_overload)
		dos_overload = max(0, dos_overload - dos_dissipate)

	// If DoS traffic exceeded capacity, crash.
	if((dos_overload > dos_capacity) && !dos_failure)
		dos_failure = 1
		update_icon()
		ntnet_global.add_log("Quantum relay switched from normal operation mode to overload recovery mode.")
	// If the DoS buffer reaches 0 again, restart.
	if((dos_overload == 0) && dos_failure)
		dos_failure = 0
		update_icon()
		ntnet_global.add_log("Quantum relay switched from overload recovery mode to normal operation mode.")
	..()

/obj/machinery/ntnet_relay/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1, var/datum/topic_state/state = default_state)
	var/list/data = list()
	data["enabled"] = enabled
	data["dos_capacity"] = dos_capacity
	data["dos_overload"] = dos_overload
	data["dos_crashed"] = dos_failure

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "ntnet_relay.tmpl", "NTNet Quantum Relay", 500, 300, state = state)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/ntnet_relay/attack_hand(var/mob/living/user)
	ui_interact(user)

/obj/machinery/ntnet_relay/Topic(href, href_list)
	if(..())
		return 1
	if(href_list["restart"])
		dos_overload = 0
		dos_failure = 0
		update_icon()
		ntnet_global.add_log("Quantum relay manually restarted from overload recovery mode to normal operation mode.")
	else if(href_list["toggle"])
		enabled = !enabled
		ntnet_global.add_log("Quantum relay manually [enabled ? "enabled" : "disabled"].")
		update_icon()

/obj/machinery/ntnet_relay/New()
	uid = gl_uid
	gl_uid++
	component_parts = list()
	component_parts += new /obj/item/stack/cable_coil(src,15)
	component_parts += new /obj/item/weapon/circuitboard/ntnet_relay(src)

	if(ntnet_global)
		ntnet_global.relays.Add(src)
		NTNet = ntnet_global
		ntnet_global.add_log("New quantum relay activated. Current amount of linked relays: [NTNet.relays.len]")
	..()

/obj/machinery/ntnet_relay/Destroy()
	if(ntnet_global)
		ntnet_global.relays.Remove(src)
		ntnet_global.add_log("Quantum relay connection severed. Current amount of linked relays: [NTNet.relays.len]")
		NTNet = null
	for(var/datum/computer_file/program/ntnet_dos/D in dos_sources)
		D.target = null
		D.error = "Connection to quantum relay severed"
	..()

/obj/machinery/ntnet_relay/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	if(istype(W, /obj/item/weapon/screwdriver))
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
		panel_open = !panel_open
		user << "You [panel_open ? "open" : "close"] the maintenance hatch"
		return
	if(istype(W, /obj/item/weapon/crowbar))
		if(!panel_open)
			user << "Open the maintenance panel first."
			return
		playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
		user << "You disassemble \the [src]!"

		for(var/atom/movable/A in component_parts)
			A.forceMove(src.loc)
		new/obj/machinery/constructable_frame/machine_frame(src.loc)
		qdel(src)
		return
	..()