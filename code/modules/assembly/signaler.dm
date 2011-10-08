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

	var
		code = 30
		frequency = 100
		delay = 0
		airlock_wire = null

	proc
		send_signal()


	activate()
		if(!..())	return 0//Cooldown check
		signal()
		pulse(0)
		if(istype(src.loc, /obj/machinery/door/airlock) && src.airlock_wire && src.wires)
			var/obj/machinery/door/airlock/A = src.loc
			A.pulse(src.airlock_wire)
//		pulse(1)//?
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
	[src.frequency]
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
		//..()
		if(usr.stat)
			return
		if ((usr.contents.Find(src) || (usr.contents.Find(src.holder) || (in_range(src, usr) && istype(src.loc, /turf)))))
			usr.machine = src
			if (href_list["freq"])
				src.frequency += text2num(href_list["freq"])
				src.frequency = round(src.frequency)
				src.frequency = min(100, src.frequency)
				src.frequency = max(1, src.frequency)
				return

			if(href_list["code"])
				src.code += text2num(href_list["code"])
				src.code = round(src.code)
				src.code = min(100, src.code)
				src.code = max(1, src.code)

			if(href_list["send"])
				spawn( 0 )
					send_signal()
					return

//					if(href_list["listen"])
//						src.listening = text2num(href_list["listen"])
		else
			usr << browse(null, "window=radio")
			return
		return

	proc/signal()//will have to do for now
		for(var/obj/item/device/assembly/signaler/S in world)
			if(!S)	continue
			if(S == src)	continue
			if((S.frequency == src.frequency) && (S.code == src.code))
				S.pulsed(1)
				return 1
		return 0