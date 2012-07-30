
/obj/machinery/computer/rust/gyrotron_controller
	name = "Gyrotron Remote Controller"
	icon_state = "power"
	var/updating = 1

	New()
		..()

	attack_ai(mob/user)
		attack_hand(user)

	attack_hand(mob/user)
		add_fingerprint(user)
		/*if(stat & (BROKEN|NOPOWER))
			return*/
		interact(user)

	/*updateDialog()
		for(var/mob/M in range(1))
			if(M.machine == src)
				interact(m)*/

	Topic(href, href_list)
		..()
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

	proc
		interact(mob/user)
			if ( (get_dist(src, user) > 1 ) || (stat & (BROKEN|NOPOWER)) )
				if (!istype(user, /mob/living/silicon))
					user.machine = null
					user << browse(null, "window=gyrotron_controller")
					return
			var/t = "<B>Gyrotron Remote Control Console</B><BR>"
			t += "<hr>"
			for(var/obj/machinery/rust/gyrotron/gyro in world)
				if(gyro.remoteenabled && gyro.on)
					t += "<font color=green>Gyrotron operational</font><br>"
					t += "Operational mode: <font color=blue>"
					if(gyro.emitting)
						t += "Emitting</font> <a href='?src=\ref[gyro];deactivate=1'>\[Deactivate\]</a><br>"
					else
						t += "Not emitting</font> <a href='?src=\ref[gyro];activate=1'>\[Activate\]</a><br>"
					t += "Emission rate: [gyro.rate] <a href='?src=\ref[gyro];modifyrate=1'>\[Modify\]</a><br>"
					t += "Beam frequency: [gyro.frequency] <a href='?src=\ref[gyro];modifyfreq=1'>\[Modify\]</a><br>"
					t += "Beam power: [gyro.mega_energy] <a href='?src=\ref[gyro];modifypower=1'>\[Modify\]</a><br>"
				else
					t += "<b><font color=red>Gyrotron unresponsive</font></b>"
				t += "<hr>"
			/*
			var/t = "<B>Reactor Core Fuel Control</B><BR>"
			t += "Current fuel injection stage: [active_stage]<br>"
			if(active_stage == "Cooling")
				//t += "<a href='?src=\ref[src];restart=1;'>Restart injection cycle</a><br>"
				t += "----<br>"
			else
				t += "<a href='?src=\ref[src];cooldown=1;'>Enter cooldown phase</a><br>"
			t += "Fuel depletion announcement: "
			t += "[announce_fueldepletion ? 		"<a href='?src=\ref[src];disable_fueldepletion=1'>Disable</a>" : "<b>Disabled</b>"] "
			t += "[announce_fueldepletion == 1 ? 	"<b>Announcing</b>" : "<a href='?src=\ref[src];announce_fueldepletion=1'>Announce</a>"] "
			t += "[announce_fueldepletion == 2 ? 	"<b>Broadcasting</b>" : "<a href='?src=\ref[src];broadcast_fueldepletion=1'>Broadcast</a>"]<br>"
			t += "Stage progression announcement: "
			t += "[announce_stageprogression ? 		"<a href='?src=\ref[src];disable_stageprogression=1'>Disable</a>" : "<b>Disabled</b>"] "
			t += "[announce_stageprogression == 1 ? 	"<b>Announcing</b>" : "<a href='?src=\ref[src];announce_stageprogression=1'>Announce</a>"] "
			t += "[announce_stageprogression == 2 ? 	"<b>Broadcasting</b>" : "<a href='?src=\ref[src];broadcast_stageprogression=1'>Broadcast</a>"] "
			t += "<hr>"
			t += "<table border=1><tr>"
			t += "<td><b>Injector Status</b></td>"
			t += "<td><b>Injection interval (sec)</b></td>"
			t += "<td><b>Assembly consumption per injection</b></td>"
			t += "<td><b>Fuel Assembly Port</b></td>"
			t += "<td><b>Assembly depletion percentage</b></td>"
			t += "</tr>"
			for(var/stage in fuel_injectors)
				var/list/cur_stage = fuel_injectors[stage]
				t += "<tr><td colspan=5><b>Fuel Injection Stage:</b> <font color=blue>[stage]</font> [active_stage == stage ? "<font color=green> (Currently active)</font>" : "<a href='?src=\ref[src];beginstage=[stage]'>Activate</a>"]</td></tr>"
				for(var/obj/machinery/rust/fuel_injector/Injector in cur_stage)
					t += "<tr>"
					t += "<td>[Injector.on && Injector.remote_enabled ? "<font color=green>Operational</font>" : "<font color=red>Unresponsive</font>"]</td>"
					t += "<td>[Injector.rate/10] <a href='?src=\ref[Injector];cyclerate=1'>Modify</a></td>"
					t += "<td>[Injector.fuel_usage*100]% <a href='?src=\ref[Injector];fuel_usage=1'>Modify</a></td>"
					t += "<td>[Injector.owned_assembly_port ? "[Injector.owned_assembly_port.cur_assembly ? "<font color=green>Loaded</font>": "<font color=blue>Empty</font>"]" : "<font color=red>Disconnected</font>" ]</td>"
					t += "<td>[Injector.owned_assembly_port && Injector.owned_assembly_port.cur_assembly ? "[Injector.owned_assembly_port.cur_assembly.amount_depleted*100]%" : ""]</td>"
					t += "</tr>"
			t += "</table>"
			*/
			t += "<A href='?src=\ref[src];close=1'>Close</A><BR>"
			user << browse(t, "window=gyrotron_controller;size=500x400")
			user.machine = src
