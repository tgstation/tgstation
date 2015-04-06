
/obj/machinery/computer/rust_gyrotron_controller
	name = "Gyrotron Remote Controller"
	icon = 'code/WorkInProgress/Cael_Aislinn/Rust/rust.dmi'
	icon_state = "engine"
	var/updating = 1

	New()
		..()

	Topic(href, href_list)
		if(..()) return 1
		if( href_list["close"] )
			usr << browse(null, "window=gyrotron_controller")
			usr.machine = null
			return
		if( href_list["target"] )
			var/obj/machinery/rust/gyrotron/gyro = locate(href_list["target"])
			gyro.Topic(href, href_list)
			return

	process()
		..()
		if(updating)
			src.updateDialog()

	interact(mob/user)
		if ( (get_dist(src, user) > 1 ) || (stat & (BROKEN|NOPOWER)) )
			if (!istype(user, /mob/living/silicon))
				user.machine = null
				user << browse(null, "window=gyrotron_controller")
				return

		// AUTOFIXED BY fix_string_idiocy.py
		// C:\Users\Rob\Documents\Projects\vgstation13\code\WorkInProgress\Cael_Aislinn\Rust\gyrotron_controller.dm:33: var/t = "<B>Gyrotron Remote Control Console</B><BR>"
		var/t = {"<B>Gyrotron Remote Control Console</B><BR>
<hr>"}
		// END AUTOFIX
		for(var/obj/machinery/rust/gyrotron/gyro in world)
			if(gyro.remoteenabled && gyro.on)

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\WorkInProgress\Cael_Aislinn\Rust\gyrotron_controller.dm:37: t += "<font color=green>Gyrotron operational</font><br>"
				t += {"<font color=green>Gyrotron operational</font><br>
					Operational mode: <font color=blue>"}
				// END AUTOFIX
				if(gyro.emitting)
					t += "Emitting</font> <a href='?src=\ref[gyro];deactivate=1'>\[Deactivate\]</a><br>"
				else
					t += "Not emitting</font> <a href='?src=\ref[gyro];activate=1'>\[Activate\]</a><br>"

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\WorkInProgress\Cael_Aislinn\Rust\gyrotron_controller.dm:43: t += "Emission rate: [gyro.rate] <a href='?src=\ref[gyro];modifyrate=1'>\[Modify\]</a><br>"
				t += {"Emission rate: [gyro.rate] <a href='?src=\ref[gyro];modifyrate=1'>\[Modify\]</a><br>
					Beam frequency: [gyro.frequency] <a href='?src=\ref[gyro];modifyfreq=1'>\[Modify\]</a><br>
					Beam power: [gyro.mega_energy] <a href='?src=\ref[gyro];modifypower=1'>\[Modify\]</a><br>"}
				// END AUTOFIX
			else
				t += "<b><font color=red>Gyrotron unresponsive</font></b>"
			t += "<hr>"
		/*

		// AUTOFIXED BY fix_string_idiocy.py
		// C:\Users\Rob\Documents\Projects\vgstation13\code\WorkInProgress\Cael_Aislinn\Rust\gyrotron_controller.dm:58: var/t = "<B>Reactor Core Fuel Control</B><BR>"
		var/t = {"<B>Reactor Core Fuel Control</B><BR>
Current fuel injection stage: [active_stage]<br>"}
		// END AUTOFIX
		if(active_stage == "Cooling")
			//t += "<a href='?src=\ref[src];restart=1;'>Restart injection cycle</a><br>"
			t += "----<br>"
		else
			t += "<a href='?src=\ref[src];cooldown=1;'>Enter cooldown phase</a><br>"

		// AUTOFIXED BY fix_string_idiocy.py
		// C:\Users\Rob\Documents\Projects\vgstation13\code\WorkInProgress\Cael_Aislinn\Rust\gyrotron_controller.dm:57: t += "Fuel depletion announcement: "
		t += {"Fuel depletion announcement:
			[announce_fueldepletion ? 		"<a href='?src=\ref[src];disable_fueldepletion=1'>Disable</a>" : "<b>Disabled</b>"]
			[announce_fueldepletion == 1 ? 	"<b>Announcing</b>" : "<a href='?src=\ref[src];announce_fueldepletion=1'>Announce</a>"]
			[announce_fueldepletion == 2 ? 	"<b>Broadcasting</b>" : "<a href='?src=\ref[src];broadcast_fueldepletion=1'>Broadcast</a>"]<br>
			Stage progression announcement:
			[announce_stageprogression ? 		"<a href='?src=\ref[src];disable_stageprogression=1'>Disable</a>" : "<b>Disabled</b>"]
			[announce_stageprogression == 1 ? 	"<b>Announcing</b>" : "<a href='?src=\ref[src];announce_stageprogression=1'>Announce</a>"]
			[announce_stageprogression == 2 ? 	"<b>Broadcasting</b>" : "<a href='?src=\ref[src];broadcast_stageprogression=1'>Broadcast</a>"]
			<hr>
			<table border=1><tr>
			<td><b>Injector Status</b></td>
			<td><b>Injection interval (sec)</b></td>
			<td><b>Assembly consumption per injection</b></td>
			<td><b>Fuel Assembly Port</b></td>
			<td><b>Assembly depletion percentage</b></td>
			</tr>"}
		// END AUTOFIX
		for(var/stage in fuel_injectors)
			var/list/cur_stage = fuel_injectors[stage]
			t += "<tr><td colspan=5><b>Fuel Injection Stage:</b> <font color=blue>[stage]</font> [active_stage == stage ? "<font color=green> (Currently active)</font>" : "<a href='?src=\ref[src];beginstage=[stage]'>Activate</a>"]</td></tr>"
			for(var/obj/machinery/rust/fuel_injector/Injector in cur_stage)

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\WorkInProgress\Cael_Aislinn\Rust\gyrotron_controller.dm:77: t += "<tr>"
				t += {"<tr>
					<td>[Injector.on && Injector.remote_enabled ? "<font color=green>Operational</font>" : "<font color=red>Unresponsive</font>"]</td>
					<td>[Injector.rate/10] <a href='?src=\ref[Injector];cyclerate=1'>Modify</a></td>
					<td>[Injector.fuel_usage*100]% <a href='?src=\ref[Injector];fuel_usage=1'>Modify</a></td>
					<td>[Injector.owned_assembly_port ? "[Injector.owned_assembly_port.cur_assembly ? "<font color=green>Loaded</font>": "<font color=blue>Empty</font>"]" : "<font color=red>Disconnected</font>" ]</td>
					<td>[Injector.owned_assembly_port && Injector.owned_assembly_port.cur_assembly ? "[Injector.owned_assembly_port.cur_assembly.amount_depleted*100]%" : ""]</td>
					</tr>"}
				// END AUTOFIX
		t += "</table>"
		*/
		t += "<A href='?src=\ref[src];close=1'>Close</A><BR>"
		user << browse(t, "window=gyrotron_controller;size=500x400")
		user.machine = src
