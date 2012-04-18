
/obj/machinery/computer/rust/radiation_monitor
	name = "Core Radiation Monitor"

/obj/machinery/computer/rust/energy_monitor
	name = "Core Primary Monitor"
	icon_state = "power"
	var/obj/machinery/rust/core/core_generator = null

	New()
		spawn(0)
			core_generator = locate() in range(15,src)

	attack_ai(mob/user)
		attack_hand(user)

	attack_hand(mob/user)
		add_fingerprint(user)
		if(stat & (BROKEN|NOPOWER))
			return
		interact(user)

	Topic(href, href_list)
		..()
		if( href_list["shutdown"] )
			core_generator.Topic(href, href_list)
			updateDialog()
			return
		if( href_list["startup"] )
			core_generator.Topic(href, href_list)
			updateDialog()
			return
		if( href_list["modify_field_strength"] )
			core_generator.Topic(href, href_list)
			updateDialog()
			return
		if( href_list["close"] )
			usr << browse(null, "window=core_monitor")
			usr.machine = null
			return

	process()
		..()
		updateDialog()

	proc
		interact(mob/user)
			if ( (get_dist(src, user) > 1 ) || (stat & (BROKEN|NOPOWER)) )
				if (!istype(user, /mob/living/silicon))
					user.machine = null
					user << browse(null, "window=core_monitor")
					return
			var/t = "<B>Reactor Core Primary Monitor</B><BR>"
			if(core_generator)
				t += "<font color=blue>[core_generator.on ? "Core Generator connected" : "Core Generator operational"]</font><br>"
				if(core_generator.owned_field)
					t += "<font color=green>Core suspension field online</font> <a href='?src=\ref[src];shutdown=1'>\[Bring field offline\]</a><br>"
					t += "Electromagnetic plasma suspension field status:<br>"
					t += "	<font color=blue>Strength (T): [core_generator.owned_field.field_strength]</font> <a href='?src=\ref[src];modify_field_strength=1'>\[Modify\]</a><br>"
					t += "	<font color=blue>Energy levels (MeV): [core_generator.owned_field.mega_energy]</font><br>"
					t += "	<font color=blue>Core frequency: [core_generator.owned_field.frequency]</font><br>"
					t += "	<font color=blue>Moles of plasma: [core_generator.owned_field.held_plasma.toxins]</font><br>"
					t += "	<font color=blue>Plasma temperature: [core_generator.owned_field.held_plasma.temperature]</font><br>"
					t += "<hr>"
					t += "<b>Core atomic and subatomic constituents:</font></b><br>"
					if(core_generator.owned_field.dormant_reactant_quantities && core_generator.owned_field.dormant_reactant_quantities.len)
						for(var/reagent in core_generator.owned_field.dormant_reactant_quantities)
							t += "	<font color=green>[reagent]:</font> [core_generator.owned_field.dormant_reactant_quantities[reagent]]<br>"
					else
						t += "	<font color=blue>No reactants present.</font><br>"
				else
					t += "<font color=red>Core suspension field offline</font> <a href='?src=\ref[src];startup=1'>\[Bring field online\]</a><br>"
			else
				t += "<b><font color=red>Core Generator unresponsive</font></b><br>"
			t += "<hr>"
			t += "<A href='?src=\ref[src];close=1'>Close</A><BR>"
			user << browse(t, "window=core_monitor;size=500x800")
			user.machine = src
