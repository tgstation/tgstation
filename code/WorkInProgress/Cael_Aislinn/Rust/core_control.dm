
/obj/machinery/computer/rust_core_control
	name = "R-UST Mk. 7 Core Control"
	icon = 'code/WorkInProgress/Cael_Aislinn/Rust/rust.dmi'
	icon_state = "core_control"
	light_color = LIGHT_COLOR_ORANGE
	var/list/connected_devices = list()
	var/scan_range = 25

	//currently viewed
	var/obj/machinery/power/rust_core/cur_viewed_device

/obj/machinery/computer/rust_core_control/attack_ai(mob/user)
	attack_hand(user)

/obj/machinery/computer/rust_core_control/attack_hand(mob/user)
	. = ..()
	if(.)
		if(user.machine == src)
			user.unset_machine(src)
		return

	interact(user)

/obj/machinery/computer/rust_core_control/interact(mob/user)
	var/dat = ""

	if(!cur_viewed_device || !check_core_status(cur_viewed_device))
		cur_viewed_device = null

	if(cur_viewed_device)
		dat += {"
			<a href='?src=\ref[src];goto_scanlist=1'>Back to overview</a><hr>
			<b>Device tag:</b> [cur_viewed_device.id_tag]<br>
			<span style='color: [cur_viewed_device.owned_field ? "green" : "red"]'>Device [cur_viewed_device.owned_field ? "activated" : "deactivated"].</span><br>
			<a href='?src=\ref[src];toggle_active=1'>Bring field [cur_viewed_device.owned_field ? "offline" : "online"]</a><br>
			<hr>

			<b>Field encumbrance:</b> [cur_viewed_device.owned_field ? 0 : "N/A"]<br>
			<b>Field power density (W.m<sup>-3</sup>):</b><br>
			<a href='?src=\ref[src];str=-1000'>----</a>
			<a href='?src=\ref[src];str=-100'>--- </a>
			<a href='?src=\ref[src];str=-10'>--  </a>
			<a href='?src=\ref[src];str=-1'>-   </a>
			<a href='?src=\ref[src];str=0'>[cur_viewed_device.field_strength]</a>
			<a href='?src=\ref[src];str=1'>+   </a>
			<a href='?src=\ref[src];str=10'>++  </a>
			<a href='?src=\ref[src];str=100'>+++ </a>
			<a href='?src=\ref[src];str=1000'>++++</a><hr>
		"}

		dat += {"
			<b>Field frequency (MHz):</b><br>
			<a href='?src=\ref[src];freq=-1000'>----</a>
			<a href='?src=\ref[src];freq=-100'>--- </a>
			<a href='?src=\ref[src];freq=-10'>--  </a>
			<a href='?src=\ref[src];freq=-1'>-   </a>
			<a href='?src=\ref[src];freq=0'>[cur_viewed_device.field_frequency]</a>
			<a href='?src=\ref[src];freq=1'>+   </a>
			<a href='?src=\ref[src];freq=10'>++  </a>
			<a href='?src=\ref[src];freq=100'>+++ </a>
			<a href='?src=\ref[src];freq=1000'>++++</a><br>
			<hr>
		"}

	else
		if(connected_devices.len)
			dat += {"
				<b>Connected R-UST Mk. 7 Tokamak pattern Electromagnetic Field Generators:</b><hr>
				<table>
					<tr>
						<th><b>Device tag</b></th>
						<th><b>Status</b></th>
						<th><b>Controls</b></th>
					</tr>
			"}

			for(var/obj/machinery/power/rust_core/C in connected_devices)
				var/status
				var/can_access = 1
				if(!check_core_status(C))
					status = "<span style='color: red'>Unresponsive</span>"
					can_access = 0
				else if(C.avail() < C.active_power_usage)
					status = "<span style='color: orange'>Underpowered</span>"
				else
					status = "<span style='color: green'>Good</span>"

				dat += {"
					<tr>
						<td>[C.id_tag]</td>
						<td>[status]</td>
				"}

				if(!can_access)
					dat += {"
						<td><span style='color: red'>ERROR</span></td>
					"}
				else
					dat += {"
						<td><a href=?src=\ref[src];access_device=[connected_devices.Find(C)]'>ACCESS</a></td>
					"}
				dat += {"
					</tr>
				"}

		else
			dat += "<span style='color: red'>No R-UST Mk. 7 Tokamak pattern Electromagnetic Field Generators connected.</span>"

	var/datum/browser/popup = new(user, "rust_control", name, 500, 400, src)
	popup.set_content(dat)
	popup.open()
	user.set_machine(src)

/obj/machinery/computer/rust_core_control/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["access_device"])
		var/idx = Clamp(text2num(href_list["toggle_active"]), 1, connected_devices.len)
		cur_viewed_device = connected_devices[idx]
		updateUsrDialog()
		return 1

	if(!cur_viewed_device || !check_core_status(cur_viewed_device)) //All HREFs from this point on require a device anyways.
		return

	if(href_list["goto_scanlist"])
		cur_viewed_device = null
		updateUsrDialog()
		return 1

	if(href_list["toggle_active"])
		if(!cur_viewed_device.Startup()) //Startup() whilst the device is active will return null.
			cur_viewed_device.Shutdown()
		updateUsrDialog()
		return 1

	if(href_list["str"])
		var/val = text2num(href_list["str"])
		if(!val) //Value is 0, which is manual entering.
			cur_viewed_device.set_strength(input("Enter the new field power density (W.m^-3)", "R-UST Mk. 7 Tokamak Controls", cur_viewed_device.field_strength) as num)
		else
			cur_viewed_device.set_strength(cur_viewed_device.field_strength + val)
		updateUsrDialog()
		return 1

	if(href_list["freq"])
		var/val = text2num(href_list["freq"])
		if(!val) //Value is 0, which is manual entering.
			cur_viewed_device.set_frequency(input("Enter the new field frequency (MHz)", "R-UST Mk. 7 Tokamak Controls", cur_viewed_device.field_frequency) as num)
		else
			cur_viewed_device.set_frequency(cur_viewed_device.field_frequency + val)
		updateUsrDialog()
		return 1


//Returns 1 if the machine can be interacted with via this console.
/obj/machinery/computer/rust_core_control/proc/check_core_status(var/obj/machinery/power/rust_core/C)
	if(isnull(C))
		return

	if(C.stat & BROKEN)
		return

	if(C.state != 2)
		return

	if(C.idle_power_usage > C.avail())
		return

	. = 1

//Multitool menu shit starts here.
//It's all . because . is faster than return, thanks BYOND.
/obj/machinery/computer/rust_core_control/multitool_menu(var/mob/user, var/obj/item/device/multitool/P)
	. = "Linked R-UST Tokamak cores:<br><lu>"

	for(var/obj/machinery/power/rust_core/C in connected_devices)
		. += "<li><b>[C.id_tag]</b> <a href='?src=\ref[src];unlink=[connected_devices.Find(C)]'>\[X\]</a></li>"
	. += "</ul>"

/obj/machinery/computer/rust_core_control/linkMenu(var/obj/machinery/power/rust_core/O)
	if(istype(O))
		. = "<a href='?src=\ref[src];link=1'>\[LINK\]</a> "

/obj/machinery/computer/rust_core_control/canLink(var/obj/machinery/power/rust_core/O, var/list/context)
	. = (istype(O) && get_dist(src, O) < scan_range)

/obj/machinery/computer/rust_core_control/isLinkedWith(var/obj/O)
	. = (O in connected_devices)

/obj/machinery/computer/rust_core_control/linkWith(var/mob/user, var/obj/machinery/power/rust_core/O, var/list/context)
	connected_devices += O
	. = 1

/obj/machinery/computer/rust_core_control/getLink(var/idx)
	if(idx <= connected_devices.len)
		. = connected_devices[idx]

/obj/machinery/computer/rust_core_control/unlinkFrom(var/mob/user, var/obj/buffer)
	connected_devices -= buffer
	. = 1
