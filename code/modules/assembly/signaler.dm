/obj/item/device/assembly/signaler
	name = "remote signaling device"
	desc = "Used to remotely activate devices. Allows for syncing when using a secure signaler on another."
	icon_state = "signaller"
	item_state = "signaler"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	materials = list(MAT_METAL=400, MAT_GLASS=120)
	origin_tech = "magnets=1;bluespace=1"
	wires = WIRE_RECEIVE | WIRE_PULSE | WIRE_RADIO_PULSE | WIRE_RADIO_RECEIVE
	attachable = 1

	var/code = 30
	var/frequency = 1457
	var/delay = 0
	var/datum/radio_frequency/radio_connection

/obj/item/device/assembly/signaler/New()
	..()
	spawn(40)
		set_frequency(frequency)


/obj/item/device/assembly/signaler/Destroy()
	SSradio.remove_object(src,frequency)
	return ..()

/obj/item/device/assembly/signaler/activate()
	if(!..())//cooldown processing
		return FALSE
	signal()
	return TRUE

/obj/item/device/assembly/signaler/update_icon()
	if(holder)
		holder.update_icon()
	return

/obj/item/device/assembly/signaler/interact(mob/user, flag1)
	if(is_secured(user))
		var/t1 = "-------"
	//	if ((src.b_stat && !( flag1 )))
	//		t1 = text("-------<BR>\nGreen Wire: []<BR>\nRed Wire:   []<BR>\nBlue Wire:  []<BR>\n", (src.wires & 4 ? text("<A href='?src=\ref[];wires=4'>Cut Wire</A>", src) : text("<A href='?src=\ref[];wires=4'>Mend Wire</A>", src)), (src.wires & 2 ? text("<A href='?src=\ref[];wires=2'>Cut Wire</A>", src) : text("<A href='?src=\ref[];wires=2'>Mend Wire</A>", src)), (src.wires & 1 ? text("<A href='?src=\ref[];wires=1'>Cut Wire</A>", src) : text("<A href='?src=\ref[];wires=1'>Mend Wire</A>", src)))
	//	else
	//		t1 = "-------"	Speaker: [src.listening ? "<A href='byond://?src=\ref[src];listen=0'>Engaged</A>" : "<A href='byond://?src=\ref[src];listen=1'>Disengaged</A>"]<BR>
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


/obj/item/device/assembly/signaler/Topic(href, href_list)
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

/obj/item/device/assembly/signaler/attackby(obj/item/weapon/W, mob/user, params)
	if(issignaler(W))
		var/obj/item/device/assembly/signaler/signaler2 = W
		if(secured && signaler2.secured)
			code = signaler2.code
			frequency = signaler2.frequency
			to_chat(user, "You transfer the frequency and code of \the [signaler2.name] to \the [name]")
	else
		..()

/obj/item/device/assembly/signaler/proc/signal()
	if(!radio_connection) return

	var/datum/signal/signal = new
	signal.source = src
	signal.encryption = code
	signal.data["message"] = "ACTIVATE"
	radio_connection.post_signal(src, signal)

	var/time = time2text(world.realtime,"hh:mm:ss")
	var/turf/T = get_turf(src)
	if(usr)
		GLOB.lastsignalers.Add("[time] <B>:</B> [usr.key] used [src] @ location ([T.x],[T.y],[T.z]) <B>:</B> [format_frequency(frequency)]/[code]")


	return
/*
		for(var/obj/item/device/assembly/signaler/S in world)
			if(!S)
				continue
			if(S == src)
				continue
			if((S.frequency == src.frequency) && (S.code == src.code))
				spawn(0)
					if(S)
						S.pulse(0)
		return 0*/

/obj/item/device/assembly/signaler/receive_signal(datum/signal/signal)
	if(!signal)
		return 0
	if(signal.encryption != code)
		return 0
	if(!(src.wires & WIRE_RADIO_RECEIVE))
		return 0
	pulse(1)
	audible_message("[bicon(src)] *beep* *beep*", null, 1)
	return


/obj/item/device/assembly/signaler/proc/set_frequency(new_frequency)
	if(!SSradio)
		sleep(20)
	if(!SSradio)
		return
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency, GLOB.RADIO_CHAT)
	return

// Embedded signaller used in grenade construction.
// It's necessary because the signaler doens't have an off state.
// Generated during grenade construction.  -Sayu
/obj/item/device/assembly/signaler/reciever
	var/on = FALSE

/obj/item/device/assembly/signaler/reciever/proc/toggle_safety()
	on = !on

/obj/item/device/assembly/signaler/reciever/activate()
	toggle_safety()
	return 1

/obj/item/device/assembly/signaler/reciever/describe()
	return "The radio receiver is [on?"on":"off"]."

/obj/item/device/assembly/signaler/reciever/receive_signal(datum/signal/signal)
	if(!on) return
	return ..(signal)


// Embedded signaller used in anomalies.
/obj/item/device/assembly/signaler/anomaly
	name = "anomaly core"
	desc = "The neutralized core of an anomaly. It'd probably be valuable for research."
	icon_state = "anomaly core"
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'

/obj/item/device/assembly/signaler/anomaly/receive_signal(datum/signal/signal)
	if(!signal)
		return 0
	if(signal.encryption != code)
		return 0
	for(var/obj/effect/anomaly/A in get_turf(src))
		A.anomalyNeutralize()

/obj/item/device/assembly/signaler/anomaly/attack_self()
	return

/obj/item/device/assembly/signaler/cyborg
	origin_tech = null

/obj/item/device/assembly/signaler/cyborg/attackby(obj/item/weapon/W, mob/user, params)
	return
