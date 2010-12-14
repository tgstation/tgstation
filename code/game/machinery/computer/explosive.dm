/obj/machinery/computer/explosive
	name = "Prisoner Management"
	icon = 'computer.dmi'
	icon_state = "explosive"
	req_access = list(access_armory)

	var/id = 0.0
	var/temp = null
	var/status = 0
	var/timeleft = 60
	var/stop = 0.0
	var/screen = 0 // 0 - No Access Denied, 1 - Access allowed

/obj/machinery/computer/explosive/attackby(I as obj, user as mob)
	if(istype(I, /obj/item/weapon/screwdriver))
		playsound(src.loc, 'Screwdriver.ogg', 50, 1)
		if(do_after(user, 20))
			if (src.stat & BROKEN)
				user << "\blue The broken glass falls out."
				var/obj/computerframe/A = new /obj/computerframe( src.loc )
				new /obj/item/weapon/shard( src.loc )
				var/obj/item/weapon/circuitboard/explosive/M = new /obj/item/weapon/circuitboard/explosive( A )
				for (var/obj/C in src)
					C.loc = src.loc
				M.id = src.id
				A.circuit = M
				A.state = 3
				A.icon_state = "3"
				A.anchored = 1
				del(src)
			else
				user << "\blue You disconnect the monitor."
				var/obj/computerframe/A = new /obj/computerframe( src.loc )
				var/obj/item/weapon/circuitboard/explosive/M = new /obj/item/weapon/circuitboard/explosive( A )
				for (var/obj/C in src)
					C.loc = src.loc
				M.id = src.id
				A.circuit = M
				A.state = 4
				A.icon_state = "4"
				A.anchored = 1
				del(src)

	//else
	src.attack_hand(user)
	return

/obj/machinery/computer/explosive/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/explosive/attack_paw(var/mob/user as mob)

	return src.attack_hand(user)
	return

/obj/machinery/computer/explosive/attack_hand(var/mob/user as mob)
	if(..())
		return
	user.machine = src
	var/dat
	dat += "<B>Prisoner Implant Manager System</B><BR>"
	if(screen == 0)
		dat += "<HR><A href='?src=\ref[src];lock=1'>Unlock Console</A>"
	else if(screen == 1)
		for(var/obj/item/weapon/implant/explosive/E in world)
			if(!E.implanted) continue
			dat += "[E.imp_in.name] | "
			dat += "<A href='?src=\ref[src];killimplant=\ref[E]'>(<font color=red><i>Detonate</i></font>)</A> | "
			dat += "<A href='?src=\ref[src];disable=\ref[E]'>(<font color=red><i>Deactivate</i></font>)</A> | "
			dat += "<A href='?src=\ref[src];warn=\ref[E]'>(<font color=red><i>Warn</i></font>)</A> |<BR>"
		dat += "<HR><A href='?src=\ref[src];lock=1'>Lock Console</A>"

	user << browse(dat, "window=computer;size=400x500")
	onclose(user, "computer")
	return

/obj/machinery/computer/engine/process()
	if(stat & (NOPOWER|BROKEN))
		return
	use_power(500)
	src.updateDialog()
	return

/obj/machinery/computer/explosive/Topic(href, href_list)
	if(..())
		return
	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon)))
		usr.machine = src
		if (href_list["killimplant"])
			var/obj/item/weapon/implant/I = locate(href_list["killimplant"])
			var/mob/living/carbon/R = I.imp_in
			if(R)
				var/choice = input("Are you certain you wish to detonate [R.name]?") in list("Confirm", "Abort")
				if(choice == "Confirm")
					R << "You hear quiet beep from the base of your skull."
					message_admins("\blue [key_name_admin(usr)] gibbed [R.name]")
					if(prob(95))
						R.gib()
					else
						R << "\blue you hear a click as the implant fails to detonate and disintegrates."

		else if (href_list["disable"])
			var/choice = input("Are you certain you wish to deactivate the implant?") in list("Confirm", "Abort")
			if(choice == "Confirm")
				var/obj/item/weapon/implant/I = locate(href_list["disable"])
				var/mob/living/carbon/R = I.imp_in
				R << "You hear quiet beep from the base of your skull."
				if(prob(1))
					message_admins("\blue [key_name_admin(usr)] attempted to disarm [R.name]' implant but it glitched. Oops.")
					R.gib()
				else
					R << "\blue you hear a click as the implant disintegrates."
					del(I)

		else if (href_list["lock"])
			if(src.allowed(usr))
				screen = !screen
			else
				usr << "Unauthorized Access."

		else if (href_list["warn"])
			var/warning = input(usr,"Message:","Enter your message here!","")
			var/obj/item/weapon/implant/I = locate(href_list["warn"])
			var/mob/living/carbon/R = I.imp_in
			R << "\green You hear a voice in your head saying: '[warning]'"

		src.add_fingerprint(usr)
	src.updateUsrDialog()
	return


