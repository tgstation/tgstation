/obj/item/device/radio/signaler
	name = "Remote Signaling Device"
	desc = "Used to remotely activate devices."
	icon = 'new_assemblies.dmi'
	icon_state = "signaller"
	item_state = "signaler"
	var/code = 30
	w_class = 1
	frequency = 1457
	var/delay = 0
	var/airlock_wire = null

	var
		secured = 1
		small_icon_state_left = "signaller_left"
		small_icon_state_right = "signaller_right"
		list/small_icon_state_overlays = null
		obj/holder = null
		cooldown = 0//To prevent spam

	proc
		Activate()//Called when this assembly is pulsed by another one
		Secure()//Code that has to happen when the assembly is ready goes here
		Unsecure()//Code that has to happen when the assembly is taken off of the ready state goes here
		Attach_Assembly(var/obj/A, var/mob/user)//Called when an assembly is attacked by another
		Process_cooldown()//Call this via spawn(10) to have it count down the cooldown var


	IsAssembly()
		return 1


	Process_cooldown()
		cooldown--
		if(cooldown <= 0)	return 0
		spawn(10)
			Process_cooldown()
		return 1


	Activate()
		if((!secured) || (cooldown > 0))
			return 0
		cooldown = 2
		send_signal()
		spawn(10)
			Process_cooldown()
		return 0


	Secure()
		if(secured)
			return 0
		secured = 1
		return 1


	Unsecure()
		if(!secured)
			return 0
		secured = 0
		return 1


	Attach_Assembly(var/obj/A, var/mob/user)
		holder = new/obj/item/device/assembly_holder(get_turf(src))
		if(holder:attach(A,src,user))
			user.show_message("\blue You attach the [A.name] to the [src.name]!")
			return 1
		return 0


	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if(W.IsAssembly())
			var/obj/item/device/D = W
			if((!D:secured) && (!src.secured))
				Attach_Assembly(D,user)
		if(isscrewdriver(W))
			if(src.secured)
				Unsecure()
				b_stat = 1
				user.show_message("\blue The [src.name] can now be attached!")
			else
				Secure()
				b_stat = 0
				user.show_message("\blue The [src.name] is ready!")
			return
		else
			..()
		return

/obj/item/device/radio/signaler/attack_self(mob/user as mob, flag1)
	user.machine = src
	interact(user,flag1)

/obj/item/device/radio/signaler/interact(mob/user as mob, flag1)
	var/t1
	if ((src.b_stat && !( flag1 )))
		t1 = text("-------<BR>\nGreen Wire: []<BR>\nRed Wire:   []<BR>\nBlue Wire:  []<BR>\n", (src.wires & 4 ? text("<A href='?src=\ref[];wires=4'>Cut Wire</A>", src) : text("<A href='?src=\ref[];wires=4'>Mend Wire</A>", src)), (src.wires & 2 ? text("<A href='?src=\ref[];wires=2'>Cut Wire</A>", src) : text("<A href='?src=\ref[];wires=2'>Mend Wire</A>", src)), (src.wires & 1 ? text("<A href='?src=\ref[];wires=1'>Cut Wire</A>", src) : text("<A href='?src=\ref[];wires=1'>Mend Wire</A>", src)))
	else
		t1 = "-------"
	var/dat = {"
<TT>
Speaker: [src.listening ? "<A href='byond://?src=\ref[src];listen=0'>Engaged</A>" : "<A href='byond://?src=\ref[src];listen=1'>Disengaged</A>"]<BR>
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

/obj/item/device/radio/signaler/hear_talk()
	return

/obj/item/device/radio/signaler/send_hear()
	return


/obj/item/device/radio/signaler/receive_signal(datum/signal/signal)
	if(cooldown > 0)	return 0
	if(!signal || (signal.encryption != code))	return 0

	if (!( src.wires & 2 ))
		return
	if(istype(src.loc, /obj/machinery/door/airlock) && src.airlock_wire && src.wires & 1)
		var/obj/machinery/door/airlock/A = src.loc
		A.pulse(src.airlock_wire)
	if((src.holder) && (holder.IsAssemblyHolder()) && (secured) && (src.wires & 1))
		spawn(0)
			holder:Process_Activation(src)
			return
//		src.holder.receive_signal(signal)

	for(var/mob/O in hearers(1, src.loc))
		O.show_message(text("\icon[] *beep* *beep*", src), 3, "*beep* *beep*", 2)
	cooldown = 2
	spawn(10)
		Process_cooldown()
	return


/obj/item/device/radio/signaler/proc/send_signal(message="ACTIVATE")

	if(last_transmission && world.time < (last_transmission + TRANSMISSION_DELAY))
		return
	last_transmission = world.time

	if (!( src.wires & 4 ))
		return

	if((usr)&&(ismob(usr)))
		var/time = time2text(world.realtime,"hh:mm:ss")
		lastsignalers.Add("[time] <B>:</B> [usr.key] used [src] @ location ([src.loc.x],[src.loc.y],[src.loc.z]) <B>:</B> [format_frequency(frequency)]/[code]")

	var/datum/signal/signal = new
	signal.source = src
	signal.encryption = code
	signal.data["message"] = message

	radio_connection.post_signal(src, signal)

	return

/obj/item/device/radio/signaler/Topic(href, href_list)
	//..()
	if (usr.stat)
		return
	if ((usr.contents.Find(src) || (usr.contents.Find(src.holder) || (in_range(src, usr) && istype(src.loc, /turf)))))
		usr.machine = src
		if (href_list["freq"])
			..()
			return
		else
			if (href_list["code"])
				src.code += text2num(href_list["code"])
				src.code = round(src.code)
				src.code = min(100, src.code)
				src.code = max(1, src.code)
			else
				if (href_list["send"])
					spawn( 0 )
						src.send_signal("ACTIVATE")
						return
				else
					if (href_list["listen"])
						src.listening = text2num(href_list["listen"])
					else
						if (href_list["wires"])
							var/t1 = text2num(href_list["wires"])
							if (!( istype(usr.equipped(), /obj/item/weapon/wirecutters) ))
								return
							if ((!( src.b_stat ) && !( src.master )))
								return
							if (t1 & 1)
								if (src.wires & 1)
									src.wires &= 65534
								else
									src.wires |= 1
							else
								if (t1 & 2)
									if (src.wires & 2)
										src.wires &= 65533
									else
										src.wires |= 2
								else
									if (t1 & 4)
										if (src.wires & 4)
											src.wires &= 65531
										else
											src.wires |= 4
		src.add_fingerprint(usr)
		if (!src.master)
			if (istype(src.loc, /mob))
				attack_self(src.loc)
			else
				for(var/mob/M in viewers(1, src))
					if (M.client)
						src.attack_self(M)
		else
			if (istype(src.master.loc, /mob))
				src.attack_self(src.master.loc)
			else
				for(var/mob/M in viewers(1, src.master))
					if (M.client)
						src.attack_self(M)
	else
		usr << browse(null, "window=radio")
		return
	return