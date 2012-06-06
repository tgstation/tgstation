//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/obj/item/device/assembly/signaler
	name = "Remote Signaling Device"
	desc = "Used to remotely activate devices."
	icon_state = "signaller"
	item_state = "signaler"
	m_amt = 1000
	g_amt = 200
	w_amt = 100
	origin_tech = "magnets=1"
	wires = WIRE_RECEIVE | WIRE_PULSE | WIRE_RADIO_PULSE | WIRE_RADIO_RECEIVE

	secured = 1
	small_icon_state_left = "signaller_left"
	small_icon_state_right = "signaller_right"

	var/code = 30
	var/frequency = 1457
	var/delay = 0
	var/airlock_wire = null
	var/datum/radio_frequency/radio_connection

	proc
		signal()


	New()
		..()
		spawn(40)
			set_frequency(frequency)
		return


	activate()
		if(cooldown > 0)	return 0
		cooldown = 2
		spawn(10)
			process_cooldown()

		signal()
		return 1


	interact(mob/user as mob, flag1)
		var/t1 = "-------"
//		if ((src.b_stat && !( flag1 )))
//			t1 = text("-------<BR>\nGreen Wire: []<BR>\nRed Wire:   []<BR>\nBlue Wire:  []<BR>\n", (src.wires & 4 ? text("<A href='?src=\ref[];wires=4'>Cut Wire</A>", src) : text("<A href='?src=\ref[];wires=4'>Mend Wire</A>", src)), (src.wires & 2 ? text("<A href='?src=\ref[];wires=2'>Cut Wire</A>", src) : text("<A href='?src=\ref[];wires=2'>Mend Wire</A>", src)), (src.wires & 1 ? text("<A href='?src=\ref[];wires=1'>Cut Wire</A>", src) : text("<A href='?src=\ref[];wires=1'>Mend Wire</A>", src)))
//		else
//			t1 = "-------"	Speaker: [src.listening ? "<A href='byond://?src=\ref[src];listen=0'>Engaged</A>" : "<A href='byond://?src=\ref[src];listen=1'>Disengaged</A>"]<BR>
		var/dat = {"
	<TT>

	<A href='byond://?src=\ref[src];send=1'>Send Signal</A><BR>
	<B>Frequency/Code</B> for signaler:<BR>
	Frequency:
	<A href='byond://?src=\ref[src];freq=-10'>-</A>
	<A href='byond://?src=\ref[src];freq=-2'>-</A>
	[format_frequency(src.frequency)]
	<A href='byond://?src=\ref[src];freq=2'>+</A>
	<A href='byond://?src=\ref[src];freq=10'>+</A><BR>

	Code:
	<A href='byond://?src=\ref[src];code=-5'>-</A>
	<A href='byond://?src=\ref[src];code=-1'>-</A>
	[src.code]
	<A href='byond://?src=\ref[src];code=1'>+</A>
	<A href='byond://?src=\ref[src];code=5'>+</A><BR>
	[t1]
	</TT>"}
		user << browse(dat, "window=radio")
		onclose(user, "radio")
		return


	Topic(href, href_list)
		..()

		if(!usr.canmove || usr.stat || usr.restrained() || !in_range(loc, usr))
			usr << browse(null, "window=radio")
			onclose(usr, "radio")
			return

		if (href_list["freq"])
			var/new_frequency = (frequency + text2num(href_list["freq"]))
			if(new_frequency < 1200 || new_frequency > 1600)
				new_frequency = sanitize_frequency(new_frequency)
			set_frequency(new_frequency)

		if(href_list["code"])
			src.code += text2num(href_list["code"])
			src.code = round(src.code)
			src.code = min(100, src.code)
			src.code = max(1, src.code)

		if(href_list["send"])
			spawn( 0 )
				signal()

		if(usr)
			attack_self(usr)

		return


	signal()
		var/datum/signal/signal = new
		signal.source = src
		signal.encryption = code
		signal.data["message"] = "ACTIVATE"
		radio_connection.post_signal(src, signal)
		return
/*
		for(var/obj/item/device/assembly/signaler/S in world)
			if(!S)	continue
			if(S == src)	continue
			if((S.frequency == src.frequency) && (S.code == src.code))
				spawn(0)
					if(S)	S.pulse(0)
		return 0*/


	pulse(var/radio = 0)
		if(istype(src.loc, /obj/machinery/door/airlock) && src.airlock_wire && src.wires)
			var/obj/machinery/door/airlock/A = src.loc
			A.pulse(src.airlock_wire)
		else if(holder)
			holder.process_activation(src, 1, 0)
		return 1


	receive_signal(datum/signal/signal)
		if(!signal)	return 0
		if(signal.encryption != code)	return 0
		if(!(src.wires & WIRE_RADIO_RECEIVE))	return 0
		pulse(1)

		for(var/mob/O in hearers(1, src.loc))
			O.show_message(text("\icon[] *beep* *beep*", src), 3, "*beep* *beep*", 2)
		return


	proc/set_frequency(new_frequency)
		if(!radio_controller)
			sleep(20)
		if(!radio_controller)
			return
		radio_controller.remove_object(src, frequency)
		frequency = new_frequency
		radio_connection = radio_controller.add_object(src, frequency, RADIO_CHAT)
		return
