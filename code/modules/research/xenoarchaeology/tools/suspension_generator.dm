/obj/machinery/suspension_gen
	name = "suspension field generator"
	desc = "It has stubby legs bolted up against it's body for stabilising."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "suspension2"
	density = 1
	req_access = list(access_research)
	var/obj/item/weapon/cell/cell
	var/obj/item/weapon/card/id/auth_card
	var/locked = 1
	var/open = 0
	var/screwed = 1
	var/field_type = ""
	var/power_use = 25
	var/obj/effect/suspension_field/suspension_field
	var/list/secured_mobs = list()

/obj/machinery/suspension_gen/New()
	src.cell = new/obj/item/weapon/cell/high(src)
	..()

/obj/machinery/suspension_gen/process()
	set background = 1

	if (suspension_field)
		cell.charge -= power_use

		var/turf/T = get_turf(suspension_field)
		if(field_type == "carbon")
			for(var/mob/living/carbon/M in T)
				M.weakened = max(M.weakened, 3)
				cell.charge -= power_use
				if(prob(5))
					M << "\blue [pick("You feel tingly.","You feel like floating.","It is hard to speak.","You can barely move.")]"

		if(field_type == "iron")
			for(var/mob/living/silicon/M in T)
				M.weakened = max(M.weakened, 3)
				cell.charge -= power_use
				if(prob(5))
					M << "\blue [pick("You feel tingly.","You feel like floating.","It is hard to speak.","You can barely move.")]"

		for(var/obj/item/I in T)
			if(!suspension_field.contents.len)
				suspension_field.icon_state = "energynet"
				suspension_field.overlays += "shield2"
			I.loc = suspension_field

		for(var/mob/living/simple_animal/M in T)
			M.weakened = max(M.weakened, 3)
			cell.charge -= power_use
			if(prob(5))
				M << "\blue [pick("You feel tingly.","You feel like floating.","It is hard to speak.","You can barely move.")]"

		if(cell.charge <= 0)
			deactivate()

/obj/machinery/suspension_gen/interact(mob/user as mob)
	var/dat = "<b>Multi-phase mobile suspension field generator MK II \"Steadfast\"</b><br>"
	if(cell)
		var/colour = "red"
		if(cell.charge / cell.maxcharge > 0.66)
			colour = "green"
		else if(cell.charge / cell.maxcharge > 0.33)
			colour = "orange"
		dat += "<b>Energy cell</b>: <font color='[colour]'>[100 * cell.charge / cell.maxcharge]%</font><br>"
	else
		dat += "<b>Energy cell</b>: None<br>"
	if(auth_card)
		dat += "<A href='?src=\ref[src];ejectcard=1'>\[[auth_card]\]<a><br>"
		if(!locked)
			dat += "<b><A href='?src=\ref[src];toggle_field=1'>[suspension_field ? "Disable" : "Enable"] field</a></b><br>"
		else
			dat += "<br>"
	else
		dat += "<A href='?src=\ref[src];insertcard=1'>\[------\]<a><br>"
		if(!locked)
			dat += "<b><A href='?src=\ref[src];toggle_field=1'>[suspension_field ? "Disable" : "Enable"] field</a></b><br>"
		else
			dat += "Enter your ID to begin.<br>"

	dat += "<hr>"
	if(!locked)
		dat += "<b>Select field mode</b><br>"
		dat += "[field_type=="carbon"?"<b>":""			]<A href='?src=\ref[src];select_field=carbon'>Diffracted carbon dioxide laser</A></b><br>"
		dat += "[field_type=="nitrogen"?"<b>":""		]<A href='?src=\ref[src];select_field=nitrogen'>Nitrogen tracer field</A></b><br>"
		dat += "[field_type=="potassium"?"<b>":""		]<A href='?src=\ref[src];select_field=potassium'>Potassium refrigerant cloud</A></b><br>"
		dat += "[field_type=="mercury"?"<b>":""	]<A href='?src=\ref[src];select_field=mercury'>Mercury dispersion wave</A></b><br>"
		dat += "[field_type=="iron"?"<b>":""		]<A href='?src=\ref[src];select_field=iron'>Iron wafer conduction field</A></b><br>"
		dat += "[field_type=="calcium"?"<b>":""	]<A href='?src=\ref[src];select_field=calcium'>Calcium binary deoxidiser</A></b><br>"
		dat += "[field_type=="plasma"?"<b>":""	]<A href='?src=\ref[src];select_field=chlorine'>Chlorine diffusion emissions</A></b><br>"
		dat += "[field_type=="plasma"?"<b>":""	]<A href='?src=\ref[src];select_field=plasma'>Plasma saturated field</A></b><br>"
	else
		dat += "<br>"
		dat += "<br>"
		dat += "<br>"
		dat += "<br>"
		dat += "<br>"
		dat += "<br>"
		dat += "<br>"
		dat += "<br>"
	dat += "<hr>"
	dat += "<font color='blue'><b>Always wear safety gear and consult a field manual before operation.</b></font><br>"
	if(!locked)
		dat += "<A href='?src=\ref[src];lock=1'>Lock console</A><br>"
	else
		dat += "<br>"
	dat += "<A href='?src=\ref[src];refresh=1'>Refresh console</A><br>"
	dat += "<A href='?src=\ref[src];close=1'>Close console</A>"
	user << browse(dat, "window=suspension;size=500x400")
	onclose(user, "suspension")

