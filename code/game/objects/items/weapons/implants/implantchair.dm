//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/obj/machinery/implantchair
	name = "Loyalty Implanter"
	desc = "Used to implant occupants with loyalty implants."
	icon = 'icons/obj/machines/implantchair.dmi'
	icon_state = "implantchair"
	density = 1
	opacity = 0
	anchored = 1

	var/ready = 1
	var/malfunction = 0
	var/list/obj/item/weapon/implant/loyalty/implant_list = list()
	var/max_implants = 5
	var/injection_cooldown = 600
	var/replenish_cooldown = 6000
	var/replenishing = 0
	var/mob/living/carbon/occupant = null
	var/injecting = 0

	proc
		go_out()
		put_mob(mob/living/carbon/M as mob)
		implant(var/mob/M)
		add_implants()


	New()
		..()
		add_implants()


	attack_hand(mob/user as mob)
		user.set_machine(src)
		var/health_text = ""
		if(src.occupant)
			if(src.occupant.health <= -100)
				health_text = "<FONT color=red>Dead</FONT>"
			else if(src.occupant.health < 0)
				health_text = "<FONT color=red>[round(src.occupant.health,0.1)]</FONT>"
			else
				health_text = "[round(src.occupant.health,0.1)]"

		var/dat ="<B>Implanter Status</B><BR>"

		dat +="<B>Current occupant:</B> [src.occupant ? "<BR>Name: [src.occupant]<BR>Health: [health_text]<BR>" : "<FONT color=red>None</FONT>"]<BR>"
		dat += "<B>Implants:</B> [src.implant_list.len ? "[implant_list.len]" : "<A href='?src=\ref[src];replenish=1'>Replenish</A>"]<BR>"
		if(src.occupant)
			dat += "[src.ready ? "<A href='?src=\ref[src];implant=1'>Implant</A>" : "Recharging"]<BR>"
		user.set_machine(src)
		user << browse(dat, "window=implant")
		onclose(user, "implant")


	Topic(href, href_list)
		if((get_dist(src, usr) <= 1) || istype(usr, /mob/living/silicon/ai))
			if(href_list["implant"])
				if(src.occupant)
					injecting = 1
					go_out()
					ready = 0
					spawn(injection_cooldown)
						ready = 1

			if(href_list["replenish"])
				ready = 0
				spawn(replenish_cooldown)
					add_implants()
					ready = 1

			src.updateUsrDialog()
			src.add_fingerprint(usr)
			return


	attackby(var/obj/item/weapon/G as obj, var/mob/user as mob)
		if(istype(G, /obj/item/weapon/grab))
			if(!ismob(G:affecting))
				return
			for(var/mob/living/carbon/slime/M in range(1,G:affecting))
				if(M.Victim == G:affecting)
					usr << "[G:affecting:name] will not fit into the [src.name] because they have a slime latched onto their head."
					return
			var/mob/M = G:affecting
			if(put_mob(M))
				del(G)
		src.updateUsrDialog()
		return


	go_out(var/mob/M)
		if(!( src.occupant ))
			return
		if(M == occupant) // so that the guy inside can't eject himself -Agouri
			return
		if (src.occupant.client)
			src.occupant.client.eye = src.occupant.client.mob
			src.occupant.client.perspective = MOB_PERSPECTIVE
		src.occupant.loc = src.loc
		if(injecting)
			implant(src.occupant)
			injecting = 0
		src.occupant = null
		icon_state = "implantchair"
		return


	put_mob(mob/living/carbon/M as mob)
		if(!iscarbon(M))
			usr << "\red <B>The [src.name] cannot hold this!</B>"
			return
		if(src.occupant)
			usr << "\red <B>The [src.name] is already occupied!</B>"
			return
		if(M.client)
			M.client.perspective = EYE_PERSPECTIVE
			M.client.eye = src
		M.stop_pulling()
		M.loc = src
		src.occupant = M
		src.add_fingerprint(usr)
		icon_state = "implantchair_on"
		return 1


	implant(var/mob/M)
		if (!istype(M, /mob/living/carbon))
			return
		if(!implant_list.len)	return
		for(var/obj/item/weapon/implant/loyalty/imp in implant_list)
			if(!imp)	continue
			if(istype(imp, /obj/item/weapon/implant/loyalty))
				for (var/mob/O in viewers(M, null))
					O.show_message("\red [M] has been implanted by the [src.name].", 1)

				if(imp.implanted(M))
					imp.loc = M
					imp.imp_in = M
					imp.implanted = 1
				implant_list -= imp
				break
		return


	add_implants()
		for(var/i=0, i<src.max_implants, i++)
			var/obj/item/weapon/implant/loyalty/I = new /obj/item/weapon/implant/loyalty(src)
			implant_list += I
		return

	verb
		get_out()
			set name = "Eject occupant"
			set category = "Object"
			set src in oview(1)
			if(usr.stat != 0)
				return
			src.go_out(usr)
			add_fingerprint(usr)
			return


		move_inside()
			set name = "Move Inside"
			set category = "Object"
			set src in oview(1)
			if(usr.stat != 0 || stat & (NOPOWER|BROKEN))
				return
			put_mob(usr)
			return
