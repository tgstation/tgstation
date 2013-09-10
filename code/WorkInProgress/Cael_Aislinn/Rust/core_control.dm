
/obj/machinery/computer/rust_core_control
	name = "RUST Core Control"
	icon = 'code/WorkInProgress/Cael_Aislinn/Rust/rust.dmi'
	icon_state = "core_control"
	var/list/connected_devices = list()
	var/id_tag = "allan remember to update this before you leave"
	var/scan_range = 25

	//currently viewed
	var/obj/machinery/power/rust_core/cur_viewed_device

/obj/machinery/computer/rust_core_control/process()
	if(stat & (BROKEN|NOPOWER))
		return

/obj/machinery/computer/rust_core_control/attack_ai(mob/user)
	attack_hand(user)

/obj/machinery/computer/rust_core_control/attack_hand(mob/user)
	add_fingerprint(user)
	interact(user)

/obj/machinery/computer/rust_core_control/interact(mob/user)
	if(stat & BROKEN)
		user.unset_machine()
		user << browse(null, "window=core_control")
		return
	if (!istype(user, /mob/living/silicon) && (get_dist(src, user) > 1 ))
		user.unset_machine()
		user << browse(null, "window=core_control")
		return

	var/dat = ""
	if(stat & NOPOWER)
		dat += "<i>The console is dark and nonresponsive.</i>"
	else
		dat += "<B>Reactor Core Primary Monitor</B><BR>"
		if(cur_viewed_device && cur_viewed_device.stat & (BROKEN|NOPOWER))
			cur_viewed_device = null
		if(cur_viewed_device && !cur_viewed_device.remote_access_enabled)
			cur_viewed_device = null

		if(cur_viewed_device)

			// AUTOFIXED BY fix_string_idiocy.py
			// C:\Users\Rob\Documents\Projects\vgstation13\code\WorkInProgress\Cael_Aislinn\Rust\core_control.dm:45: dat += "<b>Device tag:</b> [cur_viewed_device.id_tag ? cur_viewed_device.id_tag : "UNSET"]<br>"
			dat += {"<b>Device tag:</b> [cur_viewed_device.id_tag ? cur_viewed_device.id_tag : "UNSET"]<br>
				<font color=blue>Device [cur_viewed_device.owned_field ? "activated" : "deactivated"].</font><br>
				<a href='?src=\ref[cur_viewed_device];extern_update=\ref[src];toggle_active=1'>\[Bring field [cur_viewed_device.owned_field ? "offline" : "online"]\]</a><br>
				<b>Device [cur_viewed_device.anchored ? "secured" : "unsecured"].</b><br>
				<hr>
				<b>Field encumbrance:</b> [cur_viewed_device.owned_field ? 0 : "NA"]<br>
				<b>Field strength:</b> [cur_viewed_device.field_strength] Wm^3<br>
				<a href='?src=\ref[cur_viewed_device];extern_update=\ref[src];str=-1000'>\[----\]</a>
			<a href='?src=\ref[cur_viewed_device];extern_update=\ref[src];str=-100'>\[--- \]</a>
			<a href='?src=\ref[cur_viewed_device];extern_update=\ref[src];str=-10'>\[--  \]</a>
			<a href='?src=\ref[cur_viewed_device];extern_update=\ref[src];str=-1'>\[-   \]</a>
			<a href='?src=\ref[cur_viewed_device];extern_update=\ref[src];str=1'>\[+   \]</a>
			<a href='?src=\ref[cur_viewed_device];extern_update=\ref[src];str=10'>\[++  \]</a>
			<a href='?src=\ref[cur_viewed_device];extern_update=\ref[src];str=100'>\[+++ \]</a>
			<a href='?src=\ref[cur_viewed_device];extern_update=\ref[src];str=1000'>\[++++\]</a><br>"}
			// END AUTOFIX

			// AUTOFIXED BY fix_string_idiocy.py
			// C:\Users\Rob\Documents\Projects\vgstation13\code\WorkInProgress\Cael_Aislinn\Rust\core_control.dm:60: dat += "<b>Field frequency:</b> [cur_viewed_device.field_frequency] MHz<br>"
			dat += {"<b>Field frequency:</b> [cur_viewed_device.field_frequency] MHz<br>
				<a href='?src=\ref[cur_viewed_device];extern_update=\ref[src];freq=-1000'>\[----\]</a>
			<a href='?src=\ref[cur_viewed_device];extern_update=\ref[src];freq=-100'>\[--- \]</a>
			<a href='?src=\ref[cur_viewed_device];extern_update=\ref[src];freq=-10'>\[--  \]</a>
			<a href='?src=\ref[cur_viewed_device];extern_update=\ref[src];freq=-1'>\[-   \]</a>
			<a href='?src=\ref[cur_viewed_device];extern_update=\ref[src];freq=1'>\[+   \]</a>
			<a href='?src=\ref[cur_viewed_device];extern_update=\ref[src];freq=10'>\[++  \]</a>
			<a href='?src=\ref[cur_viewed_device];extern_update=\ref[src];freq=100'>\[+++ \]</a>
			<a href='?src=\ref[cur_viewed_device];extern_update=\ref[src];freq=1000'>\[++++\]</a><br>"}
			// END AUTOFIX

			var/power_stat = "Good"
			if(cur_viewed_device.cached_power_avail < cur_viewed_device.active_power_usage)
				power_stat = "Insufficient"
			else if(cur_viewed_device.cached_power_avail < cur_viewed_device.active_power_usage * 2)
				power_stat = "Check"
			dat += "<b>Power status:</b> [power_stat]<br>"
		else
			dat += "<a href='?src=\ref[src];scan=1'>\[Refresh device list\]</a><br><br>"
			if(connected_devices.len)

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\WorkInProgress\Cael_Aislinn\Rust\core_control.dm:79: dat += "<table width='100%' border=1>"
				dat += {"<table width='100%' border=1>
					<tr>
					<td><b>Device tag</b></td>
					<td></td>
					</tr>"}
				// END AUTOFIX
				for(var/obj/machinery/power/rust_core/C in connected_devices)
					if(!check_core_status(C))
						connected_devices.Remove(C)
						continue


					// AUTOFIXED BY fix_string_idiocy.py
					// C:\Users\Rob\Documents\Projects\vgstation13\code\WorkInProgress\Cael_Aislinn\Rust\core_control.dm:89: dat += "<tr>"
					dat += {"<tr>
						<td>[C.id_tag]</td>
						<td><a href='?src=\ref[src];manage_individual=\ref[C]'>\[Manage\]</a></td>
						</tr>
						</table>"}
					// END AUTOFIX
			else
				dat += "No devices connected.<br>"


		// AUTOFIXED BY fix_string_idiocy.py
		// C:\Users\Rob\Documents\Projects\vgstation13\code\WorkInProgress\Cael_Aislinn\Rust\core_control.dm:97: dat += "<hr>"
		dat += {"<hr>
			<a href='?src=\ref[src];refresh=1'>Refresh</a>
			<a href='?src=\ref[src];close=1'>Close</a>"}
		// END AUTOFIX
	user << browse(dat, "window=core_control;size=500x400")
	onclose(user, "core_control")
	user.set_machine(src)

/obj/machinery/computer/rust_core_control/Topic(href, href_list)
	..()

	if( href_list["goto_scanlist"] )
		cur_viewed_device = null

	if( href_list["manage_individual"] )
		cur_viewed_device = locate(href_list["manage_individual"])

	if( href_list["scan"] )
		connected_devices = list()
		for(var/obj/machinery/power/rust_core/C in range(scan_range, src))
			if(check_core_status(C))
				connected_devices.Add(C)

	if( href_list["startup"] )
		if(cur_viewed_device)
			cur_viewed_device.Startup()

	if( href_list["shutdown"] )
		if(cur_viewed_device)
			cur_viewed_device.Shutdown()

	if( href_list["close"] )
		usr << browse(null, "window=core_control")
		usr.unset_machine()

	updateDialog()

/obj/machinery/computer/rust_core_control/proc/check_core_status(var/obj/machinery/power/rust_core/C)
	if(!C)
		return 0

	if(C.stat & (BROKEN|NOPOWER) || !C.remote_access_enabled || !C.id_tag)
		if(connected_devices.Find(C))
			connected_devices.Remove(C)
		return 0

	return 1