/obj/machinery/suspension_gen/Topic(href, href_list)
	..()
	usr.set_machine(src)

	if(href_list["toggle_field"])
		if(!suspension_field)
			if(cell.charge > 0)
				if(anchored)
					activate()
				else
					usr << "<span class='warning'>You are unable to activate [src] until it is properly secured on the ground.</span>"
		else
			deactivate()
	if(href_list["select_field"])
		field_type = href_list["select_field"]
	else if(href_list["insertcard"])
		var/obj/item/I = usr.get_active_hand()
		if (istype(I, /obj/item/weapon/card))
			usr.drop_item()
			I.loc = src
			auth_card = I
			if(attempt_unlock(I))
				usr << "<span class='info'>You insert [I], the console flashes \'<i>Access granted.</a>\'</span>"
			else
				usr << "<span class='warning'>You insert [I], the console flashes \'<i>Access denied.</a>\'</span>"
	else if(href_list["ejectcard"])
		if(auth_card)
			if(ishuman(usr))
				auth_card.loc = usr.loc
				if(!usr.get_active_hand())
					usr.put_in_hands(auth_card)
				auth_card = null
			else
				auth_card.loc = loc
				auth_card = null
	else if(href_list["lock"])
		locked = 1
	else if(href_list["close"])
		usr.unset_machine()
		usr << browse(null, "window=suspension")

	updateUsrDialog()

/obj/machinery/suspension_gen/attack_hand(mob/user as mob)
	if(!open)
		interact(user)
	else if(cell)
		cell.loc = loc
		cell.add_fingerprint(user)
		cell.updateicon()

		icon_state = "suspension0"
		cell = null
		user << "<span class='info'>You remove the power cell</span>"

/obj/machinery/suspension_gen/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/screwdriver))
		if(!open)
			if(screwed)
				screwed = 0
			else
				screwed = 1
			user << "<span class='info'>You [screwed ? "screw" : "unscrew"] the battery panel.</span>"
	else if (istype(W, /obj/item/weapon/crowbar))
		if(!locked)
			if(!screwed)
				if(!suspension_field)
					if(open)
						open = 0
					else
						open = 1
					user << "<span class='info'>You crowbar the battery panel [open ? "open" : "in place"].</span>"
					icon_state = "suspension[open ? (cell ? "1" : "0") : "2"]"
				else
					user << "<span class='warning'>[src]'s safety locks are engaged, shut it down first.</span>"
			else
				user << "<span class='warning'>Unscrew [src]'s battery panel first.</span>"
		else
			user << "<span class='warning'>[src]'s security locks are engaged.</span>"
	else if (istype(W, /obj/item/weapon/wrench))
		if(!suspension_field)
			if(anchored)
				anchored = 0
			else
				anchored = 1
			user << "<span class='info'>You wrench the stabilising legs [anchored ? "into place" : "up against the body"].</span>"
			if(anchored)
				desc = "It is resting securely on four stubby legs."
			else
				desc = "It has stubby legs bolted up against it's body for stabilising."
		else
			user << "<span class='warning'>You are unable to secure [src] while it is active!</span>"
	else if (istype(W, /obj/item/weapon/cell))
		if(open)
			if(cell)
				user << "<span class='warning'>There is a power cell already installed.</span>"
			else
				user.drop_item()
				W.loc = src
				cell = W
				user << "<span class='info'>You insert the power cell.</span>"
				icon_state = "suspension1"
	else if(istype(W, /obj/item/weapon/card))
		var/obj/item/weapon/card/I = W
		if(!auth_card)
			if(attempt_unlock(I))
				user << "<span class='info'>You swipe [I], the console flashes \'<i>Access granted.</i>\'</span>"
			else
				user << "<span class='warning'>You swipe [I], console flashes \'<i>Access denied.</i>\'</span>"
		else
			user << "<span class='warning'>Remove [auth_card] first.</span>"

