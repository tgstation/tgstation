<<<<<<< HEAD
#define TANK_DISPENSER_CAPACITY 10

/obj/structure/tank_dispenser
	name = "tank dispenser"
	desc = "A simple yet bulky storage device for gas tanks. Holds up to 10 oxygen tanks and 10 plasma tanks."
	icon = 'icons/obj/objects.dmi'
	icon_state = "dispenser"
	density = 1
	anchored = 1
	var/oxygentanks = TANK_DISPENSER_CAPACITY
	var/plasmatanks = TANK_DISPENSER_CAPACITY

/obj/structure/tank_dispenser/oxygen
	plasmatanks = 0

/obj/structure/tank_dispenser/plasma
	oxygentanks = 0

/obj/structure/tank_dispenser/New()
	for(var/i in 1 to oxygentanks)
		new /obj/item/weapon/tank/internals/oxygen(src)
	for(var/i in 1 to plasmatanks)
		new /obj/item/weapon/tank/internals/plasma(src)
	update_icon()

/obj/structure/tank_dispenser/update_icon()
	cut_overlays()
	switch(oxygentanks)
		if(1 to 3)
			add_overlay("oxygen-[oxygentanks]")
		if(4 to TANK_DISPENSER_CAPACITY)
			add_overlay("oxygen-4")
	switch(plasmatanks)
		if(1 to 4)
			add_overlay("plasma-[plasmatanks]")
		if(5 to TANK_DISPENSER_CAPACITY)
			add_overlay("plasma-5")

/obj/structure/tank_dispenser/attackby(obj/item/I, mob/user, params)
	var/full
	if(istype(I, /obj/item/weapon/tank/internals/plasma))
		if(plasmatanks < TANK_DISPENSER_CAPACITY)
			plasmatanks++
		else
			full = TRUE
	else if(istype(I, /obj/item/weapon/tank/internals/oxygen))
		if(oxygentanks < TANK_DISPENSER_CAPACITY)
			oxygentanks++
		else
			full = TRUE
	else if(user.a_intent != "harm")
		user << "<span class='notice'>[I] does not fit into [src].</span>"
		return
	else
		return ..()
	if(full)
		user << "<span class='notice'>[src] can't hold anymore of [I].</span>"
		return

	if(!user.drop_item())
		return
	I.loc = src
	user << "<span class='notice'>You put [I] in [src].</span>"
	update_icon()

/obj/structure/tank_dispenser/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, \
										datum/tgui/master_ui = null, datum/ui_state/state = physical_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "tank_dispenser", name, 275, 100, master_ui, state)
		ui.open()

/obj/structure/tank_dispenser/ui_data(mob/user)
	var/list/data = list()
	data["oxygen"] = oxygentanks
	data["plasma"] = plasmatanks

	return data

/obj/structure/tank_dispenser/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("plasma")
			var/obj/item/weapon/tank/internals/plasma/tank = locate() in src
			if(tank)
				usr.put_in_hands(tank)
				plasmatanks--
			. = TRUE
		if("oxygen")
			var/obj/item/weapon/tank/internals/oxygen/tank = locate() in src
			if(tank)
				usr.put_in_hands(tank)
				oxygentanks--
			. = TRUE
	update_icon()

#undef TANK_DISPENSER_CAPACITY
=======
/obj/structure/dispenser
	name = "tank storage unit"
	desc = "A simple yet bulky storage device for gas tanks. Has room for up to ten oxygen tanks, and ten plasma tanks."
	icon = 'icons/obj/objects.dmi'
	icon_state = "dispenser"
	density = 1
	anchored = 1.0
	var/oxygentanks = 10
	var/plasmatanks = 10
	var/list/oxytanks = list()	//sorry for the similar var names
	var/list/platanks = list()


/obj/structure/dispenser/oxygen
	plasmatanks = 0

/obj/structure/dispenser/plasma
	oxygentanks = 0

/obj/structure/dispenser/empty
	plasmatanks = 0
	oxygentanks = 0


/obj/structure/dispenser/New()
	. = ..()
	update_icon()


/obj/structure/dispenser/update_icon()
	overlays.len = 0
	switch(oxygentanks)
		if(1 to 3)	overlays += image(icon = icon, icon_state = "oxygen-[oxygentanks]")
		if(4 to INFINITY) overlays += image(icon = icon, icon_state = "oxygen-4")
	switch(plasmatanks)
		if(1 to 4)	overlays += image(icon = icon, icon_state = "plasma-[plasmatanks]")
		if(5 to INFINITY) overlays += image(icon = icon, icon_state = "plasma-5")


/obj/structure/dispenser/attack_robot(mob/user as mob)
	if(isMoMMI(user))
		return attack_hand(user)
	return ..()

/obj/structure/dispenser/attack_hand(mob/user as mob)
	user.set_machine(src)
	var/dat = "[src]<br><br>"

	dat += {"Oxygen tanks: [oxygentanks] - [oxygentanks ? "<A href='?src=\ref[src];oxygen=1'>Dispense</A>" : "empty"]<br>
		Plasma tanks: [plasmatanks] - [plasmatanks ? "<A href='?src=\ref[src];plasma=1'>Dispense</A>" : "empty"]"}
	user << browse(dat, "window=dispenser")
	onclose(user, "dispenser")
	return


/obj/structure/dispenser/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/weapon/tank/oxygen) || istype(I, /obj/item/weapon/tank/air) || istype(I, /obj/item/weapon/tank/anesthetic))
		if(oxygentanks < 10)
			if(user.drop_item(I, src))
				oxytanks.Add(I)
				oxygentanks++
				to_chat(user, "<span class='notice'>You put [I] in [src].</span>")
		else
			to_chat(user, "<span class='notice'>[src] is full.</span>")
		updateUsrDialog()
		return
	if(istype(I, /obj/item/weapon/tank/plasma))
		if(plasmatanks < 10)
			if(user.drop_item(I, src))
				platanks.Add(I)
				plasmatanks++
				to_chat(user, "<span class='notice'>You put [I] in [src].</span>")
		else
			to_chat(user, "<span class='notice'>[src] is full.</span>")
		updateUsrDialog()
		return
	if(iswrench(I))
		if(anchored)
			to_chat(user, "<span class='notice'>You lean down and unwrench [src].</span>")
			playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
			anchored = 0
		else
			to_chat(user, "<span class='notice'>You wrench [src] into place.</span>")
			playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
			anchored = 1
		return

/obj/structure/dispenser/Topic(href, href_list)
	if(usr.stat || usr.restrained())
		return
	if(Adjacent(usr))
		usr.set_machine(src)
		if(href_list["oxygen"])
			if(oxygentanks > 0)
				var/obj/item/weapon/tank/oxygen/O
				if(oxytanks.len == oxygentanks)
					O = oxytanks[1]
					oxytanks.Remove(O)
				else
					O = new /obj/item/weapon/tank/oxygen(loc)
				O.loc = loc
				to_chat(usr, "<span class='notice'>You take [O] out of [src].</span>")
				oxygentanks--
				update_icon()
		if(href_list["plasma"])
			if(plasmatanks > 0)
				var/obj/item/weapon/tank/plasma/P
				if(platanks.len == plasmatanks)
					P = platanks[1]
					platanks.Remove(P)
				else
					P = new /obj/item/weapon/tank/plasma(loc)
				P.loc = loc
				to_chat(usr, "<span class='notice'>You take [P] out of [src].</span>")
				plasmatanks--
				update_icon()
		add_fingerprint(usr)
		updateUsrDialog()
	else
		usr << browse(null, "window=dispenser")
		return
	return
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
