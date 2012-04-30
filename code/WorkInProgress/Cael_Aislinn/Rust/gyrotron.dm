
//high frequency photon (laser beam)
/obj/item/projectile/beam/ehf_beam

/obj/machinery/rust/gyrotron
	icon = 'gyrotron.dmi'
	icon_state = "emitter-off"
	name = "Gyrotron"
	anchored = 1
	density = 0
	layer = 4
	var/frequency = 1
	var/emitting = 0
	var/rate = 10
	var/mega_energy = 0.001
	var/on = 1
	var/remoteenabled = 1
	//
	req_access = list(access_engine)
	//
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 300

	New()
		..()
		//pixel_x = (dir & 3)? 0 : (dir == 4 ? -24 : 24)
		//pixel_y = (dir & 3)? (dir ==1 ? -24 : 24) : 0

	Topic(href, href_list)
		..()
		if( href_list["close"] )
			usr << browse(null, "window=gyro_monitor")
			usr.machine = null
			return
		if( href_list["modifypower"] )
			var/new_val = text2num(input("Enter new emission power level (0.001 - 0.01)", "Modifying power level (MeV)", mega_energy))
			if(!new_val)
				usr << "\red That's not a valid number."
				return
			new_val = min(new_val,0.01)
			new_val = max(new_val,0.001)
			mega_energy = new_val
			for(var/obj/machinery/computer/rust/gyrotron_controller/comp in range(25))
				comp.updateDialog()
			return
		if( href_list["modifyrate"] )
			var/new_val = text2num(input("Enter new emission rate (1 - 10)", "Modifying emission rate (sec)", rate))
			if(!new_val)
				usr << "\red That's not a valid number."
				return
			new_val = min(new_val,1)
			new_val = max(new_val,10)
			rate = new_val
			for(var/obj/machinery/computer/rust/gyrotron_controller/comp in range(25))
				comp.updateDialog()
			return
		if( href_list["modifyfreq"] )
			var/new_val = text2num(input("Enter new emission frequency (1 - 50000)", "Modifying emission frequency (GHz)", frequency))
			if(!new_val)
				usr << "\red That's not a valid number."
				return
			new_val = min(new_val,1)
			new_val = max(new_val,50000)
			frequency = new_val
			for(var/obj/machinery/computer/rust/gyrotron_controller/comp in range(25))
				comp.updateDialog()
			return
		if( href_list["activate"] )
			emitting = 1
			spawn(rate)
				Emit()
			for(var/obj/machinery/computer/rust/gyrotron_controller/comp in range(25))
				comp.updateDialog()
			return
		if( href_list["deactivate"] )
			emitting = 0
			for(var/obj/machinery/computer/rust/gyrotron_controller/comp in range(25))
				comp.updateDialog()
			return
		if( href_list["enableremote"] )
			remoteenabled = 1
			for(var/obj/machinery/computer/rust/gyrotron_controller/comp in range(25))
				comp.updateDialog()
			return
		if( href_list["disableremote"] )
			remoteenabled = 0
			for(var/obj/machinery/computer/rust/gyrotron_controller/comp in range(25))
				comp.updateDialog()
			return

	proc/Emit()
		var/obj/item/projectile/beam/ehf_beam/A = new ( src.loc )
		A.frequency = frequency
		A.damage = mega_energy * 500
		//
		A.icon_state = "emitter"
		playsound(src.loc, 'emitter.ogg', 25, 1)
		use_power(100 * mega_energy + 500)
		/*if(prob(35))
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(5, 1, src)
			s.start()*/
		A.dir = src.dir
		if(src.dir == 1)//Up
			A.yo = 20
			A.xo = 0
		else if(src.dir == 2)//Down
			A.yo = -20
			A.xo = 0
		else if(src.dir == 4)//Right
			A.yo = 0
			A.xo = 20
		else if(src.dir == 8)//Left
			A.yo = 0
			A.xo = -20
		else // Any other
			A.yo = -20
			A.xo = 0
		A.fired()
		//
		flick("emitter-active",src)
		if(emitting)
			spawn(rate)
				Emit()

	proc/UpdateIcon()
		if(on)
			icon_state = "emitter-on"
		else
			icon_state = "emitter-off"

/obj/machinery/rust/gyrotron/control_panel
	icon_state = "control_panel"
	name = "Control panel"
	var/obj/machinery/rust/gyrotron/owned_gyrotron
	New()
		..()
		pixel_x = -pixel_x
		pixel_y = -pixel_y

	attack_ai(mob/user)
		attack_hand(user)

	attack_hand(mob/user)
		add_fingerprint(user)
		/*if(stat & (BROKEN|NOPOWER))
			return*/
		interact(user)

	proc
		interact(mob/user)
			if ( (get_dist(src, user) > 1 ) || (stat & (BROKEN|NOPOWER)) )
				if (!istype(user, /mob/living/silicon))
					user.machine = null
					user << browse(null, "window=gyro_monitor")
					return
			var/t = "<B>Free electron MASER (Gyrotron) Control Panel</B><BR>"
			if(owned_gyrotron && owned_gyrotron.on)
				t += "<font color=green>Gyrotron operational</font><br>"
				t += "Operational mode: <font color=blue>"
				if(owned_gyrotron.emitting)
					t += "Emitting</font> <a href='?src=\ref[owned_gyrotron];deactivate=1'>\[Deactivate\]</a><br>"
				else
					t += "Not emitting</font> <a href='?src=\ref[owned_gyrotron];activate=1'>\[Activate\]</a><br>"
				t += "Emission rate: [owned_gyrotron.rate] <a href='?src=\ref[owned_gyrotron];modifyrate=1'>\[Modify\]</a><br>"
				t += "Beam frequency: [owned_gyrotron.frequency] <a href='?src=\ref[owned_gyrotron];modifyfreq=1'>\[Modify\]</a><br>"
				t += "Beam power: [owned_gyrotron.mega_energy] <a href='?src=\ref[owned_gyrotron];modifypower=1'>\[Modify\]</a><br>"
			else
				t += "<b><font color=red>Gyrotron unresponsive</font></b>"
			t += "<hr>"
			t += "<A href='?src=\ref[src];close=1'>Close</A><BR>"
			user << browse(t, "window=gyro_monitor;size=500x800")
			user.machine = src