/obj/machinery/suspension_gen/proc/attempt_unlock(var/obj/item/weapon/card/C)
	if(!open)
		if(istype(C, /obj/item/weapon/card/emag) && cell.charge > 0)
			//put sparks here
			if(prob(95))
				locked = 0
		else if(istype(C, /obj/item/weapon/card/id) && check_access(C))
			locked = 0

		if(!locked)
			return 1

//checks for whether the machine can be activated or not should already have occurred by this point
/obj/machinery/suspension_gen/proc/activate()
	//depending on the field type, we might pickup certain items
	var/turf/T = get_turf(get_step(src,dir))
	var/success = 0
	var/collected = 0
	switch(field_type)
		if("carbon")
			success = 1
			for(var/mob/living/carbon/C in T)
				C.weakened += 5
				C.visible_message("\blue \icon[C] [C] begins to float in the air!","You feel tingly and light, but it is difficult to move.")
		if("nitrogen")
			success = 1
			//
		if("mercury")
			success = 1
			//
		if("chlorine")
			success = 1
			//
		if("potassium")
			success = 1
			//
		if("plasma")
			success = 1
			//
		if("calcium")
			success = 1
			//
		if("iron")
			success = 1
			for(var/mob/living/silicon/R in T)
				R.weakened += 5
				R.visible_message("\blue \icon[R] [R] begins to float in the air!","You feel tingly and light, but it is difficult to move.")
			//
	//in case we have a bad field type
	if(!success)
		return

	for(var/mob/living/simple_animal/C in T)
		C.visible_message("\blue \icon[C] [C] begins to float in the air!","You feel tingly and light, but it is difficult to move.")
		C.weakened += 5

	suspension_field = new(T)
	suspension_field.field_type = field_type
	src.visible_message("\blue \icon[src] [src] activates with a low hum.")
	icon_state = "suspension3"

	for(var/obj/item/I in T)
		I.loc = suspension_field
		collected++

	if(collected)
		suspension_field.icon_state = "energynet"
		suspension_field.overlays += "shield2"
		src.visible_message("\blue \icon[suspension_field] [suspension_field] gently absconds [collected > 1 ? "something" : "several things"].")
	else
		if(istype(T,/turf/simulated/mineral) || istype(T,/turf/simulated/wall))
			suspension_field.icon_state = "shieldsparkles"
		else
			suspension_field.icon_state = "shield2"

/obj/machinery/suspension_gen/proc/deactivate()
	//drop anything we picked up
	var/turf/T = get_turf(suspension_field)

	for(var/mob/M in T)
		M << "<span class='info'>You no longer feel like floating.</span>"
		M.weakened = min(M.weakened, 3)

	src.visible_message("\blue \icon[src] [src] deactivates with a gentle shudder.")
	del(suspension_field)
	icon_state = "suspension2"

/obj/machinery/suspension_gen/Del()
	//safety checks: clear the field and drop anything it's holding
	deactivate()
	..()

/obj/machinery/suspension_gen/verb/toggle()
	set src in view(1)
	set name = "Rotate suspension gen (clockwise)"
	set category = "IC"

	if(anchored)
		usr << "\red You cannot rotate [src], it has been firmly fixed to the floor."
	else
		dir = turn(dir, 90)

/obj/effect/suspension_field
	name = "energy field"
	icon = 'icons/effects/effects.dmi'
	anchored = 1
	density = 1
	var/field_type = "chlorine"

/obj/effect/suspension_field/Del()
	for(var/obj/I in src)
		I.loc = src.loc
	..()
