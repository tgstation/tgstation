<<<<<<< HEAD
//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/obj/machinery/implantchair
	name = "mindshield implanter"
	desc = "Used to implant occupants with mindshield implants."
	icon = 'icons/obj/machines/implantchair.dmi'
	icon_state = "implantchair"
	density = 1
	opacity = 0
	anchored = TRUE

	var/ready = TRUE
	var/replenishing = FALSE

	var/ready_implants = 5
	var/max_implants = 5
	var/injection_cooldown = 600
	var/replenish_cooldown = 6000
	var/implant_type = /obj/item/weapon/implant/mindshield
	var/auto_inject = FALSE
	var/auto_replenish = TRUE
	var/special = FALSE
	var/special_name = "special function"

/obj/machinery/implantchair/New()
	..()
	open_machine()
	update_icon()


/obj/machinery/implantchair/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, \
									datum/tgui/master_ui = null, datum/ui_state/state = notcontained_state)

	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "implantchair", name, 375, 280, master_ui, state)
		ui.open()


/obj/machinery/implantchair/ui_data()
	var/list/data = list()
	data["occupied"] = occupant ? 1 : 0
	data["open"] = state_open

	data["occupant"] = list()
	if(occupant)
		data["occupant"]["name"] = occupant.name
		data["occupant"]["stat"] = occupant.stat

	data["special_name"] = special ? special_name : null
	data["ready_implants"]  = ready_implants
	data["ready"] = ready
	data["replenishing"] = replenishing
	
	return data

/obj/machinery/implantchair/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("door")
			if(state_open)
				close_machine()
			else
				open_machine()
			. = TRUE
		if("implant")
			implant(occupant,usr)
			. = TRUE

/obj/machinery/implantchair/proc/implant(mob/living/carbon/M,mob/user)
	if (!istype(M))
		return
	if(!ready_implants || !ready)
		return
	if(implant_action(M,user))
		ready_implants--
		if(!replenishing && auto_replenish)
			replenishing = TRUE
			addtimer(src,"replenish",replenish_cooldown)
		if(injection_cooldown > 0)
			ready = FALSE
			addtimer(src,"set_ready",injection_cooldown)
	else
		playsound(get_turf(src), 'sound/machines/buzz-sigh.ogg', 25, 1)
	update_icon()

/obj/machinery/implantchair/proc/implant_action(mob/living/carbon/M)
	var/obj/item/weapon/implant/I = new implant_type
	if(I.implant(M))
		visible_message("<span class='warning'>[M] has been implanted by the [name].</span>")
		return 1

/obj/machinery/implantchair/update_icon()
	icon_state = initial(icon_state)
	if(state_open)
		icon_state += "_open"
	if(occupant)
		icon_state += "_occupied"
	if(ready)
		add_overlay("ready")
	else
		cut_overlays()

/obj/machinery/implantchair/proc/replenish()
	if(ready_implants < max_implants)
		ready_implants++
	if(ready_implants < max_implants)
		addtimer(src,"replenish",replenish_cooldown)
	else
		replenishing = FALSE

/obj/machinery/implantchair/proc/set_ready()
	ready = TRUE
	update_icon()

/obj/machinery/implantchair/container_resist()
	var/mob/living/user = usr
	if(state_open)
		return
	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	user << "<span class='notice'>You lean on the back of [src] and start pushing the door open... (this will take about about a minute.)</span>"
	audible_message("<span class='italics'>You hear a metallic creaking from [src]!</span>",hearing_distance = 2)

	if(do_after(user, 600, target = src))
		if(!user || user.stat != CONSCIOUS || user.loc != src || state_open)
			return
		visible_message("<span class='warning'>[user] successfully broke out of [src]!</span>")
		user << "<span class='notice'>You successfully break out of [src]!</span>"
		open_machine()

/obj/machinery/implantchair/relaymove(mob/user)
	container_resist()

/obj/machinery/implantchair/MouseDrop_T(mob/target, mob/user)
	if(user.stat || user.lying || !Adjacent(user) || !user.Adjacent(target) || !iscarbon(target) || !user.IsAdvancedToolUser())
		return
	close_machine(target)

/obj/machinery/implantchair/close_machine(mob/user)
	if((isnull(user) || istype(user)) && state_open)
		..(user)
		if(auto_inject && ready && ready_implants > 0)
			implant(user,null)

/obj/machinery/implantchair/genepurge
	name = "Genetic purifier"
	desc = "Used to purge human genome of foreign influences"
	special = TRUE
	special_name = "Purge genome"
	injection_cooldown = 0
	replenish_cooldown = 300

/obj/machinery/implantchair/genepurge/implant_action(mob/living/carbon/human/H,mob/user)
	if(!istype(H))
		return 0
	H.set_species(/datum/species/human, 1)//lizards go home
	purrbation_remove(H)//remove cats
	H.dna.remove_all_mutations()//hulks out
	return 1


/obj/machinery/implantchair/brainwash
	name = "Neural Imprinter"
	desc = "Used to <s>indoctrinate</s> rehabilitate hardened recidivists."
	special_name = "Imprint"
	injection_cooldown = 3000
	auto_inject = FALSE
	auto_replenish = FALSE
	special = TRUE
	var/objective = "Obey the law. Praise Nanotrasen."
	var/custom = FALSE

/obj/machinery/implantchair/brainwash/implant_action(mob/living/carbon/C,mob/user)
	if(!istype(C) || !C.mind)
		return 0
	if(custom)
		if(!user || !user.Adjacent(src))
			return 0
		objective = stripped_input(usr,"What order do you want to imprint on [C]?","Enter the order","",120)
		message_admins("[key_name_admin(user)] set brainwash machine objective to '[objective]'.")
		log_game("[key_name_admin(user)] set brainwash machine objective to '[objective]'.")
	var/datum/objective/custom_objective = new/datum/objective(objective)
	custom_objective.owner = C.mind
	C.mind.objectives += custom_objective
	C.mind.announce_objectives()
	message_admins("[key_name_admin(user)] brainwashed [key_name_admin(C)] with objective '[objective]'.")
	log_game("[key_name_admin(user)] brainwashed [key_name_admin(C)] with objective '[objective]'.")
	return 1

	
=======
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


		dat += {"<B>Current occupant:</B> [src.occupant ? "<BR>Name: [src.occupant]<BR>Health: [health_text]<BR>" : "<FONT color=red>None</FONT>"]<BR>
			<B>Implants:</B> [src.implant_list.len ? "[implant_list.len]" : "<A href='?src=\ref[src];replenish=1'>Replenish</A>"]<BR>"}
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
					to_chat(usr, "[G:affecting:name] will not fit into the [src.name] because they have a slime latched onto their head.")
					return
			var/mob/M = G:affecting
			if(put_mob(M))
				returnToPool(G)
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
			to_chat(usr, "<span class='danger'>The [src.name] cannot hold this!</span>")
			return
		if(src.occupant)
			to_chat(usr, "<span class='danger'>The [src.name] is already occupied!</span>")
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
					O.show_message("<span class='warning'>[M] has been implanted by the [src.name].</span>", 1)

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
			if(usr.isUnconscious())
				return
			src.go_out(usr)
			add_fingerprint(usr)
			return


		move_inside()
			set name = "Move Inside"
			set category = "Object"
			set src in oview(1)
			if(usr.isUnconscious() || stat & (NOPOWER|BROKEN))
				return
			put_mob(usr)
			return
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
