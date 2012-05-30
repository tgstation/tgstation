//This file was auto-corrected by findeclaration.exe on 29/05/2012 15:03:04

/obj/machinery/computer/aiupload
	name = "AI Upload"
	desc = "Used to upload laws to the AI."
	icon_state = "command"
	circuit = "/obj/item/weapon/circuitboard/aiupload"
	var/mob/living/silicon/ai/current = null
	var/opened = 0


	verb/AccessInternals()
		set category = "Object"
		set name = "Access Computer's Internals"
		set src in oview(1)
		if(get_dist(src, usr) > 1 || usr.restrained() || usr.lying || usr.stat || istype(usr, /mob/living/silicon))
			return

		opened = !opened
		if(opened)
			usr << "\blue The access panel is now open."
		else
			usr << "\blue The access panel is now closed."
		return


	attackby(obj/item/weapon/O as obj, mob/user as mob)
		if(istype(O, /obj/item/weapon/aiModule))
			var/obj/item/weapon/aiModule/M = O
			M.install(src)
		else
			..()


	attack_hand(var/mob/user as mob)
		if(src.stat & NOPOWER)
			usr << "The upload computer has no power!"
			return
		if(src.stat & BROKEN)
			usr << "The upload computer is broken!"
			return

		src.current = activeais()

		if (!src.current)
			usr << "No active AIs detected."
		else
			usr << "[src.current.name] selected for law changes."
		return



/obj/machinery/computer/borgupload
	name = "Cyborg Upload"
	desc = "Used to upload laws to Cyborgs."
	icon_state = "command"
	circuit = "/obj/item/weapon/circuitboard/borgupload"
	var/mob/living/silicon/robot/current = null


	attackby(obj/item/weapon/aiModule/module as obj, mob/user as mob)
		if(istype(module, /obj/item/weapon/aiModule))
			module.install(src)
		else
			return ..()


	attack_hand(var/mob/user as mob)
		if(src.stat & NOPOWER)
			usr << "The upload computer has no power!"
			return
		if(src.stat & BROKEN)
			usr << "The upload computer is broken!"
			return

		src.current = freeborg()

		if (!src.current)
			usr << "No free cyborgs detected."
		else
			usr << "[src.current.name] selected for law changes."
		return

/obj/machinery/computer/aistatus
	name = "AI Status Panel"
	desc = "This shows the status of the AI."
	icon = 'mainframe.dmi'
	icon_state = "left"
//	brightnessred = 0
//	brightnessgreen = 2
//	brightnessblue = 0

/obj/machinery/computer/aistatus/attack_hand(mob/user as mob)
	if(stat & NOPOWER)
		user << "\red The status panel has no power!"
		return
	if(stat & BROKEN)
		user << "\red The status panel is broken!"
		return
	if(!issilicon(user))
		user << "\red You don't understand any of this!"
	else
		user << "\blue You know all of this already, why are you messing with it?"
	return


/obj/machinery/computer/aiupload/mainframe
	name = "AI Mainframe Upload"
	icon = 'mainframe.dmi'
	icon_state = "aimainframe"


/obj/machinery/computer/borgupload/mainframe
	name = "Borg Mainframe Upload"
	icon = 'mainframe.dmi'
	icon_state = "aimainframe"


/*Module Storage Unit/Closet!  Solid, only modules fit in it.*/
/obj/structure/aiuploadcloset
	name = "AI Mainframe Module Storage Unit"
	icon = 'mainframe.dmi'
	icon_state = "right-closed"
	density = 1

	var/open = 0  /*It's closed!*/

/obj/structure/aiuploadcloset/New()
	..()
	new /obj/item/weapon/aiModule/reset(src)
	new /obj/item/weapon/aiModule/purge(src)
	new /obj/item/weapon/aiModule/nanotrasen(src)
	new /obj/item/weapon/aiModule/paladin(src)
	new /obj/item/weapon/aiModule/asimov(src)
	new /obj/item/weapon/aiModule/safeguard(src)
	new /obj/item/weapon/aiModule/protectStation(src)
	new /obj/item/weapon/aiModule/quarantine(src)
	new /obj/item/weapon/aiModule/teleporterOffline(src)
	new /obj/item/weapon/aiModule/oxygen(src)
	new /obj/item/weapon/aiModule/oneHuman(src)
	new /obj/item/weapon/aiModule/freeform(src)
	for(var/obj/item/weapon/aiModule/M in src)
		M.pixel_x = rand(-10, 10)
		M.pixel_y = rand(-10, 10)

/obj/structure/aiuploadcloset/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/aiModule))
		user.drop_item()
		W.loc = get_turf(src)
	else
		return attack_hand(user)

/obj/structure/aiuploadcloset/attack_hand(mob/user as mob)
	if(!open)
		var/temp_count
		for(var/obj/item/weapon/aiModule/M in src)
			M.loc = src.loc
			temp_count++

		user << "\blue You open the module storage unit, [temp_count > 0 ? "and take out all the modules." : "\red but it's empty!"]"
		open = 1
		icon_state = "right-open"

	else
		var/temp_count
		for(var/obj/item/weapon/aiModule/M in get_turf(src))
			M.loc = src
			temp_count++

		user << "\blue [temp_count > 0 ? "You put all the modules back into the module storage unit, and then close it." : "You close the module storage unit."]"
		open = 0
		icon_state = "right-closed"

/obj/structure/aiuploadcloset/ex_act(severity)
	switch(severity)
		if (1)
			for(var/obj/item/weapon/aiModule/M in src)
				M.loc = src.loc
				M.ex_act(severity)
			del(src)
		if (2)
			if (prob(50))
				for(var/obj/item/weapon/aiModule/M in src)
					M.loc = src.loc
					M.ex_act(severity)
				del(src)
		if (3)
			if (prob(5))
				for(var/obj/item/weapon/aiModule/M in src)
					M.loc = src.loc
					M.ex_act(severity)
				del(src)
