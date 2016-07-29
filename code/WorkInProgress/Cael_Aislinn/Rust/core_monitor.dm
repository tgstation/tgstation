/obj/machinery/computer/rust_core_monitor
	name = "R-UST Mk. 7 Tokamak Core Monitoring Computer"
	icon_state = "power"
	light_color = LIGHT_COLOR_YELLOW
	circuit = /obj/item/weapon/circuitboard/rust_core_monitor

	var/obj/machinery/power/rust_core/linked_core

/obj/machinery/computer/rust_core_monitor/attack_hand(var/mob/user)
	. =..()
	if(.)
		user.unset_machine()
		return

	interact(user)

/obj/machinery/computer/rust_core_monitor/attack_ai(var/mob/user)
	attack_hand(user)

/obj/machinery/computer/rust_core_monitor/interact(var/mob/user)
	if(linked_core)
		. = {"
			<b>Device ID tag:</b> [linked_core.id_tag]<br>
		"}
		if(!check_core_status())
			. += {"
			<b><span style='color: red'>ERROR: Device unresponsive</b><span>
			"}
		else
			var/power_color = (linked_core.avail() < linked_core.active_power_usage ? "orange" : "green")
			. += {"
			<b>Device power status: </b><span style='color: [power_color]'>[linked_core.avail()]/[linked_core.active_power_usage] W</span><br>
			<b>Device field status: </b><span style='color: [linked_core.owned_field ? "green" : "red"]'>[linked_core.owned_field ? "enabled" : "disabled"]</span><hr>
			<b>Field power density (W.m<sup>-3</sup>):</b> [linked_core.field_strength]<br>
			<b>Field frequency (MHz):</b> [linked_core.field_frequency]<br>
			"}
			if(linked_core.owned_field)
				. += {"
			<b>Approximate field diameter (m):</b> [linked_core.owned_field.size]<br>
			<b>Field mega energy:</b> [linked_core.owned_field.mega_energy]<br>
			<b>Field sub-mega energy:</b> [linked_core.owned_field.energy]<hr>
			<b>Field dormant reagents:</b><br>
			<table>
				<tr>
					<th><b>Name</b></th>
					<th><b>Amount</b></th>
				</tr>
				"}
				for(var/reagent in linked_core.owned_field.dormant_reactant_quantities)
					. += {"
				<tr>
					<td>[reagent]</td>
					<td>[linked_core.owned_field.dormant_reactant_quantities[reagent]]</td>
				</tr>
					"}
			. += {"
			</table>
			"}
	else
		. = {"
			<span style='color: red'><b>No linked R-UST Mk. 7 pattern Electromagnetic Field Generator</b></span>
		"}

	var/datum/browser/popup = new(user, "rust_core_monitor", name, 500, 400, src)
	popup.set_content(.)
	popup.open()
	user.set_machine(src)

//Returns 1 if the linked core is accesible.
/obj/machinery/computer/rust_core_monitor/proc/check_core_status()
	if(!istype(linked_core))
		return

	if(linked_core.stat & BROKEN)
		return

	if(linked_core.avail() < linked_core.idle_power_usage)
		return

	. = 1

//Multitool menu shit.
/obj/machinery/computer/rust_core_monitor/multitool_menu(var/mob/user, var/obj/item/device/multitool/P)
	if(linked_core)
		. = {"
			<b>Linked R-UST Mk. 7 pattern Electromagnetic Field Generator:<br>
			[linked_core.id_tag] <a href='?src=\ref[src];unlink=1'>\[X\]</a></b>
		"}
	else
		. = {"
			<b>No Linked R-UST Mk. 7 pattern Electromagnetic Field Generator</b>
		"}

/obj/machinery/computer/rust_core_monitor/linkMenu(var/obj/machinery/power/rust_core/O)
	if(istype(O))
		. = "<a href='?src=\ref[src];link=1'>\[LINK\]</a> "

/obj/machinery/computer/rust_core_monitor/canLink(var/obj/machinery/power/rust_core/O, var/list/context)
	if(istype(O) && !linked_core)
		. = 1

/obj/machinery/computer/rust_core_monitor/isLinkedWith(var/obj/machinery/power/rust_core/O)
	. = (linked_core == O)

/obj/machinery/computer/rust_core_monitor/linkWith(var/mob/user, var/obj/machinery/power/rust_core/O, var/list/context)
	linked_core = O
	. = 1

/obj/machinery/computer/rust_core_monitor/getLink(var/idx)
	. = linked_core

/obj/machinery/computer/rust_core_monitor/unlinkFrom(var/mob/user, var/obj/buffer)
	linked_core = null
	. = 1
